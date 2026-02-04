

local ContainerIndex = 0




ARMORY = ARMORY or nil

function CreateArmory()
    ARMORY = vgui.Create("DPanel")
    ARMORY:SetSize(0,1 * BoxSize + BoxSize/10 + BoxSize /2 )
    ARMORY:SetPos(0,0)
    ARMORY:SetName("InventoryPassivePanel")
    ARMORY:DockMargin(BoxSize/40,BoxSize/40,BoxSize/40,BoxSize/40)
    ARMORY:DockPadding(BoxSize/40,BoxSize/40,BoxSize/40,BoxSize/40)
    ARMORY:SetBackgroundColor(Color(0,0,0,0))
    ARMORY:Add(createContainerV2(11,4,0,0,"Bereitgestellte Ausrüstung",{["allow"] = "none", ["infinite"] = "true",["isEquipment"] = false}))
    ARMORY:Add(createContainerV2(4,4,BoxSize * 11+BoxSize/2,0,"Zurücklegen",{["isEquipment"] = false,["isBin"] = true}))
    return ARMORY
end


function AddToArmory(item)
    local itemInfo = InventoryItems[item.Item_ID]
    if itemInfo then
        local Size = tonumber(itemInfo.Size )
        local ItemPanel = CreateDropItem(
            item.Item_ID,
            itemInfo
        )
        local x,y = getSizeXY(Size)
        for i = 0, #ARMORY:GetChild(0):GetChild(0):GetChildren()-1 do
            local inventoryhover = ARMORY:GetChild(0):GetChild(0):GetChild(i)
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
    "invWeaponBox",
    function()
        if(INVENTORY.GUI.ALL and INVENTORY.GUI.ALL:IsValid()) then
            -- INVENTORY.GUI.MAIN:Remove()
            if(INVENTORY.GUI.MODEL and INVENTORY.GUI.MODEL:IsValid()) then
                INVENTORY.GUI.MODEL:SetModel(LocalPlayer():GetModel())
            else 
                CreateInventory()
            end
            INVENTORY.GUI.ALL:SetVisible(not INVENTORY.GUI.ALL:IsVisible())
            CreateWeaponChest()
            RequestArmorySync() 
            return
        else
            CreateInventory()
            CreateWeaponChest()
            RequestArmorySync() 
        end
        
    end
)
concommand.Add(
    "invWeaponBoxReload",function()
        reload()
    end
)


