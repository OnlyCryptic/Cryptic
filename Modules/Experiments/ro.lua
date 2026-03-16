-- [[ Cryptic Hub - Auto Roll Abilities ]]
-- المطور: يامي | الوصف: لف قدرات تلقائي مع حماية من الكراش

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

return function(Tab, UI)
    local isAutoRolling = false

    local function Notify(title, text)
        pcall(function() StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=3}) end)
    end

    Tab:AddToggle("لف قدرات تلقائي | Auto Roll Abilities", function(state)
        isAutoRolling = state
        
        if state then
            Notify("Cryptic Hub 🔮", "تم تفعيل اللف التلقائي!\nAuto Roll Started!")
            
            task.spawn(function()
                while isAutoRolling do
                    pcall(function()
                        -- التأكد من وجود الريموت والكرة عشان السكربت ما يعلق لو الماب ما ترسبن كامل
                        local remote = ReplicatedStorage:FindFirstChild("RemoteEvent_1")
                        local crystalBall = workspace:FindFirstChild("CrystallBall_3")
                        
                        if remote and crystalBall then
                            local args = {
                                "BuyCrystalBall",
                                crystalBall,
                                2
                            }
                            remote:FireServer(unpack(args))
                        end
                    end)
                    -- 🔴 سرعة اللف: خليتها 0.5 ثانية كحماية. 
                    -- إذا اللعبة ما تطردك على السبام، تقدر تنقصها لـ 0.1 عشان يلف أسرع!
                    task.wait(0.5) 
                end
            end)
        else
            Notify("Cryptic Hub 🛑", "تم إيقاف اللف التلقائي!\nAuto Roll Stopped!")
        end
    end)
    
    Tab:AddLine()
end
