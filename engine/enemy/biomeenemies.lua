-- Chargement des classes ennemies
local TheRock = require("enemies.therock")
local IceSlime = require("enemies.iceSlime.iceslime")
local DesertSlime = require("enemies.sandSlime.sandSlime")

-- Définition des ennemis par biome
local BiomeEnemies = {
    Forest = {TheRock},
    Taiga = {IceSlime},
    Desert = {DesertSlime}
}

return BiomeEnemies
