local TileUtils = require("engine.map.tileUtils")
local World = require("game.world")

local Taiga = {}

-- Général
Taiga.name = "Taiga"
Taiga.minAltitude = 0.5
Taiga.maxAltitude = 1
Taiga.minHumidity = 0
Taiga.maxHumidity = 1
Taiga.color = {1, 1, 1}

Taiga.sub = {
    {
        elementName = "Big_tree",
        name = "Taiga",
        minAltitude = 0.65,
        maxAltitude = 0.85,
        minHumidity = 0.4,
        maxHumidity = 0.6,
        color = {236 / 255, 240 / 255, 243 / 255},
        probability = 0.5,
        element = {
            width = 60,
            height = 91,
            x = 0,
            y = 0,
            collision = true,
            hitbox = {x = 0, y = 0, width = 60, height = 91}
        }
    }
}

-- Terrain
Taiga.terrainPath = "sprites/tilesets/taiga/taiga_ground.png"
Taiga.terrainTileSize = 32

-- Éléments
Taiga.elementsPath = "sprites/tilesets/taiga/taiga_elements.png"

function Taiga.loadAssets()
    -- Terrain
    Taiga.terrain = love.graphics.newImage(Taiga.terrainPath)
    Taiga.terrain:setFilter("nearest", "nearest")
    local result = TileUtils.createTileQuads(Taiga.terrain, Taiga.terrainTileSize)
    -- only the first one is needed
    Taiga.terrainQuads = {result[1], result[2], result[3], result[4], result[5]}

    -- Éléments
    Taiga.element = love.graphics.newImage(Taiga.elementsPath)
    Taiga.element:setFilter("nearest", "nearest")
    Taiga.elementQuads = {}
    local elementWidth = Taiga.element:getWidth()
    local elementHeight = Taiga.element:getHeight()
    Taiga.elements = {}

    for _, subElement in ipairs(Taiga.sub) do
        subElement.quad =
            love.graphics.newQuad(
            subElement.element.x,
            subElement.element.y,
            subElement.element.width,
            subElement.element.height,
            elementWidth,
            elementHeight
        )
    end
end

function Taiga.generateTerrain(x, y)
    local groundQuadIndex = love.math.random(#Taiga.terrainQuads)
    return {
        quad = Taiga.terrainQuads[groundQuadIndex],
        collision = false -- Pas d'obstacle par défaut
    }
end

function Taiga.generateElement(x, y, altitude, humidity)
    for _, subElement in ipairs(Taiga.sub) do
        local probability = love.math.random()

        if (probability > subElement.probability) then
            return nil
        end

        if
            altitude > subElement.minAltitude and altitude < subElement.maxAltitude and
                humidity > subElement.minHumidity and
                humidity < subElement.maxHumidity
         then
            local elementType = subElement.elementName
            local elementData = subElement.element

            x = x * 32
            y = y * 32

            local elementCreated = {
                quad = subElement.quad,
                type = elementType,
                x = x,
                y = y,
                collision = elementData.collision,
                hitbox = elementData.hitbox and
                    {
                        x = x + elementData.hitbox.x,
                        y = y + elementData.hitbox.y,
                        width = elementData.hitbox.width,
                        height = elementData.hitbox.height
                    } or
                    nil
            }

            Taiga.initElement(elementCreated)

            return elementCreated
        end
    end
    return nil
end

function Taiga.initElement(element)
    if element.hitbox and element.collision then
        local body = love.physics.newBody(World.world, element.hitbox.x, element.hitbox.y, "static")
        local shape = love.physics.newRectangleShape(element.hitbox.width, element.hitbox.height)
        local fixture = love.physics.newFixture(body, shape)
        fixture:setUserData({name = "wall", type = "wall"})
    end
end

function Taiga.drawElement(element)
    love.graphics.draw(Taiga.element, element.quad, element.x, element.y - element.hitbox.height)
end

return Taiga
