local L = AceLibrary("AceLocale-2.2"):new("NampowerSettings")

L:RegisterTranslations("enUS", function()
    return {
        ["|cffffcc00Pepo Nampower v2|cffffaaaa not present hiding settings."] = true,

        ["|cffffcc00Pepo Nampower update available.|cffffcc00  Some settings may be hidden until you update.  Replace your existing nampower.dll with the latest from https://github.com/pepopo978/nampower/releases"] = true,

        ["Superwow required to display queued spells."] = true,

        ["Enable Per Character Settings"] = true,
        ["Whether to use per character settings for all of the NP_ settings.  This will cause settings saved in your character's NampowerSettings.lua to override any global settings in Config.wtf."] = true,

        ["Queue Cast Time Spells"] = true,
        ["Whether to enable spell queuing for spells with a cast time"] = true,

        ["Queue Instant Spells"] = true,
        ["Whether to enable spell queuing for instant cast spells tied to gcd"] = true,

        ["Queue On Swing Spells"] = true,
        ["Whether to enable on swing spell queuing"] = true,

        ["Queue Channeling Spells"] = true,
        ["Whether to enable channeling spell queuing"] = true,

        ["Queue Targeting Spells"] = true,
        ["Whether to enable terrain targeting spell queuing"] = true,

        ["Queue Spells Coming Off Cooldown"] = true,
        ["Whether to enable spell queuing for spells coming off cooldown"] = true,

        ["Queue Windows"] = true,
        ["How much time in ms you have before a cast ends to queue different types of spells"] = true,

        ["Spell Queue Window (ms)"] = true,
        ["The window in ms before a cast finishes where the next will get queued"] = true,

        ["On Swing Buffer Cooldown (ms)"] = true,
        ["The cooldown time in ms after an on swing spell before you can queue on swing spells"] = true,

        ["Channel Queue Window (ms)"] = true,
        ["The window in ms before a channel finishes where the next will get queued"] = true,

        ["Targeting Queue Window (ms)"] = true,
        ["The window in ms before a terrain targeting spell finishes where the next will get queued"] = true,

        ["Cooldown Queue Window (ms)"] = true,
        ["The window in ms before a spell coming off cooldown finishes where the next will get queued"] = true,

        ["Advanced options"] = true,
        ["Collection of various advanced options"] = true,

        ["Double Cast to End Channel Early"] = true,
        ["Whether to allow double casting a spell within 350ms to end channeling on the next tick.  Takes into account your ChannelLatencyReductionPercentage."] = true,

        ["Interrupt Channels Outside Queue Window"] = true,
        ["Whether to allow interrupting channels (the original client behavior) when trying to cast a spell outside the channeling queue window"] = true,

        ["Retry Server Rejected Spells"] = true,
        ["Whether to retry spells that are rejected by the server for these reasons: SPELL_FAILED_ITEM_NOT_READY, SPELL_FAILED_NOT_READY, SPELL_FAILED_SPELL_IN_PROGRESS"] = true,

        ["Quickcast Targeting Spells"] = true,
        ["Whether to enable quick casting for ALL spells with terrain targeting"] = true,

        ["Replace Matching Non GCD Category"] = true,
        ["Whether to replace any queued non gcd spell when a new non gcd spell with the same non zero StartRecoveryCategory is cast.  Most trinkets and spells are category 0 which are ignored by this setting.  The primary use case is to switch which potion you have queued."] = true,

        ["Optimize Buffer Using Packet Timings"] = true,
        ["Whether to attempt to optimize your buffer using your latency and server packet timings"] = true,

        ["Minimum Buffer Time (ms)"] = true,
        ["The minimum buffer delay in ms added to each cast"] = true,

        ["Non GCD Buffer Time (ms)"] = true,
        ["The buffer delay in ms added AFTER each cast that is not tied to the gcd"] = true,

        ["Max Buffer Increase (ms)"] = true,
        ["The maximum amount of time in ms to increase the buffer by when the server rejects a cast"] = true,

        ["Channel Latency Reduction (%)"] = true,
        ["The percentage of your latency to subtract from the end of a channel duration to optimize cast time while hopefully not losing any ticks"] = true,

        ["Queued Spell Display Options"] = true,
        ["Options for displaying an icon for the queued spell"] = true,

        ["Display queued spell icon"] = true,
        ["Whether to display an icon of the queued spell"] = true,

        ["Icon size"] = true,
        ["Change the spell icon size"] = true,

        ["Allow dragging"] = true,
        ["Whether to allow interaction with the queued spell icon so you can move it around"] = true,

        ["Reset Position"] = true,
        ["Reset the position of the queued spell icon"] = true,

        ["Show/Hide for positioning"] = true,
        ["Test the queued spell icon and position it to your liking"] = true,

        ["Prevent Right Click Target Change"] = true,
        ["Whether to prevent right-clicking from changing your current target when in combat.  If you don't have a target right click will still change your target even with this on.  This is mainly to prevent accidentally changing targets in combat when trying to adjust your camera."] = true,

        ["Nameplate Distance"] = true,
        ["The distance in yards to show nameplates"] = true,
    }
end)

