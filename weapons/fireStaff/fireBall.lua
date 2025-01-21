local BulletObject = require("weapons.BulletObject")

local FireBall = BulletObject:extend()
FireBall.__index = FireBall

function FireBall:init(params)
    params = params or {}
    params.name = "fireBall"
    params.imageRatio = params.imageRatio or 1
    params.imagePath = "sprites/weapons/fireStaff/fireball.png"

    BulletObject.init(self, params)
    return self
end

function FireBall:ajusteRotation()
    return self.direction
end

return FireBall
