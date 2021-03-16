---
title: HTTP Options
---

 * `progress` is a Lua callback function that receives two numeric arguments representing total and current download progress in bytes.
 * `headers` is a Lua table with HTTP headers to be used on the request.
 * `userpwd` is a username and optional password in the format of username:password which will be used to authenticate the request
 * `username` is the username which will be used to authenticate the request
 * `password` is the password which will be used to authenticate the request
 * `timeout` is the timeout in seconds.
 * `timeoutms` is the timeout in milliseconds.
 * `sslverifyhost` Verify the host name in the SSL certificate. See [CURLOPT_SSL_VERIFYHOST](https://curl.haxx.se/libcurl/c/CURLOPT_SSL_VERIFYHOST.html)
 * `sslverifypeer` Verify the SSL certificate. See [CURLOPT_SSL_VERIFYPEER](https://curl.haxx.se/libcurl/c/CURLOPT_SSL_VERIFYPEER.html)
 * `proxyurl` is the URL which will be used as the proxy for the request. See [CURLOPT_PROXY](https://curl.haxx.se/libcurl/c/CURLOPT_PROXY.html)


### Examples ###

```lua
local options = {
    timeoutms = 2500,
    sslverifypeer = 0,
    username = "premake",
    password = "hunter2",
}
http.post("http://null.com", "data", options)
```

### Availability ###

Premake 5.0 or later.

### See Also ###

* [http.get](http.get.md)
* [http.post](http.post.md)
* [http.download](http.download.md)
