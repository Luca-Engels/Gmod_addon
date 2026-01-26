-- CRUD Database

-- CRUD Player

-- ENDPOINTS FOR CRUD INVENTORY


function CreateTable()
    sql.Query("CREATE TABLE IF NOT EXISTS player_data (SteamID TEXT PRIMARY KEY, Faction TEXT)")
    sql.Query("CREATE TABLE IF NOT EXISTS item_data (Item_ID TEXT, Item_Name TEXT, Size INTEGER, Color_HEX VARCHAR(7), Ammo INTEGER, PRIMARY KEY (Item_ID))")
    sql.Query("CREATE TABLE IF NOT EXISTS player_inventory (SteamID TEXT, Item_ID TEXT, Amount INTEGER, PRIMARY KEY (SteamID, Item_ID))")
end

function ReadTable()
    local playerData = sql.Query("SELECT * FROM player_data")
    local itemData = sql.Query("SELECT * FROM item_data")
    local playerInventory = sql.Query("SELECT * FROM player_inventory")

    return {
        playerData = playerData,
        itemData = itemData,
        playerInventory = playerInventory
    }
end

function DeleteTable()
    sql.Query("DROP TABLE IF EXISTS player_data")
    sql.Query("DROP TABLE IF EXISTS item_data")
    sql.Query("DROP TABLE IF EXISTS player_inventory")
end

function CreatePlayer(player, faction)
    local result = ReadPlayer(player)
    if(result) then
        ErrorNoHalt("Player with SteamID: " .. player:SteamID() .. " already exists.\n")
        return
    end
    sql.Query("INSERT INTO player_data (SteamID, Faction) VALUES ('" .. player:SteamID() .. "', '" .. faction .. "')")
end

function ReadPlayer(player)
    print("Reading player with SteamID: " .. player:SteamID())
    local result = sql.Query("SELECT * FROM player_data WHERE SteamID = '" .. player:SteamID() .. "'")
    if(not result) then
        ErrorNoHalt("No player found with SteamID: " .. player:SteamID() .. "\n")
        return nil
    end
    return result
end

function UpdatePlayer(player, faction)
    local result = ReadPlayer(player)
    if(not result) then
        return
    end
    sql.Query("UPDATE player_data SET Faction = '" .. faction .. "' WHERE SteamID = '" .. player:SteamID() .. "'" )
end

function DeletePlayer(player)
    local result = ReadPlayer(player)
    if(not result) then
        return
    end
    sql.Query("DELETE FROM player_data WHERE SteamID = '" .. player:SteamID() .. "'")
end

function CreateItem(itemID, itemName, size, colorHex, ammo)
    local result = ReadItem(itemID)
    if(result) then
        ErrorNoHalt("Item with ID: " .. itemID .. " already exists.\n")
        return
    end

    sql.Query("INSERT INTO item_data (Item_ID, Item_Name, Size, Color_HEX, Ammo) VALUES ('" .. itemID .. "', '" .. itemName .. "', " .. size .. ", '" .. colorHex .. "', " .. ammo .. ")")
end

function ReadItem(itemID)
    local result = sql.Query("SELECT * FROM item_data WHERE Item_ID = '" .. itemID .. "'")
    if(not result) then
        ErrorNoHalt("No item found with ID: " .. itemID .. "\n")
        return nil
    end
    return result
end

function UpdateItem(itemID, itemName, size, colorHex)
    local result = ReadItem(itemID)
    if(not result) then
        return
    end
    sql.Query("UPDATE item_data SET Item_Name = '" .. itemName .. "', Size = " .. size .. ", Color_HEX = '" .. colorHex .. "' WHERE Item_ID = '" .. itemID .. "'")
end

function DeleteItem(itemID)
    local result = ReadItem(itemID)
    if(not result) then
        return
    end
    sql.Query("DELETE FROM item_data WHERE Item_ID = '" .. itemID .. "'")
end

function createInventoryEntry(player, itemID, amount)
    local result = ReadPlayer(player)
    if(not result) then
        ErrorNoHalt("No player found with SteamID: " .. player:SteamID() .. "\n")
        return
    end
    local itemResult = ReadItem(itemID)
    if(not itemResult) then
        ErrorNoHalt("No item found with ID: " .. itemID .. "\n")
        return
    end
    local inventoryResult = readInventoryEntry(player, itemID)
    if(inventoryResult) then
        updateInventoryEntry(player, itemID, amount + tonumber(inventoryResult[1].Amount))
        print("Updated existing inventory entry for SteamID: " .. player:SteamID() .. " and Item_ID: " .. itemID .. " to amount: " .. (amount + tonumber(inventoryResult[1].Amount)) .. "\n")
        return
    end
    sql.Query("INSERT INTO player_inventory (SteamID, Item_ID, Amount) VALUES ('" .. player:SteamID() .. "', '" .. itemID .. "', " .. amount .. ")")
    SyncPlayerInventory(player)

end
function readInventory(player)
    local result = sql.Query("SELECT * FROM player_inventory WHERE SteamID = '" .. player:SteamID() .. "'")
    if(not result) then
        ErrorNoHalt("No inventory entry found for SteamID: " .. player:SteamID() .. "\n")
        return {}
    end
    return result
end
function readInventoryEntry(player, itemID)
    print("Reading inventory entry for SteamID: " .. player:SteamID() .. " and Item_ID: " .. itemID)
    local result = sql.Query("SELECT * FROM player_inventory WHERE SteamID = '" .. player:SteamID() .. "' AND Item_ID = '" .. itemID .. "'")
    if(not result) then
        ErrorNoHalt("No inventory entry found for SteamID: " .. player:SteamID() .. " and Item_ID: " .. itemID .. "\n")
        return nil
    end
    return result
end
function updateInventory(player, inventory)
    for k, v in pairs(inventory) do
        updateInventoryEntry(player, v.Item_ID, v.Amount)
    end
    SyncPlayerInventory(player)
end
function updateInventoryEntry(player, itemID, amount)
    local result = readInventoryEntry(player, itemID)
    if amount <= 0 then
        amount = 1
    end
    if(not result) then
        return
    end
    sql.Query("UPDATE player_inventory SET Amount = " .. amount .. " WHERE SteamID = '" .. player:SteamID() .. "' AND Item_ID = '" .. itemID .. "'")
    SyncPlayerInventory(player)
end
function deleteInventoryEntry(player, itemID, amount)
    local result = readInventoryEntry(player, itemID)
    if(not result) then
        return
    end
    if (amount < 1) or (tonumber(result[1].Amount) <= amount) then
        sql.Query("DELETE FROM player_inventory WHERE SteamID = '" .. player:SteamID() .. "' AND Item_ID = '" .. itemID .. "'")
        SyncPlayerInventory(player)
    else
        sql.Query("DELETE FROM player_inventory WHERE SteamID = '" .. player:SteamID() .. "' AND Item_ID = '" .. itemID .. "'")
        updateInventoryEntry(player, itemID, tonumber(result[1].Amount) - amount)
    end
end
