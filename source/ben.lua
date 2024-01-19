import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Ben').extends(pd.graphics.sprite)

function Ben:init(x, y, popSpr)
    local benImg = gfx.image.new('images/ben_small.png')
    assert(benImg)

    self:moveTo(x, y)
    self:setImage(benImg)
    self:setCollideRect(0,0,self:getSize())
    self.startX = x
    self.startY = y
    self.popSpr = popSpr
    self.popSnd = pd.sound.sampleplayer.new("audio/balloon_pop.wav")
    self.alive = true;
end

-- function Ben:moveBy(y)
--     local currentY = self.y
--     -- self:moveTo(self.x, currentY + y)
--     self:moveWithCollisions(self.x, currentY + y)
-- end

function Ben:collisionResponse(other)

end

function Ben:death()
    if(self.alive)
    then
        print("death")
        self.popSnd:play()
        self.popSpr:moveTo(self.x, self.y)
        self.popSpr:add()
        alive = false
        self:remove()
    end
end
