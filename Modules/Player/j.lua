-- [[ Cryptic Hub - نسخ شخصية الهدف الكاملة V2.0 ]]
-- المطور: يامي | الميزات: نسخ المظهر الكامل (ملابس + اكسسوارات + شكل الجسم)

return function(Tab, UI)
    local Players         = game:GetService("Players")
    local StarterGui      = game:GetService("StarterGui")
    local HttpService     = game:GetService("HttpService")
    local lp              = Players.LocalPlayer

    local function Notify(ar, en)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub", Text = ar .. "\n" .. en, Duration = 6
            })
        end)
    end

    -- ============================================================
    -- دالة جلب بيانات الشخصية عبر API روبلوكس
    -- ============================================================
    local function GetAvatarData(userId)
        -- جلب الـ assets (ملابس، اكسسوارات، هيئة الجسم)
        local url = "https://avatar.roblox.com/v1/users/" .. userId .. "/avatar"
        local s, r = pcall(game.HttpGet, game, url)
        if not s or not r then return nil end
        local ok, data = pcall(function() return HttpService:JSONDecode(r) end)
        if not ok or not data then return nil end
        return data
    end

    -- ============================================================
    -- دالة تطبيق الشخصية على اللاعب المحلي
    -- ============================================================
    local function ApplyAppearance(targetPlayer)
        if not targetPlayer or not targetPlayer.Character then
            Notify("⚠️ الهدف غير موجود!", "Target not found!")
            return
        end

        local targetUserId = targetPlayer.UserId
        local avatarData   = GetAvatarData(targetUserId)

        if not avatarData then
            Notify("❌ فشل جلب بيانات الهدف!", "Failed to fetch target data!")
            return
        end

        -- بناء قائمة الـ assetIds
        local assetIds = {}

        -- الملابس والاكسسوارات
        if avatarData.assets then
            for _, asset in ipairs(avatarData.assets) do
                table.insert(assetIds, asset.id)
            end
        end

        -- لون الجسم والشخصية
        local bodyColors = avatarData.bodyColors
        local scales     = avatarData.scales  -- حجم الجسم (طول/عرض/رأس)
        local playerType = avatarData.playerAvatarType -- R6 أو R15

        -- بناء الـ HumanoidDescription
        local desc = Instance.new("HumanoidDescription")

        -- تطبيق ألوان الجسم
        if bodyColors then
            pcall(function()
                -- BrickColor.new(id).Color يرجع Color3 مباشرة بدون ضرب 255
                desc.HeadColor        = BrickColor.new(bodyColors.headColorId).Color
                desc.TorsoColor       = BrickColor.new(bodyColors.torsoColorId).Color
                desc.LeftArmColor     = BrickColor.new(bodyColors.leftArmColorId).Color
                desc.RightArmColor    = BrickColor.new(bodyColors.rightArmColorId).Color
                desc.LeftLegColor     = BrickColor.new(bodyColors.leftLegColorId).Color
                desc.RightLegColor    = BrickColor.new(bodyColors.rightLegColorId).Color
            end)
        end

        -- تطبيق مقاسات الجسم
        if scales then
            pcall(function()
                desc.HeightScale     = scales.height     or 1
                desc.WidthScale      = scales.width      or 1
                desc.HeadScale       = scales.head       or 1
                desc.BodyDepthScale  = scales.depth      or 1
                desc.BodyWidthScale  = scales.width      or 1
                desc.BodyHeightScale = scales.height     or 1
                desc.ProportionScale = scales.proportion or 1
            end)
        end

        -- تطبيق الـ assets (ملابس، شعر، وجه، قبعات، اكسسوارات)
        local hatIds       = {}
        local hairIds      = {}
        local faceIds      = {}
        local frontIds     = {}
        local backIds      = {}
        local neckIds      = {}
        local shoulderIds  = {}
        local waistIds     = {}

        if avatarData.assets then
            for _, asset in ipairs(avatarData.assets) do
                local aType = asset.assetType and asset.assetType.id
                if not aType then continue end
                pcall(function()
                    if     aType == 11 then desc.Shirt        = asset.id
                    elseif aType == 12 then desc.Pants        = asset.id
                    elseif aType == 17 then desc.Face         = asset.id
                    elseif aType == 18 then desc.Head         = asset.id
                    elseif aType == 27 then desc.Torso        = asset.id
                    elseif aType == 28 then desc.RightArm     = asset.id
                    elseif aType == 29 then desc.LeftArm      = asset.id
                    elseif aType == 30 then desc.RightLeg     = asset.id
                    elseif aType == 31 then desc.LeftLeg      = asset.id
                    elseif aType == 48 then desc.GraphicTShirt = asset.id
                    -- اكسسوارات مصنفة
                    elseif aType == 8  then table.insert(hatIds,      asset.id) -- قبعة
                    elseif aType == 41 then table.insert(hairIds,     asset.id) -- شعر
                    elseif aType == 42 then table.insert(faceIds,     asset.id) -- وجه
                    elseif aType == 43 then table.insert(neckIds,     asset.id) -- عنق
                    elseif aType == 44 then table.insert(shoulderIds, asset.id) -- كتف
                    elseif aType == 45 then table.insert(frontIds,    asset.id) -- أمامي
                    elseif aType == 46 then table.insert(backIds,     asset.id) -- خلفي
                    elseif aType == 47 then table.insert(waistIds,    asset.id) -- خصر
                    end
                end)
            end
        end

        -- دالة مساعدة لتحويل قائمة IDs إلى string مفصولة بفاصلة
        local function IdsToStr(t)
            return table.concat(t, ",")
        end

        pcall(function()
            if #hatIds      > 0 then desc.HatAccessory       = IdsToStr(hatIds)      end
            if #hairIds     > 0 then desc.HairAccessory      = IdsToStr(hairIds)     end
            if #faceIds     > 0 then desc.FaceAccessory      = IdsToStr(faceIds)     end
            if #neckIds     > 0 then desc.NeckAccessory      = IdsToStr(neckIds)     end
            if #shoulderIds > 0 then desc.ShouldersAccessory = IdsToStr(shoulderIds) end
            if #frontIds    > 0 then desc.FrontAccessory     = IdsToStr(frontIds)    end
            if #backIds     > 0 then desc.BackAccessory      = IdsToStr(backIds)     end
            if #waistIds    > 0 then desc.WaistAccessory     = IdsToStr(waistIds)    end
        end)

        -- تطبيق الـ HumanoidDescription على شخصيتنا
        local char = lp.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")

        if hum then
            local ok, err = pcall(function()
                hum:ApplyDescription(desc)
            end)
            if ok then
                Notify(
                    "✅ تم نسخ شخصية: " .. targetPlayer.DisplayName,
                    "Copied appearance of: " .. targetPlayer.DisplayName
                )
                if TabOps and TabOps.LogAction then
                    TabOps.LogAction("🪞 نسخ شخصية", "target_mimic", targetPlayer.Name, 65430)
                end
            else
                -- إذا ApplyDescription فشلت، نحاول طريقة بديلة عبر LoadCharacterAppearance
                pcall(function()
                    local appearance = Players:GetCharacterAppearanceAsync(targetUserId)
                    if appearance then
                        -- إزالة الاكسسوارات والملابس الحالية
                        for _, obj in pairs(char:GetChildren()) do
                            if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or obj:IsA("BodyColors") then
                                obj:Destroy()
                            end
                        end
                        -- إضافة الاكسسوارات والملابس الجديدة
                        for _, obj in pairs(appearance:GetChildren()) do
                            if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or obj:IsA("BodyColors") then
                                local clone = obj:Clone()
                                clone.Parent = char
                            end
                        end
                        appearance:Destroy()
                        Notify(
                            "✅ تم نسخ مظهر: " .. targetPlayer.DisplayName,
                            "Appearance copied: " .. targetPlayer.DisplayName
                        )
                    end
                end)
            end
        else
            Notify("❌ شخصيتك غير جاهزة!", "Your character is not ready!")
        end
    end

    -- ============================================================
    -- دالة استعادة المظهر الأصلي
    -- ============================================================
    local function RestoreAppearance()
        local char = lp.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then
            Notify("❌ شخصيتك غير جاهزة!", "Your character is not ready!")
            return
        end

        local ok = pcall(function()
            local originalDesc = Players:GetHumanoidDescriptionFromUserId(lp.UserId)
            hum:ApplyDescription(originalDesc)
        end)

        if ok then
            Notify("🔄 تم استعادة مظهرك الأصلي!", "Original appearance restored!")
        else
            Notify("❌ فشل الاستعادة، حاول Rejoin.", "Restore failed, try rejoining.")
        end
    end

    -- ============================================================
    -- واجهة المستخدم
    -- ============================================================

    -- زر النسخ
    Tab:AddButton("🪞 انسخ شخصية الهدف / Copy Target", function()
        if not _G.ArwaTarget then
            Notify("⚠️ حدد لاعباً أولاً!", "Select a player first!")
            return
        end
        Notify("⏳ جاري نسخ الشخصية...", "Copying appearance, please wait...")
        task.spawn(function()
            ApplyAppearance(_G.ArwaTarget)
        end)
    end)

    -- زر الاستعادة
    Tab:AddButton("🔄 استعادة مظهرك / Restore Appearance", function()
        task.spawn(function()
            RestoreAppearance()
        end)
    end)

end
