--[[
    Original module was made by: BIack1st,
    
    Made with 💕 by BIack1st & TheH0melands
    ]]
    
local RunService = game:GetService("RunService")

local module = {}

local validMethods = {
    "range",
    "part",
    "box"
}

type hitboxSettings = {
   
}

local function generateHitbox(currentSettings)
    local method = currentSettings.Method:lower()

    if method ==  "range" then
        local range = currentSettings.Range or error("Range must be specified")
        local origin = currentSettings.Origin or error("Origin must be specified")
        local hitboxObject = workspace:GetPartBoundsInRadius(origin, range)

        return hitboxObject
    elseif method == "box" then
        local cframe = currentSettings.CFrame or error("CFrame must be specified")
        local size = currentSettings.Size or error("Size must be specified")
        local params = currentSettings.Params

        local hitboxObject = workspace:GetPartBoundsInBox(cframe, size, params)

        return hitboxObject
    elseif method == "part" then
        local part = currentSettings.Part or error("Part must be specified")
        local params = currentSettings.Params

        local hitboxObject = workspace:GetPartsInPart(part, params)

        return hitboxObject
    end
end

function module:CreateHitbox(hitboxSettings)
    if not hitboxSettings or typeof(hitboxSettings) ~= "table" then error(string.format("Expected table for hitbox settings, got %s", typeof(hitboxSettings))) return end
    if not hitboxSettings.Method then error("Method must be specified") return end
    if not table.find(validMethods, hitboxSettings.Method:lower()) then error("Specifed method is invalid.") end

    local hitbox = setmetatable({}, {})

    local stoppedEvent = Instance.new("BindableEvent")
    local startedEvent = Instance.new("BindableEvent")
    local touchedEvent = Instance.new("BindableEvent")
    local updatedEvent = Instance.new("BindableEvent")
   
    hitbox.Stopped = stoppedEvent.Event
    hitbox.Started = startedEvent.Event
    hitbox.Touched = touchedEvent.Event
    hitbox.Updated = updatedEvent.Event

    local started = false

    local connections = {}

    local function disconnectConnections()
       for _, connection in pairs(connections) do
            if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()

                connections[connection] = nil
            end
       end
    end

    local function startConnections()
    
        local function touched()
            local success, err = pcall(function()
                if started then
                    local currentSettings = hitbox._settings
    
                    local hitboxObject = generateHitbox(currentSettings)
    
                    for _, obj in ipairs(hitboxObject) do 
                        if table.find(generateHitbox(currentSettings), obj) then
                            touchedEvent:Fire(obj)
                        end
                    end              
                end
            end)
            if not success then
                disconnectConnections()
                error(err)
            end
            
        end
        
        local touchedConnection = RunService.Heartbeat:Connect(touched)

        table.insert(connections, touchedConnection)
    end

    function hitbox:GetState()
        return started
    end

    function hitbox:Stop()
        started = false

        disconnectConnections()

        stoppedEvent:Fire()
    end

    function hitbox:Start()
        started = true

        startConnections()

        startedEvent:Fire()
    end
    
    function hitbox:Update(new)
        local oldSettings = self._settings

        self._settings = new

        updatedEvent:Fire(oldSettings, new)
    end
    
    hitbox._settings = hitboxSettings
    

    return hitbox
end

return module