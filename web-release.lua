#!/usr/bin/env lua

-- Set variables
local head_file = "tpl/head.html"
local body_file = "tpl/body.html"
local release_dir = "releases/web"

-- Create release directory 
os.execute("mkdir -p " .. release_dir)

-- Build project
os.execute("npx love.js " .. arg[1] .. " " .. release_dir .. " -c -t " .. arg[2] .. " -m 52428800")
os.execute("cp tpl/style.css " .. release_dir .. "/theme/love.css")

local file = io.open(release_dir .. "/index.html", "r")
local index_content = file:read("*all")
file:close()

-- Load header and body contents from files
local head_content = assert(io.open(head_file, "r")):read("*all")
local body_content = assert(io.open(body_file, "r")):read("*all")

local start_index, end_index = string.find(index_content, "<center>.*</center>")
if start_index ~= nil and end_index ~= nil then
    index_content = string.gsub(index_content, "<footer>.-</footer>", "")

    local new_content = head_content .. "\n" .. body_content .. string.sub(index_content, end_index + 1)

    local file = io.open(release_dir .. "/index.html", "w")
    file:write(new_content)
    file:close()
end

os.execute("cd " .. release_dir .. " && ran")
