local Camera = require("engine.camera")

local Map = {}
Map.__index = Map

local TILE_SIZE = 32
local MAP_WIDTH = 1000
local MAP_HEIGHT = 1000

-- Crée une nouvelle instance de carte
function Map.new(world)
    local self = setmetatable({}, Map)
    self.tiles = {} -- Stocke les tiles de la carte
    self.world = world -- Référence au monde physique

    -- Chargement du tileset
    self.tileset = love.graphics.newImage("sprites/tilesets/v0.png")
    self.tileset:setFilter("nearest", "nearest") -- Désactiver le filtrage bilinéaire

    -- Découpe du tileset en quads
    self.tileQuads = createTileQuads(self.tileset, TILE_SIZE)

    -- Définition des types de tiles
    self.groundQuads = {self.tileQuads[1], self.tileQuads[2], self.tileQuads[3], self.tileQuads[4]} -- Sols
    self.bushQuad = self.tileQuads[5] -- Buissons

    -- Génération de la carte
    self:generate()
    return self
end

-- Génère la carte procédurale avec collisions
function Map:generate()
    for y = 1, MAP_HEIGHT do
        self.tiles[y] = {}
        for x = 1, MAP_WIDTH do
            local isBush = love.math.random(1, 10) == 1 -- 10% de chance d'être un buisson
            if isBush then
                -- Tile avec obstacle (buisson)
                self.tiles[y][x] = {quad = self.bushQuad, collision = true}

                -- Ajout au moteur physique
                local body = love.physics.newBody(self.world, (x - 0.5) * TILE_SIZE, (y - 0.5) * TILE_SIZE, "static")
                local shape = love.physics.newRectangleShape(TILE_SIZE, TILE_SIZE)
                local fixture = love.physics.newFixture(body, shape)
                fixture:setUserData(
                    {
                        name = "wall"
                    }
                )
            else
                -- Tile de sol aléatoire
                local randomGroundQuad = self.groundQuads[love.math.random(1, #self.groundQuads)]
                self.tiles[y][x] = {quad = randomGroundQuad, collision = false}
            end
        end
    end
end

-- Dessine la carte (vue basée sur une caméra)
function Map:draw()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local scale = Camera.i.scale

    -- Calcul des coordonnées de début et de fin en fonction de la caméra
    local startX = math.max(1, math.floor((Camera.i.x - screenWidth / (2 * scale)) / TILE_SIZE))
    local startY = math.max(1, math.floor((Camera.i.y - screenHeight / (2 * scale)) / TILE_SIZE))
    local endX = math.min(MAP_WIDTH, math.ceil((Camera.i.x + screenWidth / (2 * scale)) / TILE_SIZE))
    local endY = math.min(MAP_HEIGHT, math.ceil((Camera.i.y + screenHeight / (2 * scale)) / TILE_SIZE))

    -- Dessin des tiles visibles
    for y = startY, endY do
        for x = startX, endX do
            if self.tiles[y] and self.tiles[y][x] then
                local tile = self.tiles[y][x]
                love.graphics.draw(
                    self.tileset,
                    tile.quad,
                    math.floor((x - 1) * TILE_SIZE),
                    math.floor((y - 1) * TILE_SIZE)
                )
            end
        end
    end
end

-- Fonction utilitaire pour découper un tileset en quads
function createTileQuads(tileset, tileSize)
    local quads = {}
    local tilesetWidth = tileset:getWidth()
    local tilesetHeight = tileset:getHeight()
    for y = 0, tilesetHeight / tileSize - 1 do
        for x = 0, tilesetWidth / tileSize - 1 do
            table.insert(
                quads,
                love.graphics.newQuad(x * tileSize, y * tileSize, tileSize, tileSize, tileset:getDimensions())
            )
        end
    end
    return quads
end

return Map
