local BasePlugin = require "kong.plugins.base_plugin"
local UpstreamJWT = BasePlugin:extend()
local tokens = require "kong.plugins.upstream-token-auth.tokens"
local jsontokens = require "kong.plugins.upstream-token-auth.tokens-json"
local socket = require "socket"
local kong = kong

UpstreamJWT.PRIORITY = 811
UpstreamJWT.VERSION = "1.0.0"

function UpstreamJWT:new()
    UpstreamJWT.super.new(self, "upstream-jwt")
end

local function split(s, delimiter)
    local splitResult = {};
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(splitResult, match);
    end
    return splitResult;
end

local function splitTable(s)
    local splitTableResult = {};
    for _, v in pairs(s) do
        local i, _ = string.find(v, ":")
        splitTableResult[string.sub(v, 1, i - 1)] = string.sub(v, i + 1, #v)
    end
    return splitTableResult
end

local function cachedToken(parameters, headers, tokenURL, tokenexpiry, requesttype, responsetype, tokenpath)
    local cachekey = ""

    -- Creating a cache key with the parameters
    for k, _ in pairs(parameters) do
        cachekey = cachekey .. parameters[k]
    end
    local err, res
    local expirytime

    for _ = 1, 2 do
        if  requesttype == "json" then
            res, err = kong.cache:get(cachekey, nil, jsontokens.get_access_token, tokenURL, parameters, headers, responsetype, tokenpath)
        else
            res, err = kong.cache:get(cachekey, nil, tokens.get_access_token, tokenURL, parameters, headers, responsetype, tokenpath)
        end 

        expirytime = (res.current_time + tokenexpiry) - socket.gettime()
        kong.log.notice("Token expires in : " .. expirytime)
        -- preventively ask for new access token if about to expire
        if res and res.current_time and ((res.current_time + tokenexpiry) - socket.gettime()) < 20 then
            kong.cache:invalidate_local(cachekey)
            kong.log.notice("Invalidated cachekey : " .. cachekey)
            kong.response.set_header("X-Token-Expired", (res.current_time + tokenexpiry) - socket.gettime())
        elseif res and res.access_token then
            break
        else
            kong.cache:invalidate_local(cachekey)
            return kong.response.exit(401, res or err)
        end
    end
    kong.response.set_header("X-Token-Expires-In", (res.current_time + tokenexpiry) - socket.gettime())
    return res.access_token
end

local function nonCachedToken(parameters, headers, tokenURL, requesttype, responsetype, tokenpath)
    if  requesttype == "json" then
        local authToken = jsontokens.get_access_token(tokenURL, parameters, headers, responsetype, tokenpath)
        return authToken.access_token
    else
        local authToken = tokens.get_access_token(tokenURL, parameters, headers, responsetype, tokenpath)
        return authToken.access_token
    end 
   
end

function UpstreamJWT:access(conf)
    UpstreamJWT.super.access(self)

    local headers = {}
    local tokenURL = conf.token_url
    local tokenexpiry = conf.tokenexpiry
    local tokentype = conf.tokentype
    local responsetype = conf.responsetype
    local requesttype = conf.requesttype
    local tokenpath = conf.tokenpath

    local parametersList = split(conf.parameters, ",")
    local parameters = splitTable(parametersList)

    if (conf.headers) then
        local headersList = split(conf.headers, ",")
        headers = splitTable(headersList)
    end

    local access_token
    if (tokenexpiry) then
        kong.log.notice("Token expiry flow " .. tokenexpiry)
        access_token = cachedToken(parameters, headers, tokenURL, tokenexpiry, requesttype, responsetype, tokenpath)
    else
        access_token = nonCachedToken(parameters, headers, tokenURL, requesttype, responsetype, tokenpath)
    end

    if (tokentype) then
        kong.service.request.set_header("Authorization", conf.tokentype .. access_token)
        kong.log.notice("Authorization with token type : " .. conf.tokentype .. access_token)
    else
        kong.service.request.set_header("Authorization", access_token)
        kong.log.notice("Authorization with token type : " .. access_token)
    end
end

function UpstreamJWT:header_filter(conf)
    local status = kong.response.get_status()
    -- If auth doesn't work, delete token from cache
    if status == 401 and kong.response.get_source() == "service" and conf.tokenexpiry then
        local cachekey = ""
        local parametersList = split(conf.parameters, ",")
        local parameters = splitTable(parametersList)
        -- Creating a cache key with the parameters
        for k, _ in pairs(parameters) do
            cachekey = cachekey .. parameters[k]
        end
        kong.log.notice("Invalidated cachekey in header_filter phase: " .. cachekey)
        kong.cache:invalidate(cachekey)
    end
end

return UpstreamJWT