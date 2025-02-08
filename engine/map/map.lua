local NoiseUtils = require("engine.map.noiseUtils")
local Camera = require("engine.camera")
local Beacon = require("items.beacon")
local Config = require("config")

local Forest = require("engine.map.biomes.forest")
local Desert = require("engine.map.biomes.desert")
local Taiga = require("engine.map.biomes.taiga")

local BIOMES = {
    ["Forest"] = Forest:new(),
    ["Desert"] = Desert:new(),
    ["Taiga"] = Taiga:new()
}

local Map = {}

function Map.load(world)
    Map.BIOMES = BIOMES
    Map.world = world
    Map.MAP_WIDTH = 1000
    Map.MAP_HEIGHT = 1000
    Map.TILE_SIZE = 32
    Map.WORLD_WIDTH = Map.MAP_WIDTH * Map.TILE_SIZE
    Map.WORLD_HEIGHT = Map.MAP_HEIGHT * Map.TILE_SIZE
    Map.NOISE_SCALE = 5
    Map.tiles = {}
    Map.elements = {}
    Map.beacon = nil
    Map.generate()

    return Map
end

function Map.gridToWorld(xTile, yTile)
    return xTile * Map.TILE_SIZE, yTile * Map.TILE_SIZE
end

function Map.worldToGrid(x, y)
    return math.floor(x / Map.TILE_SIZE), math.floor(y / Map.TILE_SIZE)
end

function Map.convertPxToTile(px)
    return math.floor(px / Map.TILE_SIZE)
end

-- Génère la carte
function Map.generate()
    print("Generating map...")

    -- Générer les cartes de bruit
    Map.altitudeMap = NoiseUtils.generateNoiseMap(Map.MAP_WIDTH, Map.MAP_HEIGHT, Map.NOISE_SCALE)
    Map.humidityMap = NoiseUtils.generateNoiseMap(Map.MAP_WIDTH, Map.MAP_HEIGHT, Map.NOISE_SCALE)

    -- Assigner les biomes
    Map.biomes = Map.assignBiomes(Map.MAP_WIDTH, Map.MAP_HEIGHT, Map.altitudeMap, Map.humidityMap)

    -- Générer le terrain
    Map.generateTerrain()

    -- Générer le beacon
    Map.generateBeacon()

    -- Générer les éléments si nécessaire
    if not Config.NO_GENERATION_ELEMENTS then
        Map.generateElements()
    end
end

-- Assigner des biomes aux tuiles en fonction de l'altitude et de l'humidité
function Map.assignBiomes(width, height, altitudeMap, humidityMap)
    local biomes = {}

    for y = 1, height do
        biomes[y] = {}
        for x = 1, width do
            local altitude = altitudeMap[y][x]
            local humidity = humidityMap[y][x]
            local assignedBiome = nil

            -- Assigner un biome basé sur l'altitude et l'humidité
            for _, biomeModule in pairs(BIOMES) do
                if
                    (not biomeModule.minAltitude or altitude >= biomeModule.minAltitude) and
                        (not biomeModule.maxAltitude or altitude <= biomeModule.maxAltitude) and
                        (not biomeModule.minHumidity or humidity >= biomeModule.minHumidity) and
                        (not biomeModule.maxHumidity or humidity <= biomeModule.maxHumidity)
                 then
                    assignedBiome = biomeModule
                    break
                end
            end

            -- Si aucun biome n'est trouvé, assigner un biome par défaut
            if not assignedBiome then
                assignedBiome = BIOMES[""] -- Assurer un biome par défaut
            end

            biomes[y][x] = assignedBiome
        end
    end

    return biomes
end

-- Générer le terrain
function Map.generateTerrain()
    print("Generating terrain...")

    for y = 1, Map.MAP_HEIGHT do
        Map.tiles[y] = {}
        for x = 1, Map.MAP_WIDTH do
            local biomeModule = Map.biomes[y][x]
            if biomeModule then
                Map.tiles[y][x] = biomeModule:generateTerrain(x, y)
            end
        end
    end
