function isDropable(toPut, i, sizeX, sizeY, PickedUpItem)
    local width = toPut:GetCookie("SizeX")
    local height = toPut:GetCookie("SizeY")
    local parent = toPut:GetParent()
    local totalCells = width * height

    for dy = 0, sizeY - 1 do
        for dx = 0, sizeX - 1 do
            local cellIndex = i + dx + dy * width

            -- Check bounds
            if cellIndex >= totalCells then
                return false
            end

            -- Prevent row wrapping
            if dx > 0 and ((i + dx) % width) == 0 then
                return false
            end

            local cell = parent:GetChild(cellIndex)
            if not cell or cell:GetWide() <= 0 then
                return false
            end

            local children = cell:GetChildren()
            if #children > 0 and children[1] ~= PickedUpItem then
                return false
            end
        end
    end

    return true
end

function DropEvent(InventoryHover, PickedUpItem,wasDropped,index,cursorx,cursory,doEquip)
    local xBox, yBox = PickedUpItem:GetSize()

    xBox, yBox = xBox / BoxSize, yBox / BoxSize
    xBox, yBox = math.floor(xBox), math.floor(yBox)
    local i = 0
    for k, v in pairs(InventoryHover:GetParent():GetChildren()) do
        if v == InventoryHover then break end
        i = i + 1
    end

    if wasDropped then
        allow = InventoryHover:GetCookie("AllowType")
        Type = PickedUpItem:GetCookie("Type")
        if not allow or allow == Type then
            if isDropable(InventoryHover, i, xBox, yBox, PickedUpItem) then
                changeSizes(InventoryHover, xBox, yBox, PickedUpItem)
                if PickedUpItem:GetCookie("isEquipped") == tostring(doEquip) then
                    MsgC(Color(0,255,0),PickedUpItem:GetName() .. " was equipped / unequipped to / from your Inventory!\n")
                    PickedUpItem:SetCookie("isEquipped",tostring(not doEquip))
                    local activeItems = {
                        { Item_ID = PickedUpItem:GetName(), Active = not doEquip },
                    }
                    net.Start("RequestInventoryEquip")
                    net.WriteTable(activeItems)
                    net.SendToServer()
                else
                    print(PickedUpItem:GetName() .. " was moved in Inventory")
                end
                if PickedUpItem:GetParent():GetCookie("Infinite") == "true" then
                    -- copy the item to the PickedUpItem:GerParent and changeSize
                    local itemInfo = InventoryItems[PickedUpItem:GetName()]
                    print("Creating copy of " .. PickedUpItem:GetName() .. " as it was taken from an infinite container.")
                    local itemCopy = CreateDropItem(PickedUpItem:GetName(),itemInfo)
                    local x, y = getSizeXY(itemInfo.Size)
                    changeSizes(PickedUpItem:GetParent(), x,y, PickedUpItem)
                    PickedUpItem:GetParent():Add(itemCopy)
                    print("Create NEW")
                end
                InventoryHover:Add(PickedUpItem)
                if( InventoryHover:GetCookie("isBin") == "true") then
                    print("xBox: " .. tostring(xBox) .. " yBox: " .. tostring(yBox))
                    changeSizes(nil,xBox, yBox,PickedUpItem)
                    PickedUpItem:Remove()
                    print("Item was removed as it was dropped in a bin.")
                end
                print(InventoryHover:GetName() .. " was dropped in Inventory by Inventory", PickedUpItem:GetText())
            end 
        else
            MsgC(Color(120,0,0), Type .. " is not allowed in Inventory reserved for " .. allow .. "!\n")
        end
    end
end

function DropEventInventory(InventoryHover, PickedUpItemTBL, wasDropped, index, cursorx, cursory)
    DropEvent(InventoryHover,PickedUpItemTBL[1],wasDropped,index,cursorx,cursory,true)
end

function DropEventEquipment(InventoryHover, PickedUpItemTBL, wasDropped, index, cursorx, cursory)
    DropEvent(InventoryHover,PickedUpItemTBL[1],wasDropped,index,cursorx,cursory,false)
end