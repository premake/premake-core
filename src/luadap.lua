-- luadap.lua

-- luadap.lua
-- Luadap class with integrated JSON library
-- JSON library by rxi
-- Source: https://github.com/rxi/json.lua

-- LuadapServer class
-----------------------------------------------------------------------------
-- LuaSocket helper module
-- Author: Diego Nehab
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Declare module and import dependencies
-----------------------------------------------------------------------------
local base = _G
local string = require("string")
local math = require("math")
local luasocket = require("luasocket")

local socket
if type(luasocket) == "table" then
    socket = luasocket
else
    socket = _G.socket
	luasocket = _G.socket
end

-- require("luasocket") returns a boolean when embedded, this means it is loaded in the global scope so we can fetch it

-----------------------------------------------------------------------------
-- Exported auxiliar functions
-----------------------------------------------------------------------------
function socket.connect4(address, port, laddress, lport)
    return luasocket.connect(address, port, laddress, lport, "inet")
end

function socket.connect6(address, port, laddress, lport)
    return luasocket.connect(address, port, laddress, lport, "inet6")
end

function socket.bind(host, port, backlog)
    if host == "*" then host = "0.0.0.0" end
    local addrinfo, err = luasocket.dns.getaddrinfo(host);
    if not addrinfo then return nil, err end
    local sock, res
    err = "no info on address"
    for i, alt in base.ipairs(addrinfo) do
        if alt.family == "inet" then
            sock, err = luasocket.tcp4()
        else
            sock, err = luasocket.tcp6()
        end
        if not sock then return nil, err end
        sock:setoption("reuseaddr", true)
        res, err = sock:bind(alt.addr, port)
        if not res then
            sock:close()
        else
            res, err = sock:listen(backlog)
            if not res then
                sock:close()
            else
                return sock
            end
        end
    end
    return nil, err
end

socket.try = socket.newtry()

function socket.choose(table)
    return function(name, opt1, opt2)
        if base.type(name) ~= "string" then
            name, opt1, opt2 = "default", name, opt1
        end
        local f = table[name or "nil"]
        if not f then base.error("unknown key (".. base.tostring(name) ..")", 3)
        else return f(opt1, opt2) end
    end
end

-----------------------------------------------------------------------------
-- luasocket sources and sinks, conforming to LTN12
-----------------------------------------------------------------------------
-- create namespaces inside LuaSocket namespace
local sourcet, sinkt = {}, {}
socket.sourcet = sourcet
socket.sinkt = sinkt

socket.BLOCKSIZE = 2048

sinkt["close-when-done"] = function(sock)
    return base.setmetatable({
        getfd = function() return sock:getfd() end,
        dirty = function() return sock:dirty() end
    }, {
        __call = function(self, chunk, err)
            if not chunk then
                sock:close()
                return 1
            else return sock:send(chunk) end
        end
    })
end

sinkt["keep-open"] = function(sock)
    return base.setmetatable({
        getfd = function() return sock:getfd() end,
        dirty = function() return sock:dirty() end
    }, {
        __call = function(self, chunk, err)
            if chunk then return sock:send(chunk)
            else return 1 end
        end
    })
end

sinkt["default"] = sinkt["keep-open"]

socket.sink = socket.choose(sinkt)

sourcet["by-length"] = function(sock, length)
    return base.setmetatable({
        getfd = function() return sock:getfd() end,
        dirty = function() return sock:dirty() end
    }, {
        __call = function()
            if length <= 0 then return nil end
            local size = math.min(luasocket.BLOCKSIZE, length)
            local chunk, err = sock:receive(size)
            if err then return nil, err end
            length = length - string.len(chunk)
            return chunk
        end
    })
end

sourcet["until-closed"] = function(sock)
    local done
    return base.setmetatable({
        getfd = function() return sock:getfd() end,
        dirty = function() return sock:dirty() end
    }, {
        __call = function()
            if done then return nil end
            local chunk, err, partial = sock:receive(luasocket.BLOCKSIZE)
            if not err then return chunk
            elseif err == "closed" then
                sock:close()
                done = 1
                return partial
            else return nil, err end
        end
    })
end


sourcet["default"] = sourcet["until-closed"]

socket.source = socket.choose(sourcet)

--embedded Socket.lua

local LuadapServer = {}
LuadapServer.__index = LuadapServer

Luadap = {}

local dap_server = nil
local dap_client = nil
-- LuadapClient class
local LuadapClient = {}
LuadapClient.__index = LuadapClient
local debug = require "debug"
local os = os or (function(module)
  local ok, res = pcall(require, module)
  return ok and res or nil
end)("os")
--[[
 START OF DKJSON
]]--


-- Module options:
local always_use_lpeg = false
local register_global_module_table = false
local global_module_name = 'json'

--[==[

David Kolf's JSON module for Lua 5.1 - 5.4

Version 2.8


For the documentation see the corresponding readme.txt or visit
<http://dkolf.de/dkjson-lua/>.

You can contact the author by sending an e-mail to 'david' at the
domain 'dkolf.de'.


Copyright (C) 2010-2024 David Heiko Kolf

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

]==]

-- global dependencies:
local pairs, type, tostring, tonumber, getmetatable, setmetatable =
      pairs, type, tostring, tonumber, getmetatable, setmetatable
local error, require, pcall, select = error, require, pcall, select
local floor, huge = math.floor, math.huge
local strrep, gsub, strsub, strbyte, strchar, strfind, strlen, strformat =
      string.rep, string.gsub, string.sub, string.byte, string.char,
      string.find, string.len, string.format
local strmatch = string.match
local concat = table.concat

local json = { version = "dkjson 2.8" }

local jsonlpeg = {}

if register_global_module_table then
  if always_use_lpeg then
    _G[global_module_name] = jsonlpeg
  else
    _G[global_module_name] = json
  end
end

-- local _ENV = nil -- blocking globals in Lua 5.2 and later

pcall (function()
  -- Enable access to blocked metatables.
  -- Don't worry, this module doesn't change anything in them.
  local debmeta = require "debug".getmetatable
  if debmeta then getmetatable = debmeta end
end)

json.null = setmetatable ({}, {
  __tojson = function () return "null" end
})

local function isarray (tbl)
  local max, n, arraylen = 0, 0, 0
  for k,v in pairs (tbl) do
    if k == 'n' and type(v) == 'number' then
      arraylen = v
      if v > max then
        max = v
      end
    else
      if type(k) ~= 'number' or k < 1 or floor(k) ~= k then
        return false
      end
      if k > max then
        max = k
      end
      n = n + 1
    end
  end
  if max > 10 and max > arraylen and max > n * 2 then
    return false -- don't create an array with too many holes
  end
  return true, max
end

local escapecodes = {
  ["\""] = "\\\"", ["\\"] = "\\\\", ["\b"] = "\\b", ["\f"] = "\\f",
  ["\n"] = "\\n",  ["\r"] = "\\r",  ["\t"] = "\\t"
}

local function escapeutf8 (uchar)
  local value = escapecodes[uchar]
  if value then
    return value
  end
  local a, b, c, d = strbyte (uchar, 1, 4)
  a, b, c, d = a or 0, b or 0, c or 0, d or 0
  if a <= 0x7f then
    value = a
  elseif 0xc0 <= a and a <= 0xdf and b >= 0x80 then
    value = (a - 0xc0) * 0x40 + b - 0x80
  elseif 0xe0 <= a and a <= 0xef and b >= 0x80 and c >= 0x80 then
    value = ((a - 0xe0) * 0x40 + b - 0x80) * 0x40 + c - 0x80
  elseif 0xf0 <= a and a <= 0xf7 and b >= 0x80 and c >= 0x80 and d >= 0x80 then
    value = (((a - 0xf0) * 0x40 + b - 0x80) * 0x40 + c - 0x80) * 0x40 + d - 0x80
  else
    return ""
  end
  if value <= 0xffff then
    return strformat ("\\u%.4x", value)
  elseif value <= 0x10ffff then
    -- encode as UTF-16 surrogate pair
    value = value - 0x10000
    local highsur, lowsur = 0xD800 + floor (value/0x400), 0xDC00 + (value % 0x400)
    return strformat ("\\u%.4x\\u%.4x", highsur, lowsur)
  else
    return ""
  end
end

local function fsub (str, pattern, repl)
  -- gsub always builds a new string in a buffer, even when no match
  -- exists. First using find should be more efficient when most strings
  -- don't contain the pattern.
  if strfind (str, pattern) then
    return gsub (str, pattern, repl)
  else
    return str
  end
end

local function quotestring (value)
  -- based on the regexp "escapable" in https://github.com/douglascrockford/JSON-js
  value = fsub (value, "[%z\1-\31\"\\\127]", escapeutf8)
  if strfind (value, "[\194\216\220\225\226\239]") then
    value = fsub (value, "\194[\128-\159\173]", escapeutf8)
    value = fsub (value, "\216[\128-\132]", escapeutf8)
    value = fsub (value, "\220\143", escapeutf8)
    value = fsub (value, "\225\158[\180\181]", escapeutf8)
    value = fsub (value, "\226\128[\140-\143\168-\175]", escapeutf8)
    value = fsub (value, "\226\129[\160-\175]", escapeutf8)
    value = fsub (value, "\239\187\191", escapeutf8)
    value = fsub (value, "\239\191[\176-\191]", escapeutf8)
  end
  return "\"" .. value .. "\""
end
json.quotestring = quotestring

local function replace(str, o, n)
  local i, j = strfind (str, o, 1, true)
  if i then
    return strsub(str, 1, i-1) .. n .. strsub(str, j+1, -1)
  else
    return str
  end
end

-- locale independent num2str and str2num functions
local decpoint, numfilter

local function updatedecpoint ()
  decpoint = strmatch(tostring(0.5), "([^05+])")
  -- build a filter that can be used to remove group separators
  numfilter = "[^0-9%-%+eE" .. gsub(decpoint, "[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0") .. "]+"
end

updatedecpoint()

