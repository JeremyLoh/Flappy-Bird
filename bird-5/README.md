# bird-5: Infinite Pipe update

Create a new `Pipe` Class to represent a pipe in the game.

A timer is checked for each `love.update` to spawn a new pipe after a certain duration. We also need to check when a pipe has exited the left edge of the game screen: The relevant pipes will then be removed from the game.

Render order for the pipes is important (e.g. render pipe before ground to have effect of pipe sticking out of ground)

`main.lua`

```Lua
local pipes = {}
local spawnTimer = 0

function love.load()
    -- ...
    -- Seed RNG
    math.randomseed(os.time())
end

function love.update(dt)
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
    groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH

    spawnTimer = spawnTimer + dt
    if spawnTimer > 2 then
        table.insert(pipes, Pipe())
        spawnTimer = 0
    end

    bird:update(dt)

    -- Iterate over all pipes
    for key, pipe in pairs(pipes) do
        pipe:update(dt)
        -- Check for pipe exiting left of screen
        if pipe.x < -pipe.width then
            table.remove(pipes, key)
        end
    end
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()
    love.graphics.draw(background, -backgroundScroll, 0)
    for key, pipe in pairs(pipes) do
        pipe:render()
    end
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)
    bird:render()
    push:finish()
end
```

1. `spawnTimer` variable is used to check time elapsed, to spawn new pipes. We use the `love.update(dt)` function to increment this timer. This timer will be the number of seconds since the last pipe spawn.
