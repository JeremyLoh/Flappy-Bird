local push = require "push"

local WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720
local VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 512, 288 -- Fixed game resolution

local background = love.graphics.newImage("background.png")
local ground = love.graphics.newImage("ground.png")

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest', 16)
    love.window.setTitle("Flappy Bird")
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true,
    })
end

function love.resize(width, height)
    push:resize(width, height)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    end
end

function love.draw()
    push:start()
    love.graphics.draw(background, 0, 0)
    love.graphics.draw(ground, 0, VIRTUAL_HEIGHT - 16)
    push:finish()
end