-- [[ Cryptic Hub - Infinite Camera Zoom ]]
-- يسمح لك تبعد/تقرّب الكاميرا لأي مسافة بدون حدود
-- Localized via i18n. الكي: other.infinite_zoom.*

local i18n = getgenv().CrypticI18n
local T    = (i18n and i18n.T) or function(k) return k end

return function(Tab, UI)
    local Players     = game:GetService("Players")
    local StarterGui  = game:GetService("StarterGui")
    local RunService  = game:GetService("RunService")
    local lp          = Players.LocalPlayer

    local originalMin = lp.CameraMinZoomDistance
    local originalMax = lp.CameraMaxZoomDistance
    local enforceConn = nil

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title    = "Cryptic Hub",
                Text     = text,
                Duration = 3,
            })
        end)
    end

    local function applyInfinite()
        pcall(function()
            lp.CameraMinZoomDistance = 0.5
            lp.CameraMaxZoomDistance = math.huge
        end)
    end

    local function restoreOriginal()
        pcall(function()
            lp.CameraMinZoomDistance = originalMin or 0.5
            lp.CameraMaxZoomDistance = originalMax or 400
        end)
    end

    Tab:AddToggle(T("other.infinite_zoom.label"), function(state)
        if state then
            applyInfinite()
            -- إعادة فرض القيم باستمرار في حال السيرفر حاول يرجعها
            if enforceConn then enforceConn:Disconnect() end
            enforceConn = RunService.Heartbeat:Connect(function()
                if lp.CameraMaxZoomDistance ~= math.huge or lp.CameraMinZoomDistance > 0.5 then
                    applyInfinite()
                end
            end)
            Notify(T("other.infinite_zoom.on"))
        else
            if enforceConn then enforceConn:Disconnect() enforceConn = nil end
            restoreOriginal()
            Notify(T("other.infinite_zoom.off"))
        end
    end)

    -- لو غير الشخصية أعد تطبيق القيم لو الميزة مفعلة
    lp.CharacterAdded:Connect(function()
        task.wait(0.5)
        if enforceConn then applyInfinite() end
    end)
end
