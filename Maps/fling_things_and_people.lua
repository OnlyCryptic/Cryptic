-- [[ Cryptic Hub - Map: Fling Things and People ]]
-- Read-only, map-specific status panel. No remote calls or player manipulation.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local function getValueObjectValue(parent, name)
    local valueObject = parent and parent:FindFirstChild(name)
    if not valueObject then
        return nil
    end

    local ok, value = pcall(function()
        return valueObject.Value
    end)
    if ok then
        return value
    end
    return nil
end

local function formatNumber(value)
    if type(value) == "number" then
        return tostring(math.floor(value))
    end
    return "غير متاح / N/A"
end

return {
    Name = "Fling Things and People",

    Render = function(tab)
        local localPlayer = Players.LocalPlayer

        tab:AddParagraph(
            "معلومات الماب / Map info",
            "Fling Things and People\nPlace ID: 6961824067  |  Universal ID: 2668101271"
        )
        tab:AddParagraph(
            "حالة اللاعب / Player status",
            "معلومات للقراءة فقط عن جلستك الحالية؛ لا تغيّر إعدادات اللعبة أو اللاعبين الآخرين."
        )

        local playerCountLabel = tab:AddLabel("اللاعبون / Players: —")
        local plotLabel = tab:AddLabel("البلوت / Plot: —")
        local toyCountLabel = tab:AddLabel("الألعاب المنشأة / Toys: —")
        local characterLabel = tab:AddLabel("الشخصية / Character: —")
        local refreshedAtLabel = tab:AddLabel("آخر تحديث / Updated: —")

        local function refreshStatus()
            local playerCount = #Players:GetPlayers()
            local maxPlayers = Players.MaxPlayers
            playerCountLabel.SetText(
                "اللاعبون / Players: " .. playerCount .. " / " .. tostring(maxPlayers)
            )

            local inPlot = getValueObjectValue(localPlayer, "InPlot")
            local plotStatus
            if inPlot == true then
                plotStatus = "داخل البلوت / In plot"
            elseif inPlot == false then
                plotStatus = "ليس داخل البلوت / Not in plot"
            else
                plotStatus = "غير متاح / N/A"
            end
            plotLabel.SetText("البلوت / Plot: " .. plotStatus)

            local spawnedToys = Workspace:FindFirstChild(localPlayer.Name .. "SpawnedInToys")
            local toyCount = spawnedToys and #spawnedToys:GetChildren() or 0
            local toyLimit = getValueObjectValue(localPlayer, "ToysLimitCap")
            toyCountLabel.SetText(
                "الألعاب المنشأة / Toys: "
                    .. tostring(toyCount)
                    .. " / "
                    .. formatNumber(toyLimit)
            )

            local character = localPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                characterLabel.SetText(
                    "الصحة / Health: "
                        .. formatNumber(humanoid.Health)
                        .. " / "
                        .. formatNumber(humanoid.MaxHealth)
                        .. "  |  WalkSpeed: "
                        .. formatNumber(humanoid.WalkSpeed)
                )
            else
                characterLabel.SetText("الشخصية / Character: غير متاحة / N/A")
            end

            refreshedAtLabel.SetText(
                "آخر تحديث / Updated: "
                    .. os.date("%H:%M:%S")
            )
        end

        tab:AddButton("تحديث المعلومات / Refresh status", refreshStatus)
        refreshStatus()

        task.spawn(function()
            while tab.Page and tab.Page.Parent do
                task.wait(2)
                if not tab.Page or not tab.Page.Parent then
                    break
                end
                pcall(refreshStatus)
            end
        end)
    end,
}