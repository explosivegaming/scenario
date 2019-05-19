--- This file is a breakout from core which forcues on instance management of defines
local Global = require 'utils.global'

local Instances = {
    categorise={},
    data={}
}
Global.register(Instances.data,function(tbl)
    Instances.data = tbl
end)

function Instances.has_categories(name)
    return type(Instances.categorise[name]) == 'function'
end

function Instances.is_registered(name)
    return Instances.categorise[name] ~= nil
end

function Instances.register(name,categorise)
    if _LIFECYCLE ~= _STAGE.control then
        return error('Can only be called during the control stage', 2)
    end

    if Instances.categorise[name] then
        return error('Instances for '..name..' already exist.',2)
    end

    categorise = type(categorise) == 'function' and categorise or true

    Instances.data[name] = {}
    Instances.categorise[name] = categorise

    return name
end

function Instances.add_element(name,element)
    if not Instances.categorise[name] then
        return error('Inavlid name for instance group: '..name,2)
    end

    if Instances.has_categories(name) then
        local category = Instances.categorise[name](element)
        if not Instances.data[name][category] then Instances.data[name][category] = {} end
        table.insert(Instances.data[name][category],element)
    else
        table.insert(Instances.data[name],element)
    end
end

function Instances.get_elements_raw(name,category)
    if not Instances.categorise[name] then
        return error('Inavlid name for instance group: '..name,2)
    end

    if Instances.has_categories(name) then
        return Instances.data[name][category] or {}
    else
        return Instances.data[name]
    end
end

function Instances.get_valid_elements(name,category,callback)
    if not Instances.categorise[name] then
        return error('Inavlid name for instance group: '..name,2)
    end

    category = category or callback
    local elements = Instances.get_elements_raw(name,category)
    local categorise = Instances.has_categories(name)

    for key,element in pairs(elements) do
        if not element or not element.valid then
            elements[key] = nil
        else
            if categorise and callback then callback(element)
            elseif category then category(element) end
        end
    end

    return elements
end
Instances.get_elements = Instances.get_valid_elements
Instances.apply_to_elements = Instances.get_valid_elements

function Instances.unregistered_add_element(name,categorise,element)
    if not Instances.data[name] then Instances.data[name] = {} end
    if type(categorise) == 'function' then
        local category = categorise(element)
        if not Instances.data[name][category] then Instances.data[name][category] = {} end
        table.insert(Instances.data[name][category],element)
    else
        table.insert(Instances.data[name],element)
    end
end

function Instances.unregistered_get_elements(name,category,callback)
    local elements = Instances.data[name]
    if category then
        elements = Instances.data[name][category]
    end

    if not elements then return {} end

    for key,element in pairs(elements) do
        if not element or not element.valid then
            elements[key] = nil
        else
            if callback then callback(element) end
        end
    end

    return elements
end
Instances.unregistered_apply_to_elements = Instances.runtime_get_elements

return Instances