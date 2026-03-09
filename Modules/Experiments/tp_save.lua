-- [[ Cryptic Hub - حفظ الأماكن ]]
local HttpService = game:GetService("HttpService")

return function(Tab, UI)
    local locationName = ""
    
    Tab:AddInput("اسم المكان الجديد", "اكتب اسم المكان هنا...", function(text)
        locationName = text
    end)

    Tab:AddButton("📍 حفظ إحداثيات موقعي الحالي", function()
        if locationName == "" then 
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "تنبيه", Text = "اكتب اسم المكان أولاً!", Duration = 3})
            return 
        end
        
        local player = game.Players.LocalPlayer
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local pos = player.Character.HumanoidRootPart.CFrame
        local saveTable = {x = pos.X, y = pos.Y, z = pos.Z}
        
        -- إنشاء ملف حفظ خاص بالماب الحالي
        local fileName = "Cryptic_TP_" .. game.PlaceId .. ".json"
        local data = {}
        
        if isfile and isfile(fileName) then
            pcall(function() data = HttpService:JSONDecode(readfile(fileName)) end)
        end
        
        data[locationName] = saveTable
        
        if writefile then
            writefile(fileName, HttpService:JSONEncode(data))
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "نجاح", Text = "تم حفظ: " .. locationName, Duration = 3})
            
            -- أمر لتحديث القائمة المنسدلة في الملف الثالث تلقائياً
            if _G.RefreshTPLocations then _G.RefreshTPLocations() end
        end
    end)
    Tab:AddLine()
end
