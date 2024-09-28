Downloads an HTTP resource from the specified URL to a file.

```lua
http.download(url, file, { options })
```

### Parameters ###

`url` is the URL to be downloaded.

`file` is the destination file that will be written to.

`options` is a [table of options](http-options-table.md) used for this HTTP request.

### Return Values ###

There are two return values.

```lua
result_str, response_code = http.download(url, file, { options })
```

 * `result_str` is set to "OK" if successful or contains a description of the failure.
 * `result_code` is the HTTP [result code](http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html) of the download.

### Examples ###

```lua
local result_str, response_code = http.download("http://example.com/file.zip", "file.zip")
```

```lua
function progress(total, current)
  local ratio = current / total;
  ratio = math.min(math.max(ratio, 0), 1);
  local percent = math.floor(ratio * 100);
  print("Download progress (" .. percent .. "%/100%)")
end

local result_str, response_code = http.download("http://example.com/file.zip", "file.zip", {
    progress = progress,
    headers = { "From: Premake", "Referer: Premake" },
    userpwd = "username:password"
})
```

### Backward compatible function signature ###

The previous signature of this function was

```lua
http.download(url, file, progress, headers)
```

and continues to be supported. This is equivalent to

```lua
http.download(url, file, { progress = progress, headers = headers })
```

### Availability ###

Premake 5.0 or later.


### See Also ###

* [http.get](http.get.md)
