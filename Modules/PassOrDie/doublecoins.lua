-- [[ Arwa Hub - تدبيل الفلوس التلقائي ]]
return function(Tab, UI)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local autoDoubleCoins = false

    Tab:AddToggle("💰 تدبيل الفلوس تلقائياً (Auto-x2 Coins)", function(active)
        autoDoubleCoins = active
        if active then
            UI:Notify("💸 تم التفعيل! سيتم شراء واستخدام التدبيل كل جولة تلقائياً.")
        else
            UI:Notify("🛑 تم إيقاف تدبيل الفلوس.")
        end
    end)

    task.spawn(function()
        local powersRemotes = ReplicatedStorage:WaitForChild("Powers"):WaitForChild("Core"):WaitForChild("Default"):WaitForChild("Remotes")
        local buyRemote = powersRemotes:WaitForChild("Buy")
        local useRemote = powersRemotes:WaitForChild("Use")

        while task.wait(1.5) do 
            if autoDoubleCoins then
                pcall(function()
                    buyRemote:InvokeServer("7")
                    task.wait(0.2)
                    useRemote:InvokeServer("7")
                end)
            end
        end
    end)
end
