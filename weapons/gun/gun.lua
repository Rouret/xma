local Skills = require("engine.skills")
local GlobalState = require("game.state")
local Bullet = require("weapons.gun.bullet")
local State = require("player.state")
local Timer = require("engine.timer")
local Weapon = require("engine.weapon")

local Gun = Weapon:extend()

function Gun:init()
    params = params or {}
    params.skills = {
        Skills.new(
            {
                name = "Shoot",
                cooldown = 0.5,
                damage = 10,
                image = "sprites/weapons/gun/skill1.jpg",
                effect = function()
                    GlobalState:addEntity(
                        Bullet:new(
                            {
                                damage = 20,
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
                                    Bullet:new(
                                        {
                                            damage = 20,
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
                                Bullet:new(
                                    {
                                        damage = 60,
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
    params.image = "sprites/weapons/gun/gun.png"
    params.imageRatio = 1

    Weapon.init(self, params)
    return self
end

function Gun:update(dt)
end

return Gun
