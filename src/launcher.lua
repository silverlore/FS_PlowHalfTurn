local directory = g_currentModDirectory
local modName = g_currentModName

local vehicles = {}
local vehiclesByReplaceType = {}

local function validateVehicleTypes(typeManager)
    print(typeManager.typeName)
    if typeManager.typeName == "vehicle" then
        print("Center plow Extention: started vehicleTypesValidation.")
        PlowHalfTurn.modName = modName
        
        for typeName, typeEntry in pairs(g_vehicleTypeManager:getTypes()) do
            if SpecializationUtil.hasSpecialization(Plow, typeEntry.specializations) and
                not SpecializationUtil.hasSpecialization(PlowHalfTurn, typeEntry.specializations) then
                    typeManager:addSpecialization(typeName, modName .. ".PlowHalfTurn")
            end
        end
    end
end

local function init()
    print("Center plow Extention: started mod.")
    TypeManager.validateTypes = Utils.prependedFunction(TypeManager.validateTypes, validateVehicleTypes)
end

init()