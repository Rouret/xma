local State = require("player.state")
local love = require("love")

local Camera = {}
Camera.DEFAULT_SCALE = 0.5
-- Initialise la caméra globale (singleton)
function Camera.init(x, y, scale, map)
    Camera.width = love.graphics.getWidth()
    Camera.height = love.graphics.getHeight()
    Camera.x = x
    Camera.y = y
    Camera.scale = scale or Camera.DEFAULT_SCALE
    Camera.midWidth = Camera.width / 2
    Camera.midHeight = Camera.height / 2
    Camera.map = map

    Camera.mx = Camera.width / Camera.map.MAP_WIDTH
    Camera.my = Camera.height / Camera.map.MAP_HEIGHT
end

-- Définit la position de la caméra
---@param x number
---@param y number
function Camera.setPosition(x, y)
    local function clamp(value, min, max)
        if value < min then
            return min
        elseif value > max then
            return max
        else
            return value
        end
    end

    local midWidth, midHeight = Camera.midWidth, Camera.midHeight
    local mapWidth, mapHeight =
        Camera.map.MAP_WIDTH * Camera.map.TILE_SIZE,
        Camera.map.MAP_HEIGHT * Camera.map.TILE_SIZE

    ---@type number
    local new_x = clamp(x, midWidth, mapWidth - midWidth)
    ---@type number
    local new_y = clamp(y, midHeight, mapHeight - midHeight)

    Camera.x = math.floor(new_x)
    Camera.y = math.floor(new_y)
end
function Camera.setScale(scale)
    Camera.scale = scale
end

-- Applique la transformation de la caméra
function Camera.apply()
    love.graphics.push()
    love.graphics.scale(Camera.scale)
    love.graphics.translate(
        -Camera.x + math.floor(love.graphics.getWidth() / (2 * Camera.scale)),
        -Camera.y + math.floor(love.graphics.getHeight() / (2 * Camera.scale))
    )
end

-- Réinitialise la transformation de la caméra
function Camera.reset()
    love.graphics.pop()
end

function Camera.getVisibleArea()
    local halfWidth = Camera.width / (2 * Camera.scale)
    local halfHeight = Camera.height / (2 * Camera.scale)
    local x = Camera.x - halfWidth
    local y = Camera.y - halfHeight
    local width = halfWidth * 2
    local height = halfHeight * 2

    return x, y, width, height
end

function Camera.isVisible(x, y, objectWidth, objectHeight)
    local a = {x = x, y = y}
    local b = {x = x + objectWidth, y = y + objectHeight}

    return Camera.isPositionInCamera(a.x, a.y) or Camera.isPositionInCamera(b.x, b.y)
end

function Camera.getT()
    local tx = State.x - Camera.width / (2 * Camera.scale)
    local ty = State.y - Camera.height / (2 * Camera.scale)

    if tx < 0 then
        tx = 0
    end

    if ty < 0 then
        ty = 0
    end

    return tx, ty
end

function Camera.isPositionInCamera(x, y)
    local transform = love.math.newTransform()
    transform:scale(Camera.scale)
    transform:translate(
        -Camera.x + math.floor(love.graphics.getWidth() / (2 * Camera.scale)),
        -Camera.y + math.floor(love.graphics.getHeight() / (2 * Camera.scale))
    )

    -- Applique la transformation
    local sx, sy = transform:transformPoint(x, y)

    return sx >= 0 and sx <= Camera.width and sy >= 0 and sy <= Camera.height
end

function Camera.worldToScreen(x, y)
    -- Créer une transformation avec la mise à l'échelle et la translation
    local transform = love.math.newTransform()

    -- Appliquer la mise à l'échelle
    transform:scale(Camera.scale)

    -- Appliquer la translation (ajustement pour centrer la vue)
    transform:translate(
        -Camera.x + math.floor(love.graphics.getWidth() / (2 * Camera.scale)),
        -Camera.y + math.floor(love.graphics.getHeight() / (2 * Camera.scale))
    )

    -- Appliquer la transformation au point
    local sx, sy = transform:transformPoint(x, y)

    return sx, sy
end

return Camera
