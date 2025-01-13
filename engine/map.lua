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

-- Génère la carte procédurale avec clusters de buissons
function Map:generate()
    -- Initialisation des tiles avec des sols
    for y = 1, MAP_HEIGHT do
        self.tiles[y] = {}
        for x = 1, MAP_WIDTH do
            local randomGroundQuad = self.groundQuads[love.math.random(1, #self.groundQuads)]
            self.tiles[y][x] = {quad = randomGroundQuad, collision = false}
        end
    end

    -- Génération des buissons
    self:generateBushClusters(1000, 5, 10) -- 100 clusters, min 5 buissons, max 10 buissons par cluster
end

-- Génère des clusters de buissons
function Map:generateBushClusters(clusterCount, minSize, maxSize)
    for i = 1, clusterCount do
        -- Point de départ aléatoire
        local startX = love.math.random(1, MAP_WIDTH)
        local startY = love.math.random(1, MAP_HEIGHT)
        local clusterSize = love.math.random(minSize, maxSize)

        self:growBushCluster(startX, startY, clusterSize)
    end
end

-- Fait croître un cluster de buissons
function Map:growBushCluster(startX, startY, size)
    local directions = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}} -- Haut, droite, bas, gauche
    local bushCount = 0
    local queue = {{x = startX, y = startY}}

    while bushCount < size and #queue > 0 do
        local current = table.remove(queue, 1)
        local x, y = current.x, current.y

        -- Vérifie si la position est valide
        if self:isValidTile(x, y) and not self.tiles[y][x].collision then
            -- Place un buisson
            self.tiles[y][x] = {quad = self.bushQuad, collision = true}
            bushCount = bushCount + 1

            -- Ajoute un body pour la collision
            local body = love.physics.newBody(self.world, (x - 0.5) * TILE_SIZE, (y - 0.5) * TILE_SIZE, "static")
            local shape = love.physics.newRectangleShape(TILE_SIZE, TILE_SIZE)
            local fixture = love.physics.newFixture(body, shape)
            fixture:setUserData(
                {
                    name = "wall"
                }
            )

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

-- Vérifie si une position est valide pour un tile
function Map:isValidTile(x, y)
    return x >= 1 and x <= MAP_WIDTH and y >= 1 and y <= MAP_HEIGHT
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
