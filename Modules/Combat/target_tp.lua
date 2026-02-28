return function(Tab, UI)
    Tab:AddButton("🚀 انتقال للهدف", function()
        local target = _G.ArwaTarget
        local lp = game.Players.LocalPlayer
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            lp.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
        else
            UI:Notify("⚠️ حدد لاعباً أولاً!")
        end
    end)
end
