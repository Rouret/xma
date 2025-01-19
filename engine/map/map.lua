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

function Map.new(world)
    print("Creating map...")
    local self = setmetatable({}, Map)

    self.world = world
    self.MAP_WIDTH = 1000
    self.MAP_HEIGHT = 1000
    self.TILE_SIZE = 32
    self.NOISE_SCALE = 2

    self:generate()

    return self
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
    self.tiles = {}
    self.elements = {}

    -- Générer le terrain
    self:generateTerrain()
    -- Générer les éléments
    self:generateElements()
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

function Map:draw()
    local camX, camY, camWidth, camHeight = Camera.i:getVisibleArea()

    local startX = math.max(1, math.floor(camX / self.TILE_SIZE))
    local endX = math.min(self.MAP_WIDTH, math.ceil((camX + camWidth) / self.TILE_SIZE))
    local startY = math.max(1, math.floor(camY / self.TILE_SIZE))
    local endY = math.min(self.MAP_HEIGHT, math.ceil((camY + camHeight) / self.TILE_SIZE))

    for y = startY, endY do
        for x = startX, endX do
            local biome = self.biomes[y][x]
            if biome then
                local biomeModule = BiomeRegistry.getBiome(biome.name)
                if biomeModule then
                    local tile = self.tiles[y][x]
                    love.graphics.draw(
                        biomeModule.terrain,
                        tile.quad,
                        (x - 1) * self.TILE_SIZE,
                        (y - 1) * self.TILE_SIZE
                    )
                end
            end
        end
    end

    self:drawElements(startX, endX, startY, endY)
end

function Map:drawElements(startX, endX, startY, endY)
    for _, element in ipairs(self.elements) do
        -- Vérifiez si l'élément est visible dans la zone de la caméra
        if
            element.x >= startX * self.TILE_SIZE and element.x <= endX * self.TILE_SIZE and
                element.y >= startY * self.TILE_SIZE and
                element.y <= endY * self.TILE_SIZE
         then
            -- Récupérer le module de biome pour dessiner l'élément
            local biomeModule = BiomeRegistry.getBiome(element.biomeName)
            if biomeModule and biomeModule.drawElement then
                biomeModule.drawElement(element)
            end
        end
    end
end

return Map
