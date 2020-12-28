--[[
    BaseState Class

    Used as the base class for all of our states. 
    We will not need to define empty methods in each of them.

    The StateMachine requires each State to have 4 methods implemented.
    Inheriting from this base class allows for the 4 required methods to exist even if we do not override them.
]]

BaseState = Class{}

function BaseState:init() end
function BaseState:enter() end
function BaseState:exit() end
function BaseState:update(dt) end
function BaseState:render() end
