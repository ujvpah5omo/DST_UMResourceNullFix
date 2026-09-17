GLOBAL.setmetatable(env, { __index = function(_, key) return GLOBAL.rawget(GLOBAL, key) end })

local UMSS_CODES =
{
    "A_MonkeyOutpost",
    "activebiome_cbts_bb",
    "activebiome_cbts_ss",
    "activebiome_test_bb",
    "activebiome_test_rr",
    "activebiome_test_ss",
    "ancientwalrusTable",
    "B_MonkeyOutpost",
    "badfarmerTable",
    "baseFrag_rattyStorage",
    "baseFrag_smellyKitchen",
    "demoTable",
    "dudu DUN DUN",
    "failedFisherman",
    "fooltrap1Table",
    "funFair",
    "funniPortal",
    "grassTrap",
    "Guardian Of Nothing",
    "impactfulDiscovery",
    "inactivebiome_cbts_1",
    "inactivebiome_cbts_2",
    "inactivebiome_cbts_3",
    "inactivebiome_test",
    "LazyBase",
    "MAGMASPLOTCH1",
    "MAGMASPLOTCH2",
    "MAGMASPLOTCH3",
    "MAGMASPLOTCH4",
    "megabaseruins_centerpiece",
    "megabaseruins_intersection",
    "megabaseruins_road",
    "moonFrag",
    "moonOil",
    "moxTable",
    "returnedTable273",
    "scorpionCenter1",
    "scorpionOutskirts1",
    "scorpionOutskirts2",
    "scorpionOutskirts3",
    "scorpionOutskirts4",
    "singlefather",
    "sos",
    "startPortal",
    "sunkenboat",
    "sussyTable",
    "swamplake",
    "testTable",
    "testTable2",
    "testTable3",
    "testTable4",
    "tridentTrap",
    "walterifgood",
    "wixie_puzzle",
}

local function ConfigKeyForUMSS(name)
    return "block_umss_" .. tostring(name):gsub("[^%w_]", "_")
end

local function GetConfig(name)
    if GLOBAL.GetModConfigData == nil then
        return nil
    end

    return GLOBAL.GetModConfigData(name)
end

local function GetBlockMode()
    return GetConfig("block_mode") or "selected"
end

local function ShouldBlockUMSS(name)
    if type(name) ~= "string" then
        return false
    end

    local mode = GetBlockMode()
    if mode == "off" then
        return false
    end
    if mode == "all_umss" then
        return true
    end

    return GetConfig(ConfigKeyForUMSS(name)) == true
end

local function RemoveUMSSChoice(table_ref, name)
    if type(table_ref) ~= "table" then
        return
    end

    table_ref[name] = nil
    table_ref[name:gsub("%s+", "_")] = nil
end

local function RemoveFromWeightedTables(inst, name)
    RemoveUMSSChoice(inst.DecidTable, name)
    RemoveUMSSChoice(inst.WixieTable, name)
    RemoveUMSSChoice(inst.DesertTable, name)
    RemoveUMSSChoice(inst.MarshTable, name)
    RemoveUMSSChoice(inst.HoodedTable, name)
    RemoveUMSSChoice(inst.DarkForestTable, name)
    RemoveUMSSChoice(inst.RockyTable, name)
    RemoveUMSSChoice(inst.SavannaTable, name)
    RemoveUMSSChoice(inst.MosaicTable, name)
    RemoveUMSSChoice(inst.GeneralTable, name)
    RemoveUMSSChoice(inst.OceanTable, name)
end

local function StripBlockedChoices(inst)
    if inst == nil then
        return
    end

    local mode = GetBlockMode()
    if mode == "off" then
        return
    end
    if mode == "all_umss" then
        inst.DecidTable = {}
        inst.WixieTable = {}
        inst.DesertTable = {}
        inst.MarshTable = {}
        inst.HoodedTable = {}
        inst.DarkForestTable = {}
        inst.RockyTable = {}
        inst.SavannaTable = {}
        inst.MosaicTable = {}
        inst.GeneralTable = {}
        inst.OceanTable = {}
        inst:Remove()
        return
    end

    for _, name in ipairs(UMSS_CODES) do
        if ShouldBlockUMSS(name) then
            RemoveFromWeightedTables(inst, name)
        end
    end
end

AddPrefabPostInit("ums_biometable", function(inst)
    if GLOBAL.TheWorld == nil or GLOBAL.TheWorld.ismastersim ~= true then
        return
    end

    StripBlockedChoices(inst)
end)

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
            self.spawnTable = nil
            self.umss_blocked_by_controller = name
            self:DoTaskInTime(0, self.Remove)
            return false
        end

        return old_define_table(self, name, ...)
    end
end)
