-- [[ Cryptic Hub - ميزة نسخ سكن اللاعبين (Local Avatar Copier) ]]
-- المطور: يامي/أروى | الوصف: قائمة لاعبين مصغرة مع زر لنسخ الشكل محلياً

return function(Tab, UI)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer

    -- العنوان المزدوج كما طلبت بالضبط
    Tab:AddParagraph("نسخ سكن / Copy Outfit", "فقط انت تقدر تشوفه / Only you can see it")

    -- إنشاء حاوية القائمة (مربع أسود أنيق يحتوي على اللاعبين)
    Tab.Order = Tab.Order + 1
    local ListContainer = Instance.new("Frame", Tab.Page)
    ListContainer.LayoutOrder = Tab.Order
    ListContainer.Size = UDim2.new(0.98, 0, 0, 220) -- ارتفاع القائمة
    ListContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Instance.new("UICorner", ListContainer).CornerRadius = UDim.new(0, 6)
    
    local Scroll = Instance.new("ScrollingFrame", ListContainer)
    Scroll.Size = UDim2.new(1, 0, 1, -10)
    Scroll.Position = UDim2.new(0, 0, 0, 5)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 3
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local Layout = Instance.new("UIListLayout", Scroll)
    Layout.Padding = UDim.new(0, 5)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)

    -- دالة تحديث قائمة اللاعبين
    local function RefreshList()
        -- مسح اللاعبين القدامى لمنع التكرار
        for _, child in pairs(Scroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= lp then -- لا نعرض اسمك أنت في القائمة
                local PlayerRow = Instance.new("Frame", Scroll)
                PlayerRow.Size = UDim2.new(0.95, 0, 0, 45)
                PlayerRow.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                Instance.new("UICorner", PlayerRow).CornerRadius = UDim.new(0, 4)

                -- صورة وجه اللاعب (لإضافة لمسة فخامة)
                local Pfp = Instance.new("ImageLabel", PlayerRow)
                Pfp.Size = UDim2.new(0, 35, 0, 35)
                Pfp.Position = UDim2.new(0, 5, 0.5, -17.5)
                Pfp.BackgroundTransparency = 1
                Pfp.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png"
                Instance.new("UICorner", Pfp).CornerRadius = UDim.new(1, 0)

                -- اسم اللاعب
                local NameLbl = Instance.new("TextLabel", PlayerRow)
                NameLbl.Size = UDim2.new(0.5, 0, 1, 0)
                NameLbl.Position = UDim2.new(0, 50, 0, 0)
                NameLbl.BackgroundTransparency = 1
                NameLbl.Text = player.DisplayName
                NameLbl.TextColor3 = Color3.new(1, 1, 1)
                NameLbl.Font = Enum.Font.GothamSemibold
                NameLbl.TextSize = 12
                NameLbl.TextXAlignment = Enum.TextXAlignment.Left

                -- زر النسخ
                local CopyBtn = Instance.new("TextButton", PlayerRow)
                CopyBtn.Size = UDim2.new(0, 70, 0, 26)
                CopyBtn.Position = UDim2.new(1, -75, 0.5, -13)
                CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255) -- لون أزرق مميز
                CopyBtn.Text = "نسخ / Copy"
                CopyBtn.TextColor3 = Color3.new(1, 1, 1)
                CopyBtn.Font = Enum.Font.GothamBold
                CopyBtn.TextSize = 10
                Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 4)

                -- وظيفة النسخ عند الضغط
                CopyBtn.MouseButton1Click:Connect(function()
                    pcall(function()
                        local myChar = lp.Character
                        local myHum = myChar and myChar:FindFirstChild("Humanoid")
                        if myHum then
                            -- استخدام نظام روبلوكس الرسمي لنسخ السكن (آمن 100%)
                            local targetDesc = Players:GetHumanoidDescriptionFromUserId(player.UserId)
                            if targetDesc then
                                myHum:ApplyDescription(targetDesc)
                                
                                -- إشعار النجاح
                                game:GetService("StarterGui"):SetCore("SendNotification", {
                                    Title = "Cryptic Hub 🎭",
                                    Text = "تم نسخ سكن " .. player.DisplayName .. " بنجاح!",
                                    Duration = 3
                                })
                            end
                        end
                    end)
                end)
            end
        end
    end

    -- تشغيل القائمة فوراً عند فتح القسم
    RefreshList()
    
    -- تحديث تلقائي عند دخول أو خروج لاعبين
    Players.PlayerAdded:Connect(RefreshList)
    Players.PlayerRemoving:Connect(RefreshList)
    
    Tab:AddLine()
    
    -- زر احتياطي لتحديث القائمة يدوياً
    Tab:AddButton("🔄 تحديث القائمة / Refresh Players", function()
        RefreshList()
    end)
end
