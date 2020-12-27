# bird-6: Pipe Pair update

Create a new Class `PipePair` that encapsulates 2 `Pipe` objects.

When you flip or rotate an image, it does it about its pivotal point, which is the top left corner of the image. You need to offset your image so that its in the same location as its original state.

When flipping on y axis, it shifts Object by its height amount and then flip the object. Need to move the object back down by the object height amount to get back to the wanted flip position.

`main.lua`

```Lua
require "PipePair"
local pipePairs = {}
local lastPipeY = -PIPE_HEIGHT + math.random(60) + 20

function love.update(dt)
    -- ...
    spawnTimer = spawnTimer + dt
    if spawnTimer > 2 then
        local topY = -PIPE_HEIGHT + 20
        local bottomY = math.min(lastPipeY + math.random(-20, 20), VIRTUAL_HEIGHT - 90)
        -- Limit y values
        local y = math.max(topY, bottomY)
        table.insert(pipePairs, PipePair(y))
        spawnTimer = 0
    end

    bird:update(dt)

    -- Iterate over all pipes
    for key, pair in pairs(pipePairs) do
        pair:update(dt)
        -- Check for pipe exiting left of screen
        -- if pipe.x < -pipe.width then
        --     table.remove(pipePairs, key)
        -- end
    end

    -- Remove any flagged pipes
    -- Need this second loop, rather than deleting in the previous loop
    -- Modifying the table in-place without explicit keys will result in skipping the next pipe,
    -- since all implicit keys (numerical indices) are automatically shifted
    -- down after a table removal
    for key, pair in pairs(pipePairs) do
        if pair.remove then
            table.remove(pipePairs, key)
        end
    end
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()
    -- ...
    for key, pair in pairs(pipePairs) do
        pair:render()
    end
    -- ...
    push:finish()
end
```

`PipePair.lua` - New class representing pair of pipes

```Lua
PipePair = Class{}

local PIPE_GAP = 90

function PipePair:init(y)
    self.y = y
    -- When flipping on y axis, it shifts Object by its height amount and flip the object. Need to move the object back down by the object height amount.
    self.pipes = {
        ["top"] = Pipe("top", self.y),
        ["bottom"] = Pipe("bottom", self.y + PIPE_GAP + PIPE_HEIGHT)
    }
    self.remove = false
end

function PipePair:update(dt)
    for key, pipe in pairs(self.pipes) do
        pipe:update(dt)
        -- Check for pipe exiting left of screen
        if pipe.x < -pipe.width then
            self.remove = true
        end
    end
end

function PipePair:render()
    for key, pipe in pairs(self.pipes) do
        pipe:render()
    end
end
```

`Pipe.lua` changes

```Lua
-- height of pipe image, globally accessible
PIPE_HEIGHT = 288
PIPE_WIDTH = 70

function Pipe:init(orientation, y)
    -- ...
    self.orientation = orientation
    self.y = y
end

function Pipe:render()
    -- scale factor of -1 flips sprite
    -- When flipping on y axis, it shifts Object by its height amount and flip the object. Need to move the object back down by the object height amount.
    love.graphics.draw(IMAGE,
        self.x, -- x axis position
        (self.orientation == "top" and (self.y + PIPE_HEIGHT) or self.y), -- y axis position
        0, -- orientation (radians)
        1, -- Scale factor (x-axis)
        (self.orientation == "top" and -1 or 1) -- Scale factor (y-axis).
    )
end
```
