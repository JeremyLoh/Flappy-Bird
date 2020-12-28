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
        gStateMachine:change("countdown")
    end
end

function ScoreState:render()
    love.graphics.setFont(bigFont)
    love.graphics.printf("You scored...", 0, 60, VIRTUAL_WIDTH, "center")
    love.graphics.printf(self.score .. " points!", 0, 100, VIRTUAL_WIDTH, "center")
    love.graphics.setFont(mediumFont)
    love.graphics.printf("Press Enter to Restart!", 0, 150, VIRTUAL_WIDTH, "center")
end
