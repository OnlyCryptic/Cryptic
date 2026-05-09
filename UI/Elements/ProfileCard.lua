-- [[ Cryptic Hub - Element: Profile Card (V9 redesign) ]]
-- Layout:
--   [Avatar]   Welcome, <DisplayName>
--              @username  •  ID: 12345  •  ⏱ 00:42
-- The timer ticks live for the duration of the script session and is
-- styled exactly like the username/ID line so everything sits on a
-- single info row beneath the welcome line.
return function(TabOps, player)
    TabOps.Order = TabOps.Order + 1

    local THEME_ACCENT = Color3.fromRGB(0, 255, 150)
    local THEME_BLUE   = Color3.fromRGB(0, 150, 255)
    local THEME_TEXT   = Color3.fromRGB(235, 240, 248)
    local THEME_DIM    = Color3.fromRGB(170, 178, 195)
    local THEME_BG     = Color3.fromRGB(22, 26, 34)
    local THEME_STROKE = Color3.fromRGB(60, 90, 120)

    -- Card root
    local R = Instance.new("Frame", TabOps.Page)
    R.LayoutOrder            = TabOps.Order
    R.Size                   = UDim2.new(0.98, 0, 0, 78)
    R.BackgroundColor3       = THEME_BG
    R.BackgroundTransparency = 0.25
    R.BorderSizePixel        = 0
    Instance.new("UICorner", R).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", R)
    stroke.Thickness       = 1
    stroke.Transparency    = 0.55
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    stroke.LineJoinMode    = Enum.LineJoinMode.Round
    local strokeGrad = Instance.new("UIGradient", stroke)
    strokeGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, THEME_ACCENT),
        ColorSequenceKeypoint.new(1, THEME_BLUE),
    }
    strokeGrad.Rotation = 35

    -- Subtle inner depth gradient
    local bgGrad = Instance.new("UIGradient", R)
    bgGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 38, 52)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 22, 30)),
    }
    bgGrad.Rotation = 120

    -- Avatar (left side, circular)
    local AvatarHolder = Instance.new("Frame", R)
    AvatarHolder.Size                   = UDim2.new(0, 56, 0, 56)
    AvatarHolder.Position               = UDim2.new(0, 11, 0.5, -28)
    AvatarHolder.BackgroundColor3       = Color3.fromRGB(35, 40, 50)
    AvatarHolder.BorderSizePixel        = 0
    Instance.new("UICorner", AvatarHolder).CornerRadius = UDim.new(1, 0)
    local avStroke = Instance.new("UIStroke", AvatarHolder)
    avStroke.Thickness    = 1.2
    avStroke.Transparency = 0.3
    local avStrokeGrad = Instance.new("UIGradient", avStroke)
    avStrokeGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, THEME_ACCENT),
        ColorSequenceKeypoint.new(1, THEME_BLUE),
    }
    avStrokeGrad.Rotation = 90

    local Avatar = Instance.new("ImageLabel", AvatarHolder)
    Avatar.Size                   = UDim2.new(1, -4, 1, -4)
    Avatar.Position               = UDim2.new(0, 2, 0, 2)
    Avatar.BackgroundTransparency = 1
    Avatar.BorderSizePixel        = 0
    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)

    task.spawn(function()
        local ok, thumb = pcall(function()
            return game:GetService("Players"):GetUserThumbnailAsync(
                player.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size420x420)
        end)
        if ok and thumb then Avatar.Image = thumb end
    end)

    -- ----------------------------------------------------------
    -- Text stack on the right of the avatar.
    -- Two lines:
    --   1) "Welcome, <DisplayName>"  (large, accent-tinted)
    --   2) "@username  •  ID: 12345  •  ⏱ 00:42"  (single info row)
    -- ----------------------------------------------------------
    local TEXT_LEFT = 80

    local NameLbl = Instance.new("TextLabel", R)
    NameLbl.Size                   = UDim2.new(1, -(TEXT_LEFT + 12), 0, 26)
    NameLbl.Position               = UDim2.new(0, TEXT_LEFT, 0, 12)
    NameLbl.BackgroundTransparency = 1
    NameLbl.RichText               = true
    NameLbl.Text                   = string.format(
        "<font color=\"#FFFFFF\">Welcome, </font>"
        .. "<font color=\"#00FF96\"><b>%s</b></font>",
        player.DisplayName)
    NameLbl.TextColor3             = THEME_TEXT
    NameLbl.TextXAlignment         = Enum.TextXAlignment.Left
    NameLbl.TextYAlignment         = Enum.TextYAlignment.Center
    NameLbl.Font                   = Enum.Font.GothamBold
    NameLbl.TextSize               = 16

    local InfoLbl = Instance.new("TextLabel", R)
    InfoLbl.Name                   = "InfoLine"
    InfoLbl.Size                   = UDim2.new(1, -(TEXT_LEFT + 12), 0, 18)
    InfoLbl.Position               = UDim2.new(0, TEXT_LEFT, 0, 40)
    InfoLbl.BackgroundTransparency = 1
    InfoLbl.RichText               = true
    InfoLbl.TextColor3             = THEME_DIM
    InfoLbl.TextXAlignment         = Enum.TextXAlignment.Left
    InfoLbl.TextYAlignment         = Enum.TextYAlignment.Center
    InfoLbl.Font                   = Enum.Font.Gotham
    InfoLbl.TextSize               = 12
    InfoLbl.TextTruncate           = Enum.TextTruncate.AtEnd

    -- Live session timer that ticks every second. Format: MM:SS while
    -- the run is under an hour, then HH:MM:SS afterwards.
    local sessionStart = tick()
    local function formatTimer(elapsed)
        local s = math.floor(elapsed)
        local hh = math.floor(s / 3600)
        local mm = math.floor((s % 3600) / 60)
        local ss = s % 60
        if hh > 0 then
            return string.format("%02d:%02d:%02d", hh, mm, ss)
        end
        return string.format("%02d:%02d", mm, ss)
    end

    local function paint()
        InfoLbl.Text = string.format(
            "<font color=\"#AAB2C3\">@%s</font>"
            .. "<font color=\"#5B6478\">  •  </font>"
            .. "<font color=\"#AAB2C3\">ID: %d</font>"
            .. "<font color=\"#5B6478\">  •  </font>"
            .. "<font color=\"#00FF96\">⏱ %s</font>",
            player.Name, player.UserId, formatTimer(tick() - sessionStart))
    end

    paint()

    task.spawn(function()
        while R.Parent do
            task.wait(1)
            if R.Parent then paint() end
        end
    end)
end
