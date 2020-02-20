local ContextTooltip = stateMainForm:GetChildUnchecked("ContextTooltip", false)
local Tooltip = ContextTooltip:GetChildUnchecked("Tooltip", false)
local Container = Tooltip:GetChildUnchecked("Container", false)
Container:SetOnShowNotification(true)

local LotteryDescText = mainForm:GetChildChecked( "Text", false )

function FindItems(params)
	local elements = params.widget:GetElementCount()
	LotteryDescText:Show(false)
	params.widget:AddChild(LotteryDescText)
	if (elements ~= 6) and (elements ~= 7) then return false end
	local elementname = params.widget:At(0) 
	local elementdesc1 = params.widget:At(1)
	local elementdesc2 = params.widget:At(3) 
	if (common.GetApiType(elementname) ~= "TextViewSafe") then return false end
	if (common.GetApiType(elementdesc1) ~= "TextViewSafe") then return false end
	if elements == 7 and userMods.FromWString(common.ExtractWStringFromValuedText(params.widget:At(1):GetValuedText())):find("при появлении в сумке") then
	local available = CheckPetInBag(userMods.FromWString(common.ExtractWStringFromValuedText(elementname:GetValuedText())))
		LotteryDescText:Show(true)
		if available then
		LotteryDescText:SetVal("name", GTL("Available"))
		LotteryDescText:SetClassVal("class", "tip_green")
		else
		LotteryDescText:SetVal("name", GTL("Not available"))
		LotteryDescText:SetClassVal("class", "tip_red")
		end
	end
	if elements == 6 and LotteryBoxes[userMods.FromWString(common.ExtractWStringFromValuedText(elementname:GetValuedText()))]then
	local available, costume = CheckCardCostume(userMods.FromWString(common.ExtractWStringFromValuedText(elementname:GetValuedText())))
		if costume then 
		LotteryDescText:SetVal("name", GTL("Inside: ")..costume)
		end
		LotteryDescText:Show(true)
		if available then
		LotteryDescText:SetClassVal("class", "tip_green")
		else
		LotteryDescText:SetClassVal("class", "tip_red")
		end
	end
	if (common.GetApiType(elementdesc2) ~= "TextViewSafe") then return false end
	if elements == 6 and userMods.FromWString(common.ExtractWStringFromValuedText(params.widget:At(3):GetValuedText())):find("Святое оружие") then
	local available = CheckHolyWeaponInBag(userMods.FromWString(common.ExtractWStringFromValuedText(elementname:GetValuedText())))
		LotteryDescText:Show(true)
		if available then
		LotteryDescText:SetVal("name", GTL("Available"))
		LotteryDescText:SetClassVal("class", "tip_green")
		else
		LotteryDescText:SetVal("name", GTL("Not available"))
		LotteryDescText:SetClassVal("class", "tip_red")
		end
	end
	return true
end

function CheckHolyWeaponInBag(name)
local list = poweredLSWeaponsLib.GetItems()
for k, v in pairs(list) do
	if userMods.FromWString(itemLib.GetName(v.item)) == LotteryWapons[GTL(name)] then
			if poweredLSWeaponsLib.IsItemInPoweredContainer(v.item) then
				return true
				else
				return false
			end
		end
	end
end

function CheckPetInBag(name)
local categories = checkroomLib.GetCategories()
for k, v in pairs(categories) do
	if userMods.FromWString(categories[k]:GetInfo().name) == GTL("Pets") then
		local collections = checkroomLib.GetCollections(v)
			for kk, vv in pairs(collections) do
				if userMods.FromWString(collections[kk]:GetInfo().name) == GTL("Rare Pets") then
					local items = checkroomLib.GetItems(vv)
						for _, vvv in pairs(items) do
						local itemInfo = itemLib.GetItemInfo(vvv)
						if userMods.FromWString(itemInfo.name) == GTL(name) then
							if  checkroomLib.IsItemInCheckroom( itemInfo.id ) then
							return true
							else
							return false
							end
						end
					end
				end
			end
		end 
	end
end

function CheckCardCostume(name)
local categories = checkroomLib.GetCategories()
for k, v in pairs(categories) do
	if userMods.FromWString(categories[k]:GetInfo().name) == GTL("Prophetic Card") then
		local collections = checkroomLib.GetCollections(v)
			for kk, vv in pairs(collections) do
				if userMods.FromWString(collections[kk]:GetInfo().name) == GTL("Unique Costumes") then
					local items = checkroomLib.GetItems(vv)
						for _, vvv in pairs(items) do
						local itemInfo = itemLib.GetItemInfo(vvv)
						if userMods.FromWString(itemInfo.name) == LotteryBoxes[GTL(name)]						then
							if  checkroomLib.IsItemInCheckroom( itemInfo.id ) then
							return true, LotteryBoxes[GTL(name)]
							else
							return false, LotteryBoxes[GTL(name)]
							end
						end
					end
				end
			end
		end 
	end
end

function onWidgetShowChanged(params)
if (params.addonName ~= "ContextTooltip") then return end
if (common.GetApiType(params.widget) ~= "ScrollableContainerSafe") then return end
if (params.widget:GetName() ~= "Container") then return end
local wtparent = params.widget:GetParent()
if (not wtparent) or (wtparent:GetName() ~= "Tooltip") then return end
wtparent = wtparent:GetParent()
if (not wtparent) or (wtparent:GetName() ~= "ContextTooltip") then return end
if FindItems(params) then return end
end 

function Init()
	common.RegisterEventHandler( onWidgetShowChanged, "EVENT_WIDGET_SHOW_CHANGED")
end

if (avatar.IsExist()) then Init()
else common.RegisterEventHandler(Init, "EVENT_AVATAR_CREATED")	
end