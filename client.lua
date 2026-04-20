local treeCooldowns = {}
local spawnedProps = {}
local dealerPed = nil

-- ============================================================
--  UTILITY
-- ============================================================
local function notify(msg, ntype)
    lib.notify({ title = "Drogy", description = msg, type = ntype or "inform" })
end

-- ============================================================
--  QTE PROGRESS BAR  (stlač E v správnom čase)
--
--  Parametry:
--    duration     – celková dĺžka v ms
--    label        – text nad barom
--    windowPct    – veľkosť zeleného okna  (0.0 – 1.0), default 0.18
--    animDict/Clip – animácia počas akcie
--
--  Návratová hodnota:
--    true  – hráč stlačil E v zelenom okne
--    false – nestlačil, stlačil mimo, alebo sa vzdal (ESC/backspace)
-- ============================================================
local function qteProgress(params)
    local duration   = params.duration   or 5000
    local label      = params.label      or "Drž a stlač E..."
    local windowPct  = params.windowPct  or 0.18
    local animDict   = params.animDict
    local animClip   = params.animClip

    -- Zahrať animáciu
    if animDict and animClip then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do Wait(50) end
        TaskPlayAnim(PlayerPedId(), animDict, animClip, 3.0, -1.0, -1, 1, 0, false, false, false)
    end

    local ped = PlayerPedId()

    -- Náhodná pozícia zeleného okna (začiatok ako % z celku, 10%–72%)
    local windowStart = math.random(10, math.floor((1.0 - windowPct) * 100)) / 100

    local startTime = GetGameTimer()
    local done      = false
    local result    = false

    -- Zobraz NUI progress bar
    SendNUIMessage({
        type        = "qte_start",
        label       = label,
        duration    = duration,
        windowStart = windowStart,
        windowSize  = windowPct,
    })

    -- Hlavná QTE slučka
    while not done do
        DisableAllControlActions(0)

        local elapsed  = GetGameTimer() - startTime
        local progress = elapsed / duration

        -- Stlačil E
        if IsDisabledControlJustPressed(0, 38) then
            done = true
            if progress >= windowStart and progress <= (windowStart + windowPct) then
                result = true
            else
                result = false
            end

        -- Zrušil (Backspace alebo ESC)
        elseif IsDisabledControlJustPressed(0, 177) or IsDisabledControlJustPressed(0, 200) then
            done = true
            result = false
            notify("Akcia zrušená.", "error")

        -- Čas vypršal – nestlačil vôbec
        elseif elapsed >= duration then
            done   = true
            result = false
        end

        Wait(0)
    end

    -- Uprac
    SendNUIMessage({ type = "qte_stop" })
    EnableAllControlActions(0)
    if animDict and animClip then
        StopAnimTask(ped, animDict, animClip, 1.0)
    end

    return result
end

-- ============================================================
--  SPAWN STROMY
-- ============================================================
local function spawnTrees()
    for i, tree in ipairs(Config.Trees) do
        for j, coord in ipairs(tree.coords) do
            local key = i .. "_" .. j

            RequestModel(tree.model)
            while not HasModelLoaded(tree.model) do Wait(100) end

            local obj = CreateObject(tree.model, coord.x, coord.y, coord.z - 1.0, false, false, false)
            PlaceObjectOnGroundProperly(obj)
            FreezeEntityPosition(obj, true)
            SetEntityInvincible(obj, true)
            table.insert(spawnedProps, obj)

            exports.ox_target:addLocalEntity(obj, {
                {
                    name     = "harvest_tree_" .. key,
                    icon     = "fas fa-leaf",
                    label    = "Zbierať listy koky",
                    distance = 2.0,
                    onSelect = function()
                        if treeCooldowns[key] and (GetGameTimer() - treeCooldowns[key]) < (tree.cooldown * 1000) then
                            local remaining = math.ceil((tree.cooldown * 1000 - (GetGameTimer() - treeCooldowns[key])) / 1000)
                            notify("Strom je prázdny! Skús o " .. remaining .. "s", "error")
                            return
                        end

                        local success = qteProgress({
                            duration  = tree.harvestTime,
                            label     = tree.harvestLabel .. " – stlač [E] v zelenom!",
                            animDict  = "amb@world_human_gardener_plant@male@base",
                            animClip  = "base",
                        })

                        if success then
                            treeCooldowns[key] = GetGameTimer()
                            TriggerServerEvent("cocaine:harvestLeaves", i, key)
                        else
                            notify("Pokazil si to!", "error")
                        end
                    end
                }
            })
        end
    end
