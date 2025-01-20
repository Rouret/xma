local GlobalState = require("game.state")
local World = require("game.world")
local State = require("player.state")
local BulletObject = require("weapons.BulletObject")

local FireBall = BulletObject:extend()
FireBall.__index = FireBall

function FireBall:init(params)
    params = params or {}
    params.name = "fireBall"
    params.imageRatio = 1
    params.imagePath = "sprites/weapons/fireStaff/fireball.png"

    BulletObject.init(self, params)
    return self
end

function FireBall:ajusteRotation()
    return self.direction + math.pi / 2
end

return FireBall
