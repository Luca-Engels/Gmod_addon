
local scrw, scrh = ScrW(), ScrH()
local winw, winh = scrw * 0.6, scrh * 0.5
local InvX, InvY = 10,1
local BoxSize = (winw * 0.7 / 10) - 10
local ContainerIndex = 0



AddCSLuaFile("cl_inventory_gui.lua")

function CreateInventory()
    MsgC(Color(0,255,0),"__ Creating Inventory __\n")
    INVENTORY.GUI.MAIN = vgui.Create("DPanel")

    INVENTORY.GUI.MAIN:SetSize(winw, winh)
    INVENTORY.GUI.MAIN:Center()
    INVENTORY.GUI.MAIN:MakePopup()
    INVENTORY.GUI.MAIN:SetVisible(false)
    INVENTORY.GUI.MAIN:SetBackgroundColor(Color(0,0,0,0))
    inventoryContainer = vgui.Create("DPanel",INVENTORY.GUI.MAIN)
    inventoryContainer:Dock(RIGHT)
    inventoryContainer:DockPadding(4,4,4,4)
    inventoryContainer:SetSize(11 * BoxSize,6 * BoxSize)
    inventoryContainer:SetPos(0,0)
    inventoryContainer:SetBackgroundColor(Color(0,0,0,0))
    inventoryContainer.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, self.startTime)
        
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
        INVENTORY.GUI.MAIN:SetVisible(false)
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
        INVENTORY.GUI.MAIN:Remove()
        INVENTORY.ITEMS = {}
        CreateInventory()
        RequestInventorySync() 
        INVENTORY.GUI.MAIN:SetVisible(true)
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
    INVENTORY.GUI.ACTIVE.MODEL = vgui.Create("DModelPanel", modelContainer)
    INVENTORY.GUI.ACTIVE.MODEL:SetModel("models/player/skeleton.mdl")
    INVENTORY.GUI.ACTIVE.MODEL:Dock(FILL)


    INVENTORY.GUI.ACTIVE.TOP = vgui.Create("DPanel",inventoryContainer)
    INVENTORY.GUI.ACTIVE.TOP:Dock(FILL)
    INVENTORY.GUI.ACTIVE.TOP:SetBackgroundColor(Color(0,0,0,0))
    INVENTORY.GUI.ACTIVE.TOP:Add(createContainerV2(2,3,BoxSize / 2 ,0,"Rüstung","Armor"))
    INVENTORY.GUI.ACTIVE.TOP:Add(createContainerV2(3,3,BoxSize * 3,0,"Waffen","Weapon"))
    INVENTORY.GUI.ACTIVE.TOP:Add(createContainerV2(4,3,BoxSize / 2+BoxSize * 6,0,"Ausrüstung","Util"))
    -- INVENTORY.GUI.ACTIVE.TOP:Add(createContainerV2(1,1,BoxSize / 2 + BoxSize * 6 ,BoxSize / 2,"Holster","Weapon"))
    -- INVENTORY.GUI.ACTIVE.TOP:Add(createContainerV2(2,1,BoxSize * 4 ,BoxSize / 2,"Secondary","Weapon"))
    -- INVENTORY.GUI.ACTIVE.TOP:Add(createContainerV2(5,1,BoxSize / 2  ,BoxSize * 2,"Util","Util"))
    -- INVENTORY.GUI.ACTIVE.TOP:Add(createContainerV2(5,1,BoxSize / 2  ,BoxSize + BoxSize*2+BoxSize/2,"Ammo","Ammo"))

    INVENTORY.GUI.PASSIVE = vgui.Create("DPanel", inventoryContainer)
    INVENTORY.GUI.PASSIVE:SetSize(0,2 * BoxSize + 8)
    INVENTORY.GUI.PASSIVE:SetPos(0,0)
    INVENTORY.GUI.PASSIVE:SetName("InventoryPassivePanel")
    INVENTORY.GUI.PASSIVE:DockMargin(2,2,2,2)
    INVENTORY.GUI.PASSIVE:DockPadding(2,2,2,2)
    INVENTORY.GUI.PASSIVE:Dock(BOTTOM)
    INVENTORY.GUI.PASSIVE:SetBackgroundColor(Color(0,0,0,0))
    INVENTORY.GUI.PASSIVE:Add(createContainerV2(10,1,BoxSize/2,0,"Rucksack"))
end


