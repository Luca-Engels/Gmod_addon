

local ContainerIndex = 0




AddCSLuaFile("cl_inventory_gui.lua")

PRIVATE_STORAGE = PRIVATE_STORAGE or nil

function CreatePrivateStorage()
    PRIVATE_STORAGE = vgui.Create("DPanel", inventoryContainer)
    PRIVATE_STORAGE:SetSize(0,5 * BoxSize + 8 + BoxSize /2 )
    PRIVATE_STORAGE:SetPos(0,0)
    PRIVATE_STORAGE:SetName("InventoryPassivePanel")
    PRIVATE_STORAGE:DockMargin(2,2,2,2)
    PRIVATE_STORAGE:DockPadding(2,2,2,2)
    PRIVATE_STORAGE:SetBackgroundColor(Color(0,0,0,0))
    local ScrollPane = vgui.Create("DScrollPanel", PRIVATE_STORAGE)
    ScrollPane:AddItem(createContainerV2(16,8,BoxSize/2,0,"Privat Lager"))
    ScrollPane:Dock(FILL)
    return PRIVATE_STORAGE
end


function AddToPrivateStorage(item)
    local itemInfo = InventoryItems[item.Item_ID]
    if itemInfo then
        local Size = tonumber(itemInfo.Size )
        local ItemPanel = CreateDropItem(
            item.Item_ID,
            itemInfo
        )
        local x,y = getSizeXY(Size)
        for i = 0, #PRIVATE_STORAGE:GetChild(0):GetChild(0):GetChildren()-1 do
            local inventoryhover = PRIVATE_STORAGE:GetChild(0):GetChild(0):GetChild(i)
            if isDropable(inventoryhover, i, x, y, ItemPanel) then
                inventoryhover:Add(ItemPanel)
                changeSizes(inventoryhover, x, y, ItemPanel)
                return
            end
        end
        MsgC(Color(127,0,0),"Couldn't add Item to Inventory:\n")
        ItemPanel:Remove()
    end
end