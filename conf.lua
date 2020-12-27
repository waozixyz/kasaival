-- Configuration
function love.conf(t)
	t.gammacorrect = true
	t.title, t.identity = "Kasaival", "Minimal"
	t.version = "11.3"
	t.window.vsync = false
 	t.window.borderless=true
	t.window.resizable=true 
	t.window.width=800
	t.window.height=600
	t.window.icon='icon.png'
	-- For Windows debugging
	t.console = false
end
