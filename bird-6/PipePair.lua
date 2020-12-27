PipePair = Class{}

local PIPE_GAP = 90

function PipePair:init(y)
    self.y = y
    -- When flipping on y axis, it shifts Object by its height amount and flip the object. Need to move the object back down by the object height amount. 
    self.pipes = {
        ["top"] = Pipe("top", self.y),
        ["bottom"] = Pipe("bottom", self.y + PIPE_GAP + PIPE_HEIGHT)
    }
    self.remove = false
end

function PipePair:update(dt)
    for key, pipe in pairs(self.pipes) do
        pipe:update(dt)
        -- Check for pipe exiting left of screen
        if pipe.x < -pipe.width then
            self.remove = true
        end
    end
end

function PipePair:render()
    for key, pipe in pairs(self.pipes) do
        pipe:render()
    end
end