L:RegisterTranslations("zhCN", function()
    return {
        ["|cffffcc00Pepo Nampower v2|cffffaaaa not present hiding settings."] = "|cffffcc00Pepo Nampower v2|cffffaaaa 未安装，隐藏设置项。",

        ["|cffffcc00Pepo Nampower update available.|cffffcc00  Some settings may be hidden until you update.  Replace your existing nampower.dll with the latest from https://github.com/pepopo978/nampower/releases"] = "|cffffcc00Pepo Nampower 有更新可用。|cffffcc00 更新前部分设置可能隐藏。请从 https://github.com/pepopo978/nampower/releases 下载最新 nampower.dll 替换当前版本。",

        ["Superwow required to display queued spells."] = "需 Superwow 插件显示队列中法术。",

        ["Enable Per Character Settings"] = "启用角色独立设置",
        ["Whether to use per character settings for all of the NP_ settings.  This will cause settings saved in your character's NampowerSettings.lua to override any global settings in Config.wtf."] = "是否为所有 NP_ 设置启用角色独立配置。启用后，角色 NampowerSettings.lua 中的设置将覆盖 Config.wtf 中的全局设置。",

        ["Queue Cast Time Spells"] = "队列施法时间法术",
        ["Whether to enable spell queuing for spells with a cast time"] = "是否对施法时间类法术启用队列功能",

        ["Queue Instant Spells"] = "队列瞬发法术",
        ["Whether to enable spell queuing for instant cast spells tied to gcd"] = "是否对涉及公共冷却的瞬发法术启用队列功能",

        ["Queue On Swing Spells"] = "队列特殊攻击法术",
        ["Whether to enable on swing spell queuing"] = "是否对特殊攻击类法术（如战士压制）启用队列功能",

        ["Queue Channeling Spells"] = "队列引导法术",
        ["Whether to enable channeling spell queuing"] = "是否对引导类法术（如暴风雪）启用队列功能",

        ["Queue Targeting Spells"] = "队列目标区域法术",
        ["Whether to enable terrain targeting spell queuing"] = "是否对目标区域类法术（如暴风雪）启用队列功能",

        ["Queue Spells Coming Off Cooldown"] = "队列冷却结束法术",
        ["Whether to enable spell queuing for spells coming off cooldown"] = "是否对即将结束冷却的法术启用队列功能",

        ["Queue Windows"] = "队列窗口设置",
        ["How much time in ms you have before a cast ends to queue different types of spells"] = "各种法术类型在施法结束前多少毫秒（ms）开始进入队列",

        ["Spell Queue Window (ms)"] = "法术队列窗口（ms）",
        ["The window in ms before a cast finishes where the next will get queued"] = "当前施法结束前多少毫秒（ms）可将下一个法术加入队列",

        ["On Swing Buffer Cooldown (ms)"] = "特殊攻击缓冲冷却（ms）",
        ["The cooldown time in ms after an on swing spell before you can queue on swing spells"] = "特殊攻击法术施放后，多少毫秒（ms）内无法再次将同类法术加入队列",

        ["Channel Queue Window (ms)"] = "引导法术队列窗口（ms）",
        ["The window in ms before a channel finishes where the next will get queued"] = "引导法术结束前多少毫秒（ms）可将下一个法术加入队列",

        ["Targeting Queue Window (ms)"] = "目标区域法术队列窗口（ms）",
        ["The window in ms before a terrain targeting spell finishes where the next will get queued"] = "目标区域法术结束前多少毫秒（ms）可将下一个法术加入队列",

        ["Cooldown Queue Window (ms)"] = "冷却结束队列窗口（ms）",
        ["The window in ms before a spell coming off cooldown finishes where the next will get queued"] = "法术冷却结束前多少毫秒（ms）可将该法术加入队列",

        ["Advanced options"] = "高级选项",
        ["Collection of various advanced options"] = "各类高级选项集合",

        ["Double Cast to End Channel Early"] = "双重施法提前结束引导",
        ["Whether to allow double casting a spell within 350ms to end channeling on the next tick.  Takes into account your ChannelLatencyReductionPercentage."] = "是否允许350毫秒内双重施法以在下一个伤害周期提前结束引导。受引导延迟削减比例影响。",

        ["Interrupt Channels Outside Queue Window"] = "队列窗口外允许打断引导",
        ["Whether to allow interrupting channels (the original client behavior) when trying to cast a spell outside the channeling queue window"] = "在引导法术队列窗口外尝试施法时，是否允许打断引导（默认客户端行为）",

        ["Retry Server Rejected Spells"] = "重试服务器拒绝的法术",
        ["Whether to retry spells that are rejected by the server for these reasons: SPELL_FAILED_ITEM_NOT_READY, SPELL_FAILED_NOT_READY, SPELL_FAILED_SPELL_IN_PROGRESS"] = "是否对因以下原因被服务器拒绝的法术进行重试：未准备就绪、未冷却、已有法术施放中",

        ["Quickcast Targeting Spells"] = "快速施放目标区域法术",
        ["Whether to enable quick casting for ALL spells with terrain targeting"] = "是否为所有目标区域法术启用快速施放功能",

        ["Replace Matching Non GCD Category"] = "替换同类型非公共冷却法术",
        ["Whether to replace any queued non gcd spell when a new non gcd spell with the same non zero StartRecoveryCategory is cast.  Most trinkets and spells are category 0 which are ignored by this setting.  The primary use case is to switch which potion you have queued."] = "当施放新的非公共冷却法术且其启动类别相同时，是否替换队列中的同类法术。饰品和多数法术属类别0（不受影响），主要用于替换已队列的药水。",

        ["Optimize Buffer Using Packet Timings"] = "基于封包时间优化缓冲",
        ["Whether to attempt to optimize your buffer using your latency and server packet timings"] = "是否根据延迟和服务器封包时间优化法术缓冲机制",

        ["Minimum Buffer Time (ms)"] = "最低缓冲时间（ms）",
        ["The minimum buffer delay in ms added to each cast"] = "为每次施法添加的最小缓冲延迟（毫秒）",

        ["Non GCD Buffer Time (ms)"] = "非公共冷却缓冲时间（ms）",
        ["The buffer delay in ms added AFTER each cast that is not tied to the gcd"] = "在非公共冷却法术施放后添加的缓冲延迟（毫秒）",

        ["Max Buffer Increase (ms)"] = "最大缓冲增加量（ms）",
        ["The maximum amount of time in ms to increase the buffer by when the server rejects a cast"] = "当法术被服务器拒绝时，缓冲时间可增加的最大毫秒数",

        ["Channel Latency Reduction (%)"] = "引导延迟削减比例（%）",
        ["The percentage of your latency to subtract from the end of a channel duration to optimize cast time while hopefully not losing any ticks"] = "为优化施法时间，从引导结束时序中扣除延迟的百分比（避免丢失伤害周期）",

        ["Queued Spell Display Options"] = "队列法术显示选项",
        ["Options for displaying an icon for the queued spell"] = "队列中法术图标的显示设置",

        ["Display queued spell icon"] = "显示队列法术图标",
        ["Whether to display an icon of the queued spell"] = "是否显示队列中法术的图标",

        ["Icon size"] = "图标尺寸",
        ["Change the spell icon size"] = "修改法术图标大小",

        ["Allow dragging"] = "允许拖动",
        ["Whether to allow interaction with the queued spell icon so you can move it around"] = "是否允许通过拖动交互调整队列法术图标位置",

        ["Reset Position"] = "重置位置",
        ["Reset the position of the queued spell icon"] = "重置队列法术图标位置",

        ["Show/Hide for positioning"] = "显示/隐藏（用于定位）",
        ["Test the queued spell icon and position it to your liking"] = "测试队列法术图标位置，按需调整",

        ["Prevent Right Click Target Change"] = "阻止右键切换目标",
        ["Whether to prevent right-clicking from changing your current target when in combat.  If you don't have a target right click will still change your target even with this on.  This is mainly to prevent accidentally changing targets in combat when trying to adjust your camera."] = "战斗中右键点击是否不改变当前目标（无目标时仍可切换）。主要用于调整镜头时避免误切目标。",

        ["Nameplate Distance"] = "姓名板显示距离",
        ["The distance in yards to show nameplates"] = "显示姓名板的最大距离（码）",
    }
end)