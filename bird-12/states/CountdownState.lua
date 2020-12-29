--[[
    CountdownState Class

    Counts down visually on the screen before the game is about to begin. 
    The CountdownState automatically transitions to the PlayState as soon as the countdown is complete
]]

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
