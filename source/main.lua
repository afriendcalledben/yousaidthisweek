import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "ben"

local hotdogModule = import "hotdog"
local Hotdog = hotdogModule.Hotdog
local HotdogType = hotdogModule.HotdogType

local pd <const> = playdate
local gfx <const> = pd.graphics

-- local gameState.value = 0
local gameState = { value = 0 }

local cPos = 0
local cPos2 = -150
local synth = pd.sound.synth.new(pd.sound.kWaveTriangle)
-- local hx = 200
-- local hy = -300
-- local hc = 0

local bool
popped = false

function init()
    -- New York skyline
    local bgImg = gfx.image.new('images/background_nyc.png')
    assert(bgImg)
    skySpr = gfx.sprite.new(bgImg)
    skySpr:moveTo(200, -260)
    skySpr:add()


    -- Deep Space BG
    local deepSpaceImg = gfx.image.new('images/deepSpace.png')
    assert(deepSpaceImg)
    deepSpaceSpr = gfx.sprite.new(deepSpaceImg)
    deepSpaceSpr:moveTo(200, -260 + 2000)
    deepSpaceSpr:add()

    -- Space BG
    local spaceImg = gfx.image.new('images/space.png')
    -- local spaceImg = gfx.image.new('images/deepSpace.png')
    assert(spaceImg)
    spaceSpr = gfx.sprite.new(spaceImg)
    spaceSpr:moveTo(200, -260 + 1000)
    spaceSpr:add()



    -- Top of Al's head
    local topImg = gfx.image.new('images/al_top.png')
    assert(topImg)
    topSpr = gfx.sprite.new(topImg)
    topSpr:moveTo(200, 120)
    topSpr:add()

    -- Top of Al's head cropped
    local topImgCropped = gfx.image.new('images/al_top_cropped.png')
    assert(topImgCropped)
    topSprCropped = gfx.sprite.new(topImgCropped)
    topSprCropped:moveTo(200, 120)

    -- Head pop graphic - not initially added to the display
    local popImg = gfx.image.new('images/pop.png')
    assert(popImg)
    popSpr = gfx.sprite.new(popImg)
    popSpr:moveTo(200, 120)

    -- Ben
    ben = Ben(200, 2000, popSpr, gameState)
    ben:add()

    -- Bottom of Al's head
    local bottomImg = gfx.image.new('images/al_bottom.png')
    assert(bottomImg)
    bottomSpr = gfx.sprite.new(bottomImg)
    bottomSpr:moveTo(200, 170)
    bottomSpr:add()

    -- Hotdogs
    hotdog1 = Hotdog(200, -600, HotdogType.Small, 2, "h1")
    hotdog1:add()

    hotdog2 = Hotdog(200, -1000, HotdogType.Small, 4, "h2")
    hotdog2:add()

    hotdog3 = Hotdog(200, -1400, HotdogType.Small, 6, "h3")
    hotdog3:add()

    hotdog4 = Hotdog(200, -1800, HotdogType.Small, 8, "h4")
    hotdog4:add()

    hotdog5 = Hotdog(200, -2200, HotdogType.Small, 10, "h5")
    hotdog5:add()

    hotdog6 = Hotdog(200, -2600, HotdogType.Small, 12, "h6")
    hotdog6:add()

    hotdog7 = Hotdog(200, -3000, HotdogType.Small, 14, "h7")
    hotdog7:add()

    hotdog8 = Hotdog(200, -3400, HotdogType.Small, 16, "h8")
    hotdog8:add()

    hotdog9 = Hotdog(200, -4000, HotdogType.Small, 20, "h9")
    hotdog9:add()

    hotdog10 = Hotdog(200, -4400, HotdogType.Small, 22, "h10")
    hotdog10:add()

    hotdog11 = Hotdog(200, -4800, HotdogType.Small, 24, "h11")
    hotdog11:add()

    hotdog12 = Hotdog(200, -5100, HotdogType.Small, 28, "h12")
    hotdog12:add()

    hotdog13 = Hotdog(200, -5400, HotdogType.Small, 32, "h13")
    hotdog13:add()

    hotdog14 = Hotdog(200, -5700, HotdogType.Big, 38, "h14")
    hotdog14:add()
end

init()

