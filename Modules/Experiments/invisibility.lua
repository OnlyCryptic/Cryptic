return function(Tab, UI)
    local Player = game.Players.LocalPlayer
    local IsInvisible = false

    -- استخدام AddToggle لأنه الاسم الموجود في الـ UI Engine الخاص بكِ
    Tab:AddToggle("الاختفاء الكامل 👻", function(state)
        local Character = Player.Character
        if not Character then return end
        
        IsInvisible = state
        
        -- إخفاء/إظهار أجزاء الجسم والملابس والإكسسوارات
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                -- نظام حفظ الشفافية الأصلية
                if not part:FindFirstChild("OriginalTransparency") then
                    local val = Instance.new("NumberValue", part)
                    val.Name = "OriginalTransparency"
                    val.Value = part.Transparency
                end

                if IsInvisible then
                    part.Transparency = 1
                else
                    part.Transparency = part:FindFirstChild("OriginalTransparency").Value
                end
            end
        end

        -- إخفاء اسم اللاعب (Display Name & NameTag)
        local Head = Character:FindFirstChild("Head")
        if Head then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if IsInvisible then
                if Humanoid then Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
            else
                if Humanoid then Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end
            end
        end

        -- إرسال إشعار (Notification)
        if IsInvisible then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Arwa Hub",
                Text = "تم تفعيل الاختفاء الكامل بنجاح!",
                Duration = 3
            })
        end
    end)
end
