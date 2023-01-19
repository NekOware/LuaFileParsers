# LuaFileParsers
Parsing diffrent file formats using Lua.  
(The code you'll see here is total spaghetti bolognese.)

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

There are some extra features that i support in the INI standard which are listed below.
- Comments start with either `;` or `#` characters that are outside of a string and end when a new line starts.
- You can go up a level in sections using `..` in a section name.
  - ex. Go from `[Foo.Bar]` to `[Foo.Baz]` using `[..Baz]`.
- The values `true`, `false` and any numerical value if outside of a string, will automatically be converted into a boolean/number.
  - This won't apply if the value is inside of quotes like `"true"` or `"234"`.
- If a value occurs multiple times in a section then the last one will be used over any other.
- Values not inside of quotes will have their whitespace trimmed from the start and/or end.
- You can ignore a newline by having a `\` character right before EOL (End Of Line).
- You han also use the following escape sequences inside of the values in the INI data.
  - `\\`: Escapes the `\` character.
  - `\'`: Apostrophe.
  - `\"`: Double quotes.
  - `\0`: Null character.
  - `\a`: Bell/Alert/Audible.
  - `\b`: Backspace.
  - `\t`: Tab character.
  - `\r`: Carriage return.
  - `\n`: Line feed.
  - `\;`: Semicolon.
  - `\#`: Number sign.
  - `\=`: Equals.
  - `\:`: Colon.
  
</details>
