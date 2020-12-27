Pipe = Class{}

local IMAGE = love.graphics.newImage("pipe.png")
local PIPE_SCROLL = -50

function Pipe:init()
    self.width = IMAGE:getWidth()
    self.height = IMAGE:getHeight()
    self.x = VIRTUAL_WIDTH + (self.width / 2)
    self.y = math.random(VIRTUAL_HEIGHT / 4, VIRTUAL_HEIGHT - (self.width / 2))
end

function Pipe:update(dt)
    self.x = self.x + (PIPE_SCROLL * dt)
end

function Pipe:render()
    love.graphics.draw(IMAGE, self.x, self.y)
end
