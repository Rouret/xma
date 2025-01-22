-- engine/camera.lua

local camera = {}
camera.__index = camera

-- Instance unique pour la caméra globale
camera.i = nil
local DEFAULT_SCALE = 0.5
-- Initialise la caméra globale (singleton)
function camera.init(x, y, scale, map)
    if not camera.i then
        camera.i =
            setmetatable(
            {
                x = x or 0,
                y = y or 0,
                scale = scale or DEFAULT_SCALE
            },
            camera
        )
    end

    camera.i.width = love.graphics.getWidth()
    camera.i.height = love.graphics.getHeight()
    camera.i.midWidth = camera.i.width / 2
    camera.i.midHeight = camera.i.height / 2
    camera.i.map = map

    return camera.i
end

-- Crée une nouvelle instance de caméra (non liée à l'instance globale)
function camera.new(x, y, scale)
    return setmetatable(
        {
            x = x or 0,
            y = y or 0,
            scale = scale or DEFAULT_SCALE
        },
        camera
    )
end

-- Définit la position de la caméra
function camera:setPosition(x, y)
    local function clamp(value, min, max)
        if value < min then
            return min
        elseif value > max then
            return max
        else
            return value
        end
    end

    local midWidth, midHeight = self.midWidth, self.midHeight
    local mapWidth, mapHeight = self.map.MAP_WIDTH * 32, self.map.MAP_HEIGHT * 32

    x = clamp(x, midWidth, mapWidth - midWidth)
    y = clamp(y, midHeight, mapHeight - midHeight)

    self.x = math.floor(x)
    self.y = math.floor(y)
end

-- Définit le zoom de la caméra
function camera:setScale(scale)
    self.scale = scale
end

-- Applique la transformation de la caméra
function camera:apply()
    love.graphics.push()
    love.graphics.scale(self.scale)
    love.graphics.translate(
        -self.x + math.floor(love.graphics.getWidth() / (2 * self.scale)),
        -self.y + math.floor(love.graphics.getHeight() / (2 * self.scale))
    )
end

-- Réinitialise la transformation de la caméra
function camera:reset()
    love.graphics.pop()
end

-- Optimiser getVisibleArea
function camera:getVisibleArea()
    local halfWidth = camera.i.width / (2 * self.scale)
    local halfHeight = camera.i.height / (2 * self.scale)
    local x = self.x - halfWidth
    local y = self.y - halfHeight
    local width = halfWidth * 2
    local height = halfHeight * 2

    return x, y, width, height
end

return camera
