PlowHalfTurn = {}

PlowHalfTurn.STATE_RIGHT = 1
PlowHalfTurn.STATE_CENTER = 2
PlowHalfTurn.STATE_LEFT = 3

function PlowHalfTurn.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Plow, specializations)
end

function PlowHalfTurn.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", PlowHalfTurn)
end

function PlowHalfTurn.registerFunctions(vehicleType)
    SpecializationUtil.registerFunction(vehicleType, "actionHalfTurn", PlowHalfTurn.actionHalfTurn)
end

function PlowHalfTurn.registerOverwrittenFunctions(vehicleType)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "setRotationMax", PlowHalfTurn.setRotationMax)
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
                insert(self:addPoweredActionEvent(spec.actionEvents, InputAction.PHT_ROTATE_RIGHT, self, PlowHalfTurn.actionEventHalfTurn, false, true, false, true, nil))
                insert(self:addPoweredActionEvent(spec.actionEvents, InputAction.PHT_ROTATE_CENTER, self, PlowHalfTurn.actionEventHalfTurn, false, true, false, true, nil))
                insert(self:addPoweredActionEvent(spec.actionEvents, InputAction.PHT_ROTATE_LEFT, self, PlowHalfTurn.actionEventHalfTurn, false, true, false, true, nil))

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
    if plowSpec.rotationPart.turnAnimation ~= nil then
        if self:getIsPlowRotationAllowed() then
            if actionName == InputAction.PHT_ROTATE_RIGHT then
                self:actionHalfTurn(PlowHalfTurn.STATE_RIGHT, false)
            elseif actionName == InputAction.PHT_ROTATE_CENTER then
                self:actionHalfTurn(PlowHalfTurn.STATE_CENTER, false)
            elseif actionName == InputAction.PHT_ROTATE_LEFT then
                self:actionHalfTurn(PlowHalfTurn.STATE_LEFT, false)
            end
        end
    end
end

function PlowHalfTurn:actionHalfTurn(targetState, noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(PlowHalfRotationEvent.new(self, targetState), nil, nil, self)
        else
            g_client:getServerConnection():sendEvent(PlowHalfRotationEvent.new(self, targetState))
        end
    end

    local plowSpec = self.spec_plow
    if plowSpec.rotationPart.turnAnimation ~= nil then
        if self:getIsPlowRotationAllowed() then
            local animTime = self:getAnimationTime(plowSpec.rotationPart.turnAnimation)
            local animSpeed = self:getAnimationSpeed(plowSpec.rotationPart.turnAnimation)
            local animCenter = plowSpec.ai.centerPosition
            if targetState == PlowHalfTurn.STATE_RIGHT then
                if animTime > 0 then
                    plowSpec.rotationMax = false
                    self:setAnimationStopTime(plowSpec.rotationPart.turnAnimation, 0)
                    self:playAnimation(plowSpec.rotationPart.turnAnimation, -1, animTime, true)
                end
            elseif targetState == PlowHalfTurn.STATE_CENTER then
                self:setAnimationStopTime(plowSpec.rotationPart.turnAnimation, plowSpec.ai.centerPosition)
                if animTime < animCenter then
                    plowSpec.rotationMax = false
                    self:playAnimation(plowSpec.rotationPart.turnAnimation, 1, animTime, true)
                elseif animTime > animCenter then
                    plowSpec.rotationMax = true
                    self:playAnimation(plowSpec.rotationPart.turnAnimation, -1, animTime, true)
                end
            elseif targetState == PlowHalfTurn.STATE_LEFT then
                if animTime < 1 then
                    plowSpec.rotationMax = true
                    self:setAnimationStopTime(plowSpec.rotationPart.turnAnimation, 1)
                    self:playAnimation(plowSpec.rotationPart.turnAnimation, 1, animTime, true)
                end
            end
        end
    end
end

function PlowHalfTurn:setRotationMax(superFunc,rotationMax, noEventSend, turnAnimationTime)
    local plowSpec = self.spec_plow
    if plowSpec.rotationPart.turnAnimation ~= nil then
        self:stopAnimation(plowSpec.rotationPart.turnAnimation)
    end
    return superFunc(self, rotationMax, noEventSend, turnAnimationTime)
end