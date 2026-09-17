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

local function ApplyForcedUMSS(inst)
    for _, name in ipairs(FORCE_TABLES.LAND) do
        if ShouldForceUMSS(name) then
            AddForcedChoice(inst.DecidTable, name)
            AddForcedChoice(inst.WixieTable, name)
            AddForcedChoice(inst.DesertTable, name)
            AddForcedChoice(inst.MarshTable, name)
            AddForcedChoice(inst.HoodedTable, name)
            AddForcedChoice(inst.DarkForestTable, name)
            AddForcedChoice(inst.RockyTable, name)
            AddForcedChoice(inst.SavannaTable, name)
            AddForcedChoice(inst.MosaicTable, name)
            AddForcedChoice(inst.GeneralTable, name)
        end
    end

    for _, name in ipairs(FORCE_TABLES.OCEAN) do
        if ShouldForceUMSS(name) then
            AddForcedChoice(inst.OceanTable, name)
        end
    end

    for _, name in ipairs(FORCE_TABLES.CAVE) do
        if ShouldForceUMSS(name) then
            AddForcedChoice(inst.GeneralTable, name)
        end
    end

    for _, name in ipairs(FORCE_TABLES.SPECIAL) do
        if ShouldForceUMSS(name) then
            AddForcedChoice(inst.GeneralTable, name)
        end
    end
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

AddPrefabPostInit("ums_biometable", function(inst)
    if GLOBAL.TheWorld == nil or GLOBAL.TheWorld.ismastersim ~= true then
        return
    end

    ApplyForcedUMSS(inst)
end)
