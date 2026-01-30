
local scrw, scrh = ScrW(), ScrH()
local winw, winh = scrw * 0.8, scrh * 0.85
local InvX, InvY = 10,10
local BoxSize = (winw * 0.6 / InvX) - InvX
local ContainerIndex = 0

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
    local i = 0

    local width = PickedUpItem:GetParent():GetCookie("SizeX")
    local height = PickedUpItem:GetParent():GetCookie("SizeY")
    local allDropIns = PickedUpItem:GetParent():GetParent():GetChildren()

    if #allDropIns == width * height then
        for k, v in pairs(allDropIns) do
            if #v:GetChildren() == 1 and v:GetChildren()[1] == PickedUpItem then
                for dy=0, y-1 do
                    for dx=0, x-1 do
                        allDropIns[k+dx+dy*width]:SetSize(BoxSize,BoxSize)
                    end
                end
            end
        end
    end
    
    local width = toPut:GetCookie("SizeX")
    local height = toPut:GetCookie("SizeY")

    if toPut then
        local parent = toPut:GetParent()
        local children = parent:GetChildren()
        local i = 0

        for k, v in pairs(children) do
            print(v)
            if v == toPut then break end
            i = i + 1
        end

        if #children == width * height then
            for offsetY = 0, y - 1 do
                for offsetX = 0, x - 1 do
                    if not (offsetX == 0 and offsetY == 0) then
                        local index = i + offsetX + offsetY * width
                        if children[index + 1] then
                            children[index + 1]:SetSize(0, 0)
                        end
                    end
                end
            end

            -- set the size of the main panel
            toPut:SetSize(BoxSize * x, BoxSize * y)
        end
    end

end

function DropPanel(i,j)
    dropPanel = vgui.Create("DPanel")
    dropPanel:SetSize(BoxSize, BoxSize)
    dropPanel:SetName("DropIN: " .. j .. " | " .. i)
    dropPanel:SetPos((j - 1) * BoxSize + j * 2, (i - 1) * BoxSize + i * 2)
    dropPanel:SetCookieName("Inventory: " .. j .. " | " .. i)
    dropPanel:SetCookie("SizeX",InvX)
    dropPanel:SetCookie("SizeY",InvY)
    dropPanel:Receiver("Inventory", DropEventInventory)
    dropPanel.Paint = function(self, w, h)
        surface.SetDrawColor(50, 50, 50, 150)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(50, 50, 50)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end
    return dropPanel
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
            INVENTORY.GUI.PASSIVE:Add(DropPanel(i,j))
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
    INVENTORY.GUI.ACTIVE.BOTTOM:Add(createContainerv2(2,2,BoxSize * 2 + 3*BoxSize / 4, BoxSize / 8,"Armor"))
    INVENTORY.GUI.ACTIVE.BOTTOM:Add(createContainerv2(1,1,BoxSize / 4 , 0,nil,true))
    INVENTORY.GUI.ACTIVE.BOTTOM:Add(createContainerv2(1,1,BoxSize / 4 , BoxSize + BoxSize/4,nil,true))
    INVENTORY.GUI.ACTIVE.BOTTOM:Add(createContainerv2(1,1,BoxSize * 1 + BoxSize / 2, 0,nil,true))
    INVENTORY.GUI.ACTIVE.BOTTOM:Add(createContainerv2(1,1,BoxSize * 1 + BoxSize / 2, BoxSize + BoxSize/4,nil,true))
    INVENTORY.GUI.ACTIVE.BOTTOM:Add(createContainerv2(1,1,BoxSize * 5 , 0,nil,true))
    INVENTORY.GUI.ACTIVE.BOTTOM:Add(createContainerv2(1,1,BoxSize * 5, BoxSize + BoxSize/4,nil,true))
    INVENTORY.GUI.ACTIVE.BOTTOM:Add(createContainerv2(1,1,BoxSize * 6 + BoxSize / 4, 0,nil,true))
    INVENTORY.GUI.ACTIVE.BOTTOM:Add(createContainerv2(1,1,BoxSize * 6 + BoxSize / 4, BoxSize + BoxSize/4,nil,true))
    INVENTORY.GUI.ACTIVE.TOP = vgui.Create("DPanel", sidePanel)
    INVENTORY.GUI.ACTIVE.TOP:SetSize(0, BoxSize * 1.5)
    INVENTORY.GUI.ACTIVE.TOP:Dock(TOP)
    INVENTORY.GUI.ACTIVE.TOP:SetBackgroundColor(Color(0, 0, 0, 0))
    INVENTORY.GUI.ACTIVE.TOP:Add(createContainerv2(2,1,BoxSize / 4, BoxSize / 4,"Secondary"))
    INVENTORY.GUI.ACTIVE.TOP:Add(createContainerv2(1,1,BoxSize * 2 + BoxSize * 2 / 4, BoxSize / 4,"Holster"))
    -- INVENTORY.GUI.ACTIVE.TOP:Add(createContainer(3,1,BoxSize * 4, BoxSize / 4))
    INVENTORY.GUI.ACTIVE.TOP:Add(createContainerv2(3,1,BoxSize * 4, BoxSize / 4,"Primary /\nSecondary + Holster"))
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
    elseif x == 2 then
        if y == 1 then
            dropContainer:Receiver("2x1", DropEvent2x1)
        else
            dropContainer:Receiver("2x2", DropEvent2x2)
        end
    elseif x == 3 then
        dropContainer:Receiver("3x1", DropEvent3x1) 
        dropContainer:Receiver("2x1", DropEvent2x1)
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

