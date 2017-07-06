--//================================================================

function PureType(steps)
    if steps then
        return string.gsub(ToEnumShortString(steps:GetStepsType()),Game().."_","");
    else
        return nil;
    end;
end;

--//================================================================

function FormatDP(f)
    return string.format("%.2f",f*100).."%";
end;

--//================================================================

function FormatMeter(s)
    if s >= 50 then
        return "??"
    elseif s <= 0 then
        return "--"
    else
        if s < 10 then
            return "0"..s;
        else
            return s;
        end
    end
end;

--//================================================================

function CapDigits(num, cap, digits)
    local len = string.len(num)
    local rep = clamp(digits - len, 0, digits)
    return string.rep(tostring(cap), rep) .. tostring(num);

end;

--//================================================================

function FormatDate(date)
    local temp = tostring(date);
    temp = string.gsub(temp,"-","/")
    temp = string.gsub(temp," ","   ")
    return temp
end

--//================================================================

function RawDate(date)
    local temp = tostring(date);
    temp = string.gsub(temp,"-","")
    temp = string.gsub(temp,":","")
    temp = string.gsub(temp," ","")
    return temp
end

--//================================================================

function FormatSpeed(value, mode)
    if mode == 3 or mode == "M" then
        return "M"..value;
    elseif mode == 2 or mode == "C" then
        return "C"..value;
    elseif mode == 1 or mode == "X" then
        return string.format("%.2f",value/100).."X";
    else
        LuaError("Invalid or nil speed mode");
        return value;
    end;

end;

--//================================================================

function UppercaseFirst(str)
    return (str:gsub("^%l", string.upper))
end

--//================================================================

function FormatGrade(grade)
    if grade == "Grade_Tier01" then return "AAAA"
    elseif grade == "Grade_Tier02" then return "AAA"
    elseif grade == "Grade_Tier03" then return "AA"
    elseif grade == "Grade_Tier04" then return "A"
    elseif grade == "Grade_Tier05" then return "B"
    elseif grade == "Grade_Tier06" then return "C"
    elseif grade == "Grade_Tier07" then return "D"
    elseif grade == "Grade_Tier08" then return "F"
    elseif grade == "Grade_Failed" then return "Failed"
    else return "--"
    end;
end;

--//================================================================

function FormatGradePIU(grade)
    if grade == "Grade_Tier01" then return "SS"
    elseif grade == "Grade_Tier02" then return "S+"
    elseif grade == "Grade_Tier03" then return "S"
    elseif grade == "Grade_Tier04" then return "A"
    elseif grade == "Grade_Tier05" then return "B"
    elseif grade == "Grade_Tier06" then return "C"
    elseif grade == "Grade_Tier07" then return "D"
    elseif grade == "Grade_Tier08" then return "F"
    elseif grade == "Grade_Failed" then return "Failed"
    else return "--"
    end;
end;

--//================================================================

function FormatAward(award)
    if award == "StageAward_FullComboW3" then return "Full Combo!"
    elseif award == "StageAward_SingleDigitW3" then return "Single Digit Greats!"
    elseif award == "StageAward_OneW3" then return "One Great!"
    elseif award == "StageAward_FullComboW2" then return "Full Perfect!"
    elseif award == "StageAward_SingleDigitW2" then return "Single Digit Perfects!"
    elseif award == "StageAward_OneW2" then return "One Perfect!"
    elseif award == "StageAward_FullComboW1" then return "Full Superb!"
    else return ""
    end;
end;

--//================================================================

function FormatFailType(fail)
    if fail == "FailType_Immediate" then return "Immediate";
    elseif fail == "FailType_ImmediateContinue" then return "Delayed"
    elseif fail == "FailType_EndOfSong" then return "End of song"
    elseif fail == "FailType_Off" then return "Off";
    else return "" end;
end;

--//================================================================

local function dict_bool(val)
    return val and "On" or "Off";
end;

local function dict_rate(val)
    if string.len(tostring(val)) == 1 then return tostring(val)..".00x" end;
    if string.len(tostring(val)) == 3 then return tostring(val).."0x" end;
    if string.len(tostring(val)) == 4 then return tostring(val).."x" end;
end;

local dict_fail = {
    ["off"] = "Disabled",
    ["delayed"] = "Delayed",
    ["immediate"] = "Instant"
}

local dict_timing = {
    "1 (Easiest)",
    "2 (Easy)",
    "3 (Easier)",
    "4 (Normal)",
    "5 (Medium)",
    "6 (Hard)",
    "7 (Very Hard)",
    "8 (Hardest)",
    "9 (Justice)",
}

local dict_life = {
    "1 (Easiest)",
    "2 (Easy)",
    "3 (Easier)",
    "4 (Normal)",
    "5 (Hard)",
    "6 (Very Hard)",
    "7 (Hardest)",
}

function FormatOptionConfigs(str, val)
    local dictionary = {
        ["BGBrightness"]        = "Background Brightness",
        ["DefaultBG"]           = "Use Default Background",
        ["CenterPlayer"]        = "Center 1 Player",
        ["MusicRate"]           = "Music Rate",
        ["FailType"]            = "Fail Type",
        ["FailMissCombo"]       = "Miss Combo Fail",
        ["AllowW1"]             = "Flawless Timing",
        ["TimingDifficulty"]    = "Timing Window Difficulty",
        ["LifeDifficulty"]      = "Life Meter Difficulty",
    }

    local format = {
        ["BGBrightness"]        = tostring(val).."%",
        ["DefaultBG"]           = dict_bool(val),
        ["CenterPlayer"]        = dict_bool(val),
        ["MusicRate"]           = dict_rate(val),
        ["FailType"]            = dict_fail[val],
        ["FailMissCombo"]       = dict_bool(val),
        ["AllowW1"]             = dict_bool(val),
        ["TimingDifficulty"]    = dict_timing[val],
        ["LifeDifficulty"]      = dict_life[val],
    }

    local a = dictionary[str] or str;
    local b = format[str] or val;
    return { Name = a, Value = b }
end;
