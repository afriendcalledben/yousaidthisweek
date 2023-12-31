-- Sprite Container
--
-- @file	SpriteContainer.lua
-- @author  Ivan Sergeev
-- @date	2020/06/15
--

class('SpriteContainer').extends()


-- SpriteContainer(x, y, [sprite1, sprite2, ....])
-- @brief
--		-
-- @example
--		import 'Lib/SpriteContainer'
--		local container = SpriteContainer(200, 120, sprite1, sprite2)

function SpriteContainer:init(x, y, ...)
	
	self.x = x or 0
	self.y = y or 0
	self.width = 0
	self.height = 0
	self.xScale = 1
	self.yScale = 1
	self.angle = 0
	self.zIndex = nil -- nil means that control over zIndexes occurs at the project level
	self.sprites = {}
	
	self._transform = {
		translate = function (x, y, px, py)
			local t = playdate.geometry.affineTransform.new()
			t:translate(px, py)
			return t:transformXY(x, y)
		end,
		rotate = function (x, y, angle)
			local t = playdate.geometry.affineTransform.new()
			t:rotate(angle)
			return t:transformXY(x, y)
		end,
		scale = function (x, y, scale)
			local t = playdate.geometry.affineTransform.new()
			t:scale(scale)
			return t:transformXY(x, y)
		end,
	}
	
	-- add sprites
	
	self:addSprite(...)
	
	return self	
end


-- container:addSprite(...)
-- @brief
--		-
-- @example
--		container:addSprite(sprite1)
--		container:addSprite(sprite1, sprite2, sprite3)

function SpriteContainer:addSprite(...)
	
	local sprites = {...}
	
	if sprites then
		
		local xCenter, yCenter = 1, 1
		local xScale, yScale = 1, 1
		
		-- add sprites
		for _, sprite in pairs(sprites) do
			
			if not self:checkSprite(sprite) then
				
				xScale, yScale = sprite:getScale()
				xCenter, yCenter = sprite:getCenter()
			
				table.insert(self.sprites, {
					sprite = sprite,
					x = sprite.x,
					y = sprite.y,
					xorigin = sprite.x,
					yorigin = sprite.y, 
					xcenter = xCenter,
					ycenter = yCenter,
					xscale = xScale,
					yscale = yScale,
					zindex = sprite:getZIndex()
				})
			end
		end
		
		-- update zIndex
		if self.zIndex ~= nil then
			local currentZIndex = self.zIndex
			self.setZIndex(nil)
			self.setZIndex(currentZIndex)
		end
	end
end


-- container:checkSprite(sprite)
-- @brief
--		return boolean
-- @example
--		container:checkSprite(mysprite)

function SpriteContainer:checkSprite(sprite)
	
	for _, item in pairs(self.sprites) do
		if item.sprite == sprite then
			do return true end
		end
	end
	
	return false
end

-- container:getSpriteIndex(sprite)
-- @brief
--		return index or 0
-- @example
--		container:getSpriteIndex(sprite1,sprite2,sprite3)

function SpriteContainer:getSpriteIndex(sprite)

	for key, item in pairs(self.sprites) do
		
		if item.sprite == sprite then
			return key
		end
	end
		
	return 0
end

-- container:removeSprite(...)
-- @brief
--		-
-- @example
--		container:removeSprite(sprite1)
--		container:removeSprite(sprite1, sprite2, sprite3)

function SpriteContainer:removeSprite(...)
	
	local sprites = {...}
	
	if sprites then
		
		-- add sprites
		for _, sprite in pairs(sprites) do
			
			local key = self:getSpriteIndex(sprite)
			
			if key ~= 0 then
				table.remove(self.sprites, key)
			end
		end
	end
end


-- container:moveTo(x, y)
-- @brief
--		-
-- @example
--		container:moveTo(200, 120)
--		container:moveTo(-10, -20)
--		container:moveTo(399, 239)

function SpriteContainer:moveTo(x, y)
	self:moveBy(x - self.x, y - self.y)
end


-- container:moveBy(x, y)
-- @brief
--		-
-- @example
--		container:moveBy(1, 0)
--		container:moveBy(0, -5)
--		container:moveBy(10, 10)

function SpriteContainer:moveBy(x, y)
	if x and y and type(x) == 'number' and type(y) == 'number' then
		
		if x ~= self.x and y ~= self.y then
			self.x, self.y = self._transform.translate(self.x, self.y, x, y)
			
			for _, item in pairs(self.sprites) do
				item.x, item.y = self._transform.translate(item.sprite.x, item.sprite.y, x, y)			
				item.sprite:moveTo(item.x, item.y)
				
				item.xorigin, item.yorigin = self._transform.translate(item.xorigin, item.yorigin, x, y)	
			end
		end
	else
		error('SpriteContainer.moveBy/moveTo: invalid arguments (' .. x .. ',' .. y .. ')')
	end
end


-- container:getPosition()
-- @brief
--		returns the tuple (x, y)

function SpriteContainer:getPosition()
	return self.x, self.y
end


function SpriteContainer:setCenter(x, y)
	error('SpriteContainer.setCenter: not supported')
end

function SpriteContainer:getCenter()
	error('SpriteContainer.getCenter: not supported')
end

