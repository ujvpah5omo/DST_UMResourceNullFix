local is_chinese = locale == "zh" or locale == "zhr" or locale == "zht"

local function T(en, zh)
    return is_chinese and zh or en
end

name = T("UM Resource Null Fix", "永不妥协无资源设定彩蛋修正补丁")
author = "Codex"
version = "1.2.4"
forumthread = "https://steamcommunity.com/sharedfiles/filedetails/?id=3803245200"

api_version = 10
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false

all_clients_require_mod = false
client_only_mod = false
server_only_mod = true
server_filter_tags = {
    "um",
    "uncompromising",
    "umss",
    "setpiece",
    "encounter",
    "永不妥协",
    "奇遇",
}
icon_atlas = ""
icon = ""

description = T([[
Server-side patch for controlling UMSS encounters from Uncompromising Mode.

These entries come from Uncompromising Mode's scripts/umss_tables.lua. The source code shown in each option is also the name used by c_um_umss("code"). UMSS encounters are not vanilla boons, so setting the vanilla world "boons" option to never does not stop these UM setpieces.

You can block every UMSS at once, turn the patch off, or configure each UMSS entry separately. Each entry supports Allow, Block, and Force Candidate. The default only blocks moonFrag and leaves the rest unchanged.

Blocked UMSS entries run through an empty spawn path to avoid breaking UM's own spawn/save flow. Force Candidate makes the matching UMSS category prefer forced entries that have not spawned yet; for example, forcing tridentTrap makes ocean UMSS generation prefer tridentTrap. It affects new world generation and does not add encounters to existing worlds.
]], [[
服务器端补丁，用来控制永不妥协 UM 自己的 UMSS 奇遇。

这些代码来自永不妥协 scripts/umss_tables.lua，控制台 c_um_umss("代码") 也是按这里的 name 查找。UMSS 不是原版世界设置里的 boons；把原版“奇遇”设为 never 不能阻止这些 UMSS setpiece。

配置里可以一键拦截全部 UMSS，也可以关闭补丁，或逐项选择。每个 UMSS 都支持允许、拦截、强制候选三种状态。默认只拦截 moonFrag，其他保持允许。

被拦截的 UMSS 会走空生成流程，避免破坏永不妥协自己的生成/保存链。强制候选会让对应类别优先只从尚未生成过的强制 UMSS 中抽取；例如强制三叉戟陷阱后，海洋 UMSS 触发时会优先抽到 tridentTrap。它影响新世界生成，不会在旧世界里凭空补刷。
]])

local UMSS_OPTIONS =
{
    {
        description = T("Allow", "允许"),
        data = false,
        hover = T(
            "Use Uncompromising Mode's original behavior for this UMSS.",
            "按永不妥协原版规则处理该 UMSS。"
        ),
    },
    {
        description = T("Block", "拦截"),
        data = true,
        hover = T(
            "Prevent this UMSS from spawning; world generation and c_um_umss calls use an empty spawn.",
            "阻止该 UMSS 生成；世界生成和 c_um_umss 手动调出都会变为空生成。"
        ),
    },
    {
        description = T("Force Candidate", "强制候选"),
        data = "force",
        hover = T(
            "Prefer this entry when its UMSS category rolls and it has not spawned yet. Affects new world generation only.",
            "对应类别优先抽尚未生成的强制项；影响新世界生成，不会在旧世界里凭空补刷。"
        ),
    },
}

configuration_options =
{
    {
        name = "block_mode",
        label = T("UMSS Mode", "UMSS 总开关"),
        hover = T(
            "Selected list uses the per-UMSS settings below; Block all disables every UMSS from umss_tables.lua; Off leaves UM untouched.",
            "指定列表=按下面每个 UMSS 的处理方式执行；全部拦截=所有 umss_tables.lua 里的 UMSS 都不生成；关闭补丁=不干预。"
        ),
        options =
        {
            {
                description = T("Selected List", "指定列表"),
                data = "selected",
                hover = T(
                    "Use each UMSS entry's Allow, Block, or Force Candidate setting.",
                    "按下面每个 UMSS 的允许、拦截、强制候选设置执行。"
                ),
            },
            {
                description = T("Block All UMSS", "全部 UMSS"),
                data = "all_umss",
                hover = T(
                    "Prevent every UMSS encounter, including world generation and c_um_umss calls.",
                    "所有 UMSS 奇遇都会被阻止，包括世界生成和 c_um_umss 手动调出。"
                ),
            },
            {
                description = T("Off", "关闭补丁"),
                data = "off",
                hover = T(
                    "Do not intercept any UMSS encounter.",
                    "不拦截任何 UMSS。"
                ),
            },
        },
        default = "selected",
    },
}

