if SERVER then
    util.AddNetworkString("InventorySync")
    util.AddNetworkString("RequestInventorySync")
    util.AddNetworkString("RequestInventoryEquip")
    util.AddNetworkString("requestLoadInventoryToLocal")

    function SyncPlayerInventory(player)
        print("Syncing inventory for player: " .. player:Nick())
        local inventory = readInventory(player)
        for k, v in pairs(inventory) do
            print("Item ID: " .. v.Item_ID .. " | Quantity: " .. v.Amount .. "| Active: " .. (v.Active or "false"))
        end
        net.Start("InventorySync")
        net.WriteTable(inventory)
        net.Send(player)
    end
    net.Receive("RequestInventorySync", function(len, ply)
        SyncPlayerInventory(ply)
    end)

    -- hook.Add("PlayerInitialSpawn", "LoadInventory", function(ply)
    --     timer.Simple(5, function()
    --         inventories[ply] = readInventory(ply)
    --     end)
    -- end)
    -- net.Receive("requestLoadInventoryToLocal", function(len, ply)
    --         inventories[ply] = readInventory(ply)
    -- end)

    -- hook.Add("PlayerDisconnected", "SaveInventory", function(ply)
    --     writeInventory(ply, inventories[ply])
    --     inventories[ply] = nil
    -- end)



    net.Receive("RequestInventoryEquip", function(len, ply)
        local activeItems = net.ReadTable()
        print(activeItems)
        PrintTable(activeItems)
        local inventory = readInventory(ply)
        
        print(inventory)
        if not inventory then return end
        ply:RemoveAllAmmo()
        for k, v in pairs(activeItems) do
            if v.Active then
                print("Checking item: " .. v.Item_ID .. " for player: " .. ply:Nick())

                for k2, v2 in pairs(inventory) do
                    if v.Item_ID == v2.Item_ID then
                        print("Equipping item: " .. v2.Item_ID .. " for player: " .. ply:Nick())
                        PrintTable(v2)
                        ply:Give(v2.Item_ID, true)
                        ply:GiveAmmo(tonumber(InventoryItems[v2.Item_ID].Ammo) or 0, InventoryItems[v2.Item_ID].Name, true)
                        print("Giving item " .. v2.Item_ID .. " to " .. ply:Nick() .. " and " .. InventoryItems[v2.Item_ID].Ammo .. " Bullets worth of " .. InventoryItems[v2.Item_ID].Name .. " Ammonition")
                    else
                        print("Not Valid")
                    end
                end
            else
                print("Stripping item: " .. v.Item_ID .. " for player: " .. ply:Nick())
                ply:StripWeapon(v.Item_ID)
            end
        end
        print("Updated active items for player: " .. ply:Nick())
    end)

    hook.Add("PlayerSpawn","PlayerSpawnSetInventory",function(ply)
        timer.Simple(1, function()
            ply:RemoveAllItems()
            ply:RemoveAllAmmo()
            SyncPlayerInventory(ply)
        end)
    end)
end
if CLIENT then


    local inventory = {}

    net.Receive("InventorySync", function()
        if IsValid(INVENTORY.GUI.MAIN) then
            INVENTORY.GUI.MAIN:Remove()
        end
        CreateInventory()

        inventory = net.ReadTable()
        print("Received inventory sync :")
        INVENTORY.ITEMS = inventory
        PrintTable(inventory)
        PrintTable(INVENTORY.ITEMS)
        print("Filling Inventory")
        FillInventory(INVENTORY.ITEMS)
    end)

    function RequestInventorySync()
        net.Start("RequestInventorySync")
        net.SendToServer()
    end

    function RequestInventoryEquip(activeItems)
        local activeItems = {
            -- Example active items
            { Item_ID = "weapon_ar2", Active = true },
            { Item_ID = "weapon_smg1", Active = true },
        }
        net.Start("RequestInventoryEquip")
        net.WriteTable(activeItems)
        net.SendToServer()
    end

end



concommand.Add(
    "loadIt",
        function()
            net.Start("requestLoadInventoryToLocal")
            net.SendToServer()
    end
)

concommand.Add(
    "strip",
        function()
            RequestInventoryEquip()
    end
)


