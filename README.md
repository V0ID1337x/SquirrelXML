# SquirrelXML
Simplest XML parser for Squirrel lang can be used with Gothic 2 Online or Mafia 2 Online

#### Example usage:

```
local text = "<items><item name=test strength=999/><item price=6/></items>";
parser <- XmlParser();
local result = parser.parse(text);

//Print first XmlNode with childs
print(result[0].tostring());
```