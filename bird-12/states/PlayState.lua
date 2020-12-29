--[[
    PlayState Class

    Overrides methods present in BaseState. 
    Contains functionality for when the game is executed.
]]

PlayState = Class{__includes = BaseState}

function PlayState:enter(enterParams)
    if enterParams then
        self.bird = enterParams["bird"]
        self.pipePairs = enterParams["pipePairs"]
        self.lastPipeY = enterParams["lastPipeY"]
        love.graphics.printf(tostring(enterParams["lastPipeY"]),0,100,VIRTUAL_WIDTH,"center")
        self.spawnTimer = enterParams["spawnTimer"]
        self.score = enterParams["score"]   
    else
        self.bird = Bird()
        self.pipePairs = {}
        self.lastPipeY = -PIPE_HEIGHT + math.random(60) + 20
        self.spawnTimer = 0
        self.score = 0
    end
end

--[[
    How to generate random float in lua?
    https://stackoverflow.com/a/18209644

    Generates a random interval from [min, max)
]]
function getRandomSpawnInterval(min, max)
    return min + math.random() * (max - min)
end

function PlayState:update(dt) 
    -- Check for pause button
    if love.keyboard.wasPressed("p") then
        params = {
            ["bird"] = self.bird,
            ["pipePairs"] = self.pipePairs,
            ["lastPipeY"] = self.lastPipeY,
            ["spawnTimer"] = self.spawnTimer,
            ["score"] = self.score,
        }
        gStateMachine:change("pause", params)
    end

    self.spawnTimer = self.spawnTimer + dt
    spawnInterval = getRandomSpawnInterval(1.3, 1.5)
    if self.spawnTimer > spawnInterval then
        local topY = -PIPE_HEIGHT + 20
        local bottomY = math.min(self.lastPipeY + math.random(-40, 40), VIRTUAL_HEIGHT - 90)
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
            sounds["score"]:play()
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
        sounds["explosion"]:play()
        sounds["hurt"]:play()
        gStateMachine:change("score", {
            ["score"] = self.score
        })
    end

    -- Check for collision between bird and pipe
    for key, pair in pairs(self.pipePairs) do
        for k, pipe in pairs(pair.pipes) do
            if self.bird:collides(pipe) then
                sounds["explosion"]:play()
                sounds["hurt"]:play()
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
