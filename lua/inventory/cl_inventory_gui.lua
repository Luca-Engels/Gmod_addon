
local scrw, scrh = ScrW(), ScrH()
local winw, winh = scrw * 0.8, scrh * 0.85
local InvX, InvY = 10,10
local BoxSize = (winw * 0.6 / InvX) - InvX

INVENTORY = INVENTORY or {
    GUI = {
        MAIN = nil,
        PASSIVE = nil,
        ACTIVE = nil
    },
    SETTINGS = {},
    THEME = {},
    ITEMS = {}
}
INVENTORY.GUI.MAIN = INVENTORY.GUI.MAIN or nil
INVENTORY.GUI.PASSIVE = INVENTORY.GUI.PASSIVE or nil
INVENTORY.GUI.ACTIVE = INVENTORY.GUI.ACTIVE or { 
    TOP = nil,
    BOTTOM = nil,
    LEFT = nil,
    MODEL = nil,
}
INVENTORY.SETTINGS = {
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
}
INVENTORY.THEME = {
    BACKGROUND = Color(10, 10, 10, 150),
    PANEL = Color(0, 0, 0, 200),
    HOVER = Color(100, 100, 100, 200),
    TEXT = Color(255, 255, 255, 255),
    BORDER = Color(0, 0, 0, 255)
}
INVENTORY.ITEMS = INVENTORY.ITEMS or {}

AddCSLuaFile("cl_inventory_drop_event.lua")

local function HexToRGB(hex)
    hex = hex:gsub("#", "")

    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)

    return r, g, b
end

function changeSizes(toPut, x, y, PickedUpItem)
    local t = 1
    local i = 0

    local allDropIns = PickedUpItem:GetParent():GetParent():GetChildren()
    if #allDropIns == InvX * InvY then
        for k, v in pairs(allDropIns) do
            if #v:GetChildren() == 1 and v:GetChildren()[1] == PickedUpItem then
                if x == 2 and y == 1 then
                    v:SetSize(BoxSize, BoxSize)
                    allDropIns[t + 1]:SetSize(BoxSize, BoxSize)
                elseif x == 1 and y == 2 then
                    v:SetSize(BoxSize, BoxSize)
                    allDropIns[t + InvX]:SetSize(BoxSize, BoxSize)
                elseif x == 2 and y == 2 then
                    v:SetSize(BoxSize, BoxSize)
                    allDropIns[t + 1]:SetSize(BoxSize, BoxSize)
                    allDropIns[t + InvX]:SetSize(BoxSize, BoxSize)
                    allDropIns[t + InvX + 1]:SetSize(BoxSize, BoxSize)
                end
            end

            t = t + 1
        end
        -- end
    end
    if toPut then
        for k, v in pairs(toPut:GetParent():GetChildren()) do
            if v == toPut then break end
            i = i + 1
        end
        if #toPut:GetParent():GetChildren() == InvX * InvY then
            if x == 1 and y == 1 then
            elseif x == 2 and y == 1 then
                toPut:GetParent():GetChild(i + 1):SetSize(0, 0)
            elseif x == 1 and y == 2 then
                toPut:GetParent():GetChild(i + InvX):SetSize(0, 0)
            elseif x == 2 and y == 2 then
                toPut:GetParent():GetChild(i + 1):SetSize(0, 0)
                toPut:GetParent():GetChild(i + InvX):SetSize(0, 0)
                toPut:GetParent():GetChild(i + InvX + 1):SetSize(0, 0)
            end

            toPut:SetSize(BoxSize * x, BoxSize * y)
        end
    end
