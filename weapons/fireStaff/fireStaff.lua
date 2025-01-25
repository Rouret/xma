local Skills = require("engine.skills")
local GlobalState = require("game.state")
local FireBall = require("weapons.fireStaff.fireBall")
local State = require("player.state")
local Weapon = require("engine.weapon")
local FireZone = require("weapons.fireStaff.fireZone")
local World = require("game.world")
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

    -- Skill 2 effect
    self.skill2 = {
        rotation = 0,
        duration = 0.2,
        timer = 0
    }
    self.rotationInc = math.rad(360) / self.skill2.duration

    --Skill 3 particule, particule on the fireball
    self.skill3 = {}
    self.skill3.particles =
        love.graphics.newParticleSystem(love.graphics.newImage("sprites/weapons/fireStaff/fire_particule.png"), 100)

    self.skill3.particles:setParticleLifetime(0.5, 1)
    self.skill3.particles:setSizeVariation(1)
    self.skill3.particles:setEmissionRate(20)
    self.skill3.particles:setLinearAcceleration(-100, -100, 100, 100)
    self.skill3.particles:setColors(255, 255, 255, 255, 255, 255, 255, 0)
    self.skill3.particles:setSpeed(200, 300)
    self.skill3.particles:setSpread(math.pi * 2)
    self.skill3.particles:setEmissionArea("uniform", 10, 10)
    self.skill3.particles:setSizes(2, 1, 0.5)

    return self
end

function FireStaff:drawInHand(x, y)
    local rotation = State.getAngleToMouse() + math.pi / 2 - self.skill2.rotation

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

    if self.status == "skill2" then
        self.skill2.timer = self.skill2.timer + dt
        if self.skill2.timer >= self.skill2.duration then
            self.status = "idle"
            self.skill2.timer = 0
            self.skill2.rotation = 0
        else
            self.skill2.rotation = self.skill2.rotation + self.rotationInc * dt
        end
    end
end

function FireStaff:skill1()
    return Skills.new(
        {
            name = "Shoot",
            cooldown = 0.5,
            image = "sprites/weapons/fireStaff/skill1.png",
            effect = function()
                self.status = "casting"
                GlobalState:addEntity(
                    FireBall:new(
                        {
                            damage = 35,
                            x = State.x,
                            y = State.y,
                            speed = 1500,
                            TTL = 0.75,
                            from = "player"
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
            image = "sprites/weapons/fireStaff/skill2.png",
            effect = function()
                self.status = "skill2"
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
                                imageRatio = 3,
                                from = "player"
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
            cooldown = 1,
            image = "sprites/weapons/fireStaff/skill3.png",
            effect = function()
                self.status = "casting"
                self.skill3.particles:start()
                GlobalState:addEntity(
                    FireBall:new(
                        {
                            damage = 10,
                            x = State.x,
                            y = State.y,
                            speed = 1100,
                            TTL = 0.8,
                            from = "player",
                            beforeDestroy = function(fireBall)
                                self.skill3.particles:stop()
                                -- New FireZone need to do a World Operation, we need to delay this
                                table.insert(
                                    World.delayCallbacks,
                                    function()
                                        GlobalState:addEntity(
                                            FireZone:new(
                                                {
                                                    x = fireBall.x,
                                                    y = fireBall.y,
                                                    radius = 100,
                                                    damage = 10,
                                                    TTL = 5,
                                                    from = "player"
                                                }
                                            )
                                        )
                                    end
                                )
                            end,
                            afterUpdate = function(_, dt)
                                self.skill3.particles:update(dt)
                            end,
                            afterDraw = function(fireBall)
                                self.skill3.particles:setPosition(fireBall.x, fireBall.y)
                                love.graphics.draw(self.skill3.particles, 0, 0)
                            end
                        }
                    )
                )
            end
        }
    )
end

return FireStaff
