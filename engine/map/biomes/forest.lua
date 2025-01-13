local TileUtils = require("engine.map.tileUtils")

local Forest = {}

-- Général
Forest.name = "Forest"
Forest.spawnProbability = 0.9

-- Terrain
Forest.terrainPath = "sprites/tilesets/forest/forest_ground.png"
Forest.terrainTileSize = 32

-- Éléments
Forest.elementsPath = "sprites/tilesets/forest/forest_elements.png"
Forest.elements = {
    Little_tree = {width = 19, height = 23, x = 0, y = 0, collision = false}
}

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

    for elementName, element in pairs(Forest.elements) do
        Forest.elementQuads[elementName] =
            love.graphics.newQuad(element.x, element.y, element.width, element.height, elementWidth, elementHeight)
    end
end

function Forest.generateTerrain(x, y)
    local groundQuadIndex = love.math.random(#Forest.terrainQuads)
    return {
        quad = Forest.terrainQuads[groundQuadIndex],
        collision = false -- Pas d'obstacle par défaut
    }
end

function Forest.generateElement(x, y)
    if love.math.random() < 0.1 then
        return {
            quad = Forest.elementQuads.Little_tree,
            type = "Little_tree",
            x = (x - 0.5) * 32,
            y = (y - 0.5) * 32,
            collision = Forest.elements.Little_tree.collision
        }
    end
end

-- Fonction pour dessiner un élément
function Forest.drawElement(element)
    love.graphics.draw(Forest.element, element.quad, element.x, element.y - Forest.elements[element.type].height)
end

return Forest
