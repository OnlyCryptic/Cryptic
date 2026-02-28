return function(Tab, UI)
    local Player = game.Players.LocalPlayer
    local isGiant = false

    Tab:AddToggle("تحول العملاق 🦍", function(state)
        isGiant = state
        local Character = Player.Character
        
        if not Character then return end
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        
        if not Humanoid then return end

        -- فحص نوع الشخصية (مهم جداً!)
        if Humanoid.RigType == Enum.HumanoidRigType.R6 then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Arwa Hub - تنبيه",
                Text = "هذه اللعبة تستخدم نظام R6! التكبير يعمل فقط في ألعاب R15.",
                Duration = 5
            })
            return -- إيقاف الكود هنا لأن R6 لا يدعم التكبير بهذا الشكل
        end

        -- مصفوفة بأسماء القيم المسؤولة عن حجم الجسم في R15
        local scaleNames = {"BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale"}

        -- تطبيق الحجم
        for _, name in pairs(scaleNames) do
            local scaleValue = Humanoid:FindFirstChild(name)
            if scaleValue and scaleValue:IsA("NumberValue") then
                -- حفظ الحجم الأصلي
                if not scaleValue:FindFirstChild("OriginalSize") then
                    local orig = Instance.new("NumberValue")
                    orig.Name = "OriginalSize"
                    orig.Value = scaleValue.Value
                    orig.Parent = scaleValue
                end

                -- التكبير 4 أضعاف (يمكنك تغيير الرقم 4)
                if isGiant then
                    scaleValue.Value = scaleValue.OriginalSize.Value * 4 
                else
                    scaleValue.Value = scaleValue.OriginalSize.Value
                end
            end
        end

        -- إشعار النجاح
        if isGiant then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Arwa Hub",
                Text = "أنت الآن عملاق! 🦍",
                Duration = 3
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Arwa Hub",
                Text = "عدت إلى حجمك الطبيعي.",
                Duration = 3
            })
        end
    end)
end
