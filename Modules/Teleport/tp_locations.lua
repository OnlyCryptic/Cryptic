-- [[ Cryptic Hub - قائمة الانتقال ]]
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

return function(Tab, UI)
    local fileName = "Cryptic_TP_" .. game.PlaceId .. ".json"
    local locations = {}
    local locationNames = {}
    local currentSelectedLocation = nil -- متغير لحفظ المكان اللي تم اختياره من القائمة

    -- دالة لتحميل الأماكن من الملف
    local function loadLocations()
        if isfile and isfile(fileName) then
            pcall(function() locations = HttpService:JSONDecode(readfile(fileName)) end)
        end
        locationNames = {}
        for name, _ in pairs(locations) do
            table.insert(locationNames, name)
        end
        if #locationNames == 0 then 
            table.insert(locationNames, "لا توجد أماكن | No locations") 
        end
    end

    loadLocations()

    -- القائمة المنسدلة صارت وظيفتها فقط تحديد المكان (ما تنقلك مباشرة)
    local dropdown = Tab:AddDropdown("انتقال إلى | TP to", locationNames, function(selected)
        if selected == "لا توجد أماكن | No locations" then
            currentSelectedLocation = nil
        else
            currentSelectedLocation = selected
        end
    end)

    -- زر عادي لتأكيد وتفعيل الانتقال للمكان المحدد
    Tab:AddButton("🚀 انتقال | Teleport", function()
        if not currentSelectedLocation then
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "تنبيه | Alert", Text = "اختر مكان أولاً! | Select a location first!", Duration = 3})
            return
        end

        local locData = locations[currentSelectedLocation]
        if not locData then return end
        
        local targetCFrame = CFrame.new(locData.x, locData.y, locData.z)
        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        -- جلب طريقة الانتقال اللي اختارها المستخدم
        local method = _G.CrypticTPMethod or "انتقال فوري | Instant"
        
        if method == "انتقال فوري | Instant" then
            char.HumanoidRootPart.CFrame = targetCFrame
        else
            -- طيران سريع (Tween)
            local dist = (char.HumanoidRootPart.Position - targetCFrame.Position).Magnitude
            local tweenTime = dist / 150 -- سرعة الطيران
            local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
            local tween = TweenService:Create(char.HumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
            tween:Play()
        end
    end)

    -- دالة جلوبال تسمح للملف الثاني بتحديث هذه القائمة عن بُعد
    _G.RefreshTPLocations = function()
        loadLocations()
        dropdown:Refresh(locationNames)
        -- تصفير الاختيار إذا تم مسح الأماكن أو تحديثها
        if #locationNames == 1 and locationNames[1] == "لا توجد أماكن | No locations" then
            currentSelectedLocation = nil
        end
    end
    
    Tab:AddButton("🗑️ مسح الأماكن بهذا الماب | Clear Map Locations", function()
        if isfile and isfile(fileName) then
            delfile(fileName)
            locations = {}
            currentSelectedLocation = nil
            _G.RefreshTPLocations()
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "نجاح | Success", Text = "تم المسح | Locations cleared", Duration = 3})
        end
    end)
end
