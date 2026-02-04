
INVENTORY = INVENTORY or {
    GUI = {
        ALL =nil,
        MAIN = nil,
        INVENTORY = nil,
        MODEL = nil
    },
    SETTINGS = {
        SCREEN = {
            WIDTH = ScrW(),
            HEIGHT = ScrH()
        },
        WINDOW = {
            WIDTH = winw,
            HEIGHT = winh
        },
        TABLE = {
            WIDTH = InvX,
            HEIGHT = InvY
        },
        BOXSIZE = BoxSize
    },
    THEME = {},
    ITEMS = {}
}
INVENTORY.ITEMS = INVENTORY.ITEMS or {}

AddCSLuaFile("cl_inventory_drop_event.lua")
AddCSLuaFile("cl_inventory_helper.lua")

function CreateInventory()
    MsgC(Color(0,255,0),"__ Creating Inventory __\n")
    print("BoxSize: "..BoxSize  )
    INVENTORY.GUI.ALL = vgui.Create("DPanel")
    INVENTORY.GUI.ALL:SetSize(scrw, scrh)
    INVENTORY.GUI.ALL:Center()
    INVENTORY.GUI.ALL:SetVisible(false)
    INVENTORY.GUI.ALL:SetBackgroundColor(Color(0,0,0,0))
    INVENTORY.GUI.ALL.PaintOver = function(self, w, h)
        Derma_DrawBackgroundBlur(self, self.startTime)
    end

    INVENTORY.GUI.MAIN = vgui.Create("DPanel",INVENTORY.GUI.ALL)

    INVENTORY.GUI.MAIN:SetSize(winw, winh)
    INVENTORY.GUI.MAIN:Center()
    INVENTORY.GUI.MAIN:MakePopup()
    INVENTORY.GUI.MAIN:SetVisible(true)
    INVENTORY.GUI.MAIN:SetBackgroundColor(Color(0,0,0,0))
    INVENTORY.GUI.MAIN:SetPos(scrw/2-winw/2, scrh/2-winh/2)
    inventoryContainer = vgui.Create("DPanel",INVENTORY.GUI.MAIN)
    inventoryContainer:Dock(RIGHT)
    inventoryContainer:DockPadding(4,4,4,4)
    inventoryContainer:SetSize(11 * BoxSize,7 * BoxSize)
    inventoryContainer:SetPos(0,0)
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
    InventoryLabel:SetText("Inventar")
    InventoryLabel:Dock(FILL)
    InventoryLabel:SetContentAlignment(5)
    SetLabelSize(InventoryLabel, BoxSize*3/4)
    local CloseButton = vgui.Create("DButton", CloseBar)
    CloseButton:SetSize(BoxSize /2, BoxSize /2)
    CloseButton:DockMargin(BoxSize /4,BoxSize /4,BoxSize /4,BoxSize /4)
    CloseButton:SetColor(Color(0, 0, 0))
    -- CloseButton:SetFont("Roboto_3")
    CloseButton:Dock(RIGHT)
    CloseButton:SetText("✖")
    CloseButton:SetTextColor(Color(170,170,170))
    CloseButton.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(45, 45, 45))
        surface.SetDrawColor(35, 35, 35)
        surface.DrawOutlinedRect(0, 0, w, h, 4)
    end

    CloseButton.DoClick = function()
        closeInventory()
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
    modelContainer = vgui.Create("DPanel",INVENTORY.GUI.MAIN)
    
    modelContainer:Dock(LEFT)
    modelContainer:SetSize(5*BoxSize,0)
    modelContainer:DockPadding(2,2,2,2)
    modelContainer.Paint = function(self, w, h)
        surface.SetDrawColor(50,50,50,100)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255,255,255)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end
    INVENTORY.GUI.MODEL = vgui.Create("DModelPanel", modelContainer)
    INVENTORY.GUI.MODEL:SetModel("models/player/skeleton.mdl")
    INVENTORY.GUI.MODEL:Dock(FILL)


    INVENTORY.GUI.INVENTORY = vgui.Create("DPanel",inventoryContainer)
    INVENTORY.GUI.INVENTORY:Dock(FILL)
    INVENTORY.GUI.INVENTORY:SetBackgroundColor(Color(0,0,0,0))
    INVENTORY.GUI.INVENTORY:Add(createContainerV2(2,3,BoxSize / 2 ,0,"Rüstung",{["allow"] = "Armor", ["equipment"] = true}))
    INVENTORY.GUI.INVENTORY:Add(createContainerV2(3,3,BoxSize * 3,0,"Waffen",{["allow"] = "Weapon", ["equipment"] = true}))
    INVENTORY.GUI.INVENTORY:Add(createContainerV2(4,3,BoxSize / 2+BoxSize * 6,0,"Ausrüstung",{["allow"] = "Util", ["equipment"] = true}))
    INVENTORY.GUI.INVENTORY:Add(createContainerV2(10,1,BoxSize/2,BoxSize * 4,"Rucksack"))
