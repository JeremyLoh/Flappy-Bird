-- Use push library, allows us to draw the game at a virtual resolution, instead of how large our window is. Used to provide a more retro aesthetic
-- https://github.com/Ulydev/push
local push = require "push"
-- The "Class" library allows us to represent objects and classes
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require "class"

require "Bird"
require "Pipe"
require "PipePair"

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
local pipePairs = {}

local spawnTimer = 0
local lastPipeY = -PIPE_HEIGHT + math.random(60) + 20
-- scrolling variable to pause the game when we collide with a pipe
local scrolling = true

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest', 16)
    love.window.setTitle("Flappy Bird")
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true,
    })
    -- Seed RNG
    math.randomseed(os.time())
    -- Create own key
    love.keyboard.keysPressed = {}
end

function love.resize(width, height)
    push:resize(width, height)
end

function love.keypressed(key, scancode, isrepeat)
    love.keyboard.keysPressed[key] = true
    if key == "escape" then
        love.event.quit()
    end
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    if scrolling then
        backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
        groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH
        
        spawnTimer = spawnTimer + dt
        if spawnTimer > 2 then
            local topY = -PIPE_HEIGHT + 20
            local bottomY = math.min(lastPipeY + math.random(-20, 20), VIRTUAL_HEIGHT - 90)
            -- Limit y values 
            local y = math.max(topY, bottomY)
            table.insert(pipePairs, PipePair(y))
            spawnTimer = 0
        end

        bird:update(dt)

        -- Iterate over all pipes
        for key, pair in pairs(pipePairs) do
            pair:update(dt)
            -- Check for collision between bird and pipe
            for k, pipe in pairs(pair.pipes) do
                if bird:collides(pipe) then
                    scrolling = false
                end
            end
        end

        -- Remove any flagged pipes
        -- Need this second loop, rather than deleting in the previous loop
        -- Modifying the table in-place without explicit keys will result in skipping the next pipe,
        -- since all implicit keys (numerical indices) are automatically shifted
        -- down after a table removal
        for key, pair in pairs(pipePairs) do
            if pair.remove then
                table.remove(pipePairs, key)
            end
        end
    end
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()
    love.graphics.draw(background, -backgroundScroll, 0)
    for key, pair in pairs(pipePairs) do
        pair:render()
    end
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)
    bird:render()
    push:finish()
end