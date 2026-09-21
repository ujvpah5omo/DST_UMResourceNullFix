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

local function GetUMSSState(name)
    if type(name) ~= "string" then
        return "allow"
    end

    local mode = GetConfig("block_mode") or "selected"
    if mode == "off" then
        return "allow"
    end
    if mode == "all_umss" then
        return "block"
    end

    local value = GetConfig(ConfigKeyForUMSS(name))
    if value == true or value == "block" then
        return "block"
    end
    if value == "force" then
        return "force"
    end

    return "allow"
end

local function ShouldBlockUMSS(name)
    return GetUMSSState(name) == "block"
end

local function ShouldForceUMSS(name)
    return GetUMSSState(name) == "force"
end

local function HasSpawnedUMSS(name)
    if GLOBAL.TheWorld == nil or type(GLOBAL.TheWorld.umsetpieces) ~= "table" then
        return false
    end

    for _, spawned_name in ipairs(GLOBAL.TheWorld.umsetpieces) do
        if spawned_name == name then
            return true
        end
    end

    return false
end

local function ClearUMSSDefinition(inst, name)
    inst.spawnTable = {}
    inst.rotatable = false
    inst.tile_centered = false
    inst.spawninwater_tiles = false
    inst.spawninwater_prefabs = false
    inst.SpawnFn = nil
    inst.umss_tags = nil
    inst.umss_blocked_by_controller = name
    return true
end

local FORCE_WEIGHT = 100000

local FORCE_TABLES = {
    LAND = {
        "baseFrag_rattyStorage",
        "singlefather",
        "megabaseruins_road",
        "moonOil",
        "testTable",
        "testTable2",
        "dudu DUN DUN",
        "Guardian Of Nothing",
        "fooltrap1Table",
        "testTable4",
        "moxTable",
        "grassTrap",
        "scorpionOutskirts1",
        "scorpionOutskirts2",
        "scorpionOutskirts3",
        "scorpionOutskirts4",
        "LazyBase",
        "megabaseruins_centerpiece",
        "funFair",
        "ancientwalrusTable",
        "baseFrag_smellyKitchen",
        "returnedTable273",
        "wixie_puzzle",
        "megabaseruins_intersection",
        "testTable3",
        "sos",
        "walterifgood",
        "scorpionCenter1",
        "badfarmerTable",
        "demoTable",
        "moonFrag",
        "sussyTable",
        "impactfulDiscovery",
    },
    OCEAN = {
        "failedFisherman",
        "inactivebiome_test",
        "activebiome_cbts_ss",
        "activebiome_cbts_bb",
        "activebiome_test_bb",
        "activebiome_test_rr",
        "activebiome_test_ss",
        "swamplake",
        "B_MonkeyOutpost",
        "inactivebiome_cbts_3",
        "inactivebiome_cbts_1",
        "inactivebiome_cbts_2",
        "sunkenboat",
        "tridentTrap",
        "A_MonkeyOutpost",
    },
    CAVE = {
        "MAGMASPLOTCH1",
        "MAGMASPLOTCH2",
        "MAGMASPLOTCH3",
        "MAGMASPLOTCH4",
    },
    SPECIAL = {
        "startPortal",
        "funniPortal",
    },
}

local function AddForcedChoice(weighted_table, name)
    if type(weighted_table) == "table" then
        weighted_table[name] = FORCE_WEIGHT
    end
end

local function GetForcedChoices(...)
    local forced = {}

    for i = 1, select("#", ...) do
        local names = select(i, ...)
        for _, name in ipairs(names) do
            if ShouldForceUMSS(name) and not HasSpawnedUMSS(name) then
                AddForcedChoice(forced, name)
            end
        end
    end

    return next(forced) ~= nil and forced or nil
end

local function ReplaceIfForced(inst, table_name, forced)
    if forced ~= nil then
        inst[table_name] = forced
    end
end

local function ApplyForcedUMSS(inst)
    local forced_land = GetForcedChoices(FORCE_TABLES.LAND)
    ReplaceIfForced(inst, "DecidTable", forced_land)
    ReplaceIfForced(inst, "WixieTable", forced_land)
    ReplaceIfForced(inst, "DesertTable", forced_land)
    ReplaceIfForced(inst, "MarshTable", forced_land)
    ReplaceIfForced(inst, "HoodedTable", forced_land)
    ReplaceIfForced(inst, "DarkForestTable", forced_land)
    ReplaceIfForced(inst, "RockyTable", forced_land)
    ReplaceIfForced(inst, "SavannaTable", forced_land)
    ReplaceIfForced(inst, "MosaicTable", forced_land)
    ReplaceIfForced(inst, "GeneralTable", forced_land)

    ReplaceIfForced(inst, "OceanTable", GetForcedChoices(FORCE_TABLES.OCEAN))

    local forced_general = GetForcedChoices(FORCE_TABLES.CAVE, FORCE_TABLES.SPECIAL)
    ReplaceIfForced(inst, "GeneralTable", forced_general)
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
            return ClearUMSSDefinition(self, name)
        end

        if ShouldForceUMSS(name) and HasSpawnedUMSS(name) then
            return ClearUMSSDefinition(self, name)
        end

        return old_define_table(self, name, ...)
    end
end)

AddPrefabPostInit("ums_biometable", function(inst)
    if GLOBAL.TheWorld == nil or GLOBAL.TheWorld.ismastersim ~= true then
        return
    end

    ApplyForcedUMSS(inst)
end)