-- container:setCenterPoint(x, y)
-- @brief
--		The setter sets the center for the container instance
-- @example
--		container:setCenterPoint(200, 120)

function SpriteContainer:setCenterPoint(x, y)
	
	if x and y and type(x) == 'number' and type(y) == 'number' then
		self.x, self.y = x, y
	else
		error('SpriteContainer.setCenter: invalid arguments (' .. x .. ',' .. y .. ')')
	end
end


-- container:getCenterPoint()
-- @brief
--		returns a playdate.geometry.point

function SpriteContainer:getCenterPoint()
	return playdate.geometry.point.new(self.x, self.y)
end

-- container:getCenterPointPosition()
-- @brief
--		returns the tuple (x, y)

function SpriteContainer:getCenterPointPosition()
	return self.x, self.y
end


-- container:setRotation(angle)
-- @brief
--		sets the rotation for the container instance
-- @example
--		container:setRotation(45)
--		container:setRotation(-15)

function SpriteContainer:setRotation(angle)
	
	if type(angle) == 'number' then
		
		local tx, ty = 0, 0
		self.angle = (self.angle + angle > 360) and self.angle + angle - 360 or (self.angle + angle < -360) and self.angle + angle + 360  or self.angle + angle
		
		for _, item in pairs(self.sprites) do
			
			tx, ty = self._transform.rotate(item.sprite.x - self.x, item.sprite.y - self.y, angle)
			item.x, item.y = tx + self.x, ty + self.y
			
			item.sprite:moveTo(item.x, item.y)
			item.sprite:setRotation(item.sprite:getRotation() + angle)
			
			item.xorigin, item.yorigin = self._transform.rotate(item.xorigin - self.x, item.yorigin - self.y, angle)
			
			item.xorigin, item.yorigin = item.xorigin + self.x, item.yorigin + self.y
		end
	else
		error('SpriteContainer.setRotation: invalid arguments (' .. angle .. ')')
	end
end


-- container:getRotation()
-- @brief
--		returns the current rotation of the container instance

function SpriteContainer:getRotation()
	return self.angle
end


-- container:getBounds()
-- @brief
--		 returns the 4-tuple (x, y, width, height) of the container instance

function SpriteContainer:getBounds()

	local minX, maxX, minY, maxY
	local x, y, width, height = 0, 0, 0, 0
	
	for _, item in pairs(self.sprites) do
		
		x, y, width, height = item.sprite:getBounds()
		_maxX = x + width
		_maxY = y + height
		
		if not maxX or _maxX > maxX then 
			maxX = _maxX
		end
		
		if not minX or minX > x then 
			minX = x
		end
		
		if not maxY or _maxY > maxY then
			maxY = _maxY
		end
		
		if not minY or minY > y then 
			minY = y
		end
	end
	
	return minX, minY, maxX-minX, maxY-minY
end


-- container:getBoundsRect()
-- @brief
--		 returns the container instance bounds as a playdate.geometry.rect object

function SpriteContainer:getBoundsRect()
	return playdate.geometry.rect.new(self:getBounds())
end

-- container:setSize(width, height)
-- @brief
--		-
-- @example
--		-
function SpriteContainer:setSize(width, height)
	error('SpriteContainer.setSize: not supported yet')
end


-- container:getSize()
-- @brief
--		 returns the tuple (width, height), the current size of the container instance

function SpriteContainer:getSize()
	local _, _, width, height = self:getBounds()
	return width, height
end


-- container:setScale(xScale, [yScale])
-- @brief
--		 
-- @example
--		container:setScale(0.5)
--		container:setScale(1.5, 0.3)

function SpriteContainer:setScale(...)
	error('SpriteContainer.setScale: not supported yet')
end


-- container:getScale()
-- @brief
--		 returns the tuple (xScale, yScale), the current scaling of the container instance

function SpriteContainer:getScale()
	error('SpriteContainer.getScale: not supported yet')
end


-- container:setZIndex(index)
-- @brief
--		Sets the Z-index of the container instance. Valid values for z are in the range (-20000, 20000).
--		It is highly recommended that you set a multiple of 100 or 1000.
--		Automatically changes the Z-index values ​​of sprites starting from the specified index.
-- @example
--		container:setZIndex(1000)
--		container:setZIndex(-500)

function SpriteContainer:setZIndex(index)
	
	-- set index
	if type(index) == 'number' and index > -20000 and index < 20000 then
		
		if index ~= self.zIndex then
			self.zIndex = index
			
			local indexes = {}
			for key, item in pairs(self.sprites) do
				table.insert(indexes, {
					key = key,
					index = item.sprite:getZIndex(),
				})
			end
			
			table.sort(indexes, function(a,b) return a.index < b.index end)
			
			for i, item in pairs(indexes) do
				self.sprites[item.key].sprite:setZIndex(index + i)
			end
		end
		
	-- reset index
	elseif index == nil then

		self.zIndex = nil
		
		for _, item in pairs(self.sprites) do
			item.sprite:setZIndex(item.zindex)
		end
		
	else
		error('SpriteContainer.setZIndex: invalid arguments (' .. index .. ')')
	end
end


-- container:getZIndex()
-- @brief
--		returns the current value of the container instance Z-index

function SpriteContainer:getZIndex()
	return self.zIndex
end


