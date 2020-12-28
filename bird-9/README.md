# bird-9: Countdown update

The game speed and pipe random distance has also been modified to make the game more difficult. The ground scroll speed in `main.lua` has been made to match the pipe scroll speed in `Pipe.lua` as well.

Fixes bug where the bird can fly above the top edge of the screen (in `Bird.lua`):

```Lua
function Bird:update(dt)
    self.dy = self.dy + (GRAVITY * dt)
    if love.keyboard.wasPressed('space') then
        self.dy = ANTI_GRAVITY
    end
    self.y = math.max(0, self.y + self.dy)
end
```

Adds a new state: `CountdownState` Class

    Counts down visually on the screen before the game is about to begin.

    The `CountdownState` automatically transitions to the `PlayState` as soon as the countdown is complete

`CountdownState.lua`

```Lua
CountdownState = Class{__includes = BaseState}

-- Set each count down duration (in seconds)
COUNTDOWN_INCREMENT = 0.75

function CountdownState:init()
    self.count = 3
    self.timer = 0
end

function CountdownState:update(dt)
    self.timer = self.timer + dt
    if self.timer > COUNTDOWN_INCREMENT then
        self.timer = self.timer % COUNTDOWN_INCREMENT
        self.count = self.count - 1
    end

    if self.count == 0 then
        gStateMachine:change("play")
    end
end

function CountdownState:render()
    love.graphics.setFont(bigFont)
    love.graphics.printf(tostring(self.count), 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, "center")
end
```

The `TitleScreenState` and `ScoreState` state classes have been modified to direct to the `CountdownState` when the game is about to start or when the game is over (to restart the game).

`main.lua` changes

```Lua
require "states/CountdownState"
local GROUND_SCROLL_SPEED = 100

function love.load()
    -- ...
    -- Initialize state machine with all states
    gStateMachine = StateMachine ({
        ["title"] = function() return TitleScreenState() end,
        ["play"] = function() return PlayState() end,
        ["score"] = function() return ScoreState() end,
        ["countdown"] = function() return CountdownState() end,
    })
    gStateMachine:change("title")
    -- ...
end
```
