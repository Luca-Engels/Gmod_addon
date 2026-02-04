if SERVER then
    include("inventory/sv_inventory_database.lua")
    util.AddNetworkString("InventoryAdd")
    util.AddNetworkString("InventoryClear")
    util.AddNetworkString("InventoryCreate")
    util.AddNetworkString("InventoryModelChange")
    util.AddNetworkString("RequestInventorySync")
    util.AddNetworkString("RequestInventoryEquip")
    util.AddNetworkString("requestLoadInventoryToLocal")
    util.AddNetworkString("ArmoryAdd")
    util.AddNetworkString("RequestArmorySync")

    function SyncPlayerInventory(ply)
        print("Syncing inventory for player: " .. ply:Nick())
        local inventory = readInventory(ply)
        timer.Simple(0, function()
            for k, v in pairs(inventory) do
                net.Start("InventoryAdd")
                net.WriteTable(v)
                net.Send(ply)
            end
        end)
    end
    function SyncPlayerArmory(ply)
        print("Syncing Armory for player: " .. ply:Nick())
        local playerClass = readPlayer(ply)[1]["Faction"]
        local equipment = readClassEntry(playerClass)
        timer.Simple(0, function()
            for k, v in pairs(equipment) do
                PrintTable(v)
                net.Start("ArmoryAdd")
                net.WriteTable(v)
                net.Send(ply)
            end
        end)
    end
    net.Receive("RequestInventorySync", function(len, ply)
        SyncPlayerInventory(ply)
    end)
    net.Receive("RequestArmorySync", function(len, ply)
        SyncPlayerArmory(ply)
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
        local player = readPlayer(ply)
        local classInventory = readClassEntry(player[1]["Faction"])
        local inventory = readInventory(ply)
        
        if not inventory then return end
        for k, v in pairs(activeItems) do
            if v.Active then
                for k2, v2 in pairs(classInventory) do
                    print("Checking item: " .. v2.Item_ID .. " against: " .. v.Item_ID)
                    if v.Item_ID == v2.Item_ID then
                        print("Equipping item: " .. v2.Item_ID .. " for player: " .. ply:Nick())
                        if(InventoryItems[v2.Item_ID].Ammo)then
                            ply:GiveAmmo(InventoryItems[v2.Item_ID].Ammo,v2.Item_ID,true)
                        elseif(InventoryItems[v2.Item_ID].Model_Route) then
                            ply:SetModel(InventoryItems[v2.Item_ID].Model_Route) 
                            net.Start("InventoryModelChange")
                            net.WriteString(InventoryItems[v2.Item_ID].Model_Route)
                            net.Send(ply)
                        else
                            ply:Give(v2.Item_ID, true)
                        end
                    end
                end
            else
                print("Stripping item: " .. v.Item_ID .. " for player: " .. ply:Nick())
                if(InventoryItems[v.Item_ID].Ammo)then
                    ply:RemoveAmmo(InventoryItems[v.Item_ID].Ammo,v.Item_ID)
                elseif(InventoryItems[v.Item_ID].Model_Route) then
                    ply:SetModel("models/player/alyx.mdl") 
                    net.Start("InventoryModelChange")
                    net.WriteString("models/player/alyx.mdl")
                    net.Send(ply)
                else
                    ply:StripWeapon(v.Item_ID)
                end
            end
        end
    end)

    hook.Add("PlayerSpawn","PlayerSpawnSetInventory",function(ply,transition)
        timer.Simple(0, function()
            ply:RemoveAllItems()
            ply:RemoveAllAmmo()
            net.Start("InventoryClear")
            net.Send(ply)
            local inventory = readInventory(ply)
            timer.Simple(1, function()
                for k, v in pairs(inventory) do
                    net.Start("InventoryAdd")
                    net.WriteTable(v)
                    net.Send(ply)
                end
            end)
        end)
    end)
    
    hook.Add("PlayerInitialSpawn","Startup",function(ply,transition)
        net.Start("InventoryCreate")
        net.Send(ply)
    end)
end
if CLIENT then
    
    
    net.Receive("InventoryAdd", function()
        local inventory = net.ReadTable()
        table.insert(INVENTORY.ITEMS,inventory)
        AddToInventory(inventory)
    end)

    net.Receive("ArmoryAdd", function()
        local item = net.ReadTable()
        AddToArmory(item)
    end)
    net.Receive("InventoryModelChange", function()
        model = net.ReadString()
        INVENTORY.GUI.MODEL:SetModel(model)
        -- INVENTORY.GUI.ACTIVE.MODEL:StartScene(LocalPlayer())
    end)
    
    net.Receive("InventoryClear", function()
        INVENTORY.ITEMS = {}
        ClearInventory()
    end)
    net.Receive("InventoryCreate", function()
        INVENTORY.ITEMS = {}
        CreateInventory()
    end)

    function RequestInventorySync()
        net.Start("RequestInventorySync")
        net.SendToServer()
    end
    
    function RequestArmorySync()
        net.Start("RequestArmorySync")
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

    hook.Add("EntityModelChanged", "ModelChangeHook", function(ent, oldModel, newModel)
    if ent == LocalPlayer() then
        print("Local player model changed:", oldModel, "→", newModel)
    end
end)

end



concommand.Add(
    "strip",
        function()
            CreateInventory()
            RequestInventorySync() 
    end
)


