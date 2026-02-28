return function(Tab, UI)
    Tab:AddButton("🚀 انتقال إلى لاعب", function()
        local target = _G.ArwaTarget
        local lp = game.Players.LocalPlayer
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then 
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                lp.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0) 
            end
        else
            UI:Notify("⚠️ حدد هدفاً أولاً!")
        end
    end)
end
