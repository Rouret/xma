local TileUtils = require("engine.map.tileUtils")
local World = require("game.world")

local Forest = {}

-- Général
Forest.name = "Forest"

Forest.minAltitude = 0
Forest.maxAltitude = 0.5
Forest.minHumidity = 0.5
Forest.maxHumidity = 1
Forest.color = {0, 1, 0}

Forest.sub = {
    {
        elementName = "Medium_tree",
        name = "Forest",
        minAltitude = 0.15,
        maxAltitude = 0.35,
        minHumidity = 0.65,
        maxHumidity = 0.85,
        color = {144 / 255, 203 / 255, 162 / 255},
        probability = 0.8,
        element = {
            width = 34,
            height = 47,
            x = 20,
            y = 0,
            collision = true,
            hitbox = {x = 20, y = 3, width = 34, height = 44}
        }
    }
}

-- Terrain
Forest.terrainPath = "sprites/tilesets/forest/forest_ground.png"
Forest.terrainTileSize = 32

-- Éléments
Forest.elementsPath = "sprites/tilesets/forest/forest_elements.png"

function Forest.loadAssets()
    -- Terrain
    Forest.terrain = love.graphics.newImage(Forest.terrainPath)
    Forest.terrain:setFilter("nearest", "nearest")
    Forest.terrainQuads = TileUtils.createTileQuads(Forest.terrain, Forest.terrainTileSize)

    -- Éléments
    Forest.element = love.graphics.newImage(Forest.elementsPath)
    Forest.element:setFilter("nearest", "nearest")
    Forest.elementQuads = {}
    local elementWidth = Forest.element:getWidth()
    local elementHeight = Forest.element:getHeight()
    Forest.elements = {}

    for _, subElement in ipairs(Forest.sub) do
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

function Forest.generateTerrain()
    local groundQuadIndex = love.math.random(#Forest.terrainQuads)
    return {
        quad = Forest.terrainQuads[groundQuadIndex],
        collision = false -- Pas d'obstacle par défaut
    }
end

function Forest.generateElement(x, y, altitude, humidity)
    for _, subElement in ipairs(Forest.sub) do
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

            local elementCreated = {
                quad = subElement.quad,
                type = elementType,
                x = (x) * 32,
                y = (y) * 32,
                collision = elementData.collision,
                hitbox = elementData.hitbox and
                    {
                        x = (x * 32) + elementData.hitbox.x,
                        y = (y * 32) + elementData.hitbox.y,
                        width = elementData.hitbox.width,
                        height = elementData.hitbox.height
                    } or
                    nil
            }

            Forest.initElement(elementCreated)

            return elementCreated
        end
    end
    return nil
end

function Forest.initElement(element)
    if element.hitbox and element.collision then
        local body =
            love.physics.newBody(World.world, element.hitbox.x, element.hitbox.y - element.hitbox.height / 2, "static")
        local shape = love.physics.newRectangleShape(element.hitbox.width, element.hitbox.height)
        local fixture = love.physics.newFixture(body, shape)
        fixture:setUserData({name = "wall", type = "wall"})
    end
end

function Forest.drawElement(element)
    love.graphics.draw(Forest.element, element.quad, element.x, element.y - element.hitbox.height)
end

return Forest
