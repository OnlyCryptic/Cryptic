local HttpService = game:GetService("HttpService")

local CrypticLoader = {}
CrypticLoader.URL = "https://raw.githubusercontent.com/VR7ss/OMK/refs/heads/main/VR7-ON-TOP"

function CrypticLoader:FetchScript()
    local success, response = pcall(function()
        return game:HttpGet(self.URL)
    end)

    if success and response then
        return response
    else
        warn("Failed to fetch script.")
        return nil
    end
end

function CrypticLoader:Execute()
    local scriptData = self:FetchScript()

    if scriptData then
        local compiledFunction, compileError = loadstring(scriptData)

        if compiledFunction then
            local runSuccess, runError = pcall(compiledFunction)

            if not runSuccess then
                warn("Runtime Error: " .. tostring(runError))
            end
        else
            warn("Compile Error: " .. tostring(compileError))
        end
    end
end

local Startup = {}

function Startup:Initialize()
    print("Initializing Cryptic Loader...")
    
    task.wait(0.5)

    CrypticLoader:Execute()

    print("Execution Complete.")
end

Startup:Initialize()