function createContainerv2(x,y,posX,posY,Name,hidden)
    local container = vgui.Create("DPanel")
    container:SetSize(BoxSize*x, BoxSize*y)
    container:SetPos(posX, posY)
    container.Paint = function(self, w, h)
        surface.SetDrawColor(50, 50, 50, 150)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 255, 255)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end
    
    local dragContainer = vgui.Create("DPanel",container)
    dragContainer:SetSize(BoxSize*x, BoxSize*y)
    dragContainer:SetPos(0, 0)
    dragContainer.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 0)
    end
    local Text = vgui.Create("DLabel",container)
    if not Name then
        Name = "Blank"
    end
    Text:SetText(Name)
    Text:SetSize(BoxSize*x, BoxSize*y)
    Text:SetPos(0,-5)
    Text:SetContentAlignment(2)
    print(x,y)
    
    for i = 1, y do
        for j = 1, x do
            local dropContainer = vgui.Create("DPanel")
            dropContainer:SetSize(BoxSize, BoxSize)
            dropContainer:SetPos((j-1) * BoxSize, (i-1) * BoxSize)
            dropContainer:Receiver("Inventory",DropEventEquipment)
            dropContainer:SetCookieName("Equipment" .. i .. "," .. j .. ", " .. ContainerIndex)
            ContainerIndex = ContainerIndex + 1
            print("Equipment" .. i .. "," .. j)
            dropContainer:SetCookie("SizeX",x)
            dropContainer:SetCookie("SizeY",y)

            dropContainer.Paint = function(self, w, h)
                surface.SetDrawColor(50, 50, 50, 150)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(63, 63, 63, 82)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            end
            dragContainer:Add(dropContainer)
        end
    end
    return container
end


function CreateDropItem(Name, Size, Texture, index)
    local Item = vgui.Create("DPanel")
    local Text = vgui.Create("DLabel", Item)
    local x, y = 1, 1

    if Size == 2 then
        x = 2
        Item:Droppable("2x1")
        Item:Droppable("3x1")
    elseif Size == 3 then
        y = 2
        Item:Droppable("1x2")
    elseif Size == 4 then
        x, y = 2, 2
        Item:Droppable("2x2")
    elseif Size == 1 then
        x, y = 1, 1
        Item:Droppable("1x1")
    else
        x, y = 3, 1
        Item:Droppable("3x1")
    end

    Item:SetSize(BoxSize * x, BoxSize * y)
    Item:SetCookieName("Panel" .. #INVENTORY.ITEMS .. ", " .. index)
    Item:SetCookie("isEquipped", "false")

    Text:SetText(Name)
    Text:SizeToContents()

    local r, g, b = HexToRGB(Texture)
    Item:SetBackgroundColor(Color(r, g, b))
    Item:SetName(Name)
    Item:Droppable("Inventory")

    -- Anchor fix with position reset
    local originalPos = Item:GetPos()
    Item.Think = function(self)
        if self:IsDragging() then
            -- Force top-left anchor while dragging
            local mx, my = gui.MousePos()
            self:SetPos(mx - BoxSize / 2, my - BoxSize / 2)
        else
            -- Reset position if dragging stopped
            if originalPos then
                self:SetPos(originalPos)
            end
        end
    end

    -- Store original position on mouse press (in case panel moves in container)
    function Item:OnMousePressed(mousecode)
        if mousecode ~= MOUSE_LEFT then return end
        originalPos = {self:GetPos()} -- store x,y as table
        self:MouseCapture(true)
        self:DragMousePress(mousecode)
    end

    function Item:OnMouseReleased(mousecode)
        self:MouseCapture(false)
        self:DragMouseRelease(mousecode)
    end

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
            elseif Size == 5 then
                x, y = 3, 1
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
        INVENTORY.GUI.MAIN:SetVisible(true)
    end
)
