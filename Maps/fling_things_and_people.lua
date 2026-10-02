-- [[ Cryptic Hub - Map: Fling Things and People ]]
-- Enhanced status panel & game utilities module.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Remotes & References
local menuToys = ReplicatedStorage:FindFirstChild("MenuToys")
local spawnToyRF = menuToys and menuToys:FindFirstChild("SpawnToyRemoteFunction")
local buyToyRF = menuToys and menuToys:FindFirstChild("BuyToyRemoteFunction")

local characterEvents = ReplicatedStorage:FindFirstChild("CharacterEvents")
local ragdollRemote = characterEvents and characterEvents:FindFirstChild("RagdollRemote")

local function getValueObjectValue(parent, name)
    local valueObject = parent and parent:FindFirstChild(name)
    if not valueObject then
        return nil
    end

    local ok, value = pcall(function()
        return valueObject.Value
    end)
    if ok then
        return value
    end
    return nil
end

local function formatNumber(value)
    if type(value) == "number" then
        return tostring(math.floor(value))
    end
    return "غير متاح / N/A"
end

return {
    Name = "Fling Things and People",

    Render = function(tab)
        local localPlayer = Players.LocalPlayer

        -- Panel 1: Map & Player Info
        tab:AddParagraph(
            "معلومات الماب / Map info",
            "Fling Things and People\nPlace ID: 6961824067  |  Universal ID: 2668101271"
        )
        tab:AddParagraph(
            "حالة اللاعب / Player status",
            "معلومات للقراءة فقط وأدوات التحكم في الجلسة الحالية."
        )

        local playerCountLabel = tab:AddLabel("اللاعبون / Players: —")
        local plotLabel = tab:AddLabel("البلوت / Plot: —")
        local toyCountLabel = tab:AddLabel("الألعاب المنشأة / Toys: —")
        local characterLabel = tab:AddLabel("الشخصية / Character: —")
        local refreshedAtLabel = tab:AddLabel("آخر تحديث / Updated: —")

        local function refreshStatus()
            local playerCount = #Players:GetPlayers()
            local maxPlayers = Players.MaxPlayers
            playerCountLabel:SetText(
                "اللاعبون / Players: " .. playerCount .. " / " .. tostring(maxPlayers)
            )

            local inPlot = getValueObjectValue(localPlayer, "InPlot")
            local plotStatus
            if inPlot == true then
                plotStatus = "داخل البلوت / In plot"
            elseif inPlot == false then
                plotStatus = "ليس داخل البلوت / Not in plot"
            else
                plotStatus = "غير متاح / N/A"
            end
            plotLabel:SetText("البلوت / Plot: " .. plotStatus)

            local spawnedToys = Workspace:FindFirstChild(localPlayer.Name .. "SpawnedInToys")
            local toyCount = spawnedToys and #spawnedToys:GetChildren() or 0
            local toyLimit = getValueObjectValue(localPlayer, "ToysLimitCap")
            toyCountLabel:SetText(
                "الألعاب المنشأة / Toys: "
                    .. tostring(toyCount)
                    .. " / "
                    .. formatNumber(toyLimit)
            )

            local character = localPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                characterLabel:SetText(
                    "الصحة / Health: "
                        .. formatNumber(humanoid.Health)
                        .. " / "
                        .. formatNumber(humanoid.MaxHealth)
                        .. "  |  WalkSpeed: "
                        .. formatNumber(humanoid.WalkSpeed)
                )
            else
                characterLabel:SetText("الشخصية / Character: غير متاحة / N/A")
            end

            refreshedAtLabel:SetText(
                "آخر تحديث / Updated: " .. os.date("%H:%M:%S")
            )
        end

        tab:AddButton("تحديث المعلومات / Refresh status", refreshStatus)

        -- Panel 2: Movement & Player Hacks
        tab:AddParagraph("التنقل والخصائص / Movement & Utilities", "ميزات التحكم بالشخصية والحركة")

        tab:AddButton("تنقل للأمام / Teleport Forward", function()
            local character = localPlayer.Character
            if not character then return end
            local camPart = character:FindFirstChild("CamPart") or Workspace.CurrentCamera
            local hrp = character:FindFirstChild("HumanoidRootPart")

            if camPart and hrp then
                local ray = Ray.new(camPart.Position, camPart.CFrame.LookVector * 5000)
                local hitPart, hitPos = Workspace:FindPartOnRayWithIgnoreList(ray, {character})
                if hitPart then
                    hrp.CFrame = CFrame.new(hitPos.X, hitPos.Y + 5, hitPos.Z)
                end
            end
        end)

        local noclipConn = nil
        tab:AddToggle("اختراق الجدران / Noclip", false, function(enabled)
            if enabled then
                if not noclipConn then
                    noclipConn = RunService.Stepped:Connect(function()
                        local char = localPlayer.Character
                        if char then
                            for _, part in ipairs(char:GetDescendants()) do
                                if part:IsA("BasePart") and part.CanCollide then
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

        local ragdollConn = nil
        tab:AddToggle("منع الـ Ragdoll / Anti-Ragdoll", false, function(enabled)
            if enabled then
                if not ragdollConn then
                    ragdollConn = RunService.Heartbeat:Connect(function()
                        local char = localPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp and ragdollRemote then
                            pcall(function()
                                ragdollRemote:FireServer(hrp, 0)
                            end)
                        end
                    end)
                end
            elseif ragdollConn then
                ragdollConn:Disconnect()
                ragdollConn = nil
            end
        end)

        -- Panel 3: Objects & Toys Controls
        tab:AddParagraph("الأغراض والألعاب / Objects & Toys", "التحكم بالأغراض ورسبنة الألعاب")

        tab:AddButton("تثبيت الغرض الممسوك / Anchor Held Part", function()
            local grabParts = Workspace:FindFirstChild("GrabParts")
            if grabParts and grabParts:FindFirstChild("GrabPart") then
                local weld = grabParts.GrabPart:FindFirstChild("WeldConstraint")
                if weld and weld.Part1 then
                    local part = weld.Part1
                    if not part:IsDescendantOf(Workspace.Map) then
                        part.Anchored = not part.Anchored
                    end
                end
            end
        end)

        local function quickSpawn(toyName)
            local char = localPlayer.Character
            local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("CamPart"))
            if not hrp then return end

            if buyToyRF then
                pcall(function() buyToyRF:InvokeServer(toyName) end)
            end
            if spawnToyRF then
                pcall(function()
                    spawnToyRF:InvokeServer({
                        toyName,
                        hrp.CFrame,
                        Vector3.new(0, hrp.Orientation.Y, 0)
                    })
                end)
            end
        end

        tab:AddButton("رسبنة كوناي / Spawn Ninja Kunai", function() quickSpawn("NinjaKunai") end)
        tab:AddButton("رسبنة بخاخ / Spawn Spray Can", function() quickSpawn("SprayCanWD") end)
        tab:AddButton("رسبنة موزة / Spawn Banana", function() quickSpawn("FoodBanana") end)

        -- Panel 4: Entity & Camera View
        tab:AddParagraph("مراقبة الكائنات / Entity View", "التركيز والتحكم برؤية الكائنات")

        tab:AddButton("التركيز على الهدف / Focus Target", function()
            local char = localPlayer.Character
            if not char then return end
            local head = char:FindFirstChild("Head")
            if not head then return end

            local camera = Workspace.CurrentCamera
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {char}
            params.FilterType = Enum.RaycastFilterType.Exclude

            local result = Workspace:Raycast(head.Position, camera.CFrame.LookVector * 150, params)
            if result and result.Instance then
                local model = result.Instance:FindFirstAncestorOfClass("Model")
                local hum = model and model:FindFirstChildOfClass("Humanoid")
                if hum then
                    camera.CameraSubject = hum
                end
            end
        end)

        tab:AddButton("إعادة الكاميرا لشخصيتك / Reset Camera", function()
            local char = localPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                Workspace.CurrentCamera.CameraSubject = hum
            end
        end)

        -- Initial Status Refresh & Loop
        refreshStatus()

        task.spawn(function()
            while tab.Page and tab.Page.Parent do
                task.wait(2)
                if not tab.Page or not tab.Page.Parent then
                    break
                end
                pcall(refreshStatus)
            end
        end)
    end,
}
