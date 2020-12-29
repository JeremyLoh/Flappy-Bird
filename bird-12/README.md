# bird-12: Additional features

1. Fix bug where the speed of the bird is dependent on the game FPS
1. Make pipe gaps slightly random
1. Make pipe intervals slightly random
1. Implement a pause feature
1. Award players a "medal" based on their score, using images

## Fix bug where the speed of the bird is dependent on the game FPS

```Lua
function Bird:update(dt)
    self.dy = self.dy + (GRAVITY * dt)
    if love.keyboard.wasPressed('space') or love.mouse.wasPressed("primary") then
        sounds["jump"]:play()
        self.dy = ANTI_GRAVITY
    end
    self.y = math.max(0, self.y + self.dy * dt)
end
```

## Make pipe gaps slightly random

`PipePair.lua` changes

```Lua
function PipePair:init(y)
    pipeGapRandomReduction = math.random(-10, 0)
    self.x = VIRTUAL_WIDTH + (PIPE_WIDTH / 2)
    self.y = y
    -- When flipping on y axis, it shifts Object by its height amount and flip the object. Need to move the object back down by the object height amount.
    self.pipes = {
        ["top"] = Pipe("top", self.y),
        ["bottom"] = Pipe("bottom", self.y + PIPE_GAP
            + pipeGapRandomReduction + PIPE_HEIGHT)
    }
    self.remove = false
    -- Keep track of whether pair of pipes have been scored
    self.scored = false
end
```

## Make pipe intervals slightly random

`PlayState.lua` changes

```Lua
--[[
    How to generate random float in lua?
    https://stackoverflow.com/a/18209644

    Generates a random interval from [min, max)
]]
function getRandomSpawnInterval(min, max)
    return min + math.random() * (max - min)
end

function PlayState:update(dt)
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
    -- ...
end
```

## Implement a pause feature

The `PauseState` Class was created to keep track of the `PlayState`'s variables. This is done using the `enterParams` parameter of the `enter` function.

`PauseState.lua`

```Lua
PauseState = Class {__includes = BaseState}

function PauseState:enter(previousStateParams)
    self.previousStateParams = previousStateParams
end

function PauseState:update(dt)
    if love.keyboard.wasPressed("p") then
        gStateMachine:change("play", self.previousStateParams)
    end
end

function PauseState:render()
    -- Render previousState
    for key, pair in pairs(self.previousStateParams["pipePairs"]) do
        pair:render()
    end
    self.previousStateParams["bird"]:render()

    love.graphics.setFont(mediumFont)
    love.graphics.print("Score: " .. tostring(self.previousStateParams["score"]), 10, 10)

    -- Render paused information
    love.graphics.setFont(bigFont)
    love.graphics.printf("Paused", 0, 50, VIRTUAL_WIDTH, "center")
    love.graphics.printf("Press \"p\" to resume", 0, 100, VIRTUAL_WIDTH, "center")
end
```

`PlayState.lua` changes

```Lua
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
```

## Award players a "medal" based on their score, using images

The medals are created using Aseprite: https://www.aseprite.org/

Bronze, Silver and Gold medals were created for players that score the following points:

1. Bronze: 10 to 19
1. Silver: 20 to 29
1. Gold: 30 onwards

`ScoreState.lua` changes

```Lua
local goldMedal = love.graphics.newImage("assets/gold-medal.png")
local silverMedal = love.graphics.newImage("assets/silver-medal.png")
local bronzeMedal = love.graphics.newImage("assets/bronze-medal.png")

ScoreState.printMedals = function(score)
    x = (VIRTUAL_WIDTH / 2) - (goldMedal:getWidth() / 2)
    y = 20
    bronze = 10
    silver = 20
    gold = 30
    if score >= gold then
        love.graphics.draw(goldMedal, x, y)
    elseif score >= silver then
        love.graphics.draw(silverMedal, x, y)
    elseif score >= bronze then
        love.graphics.draw(bronzeMedal, x, y)
    end
end

function ScoreState:render()
    love.graphics.setFont(bigFont)
    love.graphics.printf("You scored...", 0, 60, VIRTUAL_WIDTH, "center")
    love.graphics.printf(self.score .. " points!", 0, 100, VIRTUAL_WIDTH, "center")
    self.printMedals(self.score)
    love.graphics.setFont(mediumFont)
    love.graphics.printf("Press Enter to Restart!", 0, 150, VIRTUAL_WIDTH, "center")
end
```