function createContainerV2(x,y,posX,posY,Name,allow)
    local box = vgui.Create("DPanel")
    local container = vgui.Create("DPanel")
    container:SetSize(BoxSize*x, BoxSize*y+ BoxSize/2)
    container:SetPos(posX, posY)
    container:SetBackgroundColor(Color(0,0,0,0))


    local dragContainer = vgui.Create("DPanel",container)
    dragContainer:SetSize(BoxSize*x, BoxSize*y)
    dragContainer:SetName("Container" .. x .. "," .. y .. ", " .. ContainerIndex)
    dragContainer:Dock(BOTTOM)
    dragContainer:DockPadding(2,2,2,2)
    dragContainer.Paint = function(self, w, h)
        surface.SetDrawColor(50, 50, 50, 150)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 255, 255)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end
    
    local Text = vgui.Create("DLabel",container)
    if not Name then
        Name = "Blank"
    end
    Text:SetText(Name)
    SetLabelSize(Text, BoxSize*2/4)
    Text:SetSize(BoxSize*x, BoxSize*y)
    Text:SetPos(0,5)
    Text:Dock(TOP)
    Text:SetContentAlignment(8)

    for i = 1, y do
        for j = 1, x do
            local dropContainer = vgui.Create("DPanel")
            dropContainer:SetSize(BoxSize, BoxSize)
            dropContainer:SetPos((j-1) * BoxSize, (i-1) * BoxSize)
            dropContainer:Receiver("Inventory",DropEventEquipment)
            dropContainer:SetCookieName("Equipment" .. i .. "," .. j .. ", " .. ContainerIndex)
            ContainerIndex = ContainerIndex + 1
            dropContainer:SetCookie("SizeX",x)
            dropContainer:SetCookie("SizeY",y)
            dropContainer:SetCookie("AllowType",allow)

            dropContainer.Paint = function(self, w, h)
                surface.SetDrawColor(0, 0, 0, 0)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(255, 255, 255)
                surface.DrawOutlinedRect(0, 0, w+1, h+1, 1)
            end
            dragContainer:Add(dropContainer)
        end
    end
    return container
end

local function getSizeXY(n)
    local k = math.ceil(math.sqrt(n)) -- current square size
    local m = (k - 1) * (k - 1)        -- last square end
    local p = n - m                   -- position in this layer

    local x, y

    if p <= k then
        -- Top row (left → right)
        x = p
        y = k
    else
        -- Right column (top → bottom)
        x = k
        y = k - (p - k)
    end

    return x, y
end


function CreateDropItem(Name, itemInfo, index)
    local Item = nil
    if(itemInfo.Type == "Armor") then
        Item = vgui.Create("DModelPanel", Item)
        Item.PaintOver = function(self, w, h)
            surface.SetDrawColor(255, 255, 255)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
        end

        Item:SetModel(itemInfo.Model_Route)
        Item:Dock(FILL)
    else 
        Item = vgui.Create("DPanel")
        local r, g, b = HexToRGB(itemInfo.Color)
        Item:SetBackgroundColor(Color(r, g, b,150))
    end
    local Text = vgui.Create("DLabel", Item)

    x,y = getSizeXY(itemInfo.Size)

    Item:SetSize(BoxSize * x, BoxSize * y)
    Item:SetCookieName("Panel" .. #INVENTORY.ITEMS .. ", " .. index)
    Item:SetCookie("isEquipped", "false")
    Item:SetCookie("Type", itemInfo.Type)

    Text:SetText(Name)
    Text:SizeToContents()

    Item:SetName(Name)
    Item:Droppable("Inventory")
    Item:Droppable("Equipment")

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
                itemInfo,
                i
            )
            local x,y = getSizeXY(Size)
            
            for i = 0, INVENTORY.SETTINGS.TABLE.WIDTH * INVENTORY.SETTINGS.TABLE.HEIGHT-1 do
                local inventoryhover = INVENTORY.GUI.PASSIVE:GetChild(0):GetChild(0):GetChild(i)
                if isDropable(inventoryhover, i, x, y, ItemPanel) then
                    inventoryhover:Add(ItemPanel)
                    changeSizes(inventoryhover, x, y, ItemPanel)
                    return
                end
            end
            MsgC(Color(127,0,0),"Couldn't add Item to Inventory:\n")
            PrintTable(itemInfo)
            ItemPanel:Remove()
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
hook.Add("PlayerButtonDown", "OpenInventoryKey", function(ply, key)
    print(key)
    if key == KEY_I then
        if INVENTORY.GUI.MAIN and INVENTORY.GUI.MAIN:IsValid() then
            INVENTORY.GUI.ACTIVE.MODEL:SetModel(LocalPlayer():GetModel())
            INVENTORY.GUI.MAIN:SetVisible(not INVENTORY.GUI.MAIN:IsVisible())
        else
            CreateInventory()
            RequestInventorySync()
        end
    end
end)
