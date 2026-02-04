

local ContainerIndex = 0




AddCSLuaFile("cl_inventory_gui.lua")

WARDROBE = WARDROBE or nil

function CreateWardrobe()
    WARDROBE = vgui.Create("DPanel", inventoryContainer)
    WARDROBE:SetSize(0,5 * BoxSize + BoxSize/10 + BoxSize /2 )
    WARDROBE:SetPos(0,0)
    WARDROBE:SetName("InventoryPassivePanel")
    WARDROBE:DockMargin(2,2,2,2)
    WARDROBE:DockPadding(2,2,2,2)
    WARDROBE:SetBackgroundColor(Color(0,0,0,0))
    for i = 0, 3 do
        for j = 0, 2 do
            WARDROBE:Add(createContainerV2(1,1,BoxSize*i*4,BoxSize*j*3/2,"",{["allow"] = "none", ["infinite"] = "true",["isEquipment"] = false}))
            local label = vgui.Create("DLabel")
            label:SetText("Toggle "..(i + j*4 +1) .. " on")
            SetLabelSize(label, BoxSize/2)
            label:SetPos(BoxSize*i*4+BoxSize+BoxSize/10,BoxSize*j*3/2+BoxSize/1.5)
            WARDROBE:Add(label)
        end
    end
    return WARDROBE
end


function AddToWardrobe(item)
    local itemInfo = InventoryItems[item.Item_ID]
    if itemInfo then
        local Size = tonumber(itemInfo.Size )
        local ItemPanel = CreateDropItem(
            item.Item_ID,
            itemInfo
        )
        local x,y = getSizeXY(Size)
        for i = 0, #WARDROBE:GetChild(0):GetChild(0):GetChildren()-1 do
            local inventoryhover = WARDROBE:GetChild(0):GetChild(0):GetChild(i)
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

concommand.Add(
    "invWardrobe",
    function()
        if(INVENTORY.GUI.ALL and INVENTORY.GUI.ALL:IsValid()) then
            -- INVENTORY.GUI.MAIN:Remove()
            if(INVENTORY.GUI.MODEL and INVENTORY.GUI.MODEL:IsValid()) then
                INVENTORY.GUI.MODEL:SetModel(LocalPlayer():GetModel())
            else 
                CreateInventory()
            end
            INVENTORY.GUI.ALL:SetVisible(not INVENTORY.GUI.ALL:IsVisible())
            CreateWardrobe()
            RequestWeaponChestSync() 
            return
        else
            CreateInventory()
            CreateWardrobe()
            RequestWeaponChestSync() 
        end
        
    end
)
concommand.Add(
    "invWeaponBoxReload",function()
        reload()
    end
)


