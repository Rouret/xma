local BulletObject = require("weapons.BulletObject")

---@class Bullet : BulletObject
local Bullet = BulletObject:extend()

function Bullet:new(params)
    ---@type Bullet
    local self = setmetatable({}, Bullet)

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
