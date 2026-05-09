-- [[ Cryptic Hub - Copy Skin V2.5 ]]

local Players    = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local lp         = Players.LocalPlayer

local COPIED_TAG = "_CrypticSkinCopy"

return function(Tab, UI)

    local i18n = getgenv().CrypticI18n
    local T = (i18n and i18n.T) or function(k) return k end

    local isActive = false

    local savedShirt       = nil
    local savedPants       = nil
    local savedTShirt      = nil
    local savedBodyColors  = nil
    local savedAccessories = {}
    local savedFace        = nil

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title    = "Cryptic Hub",
                Text     = text,
                Duration = 4,
            })
        end)
    end

    local function attachAccessory(myChar, acc)
        local handle = acc:FindFirstChild("Handle")
        if not handle then
            acc.Parent = myChar
            return
        end

        for _, w in pairs(handle:GetDescendants()) do
            if w:IsA("Weld") or w:IsA("WeldConstraint") then
                w:Destroy()
            end
        end

        acc.Parent = myChar
        local handleAtt = handle:FindFirstChildWhichIsA("Attachment")

        if handleAtt then
            for _, part in pairs(myChar:GetDescendants()) do
                if part:IsA("Attachment")
                    and part.Name == handleAtt.Name
                    and part.Parent ~= handle
                    and part.Parent:IsA("BasePart")
                then
                    handle.CFrame = part.Parent.CFrame
                        * part.CFrame
                        * handleAtt.CFrame:Inverse()
                    local wc = Instance.new("WeldConstraint")
                    wc.Part0 = handle
                    wc.Part1 = part.Parent
                    wc.Parent = handle
                    break
                end
            end
        else
            local head = myChar:FindFirstChild("Head")
            if head then
                handle.CFrame = head.CFrame
                local wc = Instance.new("WeldConstraint")
                wc.Part0  = handle
                wc.Part1  = head
                wc.Parent = handle
            end
        end
    end

    local function SaveOriginal(myChar)
        local sh = myChar:FindFirstChildWhichIsA("Shirt")
        savedShirt  = sh  and sh.ShirtTemplate  or ""

        local pa = myChar:FindFirstChildWhichIsA("Pants")
        savedPants  = pa  and pa.PantsTemplate  or ""

        local ts = myChar:FindFirstChildWhichIsA("ShirtGraphic")
        savedTShirt = ts  and ts.Graphic        or ""

        local bc = myChar:FindFirstChildWhichIsA("BodyColors")
        if bc then
            savedBodyColors = {
                HeadColor     = bc.HeadColor,
                TorsoColor    = bc.TorsoColor,
                LeftArmColor  = bc.LeftArmColor,
                RightArmColor = bc.RightArmColor,
                LeftLegColor  = bc.LeftLegColor,
                RightLegColor = bc.RightLegColor,
            }
        end

        savedAccessories = {}
        for _, acc in pairs(myChar:GetChildren()) do
            if acc:IsA("Accessory") then
                local clone = acc:Clone()
                clone.Parent = nil
                table.insert(savedAccessories, clone)
            end
        end

        local myHum = myChar:FindFirstChildOfClass("Humanoid")
        if myHum then
            local ok, desc = pcall(function() return myHum:GetAppliedDescription() end)
            if ok and desc then
                savedFace = desc.Face
            end
        end
    end

    local function ApplySkin(myChar, targetChar)
        for _, cls in ipairs({"Shirt","Pants","ShirtGraphic"}) do
            local obj = myChar:FindFirstChildWhichIsA(cls)
            if obj then obj:Destroy() end
        end

        for _, acc in pairs(myChar:GetChildren()) do
            if acc:IsA("Accessory") then acc:Destroy() end
        end

        for _, v in pairs(myChar:GetDescendants()) do
            pcall(function()
                if v:GetAttribute(COPIED_TAG) then v:Destroy() end
            end)
        end

        task.wait()

        for _, cls in ipairs({"Shirt","Pants","ShirtGraphic"}) do
            local src = targetChar:FindFirstChildWhichIsA(cls)
            if src then
                local clone = src:Clone()
                clone:SetAttribute(COPIED_TAG, true)
                clone.Parent = myChar
            end
        end

        local tBc = targetChar:FindFirstChildWhichIsA("BodyColors")
        local mBc = myChar:FindFirstChildWhichIsA("BodyColors")
        if tBc and mBc then
            mBc.HeadColor     = tBc.HeadColor
            mBc.TorsoColor    = tBc.TorsoColor
            mBc.LeftArmColor  = tBc.LeftArmColor
            mBc.RightArmColor = tBc.RightArmColor
            mBc.LeftLegColor  = tBc.LeftLegColor
            mBc.RightLegColor = tBc.RightLegColor
        end

        for _, acc in pairs(targetChar:GetChildren()) do
            if acc:IsA("Accessory") then
                local cloned = acc:Clone()
                cloned:SetAttribute(COPIED_TAG, true)
                pcall(function() attachAccessory(myChar, cloned) end)
            end
        end

        local tHum   = targetChar:FindFirstChildOfClass("Humanoid")
        local myHead = myChar:FindFirstChild("Head")
        if tHum and myHead then
            local ok, tDesc = pcall(function() return tHum:GetAppliedDescription() end)
            if ok and tDesc and tDesc.Face ~= 0 then
                local myMesh = myHead:FindFirstChildOfClass("SpecialMesh")
                if myMesh then
                    myMesh.TextureId = "rbxassetid://" .. tDesc.Face
                end
            end
        end

        local effectClasses = { "ParticleEmitter", "Fire", "Smoke", "Sparkles", "Highlight" }

        local tHL = targetChar:FindFirstChildWhichIsA("Highlight")
        if tHL then
            local clone = tHL:Clone()
            clone:SetAttribute(COPIED_TAG, true)
            clone.Parent = myChar
        end

        for _, part in pairs(targetChar:GetDescendants()) do
            if part:IsA("BasePart") then
                local myPart = myChar:FindFirstChild(part.Name)
                if myPart and myPart:IsA("BasePart") then
                    for _, eff in pairs(part:GetChildren()) do
                        for _, cls in ipairs(effectClasses) do
                            if eff:IsA(cls) then
                                local clonedEff = eff:Clone()
                                clonedEff:SetAttribute(COPIED_TAG, true)
                                clonedEff.Parent = myPart
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    local function RestoreSkin(myChar)
        for _, v in pairs(myChar:GetDescendants()) do
            pcall(function()
                if v:GetAttribute(COPIED_TAG) then v:Destroy() end
            end)
        end
        for _, acc in pairs(myChar:GetChildren()) do
            if acc:IsA("Accessory") and acc:GetAttribute(COPIED_TAG) then
                acc:Destroy()
            end
        end

        local function restoreClothing(className, propName, savedVal)
            local obj = myChar:FindFirstChildWhichIsA(className)
            if savedVal and savedVal ~= "" then
                if not obj then
                    obj = Instance.new(className)
                    obj.Parent = myChar
                end
                obj[propName] = savedVal
            else
                if obj then obj:Destroy() end
            end
        end

        restoreClothing("Shirt",        "ShirtTemplate", savedShirt)
        restoreClothing("Pants",        "PantsTemplate", savedPants)
        restoreClothing("ShirtGraphic", "Graphic",       savedTShirt)

        if savedBodyColors then
            local bc = myChar:FindFirstChildWhichIsA("BodyColors")
            if bc then
                bc.HeadColor     = savedBodyColors.HeadColor
                bc.TorsoColor    = savedBodyColors.TorsoColor
                bc.LeftArmColor  = savedBodyColors.LeftArmColor
                bc.RightArmColor = savedBodyColors.RightArmColor
                bc.LeftLegColor  = savedBodyColors.LeftLegColor
                bc.RightLegColor = savedBodyColors.RightLegColor
            end
        end

        if savedFace then
            local myHead = myChar:FindFirstChild("Head")
            if myHead then
                local myMesh = myHead:FindFirstChildOfClass("SpecialMesh")
                if myMesh then
                    myMesh.TextureId = "rbxassetid://" .. savedFace
                end
            end
        end

        task.wait()
        for _, acc in pairs(savedAccessories) do
            pcall(function()
                attachAccessory(myChar, acc)
            end)
        end

        savedShirt = nil; savedPants = nil; savedTShirt = nil
        savedBodyColors = nil; savedAccessories = {}; savedFace = nil
    end

    Tab:AddToggle(T("combat.copy_skin1.label"), function(active)
        isActive = active

        if active then
            local target = _G.ArwaTarget
            if not target or not target.Character then
                isActive = false
                Notify(T("combat.common.no_target"))
                return
            end

            local myChar     = lp.Character
            local targetChar = target.Character
            if not myChar or not targetChar then
                isActive = false
                return
            end

            SaveOriginal(myChar)
            ApplySkin(myChar, targetChar)
            Notify(string.format(T("combat.copy_skin1.on_fmt"), target.DisplayName))
        else
            local myChar = lp.Character
            if myChar then RestoreSkin(myChar) end
            Notify(T("combat.copy_skin1.off"))
        end
    end)

    lp.CharacterAdded:Connect(function(char)
        if not isActive then return end
        task.delay(1.5, function()
            local target = _G.ArwaTarget
            if not target or not target.Character then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then return end
            savedAccessories = {}
            SaveOriginal(char)
            ApplySkin(char, target.Character)
        end)
    end)
end
