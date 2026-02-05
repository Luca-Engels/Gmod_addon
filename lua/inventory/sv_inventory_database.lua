-- CRUD Database

-- CRUD Player

-- ENDPOINTS FOR CRUD INVENTORY


function CreateTable()
    sql.Query("CREATE TABLE IF NOT EXISTS player_data (SteamID TEXT PRIMARY KEY, Faction TEXT)")
    sql.Query("CREATE TABLE IF NOT EXISTS item_data (Item_ID TEXT, Item_Name TEXT, Size INTEGER, Color_HEX VARCHAR(7), Ammo INTEGER, PRIMARY KEY (Item_ID))")
    -- id = SteamID or classID or fractionID
    -- type = "player_inventory", "armory_storage", "fraction_storage" , "player_storage"
    sql.Query("CREATE TABLE IF NOT EXISTS storage (id TEXT, Item_ID TEXT, AMOUNT INTEGER, StorageType TEXT, PRIMARY KEY (id, Item_ID))")
    sql.Query("CREATE TABLE IF NOT EXISTS fraction_classes (fractionID TEXT, classID TEXT, PRIMARY KEY (fractionID, classID))")
end

function ReadTable()
    local playerData = sql.Query("SELECT * FROM player_data")
    local itemData = sql.Query("SELECT * FROM item_data")
    local inventory = sql.Query("SELECT * FROM storage")
    local fractionClasses = sql.Query("SELECT * FROM fraction_classes")
        return {
        playerData = playerData,
        itemData = itemData,
        fractionClasses = fractionClasses,
        inventory = inventory
    }
end

function DeleteTable()
    sql.Query("DROP TABLE IF EXISTS player_data")
    sql.Query("DROP TABLE IF EXISTS item_data")
    sql.Query("DROP TABLE IF EXISTS storage")
    sql.Query("DROP TABLE IF EXISTS fraction_classes")
end

function CreatePlayer(player, faction)
    local result = readPlayer(player)
    if(result) then
        ErrorNoHalt("Player with SteamID: " .. player:SteamID() .. " already exists.\n")
        return
    end
    sql.Query("INSERT INTO player_data (SteamID, Faction) VALUES ('" .. player:SteamID() .. "', '" .. faction .. "')")
end

function readPlayer(player)
    local result = sql.Query("SELECT * FROM player_data WHERE SteamID = '" .. player:SteamID() .. "'")
    if(not result) then
        ErrorNoHalt("No player found with SteamID: " .. player:SteamID() .. "\n")
        return nil
    end
    return result
end

function UpdatePlayer(player, faction)
    local result = readPlayer(player)
    if(not result) then
        return
    end
    sql.Query("UPDATE player_data SET Faction = '" .. faction .. "' WHERE SteamID = '" .. player:SteamID() .. "'" )
end

function DeletePlayer(player)
    local result = readPlayer(player)
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
    ErrorNoHalt("  => Creating Item with ID: " .. itemID .. ".\n")
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
    local result = readPlayer(player)
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
        print(amount + tonumber(inventoryResult[1].Amount))
        updateInventoryEntry(player, itemID, amount + tonumber(inventoryResult[1].Amount),nil)
        return
    end
    sql.Query("INSERT INTO storage(id, Item_ID, AMOUNT, StorageType) VALUES ('" .. player:SteamID() .. "', '" .. itemID .. "', " .. amount .. ", 'player_inventory')")
end
function readInventory(player)
    local result = sql.Query("SELECT * FROM storage WHERE id = '" .. player:SteamID() .. "' AND StorageType = 'player_inventory'")
    for _, row in ipairs(result) do
        row.Active = tonumber(row.Active) == 1
    end
    if(not result) then
        ErrorNoHalt("No inventory entry found for SteamID: " .. player:SteamID() .. "\n")
        return {}
    end
    return result
end
function readInventoryEntry(player, itemID)
    local result = sql.Query("SELECT * FROM storage WHERE id = '" .. player:SteamID() .. "' AND Item_ID = '" .. itemID .. "' AND StorageType = 'player_inventory'")
    if(not result) then
        ErrorNoHalt("No inventory entry found for SteamID: " .. player:SteamID() .. " and Item_ID: " .. itemID .. "\n")
        return nil
    end
        ErrorNoHalt("Inventory entry found for SteamID: " .. player:SteamID() .. " and Item_ID: " .. itemID .. "\n")
    return result
