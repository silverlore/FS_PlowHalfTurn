PlowHalfTurn = {}

function PlowHalfTurn.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Plow, specializations)
end

function PlowHalfTurn.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", PlowHalfTurn)
end

function PlowHalfTurn.registerOverwrittenFunctions(vehicleType)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "setRotationMax", PlowHalfTurn.setRotationMax)
end

function PlowHalfTurn.registerFunctions(vehicleType)
    SpecializationUtil.registerFunction(vehicleType, "actionHalfTurn", PlowHalfTurn.actionHalfTurn)
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
                insert(self:addPoweredActionEvent(spec.actionEvents, InputAction.PHT_ROTATE_CENTER, self, PlowHalfTurn.actionEventHalfTurn, false, true, false, true, nil))

                for _, actionEventId in ipairs(nonDrawActionEvents) do
                    g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_VERY_LOW)
                    g_inputBinding:setActionEventTextVisibility(actionEventId, false)
                end
            end
        end
    end
end

function PlowHalfTurn.actionEventHalfTurn(self, actionName, inputValue, callbackState, isAnalog)
    local plowSpec = self.spec_plow
    local spec = self["spec_" .. PlowHalfTurn.modName .. ".PlowHalfTurn"]
    if plowSpec.rotationPart.turnAnimation ~= nil then
        if self:getIsPlowRotationAllowed() then
            if spec.centered then
                self:setRotationMax(not plowSpec.rotationMax)
            else
                self:actionHalfTurn(false)
            end
            
        end
    end
end

function PlowHalfTurn:actionHalfTurn(noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(PlowHalfRotationEvent.new(self), nil, nil, self)
        else
            g_client:getServerConnection():sendEvent(PlowHalfRotationEvent.new(self))
        end
    end

    local plowSpec = self.spec_plow
    local spec = self["spec_" .. PlowHalfTurn.modName .. ".PlowHalfTurn"]
    if plowSpec.rotationPart.turnAnimation ~= nil then
        if self:getIsPlowRotationAllowed() then
            spec.centered = true
            self:setRotationCenter()
        end
    end
end

function PlowHalfTurn:setRotationMax(superFunc,rotationMax, noEventSend, turnAnimationTime)
    local plowSpec = self.spec_plow
    local spec = self["spec_" .. PlowHalfTurn.modName .. ".PlowHalfTurn"]
    if plowSpec.rotationPart.turnAnimation ~= nil then
        if self:getIsPlowRotationAllowed() then
            spec.centered = false
        end
    end
    return superFunc(self, rotationMax, noEventSend, turnAnimationTime)
end