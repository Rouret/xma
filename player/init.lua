local Player = {}
local State = require("player.state")
local Movement = require("player.movement")
local Animation = require("player.animation")
local Interaction = require("player.interaction")
local Draw = require("player.draw")

function Player.load()
    State.load()
end

function Player.update(dt)
    if State.isAlive() then
        Movement.update(dt)
        Interaction.update(dt)
        Animation.update(dt)
    end
end

function Player.draw()
    Draw.draw()
end

return Player
