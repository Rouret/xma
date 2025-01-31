local Camera = require("engine.camera")
local Config = require("config")
local ProFi = require("engine.profiler")
local State = require("player.state")
local UI = require("game.ui")
local Debug = {}

local Map

local showBiome = false
function Debug.load(map)
    -- Initialisation de la caméra en mode libre si nécessaire
    if Config.MODE_FREE_CAMERA then
        Camera.i:setPosition(0, 0) -- Position initiale de la caméra
    end

    Map = map

    return Debug
end

function Debug.update(dt)
    if Config.MODE_FREE_CAMERA then
        -- Déplacements de la caméra avec les touches ZQSD (WASD en QWERTY)
        if love.keyboard.isDown("z") then
            Camera.i.y = Camera.i.y - Config.CAMERA_SPEED * dt
        end
        if love.keyboard.isDown("s") then
            Camera.i.y = Camera.i.y + Config.CAMERA_SPEED * dt
        end
        if love.keyboard.isDown("q") then
            Camera.i.x = Camera.i.x - Config.CAMERA_SPEED * dt
        end
        if love.keyboard.isDown("d") then
            Camera.i.x = Camera.i.x + Config.CAMERA_SPEED * dt
        end
    end
end

function Debug.keypressed(key)
    if key == "f1" then
        print("Start profiling")
        ProFi:start()
    end
    if key == "f2" then
        print("Stop profiling")
        ProFi:stop()
        ProFi:writeReport("profiler.txt")
        love.event.quit()
    end
    if key == "f8" then
        -- Redémarrer le jeu
        love.event.quit("restart")
    end
    if key == "f3" then
        -- Changer le mode de la caméra
        Config.MODE_FREE_CAMERA = not Config.MODE_FREE_CAMERA
        print("Free Camera Mode: " .. tostring(Config.MODE_FREE_CAMERA))
    end
    if key == "f4" then
        print("Teleporting to beacon")
        local beacon = Map.beacon
        if beacon then
            local x = (beacon.x + 200)
            local y = (beacon.y + 200)
            State.body:setPosition(x, y)
            State.x = x
            State.y = y
        end
    end
    if key == "f5" then
        showBiome = true
    end
end

function Debug.keyreleased(key)
    if key == "f5" then
        showBiome = false
    end
end

function Debug.draw()
    love.graphics.setFont(UI.font.small)
    local width, height = love.graphics.getDimensions()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 5, height - 150, 250, 140)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("F1: Start profiling", 10, height - 140)
    love.graphics.print("F2: Stop profiling", 10, height - 120)
    love.graphics.print("F3: Toggle free camera mode", 10, height - 100)
    love.graphics.print("F4: TP close to beacon", 10, height - 80)
    love.graphics.print("F5: Toggle biome graph", 10, height - 60)
    love.graphics.print("F8: Restart", 10, height - 40)

    if Config.DEBUG_AIM then
        -- DRAW LINE FROM PLAYER TO MOUSE
        local mouseX, mouseY = love.mouse.getPosition()
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local playerScreenX = screenWidth / 2
        local playerScreenY = screenHeight / 2

        love.graphics.setColor(1, 0, 0)
        love.graphics.line(playerScreenX, playerScreenY, mouseX, mouseY)
        love.graphics.setColor(1, 1, 1)

        -- PRINT ANGLE TO MOUSE
        local angle = string.format("%.2f", State.getAngleToMouse())
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(angle, playerScreenX, playerScreenY + 20)
        love.graphics.setColor(1, 1, 1)
    end

    if Config.DRAW_COORDS then
        -- draw coord beyond center of screen
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local centerX = screenWidth / 2
        local centerY = screenHeight / 2

        local x = centerX
        local y = centerY + 30
        local playerX = string.format("%.2f", State.x) / 32
        local playerY = string.format("%.2f", State.y) / 32

        love.graphics.setColor(0, 0, 0)
        love.graphics.print("X: " .. playerX .. " Y: " .. playerY, x, y)
        love.graphics.setColor(1, 1, 1)
    end
    if Config.DRAW_BIOME_GRAPH and showBiome then
        local width, height = love.graphics.getDimensions()

        local scaleX = width - 50
        local scaleY = height - 50

        love.graphics.setColor(0, 0, 0)
        love.graphics.line(50, height - 50, scaleX, height - 50)
        love.graphics.line(50, height - 50, 50, 50)

        love.graphics.print("Altitude", scaleX - 40, height - 40)
        love.graphics.print("Humidity", 10, 10)

        love.graphics.setColor(0, 0, 0)
        for i = 0, 10 do
            local xTick = 50 + scaleX * (i * 0.1)
            love.graphics.line(xTick, height - 50, xTick, height - 40)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(string.format("%.1f", i * 0.1), xTick - 10, height - 40)
        end

        for i = 0, 10 do
            local yTick = height - 50 - scaleY * (i * 0.1)
            love.graphics.line(50, yTick, 60, yTick)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(string.format("%.1f", i * 0.1), 10, yTick - 10)
        end
        love.graphics.setColor(1, 1, 1)

        for biomeName, biomeData in pairs(Map.BIOMES) do
            local x1 = 50 + scaleX * biomeData.minAltitude
            local y1 = height - 50 - scaleY * biomeData.maxHumidity
            local x2 = 50 + scaleX * biomeData.maxAltitude
            local y2 = height - 50 - scaleY * biomeData.minHumidity

            love.graphics.setColor(biomeData.color)

            love.graphics.rectangle("fill", x1, y1, x2 - x1, y2 - y1)

            -- Draw grey border for each biome
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.rectangle("line", x1, y1, x2 - x1, y2 - y1)

            love.graphics.setColor(0, 0, 0)
            love.graphics.print(biomeName, (x1 + x2) / 2 - 10, (y1 + y2) / 2)

            if biomeData.sub then
                for _, subBiomeData in pairs(biomeData.sub) do
                    local subX1 = 50 + scaleX * subBiomeData.minAltitude
                    local subY1 = height - 50 - scaleY * subBiomeData.maxHumidity
                    local subX2 = 50 + scaleX * subBiomeData.maxAltitude
                    local subY2 = height - 50 - scaleY * subBiomeData.minHumidity

                    love.graphics.setColor(subBiomeData.color)

                    love.graphics.rectangle("fill", subX1, subY1, subX2 - subX1, subY2 - subY1)

                    love.graphics.setColor(0, 0, 0)
                    love.graphics.print(subBiomeData.name, (subX1 + subX2) / 2 - 10, (subY1 + subY2) / 2)
                end
            end
        end
    end
end
return Debug
