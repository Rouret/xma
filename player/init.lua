local Player = {}
local State = require("player.state")
local Movement = require("player.movement")
local Animation = require("player.animation")
local Interaction = require("player.interaction")
local Draw = require("player.draw")
local Gun = require("weapons.gun.gun")

local FireStaff = require("weapons.fireStaff.fireStaff")

function Player.load(world)
    State.load()
    State.weapons = {
        FireStaff:new(),
        Gun:new()
    }
    State.body = love.physics.newBody(world, State.x, State.y, "dynamic") -- Corps dynamique
    State.shape = love.physics.newCircleShape(State.radius) -- Forme circulaire
    State.fixture = love.physics.newFixture(State.body, State.shape)
    State.fixture:setUserData(State)
end

function Player.update(dt)
    local currentTime = love.timer.getTime()
    if State.isAlive() then
        Movement.update()
        Interaction.update(dt)
        Animation.update(dt)

        -- Update weapons skill
        for _, weapon in ipairs(State.weapons) do
            weapon:update(dt)
            for _, skill in ipairs(weapon.skills) do
                skill:updateCooldown(currentTime)
            end
        end

        State.x, State.y = State.body:getPosition()
    end
end

function Player.draw()
    Draw.draw()
end

return Player
