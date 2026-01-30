function isDropable(toPut, i, x, y, PickedUpItem)
    local width = toPut:GetCookie("SizeX")
    local height = toPut:GetCookie("SizeY")
    if x == 1 and y == 1 and #toPut:GetChildren() == 0 and toPut:GetParent():GetChild(i):GetWide() > 0 then
        return true
    elseif x == 2 and y == 1 then
        if #toPut:GetChildren() == 0 and ((i + 1) % width) ~= 0 
        and (#toPut:GetParent():GetChild(i + 1):GetChildren() == 0 or toPut:GetParent():GetChild(i + 1):GetChild(0) == PickedUpItem) 
        and (toPut:GetParent():GetChild(i + 1):GetWide() > 0) and toPut:GetParent():GetChild(i):GetWide() > 0 then
            return true
        end
    elseif x == 3 and y == 1 then
        if #toPut:GetChildren() == 0 and ((i + 1) % width) ~= 0 
        and #toPut:GetChildren() == 0 and ((i + 2) % width) ~= 0
        and (#toPut:GetParent():GetChild(i + 1):GetChildren() == 0 or toPut:GetParent():GetChild(i + 1):GetChild(0) == PickedUpItem) 
        and (#toPut:GetParent():GetChild(i + 2):GetChildren() == 0 or toPut:GetParent():GetChild(i + 2):GetChild(0) == PickedUpItem) 
        and (toPut:GetParent():GetChild(i + 1):GetWide() > 0) and toPut:GetParent():GetChild(i):GetWide() > 0 
        and (toPut:GetParent():GetChild(i + 2):GetWide() > 0) and toPut:GetParent():GetChild(i):GetWide() > 0 then
            return true
        end
    elseif x == 1 and y == 2 then 
        if #toPut:GetChildren() == 0 and (i + 1) <= width * height - width 
        and (#toPut:GetParent():GetChild(i + width):GetChildren() == 0 or toPut:GetParent():GetChild(i + width):GetChild(0) == PickedUpItem) 
        and (toPut:GetParent():GetChild(i + width):GetWide() > 0) 
        and toPut:GetParent():GetChild(i):GetWide() > 0 then
            return true        end
    elseif x == 2 and y == 2 then
        if #toPut:GetChildren() == 0 and ((i + 1) % width) ~= 0 and (i + 1) <= width * height - width 
        and (#toPut:GetParent():GetChild(i + 1):GetChildren() == 0 or toPut:GetParent():GetChild(i + 1):GetChild(0) == PickedUpItem) 
        and (#toPut:GetParent():GetChild(i + width):GetChildren() == 0 or toPut:GetParent():GetChild(i + width):GetChild(0) == PickedUpItem) 
        and (#toPut:GetParent():GetChild(i + width + 1):GetChildren() == 0 or toPut:GetParent():GetChild(i + width + 1):GetChild(0) == PickedUpItem) 
        and (toPut:GetParent():GetChild(i + 1):GetWide() > 0 or (toPut:GetParent():GetChild(i + 1 - width):GetChildren() != 0 and toPut:GetParent():GetChild(i + 1 - width):GetChild(0) == PickedUpItem))
        and (toPut:GetParent():GetChild(i + width):GetWide() > 0 or (toPut:GetParent():GetChild(i + width-1):GetChildren() != 0 and toPut:GetParent():GetChild(i + width-1):GetChild(0) == PickedUpItem))
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

function DropEvent3x1(InventoryHover, PickedUpItemTBL, wasDropped, index, cursorx, cursory)
    DropEvent(InventoryHover, PickedUpItemTBL, wasDropped, index, cursorx, cursory, 3, 1)
end

function DropEvent2x2(InventoryHover, PickedUpItemTBL, wasDropped, index, cursorx, cursory)
    DropEvent(InventoryHover, PickedUpItemTBL, wasDropped, index, cursorx, cursory, 2, 2)
end

function DropEvent1x1(InventoryHover, PickedUpItemTBL, wasDropped, index, cursorx, cursory)
    print("DROP EVENT 1x1")
    DropEvent(InventoryHover, PickedUpItemTBL, wasDropped, index, cursorx, cursory, 1, 1)
    print("DROP EVENT 1x1")
end

function DropEvent(InventoryHover,PickedUpItemTBL,wasDropped,index,cursorx,cursory,x,y)
    PickedUpItem = PickedUpItemTBL[1]
    if #InventoryHover:GetChildren() == 0 and wasDropped then
        for i=0 , #INVENTORY.GUI.PASSIVE:GetChild(0):GetChildren() -1 do
            if(INVENTORY.GUI.PASSIVE:GetChild(0):GetChild(i):HasChildren())then
                print(INVENTORY.GUI.PASSIVE:GetChild(0):GetChild(i):GetChild(0):GetCookie("isEquipped"))
            end
        end
        changeSizes(InventoryHover, x, y, PickedUpItem)
        InventoryHover:Add(PickedUpItem)
        if PickedUpItem:GetCookie("isEquipped") == "false" then
            local activeItems = {
                { Item_ID = PickedUpItem:GetName(), Active = true },
            }
            net.Start("RequestInventoryEquip")
            net.WriteTable(activeItems)
            net.SendToServer()
            if x == 2 and y == 2 then
                print("HERELKHROIUJHEBRIB")
                for i = 1, #INVENTORY.GUI.ACTIVE.BOTTOM:GetChildren()-1 do
                    
                    INVENTORY.GUI.ACTIVE.BOTTOM:GetChild(i):SetVisible(true)
                end
            end
            print(PickedUpItem:GetName() .. " was dropped in Player by Inventory", PickedUpItem:GetText())
            print("_______________ SET isEquipped true for ", PickedUpItem:GetName())
            print("picked UP",PickedUpItem:GetName())
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

    if wasDropped then
        if isDropable(InventoryHover, i, xBox, yBox, PickedUpItem) then
            changeSizes(InventoryHover, xBox, yBox, PickedUpItem)
            if PickedUpItem:GetCookie("isEquipped") == "true" then
                print("UNEQUIPEN____________")
                PickedUpItem:SetCookie("isEquipped","false")
                print(PickedUpItem:GetName() .. " was dropped in Inventory from Player")
                local activeItems = {
                    { Item_ID = PickedUpItem:GetName(), Active = false },
                }
                net.Start("RequestInventoryEquip")
                net.WriteTable(activeItems)
                net.SendToServer()
                
                if xBox == 2 and yBox == 2 then
                    print("HERELKHROIUJHEBRIB")
                    for i = 1, #INVENTORY.GUI.ACTIVE.BOTTOM:GetChildren()-1 do
                        
                        INVENTORY.GUI.ACTIVE.BOTTOM:GetChild(i):SetVisible(false)
                    end
                end
                InventoryHover:Add(PickedUpItem)
            else
                print(PickedUpItem:GetName() .. " was moved in Inventory")
            end
            InventoryHover:Add(PickedUpItem)
            print(InventoryHover:GetName() .. " was dropped in Inventory by Inventory", PickedUpItem:GetText())
        end 
    end
end

function DropEventEquipment(InventoryHover, PickedUpItemTBL, wasDropped, index, cursorx, cursory)
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

    if wasDropped then
        if isDropable(InventoryHover, i, xBox, yBox, PickedUpItem) then
            changeSizes(InventoryHover, xBox, yBox, PickedUpItem)
            if PickedUpItem:GetCookie("isEquipped") == "false" then
                print("EQUIPPPPPPPPPPEDDDDDDDDD________________________")
                PickedUpItem:SetCookie("isEquipped","true")
                print(PickedUpItem:GetName() .. " was dropped in Inventory from Player")
                local activeItems = {
                    { Item_ID = PickedUpItem:GetName(), Active = true },
                }
                net.Start("RequestInventoryEquip")
                net.WriteTable(activeItems)
                net.SendToServer()
                
                if xBox == 2 and yBox == 2 then
                    print("HERELKHROIUJHEBRIB")
                    for i = 1, #INVENTORY.GUI.ACTIVE.BOTTOM:GetChildren()-1 do
                        
                        INVENTORY.GUI.ACTIVE.BOTTOM:GetChild(i):SetVisible(false)
                    end
                end
                InventoryHover:Add(PickedUpItem)
            else
                print(PickedUpItem:GetName() .. " was moved in Inventory")
            end
            InventoryHover:Add(PickedUpItem)
            print(InventoryHover:GetName() .. " was dropped in Inventory by Inventory", PickedUpItem:GetText())
        end 
    end
end