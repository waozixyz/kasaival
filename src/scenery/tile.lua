local copy = require "utils.copy"
local state = require "state"

local gfx = love.graphics

local function init(self, props)
    for k, v in pairs(props) do
        self[k] = v
    end
    return copy(self)
end

local function findElement(c)
    local r, g, b = c[1], c[2], c[3]
    if r > g and r > b then
        return "sand"
    elseif g > r and g > b then
        return "grass"
    elseif b > r and b > g then
        return "water"
    end
end

local function balanceColor(current_c, target_c, max_change)
  local delta = target_c - current_c
  if delta > max_change then
      return max_change
  elseif delta < -max_change then
      return -max_change
  else 
    return 0 
  end
end


-- Utility function to adjust color when object is burning during 'grass' state
local function adjustGrassBurnColor(redValue)
    if redValue < 0.3 then
        return redValue + 0.17    -- add .17 to red value
    elseif redValue < 0.5 then
        return redValue + 0.12    -- add .12 to red value
    elseif redValue < 0.6 then
        return redValue + 0.08    -- add .08 to red value
    elseif redValue < 0.7 then
        return redValue + 0.05    -- add .05 to red value
    elseif redValue < 0.8 then
        return redValue + 0.03    -- add .03 to red value
    else 
        return redValue    -- don't change the red value
    end
end

-- Utility function to adjust color when object is burning during 'sand' state
local function adjustSandBurnColor(redValue, greenValue, blueValue, originalGreenValue)
    if greenValue > originalGreenValue - 0.13 then
        redValue = redValue - 0.005    -- subtract .005 from red value
        greenValue = greenValue - 0.02    -- subtract .02 from green value
        blueValue = blueValue - 0.007    -- subtract .007 from blue value 
    end
    return redValue, greenValue, blueValue
end

local function burn(self, object)
    local r, g, b = self.color[1], self.color[2], self.color[3]
    local element = findElement(self.orgColor)

    -- If the color matches "grass," adjust the color based on the value of red
    if element == "grass" then
        r = adjustGrassBurnColor(r)
    -- If the color matches "sand," adjust the color based on a combination of green and orgColor
    elseif element == "sand" then
        r, g, b = adjustSandBurnColor(r, g, b, self.orgColor[2])
    end

    -- Subtract the fuel consumed by the 'object' (with more descriptive naming)
    local remainingFuel = self.fuel - object.burnPower
    self.fuel = remainingFuel >= 0 and remainingFuel or 0

    -- Update the color and return the amount of burned fuel
    self.color = {r, g, b}
    local burnedFuelAmount = self.fuel - remainingFuel
    return burnedFuelAmount
end

local function getOctagonVertices(index, tile)
    -- Calculate the x and y coordinates of the octagon's center
    local x = tile.x
    local y = tile.y
    y = y + tile.h / 4
    
    -- Calculate the x and y offsets for the octagon's vertices based on tile width and height
    local xRadius = tile.w / 4
    local yRadius = tile.h / 4

    local xOffsets = {
        -xRadius / 2,
         xRadius / 2,
         xRadius,
         xRadius,
         xRadius / 2,
        -xRadius / 2,
        -xRadius,
        -xRadius
    }
    
    local yOffsets = {
        -yRadius,
        -yRadius,
        -yRadius / 2,
         yRadius / 2,
         yRadius,
         yRadius,
         yRadius / 2,
        -yRadius / 2
    }
  
    -- Build an array of the octagon's vertices
    local vertices = {}
    for i = 1, 8 do
      table.insert(vertices, x + xOffsets[i])
      table.insert(vertices, y + yOffsets[i])
    end
  
    return unpack(vertices)
end

local function draw(self, i)
    gfx.setColor(self.color)
    gfx.polygon("fill", getOctagonVertices(i, self))
end

-- Adjusts color of self based on orgColor
function heal(self)
  local currentColor = self.color
  local originalColor = self.orgColor
 
  local red, green, blue = currentColor[1], currentColor[2], currentColor[3]
 
  -- Find the element of the original color and adjust the RGB values accordingly
  local element = findElement(originalColor)
  if element == "grass" then
    if red > .6 then
      red, green, blue = red - .01, green - .007, blue - .002
    elseif red > .5 then
      red, green, blue = red - .005, green - .005, blue - .002
    end
  elseif element == "sand" then
    -- TODO: Add condition for sand element
  end
 
  -- Re-balance the color values
  red = red + balanceColor(red, originalColor[1], .0009)
  green = green + balanceColor(green, originalColor[2], .0003)
  blue = blue + balanceColor(blue, originalColor[3], .0001)
 
  -- Ensure that green and blue values do not go below 0.07
  if green < .07 then green = .07 end
  if blue < .07 then blue = .07 end
 
  -- Fuel regeneration calculation
  if math.floor(self.fuel * 10) ~= math.floor(self.orgFuel *10) then
    self.fuel = self.fuel + (self.orgFuel - self.fuel) * .1
  end
 
  -- Update the color value of self
  self.color = {red, green, blue}
end


local function update(self, dt)
    if not self.hit then
        heal(self)
    end
    self.hit = false
end

return {init = init, draw = draw, update = update, burn = burn}