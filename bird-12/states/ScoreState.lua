--[[
    ScoreState Class

    Keeps track of player score.

    A point is given to the player when they pass a set of pipes without touching the pipes or the ground.
]]

ScoreState = Class{__includes = BaseState}

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
    self.printMedals(self.score)
    love.graphics.setFont(mediumFont)
    love.graphics.printf("Press Enter to Restart!", 0, 150, VIRTUAL_WIDTH, "center")
end
