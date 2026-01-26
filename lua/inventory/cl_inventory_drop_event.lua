function isDropable(toPut, i, x, y, PickedUpItem)
    if x == 1 and y == 1 and #toPut:GetChildren() == 0 and toPut:GetParent():GetChild(i):GetWide() > 0 then
        return true
    elseif x == 2 and y == 1 and #toPut:GetChildren() == 0 and ((i + 1) % 10) ~= 0 and (#toPut:GetParent():GetChild(i + 1):GetChildren() == 0 or toPut:GetParent():GetChild(i + 1):GetChild(0) == PickedUpItem) and (toPut:GetParent():GetChild(i + 1):GetWide() > 0) and toPut:GetParent():GetChild(i):GetWide() > 0 then
        return true
    elseif x == 1 and y == 2 and #toPut:GetChildren() == 0 and (i + 1) <= INVENTORY.SETTINGS.TABLE.WIDTH * INVENTORY.SETTINGS.TABLE.HEIGHT - INVENTORY.SETTINGS.TABLE.WIDTH and (#toPut:GetParent():GetChild(i + INVENTORY.SETTINGS.TABLE.WIDTH):GetChildren() == 0 or toPut:GetParent():GetChild(i + INVENTORY.SETTINGS.TABLE.WIDTH):GetChild(0) == PickedUpItem) and (toPut:GetParent():GetChild(i + INVENTORY.SETTINGS.TABLE.WIDTH):GetWide() > 0) and toPut:GetParent():GetChild(i):GetWide() > 0 then
        return true
    elseif x == 2 and y == 2 then
        if #toPut:GetChildren() == 0 and ((i + 1) % 10) ~= 0 and (i + 1) <= INVENTORY.SETTINGS.TABLE.WIDTH * INVENTORY.SETTINGS.TABLE.HEIGHT - INVENTORY.SETTINGS.TABLE.WIDTH 
        and (#toPut:GetParent():GetChild(i + 1):GetChildren() == 0 or toPut:GetParent():GetChild(i + 1):GetChild(0) == PickedUpItem) 
        and (#toPut:GetParent():GetChild(i + INVENTORY.SETTINGS.TABLE.WIDTH):GetChildren() == 0 or toPut:GetParent():GetChild(i + INVENTORY.SETTINGS.TABLE.WIDTH):GetChild(0) == PickedUpItem) 
        and (#toPut:GetParent():GetChild(i + INVENTORY.SETTINGS.TABLE.WIDTH + 1):GetChildren() == 0 or toPut:GetParent():GetChild(i + INVENTORY.SETTINGS.TABLE.WIDTH + 1):GetChild(0) == PickedUpItem) 
        and (toPut:GetParent():GetChild(i + 1):GetWide() > 0 or (toPut:GetParent():GetChild(i + 1 - INVENTORY.SETTINGS.TABLE.WIDTH):GetChildren() != 0 and toPut:GetParent():GetChild(i + 1 - INVENTORY.SETTINGS.TABLE.WIDTH):GetChild(0) == PickedUpItem))
        and (toPut:GetParent():GetChild(i + INVENTORY.SETTINGS.TABLE.WIDTH):GetWide() > 0 or (toPut:GetParent():GetChild(i + INVENTORY.SETTINGS.TABLE.WIDTH-1):GetChildren() != 0 and toPut:GetParent():GetChild(i + INVENTORY.SETTINGS.TABLE.WIDTH-1):GetChild(0) == PickedUpItem))
        and toPut:GetParent():GetChild(i):GetWide() > 0 then 
            return true 
        end
    end

    return false
end



function DropEvent1x2(InventoryHover, PickedUpItemTBL, wasDropped, index, cursorx, cursory)
    DropEvent(InventoryHover, PickedUpItemTBL, wasDropped, index, cursorx, cursory, 1, 2)
end

function DropEvent2x1(InventoryHover, PickedUpItemTBL, wasDropped, index, cursorx, cursory)
    DropEvent(InventoryHover, PickedUpItemTBL, wasDropped, index, cursorx, cursory, 2, 1)
end

function DropEvent2x2(InventoryHover, PickedUpItemTBL, wasDropped, index, cursorx, cursory)
    DropEvent(InventoryHover, PickedUpItemTBL, wasDropped, index, cursorx, cursory, 2, 2)
end

function DropEvent1x1(InventoryHover, PickedUpItemTBL, wasDropped, index, cursorx, cursory)
    DropEvent(InventoryHover, PickedUpItemTBL, wasDropped, index, cursorx, cursory, 1, 1)
end

function DropEvent(InventoryHover,PickedUpItemTBL,wasDropped,index,cursorx,cursory,x,y)
    PickedUpItem = PickedUpItemTBL[1]
    if #InventoryHover:GetChildren() == 0 and wasDropped then
        changeSizes(InventoryHover, x, y, PickedUpItem)
        InventoryHover:Add(PickedUpItem)
        if PickedUpItem:GetCookie("isEquipped") == "false" then
            local activeItems = {
                { Item_ID = PickedUpItem:GetName(), Active = true },
            }
            net.Start("RequestInventoryEquip")
            net.WriteTable(activeItems)
            net.SendToServer()
            print(PickedUpItem:GetName() .. " was dropped in Player by Inventory", PickedUpItem:GetText())
            PickedUpItem:SetCookie("isEquipped","true")
        end
    end
end

function DropEventInventory(InventoryHover, PickedUpItemTBL, wasDropped, index, cursorx, cursory)
    local PickedUpItem = PickedUpItemTBL[1]
    local xBox, yBox = PickedUpItem:GetSize()
    BoxSize = math.floor(INVENTORY.SETTINGS.BOXSIZE)
    xBox, yBox = xBox / BoxSize, yBox / BoxSize
    xBox, yBox = math.floor(xBox), math.floor(yBox)
    local i = 0
    for k, v in pairs(InventoryHover:GetParent():GetChildren()) do
        if v == InventoryHover then break end
        i = i + 1
    end

    if wasDropped and isDropable(InventoryHover, i, xBox, yBox, PickedUpItem) then
        changeSizes(InventoryHover, xBox, yBox, PickedUpItem)
        if PickedUpItem:GetCookie("isEquipped") == "true" then
            PickedUpItem:SetCookie("isEquipped","false")
            print(PickedUpItem:GetName() .. " was dropped in Inventory from Player")
            local activeItems = {
                { Item_ID = PickedUpItem:GetName(), Active = false },
            }
            net.Start("RequestInventoryEquip")
            net.WriteTable(activeItems)
            net.SendToServer()
            InventoryHover:Add(PickedUpItem)
        else
            print(PickedUpItem:GetName() .. " was moved in Inventory")
        end
        InventoryHover:Add(PickedUpItem)
        print(InventoryHover:GetName() .. " was dropped in Inventory by Inventory", PickedUpItem:GetText())
    end
end