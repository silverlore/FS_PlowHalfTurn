---Event for plow rotation

PlowHalfRotationEvent = {}
PlowHalfRotationEvent_mt = Class(PlowHalfRotationEvent, Event)

InitEventClass(PlowHalfRotationEvent, "PlowHalfRotationEvent")

---Create instance of Event class
-- @return table self instance of class event
function PlowHalfRotationEvent.emptyNew()
    local self = Event.new(PlowHalfRotationEvent_mt)
    return self
end


---Create new instance of event
-- @param table object object
-- @param boolean rotationMax rotation max
function PlowHalfRotationEvent.new(object)
    local self = PlowHalfRotationEvent.emptyNew()
    self.object = object
    return self
end


---Called on client side on join
-- @param integer streamId streamId
-- @param integer connection connection
function PlowHalfRotationEvent:readStream(streamId, connection)
    self.object = NetworkUtil.readNodeObject(streamId)
    self:run(connection)
end


---Called on server side on join
-- @param integer streamId streamId
-- @param integer connection connection
function PlowHalfRotationEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.object)
end


---Run action on receiving side
-- @param integer connection connection
function PlowHalfRotationEvent:run(connection)
    if self.object ~= nil and self.object:getIsSynchronized() then
        self.object:actionHalfTurn(true)
    end

    if not connection:getIsServer() then
        g_server:broadcastEvent(PlowHalfRotationEvent.new(self.object), nil, connection, self.object)
    end
end
