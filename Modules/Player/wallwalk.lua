-- [[ Cryptic Hub - Wall Walk (Gravity Controller) ]]
-- Localized via i18n. الكي: player.wallwalk.*
--
-- تحكّم كامل بالجاذبية: اتجاه "فوق" للشخصية = السطح اللي تمشي عليه (أرض، جدار، سقف).
-- يشمل: حركة + قفز + كاميرا خاصة (ماوس/لمس/قير) + أنيميشن. وكله يرجع طبيعي لما تطفيه.

return function(Tab, UI)
    local i18n = getgenv().CrypticI18n
    local T    = (i18n and i18n.T) or function(k) return k end

    local Players          = game:GetService("Players")
    local RunService       = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer      = Players.LocalPlayer
    local env              = getgenv()

    -- لو السكربت اشتغل قبل: ننظّف النسخة القديمة أول
    if env.CrypticWallWalkCleanup then pcall(env.CrypticWallWalkCleanup) end

    ----------------------------------------------------------------
    -- إعدادات
    ----------------------------------------------------------------
    local K = {
        -- كشف الأسطح
        STICK         = 2.5,    -- مسافة إضافية للالتصاق بالسطح وانت ماشي
        LAND_TOL      = 0.5,    -- مسافة الهبوط على السطح
        WALL_RAY      = 2.2,    -- أبعد مسافة لكشف جدار قدامك
        WALL_DOT      = 0.82,   -- أقل ميلان يعتبر جدار (أقل = أشد ميلاناً)
        WALL_MIN_UP   = -0.35,  -- ما نتسلق أسطح مقلوبة أكثر من هالحد
        WRAP_AHEAD    = 1.8,    -- كشف الحافة (الالتفاف حول الزاوية)
        WRAP_EXTRA    = 0.5,
        -- الحركة
        UP_RATE       = 8,      -- سرعة دوران الاتجاه "فوق" (أعلى = أسرع)
        ACCEL_GROUND  = 16,
        ACCEL_AIR     = 2.5,
        HOVER_GAIN    = 10,
        HOVER_MAX     = 20,
        MAG_GAIN      = 8,
        MAG_MAX       = 14,
        COYOTE        = 0.15,   -- وقت سماح بعد مفارقة السطح
        AIR_RESET     = 0.7,    -- بعد كم ثانية بالهواء يرجع الاتجاه للطبيعي
        JUMP_COOLDOWN = 0.25,
        TERMINAL      = 250,
        TURN_RATE     = 14,
        EXIT_MAX      = 1.2,    -- أقصى وقت لرجوع الشخصية واقفة عند الإطفاء
        -- الكاميرا
        MAX_PITCH     = math.rad(80),
        MOUSE_X       = 0.002 * math.pi,
        MOUSE_Y       = 0.0015 * math.pi,
        TOUCH_X       = 0.00945 * math.pi,
        TOUCH_Y       = 0.003375 * math.pi,
        PAD_YAW       = 2.4,
        PAD_PITCH     = 1.6,
        FOCUS_UP      = 1.5,
        INVERT_Y      = false,  -- true = قلب اتجاه الكاميرا العمودي
    }

    local RENDER_NAME = "CrypticWallWalkCamera"

    ----------------------------------------------------------------
    -- رياضيات (Vector3 فقط)
    ----------------------------------------------------------------
    local ZERO   = Vector3.new(0, 0, 0)
    local Y_AXIS = Vector3.new(0, 1, 0)

    local function Clamp(x, a, b)
        if x < a then return a elseif x > b then return b end
        return x
    end

    local function IsBad(v)
        return v.X ~= v.X or v.Y ~= v.Y or v.Z ~= v.Z
    end

    -- أي متجه عمودي على v (v لازم يكون Unit)
    local function Perpendicular(v)
        local ref = (math.abs(v.X) < 0.9) and Vector3.new(1, 0, 0) or Vector3.new(0, 0, 1)
        return v:Cross(ref).Unit
    end

    -- تدوير v حول محور (Unit) بزاوية (قاعدة اليد اليمنى)
    local function RotateAround(v, axis, angle)
        local c, s = math.cos(angle), math.sin(angle)
        return v * c + axis:Cross(v) * s + axis * (axis:Dot(v) * (1 - c))
    end

    -- يدوّر "from" باتجاه "to" بنسبة من الزاوية. يرجع: النتيجة، المحور، الزاوية
    local function StepToward(from, to, fraction)
        local dot = Clamp(from:Dot(to), -1, 1)
        local angle = math.acos(dot)
        if angle < 1e-4 then return to, nil, 0 end
        local axis = from:Cross(to)
        if axis.Magnitude < 1e-6 then axis = Perpendicular(from) else axis = axis.Unit end
        local a = angle * fraction
        return RotateAround(from, axis, a).Unit, axis, a
    end

    local function Project(v, up)
        return v - up * v:Dot(up)
    end

    local function NormalizeOr(v, fallback)
        if v.Magnitude > 1e-5 then return v.Unit end
        return fallback
    end

    local function SignedAngle(a, b, up)
        return math.atan2(up:Dot(a:Cross(b)), a:Dot(b))
    end

    local function ClampMag(v, m)
        if v.Magnitude > m then return v.Unit * m end
        return v
    end

    ----------------------------------------------------------------
    -- الحالة
    ----------------------------------------------------------------
    local S = {
        enabled = false, attached = false, exiting = false, token = 0,
        conns = {}, charConns = {}, watchConns = {},
        errCount = 0,
    }
    local toggle

    local function DisconnectList(list)
        for i = #list, 1, -1 do
            pcall(function() list[i]:Disconnect() end)
            list[i] = nil
        end
    end

    ----------------------------------------------------------------
    -- Raycast
    ----------------------------------------------------------------
    local function MakeParams()
        local p = RaycastParams.new()
        p.FilterType = Enum.RaycastFilterType.Exclude
        p.IgnoreWater = true
        pcall(function() p.RespectCanCollide = true end)
        return p
    end
    local rayParams = MakeParams()
    local camParams = MakeParams()

    local function RebuildIgnore()
        local list = {}
        if workspace.CurrentCamera then list[#list + 1] = workspace.CurrentCamera end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then list[#list + 1] = p.Character end
        end
        rayParams.FilterDescendantsInstances = list
        camParams.FilterDescendantsInstances = list
    end

    ----------------------------------------------------------------
    -- مدخلات الحركة (من نظام التحكم الأصلي، بدون ما يتأثر بالكاميرا)
    ----------------------------------------------------------------
    local controls -- nil = لسا ما انحل، false = مو متوفر

    local function ResolveControls()
        if controls ~= nil then return controls end
        controls = false
        pcall(function()
            local scripts = LocalPlayer:WaitForChild("PlayerScripts", 3)
            local module = scripts and scripts:WaitForChild("PlayerModule", 3)
            if module then
                controls = require(module):GetControls() or false
            end
        end)
        return controls
    end

    -- يرجع (x = يمين/يسار، z = ورا/قدام) مثل Humanoid:Move قبل ما يتحول للكاميرا
    local function GetMoveInput()
        if controls then
            local ok, v = pcall(function() return controls:GetMoveVector() end)
            if ok and typeof(v) == "Vector3" and not IsBad(v) then return v end
            return ZERO
        end
        -- بديل: لوحة المفاتيح (لو نظام التحكم الأصلي مو متاح)
        local U = UserInputService
        if U:GetFocusedTextBox() then return ZERO end
        local x, z = 0, 0
        if U:IsKeyDown(Enum.KeyCode.D) or U:IsKeyDown(Enum.KeyCode.Right) then x = x + 1 end
        if U:IsKeyDown(Enum.KeyCode.A) or U:IsKeyDown(Enum.KeyCode.Left)  then x = x - 1 end
        if U:IsKeyDown(Enum.KeyCode.S) or U:IsKeyDown(Enum.KeyCode.Down)  then z = z + 1 end
        if U:IsKeyDown(Enum.KeyCode.W) or U:IsKeyDown(Enum.KeyCode.Up)    then z = z - 1 end
        return Vector3.new(x, 0, z)
    end

    ----------------------------------------------------------------
    -- الأنيميشن (نفس أنيميشن اللعبة، مع تعطيل Animate مؤقتاً)
    ----------------------------------------------------------------
    local DEFAULT_ANIM = {
        R15 = {
            idle = "rbxassetid://507766388", walk = "rbxassetid://507777826",
            jump = "rbxassetid://507765000", fall = "rbxassetid://507767968",
        },
        R6 = {
            idle = "rbxassetid://180435571", walk = "rbxassetid://180426354",
            jump = "rbxassetid://125750702", fall = "rbxassetid://180436148",
        },
    }
    local ANIM_SOURCE = {
        idle = { "idle", "Animation1" }, walk = { "walk", "WalkAnim" },
        jump = { "jump", "JumpAnim" },   fall = { "fall", "FallAnim" },
    }

    local function CleanupAnimations()
        if S.tracks then
            for _, tr in pairs(S.tracks) do
                pcall(function() tr:Stop(0.1) end)
                pcall(function() tr:Destroy() end)
            end
        end
        if S.animObjs then
            for _, a in ipairs(S.animObjs) do pcall(function() a:Destroy() end) end
        end
        if S.animateDisabled then
            pcall(function() S.animateDisabled.Disabled = false end)
        end
        S.tracks, S.animObjs, S.animateDisabled = nil, nil, nil
        S.animReady, S.animCurrent = false, nil
    end

    local function SetupAnimations(token)
        local hum, char = S.hum, S.char
        if not hum or not char then return end
        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then return end
        local animate = char:FindFirstChild("Animate")
        local rig = (hum.RigType == Enum.HumanoidRigType.R6) and "R6" or "R15"

        local tracks, objs = {}, {}
        for name, src in pairs(ANIM_SOURCE) do
            local id
            local folder = animate and animate:FindFirstChild(src[1])
            local child = folder and folder:FindFirstChild(src[2])
            if child and child:IsA("Animation") and child.AnimationId ~= "" then
                id = child.AnimationId
            end
            id = id or DEFAULT_ANIM[rig][name]
            local anim = Instance.new("Animation")
            anim.AnimationId = id
            objs[#objs + 1] = anim
            local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
            if ok and track then
                track.Looped = (name ~= "jump")
                track.Priority = Enum.AnimationPriority.Movement
                tracks[name] = track
            end
        end

        local function loaded()
            return tracks.idle and tracks.walk and tracks.idle.Length > 0 and tracks.walk.Length > 0
        end

        local t0 = os.clock()
        while os.clock() - t0 < 2 and S.token == token and S.attached and not loaded() do
            task.wait(0.1)
        end

        if S.token ~= token or not S.attached or not loaded() then
            for _, tr in pairs(tracks) do pcall(function() tr:Destroy() end) end
            for _, a in ipairs(objs) do pcall(function() a:Destroy() end) end
            return
        end

        -- نوقف Animate الأصلي بس بعد ما تأكدنا إن أنيميشننا جاهز
        if animate and animate:IsA("LocalScript") then
            local ok = pcall(function() animate.Disabled = true end)
            if ok then S.animateDisabled = animate end
        end
        for _, tr in ipairs(animator:GetPlayingAnimationTracks()) do
            local isOurs = false
            for _, mine in pairs(tracks) do if mine == tr then isOurs = true end end
            if not isOurs then pcall(function() tr:Stop(0.1) end) end
        end

        S.tracks, S.animObjs = tracks, objs
        S.animCurrent, S.animReady = nil, true
    end

    local function PlayAnim(name, speed)
        local tr = S.tracks and S.tracks[name]
        if not tr then return end
        if S.animCurrent ~= name then
            local old = S.animCurrent and S.tracks[S.animCurrent]
            if old then old:Stop(0.15) end
            tr:Play(0.15)
            S.animCurrent = name
        end
        if speed then tr:AdjustSpeed(speed) end
    end

    local function UpdateAnimation(planarSpeed, grounded, vUp)
        if not S.animReady then return end
        if not grounded then
            if vUp > 2 then PlayAnim("jump") else PlayAnim("fall") end
        elseif planarSpeed > 1 then
            PlayAnim("walk", Clamp(planarSpeed / 16, 0.3, 2.5))
        else
            PlayAnim("idle")
        end
    end

    ----------------------------------------------------------------
    -- كشف السطح
    ----------------------------------------------------------------
    -- يرجع: found, normal, position
    local function Probe(pos, up, moveUnit, hasInput, now)
        if S.jumpCd > 0 then return false end

        local sc = S.scale
        local grounded = (now - S.lastGround) < K.COYOTE

        -- 1) جدار قدامك (زاوية داخلية): نتسلقه
        if hasInput and grounded then
            local res = workspace:Raycast(pos, moveUnit * (K.WALL_RAY * sc), rayParams)
            if res then
                local nu = res.Normal:Dot(up)
                if nu < K.WALL_DOT and nu > K.WALL_MIN_UP and res.Normal:Dot(moveUnit) < 0 then
                    return true, res.Normal, res.Position
                end
            end
        end

        -- 2) السطح تحتك
        local rdir = grounded and S.surfN or up
        local len = S.standDist + (grounded and (K.STICK * sc) or (K.LAND_TOL * sc))
        local res = workspace:Raycast(pos, -rdir * len, rayParams)
        if not res and grounded then
            res = workspace:Raycast(pos, -up * len, rayParams)
        end
        if res then return true, res.Normal, res.Position end

        -- 3) حافة (زاوية خارجية): نلتف حولها
        if hasInput and grounded then
            local ahead = K.WRAP_AHEAD * sc
            local origin = pos + moveUnit * ahead - up * (S.standDist + 1.0 * sc)
            local res2 = workspace:Raycast(origin, -moveUnit * (ahead + K.WRAP_EXTRA * sc), rayParams)
            if res2 and res2.Normal:Dot(moveUnit) > 0.2 and res2.Normal:Dot(up) > K.WALL_MIN_UP then
                return true, res2.Normal, res2.Position
            end
        end

        return false
    end

    ----------------------------------------------------------------
    -- فصل الشخصية (يرجع كل شي طبيعي)
    ----------------------------------------------------------------
    local function Detach()
        if not S.attached then return end
        S.attached = false
        S.exiting = false
        S.token = S.token + 1

        DisconnectList(S.conns)
        pcall(function() RunService:UnbindFromRenderStep(RENDER_NAME) end)

        local hum, hrp = S.hum, S.hrp

        -- الكاميرا: نرجّعها للوضع الطبيعي بدون ميلان
        local cam = workspace.CurrentCamera
        if cam then
            pcall(function()
                local cf = cam.CFrame
                cam.CFrame = CFrame.lookAt(cf.Position, cf.Position + cf.LookVector)
                cam.CameraType = S.origCamType or Enum.CameraType.Custom
                if hum and hum.Parent then cam.CameraSubject = hum end
            end)
        end

        if S.mouseSet then
            pcall(function() UserInputService.MouseBehavior = Enum.MouseBehavior.Default end)
            S.mouseSet = false
        end
        S.rmb = false
        S.touches = {}

        for _, name in ipairs({ "att", "force", "align" }) do
            if S[name] then
                pcall(function() S[name]:Destroy() end)
                S[name] = nil
            end
        end

        if hum and hum.Parent then
            pcall(function()
                hum.PlatformStand = S.origPlatformStand or false
                hum.AutoRotate = (S.origAutoRotate ~= false)
                if hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
            end)
        end
        if hrp and hrp.Parent then
            pcall(function() hrp.AssemblyAngularVelocity = ZERO end)
        end

        CleanupAnimations()
        S.char, S.hum, S.hrp = nil, nil, nil
    end

    ----------------------------------------------------------------
    -- التحديث الفيزيائي (قبل كل خطوة فيزياء)
    ----------------------------------------------------------------
    local function JumpSpeed(hum)
        if hum.UseJumpPower then return hum.JumpPower end
        return math.sqrt(2 * workspace.Gravity * hum.JumpHeight)
    end

    local function Step(dt)
        if not S.attached then return end
        local hum, hrp = S.hum, S.hrp
        if not (hum and hum.Parent and hrp and hrp.Parent) then return end
        if hum.Health <= 0 then return end

        dt = math.min(dt, 0.1)
        local now = os.clock()

        if now - S.lastIgnore > 1 then
            S.lastIgnore = now
            RebuildIgnore()
        end

        local pos = hrp.Position
        local up  = S.up

        if IsBad(up) or IsBad(pos) or IsBad(S.heading) or IsBad(S.face) then
            S.up, S.targetUp, S.surfN = Y_AXIS, Y_AXIS, Y_AXIS
            S.heading = Vector3.new(0, 0, -1)
            S.face = S.heading
            S.vel = ZERO
            return
        end

        -- مدخلات
        local mv = ZERO
        if not S.exiting then mv = GetMoveInput() end

        local right = S.heading:Cross(up)
        local moveDir = S.heading * (-mv.Z) + right * mv.X
        if moveDir.Magnitude > 1 then moveDir = moveDir.Unit end
        local hasInput = moveDir.Magnitude > 0.05
        local moveUnit = hasInput and moveDir.Unit or nil

        local wantJump = S.jumpQueued
        S.jumpQueued = false
        local held = hum.Jump
        if held and not S.prevJump then wantJump = true end
        S.prevJump = held
        if S.exiting then wantJump = false end

        if S.jumpCd > 0 then S.jumpCd = S.jumpCd - dt end

        -- كشف السطح
        local found, N, P = Probe(pos, up, moveUnit, hasInput, now)
        if found then
            S.lastGround = now
            S.surfN = N
        end
        local grounded = (now - S.lastGround) < K.COYOTE
        if grounded then S.airTime = 0 else S.airTime = S.airTime + dt end

        -- الاتجاه "فوق" الهدف
        local target
        if S.exiting then
            target = Y_AXIS
        elseif found then
            target = N
        elseif grounded then
            target = S.targetUp
        elseif S.airTime > K.AIR_RESET then
            target = Y_AXIS
        else
            target = S.targetUp
        end
        S.targetUp = target

        -- تدوير "فوق" مع نقل كل الاتجاهات معه
        local newUp, axis, ang = StepToward(up, target, 1 - math.exp(-K.UP_RATE * dt))
        if axis then
            S.heading = RotateAround(S.heading, axis, ang)
            S.face    = RotateAround(S.face, axis, ang)
            S.vel     = RotateAround(S.vel, axis, ang)
        end
        up = newUp
        S.up = up
        S.heading = NormalizeOr(Project(S.heading, up), Perpendicular(up))
        S.face    = NormalizeOr(Project(S.face, up), S.heading)

        -- اتجاه الحركة بعد تحديث الإطار
        right = S.heading:Cross(up)
        moveDir = S.heading * (-mv.Z) + right * mv.X
        if moveDir.Magnitude > 1 then moveDir = moveDir.Unit end
        hasInput = moveDir.Magnitude > 0.05

        local targetTan = moveDir * hum.WalkSpeed
        local vApply
        local vUpAnim = 0

        if grounded then
            local vTan = Project(S.vel, up)
            vTan = vTan:Lerp(targetTan, 1 - math.exp(-K.ACCEL_GROUND * dt))
            if not hasInput and vTan.Magnitude < 0.3 then vTan = ZERO end

            if wantJump and S.jumpCd <= 0 then
                local jv = JumpSpeed(hum)
                S.vel = vTan + up * jv
                S.lastGround = -1e9
                S.jumpCd = K.JUMP_COOLDOWN
                S.airTime = 0
                vApply = S.vel
                vUpAnim = jv
                grounded = false
            else
                local hoverVel = ZERO
                if found then
                    local toHover = (P + N * S.standDist) - pos
                    local eN = toHover:Dot(N)
                    local lateral = toHover - N * eN
                    hoverVel = N * Clamp(eN * K.HOVER_GAIN, -K.HOVER_MAX, K.HOVER_MAX)
                        + ClampMag(lateral * K.MAG_GAIN, K.MAG_MAX)
                end
                S.vel = vTan
                vApply = vTan + hoverVel
            end
        else
            -- بالهواء: نبني على السرعة الفعلية (عشان التصادمات تأثر)
            local meas = hrp.AssemblyLinearVelocity
            if IsBad(meas) then meas = ZERO end
            local v = ClampMag(meas, 300)
            local vUp = v:Dot(up)
            local vTan = v - up * vUp
            vTan = vTan:Lerp(targetTan, 1 - math.exp(-K.ACCEL_AIR * dt))
            vUp = math.max(vUp - workspace.Gravity * dt, -K.TERMINAL)
            S.vel = vTan + up * vUp
            vApply = S.vel
            vUpAnim = vUp
        end

        hrp.AssemblyLinearVelocity = vApply

        -- اتجاه النظر (الشخصية تلتفت لجهة الحركة)
        if hasInput then
            local a = SignedAngle(S.face, moveDir.Unit, up)
            S.face = RotateAround(S.face, up, a * (1 - math.exp(-K.TURN_RATE * dt)))
        end
        S.align.CFrame = CFrame.fromMatrix(ZERO, S.face:Cross(up), up)

        -- نلغي جاذبية العالم (جاذبيتنا بنحسبها بنفسنا)
        S.force.Force = Vector3.new(0, hrp.AssemblyMass * workspace.Gravity, 0)

        UpdateAnimation(Project(vApply, up).Magnitude, grounded, vUpAnim)

        -- إنهاء الإطفاء لما الشخصية ترجع واقفة
        if S.exiting and (up:Dot(Y_AXIS) > 0.998 or now - S.exitStart > K.EXIT_MAX) then
            Detach()
        end
    end

    ----------------------------------------------------------------
    -- الكاميرا (بعد كاميرا روبلوكس مباشرة)
    ----------------------------------------------------------------
    local function ZoomLimits()
        local minD = math.max(LocalPlayer.CameraMinZoomDistance, 2)
        local maxD = math.max(LocalPlayer.CameraMaxZoomDistance, minD)
        return minD, maxD
    end

    local function CameraStep(dt)
        if not S.attached then return end
        local cam = workspace.CurrentCamera
        local hrp = S.hrp
        if not cam or not hrp or not hrp.Parent then return end
        dt = math.min(dt, 0.1)

        if cam.CameraType ~= Enum.CameraType.Scriptable then
            cam.CameraType = Enum.CameraType.Scriptable
        end

        local up = S.up

        local yaw, pitchIn = S.inYaw, S.inPitch
        S.inYaw, S.inPitch = 0, 0
        if math.abs(S.padX) > 0.15 then yaw = yaw + S.padX * K.PAD_YAW * dt end
        if math.abs(S.padY) > 0.15 then pitchIn = pitchIn - S.padY * K.PAD_PITCH * dt end

        if yaw ~= 0 then
            S.heading = NormalizeOr(Project(RotateAround(S.heading, up, -yaw), up), S.heading)
        end
        local ySign = K.INVERT_Y and -1 or 1
        S.pitch = Clamp(S.pitch - pitchIn * ySign, -K.MAX_PITCH, K.MAX_PITCH)

        local look = S.heading * math.cos(S.pitch) + up * math.sin(S.pitch)
        local focus = hrp.Position + up * (K.FOCUS_UP * S.scale)

        -- منع الكاميرا من دخول الجدران
        local dist = S.dist
        local d = dist
        local res = workspace:Raycast(focus, -look * dist, camParams)
        if res then
            d = math.max((res.Position - focus).Magnitude - 0.3, 0.5)
        end
        if d < S.curDist then
            S.curDist = d
        else
            S.curDist = S.curDist + (d - S.curDist) * (1 - math.exp(-6 * dt))
        end

        local camPos = focus - look * S.curDist
        cam.CFrame = CFrame.lookAt(camPos, camPos + look, up)
        cam.Focus = CFrame.new(focus)
    end

    ----------------------------------------------------------------
    -- مدخلات الكاميرا (ماوس / لمس / قير)
    ----------------------------------------------------------------
    local function CountTouches()
        local n = 0
        for _ in pairs(S.touches) do n = n + 1 end
        return n
    end

    local function OnInputBegan(input, processed)
        if not S.attached or processed then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.Touch then
            S.touches[input] = true
        elseif t == Enum.UserInputType.MouseButton2 then
            S.rmb = true
            if UserInputService.MouseBehavior == Enum.MouseBehavior.Default then
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
                S.mouseSet = true
            end
        end
    end

    local function OnInputChanged(input, processed)
        if not S.attached then return end

        if input.KeyCode == Enum.KeyCode.Thumbstick2 then
            S.padX, S.padY = input.Position.X, input.Position.Y
            return
        end

        local t = input.UserInputType
        if t == Enum.UserInputType.MouseMovement then
            if S.rmb or UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
                local d = input.Delta
                S.inYaw = S.inYaw + d.X * K.MOUSE_X
                S.inPitch = S.inPitch + d.Y * K.MOUSE_Y
            end
        elseif t == Enum.UserInputType.Touch then
            if S.touches[input] and CountTouches() == 1 then
                local d = input.Delta
                S.inYaw = S.inYaw + d.X * K.TOUCH_X
                S.inPitch = S.inPitch + d.Y * K.TOUCH_Y
            end
        elseif t == Enum.UserInputType.MouseWheel then
            if not processed then
                local minD, maxD = ZoomLimits()
                S.dist = Clamp(S.dist * (1 - 0.12 * input.Position.Z), minD, maxD)
            end
        end
    end

    local function OnInputEnded(input, processed)
        if not S.attached then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.Touch then
            S.touches[input] = nil
        elseif t == Enum.UserInputType.MouseButton2 then
            S.rmb = false
            if S.mouseSet then
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                S.mouseSet = false
            end
        elseif input.KeyCode == Enum.KeyCode.Thumbstick2 then
            S.padX, S.padY = 0, 0
        end
    end

    local function OnPinch(positions, scale, velocity, state, processed)
        if not S.attached or processed then return end
        if state == Enum.UserInputState.Begin then
            S.pinchStart = S.dist
        elseif state == Enum.UserInputState.Change and S.pinchStart and scale > 0.01 then
            local minD, maxD = ZoomLimits()
            S.dist = Clamp(S.pinchStart / scale, minD, maxD)
        end
    end

    ----------------------------------------------------------------
    -- حماية من الأخطاء المتكررة (لو صار شي غير متوقع نطفي بأمان)
    ----------------------------------------------------------------
    local function Guard(fn, arg)
        local ok, err = pcall(fn, arg)
        if ok then
            S.errCount = 0
            return
        end
        S.errCount = S.errCount + 1
        if S.errCount >= 5 then
            warn("Cryptic Hub: Wall Walk stopped after repeated errors - " .. tostring(err))
            S.enabled = false
            task.defer(function()
                Detach()
                if toggle then pcall(function() toggle:SetState(false) end) end
            end)
        end
    end

    ----------------------------------------------------------------
    -- ربط الشخصية
    ----------------------------------------------------------------
    local function Attach(char)
        if S.attached then Detach() end
        S.token = S.token + 1
        local token = S.token

        local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
        local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
        if not hum or not hrp then return end

        ResolveControls() -- ممكن ينتظر شوي

        if S.token ~= token or not S.enabled or LocalPlayer.Character ~= char then return end
        if hum.Health <= 0 or hum.SeatPart then return end
        local cam = workspace.CurrentCamera
        if not cam then return end

        -- ارتفاع الوقوف (من مركز الشخصية للسطح)
        local sc = hrp.Size.Y / 2
        if sc < 0.1 then sc = 1 end
        local legExtra = 0
        if hum.RigType == Enum.HumanoidRigType.R6 then
            local leg = char:FindFirstChild("Left Leg")
            if leg and leg:IsA("BasePart") then legExtra = leg.Size.Y end
        end
        local standDist = hrp.Size.Y / 2 + hum.HipHeight + legExtra
        local wasGrounded = hum.FloorMaterial ~= Enum.Material.Air

        RebuildIgnore()
        if wasGrounded then
            local r = workspace:Raycast(hrp.Position, Vector3.new(0, -(standDist + 3), 0), rayParams)
            if r then
                local m = (r.Position - hrp.Position).Magnitude
                if math.abs(m - standDist) < 1.5 then standDist = m end
            end
        end

        -- حالة الكاميرا الأولية (نحافظ على اتجاهها وبعدها الحالي)
        local camLook = cam.CFrame.LookVector
        local hrpLook = hrp.CFrame.LookVector
        local hrpFlat = NormalizeOr(Vector3.new(hrpLook.X, 0, hrpLook.Z), Vector3.new(0, 0, -1))
        local heading = NormalizeOr(Vector3.new(camLook.X, 0, camLook.Z), hrpFlat)
        local pitch = Clamp(math.asin(Clamp(camLook.Y, -1, 1)), -K.MAX_PITCH, K.MAX_PITCH)
        local minD, maxD = ZoomLimits()
        local d0 = Clamp((cam.CFrame.Position - (hrp.Position + Y_AXIS * K.FOCUS_UP * sc)).Magnitude, minD, maxD)

        S.char, S.hum, S.hrp = char, hum, hrp
        S.scale, S.standDist = sc, standDist
        S.up, S.targetUp, S.surfN = Y_AXIS, Y_AXIS, Y_AXIS
        S.heading, S.face = heading, hrpFlat
        S.pitch, S.dist, S.curDist = pitch, d0, d0
        S.vel = hrp.AssemblyLinearVelocity
        S.lastGround = wasGrounded and os.clock() or -1e9
        S.airTime, S.jumpCd = 0, 0
        S.prevJump, S.jumpQueued = false, false
        S.inYaw, S.inPitch, S.padX, S.padY = 0, 0, 0, 0
        S.touches, S.rmb, S.mouseSet, S.pinchStart = {}, false, false, nil
        S.exiting = false
        S.lastIgnore = os.clock()
        S.origPlatformStand = hum.PlatformStand
        S.origAutoRotate = hum.AutoRotate
        S.origCamType = cam.CameraType
        S.errCount = 0

        -- أدوات الفيزياء: نلغي جاذبية العالم + نثبّت الاتجاه
        local att = Instance.new("Attachment")
        att.Name = "CrypticWallWalkAttachment"
        att.Parent = hrp

        local force = Instance.new("VectorForce")
        force.Name = "CrypticWallWalkForce"
        force.Attachment0 = att
        force.RelativeTo = Enum.ActuatorRelativeTo.World
        force.ApplyAtCenterOfMass = true
        force.Force = Vector3.new(0, hrp.AssemblyMass * workspace.Gravity, 0)
        force.Parent = hrp

        local align = Instance.new("AlignOrientation")
        align.Name = "CrypticWallWalkAlign"
        align.Mode = Enum.OrientationAlignmentMode.OneAttachment
        align.Attachment0 = att
        align.RigidityEnabled = false
        align.ReactionTorqueEnabled = false
        align.MaxTorque = 1e9
        align.Responsiveness = 200
        pcall(function() align.MaxAngularVelocity = math.huge end)
        local cf0 = hrp.CFrame
        align.CFrame = CFrame.fromMatrix(ZERO, cf0.RightVector, cf0.UpVector)
        align.Parent = hrp

        S.att, S.force, S.align = att, force, align

        hum.PlatformStand = true
        hum.AutoRotate = false
        cam.CameraType = Enum.CameraType.Scriptable

        local conns = {}
        conns[#conns + 1] = RunService.Stepped:Connect(function(_, dt) Guard(Step, dt) end)
        RunService:BindToRenderStep(RENDER_NAME, Enum.RenderPriority.Camera.Value + 1, function(dt)
            Guard(CameraStep, dt)
        end)
        conns[#conns + 1] = UserInputService.InputBegan:Connect(OnInputBegan)
        conns[#conns + 1] = UserInputService.InputChanged:Connect(OnInputChanged)
        conns[#conns + 1] = UserInputService.InputEnded:Connect(OnInputEnded)
        conns[#conns + 1] = UserInputService.TouchPinch:Connect(OnPinch)
        conns[#conns + 1] = UserInputService.JumpRequest:Connect(function() S.jumpQueued = true end)
        conns[#conns + 1] = hum.Died:Connect(function() Detach() end)
        conns[#conns + 1] = hum:GetPropertyChangedSignal("SeatPart"):Connect(function()
            if hum.SeatPart then Detach() end
        end)
        conns[#conns + 1] = char.AncestryChanged:Connect(function()
            if not char:IsDescendantOf(game) then Detach() end
        end)
        S.conns = conns
        S.attached = true

        task.spawn(SetupAnimations, token)
    end

    local function WatchCharacter(char)
        DisconnectList(S.watchConns)
        task.spawn(function()
            local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 10)
            if not hum or not S.enabled or LocalPlayer.Character ~= char then return end

            -- لو نزل من الكرسي نرجّع التحكم
            S.watchConns[#S.watchConns + 1] = hum:GetPropertyChangedSignal("SeatPart"):Connect(function()
                if S.enabled and not S.attached and not hum.SeatPart then
                    task.spawn(Attach, char)
                end
            end)

            if not hum.SeatPart then Attach(char) end
        end)
    end

    ----------------------------------------------------------------
    -- تشغيل / إطفاء
    ----------------------------------------------------------------
    local function Enable()
        if S.enabled then return end
        S.enabled = true
        DisconnectList(S.charConns)
        S.charConns[#S.charConns + 1] = LocalPlayer.CharacterAdded:Connect(WatchCharacter)
        if LocalPlayer.Character then WatchCharacter(LocalPlayer.Character) end
    end

    local function Disable()
        if not S.enabled then return end
        S.enabled = false
        DisconnectList(S.charConns)
        DisconnectList(S.watchConns)
        S.token = S.token + 1 -- يلغي أي تركيب لسا ما خلص
        if S.attached then
            if S.up:Dot(Y_AXIS) > 0.998 then
                Detach()
            else
                S.exiting = true          -- ترجع واقفة بسلاسة وبعدها ينفصل
                S.exitStart = os.clock()
            end
        end
    end

    env.CrypticWallWalkCleanup = function()
        S.enabled = false
        DisconnectList(S.charConns)
        DisconnectList(S.watchConns)
        Detach()
        env.CrypticWallWalkCleanup = nil
    end

    toggle = Tab:AddToggle(T("player.wallwalk.label"), function(state)
        if state then Enable() else Disable() end
    end)
end