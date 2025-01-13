local NoiseUtils = require("engine.map.noiseUtils")
local BiomeGenerator = require("engine.map.biomeGenerator")
local Camera = require("engine.camera")
local BiomeRegistry = require("engine/map/BiomeRegistry")

local biomeFiles = {"Forest", "Desert"}
for _, biomeFile in ipairs(biomeFiles) do
    local biome = require("engine/map/biomes/" .. biomeFile)
    BiomeRegistry.register(biome.name, biome)
end

local Map = {}
Map.__index = Map

local TILE_SIZE = 32
local MAP_WIDTH = 1000
local MAP_HEIGHT = 1000
local NOISE_SCALE = 2

function Map.new(world)
    local self = setmetatable({}, Map)

    self.world = world
    self.tileset = love.graphics.newImage("sprites/tilesets/v0.png")
    self.tileset:setFilter("nearest", "nearest")
    self.tilesetQuads = self:createTileQuads()
    self.layers = {}

    self:generate()
    self:generateElements()

    return self
end

-- Découpe le tileset en quads
function Map:createTileQuads()
    local quads = {}
    local tilesetWidth = self.tileset:getWidth()
    local tilesetHeight = self.tileset:getHeight()

    for y = 0, tilesetHeight / TILE_SIZE - 1 do
        for x = 0, tilesetWidth / TILE_SIZE - 1 do
            table.insert(
                quads,
                love.graphics.newQuad(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE, self.tileset:getDimensions())
            )
        end
    end

    return quads
end

-- Génère la carte
function Map:generate()
    -- Générer les cartes de bruit
    local altitudeMap = NoiseUtils.generateNoiseMap(MAP_WIDTH, MAP_HEIGHT, NOISE_SCALE)
    local humidityMap = NoiseUtils.generateNoiseMap(MAP_WIDTH, MAP_HEIGHT, NOISE_SCALE)

    -- Assigner les biomes
    self.biomes = BiomeGenerator.assignBiomes(MAP_WIDTH, MAP_HEIGHT, altitudeMap, humidityMap) or {}

    -- Générer le layer principal
    self.layers[0] = self:generateTerrain()
end

-- Génère le terrain à partir des biomes
function Map:generateTerrain()
    local tiles = {}

    for y = 1, MAP_HEIGHT do
        tiles[y] = {}
        for x = 1, MAP_WIDTH do
            local biome = self.biomes[y][x]
            local groundQuad = self.tilesetQuads[biome.groundQuad]

            tiles[y][x] = {quad = groundQuad, collision = biome.name == "Mountain"}
        end
    end

    return tiles
end

-- Dessine la carte
function Map:draw()
    local camX, camY, camWidth, camHeight = Camera.i:getVisibleArea()

    local startX = math.max(1, math.floor(camX / TILE_SIZE))
    local endX = math.min(MAP_WIDTH, math.ceil((camX + camWidth) / TILE_SIZE))
    local startY = math.max(1, math.floor(camY / TILE_SIZE))
    local endY = math.min(MAP_HEIGHT, math.ceil((camY + camHeight) / TILE_SIZE))

    for layer = 0, #self.layers do
        local tiles = self.layers[layer]
        if not tiles then
            return
        end

        for y = startY, endY do
            for x = startX, endX do
                local tile = tiles[y][x]
                love.graphics.draw(self.tileset, tile.quad, (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE)
            end
        end
    end
    self:drawElements(startX, endX, startY, endY)
end

function Map:generateElements()
    self.elements = {}

    for y = 1, MAP_HEIGHT do
        for x = 1, MAP_WIDTH do
            local biome = self.biomes[y][x]
            if biome then
                local biomeModule = BiomeRegistry.getBiome(biome.name)
                if biomeModule and love.math.random() < biomeModule.spawnProbability then
                    local element = biomeModule.generateElement(x, y)
                    table.insert(self.elements, element)
                end
            end
        end
    end
end

function Map:drawElements(startX, endX, startY, endY)
    for _, element in ipairs(self.elements) do
        if
            element.x >= startX * TILE_SIZE and element.x <= endX * TILE_SIZE and element.y >= startY * TILE_SIZE and
                element.y <= endY * TILE_SIZE
         then
            if element.type == "Tree" then
                love.graphics.setColor(0, 1, 0) -- Vert
                love.graphics.rectangle("fill", element.x, element.y, TILE_SIZE / 2, TILE_SIZE / 2)
            elseif element.type == "Cactus" then
                love.graphics.setColor(0, 1, 0.5) -- Vert clair
                love.graphics.rectangle("fill", element.x, element.y, TILE_SIZE / 3, TILE_SIZE)
            elseif element.type == "Rock" then
                love.graphics.setColor(0.5, 0.5, 0.5) -- Gris
                love.graphics.rectangle("fill", element.x, element.y, TILE_SIZE / 2, TILE_SIZE / 2)
            elseif element.type == "Bush" then
                love.graphics.setColor(0.1, 0.8, 0.1) -- Vert foncé
                love.graphics.circle("fill", element.x, element.y, TILE_SIZE / 3)
            end
        end
    end
    love.graphics.setColor(1, 1, 1) -- Réinitialisation
end

return Map
