return function(Tab, UI)
    local Player = game.Players.LocalPlayer
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local IsInvisible = false

    Tab:CreateToggle("تفعيل الاختفاء", function(state)
        IsInvisible = state
        
        if not Character then return end
        
        -- مصفوفة للأجزاء التي سنخفيها
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                -- حفظ الشفافية الأصلية لسهولة الإرجاع
                if not part:FindFirstChild("OriginalTransparency") then
                    local val = Instance.new("NumberValue", part)
                    val.Name = "OriginalTransparency"
                    val.Value = part.Transparency
                end

                if IsInvisible then
                    part.Transparency = 1 -- اختفاء كامل
                else
                    part.Transparency = part:FindFirstChild("OriginalTransparency").Value
                end
            end
        end

        if IsInvisible then
            UI:Notify("Arwa Hub", "تم تفعيل الاختفاء بنجاح 👻")
        else
            UI:Notify("Arwa Hub", "تم إلغاء الاختفاء")
        end
    end)
end