local function num2str (num)
  return replace(fsub(tostring(num), numfilter, ""), decpoint, ".")
end

local function str2num (str)
  local num = tonumber(replace(str, ".", decpoint))
  if not num then
    updatedecpoint()
    num = tonumber(replace(str, ".", decpoint))
  end
  return num
end

local function addnewline2 (level, buffer, buflen)
  buffer[buflen+1] = "\n"
  buffer[buflen+2] = strrep ("  ", level)
  buflen = buflen + 2
  return buflen
end

function json.addnewline (state)
  if state.indent then
    state.bufferlen = addnewline2 (state.level or 0,
                           state.buffer, state.bufferlen or #(state.buffer))
  end
end

local encode2 -- forward declaration

local function addpair (key, value, prev, indent, level, buffer, buflen, tables, globalorder, state)
  local kt = type (key)
  if kt ~= 'string' and kt ~= 'number' then
    return nil, "type '" .. kt .. "' is not supported as a key by JSON."
  end
  if prev then
    buflen = buflen + 1
    buffer[buflen] = ","
  end
  if indent then
    buflen = addnewline2 (level, buffer, buflen)
  end
  -- When Lua is compiled with LUA_NOCVTN2S this will fail when
  -- numbers are mixed into the keys of the table. JSON keys are always
  -- strings, so this would be an implicit conversion too and the failure
  -- is intentional.
  buffer[buflen+1] = quotestring (key)
  buffer[buflen+2] = ":"
  return encode2 (value, indent, level, buffer, buflen + 2, tables, globalorder, state)
end

local function appendcustom(res, buffer, state)
  local buflen = state.bufferlen
  if type (res) == 'string' then
    buflen = buflen + 1
    buffer[buflen] = res
  end
  return buflen
end

local function exception(reason, value, state, buffer, buflen, defaultmessage)
  defaultmessage = defaultmessage or reason
  local handler = state.exception
  if not handler then
    return nil, defaultmessage
  else
    state.bufferlen = buflen
    local ret, msg = handler (reason, value, state, defaultmessage)
    if not ret then return nil, msg or defaultmessage end
    return appendcustom(ret, buffer, state)
  end
end

function json.encodeexception(reason, value, state, defaultmessage)
  return quotestring("<" .. defaultmessage .. ">")
end

encode2 = function (value, indent, level, buffer, buflen, tables, globalorder, state)
  local valtype = type (value)
  local valmeta = getmetatable (value)
  valmeta = type (valmeta) == 'table' and valmeta -- only tables
  local valtojson = valmeta and valmeta.__tojson
  if valtojson then
    if tables[value] then
      return exception('reference cycle', value, state, buffer, buflen)
    end
    tables[value] = true
    state.bufferlen = buflen
    local ret, msg = valtojson (value, state)
    if not ret then return exception('custom encoder failed', value, state, buffer, buflen, msg) end
    tables[value] = nil
    buflen = appendcustom(ret, buffer, state)
  elseif value == nil then
    buflen = buflen + 1
    buffer[buflen] = "null"
  elseif valtype == 'number' then
    local s
    if value ~= value or value >= huge or -value >= huge then
      -- This is the behaviour of the original JSON implementation.
      s = "null"
    else
      s = num2str (value)
    end
    buflen = buflen + 1
    buffer[buflen] = s
  elseif valtype == 'boolean' then
    buflen = buflen + 1
    buffer[buflen] = value and "true" or "false"
  elseif valtype == 'string' then
    buflen = buflen + 1
    buffer[buflen] = quotestring (value)
  elseif valtype == 'table' then
    if tables[value] then
      return exception('reference cycle', value, state, buffer, buflen)
    end
    tables[value] = true
    level = level + 1
    local isa, n = isarray (value)
    if n == 0 and valmeta and valmeta.__jsontype == 'object' then
      isa = false
    end
    local msg
    if isa then -- JSON array
      buflen = buflen + 1
      buffer[buflen] = "["
      for i = 1, n do
        buflen, msg = encode2 (value[i], indent, level, buffer, buflen, tables, globalorder, state)
        if not buflen then return nil, msg end
        if i < n then
          buflen = buflen + 1
          buffer[buflen] = ","
        end
      end
      buflen = buflen + 1
      buffer[buflen] = "]"
    else -- JSON object
      local prev = false
      buflen = buflen + 1
      buffer[buflen] = "{"
      local order = valmeta and valmeta.__jsonorder or globalorder
      if order then
        local used = {}
        n = #order
        for i = 1, n do
          local k = order[i]
          local v = value[k]
          if v ~= nil then
            used[k] = true
            buflen, msg = addpair (k, v, prev, indent, level, buffer, buflen, tables, globalorder, state)
            if not buflen then return nil, msg end
            prev = true -- add a seperator before the next element
          end
        end
        for k,v in pairs (value) do
          if not used[k] then
            buflen, msg = addpair (k, v, prev, indent, level, buffer, buflen, tables, globalorder, state)
            if not buflen then return nil, msg end
            prev = true -- add a seperator before the next element
          end
        end
      else -- unordered
        for k,v in pairs (value) do
          buflen, msg = addpair (k, v, prev, indent, level, buffer, buflen, tables, globalorder, state)
          if not buflen then return nil, msg end
          prev = true -- add a seperator before the next element
        end
      end
      if indent then
        buflen = addnewline2 (level - 1, buffer, buflen)
      end
      buflen = buflen + 1
      buffer[buflen] = "}"
    end
    tables[value] = nil
  else
    return exception ('unsupported type', value, state, buffer, buflen,
      "type '" .. valtype .. "' is not supported by JSON.")
  end
  return buflen
end

function json.encode (value, state)
  state = state or {}
  local oldbuffer = state.buffer
  local buffer = oldbuffer or {}
  state.buffer = buffer
  updatedecpoint()
  local ret, msg = encode2 (value, state.indent, state.level or 0,
                   buffer, state.bufferlen or 0, state.tables or {}, state.keyorder, state)
  if not ret then
    error (msg, 2)
  elseif oldbuffer == buffer then
    state.bufferlen = ret
    return true
  else
    state.bufferlen = nil
    state.buffer = nil
    return concat (buffer)
  end
end

local function loc (str, where)
  local line, pos, linepos = 1, 1, 0
  while true do
    pos = strfind (str, "\n", pos, true)
    if pos and pos < where then
      line = line + 1
      linepos = pos
      pos = pos + 1
    else
      break
    end
  end
  return strformat ("line %d, column %d", line, where - linepos)
end

local function unterminated (str, what, where)
  return nil, strlen (str) + 1, "unterminated " .. what .. " at " .. loc (str, where)
end

local function scanwhite (str, pos)
  while true do
    pos = strfind (str, "%S", pos)
    if not pos then return nil end
    local sub2 = strsub (str, pos, pos + 1)
    if sub2 == "\239\187" and strsub (str, pos + 2, pos + 2) == "\191" then
      -- UTF-8 Byte Order Mark
      pos = pos + 3
    elseif sub2 == "//" then
      pos = strfind (str, "[\n\r]", pos + 2)
      if not pos then return nil end
    elseif sub2 == "/*" then
      pos = strfind (str, "*/", pos + 2)
      if not pos then return nil end
      pos = pos + 2
    else
      return pos
    end
  end
end

local escapechars = {
  ["\""] = "\"", ["\\"] = "\\", ["/"] = "/", ["b"] = "\b", ["f"] = "\f",
  ["n"] = "\n", ["r"] = "\r", ["t"] = "\t"
}

local function unichar (value)
  if value < 0 then
    return nil
  elseif value <= 0x007f then
    return strchar (value)
  elseif value <= 0x07ff then
    return strchar (0xc0 + floor(value/0x40),
                    0x80 + (floor(value) % 0x40))
  elseif value <= 0xffff then
    return strchar (0xe0 + floor(value/0x1000),
                    0x80 + (floor(value/0x40) % 0x40),
                    0x80 + (floor(value) % 0x40))
  elseif value <= 0x10ffff then
    return strchar (0xf0 + floor(value/0x40000),
                    0x80 + (floor(value/0x1000) % 0x40),
                    0x80 + (floor(value/0x40) % 0x40),
                    0x80 + (floor(value) % 0x40))
  else
    return nil
  end
end

local function scanstring (str, pos)
  local lastpos = pos + 1
  local buffer, n = {}, 0
  while true do
    local nextpos = strfind (str, "[\"\\]", lastpos)
    if not nextpos then
      return unterminated (str, "string", pos)
    end
    if nextpos > lastpos then
      n = n + 1
      buffer[n] = strsub (str, lastpos, nextpos - 1)
    end
    if strsub (str, nextpos, nextpos) == "\"" then
      lastpos = nextpos + 1
      break
    else
      local escchar = strsub (str, nextpos + 1, nextpos + 1)
      local value
      if escchar == "u" then
        value = tonumber (strsub (str, nextpos + 2, nextpos + 5), 16)
        if value then
          local value2
          if 0xD800 <= value and value <= 0xDBff then
            -- we have the high surrogate of UTF-16. Check if there is a
            -- low surrogate escaped nearby to combine them.
            if strsub (str, nextpos + 6, nextpos + 7) == "\\u" then
              value2 = tonumber (strsub (str, nextpos + 8, nextpos + 11), 16)
              if value2 and 0xDC00 <= value2 and value2 <= 0xDFFF then
                value = (value - 0xD800)  * 0x400 + (value2 - 0xDC00) + 0x10000
              else
                value2 = nil -- in case it was out of range for a low surrogate
              end
            end
          end
          value = value and unichar (value)
          if value then
            if value2 then
              lastpos = nextpos + 12
            else
              lastpos = nextpos + 6
            end
          end
        end
      end
      if not value then
        value = escapechars[escchar] or escchar
        lastpos = nextpos + 2
      end
      n = n + 1
      buffer[n] = value
    end
  end
  if n == 1 then
    return buffer[1], lastpos
  elseif n > 1 then
    return concat (buffer), lastpos
  else
    return "", lastpos
  end
end

local scanvalue -- forward declaration

local function scantable (what, closechar, str, startpos, nullval, objectmeta, arraymeta)
  local tbl, n = {}, 0
  local pos = startpos + 1
  if what == 'object' then
    setmetatable (tbl, objectmeta)
  else
    setmetatable (tbl, arraymeta)
  end
  while true do
    pos = scanwhite (str, pos)
    if not pos then return unterminated (str, what, startpos) end
    local char = strsub (str, pos, pos)
    if char == closechar then
      return tbl, pos + 1
    end
    local val1, err
    val1, pos, err = scanvalue (str, pos, nullval, objectmeta, arraymeta)
    if err then return nil, pos, err end
    pos = scanwhite (str, pos)
    if not pos then return unterminated (str, what, startpos) end
    char = strsub (str, pos, pos)
    if char == ":" then
      if val1 == nil then
        return nil, pos, "cannot use nil as table index (at " .. loc (str, pos) .. ")"
      end
      pos = scanwhite (str, pos + 1)
      if not pos then return unterminated (str, what, startpos) end
      local val2
      val2, pos, err = scanvalue (str, pos, nullval, objectmeta, arraymeta)
      if err then return nil, pos, err end
      tbl[val1] = val2
      pos = scanwhite (str, pos)
      if not pos then return unterminated (str, what, startpos) end
      char = strsub (str, pos, pos)
    else
      n = n + 1
      tbl[n] = val1
    end
    if char == "," then
      pos = pos + 1
    end
  end
end

scanvalue = function (str, pos, nullval, objectmeta, arraymeta)
  pos = pos or 1
  pos = scanwhite (str, pos)
  if not pos then
    return nil, strlen (str) + 1, "no valid JSON value (reached the end)"
  end
  local char = strsub (str, pos, pos)
  if char == "{" then
    return scantable ('object', "}", str, pos, nullval, objectmeta, arraymeta)
  elseif char == "[" then
    return scantable ('array', "]", str, pos, nullval, objectmeta, arraymeta)
  elseif char == "\"" then
    return scanstring (str, pos)
  else
    local pstart, pend = strfind (str, "^%-?[%d%.]+[eE]?[%+%-]?%d*", pos)
    if pstart then
      local number = str2num (strsub (str, pstart, pend))
      if number then
        return number, pend + 1
      end
    end
    pstart, pend = strfind (str, "^%a%w*", pos)
    if pstart then
      local name = strsub (str, pstart, pend)
      if name == "true" then
        return true, pend + 1
      elseif name == "false" then
        return false, pend + 1
      elseif name == "null" then
        return nullval, pend + 1
      end
    end
    return nil, pos, "no valid JSON value at " .. loc (str, pos)
  end
end

local function optionalmetatables(...)
  if select("#", ...) > 0 then
    return ...
  else
    return {__jsontype = 'object'}, {__jsontype = 'array'}
  end
end

function json.decode (str, pos, nullval, ...)
  local objectmeta, arraymeta = optionalmetatables(...)
  return scanvalue (str, pos, nullval, objectmeta, arraymeta)
end

function json.use_lpeg ()
  local g = require ("lpeg")

  if type(g.version) == 'function' and g.version() == "0.11" then
    error "due to a bug in LPeg 0.11, it cannot be used for JSON matching"
  end

  local pegmatch = g.match
  local P, S, R = g.P, g.S, g.R

  local function ErrorCall (str, pos, msg, state)
    if not state.msg then
      state.msg = msg .. " at " .. loc (str, pos)
      state.pos = pos
    end
    return false
  end

  local function Err (msg)
    return g.Cmt (g.Cc (msg) * g.Carg (2), ErrorCall)
  end

  local function ErrorUnterminatedCall (str, pos, what, state)
    return ErrorCall (str, pos - 1, "unterminated " .. what, state)
  end

  local SingleLineComment = P"//" * (1 - S"\n\r")^0
  local MultiLineComment = P"/*" * (1 - P"*/")^0 * P"*/"
  local Space = (S" \n\r\t" + P"\239\187\191" + SingleLineComment + MultiLineComment)^0

  local function ErrUnterminated (what)
    return g.Cmt (g.Cc (what) * g.Carg (2), ErrorUnterminatedCall)
  end

  local PlainChar = 1 - S"\"\\\n\r"
  local EscapeSequence = (P"\\" * g.C (S"\"\\/bfnrt" + Err "unsupported escape sequence")) / escapechars
  local HexDigit = R("09", "af", "AF")
  local function UTF16Surrogate (match, pos, high, low)
    high, low = tonumber (high, 16), tonumber (low, 16)
    if 0xD800 <= high and high <= 0xDBff and 0xDC00 <= low and low <= 0xDFFF then
      return true, unichar ((high - 0xD800)  * 0x400 + (low - 0xDC00) + 0x10000)
    else
      return false
    end
  end
  local function UTF16BMP (hex)
    return unichar (tonumber (hex, 16))
  end
  local U16Sequence = (P"\\u" * g.C (HexDigit * HexDigit * HexDigit * HexDigit))
  local UnicodeEscape = g.Cmt (U16Sequence * U16Sequence, UTF16Surrogate) + U16Sequence/UTF16BMP
  local Char = UnicodeEscape + EscapeSequence + PlainChar
  local String = P"\"" * (g.Cs (Char ^ 0) * P"\"" + ErrUnterminated "string")
  local Integer = P"-"^(-1) * (P"0" + (R"19" * R"09"^0))
  local Fractal = P"." * R"09"^0
  local Exponent = (S"eE") * (S"+-")^(-1) * R"09"^1
  local Number = (Integer * Fractal^(-1) * Exponent^(-1))/str2num
  local Constant = P"true" * g.Cc (true) + P"false" * g.Cc (false) + P"null" * g.Carg (1)
  local SimpleValue = Number + String + Constant
  local ArrayContent, ObjectContent

  -- The functions parsearray and parseobject parse only a single value/pair
  -- at a time and store them directly to avoid hitting the LPeg limits.
  local function parsearray (str, pos, nullval, state)
    local obj, cont
    local start = pos
    local npos
    local t, nt = {}, 0
    repeat
      obj, cont, npos = pegmatch (ArrayContent, str, pos, nullval, state)
      if cont == 'end' then
        return ErrorUnterminatedCall (str, start, "array", state)
      end
      pos = npos
      if cont == 'cont' or cont == 'last' then
        nt = nt + 1
        t[nt] = obj
      end
    until cont ~= 'cont'
    return pos, setmetatable (t, state.arraymeta)
  end

  local function parseobject (str, pos, nullval, state)
    local obj, key, cont
    local start = pos
    local npos
    local t = {}
    repeat
      key, obj, cont, npos = pegmatch (ObjectContent, str, pos, nullval, state)
      if cont == 'end' then
        return ErrorUnterminatedCall (str, start, "object", state)
      end
      pos = npos
      if cont == 'cont' or cont == 'last' then
        t[key] = obj
      end
    until cont ~= 'cont'
    return pos, setmetatable (t, state.objectmeta)
  end

  local Array = P"[" * g.Cmt (g.Carg(1) * g.Carg(2), parsearray)
  local Object = P"{" * g.Cmt (g.Carg(1) * g.Carg(2), parseobject)
  local Value = Space * (Array + Object + SimpleValue)
  local ExpectedValue = Value + Space * Err "value expected"
  local ExpectedKey = String + Err "key expected"
  local End = P(-1) * g.Cc'end'
  local ErrInvalid = Err "invalid JSON"
  ArrayContent = (Value * Space * (P"," * g.Cc'cont' + P"]" * g.Cc'last'+ End + ErrInvalid)  + g.Cc(nil) * (P"]" * g.Cc'empty' + End  + ErrInvalid)) * g.Cp()
  local Pair = g.Cg (Space * ExpectedKey * Space * (P":" + Err "colon expected") * ExpectedValue)
  ObjectContent = (g.Cc(nil) * g.Cc(nil) * P"}" * g.Cc'empty' + End + (Pair * Space * (P"," * g.Cc'cont' + P"}" * g.Cc'last' + End + ErrInvalid) + ErrInvalid)) * g.Cp()
  local DecodeValue = ExpectedValue * g.Cp ()

  jsonlpeg.version = json.version
  jsonlpeg.encode = json.encode
  jsonlpeg.null = json.null
  jsonlpeg.quotestring = json.quotestring
  jsonlpeg.addnewline = json.addnewline
  jsonlpeg.encodeexception = json.encodeexception
  jsonlpeg.using_lpeg = true

  function jsonlpeg.decode (str, pos, nullval, ...)
    local state = {}
    state.objectmeta, state.arraymeta = optionalmetatables(...)
    local obj, retpos = pegmatch (DecodeValue, str, pos, nullval, state)
    if state.msg then
      return nil, state.pos, state.msg
    else
      return obj, retpos
    end
  end

  -- cache result of this function:
  json.use_lpeg = function () return jsonlpeg end
  jsonlpeg.use_lpeg = json.use_lpeg

  return jsonlpeg
end

if always_use_lpeg then
  return json.use_lpeg()
end

--[[
 START OF LUA DAP
]]--


function print_nicely(tbl)
    -- Calculate the maximum length of the keys and values
    local max_key_length = 0
    local max_value_length = 0

    for key, value in pairs(tbl) do
        local key_length = #tostring(key)
        local value_length = #tostring(value)

        if key_length > max_key_length then
            max_key_length = key_length
        end

        if value_length > max_value_length then
            max_value_length = value_length
        end
    end

    -- Print the table header
    print("+" .. string.rep("-", max_key_length + 2) .. "+" .. string.rep("-", max_value_length + 2) .. "+")
    print("| " .. "Key" .. string.rep(" ", max_key_length - 3) .. " | " .. "Value" .. string.rep(" ", max_value_length - 5) .. " |")
    print("+" .. string.rep("-", max_key_length + 2) .. "+" .. string.rep("-", max_value_length + 2) .. "+")

    -- Print each key-value pair
    for key, value in pairs(tbl) do
        local key_str = tostring(key)
        local value_str = tostring(value)

        print("| " .. key_str .. string.rep(" ", max_key_length - #key_str) .. " | " .. value_str .. string.rep(" ", max_value_length - #value_str) .. " |")
    end

    -- Print the table footer
    print("+" .. string.rep("-", max_key_length + 2) .. "+" .. string.rep("-", max_value_length + 2) .. "+")
end

--[[
  start of Luadap server and client functions.
]]--

function LuadapServer:new(host, port)
    local self = setmetatable({}, LuadapServer)
    self.host = host or "localhost"
    self.port = port or 3000
    self.server = socket.bind(self.host, self.port)
    self.server:settimeout(nil)  -- Non-blocking mode
    print("Server listening on " .. self.host .. ":" .. self.port)
    return self
end

function LuadapServer:accept()
    local client = self.server:accept()
    if client then
        print("Client connected")
        client:settimeout(nil)  -- Non-blocking mode
        return LuadapClient:fromClientSocket(client)
    end
end

function LuadapServer:settimeout(timeout)
    if self.client then
        self.client:settimeout(timeout)
    end
end

function LuadapServer:setBlocking(mode)
    if mode == true then
        self.client:settimeout(nil)
    else
        self.client:settimeout(mode)
    end
end

function LuadapServer:send(data)
    if self.client then
        self.client:send(data)
    end
end

function LuadapServer:receive(pattern)
    if self.client then
        local data, err = self.client:receive(pattern)
        if not data then
            print("Error receiving data:", err)
        else
            print("Received data:", data)
        end
        return data
    end
end

function Luadap:close()
    if self.client then
        self.client:close()
    end
    if self.server then
        self.server:close()
    end
end

function LuadapClient:new()
    local self = setmetatable({}, LuadapClient)
    self.client = socket.tcp()
    return self
end

function LuadapClient:fromClientSocket(client)
    local self = setmetatable({}, LuadapClient)
    self.client = client
    self.initialized = false
    self.hitBreakpoint = false
    self.sendEntryEvent = false
    self.hasStartReturned = false
    self.stackLevel = 0
    self.variablesCount = 0
    self.seenFrames = {}
    self.stackFrames = {}
    self.variables = {}
    self.variablesFrameId = {}
    self.rootVariables = {}
    self.watch = {}
    self.variablestranslation = {}
    self.variablesSetTranslation = {} --this is used for setVariable operations
    self.children = {}
    self.next = false
    self.nextStackLevelFirst = true -- first time the offset is different due to entry event.
    self.nextStackLevel = 0 --stack level should be the same for next/step over
    self.stepIn = false
    self.scopeOffset = 0;
    self.breakPoints = {} --breakPoints ars stored per source for quicker access
    self.breakPointsCount = 0 -- count of breakpoints
    return self
end
function LuadapClient:connect(host, port)
    local success, err = self.client:connect(host or "localhost", port or 3000)
    if not success then
        print("Error connecting:", err)
    else
        print("Connected to", host or "localhost", "on port", port or 3000)
    end
end

function LuadapClient:send(data)
    self.client:send(data)
end

function LuadapClient:receive(pattern)
    local data, err = self.client:receive(pattern)
    if not data then
        print("Error receiving data:", err)
    else
        print("Received data:", data)
    end
    return data
end

function LuadapClient:receivePackage()
    if self.client then
        -- Receive the header
        local header = {}
        while true do
            local line, err = self.client:receive("*l")
            if not line or line == "" then
                break  -- End of header
            else
                table.insert(header, line)
            end
        end

        -- Decode the Content-Length from the header
        local content_length = 0
        for _, line in ipairs(header) do
            local key, value = line:match("^(.-):%s*(.*)$")
            if key and key:lower() == "content-length" then
                content_length = tonumber(value)
                break
            end
        end

        if content_length > 0 then
            -- Receive the rest of the data based on Content-Length
            local total_received = 0
            local data = {}

            while total_received < content_length do
                local chunk, err, partial = self.client:receive(math.min(1024, content_length - total_received))
                if chunk then
                    table.insert(data, chunk)
                    total_received = total_received + #chunk
                elseif partial then
                    table.insert(data, partial)
                    total_received = total_received + #partial
                else
                    print("Error receiving data:", err)
                    break
                end
            end

            return {
                headers = header,
                body = json.decode(table.concat(data))
            }
        else
            print("Content-Length not found in header")
        end
    else
      print("no client")
    end
end

function LuadapClient:receivePackageNonBlocking()
  if self.client then
      -- Receive the header
      local header = {}
      local line, err = self.client:receive("*l")
      if not line then
        return nil
      end
      table.insert(header, line)
      while true do
        line, err = self.client:receive("*l")
        if not line or line == "" then
            break  -- End of header
        else
            table.insert(header, line)
        end
    end


      -- Decode the Content-Length from the header
      local content_length = 0
      for _, line in ipairs(header) do
          local key, value = line:match("^(.-):%s*(.*)$")
          if key and key:lower() == "content-length" then
              content_length = tonumber(value)
              break
          end
      end

      if content_length > 0 then
          -- Receive the rest of the data based on Content-Length
          local total_received = 0
          local data = {}
          while total_received < content_length do
              local chunk, err, partial = self.client:receive(math.min(1024, content_length - total_received))
              if chunk then
                  table.insert(data, chunk)
                  total_received = total_received + #chunk
              elseif partial then
                  table.insert(data, partial)
                  total_received = total_received + #partial
              else
                  print("Error receiving data:", err)
                  break
              end


          end

          return {
              headers = header,
              body = json.decode(table.concat(data))
          }
      else
          return nil
      end
  else
    print("no client")
    return nil
  end
end

function LuadapClient:sendPackage(package)
  if self.client then
    local json_data = json.encode(package)
    local content_length = #json_data
    --DEBUG PRINT
    --print(json_data)
    -- Create the header with Content-Length
    local header = "Content-Length: " .. content_length .. "\r\n\r\n"

    -- Send the header and JSON data to the client
    local success, err
    success, err = self.client:send(header)
    if not success then
      print("Error sending header:", err)
      return nil
    end
    success, err = self.client:send(json_data)
    if not success then
      print("Error sending data:", err)
      return nil
    end
    --DEBUG PRINT
    --print("Package sent successfully")
  else
    print("No client connected")
  end
end

function LuadapClient:close()
    self.client:close()
end

function LuadapClient:settimeout(timeout)
    self.client:settimeout(timeout)
end

function LuadapClient:handleInitRequest(request)
  if request.body.command == "initialize" then

    if request.body.arguments.adapterID ~= "luadap" then
      print("client does not have correct adapterID, expected luadap but was: " .. request.body.arguments.adapterID)
      return nil
    end
    local info_table = {
      clientID = request.body.arguments.clientID,
      clientName = request.body.arguments.clientName,
      adapterID = request.body.arguments.adapterID,
    }
    --print_nicely(info_table)
    local capabilities = {
      supportsConfigurationDoneRequest = true,
      supportsEvaluateForHovers = true,
      supportsLogPoints = true,
      supportsSetVariable = true,
    }
    return InitializeResponse:new(request.body.seq, request.body.seq, true, "", capabilities)
  end
end

function LuadapClient:send_event(command,seq)
  if command == "initialize" then
    self:sendPackage(Event:new(seq,"initialized"))
    dap_client.initialized = true
  end
end

function LuadapClient:handleAttach(requestBody)
  self.sessionInfo = {}
  self.sessionInfo.sessionId = requestBody.arguments.__sessionId
  self.sessionInfo.name = requestBody.arguments.name
  self.sessionInfo.type = requestBody.arguments.type
  self.sessionInfo.host = requestBody.arguments.host
  self.sessionInfo.port = requestBody.arguments.port
  self.sessionInfo.cwd = requestBody.arguments.cwd

  print(self.sessionInfo.cwd)

  if self.sessionInfo.type ~= "luadap" then
    local error_info = {
      id = 1,
      format = "Expected type 'luadap'",
      sendTelemetry = true,
      showUser = true,
    }
    local errorResponse = ErrorResponse:new(2, 2, false, "attach","Invalid type", error_info)
    return errorResponse
  end
  return true
end
function LuadapClient:debugLoop(event, line)
  local request = self:receivePackageNonBlocking()
  if request ~= nil then
    --print_nicely(request.body)
    local response = self:handleRequest(request)
    self:sendPackage(response)
  end
end

function Luadap.start(host, port)
  dap_server = LuadapServer:new(host, port)
  print("lua Debug Adapter Server waiting for client to connect!")
  dap_client = dap_server:accept()
  print("client connected, waiting for initialize request")

  local last_seq = 0
  while not dap_client.initialized do
    local request = dap_client:receivePackage()
    --print_nicely(request.body)
    local response = dap_client:handleInitRequest(request)
    --print_nicely(response)
    last_seq = request.body.seq
    dap_client:send_event(request.body.command,request.body.seq)
    dap_client:sendPackage(response)
  end
  print("debugger initialized")
  debug.sethook(Luadap.debughook, "lcr")
end

-- PROTOCOL TYPES --
Thread = {}
Thread.__index = Thread

-- Constructor for Thread
function Thread:new(id, name)
  local instance = setmetatable({}, self)
  instance.id = id or 0
  instance.name = name or ""
  return instance
end

-- Method to display the thread details
function Thread:display()
  print("Thread ID: " .. self.id)
  print("Thread Name: " .. self.name)
end

-- PROTOCOL MESSAGE OBJECTS --


ProtocolMessage = {}
ProtocolMessage.__index = ProtocolMessage

-- Constructor for ProtocolMessage
function ProtocolMessage:new(seq, type)
    local instance = setmetatable({}, self)
    instance.seq = seq or 1
    instance.type = type or 'request'
    return instance
end

-- Method to display the message details
function ProtocolMessage:display()
    print("Sequence Number: " .. self.seq)
    print("Type: " .. self.type)
end

-- Derived class Request inheriting from ProtocolMessage
Request = setmetatable({}, {__index = ProtocolMessage})
Request.__index = Request

function Request:new(seq, command, arguments)
    local instance = ProtocolMessage.new(self, seq, 'request')
    instance.command = command or ""
    instance.arguments = arguments or {}
    return instance
end

function Request:display()
    ProtocolMessage.display(self)
    print("Command: " .. self.command)
    print("Arguments: " .. tostring(self.arguments))
end

-- Derived class Event inheriting from ProtocolMessage
Event = setmetatable({}, {__index = ProtocolMessage})
Event.__index = Event

function Event:new(seq, event, body)
    local instance = ProtocolMessage.new(self, seq, 'event')
    instance.event = event
    instance.body = body
    return instance
end

function Event:display()
    ProtocolMessage.display(self)
    print("Event: " .. self.event)
    print("Body: " .. tostring(self.body))
end
-- ThreadEvent class inheriting from Event
ThreadEvent = setmetatable({}, { __index = Event })
ThreadEvent.__index = ThreadEvent

-- Constructor for ThreadEvent
function ThreadEvent:new(seq, reason, threadId)
  local body = {
    reason = reason or "",
    threadId = threadId or 0
  }
  local instance = Event.new(self, seq, 'thread', body)
  return instance
end

-- Method to display the thread event details
function ThreadEvent:display()
  Event.display(self)
  print("Reason: " .. self.body.reason)
  print("Thread ID: " .. self.body.threadId)
end

-- StoppedEvent class inheriting from Event
StoppedEvent = setmetatable({}, {__index = Event})
StoppedEvent.__index = StoppedEvent

function StoppedEvent:new(seq, reason, threadId, allThreadsStopped, hitBreakpointIds)
    local instance = Event.new(self, seq, 'stopped', {
        reason = reason,
        threadId = threadId,
        allThreadsStopped = allThreadsStopped,
        hitBreakpointIds = hitBreakpointIds
    })
    return instance
end

ContinuedEvent = setmetatable({}, { __index = Event })
ContinuedEvent.__index = StoppedEvent

function ContinuedEvent:new(seq, reason, threadId, allThreadsContinued, hitBreakpointIds)
  local instance = Event.new(self, seq, 'continued', {
    threadId = threadId,
    allThreadsContinued = allThreadsContinued,
  })
  return instance
end

-- Derived class Response inheriting from ProtocolMessage
Response = setmetatable({}, { __index = ProtocolMessage })
Response.__index = Response

function Response:new(seq, request_seq, success, command, message, body)
    local instance = ProtocolMessage.new(self, seq, 'response')
    instance.request_seq = request_seq or 1
    instance.success = success or false
    instance.command = command
    instance.message = message
    instance.body = body
    return instance
end

function Response:display()
    ProtocolMessage.display(self)
    print("Request Sequence Number: " .. self.request_seq)
    print("Success: " .. tostring(self.success))
    print("Command: " .. self.command)
    print("Message: " .. self.message)
    print("Body: " .. tostring(self.body))
end

-- Extend Response to create InitializeResponse
InitializeResponse = setmetatable({}, { __index = Response })
InitializeResponse.__index = InitializeResponse

function InitializeResponse:new(seq, request_seq, success, message, capabilities)
  -- Infer types and set default values
  seq = seq or 1
  request_seq = request_seq or 1
  success = success
  message = message
  capabilities = capabilities or {}

  local instance = Response.new(self, seq, request_seq, success, "initialize", message, capabilities)
  return instance
end

-- Derived class ErrorResponse inheriting from Response
ErrorResponse = setmetatable({}, {__index = Response})
ErrorResponse.__index = ErrorResponse

function ErrorResponse:new(seq, request_seq, success, command, message, error)
  local error_message = Message:new(
    error.id,
    error.format,
    error.variables,
    error.sendTelemetry,
    error.showUser,
    error.url,
    error.urlLabel
  )
  local body = { error = error_message }
  local instance = Response.new(self, seq, request_seq, success, command, message, body)
  return instance
end

function ErrorResponse:display()
    Response.display(self)
    print("Error: " .. tostring(self.body.error))
end

-- Derived class CancelRequest inheriting from Request
CancelRequest = setmetatable({}, {__index = Request})
CancelRequest.__index = CancelRequest

function CancelRequest:new(seq, arguments)
    local instance = Request.new(self, seq, 'cancel', arguments)
    return instance
end

function CancelRequest:display()
    Request.display(self)
end

-- Derived class CancelResponse inheriting from Response
CancelResponse = setmetatable({}, {__index = Response})
CancelResponse.__index = CancelResponse

function CancelResponse:new(seq, request_seq, success, command, message)
    local instance = Response.new(self, seq, request_seq, success, command, message, nil)
    return instance
end

function CancelResponse:display()
    Response.display(self)
end

-- Define the Message type
Message = {}
Message.__index = Message

function Message:new(id, format, variables, sendTelemetry, showUser, url, urlLabel)
  local instance = setmetatable({}, Message)
  instance.id = id
  instance.format = format
  instance.variables = variables
  instance.sendTelemetry = sendTelemetry or false
  instance.showUser = showUser or false
  instance.url = url
  instance.urlLabel = url
  return instance
end

-- Method to display the message
function Message:display()
  print("ID: " .. self.id)
  print("Format: " .. self.format)
  print("Variables: " .. tostring(self.variables))
  print("Send Telemetry: " .. tostring(self.sendTelemetry))
  print("Show User: " .. tostring(self.showUser))
  print("URL: " .. self.url)
  print("URL Label: " .. self.urlLabel)
end

-- Extend Response to create AttachResponse
AttachResponse = setmetatable({}, { __index = Response })
AttachResponse.__index = AttachResponse

function AttachResponse:new(seq, request_seq, success, message)
  local instance = Response.new(self, seq, request_seq, success, "attach", message)
  return instance
end

-- Extend Response to create AttachResponse
ConfigurationDoneResponse = setmetatable({}, { __index = Response })
ConfigurationDoneResponse.__index = AttachResponse

function ConfigurationDoneResponse:new(seq, request_seq, success, message)
  local instance = Response.new(self, seq, request_seq, success, "configurationDone", message)
  return instance
end

SetExceptionBreakpointsResponse = setmetatable({}, { __index = Response })
SetExceptionBreakpointsResponse.__index = SetExceptionBreakpointsResponse

function SetExceptionBreakpointsResponse:new(seq, request_seq, success, message)
  local instance = Response.new(self, seq, request_seq, success, "setExceptionBreakpoints", message,nil)
  return instance
end

-- ThreadsResponse class inheriting from Response
ThreadsResponse = setmetatable({}, { __index = Response })
ThreadsResponse.__index = ThreadsResponse

function ThreadsResponse:new(seq, request_seq, success, threads, message)
  local body = { threads = threads or {} }
  local instance = Response.new(self, seq, request_seq, success, "threads", message, body)
  return instance
end

function ThreadsResponse:display()
  Response.display(self)
  if self.body.threads then
    for _, thread in ipairs(self.body.threads) do
      thread:display()
    end
  end
end

Source = {}
Source.__index = Source

function Source:new(name, path)
  local instance = setmetatable({}, Source)
  instance.name = name or nil -- Optional name
  instance.path = path or nil -- Optional path
  instance.sourceReference = 0 -- specify 0 so the client reads the file.
  return instance
end

function Source:display()
  print(string.format("Source Name: %s | Path: %s",
    self.name or "[none]",
    self.path or "[unknown]"
  ))
end

StackTraceResponse = setmetatable({}, { __index = Response })
StackTraceResponse.__index = StackTraceResponse

function StackTraceResponse:new(seq, request_seq, success, stackFrames, message)
  local body = { stackFrames = stackFrames or {} }
  local instance = Response.new(self, seq, request_seq, success, "stackTrace", message, body)
  return instance
end

function StackTraceResponse:display()
  Response.display(self)
  if self.body.stackFrames then
    for _, frame in ipairs(self.body.stackFrames) do
      frame:display()
    end
  end
end

-- Example StackFrame Object
StackFrame = {}
StackFrame.__index = StackFrame

function StackFrame:new(id, name, source, line, column, stackLevel)
  local instance = setmetatable({}, StackFrame)
  instance.id = id
  instance.name = name or "[anonymous]"
  instance.source = source or Source:new()
  instance.line = line or 0
  instance.column = column or 1
  instance.column = 0

  local mt = getmetatable(instance) or {}
  mt.stackLevel = stackLevel or 0
  setmetatable(instance, mt)


  return instance
end

function StackFrame:display()
  print(string.format("Frame ID: %d | Name: %s | Source: %s | Line: %d | Column: %d",
    self.id,
    self.name,
    self.source.path,
    self.line,
    self.column
  ))
end
VariablePresentationHint = {}
VariablePresentationHint.__index = VariablePresentationHint

-- Constructor for VariablePresentationHint
function VariablePresentationHint:new(kind, attributes, visibility, lazy)
  local instance = setmetatable({}, self)
  instance.kind = kind                     -- The kind of variable (e.g., 'property', 'method', etc.)
  instance.attributes = attributes or {}   -- An array of attributes (e.g., 'static', 'constant', etc.)
  instance.visibility = visibility         -- The visibility of the variable (e.g., 'public', 'private', etc.)
  instance.lazy = lazy or false            -- Indicates if the variable should be lazily evaluated
  return instance
end

-- Method to display the hint's details
function VariablePresentationHint:display()
  print("Kind: " .. (self.kind or "nil"))
  print("Attributes: " .. table.concat(self.attributes, ", "))
  print("Visibility: " .. (self.visibility or "nil"))
  print("Lazy: " .. tostring(self.lazy))
end

Variable = {}
Variable.__index = Variable

-- Constructor for Variable
function Variable:new(name, value, variablesReference, presentationHint, evaluateName, index)
  local instance = setmetatable({}, self)
  instance.name = name or ""
  instance.value = value or ""
  instance.variablesReference = variablesReference or 0
  --[[
    The kind of variable. Before introducing additional values, try to use the
    listed values.
    Values:
    'property': Indicates that the object is a property.
    'method': Indicates that the object is a method.
    'class': Indicates that the object is a class.
    'data': Indicates that the object is data.
    'event': Indicates that the object is an event.
    'baseClass': Indicates that the object is a base class.
    'innerClass': Indicates that the object is an inner class.
    'interface': Indicates that the object is an interface.
    'mostDerivedClass': Indicates that the object is the most derived class.
    'virtual': Indicates that the object is virtual, meaning it is a
    synthetic object introduced by the adapter for rendering purposes, e.g., an
    index range for large arrays.
    'dataBreakpoint': Deprecated: Indicates that a data breakpoint is
    registered for the object. The `hasDataBreakpoint` attribute should
    generally be used instead.
    etc.
  ]]
  instance.presentationHint = presentationHint
  instance.evaluateName = evaluateName
  if type(value) == "table" then
    instance.indexedVariables = #value     -- Fast and efficient way to count array-like elements

    -- Count named variables (keys that are not sequential integers)
    local namedCount = 0
    for k in pairs(value) do
      if type(k) ~= "number" or k % 1 ~= 0 or k <= 0 or k > instance.indexedVariables then
        namedCount = namedCount + 1
      end
    end
    instance.namedVariables = namedCount > 0 and namedCount or nil
  else
    instance.namedVariables = 0
    instance.indexedVariables = 0
  end
  if presentationHint.kind == "property" then
    instance.variablesReference = 0
  end
  -- Store value in the metatable
  local mt = getmetatable(instance) or {}
  mt.value = value or ""
  mt.index = index or 0
  setmetatable(instance, mt)

  return instance
end

-- SetVariableResponse class inheriting from Response
SetVariableResponse = setmetatable({}, { __index = Response })
SetVariableResponse.__index = SetVariableResponse

function SetVariableResponse:new(seq, request_seq, success, message, value, type, variablesReference, namedVariables,
                                 indexedVariables, memoryReference, valueLocationReference)
  local instance = Response.new(self, seq, request_seq, success, "setVariable", message, nil)

  instance.value = value
  instance.type = type
  instance.variablesReference = variablesReference
  instance.namedVariables = namedVariables
  instance.indexedVariables = indexedVariables
  instance.memoryReference = memoryReference
  instance.valueLocationReference = valueLocationReference

  return instance
end

function LuadapClient:getPresentationHint(value)
  local typeOfValue = type(value)
  local kind = nil

  -- Map Lua types to supported 'kind' values directly
  if typeOfValue == "function" then
    kind = "method"
  elseif typeOfValue == "userdata" then
    kind = "class"
  elseif typeOfValue == "table" then
    if getmetatable(value) then
      kind = "class"       -- Tables with metatables likely represent objects or classes
    else
      kind = "data"        -- General data tables
    end
  elseif typeOfValue == "thread" then
    kind = "event"
  elseif typeOfValue == "boolean" or typeOfValue == "number" or typeOfValue == "string" then
    kind = "property"     -- Simplify basic types as 'property'
  end

  -- Create and return a VariablePresentationHint instance
  return VariablePresentationHint:new(kind, {}, nil, false)
end

-- Method to display the variable's details
function Variable:display()
  print("Name: " .. self.name)
  print("Value: " .. self.value)
  print("Variables Reference: " .. self.variablesReference)
  if self.presentationHint then print("Presentation Hint: " .. tostring(self.presentationHint)) end
  if self.evaluateName then print("Evaluate Name: " .. self.evaluateName) end
  if self.namedVariables then print("Named Variables: " .. self.namedVariables) end
  if self.indexedVariables then print("Indexed Variables: " .. self.indexedVariables) end
end

Scope = {}
Scope.__index = Scope

-- Constructor for Scope
function Scope:new(name, variablesReference, expensive, presentationHint, namedVariables, indexedVariables)
  local instance = setmetatable({}, self)
  instance.name = name or ""                              -- Name of the scope (e.g., 'Arguments', 'Locals', etc.)

  --[[
    A hint for how to present this scope in the UI. If this attribute is
    missing, the scope is shown with a generic UI.
    Values:
    'arguments': Scope contains method arguments.
    'locals': Scope contains local variables.
    'registers': Scope contains registers. Only a single `registers` scope
    should be returned from a `scopes` request.
    'returnValue': Scope contains one or more return values.
    etc.
  ]]
  instance.presentationHint = presentationHint
  instance.variablesReference = variablesReference or 0   -- Reference to retrieve the scope's variables
  instance.namedVariables = namedVariables                -- Number of named variables in this scope
  instance.indexedVariables = indexedVariables            -- Number of indexed variables in this scope
  instance.expensive = expensive or false                 -- Indicates if variables are expensive to retrieve
  return instance
end

-- Method to display the scope's details
function Scope:display()
  print("Name: " .. self.name)
  print("Presentation Hint: " .. (self.presentationHint or "nil"))
  print("Variables Reference: " .. self.variablesReference)
  if self.namedVariables then print("Named Variables: " .. self.namedVariables) end
  if self.indexedVariables then print("Indexed Variables: " .. self.indexedVariables) end
  print("Expensive: " .. tostring(self.expensive))
end


ScopesResponse = setmetatable({}, { __index = Response })
ScopesResponse.__index = ScopesResponse

-- Constructor for ScopesResponse
function ScopesResponse:new(seq, request_seq, success, command, message, scopes)
  -- Call the parent Response constructor
  local instance = Response.new(self, seq, request_seq, success, command, message, { scopes = scopes or {} })
  setmetatable(instance, self)
  return instance
end

-- Method to display the ScopesResponse details
function ScopesResponse:display()
  -- Call the parent Response's display method
  Response.display(self)

  -- Display ScopesResponse-specific details
  print("Scopes:")
  if #self.body.scopes == 0 then
    print("No scopes available.")
  else
    for index, scope in ipairs(self.body.scopes) do
      print("Scope " .. index .. ":")
      scope:display()       -- Assumes Scope objects have a `display` method
    end
  end
end

local function makeAbsolutePath(path)
  -- Normalize slashes
  path = path:gsub("\\", "/")

  -- If the path is already absolute, return it
  if path:match("^/") or path:match("^[a-zA-Z]:") then
    return path
  end

  -- Get the current working directory
  local cwd
  if not dap_client.sessionInfo.cwd then
    local handle = io.popen("cd") -- Works on both Windows & Linux
    cwd = handle:read("*a"):gsub("\n", ""):gsub("\\", "/") -- Normalize slashes
    handle:close()
  else
    cwd = dap_client.sessionInfo.cwd
  end

  -- Resolve ./ and ../ in the path
  local parts = {}
  for part in (cwd .. "/" .. path):gmatch("[^/]+") do
    if part == ".." then
      table.remove(parts) -- Go up one directory
    elseif part ~= "." then
      table.insert(parts, part)
    end
  end

  return "/" .. table.concat(parts, "/")
end

function LuadapClient:getStackFrames(maxLevels, offset)
  local stackFrames = {}
  local level = self.stackLevel + 1
  local collected = 0
  local usedOffset = offset or 6
  while level >= -1 and collected < maxLevels do
    local info = debug.getinfo(level + usedOffset, "nSl")
    if not info then break end
    -- Correct the path
    local correctedPath = info.short_src and info.short_src:gsub("\\", "/") or "[unknown]"
    correctedPath = makeAbsolutePath(correctedPath)
    local osCorrectedPath = correctedPath:gsub("/C:","C:",1):gsub("/", "\\")
    -- Create a Source object with the corrected path and name
    local source = Source:new(
      correctedPath:match("[^/\\]+$") or "[unknown]", -- Extract name from path
      osCorrectedPath -- Corrected path
    )
    -- Create a StackFrame object for each level
    local stackFrame = StackFrame:new(
      level + 1,                                    -- id
      info.name or source.name or "[unknown]",               -- name
      source, -- source
      info.currentline or 0,                     -- line
      level + 1
    )

    if stackFrame.source.name == "[C]" then
      return nil
    else if stackFrame.currentline ~= -1 and stackFrame.source.name ~= "luadap.lua" then
      table.insert(stackFrames, 1, stackFrame)
    end
    end
    level = level - 1
    collected = collected + 1
  end

  return stackFrames
end

StackTraceResponse = setmetatable({}, { __index = Response })
StackTraceResponse.__index = StackTraceResponse

function StackTraceResponse:new(seq, request_seq, success, stackFrames, totalFrames, message)
  local body = {
    stackFrames = stackFrames or {}, -- Array of StackFrame objects
    totalFrames = totalFrames -- Optional totalFrames field
  }
  local instance = Response.new(self, seq, request_seq, success, "stackTrace", message, body)
  return instance
end

function StackTraceResponse:display()
  Response.display(self)
  if self.body.stackFrames then
    print("Stack Frames:")
    for _, frame in ipairs(self.body.stackFrames) do
      frame:display()
    end
  end
  if self.body.totalFrames then
    print("Total Frames: " .. self.body.totalFrames)
  end
end

-- Extend Response to create VariablesResponse
VariablesResponse = setmetatable({}, { __index = Response })
VariablesResponse.__index = VariablesResponse

function VariablesResponse:new(seq, request_seq, success, message, variables)
    -- Ensure variables is always an array table
    local instance = Response.new(self, seq, request_seq, success, "variables", message, { variables = variables })
    return instance
end



-- Derived class NextResponse inheriting from Response
NextResponse = setmetatable({}, { __index = Response })
NextResponse.__index = NextResponse

function NextResponse:new(seq, request_seq, success, message, body)
  return Response.new(self, seq, request_seq, success, "next", message, body)
end

function NextResponse:display()
  Response.display(self)
end

-- Derived class NextResponse inheriting from Response
StepInResponse = setmetatable({}, { __index = Response })
StepInResponse.__index = StepInResponse

function StepInResponse:new(seq, request_seq, success, message, body)
  return Response.new(self, seq, request_seq, success, "stepIn", message, body)
end

function StepInResponse:display()
  Response.display(self)
end

-- Derived class EvaluateResponse inheriting from Response
EvaluateResponse = setmetatable({}, { __index = Response })
EvaluateResponse.__index = EvaluateResponse

function EvaluateResponse:new(seq, request_seq, success, result, variablesReference, type_, presentationHint,
                              namedVariables, indexedVariables, memoryReference, valueLocationReference)
  local body = {
    result = result,
    variablesReference = variablesReference or 0,
    type = type_ or nil,
    presentationHint = presentationHint or nil,
    namedVariables = namedVariables or nil,
    indexedVariables = indexedVariables or nil,
    memoryReference = memoryReference or nil,
    valueLocationReference = valueLocationReference or nil
  }

  local instance = Response.new(self, seq, request_seq,success, "evaluate", nil, body)
  return instance
end

function EvaluateResponse:display()
  Response.display(self)
  print("Result: " .. tostring(self.body.result))
  print("Type: " .. tostring(self.body.type))
  print("Variables Reference: " .. tostring(self.body.variablesReference))
  print("Named Variables: " .. tostring(self.body.namedVariables))
  print("Indexed Variables: " .. tostring(self.body.indexedVariables))
  print("Memory Reference: " .. tostring(self.body.memoryReference))
  print("Value Location Reference: " .. tostring(self.body.valueLocationReference))
end

SetBreakpointsResponse = setmetatable({}, { __index = Response })
SetBreakpointsResponse.__index = SetBreakpointsResponse

function SetBreakpointsResponse:new(seq, request_seq, success, breakpoints)
  local body = {
    breakpoints = breakpoints or {}
  }

  local instance = Response.new(self, seq, request_seq, success, "setBreakpoints", nil, body)
  return instance
end

function SetBreakpointsResponse:display()
  Response.display(self)
  print("Breakpoints:")
  for i, bp in ipairs(self.body.breakpoints) do
    print(string.format("  [%d] verified: %s, line: %s, column: %s, source: %s",
      i,
      tostring(bp.verified),
      tostring(bp.line),
      tostring(bp.column),
      bp.source and tostring(bp.source.path) or "nil"
    ))
  end
end

ContinueResponse = setmetatable({}, { __index = Response })
ContinueResponse.__index = ContinueResponse

function ContinueResponse:new(seq, request_seq, success, allThreadsContinued)
  local body = {
    allThreadsContinued = allThreadsContinued or true
  }

  return Response.new(self, seq, request_seq, success, "continue", nil, body)
end

function ContinueResponse:display()
  Response.display(self)
  print("All Threads Continued: " .. tostring(self.body.allThreadsContinued))
end

PauseResponse = setmetatable({}, { __index = Response })
PauseResponse.__index = ContinueResponse

function PauseResponse:new(seq, request_seq, success)
  return Response.new(self, seq, request_seq, success, "pause", nil, nil)
end

function PauseResponse:display()
  Response.display(self)
end

-- Display all stack frames
function LuadapClient:handleRequest(request)
  -- ATTACH ==================================================================
  if request.body.command == "attach" then
    local attachResult = self:handleAttach(request.body)
    if attachResult == true then
      return AttachResponse:new(request.body.seq, request.body.seq, true)
    else
      attachResult.seq = request.body.seq
      attachResult.request_seq = request.body.seq
      return
    end
  -- SetExceptionBreakpoints =================================================
  elseif request.body.command == "setExceptionBreakpoints" then
    return SetExceptionBreakpointsResponse:new(request.body.seq, request.body.seq, true)
  -- Threading ===============================================================
  elseif request.body.command == "threads" then
    -- lua is not multithreaded, so return 1 thread
    local mainRoutine = Thread:new(1, "Main Routine")
    dap_client.configurationDone = true
    return ThreadsResponse:new(request.body.seq, request.body.seq, true, { mainRoutine })
  -- configurationDone =================================================
  elseif request.body.command == "configurationDone" then
    dap_client:settimeout(0)
    return ConfigurationDoneResponse:new(request.body.seq, request.body.seq, true)
  -- stackTrace =================================================
  elseif request.body.command == "stackTrace" then
    local stackFrames = dap_client:getStackFrames(10)
    self.stackFrames = stackFrames
    return StackTraceResponse:new(request.body.seq, request.body.seq, true,stackFrames)
  elseif request.body.command == "source" then
    -- source =================================================
    -- TODO
  elseif request.body.command == "scopes" then
    -- scopes =================================================
    local stackFrames = dap_client:getStackFrames(10)
    dap_client.scopeOffset = 0;
    self.stackFrames = stackFrames
    local scopes = {}
    for _, stackFrame in ipairs(stackFrames) do
      -- Each frame gets its own scope with a unique variablesReference
      local scope = Scope:new(
        stackFrame.name,    -- name
        stackFrame.id + 1, -- variablesReference (can be frame ID or a generated one)
        false,       -- expensive
        VariablePresentationHint:new("virtual", {}, nil, false) -- scope type
      )
      table.insert(scopes, scope)
      if stackFrame.id + 1 > dap_client.scopeOffset then
        dap_client.scopeOffset = stackFrame.id + 1
      end
    end
  -- Create a ScopesResponse containing the local scope
    return ScopesResponse:new(request.body.seq, request.body.seq, true, "scopes", false, scopes)
  elseif request.body.command == "variables" then
    -- variables =================================================
      if request.body.arguments.variablesReference <= self.scopeOffset then
        local locals = self:getLocalsForFrame(request.body.arguments.variablesReference)
        return VariablesResponse:new(request.body.seq, request.body.seq, true, "Variables",
          locals)
      else
        local var = self.variables[request.body.arguments.variablesReference];
        if var ~= nil then
          local children = self.children[request.body.arguments.variablesReference]
          if children == nil then
            children = self:indexChildren(request.body.arguments.variablesReference)
          end

          --child variables not indexed

        return VariablesResponse:new(request.body.seq, request.body.seq, true, "Variables",
          children)
        end
        print("variable not found 404") -- should never be seen
      end

  -- setVariable =================================================
  elseif request.body.command == "setVariable" then
    print_nicely(request.body.arguments)
    local translation = ""
    if tonumber(request.body.arguments.name) then
      translation = self.variablesSetTranslation[request.body.arguments.variablesReference] .. "[" .. request.body.arguments.name .."]"
    else
      translation = self.variablesSetTranslation[request.body.arguments.variablesReference] ..
      "." .. request.body.arguments.name
    end

    local expression = ""
    if tonumber(request.body.arguments.value) then
      expression = translation .. "=" .. request.body.arguments.value
    else
      expression = translation .. "=\"" .. request.body.arguments.value .. "\""
    end

    local safe_globals = {
      -- Core Lua functions
      assert = assert,
      error = error,
      ipairs = ipairs,
      next = next,
      pairs = pairs,
      pcall = pcall,
      print = print,
      select = select,
      tonumber = tonumber,
      tostring = tostring,
      type = type,
      unpack = table.unpack, -- Lua 5.1 vs 5.2+

      -- Math library
      math = math,

      -- String library
      string = string,

      -- Table library
      table = table,

      -- Basic debug (optional, use with caution)
      -- debug = debug,  -- Only if you trust the input
    }
    local env = setmetatable({}, { __index = safe_globals })
    local varName = string.match(expression, "^([a-zA-Z_][a-zA-Z0-9_]*)")
    if varName then
      local varRef = self.variablestranslation[varName]
      local var = self.variables[varRef]
      print("var:" .. varName)
      env[varName] = var
    end
    local code = expression .. "\nreturn {res=" .. translation .. ",env=_ENV }"

    print("code:\n" .. code)
    local f = load(code, "eval", "t", env)
    local success, result = pcall(f)
    print(result)
    self:setLocalsForFrame(self.variablesFrameId[request.body.arguments.variablesReference], result.env)
    return SetVariableResponse:new(request.body.seq, request.body.seq, true, "variable set", result.env)
  -- next =================================================
  elseif request.body.command == "next" then
    -- reset the breakpoint.
    -- set the next flag and wait for the next line event.
    dap_client.hitBreakpoint = false
    dap_client.variablesCount = 0
    dap_client.variables = {};
    dap_client.scopeOffset = 0
    dap_client.variablestranslation = {}
    dap_client.next = true;
    if dap_client.nextStackLevelFirst == true then
      dap_client.nextStackLevelFirst = false;
      dap_client.nextStackLevel = dap_client.stackLevel - 1;
    else
      dap_client.nextStackLevel = dap_client.stackLevel;
    end
    return ContinuedEvent:new(request.body.seq, "next", 1, true)
  -- stepIn =================================================
  elseif request.body.command == "stepIn" then
    -- reset the breakpoint.
    -- set the stepIn flag and wait for the next call event.
    dap_client.hitBreakpoint = false
    dap_client.variablesCount = 0
    dap_client.variables = {};
    dap_client.scopeOffset = 0
    dap_client.variablestranslation = {}
    dap_client.stepIn = true;
    return ContinuedEvent:new(request.body.seq, "next", 1, true)
  -- evaluate hover=================================================
  elseif request.body.command == "evaluate" and request.body.arguments.context == "hover" then
    --print_nicely(request.body.arguments)
    local varRef = self.variablestranslation[request.body.arguments.expression]
    local var = self.variables[varRef]
    if varRef then
      local hint = self:getPresentationHint(var)
      if hint.kind == "data" or hint.kind == "class" then
        return EvaluateResponse:new(request.body.seq, request.body.seq, true, tostring(var),varRef)
      elseif hint.kind == "method" then
        --method
        return EvaluateResponse:new(request.body.seq, request.body.seq, true, tostring(var))
      else
        return EvaluateResponse:new(request.body.seq, request.body.seq, true, tostring(var))
      end
    else
      return EvaluateResponse:new(request.body.seq, request.body.seq, false, request.body.arguments.expression, -1,"undefined")
    end
  elseif request.body.command == "evaluate" and request.body.arguments.context == "repl" then
    local safe_globals = {
      -- Core Lua functions
      assert = assert,
      error = error,
      ipairs = ipairs,
      next = next,
      pairs = pairs,
      pcall = pcall,
      print = print,
      select = select,
      tonumber = tonumber,
      tostring = tostring,
      type = type,
      unpack = table.unpack, -- Lua 5.1 vs 5.2+

      -- Math library
      math = math,

      -- String library
      string = string,

      -- Table library
      table = table,

      -- Basic debug (optional, use with caution)
      -- debug = debug,  -- Only if you trust the input
    }
    local env = setmetatable({}, { __index = safe_globals })
    for varName in string.gmatch(request.body.arguments.expression, "[a-zA-Z_][a-zA-Z0-9_]*") do
      local varRef = self.variablestranslation[varName]
      local var = self.variables[varRef]
      env[varName] = var
    end

    local expr = request.body.arguments.expression
    local isAssignment = expr:match("%s*[%a_][%w_]*%s*=")
    local code=""
    if isAssignment then
      code = expr .."\nreturn {res=nil,env=_ENV }"
    else
      code = "return {res=".. expr .. ",env=_ENV }"
    end
    print("code:\n" ..code)
    local f = load(code, "eval", "t", env)
    local success, result = pcall(f)
    print_nicely(result)
    self:setLocalsForFrame(request.body.arguments.frameId,result.env)
    -- Handle result or error
    if success then
      return EvaluateResponse:new(request.body.seq, request.body.seq, true, tostring(result.res))
    else
      return EvaluateResponse:new(request.body.seq, request.body.seq, false, request.body.arguments.expression, -1,"undefined")
    end
  elseif request.body.command == "evaluate" and request.body.arguments.context == "watch" then
    local error = {
      id = 1001, -- Custom error code
      format = "Watch expressions are not supported by this adapter.",
      showUser = true
    }
    return ErrorResponse:new(request.body.seq, request.body.seq,false,"evaluate","not supported",error)
  -- setBreakpoints =================================================
  elseif request.body.command == "setBreakpoints" then
    --print_nicely(request.body.arguments)
    --print_nicely(request.body.arguments.source)

    local breakpoints = self:indexBreakpoints(request.body.arguments.source, request.body.arguments.breakpoints)
    return SetBreakpointsResponse:new(request.body.seq, request.body.seq, true, breakpoints)
  elseif request.body.command == "continue" then
    self.hitBreakpoint = false
    self.next = false
    self.stepIn = false
    return ContinueResponse:new(request.body.seq, request.body.seq, true)

  elseif request.body.command== "pause" then
    self.hitBreakpoint = true
    self.next = false
    self.stepIn = false
    self:sendPackage(StoppedEvent:new(0, "pause ", 1, true))
    return PauseResponse:new(request.body.seq,request.body.seq,true)

  elseif request.body.command == "disconnect" then
    self.hitBreakpoint = false
    Luadap:close()
  end
end
function LuadapClient:getFile()
  return debug.getinfo(2, "S").source:sub(2)
end
function LuadapClient:getModule()
  local src = debug.getinfo(3, "S").source
  if src:sub(1, 1) == "@" then
    return src:sub(2):match("([^/\\]+)%.lua$")
  else
    return "[C]"
  end
end

function LuadapClient:getModuleName()
  local src = debug.getinfo(3, "S").source
  if src:sub(1, 1) == "@" then
    return src:sub(2):match("([^/\\]+%.lua)$")
  else
    return "[C]"
  end
end

function LuadapClient:traceback()
  local level = 1
  while true do
    local info = debug.getinfo(level, "Sl")
    if not info then break end
    if info.what == "C" then   -- is a C function?
      --print(level, "C function")
    elseif info.short_src:match("([^/\\]+)%.lua$") ~= "luadap" then
      return info.short_src:match("([^/\\]+)%.lua$"), info.linedefined
    end
    level = level + 1
  end
end

--[[
  This function indexes all the local variables when a breakpoint has been hit
]]
function LuadapClient:getLocalsForFrame(frameId)
  local locals = {}
  local baseLevel = frameId + 4 -- match your stack offset
  local index = 1

  while true do
    local name, value = debug.getlocal(baseLevel, index)
    if not name then
      break;  -- Exit when there are no more locals
    end
    -- Skip internal variables if needed
    if name ~= "(*temporary)" then
      local varRef = self.variablesCount + self.scopeOffset + 1
      local hint = self:getPresentationHint(value)
      local usedVarRef = 0
      if hint.kind == "data" or hint.kind == "class" then
        usedVarRef = varRef
      end

      self.variables[varRef] = value
      local var = Variable:new(
        name,
        tostring(value),
        usedVarRef,
        self:getPresentationHint(value),
        name,
        index
      )
      table.insert(locals, var)
      self.rootVariables[name] = index
      self.variablesSetTranslation[varRef] = name
      self.variablestranslation[name] = varRef
      self.variablesCount = self.variablesCount + 1;
      self.variablesFrameId[varRef] = frameId
    end

    index = index + 1
  end

  return locals
end

function LuadapClient:getStackFrameById(id)


  for _, frame in ipairs(self.stackFrames) do
    if frame.id == id then
      return frame
    end
  end

  return nil
end


function LuadapClient:setLocalsForFrame(frameId,env)
  local frame = self:getStackFrameById(frameId)
  for name, value in pairs(env) do
    local index = self.rootVariables[name]
    debug.setlocal(frame.stackLevel + 5, index, value)
  end
end


function LuadapClient:indexChildren(variablesReference)

  if variablesReference == 0 then
    return {}
  end
  local children = {}

  local value = self.variables[variablesReference]
  if value ~= nil then
    for key, child in pairs(value) do
      local varRef = self.variablesCount + self.scopeOffset + 1
      local hint = self:getPresentationHint(child)
      local usedVarRef = 0

      if hint.kind == "data" or hint.kind == "class" then
        usedVarRef = varRef
      end
      if tonumber(key) then
        --indexable
        local variable = Variable:new(tostring(key),tostring(child),varRef,hint)
        table.insert(children,variable)
        self.variables[varRef] = child
        self.variablesCount = self.variablesCount + 1;
        self.variablesSetTranslation[varRef] = self.variablesSetTranslation[variablesReference] .. "[" .. tostring(key) .. "]"
        self.variablesFrameId[varRef] = self.variablesFrameId[variablesReference]

      elseif key then
        -- key value pair
        local variable = Variable:new(tostring(key), tostring(child), varRef, hint)
        table.insert(children, variable)
        self.variables[varRef] = child
        self.variablesSetTranslation[varRef] = self.variablesSetTranslation[variablesReference] .. "." .. tostring(key)
        self.variablesCount = self.variablesCount + 1;
        self.variablesFrameId[varRef] = self.variablesFrameId[variablesReference]
      else
        print("oops")
      end
    end
  end
  self.children[variablesReference] = children
  return children
end

function LuadapClient:indexBreakpoints(source, breakpoints)
  local bps = {}
  for _,bp in ipairs(breakpoints) do
    self.breakPointsCount = self.breakPointsCount + 1
    table.insert(bps, { line = bp.line, message = bp.logMessage, verified = true, id = self.breakPointsCount } )
  end
  self.breakPoints[source.name] = bps
  return bps
end
function Luadap.debughook(event, line)
-- debuging ourselves is not allowed here!

  -- we need to ensure the debug addapter configuration is complete before we start the code.
  while not dap_client.configurationDone do
    dap_client:debugLoop(event, line)
  end

  if event == "call" then
    dap_client.stackLevel = dap_client.stackLevel + 1
  elseif event == "return" or event == "tail return" then
    dap_client.stackLevel = dap_client.stackLevel - 1
  end
  local info = debug.getinfo(dap_client.stackLevel + 4, "Snl")
  local current = debug.getinfo(dap_client.stackLevel + 3, "Snl")

  local module = dap_client:getModule();
  local moduleName = dap_client:getModuleName();
  if dap_client.stackLevel >= -1 and info ~= nil and info.currentline ~= -1 and module ~= "[C]" then
    if event == "line" and not dap_client.first_line_event and not info.short_src:match("luadap.lua$") and module == "luadap" then
      -- we need to send a breakpoint event here.
      --send the stopped event
      dap_client.first_line_event = true
      dap_client.hitBreakpoint = true
      dap_client:sendPackage(StoppedEvent:new(0,"entry",1,true))
    end
  end
  if (event == "line" or event == "call") and current ~= nil and dap_client.first_line_event == true then
    -- only lua code should be halted on.
    if dap_client.stepIn == true and module ~= "[C]" then
      --stackLevel should be the same or increase
      dap_client.hitBreakpoint = true;
      dap_client.stepIn = false;
      dap_client:sendPackage(StepInResponse:new(0, 1, true))
      dap_client:sendPackage(StoppedEvent:new(0, "step", 1, true))
    elseif dap_client.next == true and module ~= "[C]" and event == "line" and dap_client.stackLevel == dap_client.nextStackLevel then
      --stackLevel should be the same.
      dap_client.hitBreakpoint = true;
      dap_client.next = false;
      dap_client:sendPackage(NextResponse:new(0, 1, true))
      dap_client:sendPackage(StoppedEvent:new(0, "step", 1, true))
    end
    if dap_client.breakPoints[moduleName] ~= nil then
      for _,bp in ipairs(dap_client.breakPoints[moduleName]) do
        if bp.line == line then

          if bp.message ~= nil then
            --excution should not be stopped on logpoints
            print(bp.message)
          elseif dap_client.hitBreakpoint == false then
            dap_client.hitBreakpoint = true
            dap_client:sendPackage(StoppedEvent:new(0, "breakpoint", 1, true, {bp.id}))
          end
          break;
        end
      end
    end

  elseif event == "line" and dap_client.stackLevel >= -1 then
    --DEBUG PRINT
    --print("executing line:" .. line .. " level:" .. dap_client.stackLevel)
  end

  while dap_client.hitBreakpoint do
    dap_client:debugLoop(event, line)
  end

  dap_client:debugLoop(event, line)
end
return Luadap
