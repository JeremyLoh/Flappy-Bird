--[[
    Representation of a Bird object in Flappy Bird
]]

Bird = Class{}

local GRAVITY = 800
local ANTI_GRAVITY = -220

function Bird:init()
    self.image = love.graphics.newImage("bird.png")
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()   
    self.x = (VIRTUAL_WIDTH / 2) - (self.width / 2)
    self.y = (VIRTUAL_HEIGHT / 2) - (self.height / 2)
    self.dy = 0
end

function Bird:collides(object)
    -- Use aabb collision detection
    -- All sides have been shrinked by a constant amount to reduce the bounding box (to give the player more leeway with the collision)
    shrinkAmount = 5
    birdLeftBoundary = self.x + shrinkAmount
    birdRightBoundary = self.x + self.width - shrinkAmount
    birdTopBoundary = self.y + shrinkAmount
    birdBottomBoundary = self.y + self.height - shrinkAmount
    return (birdLeftBoundary < (object.x + object.width) and 
        (birdRightBoundary) > object.x and 
        birdTopBoundary < (object.y + object.height) and 
        birdBottomBoundary > object.y)
end

function Bird:update(dt)
    self.dy = self.dy + (GRAVITY * dt)
    if love.keyboard.wasPressed('space') or love.mouse.wasPressed("primary") then
        sounds["jump"]:play()
        self.dy = ANTI_GRAVITY
    end
    self.y = math.max(0, self.y + self.dy * dt)
end

function Bird:render()
    love.graphics.draw(self.image, self.x, self.y)
end
