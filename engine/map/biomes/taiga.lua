local TileUtils = require("engine.map.tileUtils")
local World = require("game.world")

local Taiga = {}

-- Général
Taiga.name = "Taiga"
Taiga.spawnProbability = 0.9

-- Terrain
Taiga.terrainPath = "sprites/tilesets/taiga/taiga_ground.png"
Taiga.terrainTileSize = 32

function Taiga.loadAssets()
    -- Terrain
    Taiga.terrain = love.graphics.newImage(Taiga.terrainPath)
    Taiga.terrain:setFilter("nearest", "nearest")
    local result = TileUtils.createTileQuads(Taiga.terrain, Taiga.terrainTileSize)
    -- only the first one is needed
    Taiga.terrainQuads = {result[1], result[2], result[3], result[4], result[5]}
end

function Taiga.generateTerrain(x, y)
    local groundQuadIndex = love.math.random(#Taiga.terrainQuads)
    return {
        quad = Taiga.terrainQuads[groundQuadIndex],
        collision = false -- Pas d'obstacle par défaut
    }
end

function Taiga.generateElement(x, y)
    return nil
end

function Taiga.drawElement(element)
    love.graphics.draw(Taiga.element, element.quad, element.x, element.y - Taiga.elements[element.type].height)
end

return Taiga
