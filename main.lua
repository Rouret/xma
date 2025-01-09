local Player = require("player.init")
local StationaryEnemy = require("enemies.stationary_enemy")
local ChasingEnemy = require("enemies.chasing_enemy")
local enemies = {}

function love.conf(t)
    t.window.title = "Xma"
    t.version = "0.1"   
    t.window.fullscreen = true
end

function love.load()
    love.window.setMode(0, 0, {fullscreen=true})

    Player.load()
    table.insert(enemies, StationaryEnemy.new(400, 300))
end

function love.update(dt)
    Player.update(dt)

    -- Mettre à jour tous les ennemis
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy:update(dt, player)

        -- Supprimer les ennemis morts
        if not enemy:isAlive() then
            table.remove(enemies, i)
        end
    end

end

function love.draw()
    Player.draw()

    -- Dessiner tous les ennemis
    for _, enemy in ipairs(enemies) do
        enemy:draw()
    end
   
end
