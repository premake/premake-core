Perform a HTTP POST request to the specified URL.

```lua
http.post(url, data, { options })
```

### Parameters ###

`url` is the URL to POST to.

`data` is a string containing the data to post.

`options` is a [table of options](http-options-table.md) used for this HTTP request.

### Return Values ###

There are three return values.

```lua
resource, result_str, response_code = http.post(url, data, { options })
```

 * `resource` is the content that was retrieved or nil if it could not be retrieved.
 * `result_str` is set to "OK" if successful or contains a description of the failure.
 * `result_code` is the HTTP [result code](http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html) of the get.

### Examples ###

```lua
local resource, result_str, response_code = http.post("http://example.com/api.json", "somedata")
```


### Availability ###

Premake 5.0 or later.

### See Also ###

* [http.download](http.download.md)
* [http.get](http.get.md)
