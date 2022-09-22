{\rtf1\ansi\ansicpg1252\cocoartf1671\cocoasubrtf600
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 # Upstream Token Auth - Kong Plugin\
\
# Getting Started\
\
This plugin allows integrating with the upstream service to get the auth token which in turn sets the custom Auth header. All this process happens as a side call before the traffic hitting the actual backend application. This plugin by default won't cache the auth token received from the upstream server but token expiry can be supplied as an input during design time.\
This plugin supports different request and response formats which are listed below.\
\
Form Parameter Request<br />\
Json Request<br />\
Json Response<br />\
Plain Text Response<br />\
\
| Parameter      | Type |Required|Description |\
| ----------- | ----------- |----------- |----------------------- |\
| token_url      | String       |True | Defines the upstream token endpoint, provide the complete end point Ex : "https://api.twitter.com/oauth/authorize"\
| parameters   | String        |True | Defines the input to the upstream token API. Multiple key value pairs can be enabled , key:value pair separated by a comma. These parameters will form the request payload for the Token API call. Ex : key1:value1,key2:value2,key3:value3\
| tokentype   | String        | False | Defines the type of token return by the Authorization Server Ex : "access_token" or "Bearer "\
| tokenexpiry   | Number        |False | Defines the token expiry time in seconds Ex : 900\
| headers   | String        |False | Defines the additional custom headers required by upstream token API. Multiple headername value pairs can be enabled , headername:value pair separated by a comma. These headers will be added to  the request payload for the Token API call. Ex : headername1:value1,headername2:value2,headername3:value3\
| responsetype   | String        |False | Defines the response content-type expected from the Authorization server. Supported types : "json" , "text"\
| requesttype   | String        |False | Defines the request content-type  expected by the Authorization server. Supported types : "json" , "formparam"\
| tokenpath   | String        |False | This parameter defines the jsonpath of the token ,in the Authorization server response. Can be used only if the responsetype is "json" Ex : "responseObject.accessToken"\
\
Steps to use this plugin\
---\
\
Create a service\
\
```\
curl -i -X POST \\\
 --url http://localhost:8001/services/ \\\
 --data 'name=http-bin' \\\
 --data 'url=https://httpbin.org'\
 ```\
 \
 Create a Route\
 \
 ```\
 curl -i -X POST \\\
 --url http://localhost:8001/services/http-bin/routes \\\
 --data 'hosts[]=example.com' \
 ```\
 \
 1) Add plugin to service - When request type is form param and response type is json.\
 \
 ```\
 curl -X POST http://localhost:8001/services/http-bin/plugins \\\
--data "name=upstream-token-auth" \\\
--data "config.token_url=token_url" \\\
--data "config.tokentype=Bearer " \\\
--data "config.parameters=parameters" \\\
--data "config.tokenexpiry=tokenexpiry" \\\
--data "config.responsetype=json" \\\
--data "config.requesttype=formparam" \
```\
\
In this case user can send parameters in comma separated key value pairs. Request will be sent to upstream as formparam and response will be read from json.\
\
\
\
Test API\
\
```\
curl -v -H "Host: example.com" 'http://localhost:8000/get'\
```\
\
 2) Add plugin to service - When request type is json and response type is json\
 \
 ```\
 curl -X POST http://localhost:8001/services/http-bin/plugins \\\
--data "name=upstream-token-auth" \\\
--data "config.token_url=token_url" \\\
--data "config.tokentype=Bearer " \\\
--data "config.parameters=parameters" \\\
--data "config.tokenexpiry=tokenexpiry" \\\
--data "config.responsetype=json" \\\
--data "config.requesttype=json" \
```\
\
In this case user can send parameters in comma separated key value pairs. Request will be sent to upstream as json and response will be read from json.\
\
Test API\
\
```\
curl -v -H "Host: example.com" 'http://localhost:8000/get'\
```\
\
 3) Add plugin to service - When request type is json and response type is text\
 \
 ```\
 curl -X POST http://localhost:8001/services/http-bin/plugins \\\
--data "name=upstream-token-auth" \\\
--data "config.token_url=token_url" \\\
--data "config.tokentype=Bearer " \\\
--data "config.parameters=parameters" \\\
--data "config.tokenexpiry=tokenexpiry" \\\
--data "config.responsetype=text" \\\
--data "config.requesttype=json" \
```\
\
In this case user can send parameters in comma separated key value pairs. Request will be sent to upstream as json and response will be read from plain text.\
\
Test API\
\
```\
curl -v -H "Host: example.com" 'http://localhost:8000/get'\
```\
\
Contributers\
---\
\
| Name               | Email           \
| -------------      |:-------------\
| Mayank Murari      | mayank.murari@gmail.com \
| Siddharth Saikumar | sidshar88@gmail.com     \
\
\
 }