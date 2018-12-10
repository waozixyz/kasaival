-- This code is licensed under the MIT Open Source License.

-- Copyright (c) 2015 Ruairidh Carmichael - ruairidhcarmichael@live.co.uk

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

local path='lib/'
local tween=require(path .. 'tween')
local lg=love.graphics

local splashy = {}
splashy.list = {}
splashy.inalpha = 0
splashy.outalpha = 255
splashy.count = 1
splashy.tweenlist = {}
splashy.fadestate = "in"
splashy.finished = false
splashy.onCompleteFunction = nil

function splashy.addSplash(img,duration,index,x,y,scale)
	duration=duration or 2
	assert(type(duration)=='number' and duration>0, "duration must be a positive number.")
	index=index or #splashy.list+1
	assert(type(index)=="number", "index must be a number")
	splashy.list[index]=img
	splashy.tweenlist[index]=tween.new(duration, splashy, {inalpha = 255, outalpha = 0})
  splashy.x,splashy.y=x,y
  splashy.scale=scale
end

function splashy.skipSplash()
	splashy.fadestate='in'
	splashy.count=splashy.count+1
end
	
function splashy.skipAll()
	splashy.fadestate='in'
	splashy.count=#splashy.list+1
end

function splashy.onComplete(func)
	assert(type(func)=='function', 'func must be a function')
	splashy.onCompleteFunction = func
end

function splashy.draw()
	if splashy.finished == false then
		for i=1,#splashy.list do
			if splashy.fadestate=='in' then
				lg.setColor(1,1,1,splashy.inalpha/255)
			elseif splashy.fadestate=="out" then
				lg.setColor(1,1,1,splashy.outalpha/255)
			end

			-- If the current splash is the one in the list.
			if splashy.count==i then
				-- Then grab the splash from the list and draw it to the screen.
				local splash=splashy.list[i]
   local x,y=splashy.x,splashy.y
   local sc=splashy.scale
 
				local offX=splash:getWidth()*.5
				local offY=splash:getHeight()*.5
				lg.draw(splash,x,y,0,sc,sc,offX,offY)
			end
		end
		lg.setColor(1,1,1,1)
	end
end

function splashy.update(dt)
	if splashy.finished == false then
		for i=1, #splashy.tweenlist do
			if splashy.count == i then
				local tweenComplete = splashy.tweenlist[i]:update(dt)
				if tweenComplete then
					if splashy.fadestate == "in" then
						splashy.tweenlist[i]:reset()
						splashy.fadestate = "out"
					elseif splashy.fadestate == "out" then
						splashy.tweenlist[i]:reset()
						splashy.count=splashy.count + 1
						splashy.fadestate="in"
					end
				end
			end
		end
		if splashy.count >= #splashy.list + 1 then
	assert(type(splashy.onCompleteFunction) == "function", "onComplete needs a valid function.")
			splashy.finished = true
			splashy.onCompleteFunction()
		end
	end
end

return splashy