end
function CreateInventory()
    MsgC(Color(255,0,0),"____________________CREATING INVENTORY_________________\n")
    INVENTORY.GUI.MAIN = vgui.Create("DPanel")
    INVENTORY.GUI.MAIN:SetSize(winw, winh)
    INVENTORY.GUI.MAIN:Center()
    INVENTORY.GUI.MAIN:MakePopup()
    INVENTORY.GUI.MAIN:SetVisible(false)
    INVENTORY.GUI.MAIN:SetBackgroundColor(INVENTORY.THEME.BACKGROUND)
    local CloseBar = vgui.Create("DPanel", INVENTORY.GUI.MAIN)
    CloseBar:SetSize(0, BoxSize * .5)
    CloseBar:Dock(TOP)
    CloseBar:SetBackgroundColor(Color(0, 0, 0, 200))
    local CloseButton = vgui.Create("DButton", CloseBar)
    CloseButton:SetSize(BoxSize * .5, BoxSize * .5)
    CloseButton:SetColor(Color(0, 0, 0))
    -- CloseButton:SetFont("Roboto_3")
    CloseButton:Dock(RIGHT)
    CloseButton:SetText("X")
    CloseButton.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(255, 0, 0))
    end

    CloseButton.DoClick = function()
        INVENTORY.GUI.MAIN:SetVisible(false)
    end
    local rightSidePanel = vgui.Create("DPanel", INVENTORY.GUI.MAIN)
    rightSidePanel:SetSize(winw * 0.56, 0)
    rightSidePanel:SetBackgroundColor(Color(50, 50, 50, 150))
    rightSidePanel:Dock(RIGHT)
    INVENTORY.GUI.PASSIVE = vgui.Create("DScrollPanel", rightSidePanel) 
    INVENTORY.GUI.PASSIVE:GetVBar():SetWide(10)
    INVENTORY.GUI.PASSIVE:Dock(FILL)
    INVENTORY.GUI.PASSIVE:SetName("InventoryPassivePanel")
    INVENTORY.GUI.PASSIVE.Paint = function(self, w, h)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 255, 255)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end
    for i = 1, INVENTORY.SETTINGS.TABLE.HEIGHT do
        for j = 1, INVENTORY.SETTINGS.TABLE.WIDTH do
            local DropPanel = vgui.Create("DPanel")
            DropPanel:SetSize(BoxSize, BoxSize)
            DropPanel:SetName("DropIN: " .. j .. " | " .. i)
            DropPanel:SetPos((j - 1) * BoxSize + j * 2, (i - 1) * BoxSize + i * 2)
            DropPanel:Receiver("Inventory", DropEventInventory)
            DropPanel.Paint = function(self, w, h)
                surface.SetDrawColor(50, 50, 50, 150)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(50, 50, 50)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            end
            INVENTORY.GUI.PASSIVE:Add(DropPanel)
        end
    end
    local sidePanel = vgui.Create("DPanel", INVENTORY.GUI.MAIN)
    sidePanel:SetSize(winw * 0.42, 0)
    sidePanel:Dock(LEFT)
    sidePanel.Paint = function(self, w, h)
        surface.SetDrawColor(50, 50, 50, 150)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 255, 255)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end
    INVENTORY.GUI.ACTIVE.MODEL = vgui.Create("DModelPanel", sidePanel)
    INVENTORY.GUI.ACTIVE.MODEL:SetModel("models/player/skeleton.mdl")
    INVENTORY.GUI.ACTIVE.MODEL:Dock(FILL)
    local rightBar = vgui.Create("DPanel", sidePanel)
    rightBar:SetSize(BoxSize * .5, 0)
    rightBar:Dock(RIGHT)
    rightBar:SetBackgroundColor(Color(0, 0, 0, 0))
    INVENTORY.GUI.ACTIVE.BOTTOM = vgui.Create("DPanel", sidePanel)
    INVENTORY.GUI.ACTIVE.BOTTOM:SetSize(0, BoxSize * 2.5)
    INVENTORY.GUI.ACTIVE.BOTTOM:Dock(BOTTOM)
    INVENTORY.GUI.ACTIVE.BOTTOM:SetBackgroundColor(Color(0, 0, 0, 0))
    INVENTORY.GUI.ACTIVE.BOTTOM:Add(createContainer(2,2,BoxSize * 2 + 3*BoxSize / 4, BoxSize / 8))
    INVENTORY.GUI.ACTIVE.BOTTOM:Add(createContainer(1,1,BoxSize / 4 , 0,true))
    INVENTORY.GUI.ACTIVE.BOTTOM:Add(createContainer(1,1,BoxSize / 4 , BoxSize + BoxSize/4,true))
    INVENTORY.GUI.ACTIVE.BOTTOM:Add(createContainer(1,1,BoxSize * 1 + BoxSize / 2, 0,true))
    INVENTORY.GUI.ACTIVE.BOTTOM:Add(createContainer(1,1,BoxSize * 1 + BoxSize / 2, BoxSize + BoxSize/4,true))
    INVENTORY.GUI.ACTIVE.BOTTOM:Add(createContainer(1,1,BoxSize * 5 , 0,true))
    INVENTORY.GUI.ACTIVE.BOTTOM:Add(createContainer(1,1,BoxSize * 5, BoxSize + BoxSize/4,true))
    INVENTORY.GUI.ACTIVE.BOTTOM:Add(createContainer(1,1,BoxSize * 6 + BoxSize / 4, 0,true))
    INVENTORY.GUI.ACTIVE.BOTTOM:Add(createContainer(1,1,BoxSize * 6 + BoxSize / 4, BoxSize + BoxSize/4,true))
    INVENTORY.GUI.ACTIVE.TOP = vgui.Create("DPanel", sidePanel)
    INVENTORY.GUI.ACTIVE.TOP:SetSize(0, BoxSize * 1.5)
    INVENTORY.GUI.ACTIVE.TOP:Dock(TOP)
    INVENTORY.GUI.ACTIVE.TOP:SetBackgroundColor(Color(0, 0, 0, 0))
    INVENTORY.GUI.ACTIVE.TOP:Add(createContainer(1,1,BoxSize / 4, BoxSize / 4))
    INVENTORY.GUI.ACTIVE.TOP:Add(createContainer(1,1,BoxSize + BoxSize / 2, BoxSize / 4))
    INVENTORY.GUI.ACTIVE.TOP:Add(createContainer(1,1,BoxSize * 2 + BoxSize * 3 / 4, BoxSize / 4))
    INVENTORY.GUI.ACTIVE.TOP:Add(createContainer(1,1,BoxSize * 4, BoxSize / 4))
    INVENTORY.GUI.ACTIVE.TOP:Add(createContainer(2,1,BoxSize * 5 + BoxSize / 4, BoxSize / 4))
    INVENTORY.GUI.ACTIVE.LEFT = vgui.Create("DPanel", sidePanel)
    INVENTORY.GUI.ACTIVE.LEFT:SetSize(BoxSize * 1.5, 0)
    INVENTORY.GUI.ACTIVE.LEFT:Dock(LEFT)
    INVENTORY.GUI.ACTIVE.LEFT:SetBackgroundColor(Color(0, 0, 0, 0))
    INVENTORY.GUI.ACTIVE.LEFT:Add(createContainer(1,2,BoxSize / 4, BoxSize / 4))
    INVENTORY.GUI.ACTIVE.LEFT:Add(createContainer(1,2,BoxSize / 4, BoxSize / 2 + BoxSize * 2))
    INVENTORY.GUI.ACTIVE.LEFT:Add(createContainer(1,1,BoxSize / 4, BoxSize + BoxSize * 3 + (BoxSize * 3 / 4)))
