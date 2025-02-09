local BulletObject = require("weapons.BulletObject")

local IceBall = BulletObject:extend()
IceBall.__index = IceBall

-- IceBall throw by the iceSlime
function IceBall:init(params)
    params = params or {}
    params.name = "inceBall"
    params.imageRatio = params.imageRatio or 2
    params.imagePath = "sprites/enemies/ice_slime/ice_bullet.png"

    BulletObject.init(self, params)
    return self
end

function IceBall:ajusteRotation()
    return self.direction
end

function IceBall:onCollision(entity)
    if entity.name == "player" then
        entity.takeDamage(self.damage)
        self:destroy()
    end

    if entity.name == "beacon" then
        entity:takeDamage(self.damage)
        self:destroy()
    end

    if entity.type and entity.type == "wall" then
        self:destroy()
        return
    end
end

return IceBall
