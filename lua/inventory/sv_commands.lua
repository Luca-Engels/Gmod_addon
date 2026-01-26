include("inventory/sv_inventory_database.lua")
include("inventory/sh_inventory_items.lua")


local function serverCommands(sender, text)

    if string.match(text, "!init") then
        print("Initializing database...")
        DeleteTable()
        CreateTable()
        for k, v in pairs(InventoryItems) do
            local colorHex = string.format("#%02X%02X%02X", v.Texture_R, v.Texture_G, v.Texture_B)
            CreateItem(k, v.Name, v.Size, colorHex, v.Ammo)
            
        end
        CreatePlayer(sender, "Starter")
        -- for everything in {} Starter add to player inventory
        for itemKey, itemData in pairs(inventoryKit["Starter"]) do
            createInventoryEntry(sender, itemData, 1)
            print("Gave " .. sender:Nick() .. " item: " .. itemData)
        end
        print("Database initialized.")
        return ""
    elseif string.match(text, "!reloadServer") then
        print("Reloading server...")
        RunConsoleCommand("changelevel", game.GetMap())
        return ""
    elseif string.match(text, "!sync") then
        SyncPlayerInventory(sender)
        sender:ChatPrint("Inventory synced.")
        return ""
    elseif string.match(text, "!admin") then
        if sender:IsSuperAdmin() then
            sender:SetUserGroup("user")
            sender:ChatPrint("User")
        else
            sender:SetUserGroup("superadmin")
            sender:ChatPrint("Admin")
        end

        return ""
    elseif string.match(text, "!print") then
        print(PrintTable(ReadTable()))
        local inventory = readInventory(sender)
        print ("Inventory for " .. sender:Nick() .. ":")
        if not inventory then
            print("Inventory is empty.")
            return ""
        end
        for k, v in pairs(inventory) do
            print("Item ID: " .. v.Item_ID .. " | Quantity: " .. v.Amount)
        end
        return "" 
    elseif string.match(text, "!addtoinventory") or string.match(text, "!add") then
        local args = string.sub(text, string.find(text, " ") + 1)
        local itemName, amount = args:match("^(%S+)%s*(%d*)$")

        amount = tonumber(amount) or 1

        print("Adding item to inventory: " .. itemName)
        createInventoryEntry(sender, itemName, amount)
        return ""
    elseif string.match(text, "!removefrominventory") or string.match(text, "!remove") then
        local args = string.sub(text, string.find(text, " ") + 1, nil)
        local itemName, amount = args:match("^(%S+)%s*(%d*)$")
        print("Removing item from inventory: " .. itemName .. " Amount: " .. (tonumber(amount) or -1))
        deleteInventoryEntry(sender, itemName, tonumber(amount) or -1)
        return ""
    end


end


hook.Add("PlayerAuthed", "CreatePlayerEntry", function(ply, steamID, uniqueID)
    timer.Simple(5, function()
        local result = ReadPlayer(ply)
        if(not result) then
            print("Creating player entry for: " .. ply:Nick())
            CreatePlayer(ply, "Starter")
            -- for everything in {} Starter add to player inventory
            for itemKey, itemData in pairs(inventoryKit["Starter"]) do
                createInventoryEntry(ply, itemData, 1)
                print("Gave " .. ply:Nick() .. " starter x" .. starterAmt .. " of " .. itemKey)
            end
        end
    end)
end)

hook.Add("PlayerSay", "ServerCommands", serverCommands)