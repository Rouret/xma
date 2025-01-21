local Skills = require("skills")
local GlobalState = require("game.state")
local FireBall = require("weapons.fireStaff.fireBall")
local State = require("player.state")
local Weapon = require("engine.weapon")
local FireZone = require("weapons.fireStaff.fireZone")

local FireStaff = Weapon:extend()

function FireStaff:init()
    local params = {}
    params.skills = {
        self:skill1(),
        self:skill2(),
        self:skill3()
    }

    params.image = "sprites/weapons/fireStaff/firestaff.png"
    params.imageRatio = 1

    Weapon.init(self, params)

    self.animationDuration = 0.5
    self.animationTimer = 0

    return self
end

function FireStaff:drawInHand(x, y)
    local rotation = State.getAngleToMouse() + math.pi / 2

    if self.status == "casting" then
        rotation = rotation + math.sin(self.animationTimer * 10) / 10
    end

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
    if self.status == "casting" then
        self.animationTimer = self.animationTimer + dt
        if self.animationTimer >= self.animationDuration then
            self.status = "idle"
            self.animationTimer = 0
        end
    end
end

function FireStaff:skill1()
    return Skills.new(
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
                            damage = 35,
                            x = State.x,
                            y = State.y,
                            speed = 1500,
                            TTL = 0.75
                        }
                    )
                )
            end
        }
    )
end

function FireStaff:skill2()
    return Skills.new(
        {
            name = "Circle fire",
            cooldown = 3,
            damage = 0,
            image = "sprites/weapons/gun/skill2.jpg",
            effect = function()
                self.status = "casting"
                for i = 0, 360, 45 do
                    GlobalState:addEntity(
                        FireBall:new(
                            {
                                damage = 15,
                                x = State.x,
                                y = State.y,
                                speed = 1200,
                                TTL = 0.4,
                                direction = math.rad(i),
                                imageRatio = 1.5
                            }
                        )
                    )
                end
            end
        }
    )
end

function FireStaff:skill3()
    return Skills.new(
        {
            name = "Sniper shoot",
            cooldown = 5,
            damage = 30,
            image = "sprites/weapons/gun/skill3.jpg",
            effect = function()
                self.status = "casting"
                GlobalState:addEntity(
                    FireBall:new(
                        {
                            damage = 20,
                            x = State.x,
                            y = State.y,
                            speed = 1500,
                            TTL = 0.75,
                            beforeDestroy = function(fireBall)
                                GlobalState:addEntity(
                                    FireZone:new(
                                        {
                                            x = fireBall.x,
                                            y = fireBall.y,
                                            radius = 100,
                                            damage = 10,
                                            duration = 2
                                        }
                                    )
                                )
                            end
                        }
                    )
                )
            end
        }
    )
end

return FireStaff
