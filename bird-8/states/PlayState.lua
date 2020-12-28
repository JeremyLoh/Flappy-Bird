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

    -- Reset game if bird touches the ground
    -- Giving leeway of 3px for the bird's y coordinates
    if (self.bird.y + self.bird.height - 3) >= (VIRTUAL_HEIGHT - 16) then
        gStateMachine:change('title')
    end

    -- Iterate over all pipes
    for key, pair in pairs(self.pipePairs) do
        pair:update(dt)
        -- Check for collision between bird and pipe
        for k, pipe in pairs(pair.pipes) do
            if self.bird:collides(pipe) then
                gStateMachine:change('title')
            end
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
end

function PlayState:render() 
    for key, pair in pairs(self.pipePairs) do
        pair:render()
    end
    self.bird:render()
end

function PlayState:exit() 
    -- Remove all items in the table
    for k, p in pairs(self.pipePairs) do
        self.pipePairs[k] = nil
    end
end