local Choice = {}

-- Définir les types de choix avec des chaînes lisibles
Choice.Type = {
    SPEED = "speed",
    DAMAGE = "damage",
    HEALTH = "health",
    MAX_HEALTH = "max_health"
}

-- Charger les ressources et configurer les types
function Choice.load()
    local iconsPath = "sprites/icon/"
    local image = love.graphics.newImage

    -- Configuration pour chaque type de choix
    Choice.config = {
        [Choice.Type.SPEED] = {
            image = image(iconsPath .. "speed.png"),
            min = 1,
            max = 2
        },
        [Choice.Type.DAMAGE] = {
            image = image(iconsPath .. "damage.png"),
            min = 1,
            max = 2
        },
        [Choice.Type.HEALTH] = {
            image = image(iconsPath .. "health.png"),
            min = 1,
            max = 2
        },
        [Choice.Type.MAX_HEALTH] = {
            image = image(iconsPath .. "max_health.png"),
            min = 1,
            max = 2
        }
    }

    -- Stockage des choix générés
    Choice.choices = {}

    Choice.hasGeneratedChoices = false
end

-- Générer des choix uniques
function Choice.generateChoice()
    local availableTypes = {Choice.Type.SPEED, Choice.Type.DAMAGE, Choice.Type.HEALTH, Choice.Type.MAX_HEALTH}
    local selectedTypes = {}

    -- Générer 3 choix uniques
    for i = 1, 3 do
        -- Sélectionner un type non encore choisi
        local choiceType
        repeat
            choiceType = availableTypes[love.math.random(#availableTypes)]
        until not selectedTypes[choiceType]

        -- Marquer le type comme choisi
        selectedTypes[choiceType] = true

        -- Générer la valeur aléatoire pour ce type
        local config = Choice.config[choiceType]
        local value = love.math.random(config.min, config.max)

        -- Ajouter le choix généré
        table.insert(Choice.choices, {
            type = choiceType,
            value = value,
            image = config.image,
            isHovered = false -- Initialiser l'état de hover
        })
    end

    Choice.hasGeneratedChoices = true

    -- Débogage : Afficher les choix
    for i, choice in ipairs(Choice.choices) do
        print(string.format("Choice %d: Type=%s, Value=%d", i, choice.type, choice.value))
    end
end

-- Détecter le hover
function Choice.update(dt)
    local mouseX, mouseY = love.mouse.getPosition()

    -- Dimensions des cartes
    local cardWidth = 100
    local cardHeight = 150
    local spacing = 20
    local startX = (love.graphics.getWidth() - (3 * cardWidth + 2 * spacing)) / 2
    local y = (love.graphics.getHeight() - cardHeight) / 2

    for i, choice in ipairs(Choice.choices) do
        local x = startX + (i - 1) * (cardWidth + spacing)

        -- Vérifier si la souris est au-dessus de la carte
        if mouseX >= x and mouseX <= x + cardWidth and mouseY >= y and mouseY <= y + cardHeight then
            choice.isHovered = true
        else
            choice.isHovered = false
        end
    end
end

-- Dessiner les choix à l'écran sous forme de cartes
function Choice.draw()
    local cardWidth = 100
    local cardHeight = 150
    local spacing = 20
    local startX = (love.graphics.getWidth() - (3 * cardWidth + 2 * spacing)) / 2
    local y = (love.graphics.getHeight() - cardHeight) / 2

    for i, choice in ipairs(Choice.choices) do
        local x = startX + (i - 1) * (cardWidth + spacing)

        -- Dessiner la carte
        if choice.isHovered then
            love.graphics.setColor(0.8, 0.8, 0.8) -- Couleur plus claire pour le hover
        else
            love.graphics.setColor(1, 1, 1) -- Couleur normale
        end
        love.graphics.rectangle("fill", x, y, cardWidth, cardHeight)

        -- Dessiner l'image du choix
        love.graphics.draw(choice.image, x + (cardWidth - choice.image:getWidth()) / 2, y + 20)

        -- Dessiner le texte du type et de la valeur
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(choice.type, x, y + cardHeight - 40, cardWidth, "center")
        love.graphics.printf("Value: " .. choice.value, x, y + cardHeight - 20, cardWidth, "center")
    end
end

-- Détecter les clics
function Choice.mousepressed(x, y, button)
    if button == 1 then -- Clic gauche
        local cardWidth = 100
        local cardHeight = 150
        local spacing = 20
        local startX = (love.graphics.getWidth() - (3 * cardWidth + 2 * spacing)) / 2
        local cardY = (love.graphics.getHeight() - cardHeight) / 2

        for i, choice in ipairs(Choice.choices) do
            local cardX = startX + (i - 1) * (cardWidth + spacing)

            if x >= cardX and x <= cardX + cardWidth and y >= cardY and y <= cardY + cardHeight then
                print("Clicked on choice:", choice.type, "with value:", choice.value)
                -- Ajouter ici l'effet du choix sélectionné
            end
        end
    end
end

return Choice
