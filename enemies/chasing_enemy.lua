local ChasingEnemy = {}
ChasingEnemy.__index = ChasingEnemy

function ChasingEnemy.new(x, y, speed)
    local self = setmetatable({}, ChasingEnemy)
    self.x = x
    self.y = y
    self.speed = speed or 100 -- Vitesse de déplacement par défaut
    self.image = love.graphics.newImage("sprites/stationary_enemy.png") -- Ajoutez une image pour l'ennemi
    self.health = 100
    return self
end

function ChasingEnemy:update(dt, player)
    -- Calculer la direction vers le joueur
    local dx = player.x - self.x
    local dy = player.y - self.y
    local distance = math.sqrt(dx^2 + dy^2)

    if distance > 0 then
        self.x = self.x + (dx / distance) * self.speed * dt
        self.y = self.y + (dy / distance) * self.speed * dt
    end
end

function ChasingEnemy:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, 1, 1, self.image:getWidth() / 2, self.image:getHeight() / 2)
end

function ChasingEnemy:isAlive()
    return self.health > 0
end

function ChasingEnemy:takeDamage(damage)
    self.health = self.health - damage
end

return ChasingEnemy
