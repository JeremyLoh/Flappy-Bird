# bird-7: Collision Update

Use aabb Collision detection (Axis-Aligned Bounding Box) for pipes and bird

https://developer.mozilla.org/en-US/docs/Games/Techniques/2D_collision_detection

`main.lua` changes

```Lua
-- scrolling variable to pause the game when we collide with a pipe
local scrolling = true

function love.update(dt)
    if scrolling then
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
            -- Check for collision between bird and pipe
            for k, pipe in pairs(pair.pipes) do
                if bird:collides(pipe) then
                    scrolling = false
                end
            end
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
    end
    love.keyboard.keysPressed = {}
end
```

`Bird.lua` changes

```Lua
function Bird:collides(object)
    -- Use aabb collision detection
    -- All sides have been shrinked by a constant amount to reduce the bounding box (to give the player more leeway with the collision)
    shrinkAmount = 5
    birdLeftBoundary = self.x + shrinkAmount
    birdRightBoundary = self.x + self.width - shrinkAmount
    birdTopBoundary = self.y + shrinkAmount
    birdBottomBoundary = self.y + self.height - shrinkAmount
    return (birdLeftBoundary < (object.x + object.width) and
        (birdRightBoundary) > object.x and
        birdTopBoundary < (object.y + object.height) and
        birdBottomBoundary > object.y)
end
```
