-- [[ Cryptic Hub - Element: Large Input ]]
-- المسار: UI/Elements/LargeInput.lua

return function(TabOps, label, placeholder, callback)
    TabOps.Order = TabOps.Order + 1
    
    local Row = Instance.new("Frame", TabOps.Page)
    Row.LayoutOrder = TabOps.Order
    Row.Size = UDim2.new(0.98, 0, 0, 130)
    Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", Row)
    
    local Lbl = Instance.new("TextLabel", Row)
    Lbl.Text = label
    Lbl.Size = UDim2.new(1, -20, 0, 25)
    Lbl.Position = UDim2.new(0, 10, 0, 5)
    Lbl.TextColor3 = Color3.new(1, 1, 1)
    Lbl.BackgroundTransparency = 1
    Lbl.TextXAlignment = Enum.TextXAlignment.Center
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 11 -- 🟢 توحيد الحجم ليطابق الواجهة
    
    local InpBG = Instance.new("Frame", Row)
    InpBG.Size = UDim2.new(1, -20, 1, -45)
    InpBG.Position = UDim2.new(0, 10, 0, 35)
    InpBG.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    Instance.new("UICorner", InpBG)
    
    local Inp = Instance.new("TextBox", InpBG)
    Inp.Size = UDim2.new(1, -10, 1, -10)
    Inp.Position = UDim2.new(0, 5, 0, 5)
    Inp.Text = ""
    Inp.PlaceholderText = placeholder or "اكتب هنا..."
    Inp.BackgroundTransparency = 1
    Inp.TextColor3 = Color3.new(1, 1, 1)
    Inp.TextXAlignment = Enum.TextXAlignment.Right
    Inp.TextYAlignment = Enum.TextYAlignment.Top
    Inp.Font = Enum.Font.Gotham
    Inp.TextSize = 11 -- 🟢 توحيد الحجم ليطابق الواجهة
    Inp.TextWrapped = true
    Inp.ClearTextOnFocus = false
    Inp.MultiLine = true
    
    Inp.FocusLost:Connect(function() 
        pcall(callback, Inp.Text) 
    end)

    -- 🟢 إضافة الدالة المطلوبة لكي يتم مسح النص بعد إرسال الاقتراح
    return {
        SetText = function(self, text)
            Inp.Text = text
            pcall(callback, text)
        end
    }
end
