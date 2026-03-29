-- [[ Cryptic Hub - ريستارت / Restart ]]
-- يقتل الشخصية بكل طريقة ممكنة + ينطفي تلقائياً عند الموت

return function(Tab, UI)
    local Players    = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp         = Players.LocalPlayer

    local function Notify(ar, en)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title    = "Cryptic Hub",
                Text     = ar .. "\n" .. en,
                Duration = 3,
            })
        end)
    end

    local function ForceKill()
        local char = lp.Character
        if not char then
            pcall(function() lp:LoadCharacter() end)
            return
        end

        local hum  = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")

        -- 1. تصفير الصحة مباشرة
        if hum then
            pcall(function() hum.Health = 0 end)
        end

        -- 2. إذا ما نجحت الأولى خلال 0.15 ثانية → LoadCharacter
        task.delay(0.15, function()
            local c   = lp.Character
            local h   = c and c:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then
                pcall(function() lp:LoadCharacter() end)
            end
        end)

        -- 3. تدمير HumanoidRootPart (يبايبس أي anti-die)
        task.delay(0.3, function()
            local c = lp.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if r then pcall(function() r:Destroy() end) end
        end)

        -- 4. آخر حل: LoadCharacter قسري
        task.delay(0.5, function()
            local c = lp.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if (h and h.Health > 0) or not c then
                pcall(function() lp:LoadCharacter() end)
            end
        end)
    end

    --[[
        AddAutoOffToggle:
        - ينطفي تلقائياً عند الموت (مدمج في العنصر)
        - المستخدم يشغّله → يصير الريستارت → يموت → ينطفي لوحده
    ]]
    Tab:AddAddAutoOffToggle("ريستارت (تقتل نفسك) / Restart (die)", function(active)
        if active then
            Notify(" جاري الريستارت...", " Restarting character...")
            ForceKill()
        end
    end)
end
