-- [[ Cryptic Hub - Map: Attack on Titan (DxZ Edition) ]]
-- جميع ميزات DxZHub (فارم + غاز/سيوف + غارات + ويب هوك) مدمجة في واجهة Cryptic Hub
-- نفس بنية قسم MM2: return { Name, Render } + أقسام قابلة للطي + 21 لغة

-- ============================================================
-- 1. الترجمات (ترتيب المفاتيح ثابت، كل لغة = 36 نص بنفس الترتيب)
-- ============================================================
local KEYS = {
    "sec.farm", "sec.adjust", "sec.skills", "sec.raid", "sec.player", "sec.webhook",
    "autofarm", "multihit", "retry", "skip", "noclip", "reload", "chest", "chestred",
    "titans", "left", "slain", "session", "stages", "scan",
    "height", "speed", "multicount", "humskills", "awaken", "raidweak", "watchdog",
    "nokill", "bossnokill", "runspeed", "jump", "antiafk",
    "whon", "whhide", "whtest", "stopall",
}

local L = {
    en  = { "Auto Farm", "Adjustments", "Skills", "Raid / Anti-Stuck", "Movement", "Discord Webhook",
            "Auto Farm", "Multi Hit (gather napes)", "Auto Retry", "Auto Skip", "Noclip while flying", "Auto Reload Blades / Gas", "Auto Open Chest", "Pick Red Chest (else Purple)",
            "Titans", "left", "slain", "Session", "stages", "Scan Titans",
            "Height above head", "Fly Speed", "Multi Hit: napes (1-9)", "Auto Human Skills", "Use Awakening Skill", "Raid Boss: hit marked limb", "Anti-Stuck (no kills)",
            "No kill for (min)", "With raid boss (min)", "Run Speed", "Jump Power", "Anti AFK",
            "Send after each stage / raid", "Hide player name", "Send Test", "Stop All" },
    ar  = { "الفارم التلقائي", "الإعدادات", "المهارات", "الغارة / مكافحة التعليق", "الحركة", "ويب هوك ديسكورد",
            "فارم تلقائي", "ضربات متعددة (تجميع النيب)", "إعادة المحاولة تلقائياً", "تخطي تلقائي", "اختراق الجدران أثناء الطيران", "تبديل السيوف / تعبئة الغاز تلقائياً", "فتح الصندوق تلقائياً", "اختيار الصندوق الأحمر (وإلا البنفسجي)",
            "العمالقة", "متبقي", "تم قتل", "الجلسة", "مراحل", "فحص العمالقة",
            "الارتفاع فوق الرأس", "سرعة الطيران", "الضربات المتعددة: عدد النيب (1-9)", "مهارات الإنسان تلقائياً", "استخدام مهارة اليقظة", "زعيم الغارة: ضرب العضو المعلّم", "مكافحة التعليق (بدون قتل)",
            "بدون قتل لمدة (دقيقة)", "مع زعيم الغارة (دقيقة)", "سرعة الركض", "قوة القفز", "مضاد الـ AFK",
            "إرسال بعد كل مرحلة / غارة", "إخفاء اسم اللاعب", "إرسال تجريبي", "إيقاف الكل" },
    ru  = { "Авто-фарм", "Настройки", "Навыки", "Рейд / анти-зависание", "Движение", "Discord вебхук",
            "Авто-фарм", "Мульти-удар (сбор нап)", "Авто-повтор", "Авто-пропуск", "Noclip в полёте", "Авто-смена клинков / газ", "Авто-открытие сундука", "Красный сундук (иначе фиолетовый)",
            "Титаны", "осталось", "убито", "Сессия", "уровней", "Скан титанов",
            "Высота над головой", "Скорость полёта", "Мульти-удар: нап (1-9)", "Авто-навыки человека", "Навык пробуждения", "Босс рейда: бить отмеченную часть", "Анти-зависание (нет убийств)",
            "Без убийств (мин)", "С боссом рейда (мин)", "Скорость бега", "Сила прыжка", "Анти-AFK",
            "Отправлять после уровня / рейда", "Скрыть имя игрока", "Тестовая отправка", "Остановить всё" },
    pt  = { "Auto Farm", "Ajustes", "Habilidades", "Raid / Anti-Travamento", "Movimento", "Webhook do Discord",
            "Auto Farm", "Multi Hit (juntar nucas)", "Tentar de novo auto", "Pular auto", "Noclip ao voar", "Trocar lâminas / gás auto", "Abrir baú auto", "Baú vermelho (senão roxo)",
            "Titãs", "restantes", "abatidos", "Sessão", "fases", "Escanear Titãs",
            "Altura acima da cabeça", "Velocidade de voo", "Multi Hit: nucas (1-9)", "Habilidades humanas auto", "Usar habilidade de despertar", "Chefe da raid: atacar parte marcada", "Anti-travamento (sem abates)",
            "Sem abates por (min)", "Com chefe da raid (min)", "Velocidade de corrida", "Força do pulo", "Anti AFK",
            "Enviar após cada fase / raid", "Ocultar nome do jogador", "Enviar teste", "Parar tudo" },
    es  = { "Auto Farm", "Ajustes", "Habilidades", "Raid / Anti-atasco", "Movimiento", "Webhook de Discord",
            "Auto Farm", "Multi Hit (juntar nucas)", "Reintentar auto", "Saltar auto", "Noclip al volar", "Cambiar hojas / gas auto", "Abrir cofre auto", "Cofre rojo (si no, morado)",
            "Titanes", "restantes", "eliminados", "Sesión", "niveles", "Escanear Titanes",
            "Altura sobre la cabeza", "Velocidad de vuelo", "Multi Hit: nucas (1-9)", "Habilidades humanas auto", "Usar habilidad de despertar", "Jefe de raid: golpear parte marcada", "Anti-atasco (sin bajas)",
            "Sin bajas durante (min)", "Con jefe de raid (min)", "Velocidad de carrera", "Fuerza de salto", "Anti AFK",
            "Enviar tras cada nivel / raid", "Ocultar nombre del jugador", "Enviar prueba", "Detener todo" },
    fr  = { "Auto Farm", "Réglages", "Compétences", "Raid / Anti-blocage", "Déplacement", "Webhook Discord",
            "Auto Farm", "Multi Hit (regrouper les nuques)", "Réessai auto", "Passer auto", "Noclip en vol", "Lames / gaz auto", "Ouvrir coffre auto", "Coffre rouge (sinon violet)",
            "Titans", "restants", "tués", "Session", "niveaux", "Scanner les Titans",
            "Hauteur au-dessus de la tête", "Vitesse de vol", "Multi Hit : nuques (1-9)", "Compétences humaines auto", "Utiliser l'éveil", "Boss de raid : frapper la partie marquée", "Anti-blocage (aucun kill)",
            "Sans kill pendant (min)", "Avec boss de raid (min)", "Vitesse de course", "Puissance de saut", "Anti AFK",
            "Envoyer après chaque niveau / raid", "Masquer le nom du joueur", "Envoyer un test", "Tout arrêter" },
    id  = { "Auto Farm", "Pengaturan", "Skill", "Raid / Anti-Macet", "Gerakan", "Webhook Discord",
            "Auto Farm", "Multi Hit (kumpulkan tengkuk)", "Coba Lagi Otomatis", "Lewati Otomatis", "Noclip saat terbang", "Ganti Pedang / Gas Otomatis", "Buka Peti Otomatis", "Peti Merah (jika tidak, Ungu)",
            "Titan", "tersisa", "terbunuh", "Sesi", "tahap", "Pindai Titan",
            "Tinggi di atas kepala", "Kecepatan Terbang", "Multi Hit: tengkuk (1-9)", "Skill Manusia Otomatis", "Pakai Skill Awakening", "Bos Raid: serang bagian bertanda", "Anti-Macet (tanpa kill)",
            "Tanpa kill selama (menit)", "Dengan bos raid (menit)", "Kecepatan Lari", "Kekuatan Lompat", "Anti AFK",
            "Kirim setiap tahap / raid", "Sembunyikan nama pemain", "Kirim Tes", "Hentikan Semua" },
    tr  = { "Oto Farm", "Ayarlar", "Yetenekler", "Raid / Takılma Önleme", "Hareket", "Discord Webhook",
            "Oto Farm", "Multi Hit (ense toplama)", "Otomatik Tekrar", "Otomatik Atla", "Uçarken Noclip", "Oto Bıçak / Gaz Yenile", "Sandığı Otomatik Aç", "Kırmızı Sandık (yoksa Mor)",
            "Titanlar", "kalan", "öldürülen", "Oturum", "bölüm", "Titanları Tara",
            "Baş Üstü Yükseklik", "Uçuş Hızı", "Multi Hit: ense (1-9)", "Oto İnsan Yetenekleri", "Uyanış Yeteneğini Kullan", "Raid Boss: işaretli uzvu vur", "Takılma Önleme (öldürme yok)",
            "Öldürmesiz süre (dk)", "Raid boss varken (dk)", "Koşu Hızı", "Zıplama Gücü", "Anti AFK",
            "Her bölüm / raid sonrası gönder", "Oyuncu adını gizle", "Test Gönder", "Hepsini Durdur" },
    hi  = { "ऑटो फार्म", "सेटिंग्स", "स्किल्स", "रेड / अटकने से बचाव", "मूवमेंट", "डिस्कॉर्ड वेबहुक",
            "ऑटो फार्म", "मल्टी हिट (नेप जमा करें)", "ऑटो रीट्राई", "ऑटो स्किप", "उड़ते समय Noclip", "ऑटो ब्लेड / गैस रिफिल", "ऑटो चेस्ट खोलें", "लाल चेस्ट चुनें (वरना बैंगनी)",
            "टाइटन", "बचे", "मारे", "सेशन", "स्टेज", "टाइटन स्कैन",
            "सिर के ऊपर ऊँचाई", "उड़ने की गति", "मल्टी हिट: नेप (1-9)", "ऑटो ह्यूमन स्किल", "अवेकनिंग स्किल इस्तेमाल करें", "रेड बॉस: निशान वाला अंग मारें", "अटकने से बचाव (कोई किल नहीं)",
            "बिना किल के (मिनट)", "रेड बॉस के साथ (मिनट)", "दौड़ने की गति", "कूद की शक्ति", "Anti AFK",
            "हर स्टेज / रेड के बाद भेजें", "खिलाड़ी का नाम छिपाएं", "टेस्ट भेजें", "सब रोकें" },
    de  = { "Auto-Farm", "Einstellungen", "Fähigkeiten", "Raid / Anti-Hänger", "Bewegung", "Discord-Webhook",
            "Auto-Farm", "Multi Hit (Nacken sammeln)", "Auto-Wiederholen", "Auto-Überspringen", "Noclip beim Fliegen", "Klingen / Gas auto nachfüllen", "Truhe auto öffnen", "Rote Truhe (sonst Lila)",
            "Titanen", "übrig", "besiegt", "Sitzung", "Stufen", "Titanen scannen",
            "Höhe über dem Kopf", "Fluggeschwindigkeit", "Multi Hit: Nacken (1-9)", "Auto Menschen-Fähigkeiten", "Erwachen-Fähigkeit nutzen", "Raid-Boss: markiertes Glied treffen", "Anti-Hänger (keine Kills)",
            "Keine Kills seit (Min)", "Mit Raid-Boss (Min)", "Laufgeschwindigkeit", "Sprungkraft", "Anti AFK",
            "Nach jeder Stufe / Raid senden", "Spielernamen verbergen", "Test senden", "Alles stoppen" },
    uk  = { "Авто-фарм", "Налаштування", "Навички", "Рейд / анти-зависання", "Рух", "Discord вебхук",
            "Авто-фарм", "Мульти-удар (збір нап)", "Авто-повтор", "Авто-пропуск", "Noclip під час польоту", "Авто-заміна клинків / газ", "Авто-відкриття скрині", "Червона скриня (інакше фіолетова)",
            "Титани", "залишилось", "вбито", "Сесія", "рівнів", "Скан титанів",
            "Висота над головою", "Швидкість польоту", "Мульти-удар: нап (1-9)", "Авто-навички людини", "Навичка пробудження", "Бос рейду: бити позначену частину", "Анти-зависання (без вбивств)",
            "Без вбивств (хв)", "З босом рейду (хв)", "Швидкість бігу", "Сила стрибка", "Anti AFK",
            "Надсилати після рівня / рейду", "Сховати ім'я гравця", "Тестова відправка", "Зупинити все" },
    it  = { "Auto Farm", "Impostazioni", "Abilità", "Raid / Anti-blocco", "Movimento", "Webhook Discord",
            "Auto Farm", "Multi Hit (raduna le nuche)", "Riprova auto", "Salta auto", "Noclip in volo", "Cambio lame / gas auto", "Apri forziere auto", "Forziere rosso (altrimenti viola)",
            "Giganti", "rimasti", "abbattuti", "Sessione", "livelli", "Scansiona Giganti",
            "Altezza sopra la testa", "Velocità di volo", "Multi Hit: nuche (1-9)", "Abilità umane auto", "Usa abilità di risveglio", "Boss raid: colpisci la parte segnata", "Anti-blocco (nessun kill)",
            "Senza kill per (min)", "Con boss raid (min)", "Velocità di corsa", "Forza di salto", "Anti AFK",
            "Invia dopo ogni livello / raid", "Nascondi nome giocatore", "Invia test", "Ferma tutto" },
    vi  = { "Tự động Farm", "Điều chỉnh", "Kỹ năng", "Raid / Chống kẹt", "Di chuyển", "Webhook Discord",
            "Tự động Farm", "Multi Hit (gom gáy)", "Tự thử lại", "Tự bỏ qua", "Noclip khi bay", "Tự thay kiếm / nạp gas", "Tự mở rương", "Chọn rương đỏ (không thì tím)",
            "Titan", "còn lại", "đã chém", "Phiên", "màn", "Quét Titan",
            "Cao hơn đầu", "Tốc độ bay", "Multi Hit: số gáy (1-9)", "Tự dùng kỹ năng người", "Dùng kỹ năng thức tỉnh", "Boss raid: đánh chi có dấu", "Chống kẹt (lâu không kill)",
            "Không kill quá (phút)", "Khi có boss raid (phút)", "Tốc độ chạy", "Lực nhảy", "Anti AFK",
            "Gửi sau mỗi màn / raid", "Ẩn tên người chơi", "Gửi thử", "Dừng tất cả" },
    th  = { "ออโต้ฟาร์ม", "การปรับแต่ง", "สกิล", "เรด / กันค้าง", "การเคลื่อนไหว", "Discord Webhook",
            "ออโต้ฟาร์ม", "Multi Hit (รวมต้นคอ)", "ลองใหม่อัตโนมัติ", "ข้ามอัตโนมัติ", "Noclip ขณะบิน", "เปลี่ยนดาบ / เติมแก๊สอัตโนมัติ", "เปิดหีบอัตโนมัติ", "เลือกหีบแดง (ไม่งั้นม่วง)",
            "ไททัน", "เหลือ", "ฆ่าแล้ว", "เซสชัน", "ด่าน", "สแกนไททัน",
            "ความสูงเหนือหัว", "ความเร็วบิน", "Multi Hit: จำนวนต้นคอ (1-9)", "สกิลมนุษย์อัตโนมัติ", "ใช้สกิลตื่นพลัง", "บอสเรด: ตีส่วนที่มีเครื่องหมาย", "กันค้าง (ไม่มีการฆ่า)",
            "ไม่ฆ่านาน (นาที)", "เมื่อมีบอสเรด (นาที)", "ความเร็ววิ่ง", "พลังกระโดด", "Anti AFK",
            "ส่งหลังจบทุกด่าน / เรด", "ซ่อนชื่อผู้เล่น", "ส่งทดสอบ", "หยุดทั้งหมด" },
    zh  = { "自动刷怪", "调整", "技能", "突袭 / 防卡死", "移动", "Discord Webhook",
            "自动刷怪", "多段攻击（聚集后颈）", "自动重试", "自动跳过", "飞行时穿墙", "自动换刀 / 补充气体", "自动开箱", "选择红色宝箱（否则紫色）",
            "巨人", "剩余", "已击杀", "本次", "关卡", "扫描巨人",
            "头顶高度", "飞行速度", "多段攻击：后颈数量 (1-9)", "自动人类技能", "使用觉醒技能", "突袭首领：攻击标记部位", "防卡死（长时间无击杀）",
            "无击杀超过（分钟）", "有突袭首领时（分钟）", "奔跑速度", "跳跃力量", "防挂机",
            "每关 / 突袭结束后发送", "隐藏玩家名称", "发送测试", "全部停止" },
    ko  = { "자동 파밍", "조정", "스킬", "레이드 / 멈춤 방지", "이동", "디스코드 웹훅",
            "자동 파밍", "멀티 히트 (목덜미 모으기)", "자동 재도전", "자동 건너뛰기", "비행 중 노클립", "자동 칼날 교체 / 가스 충전", "자동 상자 열기", "빨간 상자 선택 (아니면 보라)",
            "타이탄", "남음", "처치", "세션", "스테이지", "타이탄 스캔",
            "머리 위 높이", "비행 속도", "멀티 히트: 목덜미 수 (1-9)", "자동 인간 스킬", "각성 스킬 사용", "레이드 보스: 표시된 부위 공격", "멈춤 방지 (처치 없음)",
            "처치 없이 (분)", "레이드 보스 있을 때 (분)", "달리기 속도", "점프력", "Anti AFK",
            "스테이지 / 레이드마다 전송", "플레이어 이름 숨기기", "테스트 전송", "모두 중지" },
    fil = { "Auto Farm", "Mga Setting", "Mga Skill", "Raid / Anti-Stuck", "Galaw", "Discord Webhook",
            "Auto Farm", "Multi Hit (tipunin ang batok)", "Auto Retry", "Auto Skip", "Noclip habang lumilipad", "Auto Palit Blade / Gas", "Auto Buksan ang Chest", "Pulang Chest (kung hindi, Lila)",
            "Titan", "natira", "napatay", "Session", "stage", "I-scan ang Titan",
            "Taas sa ulo", "Bilis ng Lipad", "Multi Hit: bilang ng batok (1-9)", "Auto Skill ng Tao", "Gamitin ang Awakening", "Raid Boss: tamaan ang may marka", "Anti-Stuck (walang kill)",
            "Walang kill nang (min)", "Kapag may raid boss (min)", "Bilis ng Takbo", "Lakas ng Talon", "Anti AFK",
            "Ipadala kada stage / raid", "Itago ang pangalan", "Magpadala ng Test", "Itigil Lahat" },
    ja  = { "オートファーム", "調整", "スキル", "レイド / スタック防止", "移動", "Discord Webhook",
            "オートファーム", "マルチヒット（うなじを集める）", "自動リトライ", "自動スキップ", "飛行中ノークリップ", "自動ブレード交換 / ガス補充", "自動で宝箱を開ける", "赤い宝箱を選ぶ（なければ紫）",
            "巨人", "残り", "討伐", "セッション", "ステージ", "巨人をスキャン",
            "頭上の高さ", "飛行速度", "マルチヒット：うなじ数 (1-9)", "人間スキル自動使用", "覚醒スキルを使う", "レイドボス：印のある部位を攻撃", "スタック防止（討伐なし）",
            "討伐なし（分）", "レイドボスがいる時（分）", "走る速度", "ジャンプ力", "AFK防止",
            "ステージ / レイドごとに送信", "プレイヤー名を隠す", "テスト送信", "すべて停止" },
    pl  = { "Auto Farm", "Ustawienia", "Umiejętności", "Rajd / Anty-zacięcie", "Ruch", "Webhook Discord",
            "Auto Farm", "Multi Hit (zbierz karki)", "Auto Ponów", "Auto Pomiń", "Noclip podczas lotu", "Auto wymiana ostrzy / gaz", "Auto otwieranie skrzyni", "Czerwona skrzynia (inaczej fioletowa)",
            "Tytani", "pozostało", "pokonano", "Sesja", "poziomów", "Skanuj Tytanów",
            "Wysokość nad głową", "Prędkość lotu", "Multi Hit: karki (1-9)", "Auto umiejętności człowieka", "Użyj umiejętności przebudzenia", "Boss rajdu: bij oznaczoną część", "Anty-zacięcie (brak zabójstw)",
            "Bez zabójstw przez (min)", "Z bossem rajdu (min)", "Prędkość biegu", "Siła skoku", "Anti AFK",
            "Wysyłaj po każdym poziomie / rajdzie", "Ukryj nazwę gracza", "Wyślij test", "Zatrzymaj wszystko" },
    tw  = { "自動刷怪", "調整", "技能", "突襲 / 防卡死", "移動", "Discord Webhook",
            "自動刷怪", "多段攻擊（聚集後頸）", "自動重試", "自動跳過", "飛行時穿牆", "自動換刀 / 補充瓦斯", "自動開箱", "選擇紅色寶箱（否則紫色）",
            "巨人", "剩餘", "已擊殺", "本次", "關卡", "掃描巨人",
            "頭頂高度", "飛行速度", "多段攻擊：後頸數量 (1-9)", "自動人類技能", "使用覺醒技能", "突襲首領：攻擊標記部位", "防卡死（長時間無擊殺）",
            "無擊殺超過（分鐘）", "有突襲首領時（分鐘）", "奔跑速度", "跳躍力量", "防掛機",
            "每關 / 突襲結束後發送", "隱藏玩家名稱", "發送測試", "全部停止" },
    nl  = { "Auto Farm", "Instellingen", "Vaardigheden", "Raid / Anti-vastloper", "Beweging", "Discord-webhook",
            "Auto Farm", "Multi Hit (nekken verzamelen)", "Auto Opnieuw", "Auto Overslaan", "Noclip tijdens vliegen", "Auto messen / gas verversen", "Kist auto openen", "Rode kist (anders paars)",
            "Titans", "over", "verslagen", "Sessie", "levels", "Titans scannen",
            "Hoogte boven hoofd", "Vliegsnelheid", "Multi Hit: nekken (1-9)", "Auto menselijke vaardigheden", "Ontwakingsvaardigheid gebruiken", "Raidbaas: gemarkeerd lid raken", "Anti-vastloper (geen kills)",
            "Geen kills gedurende (min)", "Met raidbaas (min)", "Loopsnelheid", "Sprongkracht", "Anti AFK",
            "Versturen na elk level / raid", "Spelersnaam verbergen", "Test versturen", "Alles stoppen" },
}

