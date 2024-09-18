local addonName, addon = ...
addon.showRatings = false

local function CreateToggleButton()
    local button = CreateFrame("Button", "ShowRatingsButton", PVPQueueFrame, "UIPanelButtonTemplate")
    button:SetSize(120, 22)
    button:SetPoint("BOTTOMLEFT", PVPQueueFrame, "BOTTOMLEFT", 10, 10)  -- Position at bottom left
    button:SetText("Show Ratings")
    button:SetFrameStrata("HIGH")  -- Ensure it's on top of other UI elements
    button:SetScript("OnClick", function()
        addon.showRatings = not addon.showRatings
        button:SetText(addon.showRatings and "Hide Ratings" or "Show Ratings")
        ConquestFrame_Update(ConquestFrame)
    end)
end

-- New function to create the Reload UI button
local function CreateReloadButton()
    local button = CreateFrame("Button", "ReloadUIButton", PVPQueueFrame, "UIPanelButtonTemplate")
    button:SetSize(160, 22)
    button:SetPoint("BOTTOMLEFT", PVPQueueFrame, "BOTTOMLEFT", 10, 35)  -- Position above the Show Ratings button
    button:SetText("Fix Grayed Out Queues")
    button:SetFrameStrata("HIGH")
    button:SetScript("OnClick", function()
        ReloadUI()
    end)
    
    -- Add tooltip
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Reloads UI to fix disabled buttons")
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

local function GetCurrentRating(ratingType)
    local rating = 0
    if ratingType == "ARENA_2v2" then
        rating = GetPersonalRatedInfo(1)
    elseif ratingType == "ARENA_3v3" then
        rating = GetPersonalRatedInfo(2)
    elseif ratingType == "RatedBG" then
        rating = GetPersonalRatedInfo(4)
    elseif ratingType == "RatedSoloShuffle" then
        rating = C_PvP.GetRatingInfo(11).personalRating
    elseif ratingType == "RatedBGBlitz" then
        rating = C_PvP.GetRatingInfo(12).personalRating  -- Assuming RatedBGBlitz is index 12
    end
    return rating
end

local function UpdateRatingDisplay(frame, ratingType)
    if addon.showRatings then
        local rating = GetCurrentRating(ratingType)
        frame.CurrentRating:SetText(rating)
        frame.Tier:Show()
    else
        frame.CurrentRating:SetText("|cFF00FF00TiltShield")
        frame.Tier:Hide()
    end
end

local function updateMe(self)
    UpdateRatingDisplay(self.Arena2v2, "ARENA_2v2")
    UpdateRatingDisplay(self.Arena3v3, "ARENA_3v3")
    UpdateRatingDisplay(self.RatedBG, "RatedBG")
    UpdateRatingDisplay(self.RatedSoloShuffle, "RatedSoloShuffle")
    UpdateRatingDisplay(self.RatedBGBlitz, "RatedBGBlitz")
end

local function hideInspectedRating(self)
    for _, pvpType in ipairs({"Arena2v2", "Arena3v3", "RatedBG", "RatedSoloShuffle", "RatedBGBlitz"}) do
        local frame = InspectPVPFrame[pvpType]
        if frame then
            frame.Rating:SetText(addon.showRatings and frame.Rating.regularText or "?")
            frame.Record:SetText(addon.showRatings and frame.Record.regularText or "? - ?")
        end
    end
end

local function hideTooltip(self) 
    if not addon.showRatings then
        GameTooltip:Hide()
        ConquestTooltip:Hide()
    end
end

local function hideTier()
    if not addon.showRatings then
        PVPQueueFrame.HonorInset.RatedPanel.Tier:Hide()
    end
end

local function hideTabContainer() 
    if not addon.showRatings then
        PVPMatchResults.content.tabContainer:Hide()
        PVPMatchResults.content.earningsContainer:Hide()
    end
end

local function OnEvent(self, event, isLogin, isReload)
    if isLogin or isReload then
        CreateReloadButton()  -- Create the new Reload UI button
        CreateToggleButton()
        hooksecurefunc("ConquestFrame_Update", updateMe)
        hooksecurefunc(PVPQueueFrame.HonorInset.RatedPanel, "Show", hideTier)
        hooksecurefunc("InspectPVPFrame_Update", hideInspectedRating)
        for _, pvpType in ipairs({"Arena2v2", "Arena3v3", "RatedBG", "RatedSoloShuffle", "RatedBGBlitz"}) do
            local frame = ConquestFrame[pvpType]
            if frame then
                frame:HookScript("OnEnter", hideTooltip)
                frame:HookScript("OnLeave", hideTooltip)
            end
        end
        PVPMatchResults:HookScript("OnShow", hideTabContainer)
    end 
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", OnEvent)