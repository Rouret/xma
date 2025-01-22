local State = require("player.state")
local Choice = require("game.choice")
local UI = {}

local cooldownOverlay = love.graphics.newImage("sprites/weapons/on_cd_skill.png")

function UI.load()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    UI.screenWidth = screenWidth
    UI.screenHeight = screenHeight

    UI.skills = {}
    UI.skills.gap = 16
    UI.skills.size = 120 * 3 + 16 * 2
    UI.skills.skillSize = 120

    UI.healthBar = {}
    UI.healthBar.width = UI.skills.size
    UI.healthBar.height = 20

    UI.expBar = {}
    UI.expBar.width = UI.skills.size
    UI.expBar.height = 20

    UI.switch = {}
    UI.switch.itemSize = 32
    UI.switch.gap = 12
    UI.switch.imageEnabled = love.graphics.newImage("sprites/switch.png")
    UI.switch.imageDisabled = love.graphics.newImage("sprites/switch-disable.png")

    UI.emptyImage = love.graphics.newImage("sprites/empty_image.png")

    UI.font = {}
    UI.font.big = love.graphics.newFont(36)
    UI.font.medium = love.graphics.newFont(24)
    UI.font.small = love.graphics.newFont(16)

    return UI
end

function UI.update()
end

function UI:draw()
    UI.drawSkills()
    UI.drawPlayerHealth()
    UI.drawPlayerExp()
    UI.drawSwitchWeapon()
    UI.drawPlayerStat()
end

function UI.drawPlayerStat()
    local x = (UI.skills.size / 2) + (UI.screenWidth / 2) + UI.switch.gap
    local y = UI.screenHeight - UI.skills.skillSize

    love.graphics.draw(Choice.config[Choice.Type.SPEED].image, x, y)
    local speedValue = UI.formatValue(State.speed)
    love.graphics.setFont(UI.font.small)
    local textHeight = UI.font.small:getHeight(speedValue)
    love.graphics.print(speedValue, x + UI.switch.itemSize + UI.switch.gap, y + (UI.switch.itemSize - textHeight) / 2)

    y = y + UI.switch.itemSize + UI.switch.gap

    love.graphics.draw(Choice.config[Choice.Type.DAMAGE].image, x, y)
    local damageValue = UI.formatValue(State.damage)
    love.graphics.setFont(UI.font.small)
    local textHeight = UI.font.small:getHeight(damageValue)
    love.graphics.print(damageValue, x + UI.switch.itemSize + UI.switch.gap, y + (UI.switch.itemSize - textHeight) / 2)
end

function UI.drawSwitchWeapon()
    local weapon = State.weapons[State.currentWeaponIndex]
    local previousWeapon = State.weapons[State.currentWeaponIndex - 1] or State.weapons[#State.weapons]
    local nextWeapon = State.weapons[State.currentWeaponIndex + 1] or State.weapons[1]

    local x = ((UI.screenWidth - UI.skills.size) / 2) - UI.switch.itemSize - UI.switch.gap
    local y = UI.screenHeight - UI.skills.skillSize

    -- Draw previous weapon
    love.graphics.draw(UI.emptyImage, x, y)

    local imageToDraw
    if State.canSwitchWeapon() then
        imageToDraw = UI.switch.imageEnabled
    else
        imageToDraw = UI.switch.imageDisabled
    end

    love.graphics.draw(imageToDraw, x, y + UI.switch.gap + UI.switch.itemSize)

    love.graphics.draw(UI.emptyImage, x, y + (UI.switch.gap + UI.switch.itemSize) * 2)
end

function UI.drawPlayerExp()
    local player = State.player
    local exp = State.experience
    local maxExp = 100 * State.level
    local expPercentage = exp / maxExp
    local expBarX = (UI.screenWidth - UI.expBar.width) / 2
    local expBarY = UI.screenHeight - UI.skills.skillSize - 80
    local expBarFillWidth = UI.expBar.width * expPercentage
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle("fill", expBarX, expBarY, expBarFillWidth, UI.expBar.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", expBarX, expBarY, UI.expBar.width, UI.expBar.height)

    local expText = string.format("%d/%d", exp, maxExp)
    love.graphics.setFont(UI.font.small)
    local textWidth = UI.font.small:getWidth(expText)
    local textHeight = UI.font.small:getHeight(expText)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        expText,
        expBarX + (UI.expBar.width - textWidth) / 2,
        expBarY + (UI.expBar.height - textHeight) / 2
    )

    local levelText = string.format("Level %d", State.level)
    local levelTextWidth = UI.font.small:getWidth(levelText)
    love.graphics.print(levelText, expBarX - levelTextWidth - 10, expBarY + (UI.expBar.height - textHeight) / 2)

    love.graphics.setColor(1, 1, 1)
end

function UI.drawPlayerHealth()
    local player = State.player
    local health = State.health
    local maxHealth = State.maxHealth
    local healthPercentage = health / maxHealth
    local healthBarX = (UI.screenWidth - UI.healthBar.width) / 2
    local healthBarY = UI.screenHeight - UI.skills.skillSize - 40
    local healthBarFillWidth = UI.healthBar.width * healthPercentage
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", healthBarX, healthBarY, healthBarFillWidth, UI.healthBar.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", healthBarX, healthBarY, UI.healthBar.width, UI.healthBar.height)

    local healthText = string.format("%d/%d", health, maxHealth)
    love.graphics.setFont(UI.font.small)
    local textWidth = UI.font.small:getWidth(healthText)
    local textHeight = UI.font.small:getHeight(healthText)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(
        healthText,
        healthBarX + (UI.healthBar.width - textWidth) / 2,
        healthBarY + (UI.healthBar.height - textHeight) / 2
    )
    love.graphics.setColor(1, 1, 1)
end

function UI.drawSkills()
    local weapon = State.weapons[State.currentWeaponIndex]
    local totalWidth = (#weapon.skills * UI.skills.skillSize) + ((#weapon.skills - 1) * UI.skills.gap)
    local x = (UI.screenWidth - totalWidth) / 2
    local y = UI.screenHeight - UI.skills.skillSize
    for i, skill in ipairs(weapon.skills) do
        local calcX = x + (i - 1) * (UI.skills.skillSize + UI.skills.gap)
        love.graphics.draw(skill.image, calcX, y)
        if skill.remainingCooldownInSeconds > 0 then
            love.graphics.draw(cooldownOverlay, calcX, y)
            local cooldownText = UI.formatTime(skill.remainingCooldownInSeconds)
            love.graphics.setFont(UI.font.big)
            local textWidth = UI.font.big:getWidth(cooldownText)
            local textHeight = UI.font.big:getHeight(cooldownText)
            love.graphics.print(
                cooldownText,
                calcX + (UI.skills.skillSize - textWidth) / 2,
                y + (UI.skills.skillSize - textHeight) / 2
            )
        end
    end
end

function UI.formatTime(seconds)
    local remainingSeconds = seconds % 60
    return string.format("%d", remainingSeconds)
end

function UI.formatValue(value)
    return string.format("%d", math.floor(value))
end

return UI
