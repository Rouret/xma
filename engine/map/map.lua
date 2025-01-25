local NoiseUtils = require("engine.map.noiseUtils")
local Camera = require("engine.camera")
local Beacon = require("items.beacon")
local Config = require("config")

local biomeFiles = {"Forest", "Desert", "Taiga"}
local BIOMES = {}

for _, biomeFile in ipairs(biomeFiles) do
    local biomeModule = require("engine/map/biomes/" .. biomeFile)
    BIOMES[biomeModule.name] = biomeModule
    biomeModule.loadAssets()
end

local Map = {}
Map.__index = Map

function Map.new(world)
    local self = setmetatable({}, Map)
    self.BIOMES = BIOMES
    self.world = world
    self.MAP_WIDTH = 1000
    self.MAP_HEIGHT = 1000
    self.TILE_SIZE = 32
    self.NOISE_SCALE = 10
    self.tiles = {}
    self.elements = {}
    self.beacon = nil
    self:generate()

    return self
end

function Map:gridToWorld(xTile, yTile)
    return xTile * self.TILE_SIZE, yTile * self.TILE_SIZE
end

function Map:worldToGrid(x, y)
    return math.floor(x / self.TILE_SIZE), math.floor(y / self.TILE_SIZE)
end

function Map:convertPxToTile(px)
    return math.floor(px / self.TILE_SIZE)
end

-- Génère la carte
function Map:generate()
    print("Generating map...")

    -- Générer les cartes de bruit
    self.altitudeMap = NoiseUtils.generateNoiseMap(self.MAP_WIDTH, self.MAP_HEIGHT, self.NOISE_SCALE)
    self.humidityMap = NoiseUtils.generateNoiseMap(self.MAP_WIDTH, self.MAP_HEIGHT, self.NOISE_SCALE)

    -- Assigner les biomes
    self.biomes = self:assignBiomes(self.MAP_WIDTH, self.MAP_HEIGHT, self.altitudeMap, self.humidityMap)

    -- Générer le terrain
    self:generateTerrain()

    -- Générer le beacon
    self:generateBeacon()

    -- Générer les éléments si nécessaire
    if not Config.NO_GENERATION_ELEMENTS then
        self:generateElements()
    end
end

-- Assigner des biomes aux tuiles en fonction de l'altitude et de l'humidité
function Map:assignBiomes(width, height, altitudeMap, humidityMap)
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
                assignedBiome = BIOMES["Default"] -- Assurer un biome par défaut
            end

            biomes[y][x] = assignedBiome
        end
    end

    return biomes
end

-- Générer le terrain
function Map:generateTerrain()
    print("Generating terrain...")

    for y = 1, self.MAP_HEIGHT do
        self.tiles[y] = {}
        for x = 1, self.MAP_WIDTH do
            local biomeModule = self.biomes[y][x]
            if biomeModule then
                self.tiles[y][x] = biomeModule.generateTerrain(x, y)
            end
        end
    end
end

-- Générer les éléments
function Map:generateElements()
    print("Generating elements...")

    for y = 1, self.MAP_HEIGHT do
        for x = 1, self.MAP_WIDTH do
            local biomeModule = self.biomes[y][x]
            if biomeModule then
                -- Passer altitudeMap et humidityMap au biome pour générer les éléments
                local altitude = self.altitudeMap[y][x]
                local humidity = self.humidityMap[y][x]

                -- Générer l'élément en utilisant les informations de hauteur et humidité
                local element = biomeModule.generateElement(x, y, altitude, humidity)
                if element then
                    element.biomeName = biomeModule.name
                    table.insert(self.elements, element)
                end
            end
        end
    end
end

-- Générer le beacon dans une zone centrale
function Map:generateBeacon(x, y)
    local pourcentage = 0.8
    local sx = self.MAP_WIDTH * (1 - pourcentage) / 2
    local dx = self.MAP_WIDTH * pourcentage
    local sy = self.MAP_HEIGHT * (1 - pourcentage) / 2
    local dy = self.MAP_HEIGHT * pourcentage

    local randomX = love.math.random(sx, sx + dx)
    local randomY = love.math.random(sy, sy + dy)
    local beaconX, beaconY = self:gridToWorld(randomX, randomY)
    self.beacon = Beacon:new({x = beaconX, y = beaconY})

    print("Beacon generated at " .. randomX .. ", " .. randomY)

    GlobalState:addEntity(self.beacon)
end

-- Dessiner la carte
function Map:draw()
    local camX, camY, camWidth, camHeight = Camera.i:getVisibleArea()

    local startX = math.max(1, math.floor(camX / self.TILE_SIZE))
    local endX = math.min(self.MAP_WIDTH, math.ceil((camX + camWidth) / self.TILE_SIZE))
    local startY = math.max(1, math.floor(camY / self.TILE_SIZE))
    local endY = math.min(self.MAP_HEIGHT, math.ceil((camY + camHeight) / self.TILE_SIZE))

    self:drawTiles(startX, endX, startY, endY)

    if not Config.NO_DRAW_ELEMENTS then
        self:drawElements(startX, endX, startY, endY)
    end
end

-- Dessiner les tuiles
function Map:drawTiles(startX, endX, startY, endY)
    for y = startY, endY do
        for x = startX, endX do
            local biomeModule = self.biomes[y][x]
            if biomeModule then
                local tile = self.tiles[y][x]
                love.graphics.draw(biomeModule.terrain, tile.quad, self:gridToWorld(x - 1, y - 1))
            end
        end
    end
end

-- Dessiner les éléments
function Map:drawElements(startX, endX, startY, endY)
    for _, element in ipairs(self.elements) do
        local elementX, elementY = self:worldToGrid(element.x, element.y)
        if elementX >= startX and elementX <= endX and elementY >= startY and elementY <= endY then
            local biomeModule = BIOMES[element.biomeName]
            if biomeModule and biomeModule.drawElement then
                biomeModule.drawElement(element)
            end
        end
    end
end

return Map
