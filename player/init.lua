local Player = {}
local State = require("player.state")
local Movement = require("player.movement")
local Animation = require("player.animation")
local Interaction = require("player.interaction")
local Draw = require("player.draw")
local Gun = require("weapons.gun.gun")
local Sword = require("weapons.sword")



function Player.load(world)
    State.load()
    State.weapons = {
        Gun.new(),
        Sword.new()
    }
    State.body = love.physics.newBody(world, State.x, State.y, "dynamic") -- Corps dynamique
    State.shape = love.physics.newCircleShape(State.radius) -- Forme circulaire
    State.fixture = love.physics.newFixture(State.body, State.shape)
    State.fixture:setUserData(State)
end

function Player.update(dt)
    if State.isAlive() then
        Movement.update(dt)
        Interaction.update(dt)
        Animation.update(dt)

        State.x, State.y = State.body:getPosition()
    end
end

function Player.draw()
    Draw.draw()
end

return Player