function pd.update()
    PlaySinWave()

    gfx.clear(gfx.kColorBlack)
    synth:stop()

    -------------------- STATE 0 -------------------- forehead goes up, background scrolls

    if (gameState.value == 0) -- initial state, whereby the crank is used to move the head up
    then
        -- If the crank is docked, reduce the head position until it reaches 0
        if (pd.isCrankDocked())
        then
            if (cPos - 10 > 0)
            then
                cPos = cPos - 10
            else
                cPos = 0
            end
        else
            -- Add the crank change to the head position, ensuring it doesn't go lower than 0 or higher than 3804 (the top of the sky)
            local c, ac = pd.getCrankChange()
            if (cPos + c < 0)
            then
                cPos = 0;
            elseif (cPos + c > 3804)
            then
                -- reach the top of this section, move to the next
                cPos = 3804
                bottomSprEndPos = bottomSpr:getPosition()
                gameState.value = 1
            else
                cPos = cPos + c
            end
        end

        if (cPos > 0)
        then
            -- If head position is more than 0, play a synth note representing the height.
            synth:playNote((cPos / 5), 0.5)
            -- PlaySinWave()
        end

        if (skySpr)
        then
            skySpr:moveTo(200, -260 + (cPos / 5))
        end

        if (topSpr)
        then
            local newTopPos = 100 + cPos
            topSpr:setClipRect(0, 0, 400, newTopPos)
        end

        if (bottomSpr)
        then
            bottomSpr:moveTo(200, 170 + cPos)
        end

        gfx.sprite.update()
        DrawLegend()

        -------------------- STATE 1 -------------------- background stops, my face comes back up
    elseif (gameState.value == 1)
    then
        local c, ac = pd.getCrankChange()
        -- bgSpr:moveTo(200,-260+(cPos/5))
        cPos = cPos + c


        bottomSpr:moveTo(200, bottomSprEndPos - cPos2)
        local newTopPos = 100 - cPos2


        topSpr:setClipRect(0, 0, 400, 150 - 21 - cPos2)

        local _, y = bottomSpr:getPosition()

        cPos2 += c

        if (y <= 170)
        then
            bottomSpr:moveTo(200, 170)
            topSpr:setClipRect(0, 0, 400, 100)
            gameState.value = 2
        end

        PlaySinWave()
        gfx.sprite.update()

        -------------------- STATE 2 -------------------- my forehead leaves frame
    elseif (gameState.value == 2)
    then
        local c, ac = pd.getCrankChange()

        topSpr:remove()
        topSprCropped:add()
        ben:moveTo(200, 120)

        topSprCropped:moveBy(0, -c)
        -- local l = topSprCropped:getPosition()
        local _, y = topSprCropped:getPosition()
        if (y > 120)
        then
            topSprCropped:moveTo(200, 170)
        end

        if (y < -10)
        then
            gameState.value = 3
        end

        PlaySinWave()
        gfx.sprite.update()

        -------------------- STATE 3 -------------------- configure for state 4, only runs once the goes straight to state 4
    elseif (gameState.value == 3)
    then
        local c, ac = pd.getCrankChange()
        local _, skyY = skySpr:getPosition()
        spaceSpr:moveTo(200, skyY - 1000)
        deepSpaceSpr:moveTo(200, skyY - 2000)
        hc = 0
        gameState.value = 4

        PlaySinWave()
        gfx.sprite.update()
    end

    -------------------- STATE 4 --------------------
    -- went straight from state 3 to state 4 so i used 'if', not 'elseif'

    if (gameState.value == 4)
    then
        local c, ac = pd.getCrankChange()
        hc += c
        skySpr:moveBy(0, c / 5)
        spaceSpr:moveBy(0, c / 5)
        deepSpaceSpr:moveBy(0, c / 5)
        bottomSpr:moveBy(0, c)

        -- Must be a better way to call this method on all the hotdogs
        hotdog1:descendBy(c)
        hotdog2:descendBy(c)
        hotdog3:descendBy(c)
        hotdog4:descendBy(c)
        hotdog5:descendBy(c)
        hotdog6:descendBy(c)
        hotdog7:descendBy(c)
        hotdog8:descendBy(c)
        hotdog9:descendBy(c)
        hotdog10:descendBy(c)
        hotdog11:descendBy(c)
        hotdog12:descendBy(c)
        hotdog13:descendBy(c)
        hotdog14:descendBy(c)



        PlaySinWave()

        gfx.sprite.update()
    end

    if (gameState.value == 5)
    then
        -- Nothing else happens

        gfx.sprite.update()
    end
end

function DrawLegend()
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(5, 5, 185, 25, 5)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawTextInRect("*FOREHEAD* " .. (tonumber(string.format("%.1f", cPos * 10)) + 12) .. "cm", 10, 10, 180, 20)
end

function PlaySinWave()
    if (popped == false)
    then
        sin = math.sin(pd.getElapsedTime() * 2)
        sin = map(sin, -1, 1, 10, 100)
        synth:playNote((sin), 0.5)
    end
end

function map(value, low, high, newLow, newHigh)
    return newLow + (value - low) * (newHigh - newLow) / (high - low)
end
