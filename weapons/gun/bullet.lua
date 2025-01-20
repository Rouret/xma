local GlobalState = require("game.state")
local World = require("game.world")
local State = require("player.state")
local BulletObject = require("weapons.BulletObject")

local Bullet = BulletObject:extend()
Bullet.__index = Bullet

function Bullet:init(params)
    params = params or {}
    params.name = "gunBullet"
    params.imageRatio = 2
    params.imagePath = "sprites/weapons/gun/bullet.png"

    BulletObject.init(self, params)
    return self
end

function Bullet:ajusteRotation()
    return self.direction + math.pi / 2
end

return Bullet
