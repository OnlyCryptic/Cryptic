-- [[ Arwa Hub - ميزة تقليد الكلام (Mimic) ]]
-- المطور: Arwa | الميزات: دعم نظام الشات الجديد والقديم، تحديث تلقائي للهدف

return function(Tab, UI)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TextChatService = game:GetService("TextChatService")
    local lp = game.Players.LocalPlayer

    local isMimicking = false
    local mimicConnection = nil

    -- الوظيفة الأساسية لربط الشات (نفس الكود الكبير)
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

    Tab:AddToggle("💬 تقليد كلام الهدف", function(active)
        isMimicking = active
        setupMimicConnection()
        if active then
            UI:Notify("✅ بدأ السكربت بتقليد كلام الهدف")
        else
            UI:Notify("❌ تم إيقاف تقليد الكلام")
        end
    end)

    -- حلقة ذكية للتأكد من تحديث التقليد إذا قمتِ بتغيير الهدف
    task.spawn(function()
        local lastTarget = nil
        while true do
            task.wait(1) -- فحص كل ثانية لضمان عدم حدوث تعليق (Lag)
            if isMimicking and _G.ArwaTarget ~= lastTarget then
                lastTarget = _G.ArwaTarget
                setupMimicConnection()
            end
        end
    end)
end
