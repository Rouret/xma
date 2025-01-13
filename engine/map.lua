local Camera = require("engine.camera")

local Map = {}
Map.__index = Map

local TILE_SIZE = 32
local MAP_WIDTH = 1000
local MAP_HEIGHT = 1000
local BUSH_CLUSTER_SIZE_MIN = 3
local BUSH_CLUSTER_SIZE_MAX = 24
local BUSH_CLUSTER_COUNT = 3000

-- Crée une nouvelle instance de carte
function Map.new(world)
    local self = setmetatable({}, Map)

    self.layers = {} -- Stocke les layers (sol, obstacles, etc.)

    self.world = world

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

-- Génère le sol (layer 0)
function Map:generateGround()
    local tiles = {}
    for y = 1, MAP_HEIGHT do
        tiles[y] = {}
        for x = 1, MAP_WIDTH do
            local randomGroundQuad = self.groundQuads[love.math.random(1, #self.groundQuads)]
            tiles[y][x] = {quad = randomGroundQuad, collision = false}
        end
    end

    return tiles
end

-- Génère les buissons (layer 1) avec clusters
function Map:generateBushClusters(clusterCount, minSize, maxSize)
    local tiles = {}

    for y = 1, MAP_HEIGHT do
        tiles[y] = {}
        for x = 1, MAP_WIDTH do
            tiles[y][x] = nil -- Initialisation vide
        end
    end

    for i = 1, clusterCount do
        -- Point de départ aléatoire
        local startX = love.math.random(1, MAP_WIDTH)
        local startY = love.math.random(1, MAP_HEIGHT)
        local clusterSize = love.math.random(minSize, maxSize)

        self:growBushCluster(startX, startY, clusterSize, tiles)
    end

    return tiles
end

-- Fait croître un cluster de buissons
function Map:growBushCluster(startX, startY, size, tiles)
    local directions = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}} -- Haut, droite, bas, gauche
    local bushCount = 0
    local queue = {{x = startX, y = startY}}

    while bushCount < size and #queue > 0 do
        local current = table.remove(queue, 1)
        local x, y = current.x, current.y

        -- Vérifie si la position est valide
        if self:isValidTile(x, y) and not tiles[y][x] then
            -- Place un buisson
            tiles[y][x] = {quad = self.bushQuad, collision = true}
            bushCount = bushCount + 1

            -- Ajoute un body pour la collision
            local body = love.physics.newBody(self.world, (x - 0.5) * TILE_SIZE, (y - 0.5) * TILE_SIZE, "static")
            local shape = love.physics.newRectangleShape(TILE_SIZE, TILE_SIZE)
            local fixture = love.physics.newFixture(body, shape)
            fixture:setUserData({name = "wall"})

            -- Ajoute les voisins à la queue (croissance)
            for _, dir in ipairs(directions) do
                local nx, ny = x + dir[1], y + dir[2]
                if love.math.random() > 0.3 then -- 70% de chance de continuer dans cette direction
                    table.insert(queue, {x = nx, y = ny})
                end
            end
        end
    end
end

-- Génère la carte
function Map:generate()
    -- Layer 0 : Sol
    self.layers[0] = self:generateGround()

    -- Layer 1 : Buissons
    self.layers[1] = self:generateBushClusters(BUSH_CLUSTER_COUNT, BUSH_CLUSTER_SIZE_MIN, BUSH_CLUSTER_SIZE_MAX)
end

-- Vérifie si une position est valide pour un tile
function Map:isValidTile(x, y)
    return x >= 1 and x <= MAP_WIDTH and y >= 1 and y <= MAP_HEIGHT
end

-- Dessine un layer
function Map:drawLayer(layer)
    local tiles = self.layers[layer]
    if not tiles then
        return
    end -- Vérifie que le layer existe

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
            if tiles[y] and tiles[y][x] then
                local tile = tiles[y][x]
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

-- Dessine la carte entière
function Map:draw()
    for layer = 0, #self.layers do
        self:drawLayer(layer)
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
