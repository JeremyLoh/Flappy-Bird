PipePair = Class{}

local PIPE_GAP = 90

function PipePair:init(y)
    pipeGapRandomReduction = math.random(-10, 0)
    self.x = VIRTUAL_WIDTH + (PIPE_WIDTH / 2)
    self.y = y
    -- When flipping on y axis, it shifts Object by its height amount and flip the object. Need to move the object back down by the object height amount.
    self.pipes = {
        ["top"] = Pipe("top", self.y),
        ["bottom"] = Pipe("bottom", self.y + PIPE_GAP
            + pipeGapRandomReduction + PIPE_HEIGHT)
    }
    self.remove = false
    -- Keep track of whether pair of pipes have been scored
    self.scored = false
end

function PipePair:update(dt)
    for key, pipe in pairs(self.pipes) do
        pipe:update(dt)
        self.x = pipe.x
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