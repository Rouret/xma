local NoiseUtils = require("engine.map.noiseUtils")
local BiomeGenerator = require("engine.map.biomeGenerator")
local Camera = require("engine.camera")
local BiomeRegistry = require("engine/map/BiomeRegistry")

local Beacon = require("items.beacon")
local Config = require("config")

-- Charger les biomes et leurs assets
local biomeFiles = {"Forest", "Desert", "Taiga"}
for _, biomeFile in ipairs(biomeFiles) do
    local biome = require("engine/map/biomes/" .. biomeFile)
    BiomeRegistry.register(biome.name, biome)
    biome.loadAssets()
end

local Map = {}
Map.__index = Map

function Map.new(world)
    local self = setmetatable({}, Map)

    self.world = world
    self.MAP_WIDTH = 1000
    self.MAP_HEIGHT = 1000
    self.TILE_SIZE = 32
    self.NOISE_SCALE = 2
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
    local altitudeMap = NoiseUtils.generateNoiseMap(self.MAP_WIDTH, self.MAP_HEIGHT, self.NOISE_SCALE)
    local humidityMap = NoiseUtils.generateNoiseMap(self.MAP_WIDTH, self.MAP_HEIGHT, self.NOISE_SCALE)

    -- Assigner les biomes
    self.biomes = BiomeGenerator.assignBiomes(self.MAP_WIDTH, self.MAP_HEIGHT, altitudeMap, humidityMap) or {}

    self:generateTerrain()
    self:generateBeacon()

    if not Config.NO_GENERATION_ELEMENTS then
        self:generateElements()
    end
end

function Map:generateTerrain()
    print("Generating terrain...")

    for y = 1, self.MAP_HEIGHT do
        self.tiles[y] = {}
        for x = 1, self.MAP_WIDTH do
            local biome = self.biomes[y][x]
            if biome then
                local biomeModule = BiomeRegistry.getBiome(biome.name)
                if biomeModule then
                    self.tiles[y][x] = biomeModule.generateTerrain(x, y)
                end
            end
        end
    end
end

function Map:generateElements()
    print("Generating elements...")

    for y = 1, self.MAP_HEIGHT do
        for x = 1, self.MAP_WIDTH do
            local biome = self.biomes[y][x]
            if biome then
                local biomeModule = BiomeRegistry.getBiome(biome.name)
                if biomeModule and love.math.random() < biomeModule.spawnProbability then
                    local element = biomeModule.generateElement(x, y)
                    if element then
                        element.biomeName = biome.name
                        table.insert(self.elements, element)
                    end
                end
            end
        end
    end
end

function Map:generateBeacon(x, y)
    --random x and Y but the beacon needs to be within 80% of the center, not on the border
    local pourcentage = 0.8
    local sx = self.MAP_WIDTH * (1 - pourcentage) / 2
    local dx = self.MAP_WIDTH * pourcentage
    local sy = self.MAP_HEIGHT * (1 - pourcentage) / 2
    local dy = self.MAP_HEIGHT * pourcentage

    local randomX = love.math.random(sx, sx + dx)
    local randomY = love.math.random(sy, sy + dy)
    local beaconX, beaconY = self:gridToWorld(randomX, randomY)
    local beacon = Beacon:new({x = beaconX, y = beaconY})
    self.beacon = beacon

    print("Beacon generated at " .. randomX .. ", " .. randomY)

    GlobalState:addEntity(beacon)
end

-- Draw
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

function Map:drawTiles(startX, endX, startY, endY)
    for y = startY, endY do
        for x = startX, endX do
            local biome = self.biomes[y][x]
            if biome then
                local biomeModule = BiomeRegistry.getBiome(biome.name)
                if biomeModule then
                    local tile = self.tiles[y][x]
                    love.graphics.draw(biomeModule.terrain, tile.quad, self:gridToWorld(x - 1, y - 1))
                end
            end
        end
    end
end

function Map:drawElements(startX, endX, startY, endY)
    for _, element in ipairs(self.elements) do
        -- Vérifiez si l'élément est visible dans la zone de la caméra
        local elementX, elementY = self:worldToGrid(element.x, element.y)
        if elementX >= startX and elementX <= endX and elementY >= startY and elementY <= endY then
            -- Récupérer le module de biome pour dessiner l'élément
            local biomeModule = BiomeRegistry.getBiome(element.biomeName)
            if biomeModule and biomeModule.drawElement then
                biomeModule.drawElement(element)
            end
        end
    end
end

return Map
