-- [[ Cryptic Hub - Map: Fling Things and People (Optimized & Enhanced) ]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Remotes & References
local menuToys = ReplicatedStorage:FindFirstChild("MenuToys")
local spawnToyRF = menuToys and menuToys:FindFirstChild("SpawnToyRemoteFunction")
local buyToyRF = menuToys and menuToys:FindFirstChild("BuyToyRemoteFunction")

local characterEvents = ReplicatedStorage:FindFirstChild("CharacterEvents")
local ragdollRemote = characterEvents and characterEvents:FindFirstChild("RagdollRemote")

-- State Connections
local noclipConn = nil
local antiGrabConn = nil
local antiRagdollConn = nil
local flyConn = nil

return {
    Name = "Fling Things and People",

    Render = function(tab)
        ------------------------------------------------------------------------
        -- 1. لوحة معلومات خفيفة ومبتكرة
        ------------------------------------------------------------------------
        tab:AddParagraph("Cryptic Hub | FTAP", "نظام الحماية والتحكم المتقدم بالجلسة")

        local statusLabel = tab:AddLabel("الحالة: جاري التحميل...")

        local function updateStatus()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hp = hum and math.floor(hum.Health) or 0
            local maxHp = hum and math.floor(hum.MaxHealth) or 100
            
            local spawnedToys = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
            local toyCount = spawnedToys and #spawnedToys:GetChildren() or 0

            statusLabel:SetText(string.format("الصحة: %d/%d | الألعاب المفعّلة: %d | اللاعبين: %d", hp, maxHp, toyCount, #Players:GetPlayers()))
        end

        ------------------------------------------------------------------------
        -- 2. ميزات الحماية والتصدي (Self Defense & Anti-Tools)
        ------------------------------------------------------------------------
        tab:AddParagraph("الحماية الشخصية / Protection", "تفعيل الحمايات ضد اللاعبين الآخرين")

        -- Anti-Grab: تدمير أي لحام (Weld) يربط شخصيتك بأي لاعب أو جسم خيالي
        tab:AddToggle("منع المسك والتطيير / Anti-Grab", false, function(enabled)
            if enabled then
                if not antiGrabConn then
                    antiGrabConn = RunService.Heartbeat:Connect(function()
                        local char = LocalPlayer.Character
                        if not char then return end

                        -- فحص الأجسام الممسوكة في الماب
                        local grabParts = Workspace:FindFirstChild("GrabParts")
                        if grabParts then
                            for _, grab in ipairs(grabParts:GetChildren()) do
                                for _, weld in ipairs(grab:GetDescendants()) do
                                    if weld:IsA("WeldConstraint") or weld:IsA("Weld") then
                                        if (weld.Part0 and weld.Part0:IsDescendantOf(char)) or (weld.Part1 and weld.Part1:IsDescendantOf(char)) then
                                            weld:Destroy()
                                        end
                                    end
                                end
                            end
                        end

                        -- فحص أي ملحقات دخلت الشخصية
                        for _, item in ipairs(char:GetDescendants()) do
                            if item:IsA("WeldConstraint") or item:IsA("RopeConstraint") then
                                item:Destroy()
                            end
                        end
                    end)
                end
            elseif antiGrabConn then
                antiGrabConn:Disconnect()
                antiGrabConn = nil
            end
        end)

        -- Anti-Ragdoll: إلغاء حظر الحركة والتساقط
        tab:AddToggle("منع السقوط / Anti-Ragdoll", false, function(enabled)
            if enabled then
                if not antiRagdollConn then
                    antiRagdollConn = RunService.Stepped:Connect(function()
                        local char = LocalPlayer.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                        end
                    end)
                end
            elseif antiRagdollConn then
                antiRagdollConn:Disconnect()
                antiRagdollConn = nil
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                end
            end
        end)

        ------------------------------------------------------------------------
        -- 3. ميزات الحركة والتنقل (Mobility & Physics)
        ------------------------------------------------------------------------
        tab:AddParagraph("الحركة والسرعة / Movement", "أدوات الانتقال والتطير في الخريطة")

        -- الانتقال الفوري للأمام عبر Raycast المطور
        tab:AddButton("انتقال لمكان النظر / TP to Look Vector", function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local cam = Workspace.CurrentCamera

            if hrp and cam then
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {char}
                rayParams.FilterType = Enum.RaycastFilterType.Exclude

                local result = Workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * 1000, rayParams)
                if result then
                    hrp.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
                end
            end
        end)

        -- اختراق الجدران (Noclip)
        tab:AddToggle("اختراق الجدران / Noclip", false, function(enabled)
            if enabled then
                if not noclipConn then
                    noclipConn = RunService.Stepped:Connect(function()
                        local char = LocalPlayer.Character
                        if char then
                            for _, part in ipairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end)
                end
            elseif noclipConn then
                noclipConn:Disconnect()
                noclipConn = nil
            end
        end)

        ------------------------------------------------------------------------
        -- 4. ميزات التحكم بالأغراض والمسك (Object & Fling Powers)
        ------------------------------------------------------------------------
        tab:AddParagraph("قوة المسك والرمي / Grab & Fling", "التحكم العالي بالأغراض واللاعبين")

        -- تثبيت / فك تثبيت الجسم الممسوك حالياً
        tab:AddButton("تثبيت/فك تثبيت الجسم الممسوك / Toggle Anchor Held", function()
            local grabParts = Workspace:FindFirstChild("GrabParts")
            if grabParts then
                for _, grab in ipairs(grabParts:GetChildren()) do
                    local weld = grab:FindFirstChildOfClass("WeldConstraint")
                    if weld and weld.Part1 and not weld.Part1:IsDescendantOf(Workspace.Map) then
                        weld.Part1.Anchored = not weld.Part1.Anchored
                    end
                end
            end
        end)

        -- رمي/تطيير خارق للجسم الممسوك
        tab:AddButton("تطيير خارق للجسم الممسوك / Super Fling Held", function()
            local grabParts = Workspace:FindFirstChild("GrabParts")
            if grabParts then
                for _, grab in ipairs(grabParts:GetChildren()) do
                    local weld = grab:FindFirstChildOfClass("WeldConstraint")
                    if weld and weld.Part1 then
                        local part = weld.Part1
                        part.AssemblyLinearVelocity = Vector3.new(0, 10000, 0)
                        part.AssemblyAngularVelocity = Vector3.new(5000, 5000, 5000)
                    end
                end
            end
        end)

        ------------------------------------------------------------------------
        -- 5. رسبنة الأدوات والقنابل (Advanced Toy Spawner)
        ------------------------------------------------------------------------
        tab:AddParagraph("رسبنة الألعاب القوية / Toy Spawner", "رسبنة ألعاب متطورة وقنابل فورية")

        local function spawnToy(toyName)
            local char = LocalPlayer.Character
            local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"))
            if not hrp then return end

            pcall(function()
                if buyToyRF then buyToyRF:InvokeServer(toyName) end
                if spawnToyRF then
                    spawnToyRF:InvokeServer({
                        toyName,
                        hrp.CFrame * CFrame.new(0, 2, -5),
                        Vector3.new(0, hrp.Orientation.Y, 0)
                    })
                end
            end)
        end

        tab:AddButton("رسبنة قنبلة / Spawn Bomb", function() spawnToy("Bomb") end)
        tab:AddButton("رسبنة كوناي / Spawn Ninja Kunai", function() spawnToy("NinjaKunai") end)
        tab:AddButton("رسبنة موزة / Spawn Banana", function() spawnToy("FoodBanana") end)

        ------------------------------------------------------------------------
        -- الحلقة التكرارية لتحديث البيانات
        ------------------------------------------------------------------------
        task.spawn(function()
            while tab.Page and tab.Page.Parent do
                pcall(updateStatus)
                task.wait(1.5)
            end
        end)
    end
}
