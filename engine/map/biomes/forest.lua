local TileUtils = require("engine.map.tileUtils")
local World = require("game.world")

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
    Little_tree = {width = 19, height = 23, x = 0, y = 0, collision = false},
    Medium_tree = {
        width = 34,
        height = 47,
        x = 20,
        y = 0,
        collision = true,
        hitbox = {x = 20, y = 3, width = 34, height = 44}
    }
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
    local rand = love.math.random()
    local elementType

    if rand <= 0.02 then
        elementType = "Little_tree"
    elseif rand <= 0.07 then
        elementType = "Medium_tree"
    else
        return nil -- Pas d'élément généré
    end

    local elementData = Forest.elements[elementType]

    local element = {
        quad = Forest.elementQuads[elementType],
        type = elementType,
        x = (x - 0.5) * 32,
        y = (y - 0.5) * 32,
        collision = elementData.collision,
        hitbox = elementData.hitbox and
            {
                x = (x - 0.5) * 32 + elementData.hitbox.x,
                y = (y - 0.5) * 32 + elementData.hitbox.y,
                width = elementData.hitbox.width,
                height = elementData.hitbox.height
            }
    }
    return element
end

-- Fonction pour dessiner un élément
function Forest.drawElement(element)
    love.graphics.draw(Forest.element, element.quad, element.x, element.y - Forest.elements[element.type].height)

    -- Dessiner la hitbox pour le débogage (optionnel)
    if element.hitbox and element.collision then
        local body = love.physics.newBody(World.world, element.hitbox.x, element.hitbox.y, "static")
        local shape = love.physics.newRectangleShape(element.hitbox.width, element.hitbox.height)
        local fixture = love.physics.newFixture(body, shape)
        fixture:setUserData({name = "wall"})
    end
end

return Forest