end

-- Générer les éléments
function Map.generateElements()
    print("Generating elements...")

    for y = 1, Map.MAP_HEIGHT do
        for x = 1, Map.MAP_WIDTH do
            local biomeModule = Map.biomes[y][x]
            if biomeModule then
                -- Passer altitudeMap et humidityMap au biome pour générer les éléments
                local altitude = Map.altitudeMap[y][x]
                local humidity = Map.humidityMap[y][x]

                -- Générer l'élément en utilisant les informations de hauteur et humidité
                local element = biomeModule:generateElement(x, y, altitude, humidity)
                if element then
                    element.biomeName = biomeModule.name
                    table.insert(Map.elements, element)
                end
            end
        end
    end
end

-- Générer le beacon dans une zone centrale
function Map.generateBeacon(x, y)
    local pourcentage = 0.8
    local sx = Map.MAP_WIDTH * (1 - pourcentage) / 2
    local dx = Map.MAP_WIDTH * pourcentage
    local sy = Map.MAP_HEIGHT * (1 - pourcentage) / 2
    local dy = Map.MAP_HEIGHT * pourcentage

    local randomX = love.math.random(sx, sx + dx)
    local randomY = love.math.random(sy, sy + dy)
    local beaconX, beaconY = Map.gridToWorld(randomX, randomY)
    Map.beacon = Beacon:new({x = beaconX, y = beaconY})

    GlobalState:addEntity(Map.beacon)
end

-- Dessiner la carte
function Map.draw()
    local camX, camY, camWidth, camHeight = Camera.i:getVisibleArea()

    local startX = math.max(1, math.floor(camX / Map.TILE_SIZE)) - 10
    local endX = math.min(Map.MAP_WIDTH, math.ceil((camX + camWidth) / Map.TILE_SIZE)) + 10
    local startY = math.max(1, math.floor(camY / Map.TILE_SIZE)) - 10 or 0
    local endY = math.min(Map.MAP_HEIGHT, math.ceil((camY + camHeight) / Map.TILE_SIZE)) + 10

    if startX < 0 then
        startX = 0
    end

    if startY < 0 then
        startY = 0
    end

    if endX > Map.MAP_WIDTH then
        endX = Map.MAP_WIDTH
    end

    if endY > Map.MAP_HEIGHT then
        endY = Map.MAP_HEIGHT
    end

    Map.drawTiles(startX, endX, startY, endY)

    if not Config.NO_DRAW_ELEMENTS then
        Map.drawElements(startX, endX, startY, endY)
    end
end

-- Dessiner les tuiles
function Map.drawTiles(startX, endX, startY, endY)
    for y = startY, endY do
        for x = startX, endX do
            local biomeModule = Map.biomes[y][x]

            if biomeModule then
                local tile = Map.tiles[y][x]
                love.graphics.draw(biomeModule.terrain, tile.quad, Map.gridToWorld(x - 1, y - 1))
            end
        end
    end
end

-- Dessiner les éléments
function Map.drawElements(startX, endX, startY, endY)
    for _, element in ipairs(Map.elements) do
        local elementX, elementY = Map.worldToGrid(element.x, element.y)
        if elementX >= startX and elementX <= endX and elementY >= startY and elementY <= endY then
            local biomeModule = BIOMES[element.biomeName]
            if biomeModule and biomeModule.drawElement then
                biomeModule:drawElement(element)
            end
        end
    end
end

function Map.getBiomeAtPosition(x, y)
    -- check if the coord  is not out of the map
    if x < 0 or y < 0 or x > Map.MAP_WIDTH * Map.TILE_SIZE or y > Map.MAP_HEIGHT * Map.TILE_SIZE then
        return nil
    end
    local xTile, yTile = Map.worldToGrid(x, y)
    return Map.biomes[yTile][xTile]
end

return Map
