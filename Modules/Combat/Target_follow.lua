-- [[ Cryptic Hub - تتبع لاعب (Target Follow) ]]
-- الوضع: معلّق فوق الهدف بمتر واحد، جسم نايم يراقبه من فوق

return function(Tab, UI)
    local RunService = game:GetService("RunService")
    local Players    = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp         = Players.LocalPlayer

    local isFollowing = false
    local followConn  = nil
    local physicsConn = nil

    -- ارتفاع الشخصية فوق الهدف (1 متر)
    local HOVER_HEIGHT = 2.5

    local function Notify(ar, en)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text  = ar .. "\n" .. en,
                Duration = 3,
            })
        end)
    end

    local function StopFollow()
        isFollowing = false
        if followConn  then followConn:Disconnect()  followConn  = nil end
        if physicsConn then physicsConn:Disconnect() physicsConn = nil end

        -- إرجاع وضعية الشخصية الطبيعية
        local char = lp.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if root and hum then
            -- نرجع الـ CFrame لوضعية مستقيمة عند نفس الموضع
            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, 0, 0)
            hum:MoveTo(root.Position)
        end
    end

    Tab:AddToggle("تتبع الهدف / Follow Target", function(active)
        if active then
            local target = _G.ArwaTarget
            if not target or not target.Character then
                Notify("⚠️ حدد لاعباً أولاً!", "⚠️ Select a player first!")
                StopFollow()
                return
            end

            isFollowing = true
            Notify(
                "👁️ يراقب من فوق: " .. target.DisplayName,
                "👁️ Hovering above: " .. target.DisplayName
            )

            -- لوب الفيزياء: noclip + antifling + تعطيل الجاذبية
            physicsConn = RunService.Stepped:Connect(function()
                if not isFollowing then return end
                local char = lp.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")

                -- NoClip للشخصية المحلية
                for _, p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                    end
                end

                -- تعطيل الجاذبية على الـ root
                if root then
                    root.AssemblyLinearVelocity  = Vector3.new(0, 0, 0)
                    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end

                -- AntiFling: تعطيل تصادم اللاعبين الآخرين
                for _, pl in pairs(Players:GetPlayers()) do
                    if pl ~= lp and pl.Character then
                        for _, p in pairs(pl.Character:GetChildren()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                end
            end)

            -- لوب التتبع: ثبّت الشخصية فوق الهدف بوضعية "نايمة" تراقبه
            followConn = RunService.Heartbeat:Connect(function()
                if not isFollowing then return end

                local char    = lp.Character
                local root    = char and char:FindFirstChild("HumanoidRootPart")
                local hum     = char and char:FindFirstChildOfClass("Humanoid")

                local tgt     = _G.ArwaTarget
                local tgtChar = tgt and tgt.Character
                local tgtRoot = tgtChar and tgtChar:FindFirstChild("HumanoidRootPart")

                if not root or not hum or not tgtRoot then return end
                if hum.Health <= 0 then return end

                -- الموضع: مباشرة فوق الهدف بـ HOVER_HEIGHT متر
                local abovePos = tgtRoot.Position + Vector3.new(0, HOVER_HEIGHT, 0)

                -- استخرج اتجاه الهدف على محور Y فقط (نفس اتجاهه الأفقي)
                local _, targetYaw, _ = tgtRoot.CFrame:ToEulerAnglesYXZ()

                --[[
                    وضعية "نايمة وتراقب من فوق":
                    - نحط الشخصية فوق الهدف
                    - نديرها بنفس اتجاه الهدف الأفقي
                    - نميلها 90 درجة للأمام (كأنها مستلقية على بطنها في الهواء وتشوف للأسفل)
                ]]
                local finalCF = CFrame.new(abovePos)
                    * CFrame.fromEulerAnglesYXZ(0, targetYaw, 0)
                    * CFrame.Angles(math.pi / 2, 0, 0)

                root.CFrame = finalCF
            end)

        else
            StopFollow()
            Notify("❌ توقف التتبع.", "❌ Follow stopped.")
        end
    end)
end
