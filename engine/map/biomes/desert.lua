local TileUtils = require("engine.map.tileUtils")
local World = require("game.world")
local Desert = {}

-- Général
Desert.name = "Desert"
Desert.minAltitude = 0
Desert.maxAltitude = 0.5
Desert.minHumidity = 0
Desert.maxHumidity = 0.5
Desert.color = {1, 1, 0}
Desert.sub = {}

-- Terrain
Desert.terrainPath = "sprites/tilesets/desert/desert_ground.png"
Desert.terrainTileSize = 32

-- Éléments
Desert.elementsPath = "sprites/tilesets/desert/desert_elements.png"
Desert.sub = {
    {
        elementName = "Cactus",
        name = "Cactus",
        minAltitude = 0.1,
        maxAltitude = 0.20,
        minHumidity = 0.1,
        maxHumidity = 0.2,
        color = {144 / 255, 203 / 255, 162 / 255},
        probability = 0.44,
        element = {
            width = 45,
            height = 60,
            x = 0,
            y = 0,
            collision = true,
            hitbox = {x = 0, y = 0, width = 45, height = 60}
        }
    }
}

function Desert.loadAssets()
    -- Terrain
    Desert.terrain = love.graphics.newImage(Desert.terrainPath)
    Desert.terrain:setFilter("nearest", "nearest")
    local result = TileUtils.createTileQuads(Desert.terrain, Desert.terrainTileSize)
    -- only the first one is needed
    Desert.terrainQuads = {result[1]}

    -- Éléments
    Desert.element = love.graphics.newImage(Desert.elementsPath)
    Desert.element:setFilter("nearest", "nearest")
    Desert.elementQuads = {}
    local elementWidth = Desert.element:getWidth()
    local elementHeight = Desert.element:getHeight()
    Desert.elements = {}

    for _, subElement in ipairs(Desert.sub) do
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

function Desert.generateTerrain(x, y)
    local groundQuadIndex = love.math.random(#Desert.terrainQuads)
    return {
        quad = Desert.terrainQuads[groundQuadIndex],
        collision = false -- Pas d'obstacle par défaut
    }
end

function Desert.generateElement(x, y, altitude, humidity)
    for _, subElement in ipairs(Desert.sub) do
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

            Desert.initElement(elementCreated)

            return elementCreated
        end
    end
    return nil
end
function Desert.initElement(element)
    if element.hitbox and element.collision then
        local body =
            love.physics.newBody(World.world, element.hitbox.x, element.hitbox.y - element.hitbox.height / 2, "static")
        local shape = love.physics.newRectangleShape(element.hitbox.width, element.hitbox.height)
        local fixture = love.physics.newFixture(body, shape)
        fixture:setUserData({name = "wall", type = "wall"})
    end
end

function Desert.drawElement(element)
    love.graphics.draw(Desert.element, element.quad, element.x, element.y - element.hitbox.height)
end

return Desert
