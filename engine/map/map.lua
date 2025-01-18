local NoiseUtils = require("engine.map.noiseUtils")
local BiomeGenerator = require("engine.map.biomeGenerator")
local Camera = require("engine.camera")
local BiomeRegistry = require("engine/map/BiomeRegistry")

-- Charger les biomes et leurs assets
local biomeFiles = {"Forest", "Desert", "Taiga"}
for _, biomeFile in ipairs(biomeFiles) do
    local biome = require("engine/map/biomes/" .. biomeFile)
    BiomeRegistry.register(biome.name, biome)
    biome.loadAssets()
end

local Map = {}
Map.__index = Map

local TILE_SIZE = 32
local MAP_WIDTH = 1000
local MAP_HEIGHT = 1000
local NOISE_SCALE = 2

function Map.new(world)
    print("Creating map...")
    local self = setmetatable({}, Map)

    self.world = world
    self.layers = {}
    self.MAP_WIDTH = MAP_WIDTH
    self.MAP_HEIGHT = MAP_HEIGHT

    self:generate()
    self:generateElements()

    return self
end

function Map:convertPxToTile(px)
    return math.floor(px / TILE_SIZE)
end
-- Génère la carte
function Map:generate()
    print("Generating map...")
    -- Générer les cartes de bruit
    local altitudeMap = NoiseUtils.generateNoiseMap(MAP_WIDTH, MAP_HEIGHT, NOISE_SCALE)
    local humidityMap = NoiseUtils.generateNoiseMap(MAP_WIDTH, MAP_HEIGHT, NOISE_SCALE)

    -- Assigner les biomes
    self.biomes = BiomeGenerator.assignBiomes(MAP_WIDTH, MAP_HEIGHT, altitudeMap, humidityMap) or {}

    -- Générer le terrain
    self.layers[0] = self:generateTerrain()
end

function Map:generateTerrain()
    print("Generating terrain...")
    local tiles = {}

    for y = 1, MAP_HEIGHT do
        tiles[y] = {}
        for x = 1, MAP_WIDTH do
            local biome = self.biomes[y][x]
            if biome then
                local biomeModule = BiomeRegistry.getBiome(biome.name)
                if biomeModule then
                    tiles[y][x] = biomeModule.generateTerrain(x, y)
                end
            end
        end
    end

    return tiles
end

function Map:generateElements()
    print("Generating elements...")
    self.elements = {}

    for y = 1, MAP_HEIGHT do
        for x = 1, MAP_WIDTH do
            local biome = self.biomes[y][x]
            if biome then
                local biomeModule = BiomeRegistry.getBiome(biome.name)
                if biomeModule and love.math.random() < biomeModule.spawnProbability then
                    local element = biomeModule.generateElement(x, y)
                    if element then
                        element.biomeName = biome.name -- Associer l'élément à son biome
                        table.insert(self.elements, element)
                    end
                end
            end
        end
    end
end

function Map:draw()
    local camX, camY, camWidth, camHeight = Camera.i:getVisibleArea()

    local startX = math.max(1, math.floor(camX / TILE_SIZE))
    local endX = math.min(MAP_WIDTH, math.ceil((camX + camWidth) / TILE_SIZE))
    local startY = math.max(1, math.floor(camY / TILE_SIZE))
    local endY = math.min(MAP_HEIGHT, math.ceil((camY + camHeight) / TILE_SIZE))

    -- Dessiner les terrains
    for y = startY, endY do
        for x = startX, endX do
            local biome = self.biomes[y][x]
            if biome then
                local biomeModule = BiomeRegistry.getBiome(biome.name)
                if biomeModule then
                    local tile = self.layers[0][y][x]
                    love.graphics.draw(biomeModule.terrain, tile.quad, (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE)
                end
            end
        end
    end

    -- Dessiner les éléments
    self:drawElements(startX, endX, startY, endY)
end

function Map:drawElements(startX, endX, startY, endY)
    local total = 0
    for _, element in ipairs(self.elements) do
        -- Vérifiez si l'élément est visible dans la zone de la caméra
        if
            element.x >= startX * TILE_SIZE and element.x <= endX * TILE_SIZE and element.y >= startY * TILE_SIZE and
                element.y <= endY * TILE_SIZE
         then
            total = total + 1

            -- Récupérer le module de biome pour dessiner l'élément
            local biomeModule = BiomeRegistry.getBiome(element.biomeName)
            if biomeModule and biomeModule.drawElement then
                biomeModule.drawElement(element)
            end
        end
    end
end

return Map
