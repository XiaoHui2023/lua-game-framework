
---@param o unit
---@param args unit.options
return function (o,args)
    require ".appearance"(o,args)
    require ".attribute"(o,args)
    require ".placement"(o,args)
    require ".combat"(o,args)
    require ".skill"(o,args)
    require ".weapon"(o,args)
    require ".target"(o,args)
end
