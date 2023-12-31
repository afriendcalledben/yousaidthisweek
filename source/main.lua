import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import 'Lib/SpriteContainer'
import 'Lib/SpriteContainerView' 

local pd <const> = playdate
local gfx <const> = pd.graphics

local state = 0
local cPos = 0
local cPos2 = -150
-- Audio 
local synth = pd.sound.synth.new(pd.sound.kWaveTriangle)
local popSnd = pd.sound.sampleplayer.new( "audio/balloon_pop.wav" )

local botty = true
local rotation = 0
-- local container = SpriteContainer(300, 120, sprite1, sprite2, sprite3)

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

    -- local container = SpriteContainer(300, 120, topImg, bottomImg)
    -- assert(container)
    
end

init()

function pd.update()
    gfx.clear()
    synth:stop()
    

    -------------------- STATE 0 -------------------- head goes up

    if (state == 0) -- initial state, whereby the crank is used to move the head up
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
                bottomSprEndPos = bottomSpr:getPosition()
                state = 1
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
            local newTopPos = 100+cPos
            -- print(newTopPos)
            topSpr:setClipRect(0, 0, 400,newTopPos)
        end
        
        if (bottomSpr)
        then
            bottomSpr:moveTo(200,170+cPos)
        end
        
       
        gfx.sprite.update()
        DrawLegend()
 


    -------------------- STATE 1 --------------------
        
    elseif (state == 1)
    then
        local c, ac = pd.getCrankChange()
        -- bgSpr:moveTo(200,-260+(cPos/5))
        cPos = cPos + c
      


        bottomSpr:moveTo(200,bottomSprEndPos-cPos2)
        local newTopPos = 100-cPos2
        
  
        topSpr:setClipRect(0, 0, 400, 150-21-cPos2)
        
        local _, y = bottomSpr:getPosition()

        cPos2 += c

        if(y <= 170)
        then 
            bottomSpr:moveTo(200,170)
            topSpr:setClipRect(0, 0, 400, 100)
            state = 2
        -- else
            -- bottomSpr:moveTo(200,bottomSprEndPos-cPos2)
            -- topSpr:setClipRect(0, 0, 400, 150-cPos2)
        end





        gfx.sprite.update()
 
        -- -- if head state, remove both head graphics and add pop graphic
        -- topSpr:remove()
        -- bottomSpr:remove()
        -- popSpr:add()
        -- gfx.sprite.update()
        -- -- play pop soundx   
        -- popSnd:play()
        -- state = 2
        -- state = 2

    -------------------- STATE 2 --------------------

    elseif (state == 2)
    then
        local c, ac = pd.getCrankChange()
        rotation += c
        -- bottomSpr:setRotation(rotation)

        gfx.sprite.update()
        -- if head state, remove both head graphics and add pop graphic
        -- topSpr:remove()
        -- bottomSpr:remove()
        -- popSpr:add()
        -- gfx.sprite.update()
        -- -- play pop sound
        -- popSnd:play()
        -- state = 3


    -------------------- STATE 3 --------------------

    elseif (state == 3)
    then
        gfx.sprite.update()
    end
end


function DrawLegend()
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(5, 5, 185, 25, 5)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawTextInRect("*FOREHEAD* "..(tonumber(string.format("%.1f", cPos*10))+12).."cm", 10, 10, 180, 20)
end

