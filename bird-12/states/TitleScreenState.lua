--[[
    TitleScreenState Class

    Overrides methods found in BaseState.
    Contains functionality for when the user is at the start screen.
]]

TitleScreenState = Class{__includes = BaseState}

function TitleScreenState:update(dt)
    if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        gStateMachine:change("countdown")
    end
end

function TitleScreenState:render()
    love.graphics.setFont(bigFont)
    love.graphics.printf("Flappy Bird", 0, 50, VIRTUAL_WIDTH, "center")

    love.graphics.setFont(mediumFont)
    love.graphics.printf("Press Enter to Start", 0, 100, VIRTUAL_WIDTH, "center")
end
