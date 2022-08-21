PlowHalfTurn = {}

function PlowHalfTurn.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Plow, specializations)
end

function PlowHalfTurn.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", PlowHalfTurn)
end

function PlowHalfTurn.registerOverwrittenFunctions(vehicleType)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "setRotationMax",                 PlowHalfTurn.setRotationMax)
end

function PlowHalfTurn:onLoad(savegame)
    local spec = self["spec_" .. PlowHalfTurn.modName .. ".PlowHalfTurn"]

    spec.centered = false;

end

function PlowHalfTurn:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection)
    if self.isClient then
        local spec = self["spec_" .. PlowHalfTurn.modName .. ".PlowHalfTurn"]
        
        self:clearActionEventsTable(spec.actionEvents)

        if isActiveForInputIgnoreSelection then
            if not self:getIsAIActive() then 
                local nonDrawActionEvents = {}
                local function insert(_, actionEventId)
                    table.insert(nonDrawActionEvents, actionEventId)
                end
                insert(self:addPoweredActionEvent(spec.actionEvents, InputAction.PHT_ROTATE_CENTER, self, PlowHalfTurn.actionHalfTurn, false, true, false, true, nil))

                for _, actionEventId in ipairs(nonDrawActionEvents) do
                    g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_VERY_LOW)
                    g_inputBinding:setActionEventTextVisibility(actionEventId, false)
                end
            end
        end
    end
end

function PlowHalfTurn:actionHalfTurn()
    local plowSpec = self.spec_plow
    local spec = self["spec_" .. PlowHalfTurn.modName .. ".PlowHalfTurn"]
    if plowSpec.rotationPart.turnAnimation ~= nil then
        if self:getIsPlowRotationAllowed() then
            if spec.centered then
                print("PHT: turning to side")
                self:setRotationMax(not plowSpec.rotationMax)
            else
                print("PHT: turning to center")
                spec.centered = true
                self:setRotationCenter()
            end
        end
    end
end

function PlowHalfTurn:setRotationMax(superFunc,rotationMax, noEventSend, turnAnimationTime)
    local plowSpec = self.spec_plow
    local spec = self["spec_" .. PlowHalfTurn.modName .. ".PlowHalfTurn"]
    if plowSpec.rotationPart.turnAnimation ~= nil then
        if self:getIsPlowRotationAllowed() then
            print("PHT: complete turn")
            spec.centered = false
        end
    end
    return superFunc(self, rotationMax, noEventSend, turnAnimationTime)
end