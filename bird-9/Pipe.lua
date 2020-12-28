Pipe = Class{}

local IMAGE = love.graphics.newImage("pipe.png")
local PIPE_SCROLL = -100
-- height of pipe image, globally accessible
PIPE_HEIGHT = 288
PIPE_WIDTH = 70

function Pipe:init(orientation, y)
    self.width = IMAGE:getWidth()
    self.height = IMAGE:getHeight()
    self.orientation = orientation
    self.x = VIRTUAL_WIDTH + (self.width / 2)
    self.y = y
end

function Pipe:update(dt)
    self.x = self.x + (PIPE_SCROLL * dt)
end

function Pipe:render()
    -- scale factor of -1 flips sprite 
    -- When flipping on y axis, it shifts Object by its height amount and flip the object. Need to move the object back down by the object height amount. 
    love.graphics.draw(IMAGE, 
        self.x, -- x axis position
        (self.orientation == "top" and (self.y + PIPE_HEIGHT) or self.y), -- y axis position
        0, -- orientation (radians)
        1, -- Scale factor (x-axis)
        (self.orientation == "top" and -1 or 1) -- Scale factor (y-axis).
    )
end
