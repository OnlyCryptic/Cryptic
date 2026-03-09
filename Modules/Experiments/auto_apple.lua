-- [[ أداة حساب الكول داون الدقيق ]]
local lp = game.Players.LocalPlayer
local hum = lp.Character:WaitForChild("Humanoid")
local lastTime = 0

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "حاسبة الكول داون", Text = "تدمج الآن، ثم كل تفاحتين ورا بعض بسرعة!", Duration = 5
})

hum:GetPropertyChangedSignal("Health"):Connect(function()
    if hum.Health > 0 then
        local currentTime = tick()
        if lastTime ~= 0 then
            local exactCooldown = currentTime - lastTime
            -- تصفية الوقت العشوائي للعبة وجلب أقرب رقم
            local formattedCooldown = math.floor(exactCooldown * 10) / 10
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "⏳ النتيجة", 
                Text = "الكول داون هو: " .. tostring(formattedCooldown) .. " ثانية", 
                Duration = 10
            })
        end
        lastTime = currentTime
    end
end)
