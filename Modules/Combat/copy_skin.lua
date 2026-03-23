-- [[ Cryptic Hub - نسخ السكن / Copy Skin ]]
-- يعيد تشغيل شخصيتك ويحطك مكان الهدف

return function(Tab, UI)
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    local function Notify(ar, en)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = ar .. "\n" .. en,
                Duration = 4
            })
        end)
    end

    Tab:AddButton("نسخ سكن الهدف / Copy Skin", function()
        local target = _G.ArwaTarget
        if not target or not target.Character then
            Notify("⚠️ حدد لاعباً أولاً!", "⚠️ Select a player first!")
            return
        end

        local tgtRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if not tgtRoot then
            Notify("⚠️ ما لقيت موقع الهدف!", "⚠️ Target position not found!")
            return
        end

        -- نحفظ موقع الهدف قبل الريستارت
        local targetPos = tgtRoot.CFrame

        Notify("🔄 جاري نسخ السكن...", "🔄 Copying skin...")

        -- نحط كود الانتقال قبل الريستارت
        local queue_tp = queue_on_teleport or (syn and syn.queue_on_teleport) or (getgenv and getgenv().queue_on_teleport)
        if queue_tp then
            -- بعد الريستارت ينتقل لموقع الهدف
            local x, y, z = targetPos.X, targetPos.Y, targetPos.Z
            queue_tp(([[
                task.wait(1)
                local lp = game.Players.LocalPlayer
                local char = lp.Character or lp.CharacterAdded:Wait()
                local root = char:WaitForChild("HumanoidRootPart", 5)
                if root then
                    root.CFrame = CFrame.new(%s, %s, %s)
                end
            ]]):format(x, y, z))
        end

        -- ريستارت الشخصية
        lp:LoadCharacter()
    end)

    Tab:AddLine()
end
