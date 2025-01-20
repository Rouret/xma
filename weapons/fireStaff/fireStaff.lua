local Skills = require("skills")
local GlobalState = require("game.state")
local FireBall = require("weapons.fireStaff.fireBall")
local State = require("player.state")
local Timer = require("timer")
local Weapon = require("engine.weapon")

local FireStaff = Weapon:extend()

function FireStaff:init()
    params = params or {}
    params.skills = {
        Skills.new(
            {
                name = "Shoot",
                cooldown = 0.5,
                damage = 10,
                image = "sprites/weapons/gun/skill1.jpg",
                effect = function()
                    self.status = "casting"
                    GlobalState:addEntity(
                        FireBall:new(
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
                    local nbFireBall = 3
                    for i = 1, nbFireBall do
                        Timer:after(
                            0.1 * i,
                            function()
                                GlobalState:addEntity(
                                    FireBall:new(
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
                                FireBall:new(
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
    params.image = "sprites/weapons/fireStaff/firestaff.png"
    params.imageRatio = 1

    Weapon.init(self, params)
    return self
end

function FireStaff:drawInHand(x, y)
    local rotation = State.getAngleToMouse() + math.pi / 2

    love.graphics.draw(
        self.sprite,
        x,
        y,
        rotation,
        self.imageRatio,
        self.imageRatio,
        self.sprintWidth,
        self.spriteHeight / 2
    )
end

function FireStaff:update(dt)
end

return FireStaff
