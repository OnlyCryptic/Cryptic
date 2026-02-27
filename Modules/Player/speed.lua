return function(Tab, UI)
    Tab:AddButton("تفعيل السرعة (100)", function()
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
        UI:Notify("السرعة الآن: 100")
    end)
    
    Tab:AddButton("سرعة طبيعية (16)", function()
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end)
end
