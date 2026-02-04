

local ContainerIndex = 0




AddCSLuaFile("cl_inventory_gui.lua")

FRACTION_STORAGE = FRACTION_STORAGE or nil

function CreateFractionStorage()
    FRACTION_STORAGE = vgui.Create("DPanel", inventoryContainer)
    FRACTION_STORAGE:SetSize(0,5 * BoxSize + BoxSize/10 + BoxSize /2 )
    FRACTION_STORAGE:SetPos(0,0)
    FRACTION_STORAGE:SetName("InventoryPassivePanel")
    FRACTION_STORAGE:SetBackgroundColor(Color(0,0,0,0))
    local ScrollPane = vgui.Create("DScrollPanel", FRACTION_STORAGE)
    ScrollPane:AddItem(createContainerV2(15,15,0,0,"Fraktions Lager"))
    ScrollPane:Dock(FILL)
    return FRACTION_STORAGE
end


function AddToFractionStorage(item)
    local itemInfo = InventoryItems[item.Item_ID]
    if itemInfo then
        local Size = tonumber(itemInfo.Size )
        local ItemPanel = CreateDropItem(
            item.Item_ID,
            itemInfo
        )
        local x,y = getSizeXY(Size)
        for i = 0, #FRACTION_STORAGE:GetChild(0):GetChild(0):GetChildren()-1 do
            local inventoryhover = FRACTION_STORAGE:GetChild(0):GetChild(0):GetChild(i)
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