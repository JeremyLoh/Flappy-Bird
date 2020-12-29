--[[
    StateMachine - The game's state machine
    
    Usage:
        States are only created as needed, to save memory, reduce cleanup bugs and increase speed due to garbage collection taking longer with more data in memory

        States are added with a string identifier and an initialisation function.
        It is expected that the init function, when called, will return a table with Render, Update, Enter and Exit methods.
        
        gStateMachine = StateMachine ({
            ["MainMenu"] = function()
                return MainMenu()
            end,
            ["InnerGame"] = function()
                return InnerGame()
            end,
            ["GameOver"] = function()
                return GameOver()
            end,
        })
        gStateMachine:change("MainGame")

        Arguments passed into the Change function after the state name
        will be forwarded to the Enter function of the state being changed too.
]]

StateMachine = Class{}

function StateMachine:init(states)
    -- states is a table that returns functions that represent the state
    -- There are 4 possible functions for each item in the states table:
    -- render, update, enter, exit
    self.states = states or {} 
    self.empty = {
        ["render"] = function() end,
        ["update"] = function() end,
        ["enter"] = function() end,
        ["exit"] = function() end,
    }
    self.currentState = self.empty
end

function StateMachine:change(stateName, enterParams)
    -- Ensure state name given is valid
    assert(self.states[stateName], "Invalid state name given for state change")
    self.currentState:exit()
    self.currentState = self.states[stateName]()
    self.currentState:enter(enterParams)
end

function StateMachine:update(dt)
    self.currentState:update(dt)
end

function StateMachine:render()
    self.currentState:render()
end
