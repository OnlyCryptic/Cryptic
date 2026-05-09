-- [[ Cryptic Hub - Target Select V2.1 ]]

return function(Tab, UI)
    local players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local lp = players.LocalPlayer

    local i18n = getgenv().CrypticI18n
    local T = (i18n and i18n.T) or function(k) return k end

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = text,
                Duration = 2,
            })
        end)
    end

    local debounceThread = nil

    local PlayerSelector = Tab:AddPlayerSelector(T("combat.select.label"), T("combat.select.placeholder"), function(selectedValue)
        if type(selectedValue) == "string" and (selectedValue == "" or selectedValue:match("^%s*$")) then
            return
        end

        if type(selectedValue) ~= "string" then
            local targetPlayer = selectedValue
            _G.ArwaTarget = targetPlayer
            PlayerSelector.SetText(targetPlayer.DisplayName .. " (@" .. targetPlayer.Name .. ")")
            Notify(string.format(T("combat.select.target_selected_fmt"), targetPlayer.DisplayName))
            return
        end

        if debounceThread then
            task.cancel(debounceThread)
        end

        debounceThread = task.delay(0.6, function()
            debounceThread = nil
            local search = selectedValue:lower()
            local targetPlayer = nil
            for _, p in pairs(players:GetPlayers()) do
                if p ~= lp and string.sub(p.Name:lower(), 1, #search) == search then
                    targetPlayer = p
                    break
                end
            end

            if targetPlayer then
                _G.ArwaTarget = targetPlayer
                PlayerSelector.SetText(targetPlayer.DisplayName .. " (@" .. targetPlayer.Name .. ")")
                Notify(string.format(T("combat.select.target_selected_fmt"), targetPlayer.DisplayName))
            else
                _G.ArwaTarget = nil
                Notify(T("combat.select.not_found"))
            end
        end)
    end)

    local function RefreshDropdown()
        local list = {}
        for _, p in pairs(players:GetPlayers()) do
            if p ~= lp then table.insert(list, p) end
        end
        PlayerSelector.UpdateList(list)
    end

    RefreshDropdown()
    players.PlayerAdded:Connect(function() RefreshDropdown() end)

    players.PlayerRemoving:Connect(function(p)
        RefreshDropdown()
        if _G.ArwaTarget and _G.ArwaTarget == p then
            _G.ArwaTarget = nil
            PlayerSelector.Clear()
            Notify(T("combat.select.target_left"))
        end
    end)
end
