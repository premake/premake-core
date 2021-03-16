Determines if the host is using a 64-bit processor.

```lua
os.is64bit()
```

### Parameters ###

None.


### Return Value ###

**True** if the host system has a 64-bit processor, **false** otherwise.


### Availability ###

Premake 4.4 or later.


### Examples ###

```lua
if os.is64bit() then
   print("This is a 64-bit system")
else
   print("This is NOT a 64-bit system")
end
```
