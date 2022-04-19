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
    Origin:Vector3,
    Range: number,
    Params: OverlapParams? 
}

local function generateHitbox(currentSettings, backupType)
    local method = currentSettings.method or backupType

    if method:lower() ==  "range" then
        local range = currentSettings.Range
        local origin = currentSettings.Origin
        local hitboxObject = workspace:GetPartBoundsInRadius(origin, range)

        return hitboxObject
    end
end

function module:CreateHitbox(hitboxType:string, hitboxSettings)

    local hitbox = setmetatable({}, {})

    local stoppedEvent = Instance.new("BindableEvent")
    local startedEvent = Instance.new("BindableEvent")
    local touchedEvent = Instance.new("BindableEvent")
    local updatedEvent = Instance.new("BindableEvent")

    hitbox.Stopped = stoppedEvent.Event
    hitbox.Started = startedEvent.Event
    hitbox.Touched = touchedEvent.Event

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
            if started then
                local currentSettings = hitbox._settings
                local method = currentSettings.method or hitboxType

                if method:lower() ==  "range" then
                    local range = currentSettings.Range
                    local origin = currentSettings.Origin 

                    local hitboxObject = generateHitbox(currentSettings, method)

                    for _, obj in ipairs(hitboxObject) do 
                        if table.find(generateHitbox(currentSettings, method), obj) then
                            touchedEvent:Fire(obj)
                        end
                    end
                end               
            end
        end
        
        local touchedConnection = RunService.Heartbeat:Connect(touched)

        table.insert(connections, touchedConnection)
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

        self.Updated:Fire(oldSettings, new)
    end
    
    hitbox._settings = hitboxSettings
    

    return hitbox
end

return module