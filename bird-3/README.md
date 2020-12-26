# bird-3: Gravity update

Add gravity to the bird object in game.

`Bird.lua` Class:

```Lua
local GRAVITY = 9

function Bird:init()
    -- ...
    self.dy = 0
end

function Bird:update(dt)
    self.dy = self.dy + (GRAVITY * dt)
    self.y = self.y + self.dy
end
```
