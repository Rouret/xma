local Camera = require("engine.camera")
local Config = require("config")
local ProFi = require("engine.profiler")
local State = require("player.state")
local Debug = {}

function Debug.load()
    print("F1: Start profiling")
    print("F2: Stop profiling")
    print("F3: Toggle free camera mode")
    print("F8: Restart")

    -- Initialisation de la caméra en mode libre si nécessaire
    if Config.MODE_FREE_CAMERA then
        Camera.i:setPosition(0, 0) -- Position initiale de la caméra
    end

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
end

function Debug.draw()
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
end
return Debug
