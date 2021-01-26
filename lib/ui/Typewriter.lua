local gr = love.graphics

local function init(self, txt, x, y, size, delay, speed, color, font)
	-- position of text
	self.x, self.y = x or 200, y or 200
	-- The font to use
	self.size = size or 42
	self.font = font or gr.newFont("assets/fonts/hintedSymbola.ttf", self.size)
	-- The color to print
	self.color = color or {.7, 0, .34}
	-- The text to write
    self.toWrite = txt or "Hello World"
    -- The text written
    self.text  = ""

    -- Timer when to make the next letter
    self.timerMax = speed or 0.1
	self.timer = delay or 1

    -- Current position to printe next letter
	self.pos = 0
	return self
end

local function update(self, dt)
	-- when write finish return true
	if self.pos > #self.toWrite then
		return true
	else
		-- Decrease timer
		self.timer = self.timer - dt
		
		-- Timer done, we need to print a new letter:
		-- Adjust position, use string.sub to get sub-string
		if self.timer <= 0 then
			self.timer = self.timerMax
			self.pos = self.pos + 1

			self.text = string.sub(self.toWrite,0,self.pos)
		end
	end
end

local function draw(self, alpha)
	-- Print text so far
	gr.setFont(self.font)
	-- if alpha given set it to color
	if alpha then self.color[4] = alpha end
	-- set color
	gr.setColor(self.color)
	-- draw text
	gr.print(self.text,self.x,self.y)
end

return {init = init, update = update, draw = draw}