end

function createContainer(x,y,posX,posY,hidden)
    dropContainer = vgui.Create("DPanel")
    dropContainer:SetSize(BoxSize*x, BoxSize*y)
    dropContainer:SetPos(posX, posY)
    if x == 1 then
        if y == 1 then
            dropContainer:Receiver("1x1", DropEvent1x1)
        else
            dropContainer:Receiver("1x2", DropEvent1x2)
        end
    elseif y == 1 then
        dropContainer:Receiver("2x1", DropEvent2x1)
    else
        dropContainer:Receiver("2x2", DropEvent2x2)
    end
    dropContainer.Paint = function(self, w, h)
        surface.SetDrawColor(50, 50, 50, 150)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(50, 50, 50)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end
    if hidden then
        dropContainer:SetVisible(false)
    end
    return dropContainer
end


function CreateDropItem(Name, Size, Texture,index)
    local Item = vgui.Create("DPanel")
    local Text = vgui.Create("DLabel", Item)
    local x, y = 1, 1
    if Size == 2 then
        x = 2
        Item:Droppable("2x1")
    elseif Size == 3 then
        y = 2
        Item:Droppable("1x2")
    elseif Size == 4 then
        x, y = 2, 2
        Item:Droppable("2x2")
    else
        x, y = 1, 1
        Item:Droppable("1x1")
    end
    Item:SetSize(BoxSize * x, BoxSize * y)
    Item:SetCookieName("Panel" .. #INVENTORY.ITEMS ..", " ..  index)
    Item:SetCookie("isEquipped","false")
    Text:SetText(Name)
    Text:SizeToContents()
    r,g,b = HexToRGB(Texture)
    Item:SetBackgroundColor(Color(r,g,b))
    Item:SetName(Name)
    Item:Droppable("Inventory")

    return Item
end

function AddToInventory(item)
        PrintTable(item)
    if item.Active then
        AddToActiveInventory(item)
    else
        AddToPassiveInventory(item) 
    end
end


function AddToActiveInventory(item)
end


function AddToPassiveInventory(item)
    for i = 1, item.Amount do
        local itemInfo = InventoryItems[item.Item_ID]
        if itemInfo then
            local Size = tonumber(itemInfo.Size )
            local ItemPanel = CreateDropItem(
                item.Item_ID,
                itemInfo.Size,
                itemInfo.Color,
                i
            )
            local x,y = 1,1
            if Size == 1 then
                x, y = 1, 1
            elseif Size == 2 then
                x, y = 2, 1
            elseif Size == 3 then
                x, y = 1, 2
            elseif Size == 4 then
                x, y = 2, 2
            end


            for i = 0, INVENTORY.SETTINGS.TABLE.WIDTH * INVENTORY.SETTINGS.TABLE.HEIGHT do
                local inventoryhover = INVENTORY.GUI.PASSIVE:GetChild(0):GetChild(i)
                if isDropable(inventoryhover, i, x, y, ItemPanel) then
                    inventoryhover:Add(ItemPanel)
                    changeSizes(inventoryhover, x, y, ItemPanel)
                    break
                end
            end
        end
    end

end

function RemoveFromPassiveInventory(itemName)
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

function RemoveFromActiveInventory(itemName)
    for i = 0, #INVENTORY.GUI.ACTIVE.TOP:GetChildren()-1 do
        if #INVENTORY.GUI.ACTIVE.TOP:GetChild(i):GetChildren() == 1 and (INVENTORY.GUI.ACTIVE.TOP:GetChild(i):GetChild(0):GetName() ==  itemName or itemName == nil) then
            INVENTORY.GUI.ACTIVE.TOP:GetChild(i):GetChild(0):Remove()
            if itemName then return end
        end
    end
    for i = 0, #INVENTORY.GUI.ACTIVE.LEFT:GetChildren()-1 do
        if #INVENTORY.GUI.ACTIVE.LEFT:GetChild(i):GetChildren() == 1 and (INVENTORY.GUI.ACTIVE.LEFT:GetChild(i):GetChild(0):GetName() == itemName or itemName == nil) then
            INVENTORY.GUI.ACTIVE.LEFT:GetChild(i):GetChild(0):Remove()
            if itemName then return end
        end
    end
    for i = 0, #INVENTORY.GUI.ACTIVE.BOTTOM:GetChildren()-1 do
        if #INVENTORY.GUI.ACTIVE.BOTTOM:GetChild(i):GetChildren() == 1 and (INVENTORY.GUI.ACTIVE.BOTTOM:GetChild(i):GetChild(0):GetName() ==  itemName or itemName == nil) then
            INVENTORY.GUI.ACTIVE.BOTTOM:GetChild(i):GetChild(0):Remove()
            if itemName then return end
        end
    end
end

function ClearInventory()
    RemoveFromPassiveInventory(nil)
    RemoveFromActiveInventory(nil)
end


concommand.Add(
    "inv",
    function()
        if(INVENTORY.GUI.MAIN and INVENTORY.GUI.MAIN:IsValid()) then
            -- INVENTORY.GUI.MAIN:Remove()
            INVENTORY.GUI.ACTIVE.MODEL:SetModel(LocalPlayer():GetModel())
            INVENTORY.GUI.MAIN:SetVisible(not INVENTORY.GUI.MAIN:IsVisible())
            return
        else
            CreateInventory()
            RequestInventorySync() 
        end
        
    end
)
concommand.Add(
    "invReload",
    function()
        INVENTORY.GUI.MAIN:Remove()
        INVENTORY.ITEMS = {}
        CreateInventory()
        RequestInventorySync() 
        INVENTORY.GUI.MAIN:SetVisible()
    end
)
