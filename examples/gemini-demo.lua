socket = require("socket")
socket.url = require("socket.url")
ssl = require("ssl")
pl = require("pl")

ssl_params = {
    mode = "client",
    protocol = "tlsv1_2"
}

links = {}
history = {}

while true do
    ::main_loop::
    io.write("> ")
    cmd = io.read()
    if string.lower(cmd) == "q" then
        io.write("Bye!\n")
        break
    elseif tonumber(cmd) ~= nil then
        url = links[tonumber(cmd)]
    elseif string.lower(cmd) == "b" then
        -- Yes, twice
        url = table.remove(history)
        url = table.remove(history)
    else
        url = cmd
    end
    
    -- Add scheme if missing
    if string.find(url, "://") == nil then
        url = "gemini://" .. url
    end
    -- Add empty path if needed
    if string.find(string.sub(url, 10, -1), "/") == nil then
        url = url .. "/"
    end
    ::parse_url::
    parsed_url = socket.url.parse(url)
    -- Open connection
    conn = socket.tcp()
    ret, str = conn:connect(parsed_url.host, 1965)
    if ret == nil then
        io.write(str) goto main_loop
    end
    conn, err = ssl.wrap(conn, ssl_params)
    if conn == nil then
        io.write(err) goto main_loop
    end
    conn:dohandshake()
    -- Send request
    conn:send(url .. "\r\n")
    -- Parse response header
    header = conn:receive("*l")
    status, meta = table.unpack(utils.split(header, "%s+", false, 2))
    -- Handle sucessful response
    if string.sub(status, 1, 1) == "2" then
	if meta == "text/gemini" then
	    --  Handle Geminimap
            links = {}
	    preformatted = false
            while true do
                line, err = conn:receive("*l")
                if line ~= nil then
		    if string.sub(line,1,3) == "```" then
			preformatted = not preformatted
		    elseif preformatted then
			io.write(line .. "\n")
		    elseif string.sub(line,1,2) == "=>" then
			line = string.sub(line,3,-1) -- Trim off =>
			line = string.gsub(line,"^%s+","") -- Trim spaces
                        link_url, label = table.unpack(utils.split(line, "%s+", false, 2))
                        if label == nil then label = link_url end
                        table.insert(links, socket.url.absolute(url, link_url))
                        io.write("[" .. #links .. "] " .. label .. "\n")
                    else
                        io.write(text.fill(line))
                    end
                else
                    break
                end
	    end
	elseif string.sub(meta, 1, 5) == "text/" then
	    -- Print text
            while true do
                line, err = conn:receive("*l")
                if line ~= nil then
                        io.write(line .. "\n")
                else
                    break
                end
	    end
        end
    -- Handle redirects
    elseif string.sub(status, 1, 1) == "3" then
        url = socket.url.absolute(url, meta)
        goto parse_url
    -- Handle errors
    elseif string.sub(status, 1, 1) == "4" or string.sub(status, 1, 1) == "5" then
        io.write("Error: " .. meta)
    elseif string.sub(status, 1, 1) == "6" then
        io.write("Client certificates not supported.")
    else
        io.write("Invalid response from server.")
    end
    table.insert(history, url)
end
