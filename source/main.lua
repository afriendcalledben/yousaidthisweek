import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = pd.graphics

local popped = 0
local cPos = 0
-- Audio 
local synth = pd.sound.synth.new(pd.sound.kWaveTriangle)
local popSnd = pd.sound.sampleplayer.new( "audio/balloon_pop.wav" )

function init()
    -- New York skyline
    local bgImg = gfx.image.new('images/background_nyc.png')
    assert(bgImg)
    bgSpr = gfx.sprite.new(bgImg)
    bgSpr:moveTo(200,-260)
    bgSpr:add()
    -- Top of Al's head
    local topImg = gfx.image.new('images/al_top.png')
    assert(topImg)
    topSpr = gfx.sprite.new(topImg)
    topSpr:moveTo(200,120)
    topSpr:add()
    -- Bottom of Al's head
    local bottomImg = gfx.image.new('images/al_bottom.png')
    assert(bottomImg)
    bottomSpr = gfx.sprite.new(bottomImg)
    bottomSpr:moveTo(200,170)
    bottomSpr:add()
    -- Head pop graphic - not initially added to the display
    local popImg = gfx.image.new('images/pop.png')
    assert(popImg)
    popSpr = gfx.sprite.new(popImg)
    popSpr:moveTo(200,120)
end

init()

function pd.update()
    gfx.clear()
    synth:stop()
    -- Has the head popped
    if (popped == 0)
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
                -- If it goes higher, the pop the head
                cPos = 3804
                popped = 1
            else
                cPos = cPos + c
            end
        end
        if (cPos > 0)
        then
            -- If head position is more than 0, play a synth note representing the height. 
            synth:playNote((cPos/5), 0.5)
        end
        if (bgSpr)
        then
            bgSpr:moveTo(200,-260+(cPos/5))
        end
        if (topSpr)
        then
            topSpr:setClipRect(0, 0, 400,100+cPos)
        end
        if (bottomSpr)
        then
            bottomSpr:moveTo(200,170+cPos)
        end
        gfx.sprite.update()
        -- Add a legend showing forehead height
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRoundRect(5, 5, 185, 25, 5)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawTextInRect("*FOREHEAD* "..(tonumber(string.format("%.1f", cPos/2))+12).."cm", 10, 10, 180, 20)
    elseif (popped == 1)
    then
        -- if head popped, remove both head graphics and add pop graphic
        topSpr:remove()
        bottomSpr:remove()
        popSpr:add()
        gfx.sprite.update()
        -- play pop sound
        popSnd:play()
        popped = 2
    elseif (popped == 2)
    then
        gfx.sprite.update()
    end

    
end