Config = {}

-- ============================================================
--  DISCORD WEBHOOK LOGOVANIE
-- ============================================================
Config.Webhook = {
    enabled  = true,
    url      = "https://discord.com/api/webhooks/1489208015063351456/cJLgGbxaJbzFsiKFT4Hl39F1JxLI7JJ6eGz3qc39C9ZSpJ3mJTcYGCU1xa6FPHr5-lYg",  -- <-- sem daj svoj webhook

    colors = {
        harvest = 3066993,   
        drying  = 15844367,  
        packing = 3447003,  
        sell    = 15158332,  
        fail    = 15158332,  
        error   = 15158332,
    },

    icons = {
        harvest = "🌿",
        drying  = "🔥",
        packing = "📦",
        sell    = "💰",
        fail    = "❌",
    },

    botName   = "DZNS DRUGS |LOGY",
    botAvatar = "https://i.imgur.com/AfFp7pu.png", 
}

Config.Trees = {
    {
        model = `prop_plant_fern_02b`, 
        coords = {
            vector3(1866.1444, -241.9536, 291.0867),
            vector3(1864.6356, -235.7959, 291.4021),
            vector3(1852.9163, -237.9716, 293.9747),
            vector3(1854.9998, -230.7730, 293.0557),
            vector3(1856.1152, -246.9371, 291.1846),
            vector3(1865.2164, -250.1088, 288.5871),
            vector3(1871.3821, -251.3002, 287.3878),
            vector3(1874.7295, -236.8234, 288.8045),
        },
        harvestItem = "coca_leaf",      
        harvestAmount = { min = 3, max = 10 }, 
        harvestTime = 5000,              
        harvestLabel = "Zbieranie listov koky",
        cooldown = 15,             
    }
}

Config.Drying = {
    coords = vector3(1389.4406, 3600.7490, 38.9419), 
    prop = `prop_cs_cardbox_01`,
    label = "Sušiť listy koky",
    recipe = {
        input = { item = "coca_leaf", amount = 5 },
        output = { item = "dried_coca", amount = 1 },
        time = 8000, 
        progressLabel = "Sušenie listov...",
    }
}


Config.Packing = {
    coords = vector3(724.6938, -1189.7804, 24.2796), 
    prop = `prop_ven_market_table1`,
    label = "Zabaliť kokain",
    recipe = {
        input1 = { item = "dried_coca", amount = 1 },
        input2 = { item = "sacok", amount = 1 },  
        output = { item = "cocaine_bag", amount = 1 },
        time = 5000,
        progressLabel = "Balenie kokainu...",
    }
}


Config.Dealer = {
    coords = vector3(581.5172, 2782.0386, 43.4812), 
    ped = `a_m_m_business_2`,              
    label = "Predať drogy",
    sellItem = "cocaine_bag",
    sellPrice = { min = 5000, max = 10000 },
    scenario = "WORLD_HUMAN_STAND_MOBILE",
}

Config.Items = {
    ["sacok"]        = { label = "Sáčok",         weight = 10  },
    ["coca_leaf"]    = { label = "Lístok koky",   weight = 20  },
    ["dried_coca"]   = { label = "Sušený koks",   weight = 30  },
    ["cocaine_bag"]  = { label = "Sáčok kokaínu", weight = 50  },
}