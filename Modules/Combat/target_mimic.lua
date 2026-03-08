-- [[ Cryptic Hub - ميزة تقليد الكلام (Chat Mimic) ]]
-- المطور: يامي (Yami) | الميزات: دعم الأنظمة الجديدة والقديمة، إشعارات مزدوجة (عربي/إنجليزي)

return function(Tab, UI)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TextChatService = game:GetService("TextChatService")
    local StarterGui = game:GetService("StarterGui")
    local lp = game.Players.LocalPlayer

    local isMimicking = false
    local mimicConnection = nil

    -- دالة الإشعارات المزدوجة (عربي/إنجليزي)
    local function Notify(arText, enText)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = arText .. "\n" .. enText,
                Duration = 10, 
            })
        end)
    end

    -- الوظيفة الأساسية لربط الشات بالهدف
    local function setupMimicConnection()
        if mimicConnection then 
            mimicConnection:Disconnect() 
            mimicConnection = nil 
        end
        
        local target = _G.ArwaTarget
        if isMimicking and target then
            mimicConnection = target.Chatted:Connect(function(msg)
                local rawMsg = tostring(msg)
                pcall(function()
                    -- دعم نظام الشات الجديد (TextChannels)
                    if TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral") then
                        TextChatService.TextChannels.RBXGeneral:SendAsync(rawMsg)
                    -- دعم نظام الشات القديم (SayMessageRequest)
                    elseif ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") then
                        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(rawMsg, "All")
                    end
                end)
            end)
        end
    end

    -- زر التشغيل بالاسم الجديد المتناسق مع السكربت
    Tab:AddToggle("تقليد كلام / Chat Mimic", function(active)
        isMimicking = active
        
        if active then
            if _G.ArwaTarget then
                setupMimicConnection()
                Notify(
                    "✅ بدأ تقليد كلام: " .. _G.ArwaTarget.DisplayName,
                    "✅ Started mimicking: " .. _G.ArwaTarget.DisplayName
                )
            else
                isMimicking = false
                -- إذا نسيت تحديد لاعب
                Notify(
                    "⚠️ حدد لاعباً أولاً من خانة البحث!",
                    "⚠️ Select a player first from the search box!"
                )
            end
        else
            if mimicConnection then 
                mimicConnection:Disconnect() 
                mimicConnection = nil 
            end
            Notify(
                "❌ تم إيقاف تقليد الكلام",
                "❌ Chat mimic stopped"
            )
        end
    end)

    -- حلقة ذكية لتحديث التقليد تلقائياً عند تغيير الهدف في خانة البحث
    task.spawn(function()
        local lastTarget = nil
        while true do
            task.wait(1) 
            if isMimicking and _G.ArwaTarget ~= lastTarget then
                lastTarget = _G.ArwaTarget
                setupMimicConnection()
            end
        end
    end)
end
