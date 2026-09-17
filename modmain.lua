GLOBAL.setmetatable(env, { __index = function(_, key) return GLOBAL.rawget(GLOBAL, key) end })

local function ConfigKeyForUMSS(name)
    return "block_umss_" .. tostring(name):gsub("[^%w_]", "_")
end

local function GetConfig(name)
    local get_mod_config_data = GLOBAL.rawget(env, "GetModConfigData")
    if type(get_mod_config_data) == "function" then
        return get_mod_config_data(name)
    end
end

local function ShouldBlockUMSS(name)
    if type(name) ~= "string" then
        return false
    end

    local mode = GetConfig("block_mode") or "selected"
    if mode == "off" then
        return false
    end
    if mode == "all_umss" then
        return true
    end

    return GetConfig(ConfigKeyForUMSS(name)) == true
end

AddPrefabPostInit("umss_general", function(inst)
    if GLOBAL.TheWorld == nil or GLOBAL.TheWorld.ismastersim ~= true then
        return
    end

    local old_define_table = inst.DefineTable
    if old_define_table == nil then
        return
    end

    function inst:DefineTable(name, ...)
        if ShouldBlockUMSS(name) then
            self.spawnTable = {}
            self.rotatable = false
            self.tile_centered = false
            self.spawninwater_tiles = false
            self.spawninwater_prefabs = false
            self.SpawnFn = nil
            self.umss_tags = nil
            self.umss_blocked_by_controller = name
            return true
        end

        return old_define_table(self, name, ...)
    end
end)
