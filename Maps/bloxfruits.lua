return {
    Name = "Blox Fruits",
    Scripts = {
        {
            Name = "QuantumOnyx",
            Script = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/flazhy/QuantumOnyx/refs/heads/main/QuantumOnyx.lua"))()]]
        },
        {
            Name = "No Lag Hub",
            Script = [[loadstring(game:HttpGet("https://nolag.wtf/script.lua"))()]]
        },
        {
            Name = "Gravity Hub",
            Script = [[
                GravityHubBF = {
                    Team = "Marines",
                    Color = "Green"
                }
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Dev-GravityHub/BloxFruits/refs/heads/main/Main.lua"))()
            ]]
        }
    }
}