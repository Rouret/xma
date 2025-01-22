local Skills = require("skills")
local State = require("player.state")
local Weapon = require("engine.weapon")

local Sword = Weapon:extend()

function Sword:init()
    params = params or {}
    params.skills = {
        Skills.new(
            {
                name = "1",
                cooldown = 0.5,
                damage = 10,
                image = "sprites/weapons/gun/skill1.jpg",
                effect = function()
                end
            }
        ),
        Skills.new(
            {
                name = "2",
                cooldown = 3,
                damage = 0,
                image = "sprites/weapons/gun/skill2.jpg",
                effect = function()
                end
            }
        ),
        Skills.new(
            {
                name = "2",
                cooldown = 5,
                damage = 30,
                image = "sprites/weapons/gun/skill3.jpg",
                effect = function()
                end
            }
        )
    }
    params.image = "sprites/weapons/sword/sword.png"
    params.imageRatio = 2

    Weapon.init(self, params)
    return self
end

function Sword:drawInHand(x, y)
    local rotation = State.getAngleToMouse() + math.pi / 2 -- Rotation par rapport à la souris

    love.graphics.draw(
        self.sprite,
        x,
        y,
        rotation,
        self.imageRatio,
        self.imageRatio,
        self.spriteWidth,
        self.spriteHeight
    )
end

return Sword
