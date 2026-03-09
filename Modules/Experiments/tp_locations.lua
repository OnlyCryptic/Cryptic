-- [[ Cryptic Hub - قائمة الانتقال ]]
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

return function(Tab, UI)
    local fileName = "Cryptic_TP_" .. game.PlaceId .. ".json"
    local locations = {}
    local locationNames = {}

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
            table.insert(locationNames, "لا توجد أماكن محفوظة") 
        end
    end

    loadLocations()

    -- إنشاء القائمة المنسدلة للأماكن المحفوظة
    local dropdown = Tab:AddDropdown("انتقال إلى مكان", locationNames, function(selected)
        if selected == "لا توجد أماكن محفوظة" then return end
        
        local locData = locations[selected]
        if not locData then return end
        
        local targetCFrame = CFrame.new(locData.x, locData.y, locData.z)
        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        -- جلب طريقة الانتقال اللي اختارها المستخدم
        local method = _G.CrypticTPMethod or "انتقال فوري (Instant)"
        
        if method == "انتقال فوري (Instant)" then
            char.HumanoidRootPart.CFrame = targetCFrame
        else
            -- طيران سريع (Tween)
            local dist = (char.HumanoidRootPart.Position - targetCFrame.Position).Magnitude
            local tweenTime = dist / 150 -- سرعة الطيران (ممكن تغير 150 لتسريعه أو تبطيئه)
            local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
            local tween = TweenService:Create(char.HumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
            tween:Play()
        end
    end)

    -- دالة جلوبال تسمح للملف الثاني بتحديث هذه القائمة عن بُعد
    _G.RefreshTPLocations = function()
        loadLocations()
        dropdown:Refresh(locationNames)
    end
    
    Tab:AddButton("🗑️ مسح جميع الأماكن المحفوظة بهذا الماب", function()
        if isfile and isfile(fileName) then
            delfile(fileName)
            locations = {}
            _G.RefreshTPLocations()
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "نجاح", Text = "تم مسح الأماكن", Duration = 3})
        end
    end)
end
