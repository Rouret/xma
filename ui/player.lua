local State = require("player.state")

local UIPlayer = {}

UIPlayer.skills = {}
UIPlayer.skills.gap = 16
UIPlayer.skills.size = 120 * 3 + 16 * 2
UIPlayer.skills.skillSize = 120

UIPlayer.healthBar = {}
UIPlayer.healthBar.width = UIPlayer.skills.size
UIPlayer.healthBar.height = 20

UIPlayer.expBar = {}
UIPlayer.expBar.width = UIPlayer.skills.size
UIPlayer.expBar.height = 20

UIPlayer.switch = {}
UIPlayer.switch.itemSize = 32
UIPlayer.switch.gap = 12
UIPlayer.switch.imageEnabled = love.graphics.newImage("sprites/switch.png")
UIPlayer.switch.imageDisabled = love.graphics.newImage("sprites/switch-disable.png")

UIPlayer.emptyImage = love.graphics.newImage("sprites/empty_image.png")
UIPlayer.cooldownOverlay = love.graphics.newImage("sprites/weapons/on_cd_skill.png")

function UIPlayer.drawPlayerHealth(UI)
    local health = State.health
    local maxHealth = State.maxHealth
    local healthPercentage = health / maxHealth
    local healthBarX = (UI.screenWidth - UIPlayer.healthBar.width) / 2
    local healthBarY = UI.screenHeight - UIPlayer.skills.skillSize - 40
    local healthBarFillWidth = UIPlayer.healthBar.width * healthPercentage
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", healthBarX, healthBarY, healthBarFillWidth, UIPlayer.healthBar.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", healthBarX, healthBarY, UIPlayer.healthBar.width, UIPlayer.healthBar.height)

    local healthText = string.format("%d/%d", health, maxHealth)
    love.graphics.setFont(UI.font.small)
    local textWidth = UI.font.small:getWidth(healthText)
    local textHeight = UI.font.small:getHeight(healthText)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(
        healthText,
        healthBarX + (UIPlayer.healthBar.width - textWidth) / 2,
        healthBarY + (UIPlayer.healthBar.height - textHeight) / 2
    )
    love.graphics.setColor(1, 1, 1)
end

function UIPlayer.drawPlayerExp(UI)
    local exp = State.experience
    local maxExp = 100 * State.level
    local expPercentage = exp / maxExp
    local expBarX = (UI.screenWidth - UIPlayer.expBar.width) / 2
    local expBarY = UI.screenHeight - UIPlayer.skills.skillSize - 80
    local expBarFillWidth = UIPlayer.expBar.width * expPercentage
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle("fill", expBarX, expBarY, expBarFillWidth, UIPlayer.expBar.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", expBarX, expBarY, UIPlayer.expBar.width, UIPlayer.expBar.height)

    local expText = string.format("%d/%d", exp, maxExp)
    love.graphics.setFont(UI.font.small)
    local textWidth = UI.font.small:getWidth(expText)
    local textHeight = UI.font.small:getHeight(expText)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        expText,
        expBarX + (UIPlayer.expBar.width - textWidth) / 2,
        expBarY + (UIPlayer.expBar.height - textHeight) / 2
    )

    local levelText = string.format("Level %d", State.level)
    local levelTextWidth = UI.font.small:getWidth(levelText)
    love.graphics.print(levelText, expBarX - levelTextWidth - 10, expBarY + (UIPlayer.expBar.height - textHeight) / 2)

    love.graphics.setColor(1, 1, 1)
end

function UIPlayer.drawSwitchWeapon(UI)
    local currentWeapon = State.getCurrentWeapon()
    local nextWeapon = State.getNextWeapon()

    if not currentWeapon then
        currentWeapon = {sprite = UIPlayer.emptyImage}
    end

    if not nextWeapon then
        nextWeapon = {sprite = UIPlayer.emptyImage}
    end

    local currentWeaponSprite = currentWeapon.sprite
    local nextWeaponSprite = nextWeapon.sprite

    local x = ((UI.screenWidth - UIPlayer.skills.size) / 2) - UIPlayer.switch.itemSize - UIPlayer.switch.gap
    local y = UI.screenHeight - UIPlayer.skills.skillSize

    -- Draw previous weapon
    love.graphics.draw(currentWeaponSprite, x, y)

    local imageToDraw
    if State.canSwitchWeapon() then
        imageToDraw = UIPlayer.switch.imageEnabled
    else
        imageToDraw = UIPlayer.switch.imageDisabled
    end

    love.graphics.draw(imageToDraw, x, y + UIPlayer.switch.gap + UIPlayer.switch.itemSize)

    love.graphics.draw(nextWeaponSprite, x, y + (UIPlayer.switch.gap + UIPlayer.switch.itemSize) * 2)
end

function UIPlayer.drawSkills(UI)
    local mouseX, mouseY = love.mouse.getPosition()

    local weapon = State.weapons[State.currentWeaponIndex]
    if not weapon then
        return
    end
    local totalWidth = (#weapon.skills * UIPlayer.skills.skillSize) + ((#weapon.skills - 1) * UIPlayer.skills.gap)
    local x = (UI.screenWidth - totalWidth) / 2
    local y = UI.screenHeight - UIPlayer.skills.skillSize
    for i, skill in ipairs(weapon.skills) do
        local calcX = x + (i - 1) * (UIPlayer.skills.skillSize + UIPlayer.skills.gap)

        local skillSize = UIPlayer.skills.skillSize
        love.graphics.draw(skill.image, calcX, y)
        if skill.remainingCooldownInSeconds > 0 then
            love.graphics.draw(UIPlayer.cooldownOverlay, calcX, y)
            local cooldownText = UI.formatTime(skill.remainingCooldownInSeconds)
            love.graphics.setFont(UI.font.big)
            local textWidth = UI.font.big:getWidth(cooldownText)
            local textHeight = UI.font.big:getHeight()
            love.graphics.print(cooldownText, calcX + (skillSize - textWidth) / 2, y + (skillSize - textHeight) / 2)
        end

        -- Detect hover
        local isHovered = mouseX >= calcX and mouseX <= calcX + skillSize and mouseY >= y and mouseY <= y + skillSize

        -- draw a popup with defailt folow the mouse
        if isHovered then
            -- white background
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(UI.font.small)
            local text = skill.name
            local textWidth = UI.font.small:getWidth(text)
            local textHeight = UI.font.small:getHeight()

            -- 32 padding
            local padding = 32
            local popupWidth = textWidth + padding
            local popupHeight = textHeight + padding
            local popupX = mouseX - popupWidth / 2
            local popupY = mouseY - popupHeight - 10
            -- draw the name of the skill
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", popupX, popupY, popupWidth, popupHeight)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(text, popupX + padding / 2, popupY + padding / 2)
        end
    end
end

function UIPlayer.draw(UI)
    UIPlayer.drawPlayerHealth(UI)
    UIPlayer.drawPlayerExp(UI)
    UIPlayer.drawSwitchWeapon(UI)
    UIPlayer.drawSkills(UI)
end

return UIPlayer