end
function updateInventory(player, inventory)
    for k, v in pairs(inventory) do
        updateInventoryEntry(player, v.Item_ID, v.Amount, v.Active)
    end
    SyncPlayerInventory(player)
end
function updateInventoryEntry(player, itemID, amount, active)
    local result = readInventoryEntry(player, itemID)
    if not result then return end


    if amount == nil then
        amount = tonumber(result.Amount)
    end

    if active == nil then
        active = tonumber(result.Active) == 1
    end

    local activeValue = active and 1 or 0

    print(player,itemID,amount,activeValue,result)
    sql.Query("UPDATE storage SET Amount = " .. amount .. ", Active = " .. activeValue .. " WHERE id = '" .. player:SteamID() .. "' AND Item_ID = '" .. itemID .. "' AND StorageType = 'player_inventory'")

end


function deleteInventoryEntry(player, itemID, amount)
    local result = readInventoryEntry(player, itemID)
    if(not result) then
        return
    end
    if (amount < 1) or (tonumber(result[1].Amount) <= amount) then
        sql.Query("DELETE FROM storage WHERE id = '" .. player:SteamID() .. "' AND Item_ID = '" .. itemID .. "' AND StorageType = 'player_inventory'")
        SyncPlayerInventory(player)
    else
        updateInventoryEntry(player, itemID, tonumber(result[1].Amount) - amount)
    end
end


function createClassEntry(className,itemID)
    local result = sql.Query("SELECT * FROM armory_storage WHERE classID = '".. className .."' and itemID = '".. itemID .."'")
    if ( not result ) then
        sql.Query("INSERT INTO armory_storage (classID, Item_ID) VALUES ('".. className .."','".. itemID .."')")
        ErrorNoHalt("Entry for " .. className .. " and " .. itemID .. "added\n")
    else 
        ErrorNoHalt("Entry for " .. className .. " and " .. itemID .. "already exists\n")
    end
end

function readClassEntry(className)
    print(className)
    local result = sql.Query("Select * from armory_storage WHERE classID = '".. className .."'")
    return result
end

function deleteClassEntry(className,itemID)
    local itemResult = ReadItem(itemID)
    if(not itemResult) then
        ErrorNoHalt("No item found with ID: " .. itemID .. "\n")
        return
    end
    local result = readClassEntry(className,ItemID)
    if ( not result ) then
        sql.Query("DELETE FROM armory_storage WHERE classID = '".. className .."' and itemID = '".. itemID .."')")
        ErrorNoHalt("Entry for " .. className .. " and " .. itemID .. "removed\n")
    else 
        ErrorNoHalt("No item found with ID: " .. itemID .. "\n")
    end
end


--  sql.Query("CREATE TABLE IF NOT EXISTS storage (id TEXT, Item_ID TEXT, AMOUNT INTEGER, StorageType TEXT, PRIMARY KEY (id, Item_ID))")
--  inventory = {["*StorageType*"] = {["*id*"] = {"*Item_ID*","*Amount*"}}, ...}

function AddToInventory(inventory)
    for storageType, storageData in pairs(inventory) do
        for id, items in pairs(storageData) do
            for itemID, amount in pairs(items) do
                local result = sql.Query("SELECT * FROM storage WHERE id = '" .. id .. "' AND Item_ID = '" .. itemID .. "' AND StorageType = '" .. storageType .. "'")
                if(result) then
                    sql.Query("UPDATE storage SET AMOUNT = AMOUNT + " .. amount .. " WHERE id = '" .. id .. "' AND Item_ID = '" .. itemID .. "' AND StorageType = '" .. storageType .. "'")
                else
                    sql.Query("INSERT INTO storage (id, Item_ID, AMOUNT, StorageType) VALUES ('" .. id .. "', '" .. itemID .. "', " .. amount .. ", '" .. storageType .. "')")
                end
            end
        end
    end
end