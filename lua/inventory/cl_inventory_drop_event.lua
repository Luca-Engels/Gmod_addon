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
                MsgC(Color(0,255,0),PickedUpItem:GetName() .. " was uequipped from your Inventory!\n")
                PickedUpItem:SetCookie("isEquipped","false")
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
        allow = InventoryHover:GetCookie("AllowType")
        Type = PickedUpItem:GetCookie("Type")
        MsgC(Color(0,0,255),Type .. "\n")
        MsgC(Color(27,129,36),allow )
        Msg("\n")
        if not allow or allow == Type then
            if isDropable(InventoryHover, i, xBox, yBox, PickedUpItem) then
                changeSizes(InventoryHover, xBox, yBox, PickedUpItem)
                if PickedUpItem:GetCookie("isEquipped") == "false" then
                    MsgC(Color(0,255,0),PickedUpItem:GetName() .. " was equipped to your Inventory!\n")
                    PickedUpItem:SetCookie("isEquipped","true")
                    local activeItems = {
                        { Item_ID = PickedUpItem:GetName(), Active = true },
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
        else
            MsgC(Color(120,0,0), Type .. " is not allowed in Inventory reserved for " .. allow .. "!\n")
        end
    end
end