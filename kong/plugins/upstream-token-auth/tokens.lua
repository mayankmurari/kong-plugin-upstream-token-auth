local http = require "socket.http"
local https = require "ssl.https"
local urlmodule = require "socket.url"
local ltn12 = require "ltn12"
local socket = require "socket"
local cjson_safe = require "cjson.safe"
local kong = kong

local function get_access_token(url, parameters, incomingheaders, responsetype, tokenpath)
    local parsed = urlmodule.parse(url)
    local request
    if parsed.scheme == "https" then
        request = https.request
    else
        request = http.request
    end
    local req_body = ngx.encode_args(parameters)
    local res_body = {}
    local headers = {}

    if (incomingheaders) then
        headers = incomingheaders
        headers["Content-Type"] = "application/x-www-form-urlencoded"
        headers["Content-Length"] = tostring(#req_body)
    else
        headers["Content-Type"] = "application/x-www-form-urlencoded"
        headers["Content-Length"] = tostring(#req_body)
    end

    local _, status = request({
        method = "POST",
        source = ltn12.source.string(req_body),
        headers = headers,
        url = url,
        port = parsed.port,
        sink = ltn12.sink.table(res_body)
    })

    local access_token = table.concat(res_body)

    local token
    if responsetype == "json" then
        local res_json, _ = cjson_safe.decode(access_token) 
        if(tokenpath) then 
            token = assert(load("return " .. tokenpath, nil, "t", res_json))() 
            kong.log.notice("Token from UserPath:", token)
        else
            token = res_json.access_token
            kong.log.notice("Token from Default Path:", token)
        end
    else
        token = access_token
        kong.log.notice("Token from Text Response", token)
    end


    local curtime = socket.gettime()
    if status == 200 then
        return {
            access_token = token,
            current_time = curtime
        }
    end
    kong.log.notice("Upstream HTTP Status : " .. status)
    kong.response.exit(401, res_body)
    return {
        status = status,
        error = "Can't get tokens: bad response code",
        response = res_body
    }
end

return {
    get_access_token = get_access_token
}