local UMSS_CONFIGS =
{
    {
        key = "baseFrag_rattyStorage",
        safe_key = "baseFrag_rattyStorage",
        label_en = "Ratty Storage Fragment",
        label_zh = "储物间残片",
        hover_en = "Wood walls, several chests, wardrobes, and uncompromising_rat.",
        hover_zh = "木墙、多个箱子、衣柜和 uncompromising_rat。",
        default = false,
    },
    {
        key = "singlefather",
        safe_key = "singlefather",
        label_en = "Small Camp Skeleton",
        label_zh = "小营地骨架",
        hover_en = "Rot, Eye of Terror minion, rotten giant durian, fire pit, and skeleton.",
        hover_zh = "腐烂食物、恐怖之眼小随从、烂巨型榴莲、火坑和骷髅。",
        default = false,
    },
    {
        key = "megabaseruins_road",
        safe_key = "megabaseruins_road",
        label_en = "Ancient Ruins Road",
        label_zh = "远古遗迹路段",
        hover_en = "A road made from many umdc_tileflag markers, plus a few seeds.",
        hover_zh = "大量 umdc_tileflag 铺出的道路，加少量种子。",
        default = false,
    },
    {
        key = "moonOil",
        safe_key = "moonOil",
        label_en = "Moon Oil Berry Patch",
        label_zh = "月油浆果点",
        hover_en = "Berry bushes, diseasecurebomb, and skeletons.",
        hover_zh = "浆果丛、diseasecurebomb、骷髅。",
        default = false,
    },
    {
        key = "failedFisherman",
        safe_key = "failedFisherman",
        label_en = "Failed Fisherman",
        label_zh = "失败渔夫",
        hover_en = "Boat, anchor, fish box, mast, fishing tackle, and rotten fish.",
        hover_zh = "船、锚、鱼箱、桅杆、钓具和腐烂鱼。",
        default = false,
    },
    {
        key = "testTable",
        safe_key = "testTable",
        label_en = "Test Table",
        label_zh = "测试表",
        hover_en = "Science machine and grass.",
        hover_zh = "科学机器和草。",
        default = false,
    },
    {
        key = "testTable2",
        safe_key = "testTable2",
        label_en = "Test Table 2",
        label_zh = "测试表 2",
        hover_en = "Evergreens and pig houses.",
        hover_zh = "常青树和猪屋。",
        default = false,
    },
    {
        key = "dudu DUN DUN",
        safe_key = "dudu_DUN_DUN",
        label_en = "Moon Potion Easter Egg",
        label_zh = "月亮药水小彩蛋",
        hover_en = "Moon Halloween potion and skeletons.",
        hover_zh = "月亮万圣药水和骷髅。",
        default = false,
    },
    {
        key = "Guardian Of Nothing",
        safe_key = "Guardian_Of_Nothing",
        label_en = "Guardian Of Nothing",
        label_zh = "守护者废墟",
        hover_en = "Stone walls, moon rock walls, moon rocks, and ruins/mosaic turf.",
        hover_zh = "石墙、月岩墙、月岩、遗迹/马赛克地皮。",
        default = false,
    },
    {
        key = "fooltrap1Table",
        safe_key = "fooltrap1Table",
        label_en = "Balloon Reed Trap",
        label_zh = "气球芦苇陷阱",
        hover_en = "Many balloons, tentacles, reeds, and skeletons.",
        hover_zh = "大量气球、触手、芦苇和骷髅。",
        default = false,
    },
    {
        key = "testTable4",
        safe_key = "testTable4",
        label_en = "Test Table 4",
        label_zh = "测试表 4",
        hover_en = "Trees, wood walls/fences, chests, axes, and torches.",
        hover_zh = "树林、木墙/栅栏、箱子、斧头和火把。",
        default = false,
    },
    {
        key = "inactivebiome_test",
        safe_key = "inactivebiome_test",
        label_en = "Inactive Ocean Biome Test",
        label_zh = "海上非活跃生态测试",
        hover_en = "Sea stacks, sludge piles, and searock_ring.",
        hover_zh = "海蚀柱、淤泥堆和 searock_ring。",
        default = false,
    },
    {
        key = "moxTable",
        safe_key = "moxTable",
        label_en = "Mox Easter Egg",
        label_zh = "Mox 小彩蛋",
        hover_en = "Rabbit stew, bunny puff, and top hat.",
        hover_zh = "兔肉炖锅、兔人尾巴和高礼帽。",
        default = false,
    },
    {
        key = "grassTrap",
        safe_key = "grassTrap",
        label_en = "Grass Trap",
        label_zh = "草陷阱",
        hover_en = "Many trapdoorspawner entries hidden among grass tufts.",
        hover_zh = "大量 trapdoorspawner 混在草丛里。",
        default = false,
    },
    {
        key = "scorpionOutskirts1",
        safe_key = "scorpionOutskirts1",
        label_en = "Scorpion Outskirts 1",
        label_zh = "蝎子外围 1",
        hover_en = "Scorpion dens, sand dunes, sandstones, and bug baby rocks.",
        hover_zh = "蝎子洞、沙丘、沙岩、虫婴岩。",
        default = false,
    },
    {
        key = "scorpionOutskirts2",
        safe_key = "scorpionOutskirts2",
        label_en = "Scorpion Outskirts 2",
        label_zh = "蝎子外围 2",
        hover_en = "Scorpion dens, bug baby rocks, sand dunes, and hound bones.",
        hover_zh = "蝎子洞、虫婴岩、沙丘和犬骨。",
        default = false,
    },
    {
        key = "scorpionOutskirts3",
        safe_key = "scorpionOutskirts3",
        label_en = "Scorpion Outskirts 3",
        label_zh = "蝎子外围 3",
        hover_en = "Scorpion dens, sandstones, and bramble bushes.",
        hover_zh = "蝎子洞、沙岩和尖刺灌木。",
        default = false,
    },
    {
        key = "scorpionOutskirts4",
        safe_key = "scorpionOutskirts4",
        label_en = "Scorpion Outskirts 4",
        label_zh = "蝎子外围 4",
        hover_en = "Sandstones, bug baby rocks, and scorpion dens.",
        hover_zh = "沙岩、虫婴岩和蝎子洞。",
        default = false,
    },
    {
        key = "activebiome_cbts_ss",
        safe_key = "activebiome_cbts_ss",
        label_en = "Active Ocean Biome SS",
        label_zh = "海上活跃生态 SS",
        hover_en = "Sea stacks, boat debris, kelpstack, haunted shipwreck, and siren_throne.",
        hover_zh = "海蚀柱、船残骸、kelpstack、幽灵沉船、siren_throne。",
        default = false,
    },
    {
        key = "activebiome_cbts_bb",
        safe_key = "activebiome_cbts_bb",
        label_en = "Active Ocean Biome BB",
        label_zh = "海上活跃生态 BB",
        hover_en = "Bull kelp, mossstack, ocean trees, salt piles, and siren_bird_nest.",
        hover_zh = "牛海带、mossstack、海树、盐堆、siren_bird_nest。",
        default = false,
    },
    {
        key = "activebiome_test_bb",
        safe_key = "activebiome_test_bb",
        label_en = "Active Biome Test BB",
        label_zh = "活跃生态测试 BB",
        hover_en = "Sea stacks, sludge piles, and siren_bird_nest.",
        hover_zh = "海蚀柱、淤泥堆和 siren_bird_nest。",
        default = false,
    },
    {
        key = "activebiome_test_rr",
        safe_key = "activebiome_test_rr",
        label_en = "Active Biome Test RR",
        label_zh = "活跃生态测试 RR",
        hover_en = "Sea stacks, sludge piles, and ocean_speaker.",
        hover_zh = "海蚀柱、淤泥堆和 ocean_speaker。",
        default = false,
    },
    {
        key = "activebiome_test_ss",
        safe_key = "activebiome_test_ss",
        label_en = "Active Biome Test SS",
        label_zh = "活跃生态测试 SS",
        hover_en = "Sea stacks, sludge piles, and siren_throne.",
        hover_zh = "海蚀柱、淤泥堆和 siren_throne。",
        default = false,
    },
    {
        key = "LazyBase",
        safe_key = "LazyBase",
        label_en = "Lazy Base",
        label_zh = "懒人基地",
        hover_en = "Tile flags, fences, wood walls, bee boxes, flowers, and pig king torches.",
        hover_zh = "地皮旗、栅栏、木墙、蜂箱、花和猪王火炬。",
        default = false,
    },
    {
        key = "swamplake",
        safe_key = "swamplake",
        label_en = "Swamp Lake",
        label_zh = "沼泽湖",
        hover_en = "Large umdc_tileflag area, rice, sea vines, boat, and a few ocean resources.",
        hover_zh = "大片 umdc_tileflag、水稻、海藤、船和少量海上资源。",
        default = false,
    },
    {
        key = "B_MonkeyOutpost",
        safe_key = "B_MonkeyOutpost",
        label_en = "Monkey Outpost B",
        label_zh = "猴子哨站 B",
        hover_en = "Grassland outpost with monkey huts, chest, pirate flag, cannon, and pirate boat.",
        hover_zh = "草地哨站、猴屋、宝箱、海盗旗、炮和海盗船。",
        default = false,
    },
    {
        key = "megabaseruins_centerpiece",
        safe_key = "megabaseruins_centerpiece",
        label_en = "Ancient Ruins Centerpiece",
        label_zh = "远古遗迹中心",
        hover_en = "Central structure made from many umdc_tileflag markers.",
        hover_zh = "大量 umdc_tileflag 组成的中心结构。",
        default = false,
    },
    {
        key = "funFair",
        safe_key = "funFair",
        label_en = "Fun Fair Easter Egg",
        label_zh = "游乐场小彩蛋",
        hover_en = "voorhams.",
        hover_zh = "voorhams。",
        default = false,
    },
    {
        key = "startPortal",
        safe_key = "startPortal",
        label_en = "Start Portal Variant",
        label_zh = "出生门变体",
        hover_en = "Portal, flowers, grass, seeds, butterflies, and trapdoor/trapdoorgrass.",
        hover_zh = "传送门、花、草、种子、蝴蝶和 trapdoor/trapdoorgrass。",
        default = false,
    },
    {
        key = "funniPortal",
        safe_key = "funniPortal",
        label_en = "Simple Start Portal Variant",
        label_zh = "简化出生门变体",
        hover_en = "Portal and a few flowers.",
        hover_zh = "传送门和少量花。",
        default = false,
    },
    {
        key = "ancientwalrusTable",
        safe_key = "ancientwalrusTable",
        label_en = "Ancient Walrus Trap",
        label_zh = "远古海象陷阱",
        hover_en = "Old bear traps, blow darts, Hawaiian shirt, seeds, and rot.",
        hover_zh = "旧熊夹、吹箭、夏威夷衬衫、种子和腐烂食物。",
        default = false,
    },
    {
        key = "baseFrag_smellyKitchen",
        safe_key = "baseFrag_smellyKitchen",
        label_en = "Smelly Kitchen Fragment",
        label_zh = "臭厨房残片",
        hover_en = "Rot, potted ferns, crock pots, ice boxes, and drying racks.",
        hover_zh = "腐烂食物、蕨类盆栽、锅、冰箱和晾肉架。",
        default = false,
    },
    {
        key = "returnedTable273",
        safe_key = "returnedTable273",
        label_en = "Empty Table / Placeholder",
        label_zh = "空表 / 占位",
        hover_en = "The source table is empty; likely a placeholder or deprecated UMSS.",
        hover_zh = "源码表为空，可能是占位或废弃 UMSS。",
        default = false,
    },
    {
        key = "wixie_puzzle",
        safe_key = "wixie_puzzle",
        label_en = "Wixie Puzzle",
        label_zh = "Wixie 谜题",
        hover_en = "wixie_piano, charles_t_horse, wixie_wardrobe, and wixie_clock.",
        hover_zh = "wixie_piano、charles_t_horse、wixie_wardrobe、wixie_clock。",
        default = false,
    },
    {
        key = "megabaseruins_intersection",
        safe_key = "megabaseruins_intersection",
        label_en = "Ancient Ruins Intersection",
        label_zh = "远古遗迹十字路口",
        hover_en = "Many umdc_tileflag markers and stone walls.",
        hover_zh = "大量 umdc_tileflag 和石墙。",
        default = false,
    },
    {
        key = "MAGMASPLOTCH1",
        safe_key = "MAGMASPLOTCH1",
        label_en = "Magma Splotch 1",
        label_zh = "岩浆地皮点 1",
        hover_en = "One magma turf flag.",
        hover_zh = "单个岩浆地皮旗。",
        default = false,
    },
    {
        key = "MAGMASPLOTCH2",
        safe_key = "MAGMASPLOTCH2",
        label_en = "Magma Splotch 2",
        label_zh = "岩浆地皮点 2",
        hover_en = "Two magma turf flags.",
        hover_zh = "两个岩浆地皮旗。",
        default = false,
    },
    {
        key = "MAGMASPLOTCH3",
        safe_key = "MAGMASPLOTCH3",
        label_en = "Magma Splotch 3",
        label_zh = "岩浆地皮点 3",
        hover_en = "Three magma turf flags.",
        hover_zh = "三个岩浆地皮旗。",
        default = false,
    },
    {
        key = "MAGMASPLOTCH4",
        safe_key = "MAGMASPLOTCH4",
        label_en = "Magma Splotch 4",
        label_zh = "岩浆地皮点 4",
        hover_en = "Five magma turf flags.",
        hover_zh = "五个岩浆地皮旗。",
        default = false,
    },
    {
        key = "testTable3",
        safe_key = "testTable3",
        label_en = "Test Table 3",
        label_zh = "测试表 3",
        hover_en = "Driftwood and dock_kit with coast/dock tile flags.",
        hover_zh = "浮木和 dock_kit，带海岸/码头地皮旗。",
        default = false,
    },
    {
        key = "sos",
        safe_key = "sos",
        label_en = "SOS Marker",
        label_zh = "SOS 标记",
        hover_en = "Many tile flags, flare, torches, and skeletons.",
        hover_zh = "大量地皮旗、信号弹、火把和骷髅。",
        default = false,
    },
    {
        key = "inactivebiome_cbts_3",
        safe_key = "inactivebiome_cbts_3",
        label_en = "Inactive Ocean Biome 3",
        label_zh = "海上非活跃生态 3",
        hover_en = "Ocean trees, sea vines, roots, barnacle cocoons, and waterlogged trunks.",
        hover_zh = "海树、海藤、树根、藤壶茧和水中树干。",
        default = false,
    },
    {
        key = "inactivebiome_cbts_1",
        safe_key = "inactivebiome_cbts_1",
        label_en = "Inactive Ocean Biome 1",
        label_zh = "海上非活跃生态 1",
        hover_en = "Water plants and sludge piles.",
        hover_zh = "水草和淤泥堆。",
        default = false,
    },
    {
        key = "inactivebiome_cbts_2",
        safe_key = "inactivebiome_cbts_2",
        label_en = "Inactive Ocean Biome 2",
        label_zh = "海上非活跃生态 2",
        hover_en = "Salt piles and cookie cutter spawn points.",
        hover_zh = "盐堆和饼干切割机刷新点。",
        default = false,
    },
    {
        key = "walterifgood",
        safe_key = "walterifgood",
        label_en = "Walter Small Camp",
        label_zh = "Walter 小营地",
        hover_en = "Evergreens, skeleton, fur/grass rolls, fire pit, and spider den.",
        hover_zh = "常青树、骷髅、毛皮/草席卷、火坑和蜘蛛巢。",
        default = false,
    },
    {
        key = "scorpionCenter1",
        safe_key = "scorpionCenter1",
        label_en = "Scorpion Center",
        label_zh = "蝎子中心",
        hover_en = "Many sandstones, sand dunes, scorpion dens, and um_scorpion.",
        hover_zh = "大量沙岩/沙丘/蝎子洞，含 um_scorpion。",
        default = false,
    },
    {
        key = "badfarmerTable",
        safe_key = "badfarmerTable",
        label_en = "Bad Farmer",
        label_zh = "坏农夫",
        hover_en = "Old farms, hoes, cooked seeds, and skeletons.",
        hover_zh = "旧农场、锄头、熟种子和骷髅。",
        default = false,
    },
    {
        key = "demoTable",
        safe_key = "demoTable",
        label_en = "Demo Table",
        label_zh = "演示表",
        hover_en = "Many logs, sea stacks, and splash.",
        hover_zh = "大量木头、海蚀柱和 splash。",
        default = false,
    },
    {
        key = "sunkenboat",
        safe_key = "sunkenboat",
        label_en = "Sunken Boat Wreck",
        label_zh = "沉船残骸",
        hover_en = "Boat fragments, rope, silk, boneshard, charcoal, and driftwood.",
        hover_zh = "船碎片、绳子、蛛丝、骨片、木炭和浮木。",
        default = false,
    },
    {
        key = "moonFrag",
        safe_key = "moonFrag",
        label_en = "Moon Island Fragment",
        label_zh = "月岛碎片",
        hover_en = "Moon glass rocks, moon trees, deciduous trees, grass, saplings, stone fruit bushes, and more. Blocked by default.",
        hover_zh = "月玻璃岩、月树、落叶树、草、树苗、石果灌木等。默认拦截。",
        default = true,
    },
    {
        key = "sussyTable",
        safe_key = "sussyTable",
        label_en = "Suspicious Tile Pattern",
        label_zh = "可疑地皮图案",
        hover_en = "Many umdc_tileflag markers and hound bones.",
        hover_zh = "大量 umdc_tileflag 和犬骨。",
        default = false,
    },
    {
        key = "tridentTrap",
        safe_key = "tridentTrap",
        label_en = "Trident Trap",
        label_zh = "三叉戟陷阱",
        hover_en = "Water plants, sea stacks, boat, kelp hat, skeletons, and trident.",
        hover_zh = "水草、海蚀柱、船、海带帽、骷髅和三叉戟。",
        default = false,
    },
    {
        key = "A_MonkeyOutpost",
        safe_key = "A_MonkeyOutpost",
        label_en = "Monkey Outpost A",
        label_zh = "猴子哨站 A",
        hover_en = "Large monkey hut/dock/pirate flag/cannon structure with swamp and rice edges.",
        hover_zh = "大型猴屋/码头/海盗旗/炮结构，带沼泽和水稻边缘。",
        default = false,
    },
    {
        key = "impactfulDiscovery",
        safe_key = "impactfulDiscovery",
        label_en = "Impactful Discovery",
        label_zh = "撞击发现",
        hover_en = "Wood wall wreckage, rocks, charcoal, cut stone, twigs, grass suit, and moon rocks.",
        hover_zh = "木墙残骸、岩石、木炭、石砖、树枝、草甲和月岩。",
        default = false,
    },
}

for i = 1, #UMSS_CONFIGS do
    local item = UMSS_CONFIGS[i]
    configuration_options[#configuration_options + 1] =
    {
        name = "block_umss_" .. item.safe_key,
        label = T(item.label_en, item.label_zh),
        hover = T(
            item.hover_en .. " Source code: " .. item.key,
            item.hover_zh .. "源码代码：" .. item.key
        ),
        options = UMSS_OPTIONS,
        default = item.default,
    }
end
