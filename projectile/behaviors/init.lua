---@param o projectile
---@param args projectile.options
return function(o, args)
    require ".appearance"(o, args)
    require ".placement"(o, args)
    require ".collision"(o, args)
end
