-- Configuration
function love.conf(t)
	t.gammacorrect = true
	t.title, t.identity = "Kasaival", "Kasaival"
	t.version = "11.3"
	t.window.vsync = false
 	t.window.borderless=true
	t.window.resizable=false
	t.window.width=640
	t.window.height=480
	t.window.icon='icon.png'
	-- For Windows debugging
	t.console = false
end
