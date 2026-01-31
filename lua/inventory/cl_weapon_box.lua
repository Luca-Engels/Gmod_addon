

local ContainerIndex = 0




AddCSLuaFile("cl_inventory_gui.lua")

WEAPON_CHEST = WEAPON_CHEST or {
    GUI = {
        MAIN = nil,
        PASSIVE = nil
    }
}

function CreateWeaponChest()
    MsgC(Color(0,255,0),"__  Opening Weapon Chest __\n")
    INVENTORY.GUI.MAIN:SetPos(scrw/2-winw/2,0)
    WEAPON_CHEST.GUI.MAIN = vgui.Create("DPanel",INVENTORY.GUI.ALL)

    WEAPON_CHEST.GUI.MAIN:SetSize(winw, winh-BoxSize/2)
    WEAPON_CHEST.GUI.MAIN:Center()
    WEAPON_CHEST.GUI.MAIN:MakePopup()
    WEAPON_CHEST.GUI.MAIN:SetVisible(true)
    WEAPON_CHEST.GUI.MAIN:SetBackgroundColor(Color(0,0,0,0))
    WEAPON_CHEST.GUI.MAIN:SetPos(scrw/2-winw/2, scrh/2+BoxSize/2)
    inventoryContainer = vgui.Create("DPanel",WEAPON_CHEST.GUI.MAIN)
    inventoryContainer:Dock(FILL)
    inventoryContainer:DockPadding(4,4,4,4)
    inventoryContainer:SetBackgroundColor(Color(0,0,0,0))
    inventoryContainer.Paint = function(self, w, h)
        
        surface.SetDrawColor(50,50,50,100)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255,255,255)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end
    
    local CloseBar = vgui.Create("DPanel", inventoryContainer)
    CloseBar:SetSize(0, BoxSize )
    CloseBar:Dock(TOP)
    CloseBar:SetBackgroundColor(Color(0,0,0,0))
    CloseBar:SetContentAlignment(6)
    local InventoryLabel = vgui.Create("DLabel", CloseBar)
    InventoryLabel:SetText("Waffenkiste")
    InventoryLabel:Dock(FILL)
    InventoryLabel:SetContentAlignment(5)
    SetLabelSize(InventoryLabel, BoxSize*3/4)
    local CloseButton = vgui.Create("DButton", CloseBar)
    CloseButton:SetSize(BoxSize /2, BoxSize /2)
    CloseButton:DockMargin(BoxSize /4,BoxSize /4,BoxSize /4,BoxSize /4)
    CloseButton:SetColor(Color(0, 0, 0))
    -- CloseButton:SetFont("Roboto_3")
    CloseButton:Dock(RIGHT)
    CloseButton:SetText("▲")
    CloseButton:SetTextColor(Color(170,170,170))
    CloseButton.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(45, 45, 45))
        surface.SetDrawColor(35, 35, 35)
        surface.DrawOutlinedRect(0, 0, w, h, 4)
    end

    CloseButton.DoClick = function()
        WEAPON_CHEST.GUI.MAIN:Remove()
        INVENTORY.GUI.MAIN:SetPos(scrw/2-winw/2, scrh/2-winh/2)
    end
    
    local ReloadButton = vgui.Create("DButton", CloseBar)
    ReloadButton:SetSize(BoxSize * .5, BoxSize * .5)
    ReloadButton:SetColor(Color(0, 0, 0))
    ReloadButton:SetTextColor(Color(170,170,170))
    ReloadButton:DockMargin(BoxSize /4,BoxSize /4,0,BoxSize /4)
    -- CloseButton:SetFont("Roboto_3")
    ReloadButton:Dock(LEFT)
    ReloadButton:SetText("↻")
    ReloadButton.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(45, 45, 45))
        surface.SetDrawColor(35, 35, 35)
        surface.DrawOutlinedRect(0, 0, w, h, 4)

    end

    ReloadButton.DoClick = function()
        reload()
    end
    WEAPON_CHEST.GUI.PASSIVE = vgui.Create("DPanel", inventoryContainer)
    WEAPON_CHEST.GUI.PASSIVE:SetSize(0,5 * BoxSize + 8 + BoxSize /2 )
    WEAPON_CHEST.GUI.PASSIVE:SetPos(0,0)
    WEAPON_CHEST.GUI.PASSIVE:SetName("InventoryPassivePanel")
    WEAPON_CHEST.GUI.PASSIVE:DockMargin(2,2,2,2)
    WEAPON_CHEST.GUI.PASSIVE:DockPadding(2,2,2,2)
    WEAPON_CHEST.GUI.PASSIVE:Dock(TOP)
    WEAPON_CHEST.GUI.PASSIVE:SetBackgroundColor(Color(0,0,0,0))
    WEAPON_CHEST.GUI.PASSIVE:Add(createContainerV2(12,5,BoxSize/2,0,"Bereitgestellte Ausrüstung",{["allow"] = "none", ["infinite"] = "true",["isEquipment"] = false}))
    WEAPON_CHEST.GUI.PASSIVE:Add(createContainerV2(3,3,BoxSize * 13,0,"Zurücklegen",{["isEquipment"] = false,["isBin"] = true}))
end


function AddToWeaponChest(item)
    local itemInfo = InventoryItems[item.Item_ID]
    if itemInfo then
        local Size = tonumber(itemInfo.Size )
        local ItemPanel = CreateDropItem(
            item.Item_ID,
            itemInfo
        )
        local x,y = getSizeXY(Size)
        for i = 0, #WEAPON_CHEST.GUI.PASSIVE:GetChild(0):GetChild(0):GetChildren()-1 do
            local inventoryhover = WEAPON_CHEST.GUI.PASSIVE:GetChild(0):GetChild(0):GetChild(i)
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



local function RemoveFromPassiveInventory(itemName)
    for i = 0, #INVENTORY.GUI.PASSIVE:GetChild(0):GetChildren()-1 do
        if#INVENTORY.GUI.PASSIVE:GetChild(0):GetChild(i):GetChildren() == 1 and (INVENTORY.GUI.PASSIVE:GetChild(0):GetChild(i):GetChild(0):GetName() == itemName or itemName == nil) then
            
            
            local xBox, yBox = INVENTORY.GUI.PASSIVE:GetChild(0):GetChild(i):GetChild(0):GetSize()
            BoxSize = math.floor(INVENTORY.SETTINGS.BOXSIZE)
            xBox, yBox = xBox / BoxSize, yBox / BoxSize
            xBox, yBox = math.floor(xBox), math.floor(yBox)
            changeSizes(nil,xBox, yBox,INVENTORY.GUI.PASSIVE:GetChild(0):GetChild(i):GetChild(0))
            INVENTORY.GUI.PASSIVE:GetChild(0):GetChild(i):GetChild(0):Remove()
            if itemName then return end

        end
    end
end


local function ClearWeaponChest()
    RemoveFromPassiveInventory(nil)
    RemoveFromActiveInventory(nil)
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
            RequestWeaponChestSync() 
            return
        else
            CreateInventory()
            CreateWeaponChest()
            RequestWeaponChestSync() 
        end
        
    end
)
concommand.Add(
    "invWeaponBoxReload",function()
        reload()
    end
)


