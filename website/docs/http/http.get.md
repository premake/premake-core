Perform a HTTP GET request using the specified URL.

```lua
http.get(url, { options })
```

### Parameters ###

`url` is the URL to be downloaded.

`options` is a [table of options](http-options-table.md) used for this HTTP request.

### Return Values ###

There are three return values.

```lua
resource, result_str, response_code = http.get(url, { options })
```

 * `resource` is the content that was retrieved or nil if it could not be retrieved.
 * `result_str` is set to "OK" if successful or contains a description of the failure.
 * `result_code` is the HTTP [result code](http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html) of the get.

### Examples ###

```lua
local resource, result_str, response_code = http.get("http://example.com/api.json")
```

```lua
function progress(total, current)
  local ratio = current / total;
  ratio = math.min(math.max(ratio, 0), 1);
  local percent = math.floor(ratio * 100);
  print("Download progress (" .. percent .. "%/100%)")
end

local resource, result_str, response_code = http.get("http://example.com/api.json", {
    progress = progress,
    headers = { "From: Premake", "Referer: Premake" },
    userpwd = "username:password"
})
```

### Backward compatible function signature ###

The previous signature of this function was

```lua
http.get(url, progress, headers)
```

and continues to be supported. This is equivalent to

```lua
http.get(url, { progress = progress, headers = headers })
```

### Availability ###

Premake 5.0 or later.

### See Also ###

* [http.download](http.download.md)
* [http.post](http.post.md)
