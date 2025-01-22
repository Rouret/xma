local TileUtils = require("engine.map.tileUtils")

local Desert = {}

-- Général
Desert.name = "Desert"
Desert.spawnProbability = 0.9

-- Terrain
Desert.terrainPath = "sprites/tilesets/desert/desert_ground.png"
Desert.terrainTileSize = 32

function Desert.loadAssets()
    -- Terrain
    Desert.terrain = love.graphics.newImage(Desert.terrainPath)
    Desert.terrain:setFilter("nearest", "nearest")
    local result = TileUtils.createTileQuads(Desert.terrain, Desert.terrainTileSize)
    -- only the first one is needed
    Desert.terrainQuads = {result[1]}
end

function Desert.generateTerrain(x, y)
    local groundQuadIndex = love.math.random(#Desert.terrainQuads)
    return {
        quad = Desert.terrainQuads[groundQuadIndex],
        collision = false -- Pas d'obstacle par défaut
    }
end

function Desert.generateElement(x, y)
    return nil
end

function Desert.drawElement(element)
    love.graphics.draw(Desert.element, element.quad, element.x, element.y - Desert.elements[element.type].height)
end

return Desert