end

function AddToInventory(item)
    for i = 1, item.Amount do
        local itemInfo = InventoryItems[item.Item_ID]
        if itemInfo then
            local Size = tonumber(itemInfo.Size )
            local ItemPanel = CreateDropItem(
                item.Item_ID,
                itemInfo
            )
            local x,y = getSizeXY(Size)
            for s = 0, #INVENTORY.GUI.INVENTORY:GetChildren()-1 do
                if INVENTORY.GUI.INVENTORY:GetChild(s):GetName() == "Rucksack" then
                    inventoryhover = INVENTORY.GUI.INVENTORY:GetChild(s):GetChild(0)
                    break
                end
            end
            print(#inventoryhover:GetChildren())
            for i = 0, #inventoryhover:GetChildren()-1 do
                if isDropable(inventoryhover:GetChild(i), i, x, y, ItemPanel) then
                    inventoryhover:GetChild(i):Add(ItemPanel)
                    changeSizes(inventoryhover:GetChild(i), x, y, ItemPanel)
                    return
                end
            end
            MsgC(Color(127,0,0),"Couldn't add Item to Inventory:\n")
            PrintTable(itemInfo)
            ItemPanel:Remove()
        end
    end
end

function RemoveFromInventory(itemName)
    for i = 0, #INVENTORY.GUI.INVENTORY:GetChildren()-1 do
        print("Checking Inventory Panel: " .. INVENTORY.GUI.INVENTORY:GetChild(i):GetName())
        local inventoryhover = INVENTORY.GUI.INVENTORY:GetChild(i):GetChild(0)
        for j = 0, #inventoryhover:GetChildren()-1 do
            local itemPanel = inventoryhover:GetChild(j)
            if #itemPanel:GetChildren() == 1 and itemPanel:GetChild(0):GetName() == itemName then
                print("Removing Item: " .. itemName .. " from Inventory")
                local xBox, yBox = itemPanel:GetChild(0):GetSize()
                BoxSize = math.floor(INVENTORY.SETTINGS.BOXSIZE)
                xBox, yBox = xBox / BoxSize, yBox / BoxSize
                xBox, yBox = math.floor(xBox), math.floor(yBox)
                changeSizes(nil,xBox, yBox,itemPanel:GetChild(0))
                itemPanel:GetChild(0):Remove()
                return
            end
        end
    end
end

function ClearInventory()
    for i = 0, #INVENTORY.GUI.INVENTORY:GetChildren()-1 do
        for j = 0, #INVENTORY.GUI.INVENTORY:GetChild(i):GetChild(0):GetChildren()-1 do
            local itemPanel = INVENTORY.GUI.INVENTORY:GetChild(i):GetChild(0):GetChild(j)
            if #itemPanel:GetChildren() == 1 then
                local xBox, yBox = itemPanel:GetChild(0):GetSize()
                BoxSize = math.floor(INVENTORY.SETTINGS.BOXSIZE)
                xBox, yBox = xBox / BoxSize, yBox / BoxSize
                xBox, yBox = math.floor(xBox), math.floor(yBox)
                changeSizes(nil,xBox, yBox,itemPanel:GetChild(0))
                itemPanel:GetChild(0):Remove()
            end
        end
    end
end



concommand.Add(
    "inv",
    function()
        if(INVENTORY.GUI.ALL and INVENTORY.GUI.ALL:IsValid()) then
            -- INVENTORY.GUI.MAIN:Remove()
            if  INVENTORY.GUI.MODEL and INVENTORY.GUI.MODEL:IsValid() then
                INVENTORY.GUI.MODEL:SetModel(LocalPlayer():GetModel())
            else 
                CreateInventory()
            end
            INVENTORY.GUI.ALL:SetVisible(not INVENTORY.GUI.ALL:IsVisible())
            return
        else
            CreateInventory()
            RequestInventorySync() 
        end
        
    end
)
concommand.Add(
    "invReload",function()
        reload()
    end
)
concommand.Add(
    "remove",function()
        RemoveFromInventory("weapon_crowbar")
    end
)
hook.Add("PlayerButtonDown", "OpenInventoryKey", function(ply, key)
    if key == KEY_N then
        if INVENTORY.GUI.ALL and INVENTORY.GUI.ALL:IsValid() then
            INVENTORY.GUI.MODEL:SetModel(LocalPlayer():GetModel())
            INVENTORY.GUI.ALL:SetVisible(not INVENTORY.GUI.ALL:IsVisible())
        else
            CreateInventory()
            RequestInventorySync()
        end
    end
end)
