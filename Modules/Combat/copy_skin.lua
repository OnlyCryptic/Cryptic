-- [[ Cryptic Hub - نسخ شخصية الهدف / Copy Target Character ]]
-- يظهر لك أنت بس بشخصية الهدف كامل

return function(Tab, UI)
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    local isCopied = false
    local originalChar = nil
    local originalCFrame = nil

    local function Notify(ar, en)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = ar .. "\n" .. en,
                Duration = 3
            })
        end)
    end

    Tab:AddToggle("نسخ شخصية الهدف / Copy Skin", function(active)
        if active then
            local target = _G.ArwaTarget
            if not target or not target.Character then
                Notify("⚠️ حدد لاعباً أولاً!", "⚠️ Select a player first!")
                return
            end

            local myChar = lp.Character
            if not myChar then return end

            local myRoot = myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end

            -- احفظ موقعك الحالي
            originalCFrame = myRoot.CFrame

            -- احفظ شخصيتك الأصلية
            originalChar = myChar

            -- نسخ شخصية الهدف
            local cloned = target.Character:Clone()

            -- شيل السكربتات
            for _, v in pairs(cloned:GetDescendants()) do
                if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
                    v:Destroy()
                end
            end

            -- شيل الـ Animate script عشان ما يتعارض
            local animate = cloned:FindFirstChild("Animate")
            if animate then animate:Destroy() end

            -- حط النسخة في workspace مكان شخصيتك
            cloned.Name = myChar.Name
            cloned.Parent = workspace

            -- انقل موقعك للنسخة
            local clonedRoot = cloned:FindFirstChild("HumanoidRootPart")
            if clonedRoot then
                clonedRoot.CFrame = originalCFrame
            end

            -- اخفي شخصيتك الأصلية
            for _, v in pairs(myChar:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("Decal") then
                    v.Transparency = 1
                end
            end

            -- خلي الكاميرا تتبع النسخة
            local cam = workspace.CurrentCamera
            cam.CameraSubject = cloned:FindFirstChildOfClass("Humanoid") or clonedRoot

            isCopied = true
            Notify("✅ تم نسخ شخصية: " .. target.DisplayName, "✅ Copied: " .. target.DisplayName)

        else
            -- إرجاع شخصيتك الأصلية
            isCopied = false

            -- اعمل ريستارت لشخصيتك
            local function restore()
                -- أظهر شخصيتك الأصلية
                local myChar = lp.Character
                if myChar then
                    for _, v in pairs(myChar:GetDescendants()) do
                        if v:IsA("BasePart") then v.Transparency = 0 end
                        if v:IsA("Decal") then v.Transparency = 0 end
                    end
                end

                -- احذف أي نسخ مزيفة
                for _, v in pairs(workspace:GetChildren()) do
                    if v.Name == lp.Name and v ~= lp.Character then
                        v:Destroy()
                    end
                end

                -- أعد الكاميرا
                local cam = workspace.CurrentCamera
                local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
                if hum then cam.CameraSubject = hum end

                -- ارجع لموقعك
                local root = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if root and originalCFrame then
                    root.CFrame = originalCFrame
                end
            end

            restore()
            Notify("🔄 تم الإلغاء وإرجاع شخصيتك", "🔄 Restored your character")
        end
    end)

    Tab:AddLine()
end
