-- Configuration
function love.conf(t)
	t.gammacorrect = false
	t.title, t.identity = "Kasaival", "Kasaival"
	t.version = "11.3"
	t.window.vsync = false
	t.window.icon='assets/icon.png'
	-- For Windows debugging
	t.console = false
end
