local TileUtils = require("engine.map.tileUtils")

local Forest = {}

Forest.name = "Forest"
Forest.tilesetPath = "sprites/tilesets/forest/forest_ground.png"
Forest.tileSize = 32

Forest.spawnProbability = 0.8
Forest.elements = {"Tree", "Bush"}

function Forest.loadAssets()
    Forest.tileset = love.graphics.newImage(Forest.tilesetPath)
    Forest.tileset:setFilter("nearest", "nearest")
    Forest.tilesetQuads = {}
    local tilesetWidth = Forest.tileset:getWidth()
    local tilesetHeight = Forest.tileset:getHeight()

    Forest.quads = TileUtils.createTileQuads(Forest.tileset, Forest.tileSize)
end

function Forest.generateTerrain(x, y)
    local groundQuadIndex = love.math.random(#Forest.quads)
    return {
        quad = Forest.quads[groundQuadIndex],
        collision = false -- Pas d'obstacle par défaut
    }
end

function Forest.generateElement(x, y)
    local elementType = love.math.random() > 0.5 and "Tree" or "Bush"
    return {
        type = elementType,
        x = (x - 0.5) * 32,
        y = (y - 0.5) * 32,
        properties = {harvestable = elementType == "Tree"}
    }
end

return Forest
