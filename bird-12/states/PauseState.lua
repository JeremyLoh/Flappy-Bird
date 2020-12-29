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
