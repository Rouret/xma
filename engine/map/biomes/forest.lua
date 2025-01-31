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

--[[
    2 types of spawn strategies:
        - perlin: spawn based on perlin noise
            minAltitude
            maxAltitude
            minHumidity
            maxHumidity
            probability
        - random: spawn randomly
            probability
]]
Forest.sub = {
    {
        elementName = "Big_tree",
        name = "Forest",
        color = {144 / 255, 203 / 255, 162 / 255},
        type = "perlin",
        typeMeta = {
            minAltitude = 0.1,
            maxAltitude = 0.20,
            minHumidity = 0.5,
            maxHumidity = 0.7,
            probability = 0.44
        },
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
        type = "random",
        typeMeta = {
            probability = 0.001
        },
        color = {144 / 255, 203 / 255, 162 / 255},
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
        type = "random",
        typeMeta = {
            probability = 0.001
        },
        color = {144 / 255, 203 / 255, 162 / 255},
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
        type = "random",
        typeMeta = {
            probability = 0.001
        },
        color = {144 / 255, 203 / 255, 162 / 255},
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
        local temp = nil
        if subElement.type == "perlin" then
            temp = Forest.generateElementPerlin(subElement, x, y, altitude, humidity)
        end

        if temp then
            return temp
        end

        if subElement.type == "random" then
            temp = Forest.generateElementRandom(subElement, x, y)
        end

        if temp then
            return temp
        end
    end

    return nil
end

function Forest.generateElementPerlin(subElement, x, y, altitude, humidity)
    local probability = love.math.random()

    if (probability > subElement.typeMeta.probability) then
        return nil
    end

    if
        altitude > subElement.typeMeta.minAltitude and altitude < subElement.typeMeta.maxAltitude and
            humidity > subElement.typeMeta.minHumidity and
            humidity < subElement.typeMeta.maxHumidity
     then
        return Forest.initElement(subElement, x, y)
    end

    return nil
end

function Forest.generateElementRandom(subElement, x, y)
    local probability = love.math.random()

    if (probability > subElement.typeMeta.probability) then
        return nil
    end

    return Forest.initElement(subElement, x, y)
end

function Forest.initElement(element, x, y)
    local elementType = element.elementName
    local elementData = element.element

    x = x * 32
    y = y * 32

    local elementCreated = {
        quad = element.quad,
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

    if elementCreated.hitbox and elementCreated.collision then
        local body =
            love.physics.newBody(
            World.world,
            elementCreated.hitbox.x,
            elementCreated.hitbox.y - elementCreated.hitbox.height / 2,
            "static"
        )
        local shape = love.physics.newRectangleShape(elementCreated.hitbox.width, elementCreated.hitbox.height)
        local fixture = love.physics.newFixture(body, shape)
        fixture:setUserData({name = "wall", type = "wall"})
    end

    return elementCreated
end

function Forest.drawElement(element)
    love.graphics.draw(Forest.element, element.quad, element.x, element.y - element.hitbox.height)
end

return Forest
