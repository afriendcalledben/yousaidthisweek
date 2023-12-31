-- Sprite Container View
--
-- @file	SpriteContainerView.lua
-- @author  Ivan Sergeev
-- @date	2020/06/15
--

class('SpriteContainerView').extends(playdate.graphics.sprite)

-- SpriteContainerView(containerInstance)
-- @brief
--		not required
-- @example
--		import 'Lib/SpriteContainer' -- required
--		import 'Lib/SpriteContainerView'
--		local container = SpriteContainer(300, 120, sprite1, sprite2, sprite3)
--		local containerView = SpriteContainerView(container)

function SpriteContainerView:init(container)
	
	self.container = container
	self._width = 400
	self._height = 240
	self.mode = 2		-- set 1 to simple view or set 2 to full view
	
	self:setSize(self._width, self._height)
	self:setCenter(0, 0)
	self:setZIndex(10000)
	self:addSprite()
end

function SpriteContainerView:draw()
	
	local gfx = playdate.graphics
	local geom = playdate.geometry
	local _x, _y = self.container.x, self.container.y
	local currentColor, currentLineWidth = gfx.getColor(), gfx.getLineWidth()
	
	gfx.setPattern({0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55})
	
	-- center point
	
	gfx.setLineWidth(2)
	gfx.drawLine(_x-5, _y, _x+5, _y)
	gfx.drawLine(_x, _y-5, _x, _y+5)
	
	if self.mode == 2 then

		-- bound
		
		gfx.drawRect(self.container:getBoundsRect())
		
		-- guides for the sprites
		
		gfx.setLineWidth(1)
		
		for _, item in pairs(self.container.sprites) do
			
			spriteX, spriteY = item.sprite:getPosition()
			spriteGuide = geom.arc.new(_x, _y, geom.distanceToPoint(_x, _y, spriteX, spriteY), 0, 360) -- rotation guide
			gfx.drawArc(spriteGuide)
			
			-- origin point
			gfx.fillCircleAtPoint(item.xorigin, item.yorigin, 4)
		end
	end
	
	-- reset project setting
	gfx.getColor(currentColor)
	gfx.getLineWidth(currentLineWidth)
	
end