-- Local visual optimization. This does not change physics, collision, scripts, or UI.
return function(Tab, UI)
    local Players = game:GetService("Players")
    local Lighting = game:GetService("Lighting")
    local CoreGui = game:GetService("CoreGui")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer

    local i18n = getgenv().CrypticI18n
    local T = (i18n and i18n.T) or function(key) return key end
    local translations = {
        en  = { label = "Smart Anti-Lag (Adaptive)", on = "Smart Anti-Lag enabled. Stronger visual reductions start only if FPS stays low.", off = "Anti-Lag stopped; visual settings restored.", boost_on = "FPS stayed low; map effects reduced. Some visual cues may be hidden.", boost_off = "FPS recovered. Visual effects restored.", mode_off = "OFF", mode_auto = "AUTO", mode_boost = "BOOST" },
        ar  = { label = "مضاد اللاج الذكي (تكيفي)", on = "تم تفعيل مضاد اللاج الذكي؛ يبدأ التخفيف القوي فقط إذا ظل FPS منخفضاً.", off = "تم إيقاف مضاد اللاج واستعادة إعدادات الرسوم.", boost_on = "ظل FPS منخفضاً؛ خُففت مؤثرات الخريطة وقد تختفي بعض العلامات البصرية.", boost_off = "تحسن FPS؛ تمت استعادة المؤثرات البصرية.", mode_off = "إيقاف", mode_auto = "تلقائي", mode_boost = "تعزيز" },
        ru  = { label = "Умный антилаг (адаптивный)", on = "Умный антилаг включён. Сильное снижение графики начнётся, только если FPS останется низким.", off = "Антилаг выключен; настройки графики восстановлены.", boost_on = "FPS долго оставался низким; эффекты карты снижены. Некоторые подсказки могут исчезнуть.", boost_off = "FPS восстановился. Визуальные эффекты возвращены.", mode_off = "ВЫКЛ", mode_auto = "АВТО", mode_boost = "БУСТ" },
        pt  = { label = "Anti-lag inteligente (adaptativo)", on = "Anti-lag inteligente ativado. A redução visual mais forte começa apenas se o FPS continuar baixo.", off = "Anti-lag desligado; configurações visuais restauradas.", boost_on = "O FPS continuou baixo; efeitos do mapa reduzidos. Alguns avisos visuais podem sumir.", boost_off = "O FPS melhorou. Efeitos visuais restaurados.", mode_off = "OFF", mode_auto = "AUTO", mode_boost = "BOOST" },
        es  = { label = "Anti-lag inteligente (adaptativo)", on = "Anti-lag inteligente activado. La reducción visual fuerte solo empieza si el FPS sigue bajo.", off = "Anti-lag desactivado; ajustes visuales restaurados.", boost_on = "El FPS siguió bajo; se redujeron los efectos del mapa. Algunas señales visuales pueden ocultarse.", boost_off = "El FPS mejoró. Efectos visuales restaurados.", mode_off = "OFF", mode_auto = "AUTO", mode_boost = "BOOST" },
        fr  = { label = "Anti-lag intelligent (adaptatif)", on = "Anti-lag activé. La réduction visuelle renforcée commence seulement si le FPS reste bas.", off = "Anti-lag désactivé ; paramètres visuels restaurés.", boost_on = "Le FPS est resté bas ; effets de la carte réduits. Certains indices visuels peuvent disparaître.", boost_off = "Le FPS s’est amélioré. Effets visuels restaurés.", mode_off = "ARRÊT", mode_auto = "AUTO", mode_boost = "BOOST" },
        id  = { label = "Anti-Lag Cerdas (Adaptif)", on = "Anti-Lag cerdas aktif. Pengurangan visual yang lebih kuat hanya dimulai jika FPS tetap rendah.", off = "Anti-Lag mati; pengaturan visual dipulihkan.", boost_on = "FPS tetap rendah; efek peta dikurangi. Beberapa petunjuk visual mungkin hilang.", boost_off = "FPS membaik. Efek visual dipulihkan.", mode_off = "MATI", mode_auto = "AUTO", mode_boost = "BOOST" },
        tr  = { label = "Akıllı Anti-Lag (Uyarlanabilir)", on = "Akıllı Anti-Lag açık. Güçlü görsel azaltma yalnızca FPS düşük kalırsa başlar.", off = "Anti-Lag kapatıldı; görsel ayarlar geri yüklendi.", boost_on = "FPS düşük kaldı; harita efektleri azaltıldı. Bazı görsel ipuçları gizlenebilir.", boost_off = "FPS düzeldi. Görsel efektler geri yüklendi.", mode_off = "KAPALI", mode_auto = "OTO", mode_boost = "GÜÇ" },
        hi  = { label = "स्मार्ट एंटी-लैग (अनुकूली)", on = "स्मार्ट एंटी-लैग चालू। तेज़ दृश्य कमी तभी शुरू होगी जब FPS कम बना रहेगा।", off = "एंटी-लैग बंद; दृश्य सेटिंग्स बहाल।", boost_on = "FPS लगातार कम रहा; मैप के प्रभाव घटाए गए। कुछ दृश्य संकेत छिप सकते हैं।", boost_off = "FPS सुधरा। दृश्य प्रभाव बहाल।", mode_off = "बंद", mode_auto = "ऑटो", mode_boost = "बूस्ट" },
        de  = { label = "Intelligenter Anti-Lag (adaptiv)", on = "Intelligenter Anti-Lag aktiv. Stärkere Grafikeffekte werden nur bei dauerhaft niedrigem FPS reduziert.", off = "Anti-Lag aus; Grafikeinstellungen wiederhergestellt.", boost_on = "FPS blieb niedrig; Karteneffekte reduziert. Einige visuelle Hinweise können fehlen.", boost_off = "FPS erholt. Visuelle Effekte wiederhergestellt.", mode_off = "AUS", mode_auto = "AUTO", mode_boost = "BOOST" },
        uk  = { label = "Розумний Anti-Lag (адаптивний)", on = "Розумний Anti-Lag увімкнено. Сильне зниження графіки почнеться, лише якщо FPS залишатиметься низьким.", off = "Anti-Lag вимкнено; графічні налаштування відновлено.", boost_on = "FPS залишався низьким; ефекти мапи зменшено. Деякі візуальні підказки можуть зникнути.", boost_off = "FPS відновився. Візуальні ефекти повернуто.", mode_off = "ВИМК", mode_auto = "АВТО", mode_boost = "БУСТ" },
        it  = { label = "Anti-lag intelligente (adattivo)", on = "Anti-lag intelligente attivo. La riduzione grafica avanzata parte solo se gli FPS restano bassi.", off = "Anti-lag disattivato; impostazioni grafiche ripristinate.", boost_on = "Gli FPS sono rimasti bassi; effetti della mappa ridotti. Alcuni segnali visivi potrebbero sparire.", boost_off = "FPS migliorati. Effetti visivi ripristinati.", mode_off = "OFF", mode_auto = "AUTO", mode_boost = "BOOST" },
        vi  = { label = "Chống lag thông minh (thích ứng)", on = "Đã bật chống lag thông minh. Chỉ giảm hình ảnh mạnh hơn nếu FPS duy trì ở mức thấp.", off = "Đã tắt chống lag; cài đặt hình ảnh được khôi phục.", boost_on = "FPS vẫn thấp; hiệu ứng bản đồ đã giảm. Một số dấu hiệu hình ảnh có thể bị ẩn.", boost_off = "FPS đã cải thiện. Hiệu ứng hình ảnh được khôi phục.", mode_off = "TẮT", mode_auto = "AUTO", mode_boost = "TĂNG" },
        th  = { label = "ลดแลคอัจฉริยะ (ปรับอัตโนมัติ)", on = "เปิดลดแลคอัจฉริยะ การลดภาพขั้นสูงจะเริ่มเมื่อ FPS ต่ำต่อเนื่องเท่านั้น", off = "ปิดลดแลคแล้ว; คืนค่ากราฟิกแล้ว", boost_on = "FPS ต่ำต่อเนื่อง; ลดเอฟเฟกต์ของแผนที่แล้ว สัญญาณภาพบางอย่างอาจหายไป", boost_off = "FPS ดีขึ้นแล้ว คืนค่าเอฟเฟกต์ภาพแล้ว", mode_off = "ปิด", mode_auto = "ออโต้", mode_boost = "บูสต์" },
        zh  = { label = "智能防卡顿（自适应）", on = "已开启智能防卡顿；只有 FPS 持续偏低时才会加强画面优化。", off = "防卡顿已关闭；画面设置已恢复。", boost_on = "FPS 持续偏低，已减少地图特效；部分视觉提示可能隐藏。", boost_off = "FPS 已恢复；视觉特效已还原。", mode_off = "关闭", mode_auto = "自动", mode_boost = "加速" },
        ko  = { label = "스마트 안티랙 (적응형)", on = "스마트 안티랙이 켜졌습니다. FPS가 계속 낮을 때만 강한 시각 효과 감소가 시작됩니다.", off = "안티랙이 꺼졌고 그래픽 설정이 복원되었습니다.", boost_on = "FPS가 계속 낮아 맵 효과를 줄였습니다. 일부 시각 신호가 숨겨질 수 있습니다.", boost_off = "FPS가 회복되어 시각 효과를 복원했습니다.", mode_off = "끔", mode_auto = "자동", mode_boost = "부스트" },
        fil = { label = "Smart Anti-Lag (Adaptive)", on = "Naka-on ang Smart Anti-Lag. Magsisimula lang ang mas malakas na bawas-biswal kapag nanatiling mababa ang FPS.", off = "Naka-off ang Anti-Lag; naibalik ang mga visual setting.", boost_on = "Nanatiling mababa ang FPS; binawasan ang mga effect sa mapa. Maaaring maitago ang ilang visual cue.", boost_off = "Bumuti ang FPS. Naibalik ang mga visual effect.", mode_off = "OFF", mode_auto = "AUTO", mode_boost = "BOOST" },
        ja  = { label = "スマートアンチラグ（自動調整）", on = "スマートアンチラグを有効にしました。FPSが低い状態で続く場合のみ、強い画質軽減を開始します。", off = "アンチラグを停止し、画質設定を復元しました。", boost_on = "FPS低下が続いたため、マップのエフェクトを軽減しました。一部の視覚的な合図が隠れる場合があります。", boost_off = "FPSが回復しました。視覚効果を復元しました。", mode_off = "オフ", mode_auto = "自動", mode_boost = "強化" },
        pl  = { label = "Inteligentny Anti-Lag (adaptacyjny)", on = "Inteligentny Anti-Lag włączony. Silniejsze ograniczenie grafiki rozpocznie się tylko przy stale niskim FPS.", off = "Anti-Lag wyłączony; ustawienia obrazu przywrócone.", boost_on = "FPS pozostawał niski; ograniczono efekty mapy. Niektóre wskazówki wizualne mogą zniknąć.", boost_off = "FPS wrócił do normy. Efekty wizualne przywrócone.", mode_off = "WYŁ.", mode_auto = "AUTO", mode_boost = "BOOST" },
        tw  = { label = "智慧防卡頓（自動調整）", on = "已啟用智慧防卡頓；只有 FPS 持續偏低時才會加強畫面最佳化。", off = "防卡頓已關閉；畫面設定已還原。", boost_on = "FPS 持續偏低，已減少地圖特效；部分視覺提示可能隱藏。", boost_off = "FPS 已恢復；視覺特效已還原。", mode_off = "關閉", mode_auto = "自動", mode_boost = "加速" },
        nl  = { label = "Slimme anti-lag (adaptief)", on = "Slimme anti-lag staat aan. Sterkere beeldreductie begint alleen als de FPS laag blijft.", off = "Anti-lag uit; beeldinstellingen hersteld.", boost_on = "FPS bleef laag; kaarteffecten verminderd. Sommige visuele aanwijzingen kunnen verdwijnen.", boost_off = "FPS hersteld. Visuele effecten teruggezet.", mode_off = "UIT", mode_auto = "AUTO", mode_boost = "BOOST" },
    }

    if i18n and i18n.Register then
        for code, text in pairs(translations) do
            i18n.Register(code, {
                ["settings.anti_lag.label"] = text.label,
                ["settings.anti_lag.on"] = text.on,
                ["settings.anti_lag.off"] = text.off,
                ["settings.anti_lag.boost_on"] = text.boost_on,
                ["settings.anti_lag.boost_off"] = text.boost_off,
                ["settings.anti_lag.mode_off"] = text.mode_off,
                ["settings.anti_lag.mode_auto"] = text.mode_auto,
                ["settings.anti_lag.mode_boost"] = text.mode_boost,
            })
        end
    end

    local function TT(key, fallback)
        local value = T(key)
        if value == nil or value == key then return fallback end
        return value
    end

    local function Notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = text,
                Duration = 4,
            })
        end)
    end

    local active = false
    local strongMode = false
    local generation = 0
    local modeGeneration = 0
    local connections = {}
    local cameraConnections = {}
    local boundCamera
    local savedEffects = {}
    local seenEffects = setmetatable({}, {__mode = "k"})
    local fpsGui
    local fpsDot
    local fpsLabel
    local fpsModeLabel
    local fpsConnection

    local savedGlobalShadows
    local changedGlobalShadows = false
    local savedTerrainDecoration
    local changedTerrainDecoration = false

    local TOUCH_DEVICE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local LOW_FPS_LIMIT = TOUCH_DEVICE and 35 or 45
    local RECOVER_FPS_LIMIT = TOUCH_DEVICE and 45 or 55
    local LOW_SAMPLES_REQUIRED = 3
    local RECOVER_SAMPLES_REQUIRED = 10
    local MIN_STRONG_SECONDS = 8
    local lowSamples = 0
    local recoverSamples = 0
    local strongModeStartedAt = 0

    local BATCH_SIZE = UserInputService.TouchEnabled and 120 or 350

    local function IsCurrent(token)
        return active and token == generation
    end

    local function IsApplying(token, modeToken)
        return strongMode
            and IsCurrent(token)
            and (modeToken == nil or modeToken == modeGeneration)
    end

    local function DisconnectAll(list)
        for i = #list, 1, -1 do
            pcall(function() list[i]:Disconnect() end)
            list[i] = nil
        end
    end

    local function IsPlayerCharacterEffect(effect)
        local node = effect.Parent
        while node and node ~= Workspace do
            if node:IsA("Model") and Players:GetPlayerFromCharacter(node) then
                return true
            end
            node = node.Parent
        end
        return false
    end

    local function IsVisualEffect(instance)
        local className = instance.ClassName
        return className == "ParticleEmitter"
            or className == "Fire"
            or className == "Smoke"
            or className == "Sparkles"
            or className == "BloomEffect"
            or className == "BlurEffect"
            or className == "ColorCorrectionEffect"
            or className == "DepthOfFieldEffect"
            or className == "SunRaysEffect"
    end

    local function ReduceEffect(instance, token, modeToken)
        if not IsApplying(token, modeToken) or seenEffects[instance] then return end
        if not IsVisualEffect(instance) or IsPlayerCharacterEffect(instance) then return end
        seenEffects[instance] = true

        local ok, wasEnabled = pcall(function() return instance.Enabled end)
        if not ok or wasEnabled ~= true then return end

        local changed = pcall(function() instance.Enabled = false end)
        if changed then savedEffects[instance] = true end
    end

    -- Walk incrementally so a large map does not get scanned in one frame.
    local function ScanRoot(root, token, modeToken)
        if not root or not IsApplying(token, modeToken) then return end

        local ok, children = pcall(function() return root:GetChildren() end)
        if not ok then return end
        local stack = children
        local processed = 0

        while #stack > 0 do
            if not IsApplying(token, modeToken) then return end
            local instance = table.remove(stack)
            ReduceEffect(instance, token, modeToken)

            local childrenOk, descendants = pcall(function()
                return instance:GetChildren()
            end)
            if childrenOk then
                for _, child in ipairs(descendants) do
                    stack[#stack + 1] = child
                end
            end

            processed += 1
            if processed % BATCH_SIZE == 0 then
                task.wait()
            end
        end
    end

    local function ForgetIfDetached(instance, token)
        if not seenEffects[instance] then return end
        task.defer(function()
            if not IsCurrent(token) then return end
            local isDestroyed = false
            pcall(function()
                isDestroyed = instance.Parent == nil
            end)
            if isDestroyed then
                savedEffects[instance] = nil
                seenEffects[instance] = nil
            end
        end)
    end

    local function SetLocalQualityReductions()
        local ok, original = pcall(function() return Lighting.GlobalShadows end)
        if ok then
            savedGlobalShadows = original
            if original then
                local changed = pcall(function() Lighting.GlobalShadows = false end)
                changedGlobalShadows = changed
            end
        end

        local terrainOk, terrain = pcall(function() return Workspace.Terrain end)
        if terrainOk and terrain then
            local decorationOk, originalDecoration = pcall(function()
                return terrain.Decoration
            end)
            if decorationOk then
                savedTerrainDecoration = originalDecoration
                if originalDecoration then
                    local changed = pcall(function() terrain.Decoration = false end)
                    changedTerrainDecoration = changed
                end
            end
        end
    end

    local function RestoreLocalQuality()
        if changedGlobalShadows and savedGlobalShadows ~= nil then
            pcall(function()
                if Lighting.GlobalShadows == false then
                    Lighting.GlobalShadows = savedGlobalShadows
                end
            end)
        end
        changedGlobalShadows = false
        savedGlobalShadows = nil

        if changedTerrainDecoration and savedTerrainDecoration ~= nil then
            pcall(function()
                if Workspace.Terrain.Decoration == false then
                    Workspace.Terrain.Decoration = savedTerrainDecoration
                end
            end)
        end
        changedTerrainDecoration = false
        savedTerrainDecoration = nil
    end

    local function RestoreTrackedEffects()
        for effect, wasEnabled in pairs(savedEffects) do
            pcall(function()
                if effect.Parent and effect.Enabled == false then
                    effect.Enabled = wasEnabled
                end
            end)
        end
        savedEffects = {}
        seenEffects = setmetatable({}, {__mode = "k"})
    end

    local function SetStrongMode(enabled, token)
        if not IsCurrent(token) or strongMode == enabled then return end

        strongMode = enabled
        modeGeneration += 1
        local modeToken = modeGeneration
        lowSamples = 0
        recoverSamples = 0

        if enabled then
            strongModeStartedAt = os.clock()
            SetLocalQualityReductions()
            task.spawn(ScanRoot, Workspace, token, modeToken)
            task.spawn(ScanRoot, Lighting, token, modeToken)

            local camera = Workspace.CurrentCamera
            if camera and not camera:IsDescendantOf(Workspace) then
                task.spawn(ScanRoot, camera, token, modeToken)
            end
            Notify(TT("settings.anti_lag.boost_on", "Strong visual reductions enabled."))
        else
            RestoreTrackedEffects()
            RestoreLocalQuality()
            Notify(TT("settings.anti_lag.boost_off", "Visual effects restored."))
        end
    end

    local function BindCamera(camera, token)
        DisconnectAll(cameraConnections)
        boundCamera = camera
        if not camera then return end

        cameraConnections[#cameraConnections + 1] = camera.DescendantAdded:Connect(function(instance)
            ReduceEffect(instance, token)
        end)
        cameraConnections[#cameraConnections + 1] = camera.DescendantRemoving:Connect(function(instance)
            ForgetIfDetached(instance, token)
        end)
        if strongMode and not camera:IsDescendantOf(Workspace) then
            task.spawn(ScanRoot, camera, token, modeGeneration)
        end
    end

    local function UpdateAdaptiveMode(fps)
        if not active then return end
        local token = generation

        if not strongMode then
            if fps < LOW_FPS_LIMIT then
                lowSamples += 1
            else
                lowSamples = 0
            end
            if lowSamples >= LOW_SAMPLES_REQUIRED then
                SetStrongMode(true, token)
            end
            return
        end

        if fps >= RECOVER_FPS_LIMIT then
            recoverSamples += 1
        else
            recoverSamples = 0
        end
        if recoverSamples >= RECOVER_SAMPLES_REQUIRED
            and os.clock() - strongModeStartedAt >= MIN_STRONG_SECONDS then
            SetStrongMode(false, token)
        end
    end

    local function Start()
        if active then return end
        active = true
        strongMode = false
        generation += 1
        modeGeneration += 1
        local token = generation

        savedEffects = {}
        seenEffects = setmetatable({}, {__mode = "k"})
        lowSamples = 0
        recoverSamples = 0

        connections[#connections + 1] = Workspace.DescendantAdded:Connect(function(instance)
            ReduceEffect(instance, token)
        end)
        connections[#connections + 1] = Workspace.DescendantRemoving:Connect(function(instance)
            ForgetIfDetached(instance, token)
        end)
        connections[#connections + 1] = Lighting.DescendantAdded:Connect(function(instance)
            ReduceEffect(instance, token)
        end)
        connections[#connections + 1] = Lighting.DescendantRemoving:Connect(function(instance)
            ForgetIfDetached(instance, token)
        end)
        connections[#connections + 1] = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
            BindCamera(Workspace.CurrentCamera, token)
        end)

        BindCamera(Workspace.CurrentCamera, token)

        Notify(TT("settings.anti_lag.on", "Smart Anti-Lag enabled; visuals change only if FPS stays low."))
    end

    local function Stop(silent)
        if not active and not strongMode then return end
        active = false
        generation += 1
        modeGeneration += 1
        DisconnectAll(connections)
        DisconnectAll(cameraConnections)
        boundCamera = nil
        strongMode = false
        lowSamples = 0
        recoverSamples = 0
        RestoreTrackedEffects()
        RestoreLocalQuality()
        if not silent then
            Notify(TT("settings.anti_lag.off", "Anti-Lag stopped; visual settings restored."))
        end
    end

    local env = getgenv()
    local previousState = env.CrypticPerformanceState
    if type(previousState) == "table" and type(previousState.Cleanup) == "function" then
        pcall(previousState.Cleanup)
    end

    local function ParentOverlay(gui)
        local parented = false
        pcall(function()
            if type(gethui) == "function" then
                local root = gethui()
                if root then
                    gui.Parent = root
                    parented = gui.Parent ~= nil
                end
            end
        end)
        if parented then return true end

        pcall(function()
            if syn and syn.protect_gui then syn.protect_gui(gui) end
            gui.Parent = CoreGui
            parented = gui.Parent ~= nil
        end)
        if not parented then
            pcall(function()
                gui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5)
                parented = gui.Parent ~= nil
            end)
        end
        return parented
    end

    local function CreateFPSOverlay()
        local gui = Instance.new("ScreenGui")
        gui.Name = "CrypticFPSCounter"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = false
        gui.DisplayOrder = 100
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local panel = Instance.new("Frame")
        panel.Name = "Panel"
        panel.AnchorPoint = Vector2.new(0, 0)
        panel.Position = UDim2.fromOffset(8, 8)
        panel.Size = UDim2.fromOffset(128, 28)
        panel.BackgroundColor3 = Color3.fromRGB(18, 22, 29)
        panel.BackgroundTransparency = 0.16
        panel.BorderSizePixel = 0
        panel.Active = false
        panel.Parent = gui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = panel

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Transparency = 0.84
        stroke.Thickness = 1
        stroke.Parent = panel

        local dot = Instance.new("Frame")
        dot.Name = "StatusDot"
        dot.AnchorPoint = Vector2.new(0, 0.5)
        dot.Position = UDim2.new(0, 9, 0.5, 0)
        dot.Size = UDim2.fromOffset(8, 8)
        dot.BackgroundColor3 = Color3.fromRGB(100, 220, 140)
        dot.BorderSizePixel = 0
        dot.Parent = panel

        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot

        local label = Instance.new("TextLabel")
        label.Name = "FPSValue"
        label.Position = UDim2.new(0, 23, 0, 0)
        label.Size = UDim2.new(0, 51, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamSemibold
        label.Text = "FPS --"
        label.TextColor3 = Color3.fromRGB(240, 244, 250)
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = panel

        local mode = Instance.new("TextLabel")
        mode.Name = "Mode"
        mode.Position = UDim2.new(1, -49, 0, 0)
        mode.Size = UDim2.new(0, 43, 1, 0)
        mode.BackgroundTransparency = 1
        mode.Font = Enum.Font.GothamBold
        mode.Text = TT("settings.anti_lag.mode_off", "OFF")
        mode.TextColor3 = Color3.fromRGB(160, 170, 184)
        mode.TextSize = 9
        mode.TextXAlignment = Enum.TextXAlignment.Right
        mode.Parent = panel

        if not ParentOverlay(gui) then
            pcall(function() gui:Destroy() end)
            return nil, nil, nil, nil
        end
        return gui, dot, label, mode
    end

    fpsGui, fpsDot, fpsLabel, fpsModeLabel = CreateFPSOverlay()

    local sampleFrames = 0
    local sampleElapsed = 0
    fpsConnection = RunService.RenderStepped:Connect(function(dt)
        sampleFrames += 1
        sampleElapsed += dt
        if sampleElapsed < 0.5 then return end

        local fps = math.floor(sampleFrames / sampleElapsed + 0.5)
        sampleFrames = 0
        sampleElapsed = 0
        UpdateAdaptiveMode(fps)

        local fpsColor
        if fps >= 55 then
            fpsColor = Color3.fromRGB(105, 231, 151)
        elseif fps >= 30 then
            fpsColor = Color3.fromRGB(255, 203, 92)
        else
            fpsColor = Color3.fromRGB(255, 105, 105)
        end
        if fpsDot and fpsDot.Parent then fpsDot.BackgroundColor3 = fpsColor end
        if fpsLabel and fpsLabel.Parent then
            fpsLabel.Text = ("FPS %d"):format(fps)
            fpsLabel.TextColor3 = fpsColor
        end
        if fpsModeLabel and fpsModeLabel.Parent then
            local modeKey = strongMode and "settings.anti_lag.mode_boost"
                or (active and "settings.anti_lag.mode_auto" or "settings.anti_lag.mode_off")
            local fallback = strongMode and "BOOST" or (active and "AUTO" or "OFF")
            fpsModeLabel.Text = TT(modeKey, fallback)
            fpsModeLabel.TextColor3 = strongMode
                and Color3.fromRGB(100, 190, 255)
                or (active and Color3.fromRGB(255, 203, 92) or Color3.fromRGB(160, 170, 184))
        end
    end)

    local performanceState = {}
    function performanceState.Cleanup()
        Stop(true)
        if fpsConnection then
            pcall(function() fpsConnection:Disconnect() end)
            fpsConnection = nil
        end
        if fpsGui then
            pcall(function() fpsGui:Destroy() end)
            fpsGui = nil
        end
    end
    env.CrypticPerformanceState = performanceState

    Tab:AddToggle(TT("settings.anti_lag.label", "Smart Anti-Lag (Adaptive)"), function(enabled)
        if enabled then
            Start()
        else
            Stop()
        end
    end)
end
