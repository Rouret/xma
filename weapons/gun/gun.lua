local Skills = require("skills")
local GlobalState = require("game.state")
local Bullet = require("weapons.gun.bullet")
local State = require("player.state")
local Timer = require("timer")

local Gun = {}
Gun.__index = Gun

function Gun.new()
    local self = setmetatable({}, Gun)
    self.name = "Gun"
    self.skills = {
        Skills.new({
            name = "Shoot",
            cooldown = 0.5,
            damage = 10,
            effect = function()
                GlobalState:addEntity(Bullet.new({
                    damage = 10,
                    x = State.x,
                    y = State.y,
                    direction = State.getAngleToMouse()
                }))
            end
        }),
        Skills.new({
            name = "Multi shoot",
            cooldown = 2,
            damage = 0,
            effect = function()
                -- Shoot 3 bullets with 50ms delay between each
                for i = 0, 2 do
                    GlobalState:addEntity(Bullet.new({
                            damage = 10,
                            x = State.x,
                            y = State.y,
                            direction = State.getAngleToMouse() + (i - 1) * 0.1
                        }))
                end
            end
        }),
        Skills.new({
            name = "Sniper shoot",
            cooldown = 1,
            damage = 30,
            effect = function()
                State.status = "immobilized"
                -- Ajouter un délai de 500ms avant de tirer
                Timer:after(0.5, function()
                    GlobalState:addEntity(Bullet.new({
                        damage = 30,
                        x = State.x,
                        y = State.y,
                        direction = State.getAngleToMouse()
                    }))
                    State.status = "idle" -- Libérer l'état immobilisé
                end)
            end
        }),
    }
    self.image = love.graphics.newImage("sprites/gun.png")
    return self
end

-- Draw the gun
function Gun:draw()
    -- Check if weapon is in hand or back
    if State.isWeaponEquipped(self.name) then
        self:drawInHand(State.x, State.y, State.getAngleForGun())
    else
        self:drawInBack()
    end
  
end

-- Draw gun in hand 
function Gun:drawInHand(x,y,rotation)
    love.graphics.draw(self.image, x, y, rotation, 1, 1, 0, 0)
end

-- Draw gun in the back
function Gun:drawInBack()
  
end

return Gun
