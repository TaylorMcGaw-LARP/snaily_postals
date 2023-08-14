--[[
    Sonaran CAD Plugins

    Plugin Name: postals
    Creator: snailyCAD
    Description: Fetches nearest postal from client
]]

-- Toggles Postal Sender

local pluginConfig = Config.GetPluginConfig("postals")
local locationsConfig = Config.GetPluginConfig("locations")

if pluginConfig.enabled and locationsConfig ~= nil then

    local state = GetResourceState(pluginConfig.nearestPostalResourceName)
    local shouldStop = false
    if  state ~= "started" then
        if state == "missing" then
            errorLog(("[postals] The configured postals resource (%s) does not exist. Please check the name."):format(pluginConfig.nearestPostalResourceName))
            shouldStop = true
        elseif state == "stopped" then
            warnLog(("[postals] The postals resource (%s) is not started. Please ensure it's started before clients conntect. This is only a warning. State: %s"):format(pluginConfig.nearestPostalResourceName, state))
        else
            errorLog(("[postals] The configured postals resource (%s) is in a bad state (%s). Please check it."):format(pluginConfig.nearestPostalResourceName, state))
            shouldStop = true
        end
    end
    if shouldStop then
        pluginConfig.enabled = false
        errorLog("Force disabling plugin to prevent client errors.")
        return
    end

    PostalsCache = {}

    RegisterNetEvent("getShouldSendPostal")
    AddEventHandler("getShouldSendPostal", function()
        TriggerClientEvent("getShouldSendPostalResponse", source,true)
    end)

    RegisterNetEvent("cadClientPostal")
    AddEventHandler("cadClientPostal", function(postal)
        PostalsCache[source] = postal
    end)

    AddEventHandler("playerDropped", function(player)
        PostalsCache[player] = nil
    end)

    function getNearestPostal(player)
        return PostalsCache[player]
    end

    exports('cadGetNearestPostal', getNearestPostal)

elseif locationsConfig == nil then
    errorLog("ERROR: Postals plugin is loaded, but required locations plugin is not. This plugin will not function correctly!")
end