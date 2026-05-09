-- [[ Cryptic Hub - Map X-Ray (Anti-Crash & Smooth) ]]
local Players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

return function(Tab, UI)
    local i18n = getgenv().CrypticI18n
    local T = (i18n and i18n.T) or function(k) return k end

    local isXRayOn = false
    local xrayTransparency = 0.5
    local originalTransparencies = {}

    local function Notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=3})
        end)
    end

    local function IsPlayerPart(part)
        if part:IsDescendantOf(workspace.CurrentCamera) then return true end
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and part:IsDescendantOf(player.Character) then
                return true
            end
        end
        return false
    end

    local function EnableXRay()
        isXRayOn = true
        local partsScanned = 0

        for _, v in ipairs(workspace:GetDescendants()) do
            if not isXRayOn then break end
            if v:IsA("BasePart") and v.Name ~= "Terrain" and not IsPlayerPart(v) then
                if not originalTransparencies[v] then
                    originalTransparencies[v] = v.Transparency
                end
                v.Transparency = xrayTransparency
            end
            partsScanned = partsScanned + 1
            if partsScanned % 1000 == 0 then task.wait() end
        end
    end

    local function DisableXRay()
        isXRayOn = false
        for part, originalTrans in pairs(originalTransparencies) do
            if part and part.Parent then
                part.Transparency = originalTrans
            end
        end
        originalTransparencies = {}
    end

    Tab:AddSpeedControl(T("misc.xray.label"), function(active, value)
        xrayTransparency = math.clamp(value, 1, 100) / 100
        if active then
            Notify("Cryptic Hub 👁️", T("misc.xray.enabling"))
            EnableXRay()
            if isXRayOn then
                Notify(T("misc.xray.enabled_title"), T("misc.xray.enabled_text"))
            end
        else
            if isXRayOn then
                DisableXRay()
                Notify(T("misc.xray.disabled_title"), T("misc.xray.disabled_text"))
            end
        end
    end, 50, 100)
end
