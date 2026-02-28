return function(Tab, UI)
    local Player = game.Players.LocalPlayer
    local isGiant = false

    Tab:AddToggle("تحول العملاق 🦍", function(state)
        isGiant = state
        local Character = Player.Character
        
        if not Character then return end
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        
        if not Humanoid then return end

        -- مصفوفة بأسماء القيم المسؤولة عن حجم الجسم
        local scaleNames = {"BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale"}

        -- وظيفة لتغيير الحجم
        local function UpdateSize(multiplier)
            for _, name in pairs(scaleNames) do
                local scaleValue = Humanoid:FindFirstChild(name)
                if scaleValue then
                    -- حفظ الحجم الأصلي حتى نتمكن من العودة إليه
                    if not scaleValue:FindFirstChild("OriginalSize") then
                        local orig = Instance.new("NumberValue")
                        orig.Name = "OriginalSize"
                        orig.Value = scaleValue.Value
                        orig.Parent = scaleValue
                    end

                    -- تطبيق الحجم الجديد (إذا كان مفعل نضربه في الرقم، وإلا نرجعه للأصلي)
                    if isGiant then
                        scaleValue.Value = scaleValue:FindFirstChild("OriginalSize").Value * multiplier
                    else
                        scaleValue.Value = scaleValue:FindFirstChild("OriginalSize").Value
                    end
                end
            end
        end

        if isGiant then
            UpdateSize(3) -- الرقم 3 يعني تكبير الحجم 3 أضعاف (يمكنك تغييره إلى 4 أو 5 إذا أردتِ حجماً أكبر!)
            
            -- إرسال إشعار
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Arwa Hub",
                Text = "أنت الآن عملاق يهز السيرفر! 🦍",
                Duration = 4
            })
        else
            UpdateSize(1) -- العودة للحجم الطبيعي
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Arwa Hub",
                Text = "عدت إلى حجمك الطبيعي.",
                Duration = 3
            })
        end
    end)
end
