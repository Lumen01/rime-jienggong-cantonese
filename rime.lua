function date_translator(input, seg)
    --- Year by Lumen
    if (input == "/year") then
        --- Candidate(type, start, end, text, comment)
        yield(Candidate("date", seg.start, seg._end, os.date("%Y年"), ""))
        yield(Candidate("date", seg.start, seg._end, os.date("%Y"), ""))
    elseif (input == "/month") then
        local monTab = {'一', '二', '三', '四', '五', '六', '七', '八', '九', '十', '十一', '十二'}
        local monShort = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'}
        local monLong = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'}
        yield(Candidate("date", seg.start, seg._end, os.date("%m月"), ""))
        yield(Candidate("date", seg.start, seg._end, monTab[tonumber(os.date("%m"))].."月", ""))
        yield(Candidate("date", seg.start, seg._end, monShort[tonumber(os.date("%m"))], ""))
        yield(Candidate("date", seg.start, seg._end, monLong[tonumber(os.date("%m"))], ""))
    elseif (input == "/date") then
        --- Candidate(type, start, end, text, comment)
        yield(Candidate("date", seg.start, seg._end, os.date("%Y-%m-%d"), ""))
        yield(Candidate("date", seg.start, seg._end, os.date("%Y年%m月%d日"), ""))
        yield(Candidate("date", seg.start, seg._end, os.date("%m-%d"), ""))
        yield(Candidate("date", seg.start, seg._end, os.date("%Y/%m/%d"), ""))
    elseif (input == "/time") then
        --- Candidate(type, start, end, text, comment)
        yield(Candidate("time", seg.start, seg._end, os.date("%H:%M"), ""))
        yield(Candidate("time", seg.start, seg._end, os.date("%H:%M:%S"), ""))
    elseif (input == "/week") then
        -- @JiandanDream
        -- https://github.com/KyleBing/rime-wubi86-jidian/issues/54
        local weekTab = {'日', '一', '二', '三', '四', '五', '六'}
        local weekShort = {'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'}
        local weekLong = {'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'}
        yield(Candidate("week", seg.start, seg._end, "周"..weekTab[tonumber(os.date("%w")+1)], ""))
        yield(Candidate("week", seg.start, seg._end, "星期"..weekTab[tonumber(os.date("%w")+1)], ""))
        yield(Candidate("week", seg.start, seg._end, weekShort[tonumber(os.date("%w")+1)], ""))
        yield(Candidate("week", seg.start, seg._end, weekLong[tonumber(os.date("%w")+1)], ""))
        yield(Candidate("date", seg.start, seg._end, os.date("第%W周"), ""))
    end
end

--- 过滤器：单字在先
function single_char_first_filter(input)
    local l = {}
    for cand in input:iter() do
        if (utf8.len(cand.text) == 1) then
            yield(cand)
        else
            table.insert(l, cand)
        end
    end
    for cand in ipairs(l) do
        yield(cand)
    end
end


--- -- Rime Lua 扩展 https://github.com/hchunhui/librime-lua
--- -- 文档 https://github.com/hchunhui/librime-lua/wiki/Scripting
--- 
--- -- processors:
--- 
--- -- 以词定字，可在 default.yaml → key_binder 下配置快捷键，默认为左右中括号 [ ]
--- select_character = require("select_character")
--- 
--- -- translators:
--- 
--- -- 日期时间，可在方案中配置触发关键字。
--- date_translator = require("date_translator")
--- 
--- -- 农历，可在方案中配置触发关键字。
--- lunar = require("lunar")
--- 
--- -- Unicode，U 开头
--- unicode = require("unicode")
--- 
--- -- 数字、人民币大写，R 开头
--- number_translator = require("number_translator")
--- 
--- -- filters:
--- 
--- -- 错音错字提示
--- -- 关闭此 Lua 时，同时需要关闭 translator/spelling_hints，否则 comment 里都是拼音
--- corrector = require("corrector")
--- 
--- -- v 模式 symbols 优先（全拼）
--- v_filter = require("v_filter")
--- 
--- -- 自动大写英文词汇
--- autocap_filter = require("autocap_filter")
--- 
--- -- 降低部分英语单词在候选项的位置，可在方案中配置要降低的模式和单词
--- reduce_english_filter = require("reduce_english_filter")
--- 
--- -- 辅码，https://github.com/mirtlecn/rime-radical-pinyin/blob/master/search.lua.md
--- search = require("search")
--- 
--- -- 置顶候选项
--- pin_cand_filter = require("pin_cand_filter")
--- 
--- -- 长词优先（全拼）
--- long_word_filter = require("long_word_filter")
--- 
--- -- 默认未启用：
--- 
--- -- 中英混输词条自动空格
--- -- 在 engine/filters 增加 - lua_filter@cn_en_spacer
--- cn_en_spacer = require("cn_en_spacer")
--- 
--- -- 英文词条上屏自动空格
--- -- 在 engine/filters 增加 - lua_filter@en_spacer
--- en_spacer = require("en_spacer")
--- 
--- -- 九宫格，将输入框的数字转为对应的拼音或英文，iRime 用，Hamster 不需要。
--- -- 在 engine/filters 增加 - lua_filter@t9_preedit
--- t9_preedit = require("t9_preedit")
--- 
--- -- 根据是否在用户词典，在 comment 上加上一个星号 *
--- -- 在 engine/filters 增加 - lua_filter@is_in_user_dict
--- -- 在方案里写配置项：
--- -- is_in_user_dict: true     为输入过的内容加星号
--- -- is_in_user_dict: false    为未输入过的内容加星号
--- is_in_user_dict = require("is_in_user_dict")
--- 
--- -- 词条隐藏、降频
--- -- 在 engine/processors 增加 - lua_processor@cold_word_drop_processor
--- -- 在 engine/filters 增加 - lua_filter@cold_word_drop_filter
--- -- 在 key_binder 增加快捷键：
--- -- turn_down_cand: "Control+j"  # 匹配当前输入码后隐藏指定的候选字词 或候选词条放到第四候选位置
--- -- drop_cand: "Control+d"       # 强制删词, 无视输入的编码
--- -- get_record_filername() 函数中仅支持了 Windows、macOS、Linux
--- cold_word_drop_processor = require("cold_word_drop.processor")
--- cold_word_drop_filter = require("cold_word_drop.filter")
--- 
--- 
--- -- 暴力 GC
--- -- 详情 https://github.com/hchunhui/librime-lua/issues/307
--- -- 这样也不会导致卡顿，那就每次都调用一下吧，内存稳稳的
--- function force_gc()
---     -- collectgarbage()
---     collectgarbage("step")
--- end
--- 
--- -- 临时用的
--- function debug_checker(input, env)
---     for cand in input:iter() do
---         yield(ShadowCandidate(
---             cand,
---             cand.type,
---             cand.text,
---             env.engine.context.input .. " - " .. env.engine.context:get_preedit().text .. " - " .. cand.preedit
---         ))
---     end
--- end
--- 
