local function notify(src, msg, ntype)
    TriggerClientEvent("cocaine:notify", src, msg, ntype or "inform")
end

local function hasItem(src, item, amount)
    return exports.ox_inventory:GetItemCount(src, item) >= amount
end

local function removeItem(src, item, amount)
    return exports.ox_inventory:RemoveItem(src, item, amount)
end

local function addItem(src, item, amount)
    return exports.ox_inventory:AddItem(src, item, amount)
end

RegisterNetEvent("cocaine:harvestLeaves", function(treeIndex, key)
    local src = source
    local tree = Config.Trees[treeIndex]
    if not tree then return end

    local amount = math.random(tree.harvestAmount.min, tree.harvestAmount.max)

    if addItem(src, tree.harvestItem, amount) then
        notify(src, "Zobral si " .. amount .. "x lístok koky! 🌿", "success")
    else
        notify(src, "Nemáš dosť miesta v inventári!", "error")
    end
end)

RegisterNetEvent("cocaine:dryCoca", function()
    local src = source
    local recipe = Config.Drying.recipe

    if not hasItem(src, recipe.input.item, recipe.input.amount) then
        notify(src, "Potrebuješ " .. recipe.input.amount .. "x " .. recipe.input.item .. "!", "error")
        return
    end

    if removeItem(src, recipe.input.item, recipe.input.amount) then
        if addItem(src, recipe.output.item, recipe.output.amount) then
            notify(src, "Vysušil si " .. recipe.output.amount .. "x sušený koks! 🔥", "success")
        else
            -- vráť item ak sa nepodaril add
            addItem(src, recipe.input.item, recipe.input.amount)
            notify(src, "Nemáš dosť miesta v inventári!", "error")
        end
    else
        notify(src, "Chyba pri odoberaní itemov!", "error")
    end
end)

RegisterNetEvent("cocaine:packCocaine", function()
    local src = source
    local recipe = Config.Packing.recipe

    if not hasItem(src, recipe.input1.item, recipe.input1.amount) then
        notify(src, "Potrebuješ " .. recipe.input1.amount .. "x sušený koks!", "error")
        return
    end

    if not hasItem(src, recipe.input2.item, recipe.input2.amount) then
        notify(src, "Potrebuješ " .. recipe.input2.amount .. "x sáčok!", "error")
        return
    end

    if removeItem(src, recipe.input1.item, recipe.input1.amount) and
       removeItem(src, recipe.input2.item, recipe.input2.amount) then
        if addItem(src, recipe.output.item, recipe.output.amount) then
            notify(src, "Zabalil si " .. recipe.output.amount .. "x sáčok kokaínu! ", "success")
        else
    
            addItem(src, recipe.input1.item, recipe.input1.amount)
            addItem(src, recipe.input2.item, recipe.input2.amount)
            notify(src, "Nemáš dosť miesta v inventári!", "error")
        end
    else
        notify(src, "Chyba pri odoberaní itemov!", "error")
    end
end)

RegisterNetEvent("cocaine:sellDrugs", function()
    local src = source
    local dealer = Config.Dealer

    if not hasItem(src, dealer.sellItem, 1) then
        notify(src, "Nemáš žiadne sáčky kokaínu!", "error")
        return
    end

    -- Náhodný počet od 1 do 5
    local bagsToSell = math.random(1, 5)
    local count = exports.ox_inventory:GetItemCount(src, dealer.sellItem)
    
    if count < bagsToSell then
        bagsToSell = count
    end

    TriggerClientEvent("cocaine:startSellAnimation", src, bagsToSell)
end)

RegisterNetEvent("cocaine:completeSell", function(bagsToSell)
    local src = source
    local dealer = Config.Dealer

    if not hasItem(src, dealer.sellItem, bagsToSell) then
        notify(src, "Chyba! Nemáš toľko sáčkov!", "error")
        return
    end

    if not removeItem(src, dealer.sellItem, bagsToSell) then
        notify(src, "Chyba pri predaji!", "error")
        return
    end

    local totalEarned = 0
    for i = 1, bagsToSell do
        totalEarned = totalEarned + math.random(dealer.sellPrice.min, dealer.sellPrice.max)
    end

    addItem(src, "money", totalEarned)

    notify(src, "Predal si " .. bagsToSell .. "x sáčok kokaínu za $" .. totalEarned .. "! 💰", "success")
    TriggerClientEvent("cocaine:markNpcAsSold", src)
end)
