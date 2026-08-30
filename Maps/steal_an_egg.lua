-- [[ Cryptic Hub - Map: Steal An Egg ]]
-- جميع إيديات Steal An Egg تشير لهذا الملف

return {
    Name = "Steal An Egg",
    Scripts = {
        {
            Name = "Ouroboros (keyless)",
            Script = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/joustingmatch/Ouroboros/main/loader.lua"))()]]
        },
        {
            Name = "Oxide Loader",
            Script = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/xulfo/Oxide-Loader/main/Main.lua"))()]]
        }
    }
}