local EN = {}
for i, k in ipairs(KEYS) do EN[k] = L.en[i] end

local function RegisterTranslations()
    local i18n = getgenv().CrypticI18n
    if not i18n or not i18n.Register then return end
    for lang, arr in pairs(L) do
        local t = {}
        for i, k in ipairs(KEYS) do t["aot." .. k] = arr[i] end
        pcall(i18n.Register, lang, t)
    end
end

-- ============================================================
-- 2. دالة الرندر
-- ============================================================
local function Render(tab, UI)
    RegisterTranslations()

    -- ── إدارة التشغيل المتكرر: كل Render له رقم، وأي لوب قديم ينتهي لحاله ──
    getgenv().AOT_RunId = (getgenv().AOT_RunId or 0) + 1
    local RUN = getgenv().AOT_RunId
    local function Alive() return getgenv().AOT_RunId == RUN end

    if getgenv().AOT_Conns then
        for _, c in ipairs(getgenv().AOT_Conns) do
            pcall(function() c:Disconnect() end)
        end
    end
    local Conns = {}
    getgenv().AOT_Conns = Conns
    local function TrackConn(c) Conns[#Conns + 1] = c; return c end

    local i18n = getgenv().CrypticI18n
    local function T(k) return (i18n and i18n.T(k)) or k end
    local function TX(k)
        local key = "aot." .. k
        local s = T(key)
        if s == nil or s == "" or s == key then return EN[k] or k end
        return s
    end

    local Players          = game:GetService("Players")
    local RunService       = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService     = game:GetService("TweenService")
    local StarterGui       = game:GetService("StarterGui")
    local HttpService      = game:GetService("HttpService")
    local GuiService       = game:GetService("GuiService")
    local VIM              = game:GetService("VirtualInputManager")
    local VirtualUser      = game:GetService("VirtualUser")

    local player    = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    -- واجهة الهب نفسها: نستثنيها من كل بحث داخل PlayerGui (حتى لا نضغط على أزرارنا بالغلط)
    local HubGui
    pcall(function() HubGui = tab.Page:FindFirstAncestorWhichIsA("ScreenGui") end)
    local function inHub(d) return HubGui ~= nil and d:IsDescendantOf(HubGui) end

    local function Notify(title, text, dur)
        pcall(function()
            StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = dur or 4 })
        end)
    end

    -- ── الكونفيج (الحالة) ─────────────────────────────────────
    local Cfg = {
        AutoFarm = false, AutoRetry = false, AutoReload = false, MultiHit = false,
        Noclip = false, AutoSkip = false, AutoChest = false, ChestRed = false,
        MultiHitCount = 9, HumanSkills = false, Awakening = false,
        RaidWeak = false, Watchdog = false, NoKillMin = 5, BossNoKillMin = 20,
        SpeedOn = false, SpeedVal = 50, JumpOn = false, JumpVal = 100, AntiAFK = false,
        WebhookOn = false, WebhookHide = false, WebhookUrl = "",
    }

    local Config = {
        NapeScale = 0.5,    -- نسبة تصغير حجم النيب
        Height = 300,       -- ارتفاع النيب فوق رأس العملاق (stud)
        Speed = 500,        -- سرعة الطيران
        SwingSpeed = 1000,  -- سرعة الذهاب والإياب
        ClickDelay = 0.01,  -- ثواني بين كل ضغطة M1
        ClickRange = 60,    -- المسافة اللي يبدأ عندها الضرب
        ClickX = 0.97, ClickY = 0.03,   -- مكان ضغط M1 على الشاشة (حافة اليمين-فوق)
        AwakeningSlot = 1,
        SkipKey = Enum.KeyCode.E,
        HeadName = "Head",
        TargetTimeout = 0.1, TargetSkip = 0,
        Swing = 5,
        MultiHitAxis = Vector3.new(1, 0, 0),
        MissionPath = "",
    }

    -- عناصر نص الحالة (تُنشأ في قسم الواجهة)
    local TitanLabel, SessionLabel
    -- دوال تُعرَّف في الجزء المنطقي وتُستعمل من الواجهة
    local API = {}

    -- ══════════════════════════════════════════════════════════
    -- المنطق (فارم / غاز / سكيل / رقم الغارة / ويب هوك)
    -- ══════════════════════════════════════════════════════════
    do
    local gatherPoint, gatherXZ = nil, nil
    local reloading = false
    local Stats = { Kills = 0, LastKillAt = os.clock() }
    local Recovery = { Blocked = false }

    local Stage = {
        killedModels = 0, peakAlive = 0, sawBoss = false, locked = false,
        startedAt = os.clock(), endedAt = nil, final = nil,
        lastCur = nil, lastMax = nil, seenAt = nil, announced = false,
    }
    local Session = { stages = 0, kills = 0, startedAt = os.clock() }
    local TitanInfo = { alive = 0, bosses = 0 }
    local knownModels = {}
    local counted = setmetatable({}, { __mode = "k" })

    local function registerKill(model)
        if model then
            if counted[model] then return end
            counted[model] = true
        end
        Stage.killedModels = Stage.killedModels + 1
        Stats.LastKillAt = os.clock()
    end

    local function resetStage()
        counted = setmetatable({}, { __mode = "k" })
        for m in pairs(knownModels) do counted[m] = true end
        knownModels = {}
        Stage.killedModels, Stage.peakAlive, Stage.sawBoss = 0, 0, false
        Stage.startedAt, Stage.endedAt, Stage.final = os.clock(), nil, nil
        Stage.lastCur, Stage.lastMax = nil, nil
        Stage.seenAt, Stage.announced = nil, false
    end

    -- العملاق مات: صحته كانت > 0 ثم صارت <= 0، أو الموديل اختفى
    local function refreshDeath(info)
        if info.dead then return true end
        local model = info.model
        local gone = (not model) or (not model.Parent)
        local died = false
        local hum = info.hum
        if hum and hum.Parent then
            if hum.Health > 0 then
                info.hpSeen = true
            elseif info.hpSeen then
                died = true
            end
        end
        if gone or died then
            info.dead = true
            if not Stage.locked then registerKill(model) end
            return true
        end
        return false
    end

    local function fmtTime(sec)
        sec = math.max(0, math.floor((sec or 0) + 0.5))
        local h, m, s = math.floor(sec / 3600), math.floor(sec % 3600 / 60), sec % 60
        if h > 0 then return string.format("%dh %02dm %02ds", h, m, s) end
        return string.format("%dm %02ds", m, s)
    end

    local function findPath(root, names)
        local cur = root
        for _, n in ipairs(names) do
            cur = cur and cur:FindFirstChild(n)
        end
        return cur
    end

    -- ── الشخصية ───────────────────────────────────────────────
    local char, hrp
    local function refreshChar()
        local chars = workspace:FindFirstChild("Characters")
        local c = (chars and chars:FindFirstChild(player.Name)) or player.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        if not h then return false end
        char, hrp = c, h
        return true
    end

    local sendWebhook, dumpRewards, scanReport

    -- ── إدخال وهمي ────────────────────────────────────────────
    local function click()
        local cam = workspace.CurrentCamera
        local vp = cam and cam.ViewportSize or Vector2.new(600, 400)
        local x, y = vp.X * Config.ClickX, vp.Y * Config.ClickY
        VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end

    local spaceHeld = false
    local function setSpace(state)
        if spaceHeld == state then return end
        spaceHeld = state
        VIM:SendKeyEvent(state, Enum.KeyCode.Space, false, game)
    end

    -- ── النيب (نقطة الضعف) ────────────────────────────────────
    local data = {}
    local napeList = {}
    local currentTarget, engagedSince = nil, nil

    local function scanNapes()
        local titans = workspace:FindFirstChild("Titans")
        if not titans then
            napeList = {}
            data = {}
            knownModels = {}
            TitanInfo.alive, TitanInfo.bosses = 0, 0
            return
        end

        local list, alive, seenModels = {}, {}, {}
        for _, o in ipairs(titans:GetDescendants()) do
            if o:IsA("BasePart") then
                local isNape = o.Name == "Nape"
                local parent = o.Parent
                local isLimb = (not isNape) and parent and parent.Name == "Hit"
                    and parent.Parent and parent.Parent.Name == "Hitboxes"
                if isNape or isLimb then
                    local model = o
                    while model.Parent and model.Parent ~= titans do
                        model = model.Parent
                    end
                    local boss = model:GetAttribute("Shifter") ~= nil
                    -- الأطراف تُستعمل فقط لزعيم الغارة
                    if isNape or boss then
                        alive[o] = true
                        seenModels[model] = true
                        if not data[o] then
                            local weld = o:FindFirstChild("Nape")
                            if weld then weld:Destroy() end
                            for _, c in ipairs(o:GetChildren()) do
                                if c:IsA("Weld") or c:IsA("WeldConstraint") or c:IsA("Motor6D") then c:Destroy() end
                            end
                            o.Anchored = true
                            o.Transparency = 1
                            data[o] = {
                                model = model,
                                head = model:FindFirstChild(Config.HeadName, true),
                                hum = model:FindFirstChildOfClass("Humanoid"),
                                size = o.Size, scale = nil, dead = false, skipUntil = nil,
                                boss = boss, limb = isLimb and true or false,
                            }
                        end
                        table.insert(list, o)
                    end
                end
            end
        end
        for n in pairs(data) do
            if not alive[n] then data[n] = nil end
        end

        local aliveModels, nAlive, nBoss = {}, 0, 0
        for _, o in ipairs(list) do
            local info = data[o]
            if info and info.model and not aliveModels[info.model] then
                if not info.hum or not info.hum.Parent then
                    info.hum = info.model:FindFirstChildOfClass("Humanoid")
                end
                if not refreshDeath(info) then
                    aliveModels[info.model] = true
                    nAlive = nAlive + 1
                    if info.boss then nBoss = nBoss + 1 end
                end
            end
        end
        TitanInfo.alive, TitanInfo.bosses = nAlive, nBoss
        if nAlive > Stage.peakAlive then Stage.peakAlive = nAlive end
        if nBoss > 0 then Stage.sawBoss = true end

        if not Stage.locked then
            for m in pairs(knownModels) do
                if not seenModels[m] then registerKill(m) end
            end
        end
        knownModels = seenModels
        napeList = list
    end

    local function anchorPos(info)
        if info.head and info.head.Parent then
            return info.head.Position
        end
        if info.model and info.model.Parent and info.model:IsA("Model") then
            return info.model:GetPivot().Position
        end
        return nil
    end

    -- نقطة التجميع (Multi Hit): فوق مكان وقوفك، أعلى من أطول رأس بـ Height
    local function computeGatherPoint()
        if Config.MultiHitPoint then return Config.MultiHitPoint end
        if not gatherXZ then return nil end
        local maxY = -math.huge
        for _, nape in ipairs(napeList) do
            local info = data[nape]
            if info and nape.Parent then
                local base = anchorPos(info)
                if base and base.Y > maxY then maxY = base.Y end
            end
        end
        if maxY == -math.huge then return nil end
        return Vector3.new(gatherXZ.X, maxY + Config.Height, gatherXZ.Z)
    end

    local function updateNapes()
        local offset = Vector3.new(0, Config.Height, 0)

        local gatherSet
        if Cfg.MultiHit and gatherPoint then
            local ref = gatherXZ or gatherPoint
            local cands = {}
            for _, nape in ipairs(napeList) do
                local info = data[nape]
                if info and nape.Parent and not info.dead and not info.limb then
                    local base = anchorPos(info)
                    if base then
                        local dx, dz = base.X - ref.X, base.Z - ref.Z
                        cands[#cands + 1] = { nape = nape, d = dx * dx + dz * dz }
                    end
                end
            end
            table.sort(cands, function(x, y) return x.d < y.d end)
            gatherSet = {}
            for i = 1, math.min(Cfg.MultiHitCount, #cands) do
                gatherSet[cands[i].nape] = true
            end
        end

        for _, nape in ipairs(napeList) do
            local info = data[nape]
            if info and nape.Parent then
                if info.scale ~= Config.NapeScale then
                    nape.Size = info.size * Config.NapeScale
                    info.scale = Config.NapeScale
                end
                if gatherSet and gatherSet[nape] then
                    nape.Position = gatherPoint
                else
                    local base = anchorPos(info)
                    if base then
                        nape.Position = base + offset
                    end
                end
            end
        end
    end

    -- العضو المعلّم عند زعيم الغارة: BillboardGui اسمه Marker
    local function weakPartOf(model)
        local marker = model:FindFirstChild("Marker")
        local ad = marker and marker:IsA("BillboardGui") and marker.Adornee
        if ad and ad:IsDescendantOf(model) then return ad end
        return nil
    end

    local function usable(nape)
        local info = data[nape]
        if not nape.Parent or not info or info.dead then return false end
        if refreshDeath(info) then return false end
        if info.skipUntil and os.clock() < info.skipUntil then return false end
        if info.boss and Cfg.RaidWeak then
            local weak = weakPartOf(info.model)
            if weak then return nape == weak end
        end
        return not info.limb
    end

    local function nearestNape()
        if not hrp then return nil end
        local best, bestD
        for _, nape in ipairs(napeList) do
            if usable(nape) then
                local d = (nape.Position - hrp.Position).Magnitude
                if not bestD or d < bestD then
                    best, bestD = nape, d
                end
            end
        end
        return best
    end

    local function onKill()
        Stats.LastKillAt = os.clock()
        if currentTarget then
            local info = data[currentTarget]
            if info then info.dead = true end
        end
        currentTarget = nil
        engagedSince = nil
    end

    -- ── عدّاد المهمة (x/y) ────────────────────────────────────
    local Progress = { cur = nil, max = nil }
    local missionLabel, lastDetect = nil, 0

    local function snapshot()
        local cur = Progress.cur or Stage.lastCur
        local mx = Progress.max or Stage.lastMax
        local killed = cur or Stage.killedModels
        local total = mx or (Stage.killedModels + TitanInfo.alive)
        if killed > total then total = killed end
        return {
            killed = killed, total = total, alive = TitanInfo.alive,
            boss = Stage.sawBoss, fromLabel = cur ~= nil,
            duration = (Stage.endedAt or os.clock()) - Stage.startedAt,
        }
    end

    local function onStageEnd()
        if TitanInfo.alive <= 2 then
            Stage.locked = false
            pcall(scanNapes)
            Stage.locked = true
        end
        Stage.endedAt = os.clock()
        Stage.final = snapshot()
        if Stage.final.killed > 0 or Stage.final.duration >= 10 then
            Session.stages = Session.stages + 1
            Session.kills = Session.kills + Stage.final.killed
        end
    end

    local lastTitanText = ""
    local function updateTitanLabel()
        if not Stage.announced and TitanInfo.alive > 0 and not Stage.locked then
            Stage.seenAt = Stage.seenAt or os.clock()
            if os.clock() - Stage.seenAt >= 3 then Stage.announced = true end
        end
        local s = snapshot()
        local line1 = string.format("%s: %d %s | %d/%d %s%s%s", TX("titans"), s.alive, TX("left"),
            s.killed, s.total, TX("slain"), s.boss and " | BOSS" or "", s.fromLabel and "" or " ~")
        local line2 = string.format("%s: %d %s | %d %s", TX("session"), Session.stages, TX("stages"), Session.kills, TX("titans"))
        local text = line1 .. "\n" .. line2
        if text == lastTitanText then return end
        lastTitanText = text
        if TitanLabel then TitanLabel.Text = line1 end
        if SessionLabel then SessionLabel.Text = line2 end
    end

    scanReport = function()
        local folder = workspace:FindFirstChild("Titans")
        local models = folder and #folder:GetChildren() or 0
        if Cfg.AutoFarm then scanNapes() end
        local s = snapshot()
        print(string.format("[AoT] left %d | slain %d/%d | %d models in workspace.Titans", s.alive, s.killed, s.total, models))
        if Cfg.AutoFarm then
            local seen, n = {}, 0
            for _, nape in ipairs(napeList) do
                local info = data[nape]
                if info and info.model and not seen[info.model] then
                    seen[info.model] = true
                    n = n + 1
                    if n <= 40 then
                        local base = anchorPos(info)
                        local d = (base and hrp) and math.floor((base - hrp.Position).Magnitude) or -1
                        print(string.format("   %d. %s | %d stud%s%s", n, info.model.Name, d,
                            info.boss and " | BOSS" or "", info.dead and " | dead" or ""))
                    end
                end
            end
        end
        Notify("AoT", string.format("%s %d | %d/%d | %d", TX("left"), s.alive, s.killed, s.total, models), 4)
    end

    local function parseProgress(text)
        if type(text) ~= "string" then return nil end
        text = text:gsub("<[^>]*>", "")
        local a, b = text:match("(%d+)%s*/%s*(%d+)")
        if a then return tonumber(a), tonumber(b) end
        return nil
    end

    local GOOD = { titan = 4, mission = 3, objective = 3, quest = 3, kill = 3, defeat = 3 }
    local BAD = { "gas", "blade", "hp", "health", "stamina", "ammo", "spear", "cooldown" }

    local function contextOf(lbl)
        local parts = { lbl:GetFullName():lower() }
        local p = lbl.Parent
        if p then
            for _, s in ipairs(p:GetChildren()) do
                if s ~= lbl and (s:IsA("TextLabel") or s:IsA("TextButton")) then
                    table.insert(parts, s.Text:lower())
                end
            end
        end
        return table.concat(parts, " ")
    end

    local function scoreContext(ctx)
        local s = 0
        for k, w in pairs(GOOD) do
            if ctx:find(k, 1, true) then s = s + w end
        end
        for _, k in ipairs(BAD) do
            if ctx:find(k, 1, true) then s = s - 10 end
        end
        return s
    end

    local function isShown(gui)
        local cur = gui
        while cur and cur ~= playerGui do
            if cur:IsA("GuiObject") and not cur.Visible then return false end
            if cur:IsA("ScreenGui") and not cur.Enabled then return false end
            cur = cur.Parent
        end
        return true
    end

    local function detectMissionLabel()
        local alive = TitanInfo.alive > 0 and TitanInfo.alive or #napeList
        local best, bestScore
        for _, d in ipairs(playerGui:GetDescendants()) do
            if (d:IsA("TextLabel") or d:IsA("TextButton")) and not inHub(d) then
                local cur, mx = parseProgress(d.Text)
                if cur and mx > 0 and cur <= mx and isShown(d) then
                    local s = scoreContext(contextOf(d))
                    if alive > 0 then
                        if cur + alive == mx then
                            s = s + 8
                        elseif mx >= alive then
                            s = s + 2
                        end
                    end
                    if s >= 3 and (not bestScore or s > bestScore) then
                        best, bestScore = d, s
                    end
                end
            end
        end
        return best
    end

    local function relPath(obj)
        local full = obj:GetFullName()
        return full:match("PlayerGui%.(.+)") or full
    end

    local function resolveMissionLabel()
        local path = Config.MissionPath
        if path ~= "" then
            path = path:match("PlayerGui%.(.+)") or path
            local node = playerGui
            for seg in path:gmatch("[^%.]+") do
                node = node and node:FindFirstChild(seg)
            end
            if node and (node:IsA("TextLabel") or node:IsA("TextButton")) then
                return node
            end
        end
        return detectMissionLabel()
    end

    local function updateMission()
        if not missionLabel or not missionLabel.Parent then
            missionLabel = nil
            if os.clock() - lastDetect >= 2 then
                lastDetect = os.clock()
                missionLabel = resolveMissionLabel()
                Progress.cur, Progress.max = nil, nil
                if missionLabel then
                    print("[AoT] mission counter: " .. relPath(missionLabel) .. " = " .. missionLabel.Text)
                end
            end
        end
        if not missionLabel then return end

        local cur, mx = parseProgress(missionLabel.Text)
        if not cur then
            missionLabel = nil
            return
        end
        if Progress.cur and cur > Progress.cur then
            onKill()
        end
        Progress.cur, Progress.max = cur, mx
        Stage.lastCur, Stage.lastMax = cur, mx
    end

    -- ── واجهة اللعبة (Rewards / Retry / Blade) ────────────────
    local rewardsUI, RetryBtn, heat
    local function refreshUI()
        if not heat or not heat.Parent then
            heat = findPath(playerGui, { "Interface", "HUD", "Main", "Top", "7", "Blades", "Inner", "Bar", "Gradient" })
        end
        if not rewardsUI or not rewardsUI.Parent then
            rewardsUI = findPath(playerGui, { "Interface", "Rewards" })
            RetryBtn = nil
        end
        if rewardsUI and (not RetryBtn or not RetryBtn.Parent) then
            RetryBtn = findPath(rewardsUI, { "Main", "Info", "Main", "Buttons", "Retry" })
        end
    end

    -- ── Noclip أثناء الطيران ──────────────────────────────────
    local noclipOrig = setmetatable({}, { __mode = "k" })
    local noclipParts, noclipChar, noclipAt = {}, nil, 0

    local function restoreNoclip()
        for p, v in pairs(noclipOrig) do
            if p.Parent then p.CanCollide = v end
            noclipOrig[p] = nil
        end
        noclipParts, noclipChar = {}, nil
    end

    TrackConn(RunService.Stepped:Connect(function()
        if not Alive() then return end
        if not (Cfg.Noclip and Cfg.AutoFarm and char and char.Parent) then
            if next(noclipOrig) ~= nil then restoreNoclip() end
            return
        end
        if noclipChar ~= char or os.clock() - noclipAt > 0.5 then
            noclipChar, noclipAt = char, os.clock()
            noclipParts = {}
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    if noclipOrig[p] == nil then noclipOrig[p] = p.CanCollide end
                    noclipParts[#noclipParts + 1] = p
                end
            end
        end
        for _, p in ipairs(noclipParts) do
            if p.Parent then p.CanCollide = false end
        end
    end))

    -- ── حلقة الطيران + M1 ─────────────────────────────────────
    local lastClick = 0
    local swingSide = 1

    local function flyThrough(center, pos)
        local aSpeed = math.max(Config.Speed, 1)
        local sSpeed = math.max(Config.SwingSpeed, 1)
        local swing = math.max(Config.Swing, 1)
        local axis = Config.MultiHitAxis
        axis = axis.Magnitude > 0 and axis.Unit or Vector3.new(1, 0, 0)

        local toCenter = center - pos
        if toCenter.Magnitude > swing + math.max(10, aSpeed / 30) then
            hrp.AssemblyLinearVelocity = toCenter.Unit * aSpeed
            return
        end

        local wp = center + axis * swing * swingSide
        local dist = (wp - pos).Magnitude
        if dist <= math.max(2, sSpeed / 30) then
            swingSide = -swingSide
            wp = center + axis * swing * swingSide
            dist = (wp - pos).Magnitude
        end
        if dist > 0.5 then
            hrp.AssemblyLinearVelocity = (wp - pos).Unit * sSpeed
        end
    end

    TrackConn(RunService.Heartbeat:Connect(function()
        if not Alive() then return end
        if not hrp or not hrp.Parent then refreshChar() end
        if Cfg.AutoFarm then updateNapes() end

        local rewardsOpen = rewardsUI and rewardsUI.Visible
        if rewardsOpen then gatherPoint, gatherXZ = nil, nil end

        if not (Cfg.AutoFarm and hrp and not rewardsOpen) or reloading or Recovery.Blocked then
            setSpace(false)
            currentTarget = nil
            engagedSince = nil
            return
        end

        local pos = hrp.Position

        -- Multi Hit: نجمع النيب فوق مكان وقوفك ونضرب ذهاباً وإياباً
        if Cfg.MultiHit then
            if not gatherXZ then gatherXZ = Vector3.new(pos.X, 0, pos.Z) end
            if not gatherPoint then gatherPoint = computeGatherPoint() end
            if not gatherPoint then
                setSpace(false)
                return
            end
            setSpace(true)
            flyThrough(gatherPoint, pos)
            if os.clock() - lastClick >= Config.ClickDelay and (gatherPoint - pos).Magnitude <= Config.ClickRange then
                lastClick = os.clock()
                click()
            end
            return
        end

        -- فارم عادي: أقرب نيب
        if currentTarget and not usable(currentTarget) then
            currentTarget = nil
            engagedSince = nil
        end

        if currentTarget and engagedSince and Config.TargetTimeout > 0
            and os.clock() - engagedSince > Config.TargetTimeout
            and not (data[currentTarget] and data[currentTarget].boss) then
            data[currentTarget].skipUntil = os.clock() + Config.TargetSkip
            currentTarget = nil
            engagedSince = nil
        end

        if not currentTarget then
            currentTarget = nearestNape()
            engagedSince = nil
        end

        local nape = currentTarget
        if not nape then
            setSpace(false)
            return
        end

        local dist = (nape.Position - pos).Magnitude
        setSpace(true)
        flyThrough(nape.Position, pos)

        if dist <= Config.ClickRange then
            engagedSince = engagedSince or os.clock()
            if os.clock() - lastClick >= Config.ClickDelay then
                lastClick = os.clock()
                click()
            end
        end
    end))

    -- ── المفاتيح ──────────────────────────────────────────────
    local DIGITS = { "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine" }
    local function keyOf(text)
        if type(text) ~= "string" then return nil end
        text = (text:gsub("<[^>]*>", ""))
        text = (text:gsub("^%s*(.-)%s*$", "%1")):upper()
        if text == "SPACE" or text == "SPACEBAR" then return Enum.KeyCode.Space end
        if text == "ENTER" or text == "RETURN" then return Enum.KeyCode.Return end
        if #text ~= 1 then return nil end
        if text:match("%d") then
            local n = tonumber(text)
            if n == 0 then return Enum.KeyCode.Zero end
            return Enum.KeyCode[DIGITS[n]]
        end
        if text:match("%a") then
            local ok, kc = pcall(function() return Enum.KeyCode[text] end)
            return ok and kc or nil
        end
        return nil
    end

    local function tapKey(kc)
        VIM:SendKeyEvent(true, kc, false, game)
        task.delay(0.05, function() VIM:SendKeyEvent(false, kc, false, game) end)
    end

    local function holdR(t)
        VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game)
        task.wait(t)
        VIM:SendKeyEvent(false, Enum.KeyCode.R, false, game)
    end

    -- ── HUD: سيوف / غاز ──────────────────────────────────────
    local function hudRoot()
        return findPath(playerGui, { "Interface", "HUD", "Main", "Top", "7" })
    end

    local function getSets()
        local r = hudRoot()
        local b = r and r:FindFirstChild("Blades")
        local l = b and b:FindFirstChild("Sets")
        if not (l and l:IsA("TextLabel")) then return nil, nil end
        local t = (l.Text:gsub("<[^>]*>", ""))
        return tonumber(t:match("(%d+)%s*/")), tonumber(t:match("/%s*(%d+)"))
    end

    local function getGas()
        local r = hudRoot()
        local g = r and r:FindFirstChild("Gas")
        local l = g and g:FindFirstChild("Percentage")
        if not (l and l:IsA("TextLabel")) then return nil end
        local t = (l.Text:gsub("<[^>]*>", ""))
        return tonumber(t:match("(%d+%.?%d*)%s*%%"))
    end

    local function getDurability()
        local r = hudRoot()
        local g = r and findPath(r, { "Blades", "Inner", "Bar", "Gradient" })
        return g and g.Offset and g.Offset.X
    end

    -- ── محطات الغاز ───────────────────────────────────────────
    local lastReload = 0
    local refillFails = 0
    local stations, stationsAt = {}, 0

    local function titanRoot(m)
        return m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
    end

    local function posOf(inst)
        if inst:IsA("Model") then return inst:GetPivot().Position end
        return inst.Position
    end

    local function findStations()
        if os.clock() - stationsAt < 30 and #stations > 0 then return stations end
        local list, models = {}, {}
        for i, d in ipairs(workspace:GetDescendants()) do
            if i % 1500 == 0 then task.wait() end
            if d.Parent and d.Parent.Name == "GasTanks" then
                if d.Name == "Refill" and d:IsA("BasePart") then
                    list[#list + 1] = d
                elseif d:IsA("Model") then
                    models[#models + 1] = d
                end
            end
        end
        if #list == 0 then list = models end
        stations, stationsAt = list, os.clock()
        return list
    end

    local function pickStation()
        local list = findStations()
        if #list == 0 then return nil end
        local threats = {}
        local folder = workspace:FindFirstChild("Titans")
        if folder then
            for _, m in ipairs(folder:GetChildren()) do
                local hum = m:IsA("Model") and m:FindFirstChildOfClass("Humanoid")
                local r = m:IsA("Model") and titanRoot(m)
                if r and not (hum and hum.Health <= 0) then threats[#threats + 1] = r.Position end
            end
        end
        local best, bestCount, bestDist
        for _, st in ipairs(list) do
            if st.Parent then
                local p = posOf(st)
                local count = 0
                for _, tp in ipairs(threats) do
                    if (tp - p).Magnitude < 180 then count = count + 1 end
                end
                local dist = hrp and (p - hrp.Position).Magnitude or 0
                if not best or count < bestCount or (count == bestCount and dist < bestDist) then
                    best, bestCount, bestDist = st, count, dist
                end
            end
        end
        return best
    end

    local function waitDurabilityFull(timeout)
        local t0 = os.clock()
        repeat
            local d = getDurability()
            if d and d >= 0.99 then return true end
            task.wait(0.1)
        until os.clock() - t0 > timeout or not Alive()
        return false
    end

    local function refillTrip()
        local station = pickStation()
        if not (station and hrp) then return false end
        local pos = posOf(station)
        local back = hrp.CFrame

        local cam = workspace.CurrentCamera
        RunService:BindToRenderStep("AoTFullLook", Enum.RenderPriority.Camera.Value + 1, function()
            if cam then cam.CFrame = CFrame.lookAt(cam.CFrame.Position, pos) end
        end)

        for _ = 1, 2 do
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(pos)
            task.wait(0.5)
        end

        local ok = false
        local deadline = os.clock() + 6
        repeat
            holdR(0.5)
            hrp.AssemblyLinearVelocity = Vector3.zero
            task.wait(0.5)
            local sets, mx = getSets()
            local gas = getGas()
            if sets and sets == (mx or 3) and gas and gas > 0 then ok = true break end
        until os.clock() > deadline or not Alive()

        pcall(function() RunService:UnbindFromRenderStep("AoTFullLook") end)
        if hrp and hrp.Parent then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.CFrame = back
        end
        return ok
    end

    local function supplyTick()
        if reloading or not hrp or not hrp.Parent or os.clock() - lastReload < 2 then return end
        if Recovery.Blocked then return end
        local sets, gas, dur = getSets(), getGas(), getDurability()
        local broken = dur ~= nil and dur < 0

        local needRefill = (gas ~= nil and gas <= 0) or (sets == 0 and broken)
        local needReload = broken and sets ~= nil and sets > 0
        if not (needRefill or needReload) then return end

        reloading = true
        setSpace(false)
        if needRefill then
            if refillTrip() then
                refillFails = 0
            else
                refillFails = refillFails + 1
                if refillFails >= 3 then
                    refillFails = 0
                    lastReload = os.clock() + 10
                end
            end
        else
            holdR(0.5)
            waitDurabilityFull(4)
        end
        reloading = false
        lastReload = math.max(lastReload, os.clock())
    end

    -- ── الاسترجاع (ragdoll / موت / انتظار الشخصية) ────────────
    Recovery.CheckedAt = 0
    local function recoveryTick()
        local now = os.clock()
        if now - Recovery.CheckedAt < 0.2 then return end
        Recovery.CheckedAt = now
        if not Cfg.AutoFarm or (rewardsUI and rewardsUI.Visible) then
            Recovery.Blocked, Recovery.Reason, Recovery.StableAt = false, nil, nil
            return
        end

        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local reason
        if not (char and char.Parent and hrp and hrp.Parent and hum) then
            reason = "waiting"
        elseif hum.Health <= 0 then
            reason = "dead"
        else
            local st = hum:GetState()
            if st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.Ragdoll
                or st == Enum.HumanoidStateType.GettingUp or st == Enum.HumanoidStateType.Physics then
                reason = "ragdoll"
            end
        end

        if reason then
            Recovery.Blocked, Recovery.Reason, Recovery.StableAt = true, reason, nil
            return
        end
        if Recovery.Blocked then
            Recovery.StableAt = Recovery.StableAt or now
            if now - Recovery.StableAt < 0.4 then return end
            if Recovery.Reason == "ragdoll" then tapKey(Enum.KeyCode.Space) end
            Recovery.Blocked, Recovery.Reason = false, nil
        end
    end

    TrackConn(RunService.Heartbeat:Connect(function()
        if not Alive() then return end
        pcall(recoveryTick)
    end))

    -- ── مهارات الإنسان (hotbar 1-5) ──────────────────────────
    local skillState = { next = 1, retryAfter = {} }

    local function skillTick()
        if not Cfg.HumanSkills then return end
        if not Cfg.AutoFarm or reloading or Recovery.Blocked then return end
        if char and char:GetAttribute("Shifter") ~= nil then return end
        local hotbar = hudRoot() and findPath(hudRoot(), { "Hotbar" })
        if not hotbar then return end

        local now = os.clock()
        local awaken = Config.AwakeningSlot
        local bar, maxBar = tonumber(player:GetAttribute("Bar")), tonumber(player:GetAttribute("Max_Bar"))

        for off = 0, 4 do
            local slot = (skillState.next + off - 1) % 5 + 1
            local allowed = true
            if slot == awaken then
                allowed = Cfg.Awakening and bar and maxBar and maxBar > 0 and bar >= maxBar - 0.5
            end
            if allowed and now >= (skillState.retryAfter[slot] or 0) then
                local sk = hotbar:FindFirstChild("Skill_" .. slot)
                if sk then
                    local cd = findPath(sk, { "Cooldown", "Label" })
                    local sec = cd and tonumber(((cd.Text or ""):match("[%d%.]+")))
                    local keyLabel = findPath(sk, { "Key", "Key" })
                    local kc = (keyLabel and keyOf(keyLabel.Text)) or Enum.KeyCode[DIGITS[slot]]
                    if (not sec or sec <= 1) and kc then
                        tapKey(kc)
                        skillState.retryAfter[slot] = now + 3
                        skillState.next = slot % 5 + 1
                        return
                    end
                end
            end
        end
    end

    -- ── الصندوق + التخطي التلقائي ─────────────────────────────
    local Chest = { attempts = 0, lastAt = 0, skipSeenAt = nil, lastSeenAny = 0 }
    local SKIP_WORDS = { "skip", "bỏ qua", "bo qua", "BỎ QUA", "BO QUA" }

    local function strip(t)
        t = tostring(t or ""):gsub("<[^>]*>", "")
        t = t:gsub("^%s+", ""):gsub("%s+$", "")
        return t
    end

    local function clickGui(g)
        local inset = GuiService:GetGuiInset()
        local sg = g:FindFirstAncestorWhichIsA("ScreenGui")
        local dy = (sg and sg.IgnoreGuiInset) and 0 or inset.Y
        local p = g.AbsolutePosition + g.AbsoluteSize / 2
        VIM:SendMouseButtonEvent(p.X, p.Y + dy, 0, true, game, 1)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(p.X, p.Y + dy, 0, false, game, 1)
    end

    local function findOpenButtons()
        local list = {}
        for _, d in ipairs(playerGui:GetDescendants()) do
            if (d:IsA("TextButton") or d:IsA("ImageButton")) and not inHub(d) and isShown(d) then
                local txt = d:IsA("TextButton") and strip(d.Text) or ""
                if txt == "" then
                    for _, c in ipairs(d:GetDescendants()) do
                        if c:IsA("TextLabel") and isShown(c) then txt = strip(c.Text) break end
                    end
                end
                if txt:lower() == "open" and d.AbsoluteSize.X > 0 then list[#list + 1] = d end
            end
        end
        table.sort(list, function(x, y) return x.AbsolutePosition.X < y.AbsolutePosition.X end)
        return list
    end

    local function findSkipButton()
        for _, d in ipairs(playerGui:GetDescendants()) do
            if (d:IsA("TextButton") or d:IsA("TextLabel")) and not inHub(d) and isShown(d) then
                local t = strip(d.Text)
                if #t > 0 and #t <= 30 then
                    local low = t:lower()
                    for _, w in ipairs(SKIP_WORDS) do
                        if low:find(w, 1, true) or t:find(w, 1, true) then return d end
                    end
                end
            end
        end
        return nil
    end

    local lastSkip = 0
    local function skipTick()
        local now = os.clock()
        if now - lastSkip < 0.4 then return end

        local wantChest = Cfg.AutoChest
        local opens = wantChest and findOpenButtons() or {}
        local skipBtn = Cfg.AutoSkip and findSkipButton() or nil

        if #opens > 0 or skipBtn then Chest.lastSeenAny = now end
        if now - Chest.lastSeenAny > 6 then
            Chest.attempts, Chest.skipSeenAt = 0, nil
        end

        if wantChest and #opens > 0 then
            if Chest.attempts < 3 and now - Chest.lastAt >= 1.5 then
                local btn = (#opens >= 2) and (Cfg.ChestRed and opens[#opens] or opens[1]) or opens[1]
                Chest.attempts = Chest.attempts + 1
                Chest.lastAt = now
                lastSkip = now
                task.spawn(function()
                    pcall(clickGui, btn)
                    if Chest.attempts >= 2 and typeof(firesignal) == "function" then
                        pcall(function() firesignal(btn.MouseButton1Click) end)
                        pcall(function() firesignal(btn.Activated) end)
                    end
                end)
                return
            end
            if Chest.attempts < 3 then return end
        end

        if not skipBtn then return end
        if wantChest then
            Chest.skipSeenAt = Chest.skipSeenAt or now
            if Chest.attempts == 0 and now - Chest.skipSeenAt < 4 then return end
            if Chest.attempts > 0 and now - Chest.lastAt < 1.5 then return end
        end
        lastSkip = now
        tapKey(Config.SkipKey)
    end

    -- ── ويب هوك ديسكورد ───────────────────────────────────────
    local httpReq = (syn and syn.request) or http_request or request or (fluxus and fluxus.request)
    local EMOJI = { red = "🔴", gold = "🟡", blue = "🔵", purple = "🟣", common = "⚪" }

    local function colorTag(c)
        if typeof(c) ~= "Color3" then return "common" end
        local h, sat, v = c:ToHSV()
        h = h * 360
        if sat < 0.2 or v < 0.25 then return "common" end
        if h < 20 or h >= 335 then return "red" end
        if h < 70 then return "gold" end
        if h < 250 then return "blue" end
        return "purple"
    end

    local function lineKind(d, t)
        if not t:find("%d") then return nil end
        local p = d.Parent
        local ctx = (d.Name .. " " .. (p and p.Name or "") .. " " .. ((p and p.Parent and p.Parent.Name) or "")):lower()
        local hay = t:lower() .. " " .. ctx
        if hay:find("exp", 1, true) or hay:find("xp", 1, true) then return "exp" end
        if hay:find("gem", 1, true) then return "gem" end
        for _, k in ipairs({ "gold", "coin", "money", "cash", "silver", "yen", "$" }) do
            if hay:find(k, 1, true) then return "money" end
        end
        return nil
    end

    local function collectRewards()
        local r = { exp = {}, gem = {}, money = {}, perk = {}, item = {} }
        if not rewardsUI then return r end
        local rows = {}
        for _, d in ipairs(rewardsUI:GetDescendants()) do
            if d:IsA("TextLabel") and isShown(d) and not d:FindFirstAncestorWhichIsA("GuiButton") then
                local t = strip(d.Text)
                if #t > 0 and #t <= 80 then rows[#rows + 1] = { d = d, t = t } end
            end
        end
        table.sort(rows, function(x, y)
            local ax, ay = x.d.AbsolutePosition, y.d.AbsolutePosition
            if math.abs(ax.Y - ay.Y) > 4 then return ax.Y < ay.Y end
            return ax.X < ay.X
        end)
        for _, row in ipairs(rows) do
            local kind = lineKind(row.d, row.t)
            if kind then
                table.insert(r[kind], row.t)
            else
                local tag = colorTag(row.d.TextColor3)
                if tag ~= "common" then
                    table.insert(r.perk, EMOJI[tag] .. " " .. row.t)
                else
                    table.insert(r.item, row.t)
                end
            end
        end
        return r
    end

    local function esc(s)
        return (tostring(s):gsub("([\\%*_~`|>])", "\\%1"))
    end

    local function bullets(list, empty, plain)
        if #list == 0 then return empty or "—" end
        local out, len = {}, 0
        for i, s in ipairs(list) do
            local line = (plain and "" or "• ") .. esc(s)
            if len + #line + 1 > 960 then
                out[#out + 1] = string.format("… +%d more", #list - i + 1)
                break
            end
            out[#out + 1] = line
            len = len + #line + 1
        end
        return table.concat(out, "\n")
    end

    local function progressBar(cur, mx, len)
        len = len or 12
        if not mx or mx <= 0 then return string.rep("▱", len) end
        local filled = math.clamp(math.floor(cur / mx * len + 0.5), 0, len)
        return string.rep("▰", filled) .. string.rep("▱", len - filled)
    end

    local function hasRare(r)
        for _, p in ipairs(r.perk) do
            if p:find(EMOJI.red, 1, true) or p:find(EMOJI.gold, 1, true) then return true end
        end
        return false
    end

    local function postWebhook(url, payload)
        if not httpReq then return false, "no request" end
        local body = HttpService:JSONEncode(payload)
        for attempt = 1, 2 do
            local ok, res = pcall(httpReq, {
                Url = url, Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body,
            })
            if not ok then return false, tostring(res) end
            local code = 0
            if type(res) == "table" then
                code = tonumber(res.StatusCode or res.status_code or (res.Success and 204) or 0) or 0
            end
            if code >= 200 and code < 300 then return true, code end
            if code == 429 and attempt == 1 then
                local wait = 2
                pcall(function()
                    local j = HttpService:JSONDecode(res.Body or "{}")
                    wait = math.clamp(tonumber(j.retry_after) or wait, 0.5, 10)
                end)
                task.wait(wait)
            else
                return false, code
            end
        end
        return false, 429
    end

    local function validWebhook(url)
        return type(url) == "string" and (url:find("discord.com/api/webhooks/", 1, true) or url:find("discordapp.com/api/webhooks/", 1, true))
    end

    local function buildEmbed(isTest)
        local snap = (not isTest and Stage.final) or snapshot()
        local r = collectRewards()
        local cleared = snap.total > 0 and snap.killed >= snap.total
        local color = hasRare(r) and 0xF1C40F or (cleared and 0x57F287 or 0xFEE75C)

        local who = player.Name
        if player.DisplayName ~= player.Name then who = player.DisplayName .. " (@" .. player.Name .. ")" end
        who = esc(who)
        who = Cfg.WebhookHide and ("||" .. who .. "||") or ("**" .. who .. "**")

        local desc = { "Player: " .. who }
        if snap.total > 0 then
            if cleared then
                desc[#desc + 1] = "🏆 All titans cleared"
            else
                desc[#desc + 1] = string.format("⚠️ Ended with %d titans left", math.max(snap.total - snap.killed, 0))
            end
        end

        local titanValue = string.format("%s  **%d/%d**", progressBar(snap.killed, snap.total), snap.killed, snap.total)
        if not snap.fromLabel then titanValue = titanValue .. "\n_estimated from map scan_" end

        local speed = "—"
        if snap.killed > 0 and snap.duration > 3 then
            speed = string.format("%.1f titans/min", snap.killed / (snap.duration / 60))
        end

        local fields = {
            { name = "⚔️ Titans slain", value = titanValue, inline = false },
            { name = "⏱️ Time", value = fmtTime(snap.duration), inline = true },
            { name = "🚀 Speed", value = speed, inline = true },
            { name = "📊 Session", value = string.format("%d stages • %d titans\n%s", Session.stages, Session.kills, fmtTime(os.clock() - Session.startedAt)), inline = true },
            { name = "✨ EXP", value = bullets(r.exp, "—", true), inline = true },
            { name = "💎 Gems", value = bullets(r.gem, "—", true), inline = true },
            { name = "💰 Money", value = bullets(r.money, "—", true), inline = true },
        }
        if #r.perk > 0 then fields[#fields + 1] = { name = "🔮 Perks", value = bullets(r.perk, "—", true), inline = false } end
        if #r.item > 0 then fields[#fields + 1] = { name = "🎁 Items", value = bullets(r.item, "—"), inline = false } end

        local title = snap.boss and "🛡️ Raid complete" or "✅ Stage complete"
        if Session.stages > 0 and not isTest then title = title .. " #" .. Session.stages end
        if isTest then title = "🧪 [Test] " .. title end

        return {
            title = title,
            description = table.concat(desc, "\n"),
            color = color,
            thumbnail = { url = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%.0f&width=150&height=150&format=png", player.UserId) },
            fields = fields,
            footer = { text = "Cryptic Hub • AoT (DxZ)" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        }
    end

    sendWebhook = function(isTest)
        local url = tostring(Cfg.WebhookUrl or ""):gsub("%s+", "")
        if not validWebhook(url) then
            if isTest then Notify("Webhook", "Invalid webhook link", 4) end
            return
        end
        if not httpReq then
            if isTest then Notify("Webhook", "Executor has no request/http_request", 4) end
            return
        end
        local okBuild, embed = pcall(buildEmbed, isTest)
        if not okBuild then
            warn("[AoT] webhook build error: " .. tostring(embed))
            if isTest then Notify("Webhook", "Build error (see F9)", 4) end
            return
        end
        local ok, info = postWebhook(url, { username = "Cryptic Hub", allowed_mentions = { parse = {} }, embeds = { embed } })
        if isTest then
            Notify("Webhook", ok and "Sent ✅" or ("Failed (" .. tostring(info) .. ")"), 4)
        end
    end

    -- يطبع كل نصوص واجهة المكافآت (لضبط القارئ حسب اللعبة)
    dumpRewards = function()
        local root = rewardsUI or findPath(playerGui, { "Interface" }) or playerGui
        local out = {}
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                local t = strip(d.Text)
                if #t > 0 and #out < 300 then
                    out[#out + 1] = string.format("%s | %q | %s | shown=%s | %s",
                        relPath(d), t, colorTag(d.TextColor3), tostring(isShown(d)), tostring(d.TextColor3))
                end
            end
        end
        local text = table.concat(out, "\n")
        print("[AoT] UI DUMP:\n" .. text)
        local copied = false
        if typeof(setclipboard) == "function" then copied = pcall(setclipboard, text) end
        Notify("Dump UI", (copied and "Copied to clipboard" or "See F9 console") .. " (" .. #out .. ")", 4)
    end

    -- مسار المكافآت: فتح الصندوق → ويب هوك → (بعدها يسمح بالـ Retry)
    local RW = { since = nil, sent = false }
    local function rewardsReady(open)
        local now = os.clock()
        if not open then
            RW.since, RW.sent = nil, false
            return false
        end
        RW.since = RW.since or now
        if not (Cfg.WebhookOn or Cfg.AutoChest) then return true end
        local waited = now - RW.since
        local chestOk = (not Cfg.AutoChest) or (Chest.attempts > 0 and now - Chest.lastAt >= 2.5) or waited >= 9
        if not RW.sent and waited >= 2.5 and chestOk then
            RW.sent = true
            if Cfg.WebhookOn then
                task.spawn(function() pcall(sendWebhook, false) end)
            end
        end
        return RW.sent and chestOk
    end

    -- ── Anti AFK ──────────────────────────────────────────────
    TrackConn(player.Idled:Connect(function()
        if not Alive() or not Cfg.AntiAFK then return end
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end))

    -- ── سرعة الركض / القفز ────────────────────────────────────
    local moveOrig = { char = nil }
    local function restoreMove()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if moveOrig.ws then hum.WalkSpeed = moveOrig.ws end
            if moveOrig.jp then hum.JumpPower = moveOrig.jp end
        end
        moveOrig = { char = char }
    end

    TrackConn(RunService.Heartbeat:Connect(function()
        if not Alive() then return end
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if moveOrig.char ~= char then moveOrig = { char = char } end

        if Cfg.SpeedOn then
            moveOrig.ws = moveOrig.ws or hum.WalkSpeed
            hum.WalkSpeed = Cfg.SpeedVal
        elseif moveOrig.ws then
            hum.WalkSpeed = moveOrig.ws
            moveOrig.ws = nil
        end

        if Cfg.JumpOn then
            moveOrig.jp = moveOrig.jp or hum.JumpPower
            hum.UseJumpPower = true
            hum.JumpPower = Cfg.JumpVal
        elseif moveOrig.jp then
            hum.JumpPower = moveOrig.jp
            moveOrig.jp = nil
        end
    end))

    -- ── مكافحة التعليق: لو طال بدون قتل ندخل على العملاق عشان تنعاد الجولة ──
    local function bossAlive()
        for _, info in pairs(data) do
            if info.boss and info.model and info.model.Parent then return true end
        end
        return false
    end

    local function giveUpToTitan()
        reloading = true
        setSpace(false)
        local t0 = os.clock()
        while os.clock() - t0 < 25 and Alive() do
            refreshChar()
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or (hum and hum.Health <= 0) then break end
            local folder = workspace:FindFirstChild("Titans")
            local best, bestD
            if folder then
                for _, m in ipairs(folder:GetChildren()) do
                    local r = m:IsA("Model") and titanRoot(m)
                    if r then
                        local d = (r.Position - hrp.Position).Magnitude
                        if not bestD or d < bestD then best, bestD = r, d end
                    end
                end
            end
            if best then hrp.CFrame = best.CFrame * CFrame.new(0, 0, -4) end
            task.wait(0.5)
        end
        reloading = false
        Stats.LastKillAt = os.clock()
    end

    local function watchdogTick(rewardsOpen)
        local idle = reloading or Recovery.Blocked or rewardsOpen or not Cfg.AutoFarm
        if idle or not Cfg.Watchdog then
            Stats.LastKillAt = os.clock()
            return
        end
        local limit = (bossAlive() and Cfg.BossNoKillMin or Cfg.NoKillMin) * 60
        if os.clock() - Stats.LastKillAt > limit then
            giveUpToTitan()
        end
    end

    -- ── اللوب الخلفي ──────────────────────────────────────────
    task.spawn(function()
        local once = false
        local lastUI, lastScan = 0, 0
        local wasRewards = false
        while Alive() do
            local ok, err = pcall(function()
                if not hrp or not hrp.Parent then refreshChar() end

                if os.clock() - lastUI >= 2 then
                    lastUI = os.clock()
                    refreshUI()
                end

                local rOpen = (rewardsUI and rewardsUI.Visible) and true or false
                Stage.locked = rOpen
                if rOpen and not wasRewards and Cfg.AutoFarm then pcall(onStageEnd) end
                if wasRewards and not rOpen then
                    resetStage()
                    Progress.cur, Progress.max = nil, nil
                end
                wasRewards = rOpen

                -- المسح يعدّل أجزاء العمالقة، لذلك نشغّله فقط والفارم شغّال
                if Cfg.AutoFarm then
                    if os.clock() - lastScan >= 1 then
                        lastScan = os.clock()
                        scanNapes()
                    end
                    updateMission()
                    updateTitanLabel()
                end

                local rewardsOpen = rewardsUI and rewardsUI.Visible

                if Cfg.AutoReload and Cfg.AutoFarm and not rewardsOpen then
                    supplyTick()
                end
                skillTick()
                skipTick()
                watchdogTick(rewardsOpen)

                local ready = rewardsReady(rewardsUI and rewardsUI.Visible)
                if rewardsUI then
                    if not rewardsUI.Visible then
                        once = false
                    elseif Cfg.AutoRetry and RetryBtn and not once and ready then
                        once = true
                        setSpace(false)
                        currentTarget = nil
                        gatherPoint, gatherXZ = nil, nil
                        missionLabel = nil
                        Progress.cur, Progress.max = nil, nil
                        task.wait(0.1)
                        RetryBtn.Parent = rewardsUI
                        task.wait(0.1)
                        RetryBtn.Size = UDim2.new(1, 0, 1, 0)
                        task.wait(0.5)
                        VIM:SendMouseButtonEvent(300, 200, 0, true, game, 1)
                        VIM:SendMouseButtonEvent(200, 300, 0, false, game, 1)
                    end
                end
            end)
            if not ok then
                warn("[AoT] loop error: " .. tostring(err))
                reloading = false
                if hrp then hrp.Anchored = false end
            end
            task.wait(0.1)
        end
    end)

    -- تنظيف عند إعادة تشغيل القسم
    TrackConn({ Disconnect = function()
        Cfg.AutoFarm = false
        setSpace(false)
        restoreNoclip()
        pcall(restoreMove)
        pcall(function() RunService:UnbindFromRenderStep("AoTFullLook") end)
    end })

    API.scan = function() if scanReport then pcall(scanReport) end end
    API.webhookTest = function() if sendWebhook then task.spawn(function() pcall(sendWebhook, true) end) end end
    API.dump = function() if dumpRewards then pcall(dumpRewards) end end
    API.resetGather = function() gatherPoint, gatherXZ = nil, nil end
    end -- do (logic)

    -- ══════════════════════════════════════════════════════════
    -- الواجهة (نفس تصميم MM2: أقسام قابلة للطي + عدّاد الميزات المفعّلة)
    -- ══════════════════════════════════════════════════════════
    do
    local C_GREEN  = Color3.fromRGB(0, 255, 150)
    local C_BLUE   = Color3.fromRGB(0, 150, 255)
    local C_RED    = Color3.fromRGB(255, 90, 90)
    local C_PURPLE = Color3.fromRGB(130, 150, 255)
    local C_CYAN   = Color3.fromRGB(0, 205, 255)
    local C_ORANGE = Color3.fromRGB(255, 150, 50)
    local C_GOLD   = Color3.fromRGB(255, 205, 55)
    local DIM      = Color3.fromRGB(110, 110, 130)
    local CARD     = Color3.fromRGB(16, 16, 22)
    local OFF_CLR  = Color3.fromRGB(45, 45, 55)
    local PAGE     = tab.Page
    local HOST     = PAGE
    local ScrollHost

    local function Tw2(o, p, t)
        TweenService:Create(o, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p):Play()
    end

    -- حاوية تمرير خاصة بنا: حجمها يتبع الجزء المرئي من النافذة
    do
        local sc = Instance.new("ScrollingFrame")
        sc.Name = "AoTScroll"
        sc.BackgroundTransparency = 1; sc.BorderSizePixel = 0
        sc.LayoutOrder = 0
        sc.Active = true
        sc.ScrollingEnabled = true
        sc.ScrollingDirection = Enum.ScrollingDirection.Y
        sc.CanvasSize = UDim2.new(0, 0, 0, 0)
        sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sc.ScrollBarThickness = 3
        sc.ScrollBarImageColor3 = Color3.fromRGB(120, 125, 140)
        sc.Size = UDim2.new(1, 0, 0, 260)
        sc.Parent = HOST
        local ll = Instance.new("UIListLayout", sc)
        ll.SortOrder = Enum.SortOrder.LayoutOrder
        ll.Padding = UDim.new(0, 8)
        ll.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local pd = Instance.new("UIPadding", sc)
        pd.PaddingBottom = UDim.new(0, 16)
        pcall(function() HOST.ScrollingEnabled = false end)

        -- القياسات بالبكسل المرسوم (بعد UIScale) والـ Size بالوحدات المحلية، فنحوّل بينهم
        local GRIP_PX = 36
        local function fit()
            local h = 0
            local scale = 1
            local ok = pcall(function()
                local curH = sc.Size.Y.Offset
                if curH > 0 and sc.AbsoluteSize.Y > 0 then
                    scale = math.clamp(sc.AbsoluteSize.Y / curH, 0.2, 5)
                end
                h = HOST.AbsoluteWindowSize.Y
                local a = HOST.Parent
                while a and a:IsA("GuiObject") do
                    if a.ClipsDescendants then
                        local visibleBottom = a.AbsolutePosition.Y + a.AbsoluteSize.Y
                        h = math.min(h, visibleBottom - sc.AbsolutePosition.Y)
                        break
                    end
                    a = a.Parent
                end
            end)
            if ok and h > 60 then
                h = math.floor(h / scale)
                if sc.Size.Y.Offset ~= h then sc.Size = UDim2.new(1, 0, 0, h) end
                local pad = math.ceil(GRIP_PX / scale) + 4
                if pd.PaddingBottom.Offset ~= pad then pd.PaddingBottom = UDim.new(0, pad) end
            end
        end
        local t = 0
        TrackConn(RunService.Heartbeat:Connect(function(dt)
            t = t + dt
            if t < 0.2 then return end
            t = 0
            fit()
        end))
        task.defer(fit)
        PAGE = sc
        ScrollHost = sc
        tab.Page = sc
    end

    getgenv().AOT_SecOpen = getgenv().AOT_SecOpen or {}
    local SecOpen = getgenv().AOT_SecOpen

    local function isPress(i)
        return i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch
    end

    -- ── سلايدر: سحب + أزرار - / + (الضغط المطوّل يكرر) ──────────
    local function AddSlider(text, minV, maxV, defaultV, step, suffix, callback)
        tab.Order = tab.Order + 1
        suffix = suffix or ""

        local R = Instance.new("Frame", tab.Page)
        R.LayoutOrder = tab.Order
        R.Size = UDim2.new(0.98, 0, 0, 76)
        R.BackgroundColor3 = CARD; R.BackgroundTransparency = 0.1; R.BorderSizePixel = 0
        Instance.new("UICorner", R).CornerRadius = UDim.new(0, 10)

        local Stroke = Instance.new("UIStroke", R)
        Stroke.Thickness = 1.2; Stroke.Transparency = 0.55
        local SG = Instance.new("UIGradient", Stroke)
        SG.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, C_GREEN), ColorSequenceKeypoint.new(1, C_BLUE) }
        SG.Rotation = 45

        local Lbl = Instance.new("TextLabel", R)
        Lbl.Text = text
        Lbl.Size = UDim2.new(1, -90, 0, 24); Lbl.Position = UDim2.new(0, 10, 0, 6)
        Lbl.TextColor3 = Color3.fromRGB(210, 210, 225); Lbl.BackgroundTransparency = 1
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.Font = Enum.Font.GothamSemibold; Lbl.TextSize = 12
        Lbl.TextWrapped = false; Lbl.TextTruncate = Enum.TextTruncate.AtEnd

        local ValLbl = Instance.new("TextLabel", R)
        ValLbl.Size = UDim2.new(0, 70, 0, 24); ValLbl.Position = UDim2.new(1, -80, 0, 6)
        ValLbl.BackgroundTransparency = 1; ValLbl.TextColor3 = C_GREEN
        ValLbl.TextXAlignment = Enum.TextXAlignment.Right
        ValLbl.Font = Enum.Font.GothamBold; ValLbl.TextSize = 13

        local function mkStepBtn(txt, pos)
            local b = Instance.new("TextButton", R)
            b.Size = UDim2.new(0, 38, 0, 34); b.Position = pos
            b.BackgroundColor3 = OFF_CLR; b.BackgroundTransparency = 0.1; b.BorderSizePixel = 0
            b.Text = txt; b.TextColor3 = Color3.new(1, 1, 1)
            b.Font = Enum.Font.GothamBold; b.TextSize = 18; b.AutoButtonColor = false
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            return b
        end
        local Minus = mkStepBtn("-", UDim2.new(0, 8, 0, 36))
        local Plus  = mkStepBtn("+", UDim2.new(1, -46, 0, 36))

        local Track = Instance.new("Frame", R)
        Track.Size = UDim2.new(1, -108, 0, 8); Track.Position = UDim2.new(0, 54, 0, 49)
        Track.BackgroundColor3 = OFF_CLR; Track.BorderSizePixel = 0
        Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

        local Fill = Instance.new("Frame", Track)
        Fill.Size = UDim2.new(0, 0, 1, 0); Fill.BackgroundColor3 = C_GREEN; Fill.BorderSizePixel = 0
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
        local FG = Instance.new("UIGradient", Fill)
        FG.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, C_GREEN), ColorSequenceKeypoint.new(1, C_BLUE) }

        local Knob = Instance.new("Frame", Track)
        Knob.Size = UDim2.new(0, 22, 0, 22); Knob.AnchorPoint = Vector2.new(0.5, 0.5)
        Knob.Position = UDim2.new(0, 0, 0.5, 0); Knob.BackgroundColor3 = Color3.new(1, 1, 1)
        Knob.BorderSizePixel = 0; Knob.ZIndex = 2
        Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

        local Hit = Instance.new("TextButton", R)
        Hit.Size = UDim2.new(1, -108, 0, 46); Hit.Position = UDim2.new(0, 54, 0, 30)
        Hit.BackgroundTransparency = 1; Hit.Text = ""; Hit.AutoButtonColor = false; Hit.ZIndex = 3

        local value = math.clamp(defaultV, minV, maxV)
        local function render()
            local a = (value - minV) / (maxV - minV)
            Fill.Size = UDim2.new(a, 0, 1, 0)
            Knob.Position = UDim2.new(a, 0, 0.5, 0)
            ValLbl.Text = tostring(value) .. suffix
        end
        render()

        local function setValue(v)
            v = math.clamp(math.floor(v / step + 0.5) * step, minV, maxV)
            if v == value then return end
            value = v
            render()
            pcall(callback, value)
        end

        local function setFromX(x)
            local w = Track.AbsoluteSize.X
            if w <= 0 then return end
            local a = math.clamp((x - Track.AbsolutePosition.X) / w, 0, 1)
            setValue(minV + a * (maxV - minV))
        end

        local dragging = false
        Hit.InputBegan:Connect(function(i)
            if isPress(i) then
                dragging = true
                pcall(function() ScrollHost.ScrollingEnabled = false end)
                Tw2(Knob, { Size = UDim2.new(0, 28, 0, 28) }, 0.12)
                Tw2(Stroke, { Transparency = 0.1 }, 0.12)
                setFromX(i.Position.X)
            end
        end)
        TrackConn(UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
                          or i.UserInputType == Enum.UserInputType.Touch) then
                setFromX(i.Position.X)
            end
        end))
        TrackConn(UserInputService.InputEnded:Connect(function(i)
            if dragging and isPress(i) then
                dragging = false
                pcall(function() ScrollHost.ScrollingEnabled = true end)
                Tw2(Knob, { Size = UDim2.new(0, 22, 0, 22) }, 0.12)
                Tw2(Stroke, { Transparency = 0.55 }, 0.12)
            end
        end))

        local holdId = nil
        local function bindStep(btn, dir)
            btn.InputBegan:Connect(function(i)
                if not isPress(i) then return end
                local id = {}
                holdId = id
                Tw2(btn, { BackgroundColor3 = C_BLUE }, 0.12)
                setValue(value + dir * step)
                task.spawn(function()
                    task.wait(0.4)
                    while holdId == id and Alive() do
                        setValue(value + dir * step)
                        task.wait(0.06)
                    end
                end)
            end)
            btn.InputEnded:Connect(function(i)
                if isPress(i) then
                    holdId = nil
                    Tw2(btn, { BackgroundColor3 = OFF_CLR }, 0.12)
                end
            end)
        end
        bindStep(Minus, -1)
        bindStep(Plus, 1)
    end

    -- ── حقل نص (رابط الويب هوك) ───────────────────────────────
    local function AddInput(placeholder, initial, callback)
        tab.Order = tab.Order + 1
        local R = Instance.new("Frame", tab.Page)
        R.LayoutOrder = tab.Order
        R.Size = UDim2.new(0.98, 0, 0, 44)
        R.BackgroundColor3 = CARD; R.BackgroundTransparency = 0.1; R.BorderSizePixel = 0
        Instance.new("UICorner", R).CornerRadius = UDim.new(0, 10)
        local st = Instance.new("UIStroke", R)
        st.Thickness = 1.2; st.Transparency = 0.55; st.Color = C_GREEN
        local tb = Instance.new("TextBox", R)
        tb.Size = UDim2.new(1, -20, 1, 0); tb.Position = UDim2.new(0, 10, 0, 0)
        tb.BackgroundTransparency = 1; tb.ClearTextOnFocus = false
        tb.Text = initial or ""; tb.PlaceholderText = placeholder
        tb.PlaceholderColor3 = DIM; tb.TextColor3 = Color3.fromRGB(230, 230, 242)
        tb.Font = Enum.Font.Gotham; tb.TextSize = 11
        tb.TextXAlignment = Enum.TextXAlignment.Left
        tb.TextTruncate = Enum.TextTruncate.AtEnd
        tb.Focused:Connect(function() Tw2(st, { Transparency = 0.1 }, 0.12) end)
        tb.FocusLost:Connect(function()
            Tw2(st, { Transparency = 0.55 }, 0.12)
            pcall(callback, tb.Text)
        end)
    end

    local function Card(parent, h)
        tab.Order = tab.Order + 1
        local f = Instance.new("Frame", parent)
        f.LayoutOrder = tab.Order
        f.Size = UDim2.new(0.98, 0, 0, h)
        f.BackgroundColor3 = CARD; f.BackgroundTransparency = 0.08; f.BorderSizePixel = 0
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
        return f
    end

    -- ── قسم قابل للطي: شريط لون جانبي + عدّاد الميزات المفعّلة ──
    local function MakeSection(id, title, color, defaultOpen)
        tab.Order = tab.Order + 1
        local Hdr = Instance.new("TextButton", PAGE)
        Hdr.LayoutOrder = tab.Order; Hdr.Size = UDim2.new(0.98, 0, 0, 50)
        Hdr.BackgroundColor3 = CARD; Hdr.BackgroundTransparency = 0.08
        Hdr.BorderSizePixel = 0; Hdr.Text = ""; Hdr.AutoButtonColor = false
        Instance.new("UICorner", Hdr).CornerRadius = UDim.new(0, 12)
        local st = Instance.new("UIStroke", Hdr)
        st.Thickness = 1.3; st.Transparency = 0.55; st.Color = color

        local bar = Instance.new("Frame", Hdr)
        bar.Size = UDim2.new(0, 5, 1, -16); bar.Position = UDim2.new(0, 8, 0, 8)
        bar.BackgroundColor3 = color; bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

        local TL = Instance.new("TextLabel", Hdr)
        TL.Size = UDim2.new(1, -120, 1, 0); TL.Position = UDim2.new(0, 24, 0, 0)
        TL.BackgroundTransparency = 1; TL.Text = title
        TL.TextColor3 = Color3.fromRGB(230, 230, 242)
        TL.Font = Enum.Font.GothamBold; TL.TextSize = 13
        TL.TextXAlignment = Enum.TextXAlignment.Left
        TL.TextTruncate = Enum.TextTruncate.AtEnd

        local Badge = Instance.new("TextLabel", Hdr)
        Badge.Size = UDim2.new(0, 46, 0, 22); Badge.Position = UDim2.new(1, -92, 0.5, -11)
        Badge.BackgroundColor3 = color; Badge.BackgroundTransparency = 0.7
        Badge.TextColor3 = Color3.new(1, 1, 1); Badge.Font = Enum.Font.GothamBlack
        Badge.TextSize = 11; Badge.Text = "0"; Badge.Visible = false
        Instance.new("UICorner", Badge).CornerRadius = UDim.new(1, 0)

        local Arr = Instance.new("TextLabel", Hdr)
        Arr.Size = UDim2.new(0, 28, 1, 0); Arr.Position = UDim2.new(1, -38, 0, 0)
        Arr.BackgroundTransparency = 1; Arr.Text = ">"; Arr.TextColor3 = DIM
        Arr.Font = Enum.Font.GothamBlack; Arr.TextSize = 18

        tab.Order = tab.Order + 1
        local Cont = Instance.new("Frame", PAGE)
        Cont.LayoutOrder = tab.Order; Cont.Size = UDim2.new(0.98, 0, 0, 0)
        Cont.BackgroundTransparency = 1; Cont.ClipsDescendants = true
        local LL = Instance.new("UIListLayout", Cont)
        LL.SortOrder = Enum.SortOrder.LayoutOrder; LL.Padding = UDim.new(0, 6)
        LL.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local pad = Instance.new("UIPadding", Cont)
        pad.PaddingTop = UDim.new(0, 4); pad.PaddingBottom = UDim.new(0, 8)

        local sec = { cont = Cont, count = 0, color = color }
        function sec.refresh()
            Badge.Visible = sec.count > 0
            Badge.Text = "ON " .. sec.count
        end

        local isOpen = false
        local function apply(open, animate)
            isOpen = open; SecOpen[id] = open
            Cont.AutomaticSize = open and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
            Cont.Size = UDim2.new(0.98, 0, 0, 0)
            local d = animate and 0.2 or 0
            Tw2(Arr, { Rotation = open and 90 or 0, TextColor3 = open and color or DIM }, d)
            Tw2(st, { Transparency = open and 0.15 or 0.55 }, d)
        end
        local startOpen = SecOpen[id]
        if startOpen == nil then startOpen = defaultOpen end
        if startOpen then task.defer(function() apply(true, false) end) end
        Hdr.MouseButton1Click:Connect(function() apply(not isOpen, true) end)
        return sec
    end

    -- يدخل عناصر الهب (Toggle/Slider/Input) داخل القسم
    local function InSection(sec, fn)
        local before = {}
        for _, c in ipairs(PAGE:GetChildren()) do before[c] = true end
        tab.Page = sec.cont
        local ok, err = pcall(fn)
        tab.Page = PAGE
        if not ok then
            warn("[AoT UI] " .. tostring(err))
            local e = Instance.new("TextLabel", sec.cont)
            e.Size = UDim2.new(1, 0, 0, 40); e.BackgroundTransparency = 1
            e.TextWrapped = true; e.TextSize = 11; e.Font = Enum.Font.Gotham
            e.TextColor3 = Color3.fromRGB(255, 120, 120); e.Text = "UI error: " .. tostring(err)
            e.LayoutOrder = 9999
        end
        for _, c in ipairs(PAGE:GetChildren()) do
            if not before[c] and c:IsA("GuiObject") then c.Parent = sec.cont end
        end
    end

    -- توغل يزيد عدّاد القسم تلقائياً (default=true يشغّله مباشرة بعد البناء)
    local allToggles = {}
    local function Tog(sec, text, cb, default)
        local on = false
        local t = tab:AddToggle(text, function(v)
            v = v and true or false
            if v ~= on then
                on = v
                sec.count = sec.count + (v and 1 or -1)
                sec.refresh()
            end
            cb(v)
        end)
        allToggles[#allToggles + 1] = t
        if default then
            task.defer(function() pcall(function() t:SetState(true) end) end)
        end
        return t
    end

    -- شبكة أزرار بعمودين
    local function Grid(sec, items)
        tab.Order = tab.Order + 1
        local G = Instance.new("Frame", sec.cont)
        G.LayoutOrder = tab.Order; G.Size = UDim2.new(0.98, 0, 0, 0)
        G.AutomaticSize = Enum.AutomaticSize.Y; G.BackgroundTransparency = 1
        local GL = Instance.new("UIGridLayout", G)
        GL.CellSize = UDim2.new(0.5, -4, 0, 50)
        GL.CellPadding = UDim2.new(0, 8, 0, 8)
        GL.SortOrder = Enum.SortOrder.LayoutOrder
        for i, it in ipairs(items) do
            local col = it.color or sec.color
            local B = Instance.new("TextButton", G)
            B.LayoutOrder = i
            B.BackgroundColor3 = col; B.BackgroundTransparency = 0.82
            B.BorderSizePixel = 0; B.AutoButtonColor = false
            B.Text = it.text; B.TextColor3 = Color3.fromRGB(235, 235, 245)
            B.Font = Enum.Font.GothamBold; B.TextSize = 12
            B.TextWrapped = true; B.TextTruncate = Enum.TextTruncate.AtEnd
            Instance.new("UICorner", B).CornerRadius = UDim.new(0, 11)
            local s = Instance.new("UIStroke", B)
            s.Thickness = 1.3; s.Color = col; s.Transparency = 0.4
            B.MouseEnter:Connect(function() Tw2(B, { BackgroundTransparency = 0.65 }, 0.1) end)
            B.MouseLeave:Connect(function() Tw2(B, { BackgroundTransparency = 0.82 }, 0.1) end)
            B.MouseButton1Click:Connect(function()
                B.BackgroundTransparency = 0.3
                Tw2(B, { BackgroundTransparency = 0.82 }, 0.25)
                pcall(it.fn)
            end)
        end
    end

    -- ═════════════ بطاقة الحالة (عدّاد العمالقة + الجلسة) ═════════════
    local statCard = Card(PAGE, 58)
    local statStroke = Instance.new("UIStroke", statCard)
    statStroke.Thickness = 1.4; statStroke.Transparency = 0.45; statStroke.Color = C_GREEN
    TitanLabel = Instance.new("TextLabel", statCard)
    TitanLabel.Size = UDim2.new(1, -24, 0, 24); TitanLabel.Position = UDim2.new(0, 12, 0, 6)
    TitanLabel.BackgroundTransparency = 1; TitanLabel.Text = "⚔️  " .. TX("titans") .. ": —"
    TitanLabel.TextColor3 = C_GREEN; TitanLabel.Font = Enum.Font.GothamBold; TitanLabel.TextSize = 12
    TitanLabel.TextXAlignment = Enum.TextXAlignment.Left; TitanLabel.TextTruncate = Enum.TextTruncate.AtEnd
    SessionLabel = Instance.new("TextLabel", statCard)
    SessionLabel.Size = UDim2.new(1, -24, 0, 20); SessionLabel.Position = UDim2.new(0, 12, 0, 32)
    SessionLabel.BackgroundTransparency = 1; SessionLabel.Text = TX("session") .. ": —"
    SessionLabel.TextColor3 = DIM; SessionLabel.Font = Enum.Font.Gotham; SessionLabel.TextSize = 11
    SessionLabel.TextXAlignment = Enum.TextXAlignment.Left; SessionLabel.TextTruncate = Enum.TextTruncate.AtEnd

    -- ═════════════ الأقسام ═════════════
    -- ── الفارم ───────────────────────────────────
    local secFarm = MakeSection("farm", "⚔️  " .. TX("sec.farm"), C_GREEN, true)
    InSection(secFarm, function()
        Tog(secFarm, "🌀  " .. TX("autofarm"), function(v) Cfg.AutoFarm = v end)
        Tog(secFarm, "🎯  " .. TX("multihit"), function(v)
            Cfg.MultiHit = v
            API.resetGather()
        end)
        Tog(secFarm, "🔁  " .. TX("retry"), function(v) Cfg.AutoRetry = v end, true)
        Tog(secFarm, "⏭️  " .. TX("skip"), function(v) Cfg.AutoSkip = v end, true)
        Tog(secFarm, "👻  " .. TX("noclip"), function(v) Cfg.Noclip = v end, true)
        Tog(secFarm, "⛽  " .. TX("reload"), function(v) Cfg.AutoReload = v end, true)
        Tog(secFarm, "🎁  " .. TX("chest"), function(v) Cfg.AutoChest = v end)
        Tog(secFarm, "🔴  " .. TX("chestred"), function(v) Cfg.ChestRed = v end)
    end)
    Grid(secFarm, {
        { text = "🔎  " .. TX("scan"), color = C_CYAN, fn = function() API.scan() end },
    })

    -- ── الإعدادات (سلايدرات) ─────────────────────
    local secAdj = MakeSection("adjust", "🎚️  " .. TX("sec.adjust"), C_CYAN, false)
    InSection(secAdj, function()
        AddSlider(TX("height"), 1, 1000, Config.Height, 5, "", function(v)
            Config.Height = v
            API.resetGather()
        end)
        AddSlider(TX("speed"), 1, 1000, Config.Speed, 5, "", function(v) Config.Speed = v end)
        AddSlider(TX("multicount"), 1, 9, Cfg.MultiHitCount, 1, "", function(v) Cfg.MultiHitCount = v end)
    end)

    -- ── المهارات ─────────────────────────────────
    local secSkill = MakeSection("skills", "✨  " .. TX("sec.skills"), C_PURPLE, false)
    InSection(secSkill, function()
        Tog(secSkill, "🗡️  " .. TX("humskills"), function(v) Cfg.HumanSkills = v end, true)
        Tog(secSkill, "⚡  " .. TX("awaken"), function(v) Cfg.Awakening = v end)
    end)

    -- ── الغارة / مكافحة التعليق ──────────────────
    local secRaid = MakeSection("raid", "🛡️  " .. TX("sec.raid"), C_RED, false)
    InSection(secRaid, function()
        Tog(secRaid, "🎯  " .. TX("raidweak"), function(v) Cfg.RaidWeak = v end, true)
        Tog(secRaid, "🧯  " .. TX("watchdog"), function(v) Cfg.Watchdog = v end, true)
        AddSlider(TX("nokill"), 1, 1000, Cfg.NoKillMin, 1, "", function(v) Cfg.NoKillMin = v end)
        AddSlider(TX("bossnokill"), 1, 1000, Cfg.BossNoKillMin, 1, "", function(v) Cfg.BossNoKillMin = v end)
    end)

    -- ── الحركة ───────────────────────────────────
    local secMove = MakeSection("player", "🏃  " .. TX("sec.player"), C_ORANGE, false)
    InSection(secMove, function()
        Tog(secMove, "💨  " .. TX("runspeed"), function(v) Cfg.SpeedOn = v end)
        AddSlider(TX("runspeed"), 16, 300, Cfg.SpeedVal, 2, "", function(v) Cfg.SpeedVal = v end)
        Tog(secMove, "🦘  " .. TX("jump"), function(v) Cfg.JumpOn = v end)
        AddSlider(TX("jump"), 50, 500, Cfg.JumpVal, 5, "", function(v) Cfg.JumpVal = v end)
        Tog(secMove, "💤  " .. TX("antiafk"), function(v) Cfg.AntiAFK = v end, true)
    end)

    -- ── ويب هوك ديسكورد ──────────────────────────
    local secWh = MakeSection("webhook", "🔔  " .. TX("sec.webhook"), C_GOLD, false)
    InSection(secWh, function()
        Tog(secWh, "📨  " .. TX("whon"), function(v) Cfg.WebhookOn = v end)
        Tog(secWh, "🙈  " .. TX("whhide"), function(v) Cfg.WebhookHide = v end)
        AddInput("https://discord.com/api/webhooks/...", Cfg.WebhookUrl, function(txt)
            Cfg.WebhookUrl = txt or ""
        end)
    end)
    Grid(secWh, {
        { text = "🧪  " .. TX("whtest"), color = C_GOLD, fn = function() API.webhookTest() end },
        { text = "📋  Dump UI", color = C_CYAN, fn = function() API.dump() end },
    })

    -- ── زر إيقاف الكل ────────────────────────────
    tab.Order = tab.Order + 1
    local StopB = Instance.new("TextButton", PAGE)
    StopB.LayoutOrder = tab.Order; StopB.Size = UDim2.new(0.98, 0, 0, 50)
    StopB.BackgroundColor3 = C_RED; StopB.BackgroundTransparency = 0.8
    StopB.BorderSizePixel = 0; StopB.AutoButtonColor = false
    StopB.Text = "⛔  " .. TX("stopall")
    StopB.TextColor3 = Color3.fromRGB(255, 200, 200)
    StopB.Font = Enum.Font.GothamBlack; StopB.TextSize = 13
    Instance.new("UICorner", StopB).CornerRadius = UDim.new(0, 12)
    local sbs = Instance.new("UIStroke", StopB)
    sbs.Thickness = 1.4; sbs.Color = C_RED; sbs.Transparency = 0.35
    StopB.MouseButton1Click:Connect(function()
        for _, t in ipairs(allToggles) do pcall(function() t:SetState(false) end) end
        Cfg.AutoFarm = false
        StopB.BackgroundTransparency = 0.4
        Tw2(StopB, { BackgroundTransparency = 0.8 }, 0.3)
    end)

    do
        local sp = Instance.new("Frame", PAGE)
        sp.LayoutOrder = tab.Order + 1; sp.Size = UDim2.new(0.98, 0, 0, 14)
        sp.BackgroundTransparency = 1; sp.BorderSizePixel = 0
    end
    end -- do (الواجهة)
end

-- ============================================================
-- 3. إرجاع الجدول
-- ============================================================
return {
    Name   = "Attack on Titan",
    Render = Render,
}
