-- Use push library, allows us to draw the game at a virtual resolution, instead of how large our window is. Used to provide a more retro aesthetic
-- https://github.com/Ulydev/push
local push = require "push"
-- The "Class" library allows us to represent objects and classes
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require "class"

require "Bird"
require "Pipe"
require "PipePair"
-- Import game state and state machine files
require "StateMachine"
require "states/BaseState"
require "states/PlayState" 
require "states/ScoreState"
require "states/CountdownState"
require "states/TitleScreenState"

WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720
VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 512, 288 -- Fixed game resolution

-- Load images into memory from files, to draw onto the screen
local background = love.graphics.newImage("background.png")
local backgroundScroll = 0
local ground = love.graphics.newImage("ground.png")
local groundScroll = 0

local BACKGROUND_SCROLL_SPEED = 25
local GROUND_SCROLL_SPEED = 100
local BACKGROUND_LOOPING_POINT = 413

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest', 16)
    love.window.setTitle("Flappy Bird")
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true,
    })

    -- Create fonts
    bigFont = love.graphics.newFont("fonts/FlappyBirdy.ttf", 32)
    mediumFont = love.graphics.newFont("fonts/FlappyBirdy.ttf", 20)

    -- Create sounds
    sounds = {
        ["jump"] = love.audio.newSource("sounds/jump.wav", "static"),
        ["hurt"] = love.audio.newSource("sounds/hurt.wav", "static"),
        ["explosion"] = love.audio.newSource("sounds/explosion.wav", "static"),
        ["score"] = love.audio.newSource("sounds/score.wav", "static"),
    }

    backgroundMusic = love.audio.newSource("sounds/Samuel Truth - Black & White - 02 Rua.mp3", "stream")
    backgroundMusic:setVolume(0.7)
    backgroundMusic:setLooping(true)
    backgroundMusic:play()

    -- Seed RNG
    math.randomseed(os.time())
    -- Initialize state machine with all states
    gStateMachine = StateMachine ({
        ["title"] = function() return TitleScreenState() end,
        ["play"] = function() return PlayState() end,
        ["score"] = function() return ScoreState() end,
        ["countdown"] = function() return CountdownState() end,
    })
    gStateMachine:change("title")

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