-- [[ Cryptic Hub - Anti Block Fling Shield ]]

local i18n = getgenv().CrypticI18n
local T = (i18n and i18n.T) or function(k) return k end

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer

    local isAntiBlockActive = false
    local ProtectionConnection = nil
    local noclippedParts = {}

    local function clearConstraints()
        local char = Player.Character
        if char then
            local folder = char:FindFirstChild("Cryptic_AntiBlock_NCC")
            if folder then folder:Destroy() end
        end
        noclippedParts = {}
    end

    Tab:AddToggle(T("other.anti_block.label"), function(state)
        isAntiBlockActive = state

        if isAntiBlockActive then
            pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Cryptic Hub", Text = T("other.anti_block.on"), Duration = 4 }) end)

            ProtectionConnection = RunService.Heartbeat:Connect(function()
                local Character = Player.Character
                if not Character then return end

                local root = Character:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local nccFolder = Character:FindFirstChild("Cryptic_AntiBlock_NCC")
                if not nccFolder then
                    nccFolder = Instance.new("Folder")
                    nccFolder.Name = "Cryptic_AntiBlock_NCC"
                    nccFolder.Parent = Character
                end

                local overlapParams = OverlapParams.new()
                overlapParams.FilterType = Enum.RaycastFilterType.Exclude
                overlapParams.FilterDescendantsInstances = {Character}

                local nearbyParts = workspace:GetPartBoundsInRadius(root.Position, 45, overlapParams)

                for _, part in ipairs(nearbyParts) do
                    if part:IsA("BasePart") and not part.Anchored then
                        if part.AssemblyLinearVelocity.Magnitude > 25 or part.AssemblyAngularVelocity.Magnitude > 25 then
                            if not noclippedParts[part] then
                                noclippedParts[part] = true
                                for _, charPart in pairs(Character:GetChildren()) do
                                    if charPart:IsA("BasePart") then
                                        local ncc = Instance.new("NoCollisionConstraint")
                                        ncc.Part0 = charPart
                                        ncc.Part1 = part
                                        ncc.Parent = nccFolder
                                    end
                                end
                            end
                        end
                    end
                end
            end)

        else
            if ProtectionConnection then
                ProtectionConnection:Disconnect()
                ProtectionConnection = nil
            end
            clearConstraints()

            pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Cryptic Hub", Text = T("other.anti_block.off"), Duration = 4 }) end)
        end
    end)
end
