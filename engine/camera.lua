local camera = {}
camera.__index = camera

-- Instance unique pour la caméra globale
camera.i = nil

-- Initialise la caméra globale (singleton)
function camera.init(x, y, scale)
    if not camera.i then
        camera.i =
            setmetatable(
            {
                x = x or 0,
                y = y or 0,
                scale = scale or 1
            },
            camera
        )
    end
    return camera.i
end

-- Crée une nouvelle i de caméra (non liée à l'i globale)
function camera.new(x, y, scale)
    return setmetatable(
        {
            x = x or 0,
            y = y or 0,
            scale = scale or 1
        },
        camera
    )
end

-- Définit la position de la caméra
function camera:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Définit le zoom de la caméra
function camera:setScale(scale)
    self.scale = scale
end

-- Applique la transformation de la caméra
function camera:apply()
    love.graphics.push()
    love.graphics.scale(self.scale)
    love.graphics.translate(
        -self.x + love.graphics.getWidth() / (2 * self.scale),
        -self.y + love.graphics.getHeight() / (2 * self.scale)
    )
end

-- Réinitialise la transformation de la caméra
function camera:reset()
    love.graphics.pop()
end

return camera
