# Upstream Token Auth - Kong Plugin

# Getting Started

This plugin allows integrating with the upstream service to get the auth token which in turn sets the custom Auth header. All this process happens as a side call before the traffic hitting the actual backend application. This plugin by default won't cache the auth token received from the upstream server but token expiry can be supplied as an input during design time.
This plugin supports different request and response formats which are listed below.

Form Parameter Request<br />
Json Request<br />
Json Response<br />
Plain Text Response<br />

Steps to use this plugin
---

Create a service

```
curl -i -X POST \
 --url http://localhost:8001/services/ \
 --data 'name=http-bin' \
 --data 'url=https://httpbin.org'
 ```
 
 Create a Route
 
 ```
 curl -i -X POST \
 --url http://localhost:8001/services/http-bin/routes \
 --data 'hosts[]=example.com' 
 ```
 
 1) Add plugin to service - When request type is form param and response type is json.
 
 ```
 curl -X POST http://localhost:8001/services/http-bin/plugins \
--data "name=upstream-token-auth" \
--data "config.token_url=token_url" \
--data "config.tokentype=Bearer " \
--data "config.parameters=parameters" \
--data "config.tokenexpiry=tokenexpiry" \
--data "config.responsetype=json" \
--data "config.requesttype=formparam" 
```

In this case user can send parameters in comma separated key value pairs. Request will be sent to upstream as formparam and response will be read from json.

Test API

```
curl -v -H "Host: example.com" 'http://localhost:8000/get'
```

 2) Add plugin to service - When request type is json and response type is json
 
 ```
 curl -X POST http://localhost:8001/services/http-bin/plugins \
--data "name=upstream-token-auth" \
--data "config.token_url=token_url" \
--data "config.tokentype=Bearer " \
--data "config.parameters=parameters" \
--data "config.tokenexpiry=tokenexpiry" \
--data "config.responsetype=json" \
--data "config.requesttype=json" 
```

In this case user can send parameters in comma separated key value pairs. Request will be sent to upstream as json and response will be read from json.

Test API

```
curl -v -H "Host: example.com" 'http://localhost:8000/get'
```

 3) Add plugin to service - When request type is json and response type is text
 
 ```
 curl -X POST http://localhost:8001/services/http-bin/plugins \
--data "name=upstream-token-auth" \
--data "config.token_url=token_url" \
--data "config.tokentype=Bearer " \
--data "config.parameters=parameters" \
--data "config.tokenexpiry=tokenexpiry" \
--data "config.responsetype=text" \
--data "config.requesttype=json" 
```

In this case user can send parameters in comma separated key value pairs. Request will be sent to upstream as json and response will be read from plain text.

Test API

```
curl -v -H "Host: example.com" 'http://localhost:8000/get'
```

Contributers
---

| Name               | Email           
| -------------      |:-------------
| Mayank Murari      | mayank.murari@gmail.com 
| Siddharth Saikumar |       


 
