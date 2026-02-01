
scrw, scrh = ScrW(), ScrH()
winw, winh = scrw * 0.6, scrh * 0.5
InvX, InvY = 10,1
BoxSize = (winw * 0.7 / 10) - 10
local ContainerIndex = 0
local ItemIndex = 0
function HexToRGB(hex)
    hex = hex:gsub("#", "")

    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)

    return r, g, b
end

function SetLabelSize(label, size)
    local name = "LabelFont_" .. size

    surface.CreateFont(name, {
        font = "Roboto",
        size = size,
        weight = 500
    })

    label:SetFont(name)
    label:SizeToContents()
    label:SetSize(
        label:GetWide() + 8,
        label:GetTall() + 8
    )
end



function changeSizes(toPut, x, y, PickedUpItem)
    local i = 0

    local width = PickedUpItem:GetParent():GetCookie("SizeX")
    local height = PickedUpItem:GetParent():GetCookie("SizeY")
    local allDropIns = PickedUpItem:GetParent():GetParent():GetChildren()
    print(PickedUpItem:GetParent():GetParent():GetName() .. " has " .. #allDropIns .. " dropins.")
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
    
    if toPut == nil then return end
    local width = toPut:GetCookie("SizeX")
    local height = toPut:GetCookie("SizeY")

    if toPut then
        local parent = toPut:GetParent()
        local children = parent:GetChildren()
        local i = 0

        for k, v in pairs(children) do
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

function createContainerV2(x,y,posX,posY,Name,options)
    -- options = {["allow"]=string, ["infinite"]=bool, ["equipment"]=bool, ["isBin"]=bool}
    local allow = nil
    local infinite = "false"
    local isEquipment = false
    local isBin = false
    if options then
        allow = options["allow"]
        infinite = tostring(options["infinite"] or false)
        isEquipment = options["equipment"]
        isBin = options["isBin"]
    end

    local box = vgui.Create("DPanel")
    local container = vgui.Create("DPanel")
    container:SetSize(BoxSize*x, BoxSize*y+ BoxSize/2)
    container:SetPos(posX, posY)
    container:SetBackgroundColor(Color(0,0,0,0))
    container:SetName(Name)


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
                if isEquipment then
                    dropContainer:Receiver("Equipment",DropEventEquipment)
                else
                    dropContainer:Receiver("Inventory",DropEventInventory)
                end
            dropContainer:SetCookieName("Equipment" .. i .. "," .. j .. ", " .. ContainerIndex)
            dropContainer:SetName("Equipment" .. i .. "," .. j .. ", " .. ContainerIndex)
            ContainerIndex = ContainerIndex + 1
            dropContainer:SetCookie("SizeX",x)
            dropContainer:SetCookie("SizeY",y)
            dropContainer:SetCookie("AllowType",allow)
            dropContainer:SetCookie("Infinite",infinite)
            dropContainer:SetCookie("isBin",tostring(isBin))

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

function getSizeXY(n)
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


function CreateDropItem(Name, itemInfo)
    local Item = nil
    PrintTable(itemInfo)
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
    Item:SetCookieName("Panel" .. #INVENTORY.ITEMS .. ", " .. ItemIndex)
    ItemIndex = ItemIndex+1
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
        highlightAcceptingType(itemInfo.Type)
        print("Dragging " .. "Type " .. itemInfo.Type)
    end

    function Item:OnMouseReleased(mousecode)
        self:MouseCapture(false)
        self:DragMouseRelease(mousecode)
        highlightAcceptingType(nil)
        print("Stopped dragging " .. "Type " .. itemInfo.Type)
    end

    return Item
end

function reload()
    INVENTORY.GUI.ALL:Remove()
    INVENTORY.ITEMS = {}
    CreateInventory()
    RequestInventorySync() 
    INVENTORY.GUI.MAIN:SetVisible(true)
end

function highlightAcceptingType(allowType)
    print("Highlighting panels for type: " .. tostring(allowType))
    -- if allowType is nil, reset all highlights
    
    for _, container in ipairs(INVENTORY.GUI.INVENTORY:GetChildren()) do
        for _, dropPanel in ipairs(container:GetChild(0):GetChildren()) do
            local panelAllowType = dropPanel:GetCookie("AllowType")
            if allowType == nil then
                -- Reset highlight
                dropPanel:GetParent().PaintOver = function(self, w, h)
                    surface.SetDrawColor(0, 0, 0, 0)
                    surface.DrawRect(0, 0, w, h)
                end
                dropPanel.PaintOver = function(self, w, h)
                    surface.SetDrawColor(255, 255, 255)
                    surface.DrawOutlinedRect(1, 1, w+1, h+1, 1)
                end
            else
                if panelAllowType == allowType or panelAllowType == nil then
                    dropPanel:GetParent().PaintOver = function(self, w, h)
                        surface.SetDrawColor(0, 255, 42)
                        surface.DrawOutlinedRect(-1, -1, w+1, h+1, 3)
                    end
                    dropPanel.PaintOver = function(self, w, h)
                        surface.SetDrawColor(255, 255, 255)
                        surface.DrawOutlinedRect(1, 1, w+1, h+1, 1)
                    end
                else
                    dropPanel:GetParent().PaintOver = function(self, w, h)
                        surface.SetDrawColor(255, 0, 0)
                        surface.DrawOutlinedRect(-1, -1, w+1, h+1, 3)
                    end
                    dropPanel.PaintOver = function(self, w, h)
                        surface.SetDrawColor(255, 255, 255)
                        surface.DrawOutlinedRect(1, 1, w+1, h+1, 1)
                    end
                end
            end
        end
    end
end

local function switchActiveInventoryPanel(panelName)
    INVENTORY.GUI.MAIN:SetPos(scrw/2-winw/2,0)
    if WEAPON_CHEST.GUI.MAIN and WEAPON_CHEST.GUI.MAIN:IsValid() then
        WEAPON_CHEST.GUI.MAIN:Remove()
    end

    if panelName == "Waffenkiste" then
        CreateWeaponChest()
    elseif panelName == "Kleiderschrank" then
        CreateWardrobe()
    elseif panelName == "Spieler Lager" then
        CreatePlayerStorage()
    elseif panelName == "Fraktions Lager" then
        CreateFractionStorage()
    end
end

local function createButtonPanel(text,parent)
    local button = vgui.Create("DButton", parent)
    button:SetText(text)
    button:SetTextColor(Color(255,255,255))
    button:Dock(LEFT)

    SetLabelSize(button, BoxSize*2/4)
    button.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
        surface.SetDrawColor(255, 255, 255)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end
    button.DoClick = function()
        switchActiveInventoryPanel(text)
    end
    return button
end
function getActiveInventoryPanel(activePanel, parent)

    local panel = vgui.Create("DPanel", parent)
    panel:SetBackgroundColor(Color(0,0,0,0))

    -- Container for buttons
    local buttonHolder = vgui.Create("DPanel", panel)
    buttonHolder:SetBackgroundColor(Color(0,0,0,0))
    buttonHolder:Dock(TOP)
    buttonHolder:SetTall(BoxSize)
    buttonHolder.PerformLayout = function(self)
        local w = 0

        for _, child in ipairs(self:GetChildren()) do
            w = w + child:GetWide()
        end

        self:SetWide(w)

        -- Center horizontally
        self:CenterHorizontal()
    end
    local weaponPanel = createButtonPanel("Waffenkiste", buttonHolder)
    local wardrobePanel = createButtonPanel("Kleiderschrank", buttonHolder)
    local playerStoragePanel = createButtonPanel("Spieler Lager", buttonHolder)
    local fractionStoragePanel = createButtonPanel("Fraktions Lager", buttonHolder)


    if activePanel == "WeaponChest" then
        weaponPanel:SetDisabled(true)
        weaponPanel:SetTextColor(Color(150,150,150))

        weaponPanel.Paint = function(self, w, h)
            surface.SetDrawColor(35, 35, 35)
            surface.DrawOutlinedRect(0, 0, w, h, 4)
        end
    elseif activePanel == "Wardrobe" then
        wardrobePanel:SetDisabled(true)
    elseif activePanel == "PlayerStorage" then
        playerStoragePanel:SetDisabled(true)
    elseif activePanel == "FractionStorage" then
        fractionStoragePanel:SetDisabled(true)
    end


    return panel
end




function closeInventory()
    INVENTORY.GUI.MAIN:SetPos(scrw/2-winw/2, scrh/2-winh/2)
    if(WEAPON_CHEST.GUI.MAIN and WEAPON_CHEST.GUI.MAIN:IsValid()) then
        WEAPON_CHEST.GUI.MAIN:Remove()
    end
    INVENTORY.GUI.ALL:SetVisible(false)
end