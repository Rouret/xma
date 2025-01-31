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
        elementName = "Big_tree",
        name = "Forest",
        minAltitude = 0.1,
        maxAltitude = 0.20,
        minHumidity = 0.5,
        maxHumidity = 0.7,
        color = {144 / 255, 203 / 255, 162 / 255},
        probability = 0.44,
        element = {
            width = 55,
            height = 85,
            x = 0,
            y = 66,
            collision = true,
            hitbox = {x = 0, y = 0, width = 55, height = 85}
        }
    },
    {
        elementName = "Big_stone",
        name = "Big_stone",
        minAltitude = 0.3,
        maxAltitude = 0.40,
        minHumidity = 0.5,
        maxHumidity = 0.7,
        color = {144 / 255, 203 / 255, 162 / 255},
        probability = 0.05,
        element = {
            width = 50,
            height = 50,
            x = 49,
            y = 0,
            collision = true,
            hitbox = {x = 0, y = 0, width = 50, height = 50}
        }
    },
    {
        elementName = "Small_stone",
        name = "Small_stone",
        minAltitude = 0.3,
        maxAltitude = 0.40,
        minHumidity = 0.8,
        maxHumidity = 1,
        color = {144 / 255, 203 / 255, 162 / 255},
        probability = 0.2,
        element = {
            width = 40,
            height = 30,
            x = 0,
            y = 0,
            collision = true,
            hitbox = {x = 0, y = 0, width = 40, height = 30}
        }
    },
    {
        elementName = "Big_bush",
        name = "Big_bush",
        minAltitude = 0.1,
        maxAltitude = 0.50,
        minHumidity = 0.7,
        maxHumidity = 1,
        color = {144 / 255, 203 / 255, 162 / 255},
        probability = 1,
        element = {
            width = 50,
            height = 50,
            x = 0,
            y = 181,
            collision = true,
            hitbox = {x = 0, y = 181, width = 50, height = 50}
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
