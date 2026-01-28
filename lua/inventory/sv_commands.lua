include("inventory/sv_inventory_database.lua")
include("inventory/sh_inventory_items.lua")


local function serverCommands(sender, text)

    if string.match(text, "!init") then
        DeleteTable()
        CreateTable()
        for k, v in pairs(InventoryItems) do
            CreateItem(k, v.Name, v.Size, v.Color, v.Ammo or 0)
            
        end
        CreatePlayer(sender, "Starter")
        -- for everything in {} Starter add to player inventory
        for itemKey, itemData in pairs(inventoryKit["Starter"]) do
            createInventoryEntry(sender, itemData, 1)
        end
        return ""
    elseif string.match(text, "!reloadServer") or string.match(text, "!r") then
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
        local inventory = readInventory(sender)
        if not inventory then
            return ""
        end
        for k, v in pairs(inventory) do
        end
        return "" 
    elseif string.match(text, "!addtoinventory") or string.match(text, "!add") then
        local args = string.sub(text, string.find(text, " ") + 1)
        local itemName, amount = args:match("^(%S+)%s*(%d*)$")

        amount = tonumber(amount) or 1

        createInventoryEntry(sender, itemName, amount)
        return ""
    elseif string.match(text, "!removefrominventory") or string.match(text, "!remove") then
        local args = string.sub(text, string.find(text, " ") + 1, nil)
        local itemName, amount = args:match("^(%S+)%s*(%d*)$")
        deleteInventoryEntry(sender, itemName, tonumber(amount) or -1)
        return ""
    end


end


hook.Add("PlayerAuthed", "CreatePlayerEntry", function(ply, steamID, uniqueID)
    timer.Simple(5, function()
        local result = ReadPlayer(ply)
        if(not result) then
            CreatePlayer(ply, "Starter")
            -- for everything in {} Starter add to player inventory
            for itemKey, itemData in pairs(inventoryKit["Starter"]) do
                createInventoryEntry(ply, itemData, 1)
            end
            SyncPlayerInventory(ply)
        end
    end)
end)

hook.Add("PlayerSay", "ServerCommands", serverCommands)