end

-- ============================================================
--  SUŠENIE
-- ============================================================
local function setupDrying()
    local d = Config.Drying

    exports.ox_target:addSphereZone({
        coords  = d.coords,
        radius  = 1.5,
        debug   = false,
        options = {
            {
                name     = "dry_coca",
                icon     = "fas fa-fire",
                label    = d.label,
                distance = 2.0,
                onSelect = function()
                    local success = qteProgress({
                        duration = d.recipe.time,
                        label    = d.recipe.progressLabel .. " – stlač [E] v zelenom!",
                        animDict = "mini@repair",
                        animClip = "fixing_a_ped",
                    })

                    if success then
                        TriggerServerEvent("cocaine:dryCoca")
                    else
                        notify("Pokazil si sušenie! Skús znova.", "error")
                    end
                end
            }
        }
    })
end

-- ============================================================
--  BALENIE
-- ============================================================
local function setupPacking()
    local p = Config.Packing

    exports.ox_target:addSphereZone({
        coords  = p.coords,
        radius  = 1.5,
        debug   = false,
        options = {
            {
                name     = "pack_cocaine",
                icon     = "fas fa-box",
                label    = p.label,
                distance = 2.0,
                onSelect = function()
                    local success = qteProgress({
                        duration = p.recipe.time,
                        label    = p.recipe.progressLabel .. " – stlač [E] v zelenom!",
                        animDict = "anim@heists@ornate_bank@thermal_charge",
                        animClip = "thermal_charge",
                    })

                    if success then
                        TriggerServerEvent("cocaine:packCocaine")
                    else
                        notify("Pokazil si balenie! Skús znova.", "error")
                    end
                end
            }
        }
    })
end

-- ============================================================
--  DEALER PED + PREDAJ
-- ============================================================
local trackedPeds = {}
local soldToNpcs = {}

local function spawnDealer()
    local d = Config.Dealer

    CreateThread(function()
        while true do
            Wait(1000)
            
            local allPeds = GetGamePool('CPed') or {}
            
            for _, ped in ipairs(allPeds) do
                if ped ~= PlayerPedId() and DoesEntityExist(ped) and not IsEntityDead(ped) then
                    if not trackedPeds[ped] then
                        SetEntityInvincible(ped, true)
                        
                        exports.ox_target:addLocalEntity(ped, {
                            {
                                name     = "sell_cocaine",
                                icon     = "fas fa-dollar-sign",
                                label    = d.label,
                                distance = 2.5,
                                onSelect = function()
                                    if not soldToNpcs[ped] then
                                        TriggerServerEvent("cocaine:sellDrugs")
                                    else
                                        notify("Už si to predal/a tomuto NPCku!", "error")
                                    end
                                end
                            }
                        })
                        
                        trackedPeds[ped] = true
                    end
                end
            end
        end
    end)
end

-- ============================================================
--  PREDAJ ANIMÁCIA
-- ============================================================
RegisterNetEvent("cocaine:startSellAnimation", function(bagsToSell)
    notify("Predávam " .. bagsToSell .. "x sáčok...", "inform")
    
    -- Krátka čakacia doba - simulácia transakcie
    Wait(2000)
    
    -- Poslať kompletáciu na server
    TriggerServerEvent("cocaine:completeSell", bagsToSell)
end)

-- ============================================================
--  INIT
-- ============================================================
CreateThread(function()
    Wait(1000)
    spawnTrees()
    setupDrying()
    setupPacking()
    spawnDealer()
end)

-- ============================================================
--  SERVER CALLBACKY
-- ============================================================
RegisterNetEvent("cocaine:notify", function(msg, ntype)
    notify(msg, ntype)
end)

RegisterNetEvent("cocaine:markNpcAsSold", function()
    -- Označ všetky NPCká ako už predané v tejto session
    local allPeds = GetGamePool('CPed') or {}
    for _, ped in ipairs(allPeds) do
        soldToNpcs[ped] = true
    end
end)
