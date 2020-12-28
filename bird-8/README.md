# bird-8: The State Machine Update

Add State Machine that allows for game state transitions and abstraction of code.

# Flappy Bird State Machine

(1)TitleScreenState -> (2)CountdownState -> (3)PlayState -> (4)ScoreState

(4)ScoreState -> (2)CountdownState

`main.lua` changes

```Lua
require "Bird"
require "Pipe"
require "PipePair"
-- Import game state and state machine files
require "StateMachine"
require "states/BaseState"
require "states/PlayState"
require "states/ScoreState"
require "states/TitleScreenState"

function love.load()
    -- ...
    -- Create fonts
    bigFont = love.graphics.newFont("fonts/FlappyBirdy.ttf", 32)
    mediumFont = love.graphics.newFont("fonts/FlappyBirdy.ttf", 20)

    -- Initialize state machine with all states
    gStateMachine = StateMachine ({
        ["title"] = function() return TitleScreenState() end,
        ["play"] = function() return PlayState() end,
        ["score"] = function() return ScoreState() end,
    })
    gStateMachine:change("title")
    -- ...
end

function love.update(dt)
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
    groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH
    gStateMachine:update(dt)
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()
    love.graphics.draw(background, -backgroundScroll, 0)
    gStateMachine:render()
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)
    push:finish()
end
```

`PipePair.lua` changes

```Lua
function PipePair:init(y)
    self.x = VIRTUAL_WIDTH + (PIPE_WIDTH / 2)
    -- ...
    -- Keep track of whether pair of pipes have been scored
    self.scored = false
end

function PipePair:update(dt)
    for key, pipe in pairs(self.pipes) do
        pipe:update(dt)
        self.x = pipe.x
        -- Check for pipe exiting left of screen
        if pipe.x < -pipe.width then
            self.remove = true
        end
    end
end
```

# State Machine

`StateMachine.lua`

```Lua
--[[
    StateMachine - The game's state machine

    Usage:
        States are only created as needed, to save memory, reduce cleanup bugs and increase speed due to garbage collection taking longer with more data in memory

        States are added with a string identifier and an initialisation function.
        It is expected that the init function, when called, will return a table with Render, Update, Enter and Exit methods.

        gStateMachine = StateMachine ({
            ["MainMenu"] = function()
                return MainMenu()
            end,
            ["InnerGame"] = function()
                return InnerGame()
            end,
            ["GameOver"] = function()
                return GameOver()
            end,
        })
        gStateMachine:change("MainGame")

        Arguments passed into the Change function after the state name
        will be forwarded to the Enter function of the state being changed too.
]]

StateMachine = Class{}

function StateMachine:init(states)
    -- states is a table that returns functions that represent the state
    -- There are 4 possible functions for each item in the states table:
    -- render, update, enter, exit
    self.states = states or {}
    self.empty = {
        ["render"] = function() end,
        ["update"] = function() end,
        ["enter"] = function() end,
        ["exit"] = function() end,
    }
    self.currentState = self.empty
end

function StateMachine:change(stateName, enterParams)
    -- Ensure state name given is valid
    assert(self.states[stateName], "Invalid state name given for state change")
    self.currentState:exit()
    self.currentState = self.states[stateName]()
    self.currentState:enter(enterParams)
end

function StateMachine:update(dt)
    self.currentState:update(dt)
end

function StateMachine:render()
    self.currentState:render()
end
```

# Different states implemented

`BaseState.lua`

```Lua
--[[
    BaseState Class

    Used as the base class for all of our states.
    We will not need to define empty methods in each of them.

    The StateMachine requires each State to have 4 methods implemented.
    Inheriting from this base class allows for the 4 required methods to exist even if we do not override them.
]]

BaseState = Class{}

function BaseState:init() end
function BaseState:enter() end
function BaseState:exit() end
function BaseState:update(dt) end
function BaseState:render() end
```

`ScoreState.lua`

```Lua
--[[
    ScoreState Class

    Keeps track of player score.

    A point is given to the player when they pass a set of pipes without touching the pipes or the ground.
]]

ScoreState = Class{__includes = BaseState}

function ScoreState:init(currentScore)
    self.score = 0
end

function ScoreState:enter(table)
    self.score = table["score"] or 0
end

function ScoreState:update(dt)
    if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        gStateMachine:change("play")
    end
end

function ScoreState:render()
    love.graphics.setFont(bigFont)
    love.graphics.printf("You scored...", 0, 60, VIRTUAL_WIDTH, "center")
    love.graphics.printf(self.score .. " points!", 0, 100, VIRTUAL_WIDTH, "center")
    love.graphics.setFont(mediumFont)
    love.graphics.printf("Press Enter to Restart!", 0, 150, VIRTUAL_WIDTH, "center")
end
```

`PlayState.lua`

```Lua
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
```

`TitleScreenState.lua`

```Lua
--[[
    TitleScreenState Class

    Overrides methods found in BaseState.
    Contains functionality for when the user is at the start screen.
]]

TitleScreenState = Class{__includes = BaseState}

function TitleScreenState:update(dt)
    if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        gStateMachine:change("play")
    end
end

function TitleScreenState:render()
    love.graphics.setFont(bigFont)
    love.graphics.printf("Flappy Bird", 0, 50, VIRTUAL_WIDTH, "center")

    love.graphics.setFont(mediumFont)
    love.graphics.printf("Press Enter to Start", 0, 100, VIRTUAL_WIDTH, "center")
end
```
