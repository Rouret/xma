local State = require("player.state")
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

    camera.i.mx = camera.i.width / camera.i.map.MAP_WIDTH
    camera.i.my = camera.i.height / camera.i.map.MAP_HEIGHT

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

function camera:getVisibleArea()
    local halfWidth = camera.i.width / (2 * self.scale)
    local halfHeight = camera.i.height / (2 * self.scale)
    local x = self.x - halfWidth
    local y = self.y - halfHeight
    local width = halfWidth * 2
    local height = halfHeight * 2

    return x, y, width, height
end

function camera:isVisible(x, y, objectWidth, objectHeight)
    local a = {x = x, y = y}
    local b = {x = x + objectWidth, y = y + objectHeight}

    return self:isPositionInCamera(a.x, a.y) and self:isPositionInCamera(b.x, b.y)
end

function camera:getT()
    local tx = State.x - camera.i.width / (2 * self.scale)
    local ty = State.y - camera.i.height / (2 * self.scale)

    if tx < 0 then
        tx = 0
    end

    if ty < 0 then
        ty = 0
    end

    return tx, ty
end

function camera:isPositionInCamera(x, y)
    local transform = love.math.newTransform()
    transform:scale(self.scale)
    transform:translate(
        -self.x + math.floor(love.graphics.getWidth() / (2 * self.scale)),
        -self.y + math.floor(love.graphics.getHeight() / (2 * self.scale))
    )

    -- Applique la transformation
    local sx, sy = transform:transformPoint(x, y)

    return sx >= 0 and sx <= camera.i.width and sy >= 0 and sy <= camera.i.height
end

function camera:worldToScreen(x, y)
    -- Créer une transformation avec la mise à l'échelle et la translation
    local transform = love.math.newTransform()

    -- Appliquer la mise à l'échelle
    transform:scale(self.scale)

    -- Appliquer la translation (ajustement pour centrer la vue)
    transform:translate(
        -self.x + math.floor(love.graphics.getWidth() / (2 * self.scale)),
        -self.y + math.floor(love.graphics.getHeight() / (2 * self.scale))
    )

    -- Appliquer la transformation au point
    local sx, sy = transform:transformPoint(x, y)

    return sx, sy
end

return camera
