--[[
    PlayState Class

    Overrides methods present in BaseState. 
    Contains functionality for when the game is executed.
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.lastPipeY = -PIPE_HEIGHT + math.random(60) + 20
    self.spawnTimer = 0
    self.score = 0
end

function PlayState:update(dt) 
    self.spawnTimer = self.spawnTimer + dt
    if self.spawnTimer > 2 then
        local topY = -PIPE_HEIGHT + 20
        local bottomY = math.min(self.lastPipeY + math.random(-20, 20), VIRTUAL_HEIGHT - 90)
        -- Limit y values 
        local y = math.max(topY, bottomY)
        table.insert(self.pipePairs, PipePair(y))
        self.spawnTimer = 0
    end
    
    self.bird:update(dt)

    -- Iterate over all pipes
    for key, pair in pairs(self.pipePairs) do
        pair:update(dt)
        -- Check for scoring, ignore if pipe is already scored
        if ((not pair.scored) and (pair.x + PIPE_WIDTH < self.bird.x)) then
            self.score = self.score + 1
            pair.scored = true
        end
    end

    -- Remove any flagged pipes
    -- Need this second loop, rather than deleting in the previous loop
    -- Modifying the table in-place without explicit keys will result in skipping the next pipe,
    -- since all implicit keys (numerical indices) are automatically shifted
    -- down after a table removal
    for k2, pair in pairs(self.pipePairs) do
        if pair.remove then
            table.remove(self.pipePairs, k2)
        end
    end

    -- Reset game if bird touches the ground
    -- Giving leeway of 3px for the bird's y coordinates
    if (self.bird.y + self.bird.height - 3) >= (VIRTUAL_HEIGHT - 16) then
        gStateMachine:change("score", {
            ["score"] = self.score
        })
    end

    -- Check for collision between bird and pipe
    for key, pair in pairs(self.pipePairs) do
        for k, pipe in pairs(pair.pipes) do
            if self.bird:collides(pipe) then
                gStateMachine:change("score", {
                    ["score"] = self.score
                })
            end
        end
    end
end

function PlayState:render() 
    for key, pair in pairs(self.pipePairs) do
        pair:render()
    end
    self.bird:render()

    love.graphics.setFont(mediumFont)
    love.graphics.print("Score: " .. tostring(self.score), 10, 10)
end

function PlayState:exit() 
    -- Remove all items in the table
    for k, p in pairs(self.pipePairs) do
        self.pipePairs[k] = nil
    end
end