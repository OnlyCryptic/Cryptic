-- [[ Cryptic Hub - حفظ الأماكن ]]
local HttpService = game:GetService("HttpService")

return function(Tab, UI)
    local locationName = ""
    
    Tab:AddInput("اسم المكان | Location Name", "اكتب اسم المكان... | Type name...", function(text)
        locationName = text
    end)

    Tab:AddButton("📍 حفظ إحداثيات موقعي | Save Position", function()
        if locationName == "" then 
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "تنبيه | Alert", Text = "اكتب اسم المكان أولاً! | Type name first!", Duration = 3})
            return 
        end
        
        local player = game.Players.LocalPlayer
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local pos = player.Character.HumanoidRootPart.CFrame
        local saveTable = {x = pos.X, y = pos.Y, z = pos.Z}
        
        local fileName = "Cryptic_TP_" .. game.PlaceId .. ".json"
        local data = {}
        
        if isfile and isfile(fileName) then
            pcall(function() data = HttpService:JSONDecode(readfile(fileName)) end)
        end
        
        data[locationName] = saveTable
        
        if writefile then
            writefile(fileName, HttpService:JSONEncode(data))
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "نجاح | Success", Text = "تم حفظ | Saved: " .. locationName, Duration = 3})
            
            -- تحديث القائمة المنسدلة تلقائياً
            if _G.RefreshTPLocations then _G.RefreshTPLocations() end
        end
    end)
    Tab:AddLine()
end
