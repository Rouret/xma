local State = require("player.state")
local Movement = {}


function Movement.update()
    if State.status == "immobilized" then
        State.body:setLinearVelocity(0, 0) -- Immobiliser le joueur
        return
    end

    local moveX, moveY = 0, 0

    -- Contrôles de déplacement
    if love.keyboard.isDown("q") then
        moveX = moveX - 1
    end
    if love.keyboard.isDown("d") then
        moveX = moveX + 1
    end
    if love.keyboard.isDown("z") then
        moveY = moveY - 1
    end
    if love.keyboard.isDown("s") then
        moveY = moveY + 1
    end

    -- Normaliser le vecteur pour éviter les mouvements diagonaux plus rapides
    local length = math.sqrt(moveX^2 + moveY^2)
    if length > 0 then
        moveX, moveY = moveX / length, moveY / length
    end

    -- Appliquer une vitesse constante au Body
    
    State.body:setLinearVelocity(moveX * State.speed, moveY * State.speed)
end

function Movement.move(dx, dy, dt)
    if State.status == "immobilized" then
        return
    end
    State.x = State.x + dx * State.speed * dt
    State.y = State.y + dy * State.speed * dt
end



return Movement
