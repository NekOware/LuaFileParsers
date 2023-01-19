# LuaFileParsers
Parsing diffrent file formats using Lua.

```lua
local parser = require'LuaFileParsers' -- or `require'LuaFileParsers/init.lua'`
```

Supported Formats:
------------------

<details><summary><code>INI</code></summary>
  
```lua
-- Load from string.
local data = parser.ini.load([[
Foo = "Hello, World!"
[Bar]
Baz = "Hi mom!"
]])
  
-- Load from file.
local data = parser.ini.loadFile('./path/to/file.ini')
  
-- Convert a table into a INI string.
local str = parser.ini.save( { Foo = "Hello, World!", Bar = { Baz = "Hi mom!" } } )
  
-- Convert a Lua table into a INI string and save it to file.
parser.ini.saveFile( './path/to/file.ini', { Foo = "Hello, World!", Bar = { Baz = "Hi mom!" } } )
```
  
</details>
