-- Use push library, allows us to draw the game at a virtual resolution, instead of how large our window is. Used to provide a more retro aesthetic
-- https://github.com/Ulydev/push
local push = require "push"
-- The "Class" library allows us to represent objects and classes
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require "class"

require "Bird"

WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720
VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 512, 288 -- Fixed game resolution

-- Load images into memory from files, to draw onto the screen
local background = love.graphics.newImage("background.png")
local backgroundScroll = 0
local ground = love.graphics.newImage("ground.png")
local groundScroll = 0

local BACKGROUND_SCROLL_SPEED = 25
local GROUND_SCROLL_SPEED = 60
local BACKGROUND_LOOPING_POINT = 413

local bird = Bird()

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

function love.update(dt)
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
    groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH
    bird:update(dt)
end

function love.draw()
    push:start()
    love.graphics.draw(background, -backgroundScroll, 0)
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)
    bird:render()
    push:finish()
end