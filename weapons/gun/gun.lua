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
        Skills.new(
            {
                name = "Shoot",
                cooldown = 0.5,
                damage = 10,
                image = "sprites/weapons/gun/skill1.jpg",
                effect = function()
                    GlobalState:addEntity(
                        Bullet.new(
                            {
                                damage = 50,
                                x = State.x,
                                y = State.y,
                                speed = 1500,
                                TTL = 0.75
                            }
                        )
                    )
                end
            }
        ),
        Skills.new(
            {
                name = "Multi shoot",
                cooldown = 3,
                damage = 0,
                image = "sprites/weapons/gun/skill2.jpg",
                effect = function()
                    local nbBullet = 3
                    for i = 1, nbBullet do
                        Timer:after(
                            0.1 * i,
                            function()
                                GlobalState:addEntity(
                                    Bullet.new(
                                        {
                                            damage = 10,
                                            x = State.x,
                                            y = State.y,
                                            speed = 2500
                                        }
                                    )
                                )
                            end
                        )
                    end
                end
            }
        ),
        Skills.new(
            {
                name = "Sniper shoot",
                cooldown = 5,
                damage = 30,
                image = "sprites/weapons/gun/skill3.jpg",
                effect = function()
                    State.status = "immobilized"
                    -- Ajouter un délai de 500ms avant de tirer
                    Timer:after(
                        0.5,
                        function()
                            GlobalState:addEntity(
                                Bullet.new(
                                    {
                                        damage = 30,
                                        x = State.x,
                                        y = State.y,
                                        TTL = 2,
                                        speed = 3250,
                                        direction = State.getAngleToMouse()
                                    }
                                )
                            )
                            State.status = "idle" -- Libérer l'état immobilisé
                        end
                    )
                end
            }
        )
    }
    self.image = love.graphics.newImage("sprites/weapons/gun/gun.png")
    return self
end

-- Draw the gun
function Gun:draw()
    -- Check if weapon is in hand or back
    if State.isWeaponEquipped(self.name) then
        self:drawInHand(State.x, State.y)
    else
        self:drawInBack()
    end
end

-- Draw gun in hand
function Gun:drawInHand(x, y)
    local rotation = State.getAngleToMouse() - math.pi / 2
    love.graphics.draw(self.image, x, y, rotation, 1, 1, 0, 0)
end

-- Draw gun in the back
function Gun:drawInBack()
end

return Gun
