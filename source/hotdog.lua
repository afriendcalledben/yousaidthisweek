import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = pd.graphics

local HotdogType = {
    Big = 1,
    Small = 2
}


class('Hotdog').extends(pd.graphics.sprite)

function Hotdog:init(x, y, type, speed, name)
    local hotdogImg
    if type == HotdogType.Regular then
        hotdogImg = gfx.image.new('images/hotdog.png')
    elseif type == HotdogType.Small then
        hotdogImg = gfx.image.new('images/hotdog_small.png')
    end
    self:moveTo(x, y)
    self:setImage(hotdogImg)
    self:setCollideRect(0, 0, self:getSize())
    self.startX = x
    self.startY = y
    self.direction = 1;
    self.speed = speed
    self.name = name -- this is just for debugging
end

function Hotdog:descendBy(y)
    local currentY = self.y
    self:moveWithCollisions(self.x, currentY + y)
end

function Hotdog:collisionResponse(other)

    if type(other.death) == "function" then
        other:death()
    end

end

function Hotdog:update()
    Hotdog.super.update()
    if (self.width / 2 + self.x > 400) then
        self.direction = -1
    end
    if (self.x - self.width / 2 < 0) then
        self.direction = 1
    end

    self:moveBy(self.direction * self.speed, 0)
end

return {
    Hotdog = Hotdog,
    HotdogType = HotdogType
}
