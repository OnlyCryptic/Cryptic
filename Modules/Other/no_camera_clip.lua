-- [[ Cryptic Hub - No Camera Clip (Camera passes through walls) ]]
-- يخلي الكاميرا ما تتصادم بالجدران، تشوف اللاعب من خلال أي شيء
-- Localized via i18n. الكي: other.no_camera_clip.*

local i18n = getgenv().CrypticI18n
local T    = (i18n and i18n.T) or function(k) return k end

return function(Tab, UI)
    local Players     = game:GetService("Players")
    local StarterGui  = game:GetService("StarterGui")
    local RunService  = game:GetService("RunService")
    local lp          = Players.LocalPlayer

    local originalOcclusion = lp.DevCameraOcclusionMode
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

    local function applyNoClip()
        pcall(function()
            lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
        end)
    end

    local function restoreOriginal()
        pcall(function()
            lp.DevCameraOcclusionMode = originalOcclusion or Enum.DevCameraOcclusionMode.Zoom
        end)
    end

    Tab:AddToggle(T("other.no_camera_clip.label"), function(state)
        if state then
            -- خزّن القيمة الأصلية الحالية كل مرة عشان لو فيه ميزة ثانية غيّرتها
            originalOcclusion = lp.DevCameraOcclusionMode
            applyNoClip()
            -- فرض دائم لو شيء حاول يرجعها
            if enforceConn then enforceConn:Disconnect() end
            enforceConn = RunService.Heartbeat:Connect(function()
                if lp.DevCameraOcclusionMode ~= Enum.DevCameraOcclusionMode.Invisicam then
                    applyNoClip()
                end
            end)
            Notify(T("other.no_camera_clip.on"))
        else
            if enforceConn then enforceConn:Disconnect() enforceConn = nil end
            restoreOriginal()
            Notify(T("other.no_camera_clip.off"))
        end
    end)

    -- إعادة تطبيق بعد الموت/الـ respawn
    lp.CharacterAdded:Connect(function()
        task.wait(0.5)
        if enforceConn then applyNoClip() end
    end)
end
