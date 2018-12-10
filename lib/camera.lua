local lg=love.graphics

local function mixin( to, from ) for i, v in pairs( from or {} ) do to[i] = v end end

-- Rotate (px, py) about (ox, oy)
local function rotateAboutPoint( px, py, ox, oy, theta )
	px, py = px - ox, py - oy
	local cos, sin = math.cos( theta ), math.sin( theta )
	return px * cos - py * sin + ox, px * sin + py * cos + oy
end

local function makePush( self, layer )
	return function()
		lg.push( layer.mode )
		lg.origin()
		lg.translate( self.x + self.offsetX, self.y + self.offsetY )
		lg.rotate( self.rotation )
		lg.scale( self.scale * self.aspectRatioScale * layer.scale )
		lg.translate( -self.translationX * layer.relativeScale, -self.translationY * layer.relativeScale )
	end
end

local function addLayer( self, name, scale, flags )
	local new = {
		name = name,
		scale = scale,
		relativeScale = 1, -- Controls the translation speed
		mode = self.mode,
	}
	new.push = makePush( self, new )
	new.pop = lg.pop

	mixin( new, flags )

	self.layers[name] = new
	return new
end

local function newCamera( w, h, flags )
	local scale, scaleW, scaleH

	local new = {
		-- Attributes
		x = 0, y = 0,
		w = w, h = h,
		translationX = 0, translationY = 0,
		offsetX = w / 2, offsetY = h / 2,
		scale = 1,
		rotation = 0,
		resizable = false,
		maintainAspectRatio = false,
		aspectRatioScale = 1, -- Controls scale due to resizing
		mode = 'transform',
		layers = {},
		-- General Functions
		update = function( self, containerW, containerH )
			if self.resizable then self:resizingFunction( self:getContainerDimensions() ) end
		end,
		resizingFunction = function( self, containerW, containerH )
			if self.maintainAspectRatio then
				containerW, containerH = containerW - 2 * self.x, containerH - 2 * self.y
				scaleW, scaleH = containerW / self.w, containerH / self.h
				scale = math.min( scaleW, scaleH )
				self.w, self.h = scale * self.w, scale * self.h
			else
				self.w, self.h = containerW - 2 * self.x, containerH - 2 * self.y
			end
			self.aspectRatioScale = self.w / w
			self.offsetX, self.offsetY = self.w / 2, self.h / 2
		end,
		getContainerDimensions = function( self ) return lg.getDimensions() end,
		addLayer = addLayer,
		getLayer = function( self, name )
			return ( type( name ) == 'table' and name or self.layers[name] )
		end,
		push = function( self, layer ) self:getLayer( layer or 'main' ):push() end,
		pop = function( self, layer ) self:getLayer( layer or 'main' ):pop() end,
		getWorldCoordinates = function( self, x, y, layer )
			layer = self:getLayer( layer or 'main' )
			local scaleFactor = self.scale * self.aspectRatioScale * layer.scale
			x, y = x - self.x - self.offsetX, y - self.y - self.offsetY
			x, y = rotateAboutPoint( x, y, 0, 0, -self.rotation )
			x, y = x / scaleFactor, y / scaleFactor
			return x + self.translationX * layer.relativeScale, y + self.translationY * layer.relativeScale
		end,
		getScreenCoordinates = function( self, x, y, layer )
			layer = self:getLayer( layer or 'main' )
			local scaleFactor = self.scale * self.aspectRatioScale * layer.scale
			x, y = x - self.translationX / layer.relativeScale, y - self.translationY * layer.relativeScale
			x, y = x * scaleFactor, y * scaleFactor
			x, y = rotateAboutPoint( x, y, 0, 0, self.rotation )
			x, y = x + self.x + self.offsetX, y + self.y + self.offsetY
			return x, y
		end,
		getMouseWorldCoordinates = function( self, layer )
			layer = self:getLayer( layer or 'main' )
			local x, y = love.mouse.getPosition()
			return self:getWorldCoordinates( x, y, layer )
		end,
		increaseScaleToPoint = function( self, ds, wx, wy )
			if not wx then
				wx, wy = self:getMouseWorldCoordinates()
			end

			local tx, ty = self:getTranslation()
			self:increaseScale( ds )
			self:increaseTranslation( ( wx - tx ) * ds / self.scale, ( wy - ty ) * ds / self.scale )
		end,
		scaleToPoint = function( self, s, wx, wy )
			if not wx then
				wx, wy = self:getMouseWorldCoordinates()
			end

			local tx, ty = self:getTranslation()
			self:scaleBy( s )
			self:increaseTranslation( ( wx - tx ) * ( 1 - 1 / s ), ( wy - ty ) * ( 1 - 1 / s ) )
		end,
		-- Getters/setters
		setViewportPosition = function( self, x, y ) self.x, self.y = x, y end,
		getViewportPosition = function( self ) return self.x, self.y end,
		setOffset = function( self, x, y ) self.offsetX, self.offsetY = x, y end,
		getOffset = function( self ) return self.offsetX, self.offsetY end,
		setTranslation = function( self, x, y ) self.translationX, self.translationY = x or 0, y or 0 end,
		getTranslation = function( self ) return self.translationX, self.translationY end,
		increaseTranslation = function( self, dx, dy ) self.translationX, self.translationY = self.translationX + dx, self.translationY + dy end,
		setRotation = function( self, theta ) self.rotation = theta end,
		getRotation = function( self ) return self.rotation end,
		increaseRotation = function( self, dr ) self.rotation = self.rotation + dr end,
		setScale = function( self, s ) self.scale = s end,
		getScale = function( self ) return self.scale end,
		increaseScale = function( self, ds ) self.scale = self.scale + ds end,
		scaleBy = function( self, ds ) self.scale = self.scale * ds end,
	}
	new.translate = new.increaseTranslation
	new.rotate = new.increaseRotation

	mixin( new, flags )
	addLayer( new, 'main', 1 )

	return new
end


return setmetatable( { new = newCamera, }, { __call = function( _, ... ) return newCamera( ... ) end } )
