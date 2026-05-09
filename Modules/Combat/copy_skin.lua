-- [[ Cryptic Hub - Copy Target Character ]]

return function(Tab, UI)
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    local i18n = getgenv().CrypticI18n
    local T = (i18n and i18n.T) or function(k) return k end

    local isCopied = false
    local originalChar = nil
    local originalCFrame = nil

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = text,
                Duration = 3
            })
        end)
    end

    Tab:AddToggle(T("combat.copy_skin.label"), function(active)
        if active then
            local target = _G.ArwaTarget
            if not target or not target.Character then
                Notify(T("combat.common.no_target"))
                return
            end

            local myChar = lp.Character
            if not myChar then return end

            local myRoot = myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end

            originalCFrame = myRoot.CFrame
            originalChar = myChar

            local cloned = target.Character:Clone()
            for _, v in pairs(cloned:GetDescendants()) do
                if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
                    v:Destroy()
                end
            end

            local animate = cloned:FindFirstChild("Animate")
            if animate then animate:Destroy() end

            cloned.Name = myChar.Name
            cloned.Parent = workspace

            local clonedRoot = cloned:FindFirstChild("HumanoidRootPart")
            if clonedRoot then
                clonedRoot.CFrame = originalCFrame
            end

            for _, v in pairs(myChar:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("Decal") then
                    v.Transparency = 1
                end
            end

            local cam = workspace.CurrentCamera
            cam.CameraSubject = cloned:FindFirstChildOfClass("Humanoid") or clonedRoot

            isCopied = true
            Notify(string.format(T("combat.copy_skin.on_fmt"), target.DisplayName))
        else
            isCopied = false
            local function restore()
                local myChar = lp.Character
                if myChar then
                    for _, v in pairs(myChar:GetDescendants()) do
                        if v:IsA("BasePart") then v.Transparency = 0 end
                        if v:IsA("Decal") then v.Transparency = 0 end
                    end
                end

                for _, v in pairs(workspace:GetChildren()) do
                    if v.Name == lp.Name and v ~= lp.Character then
                        v:Destroy()
                    end
                end

                local cam = workspace.CurrentCamera
                local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
                if hum then cam.CameraSubject = hum end

                local root = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if root and originalCFrame then
                    root.CFrame = originalCFrame
                end
            end

            restore()
            Notify(T("combat.copy_skin.off"))
        end
    end)

    Tab:AddLine()
end
