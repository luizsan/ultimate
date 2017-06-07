--//================================================================

function PureType(steps)
    local filter
    filter = string.gsub(ToEnumShortString(steps:GetStepsType()),Game().."_","");
    return filter
end;


--//================================================================

function FormatDP(f)
    return string.format("%.2f",f*100).."%";
end;

--//================================================================

function FormatMeter(s)
    if s >= 50 or s <= 0 then
        return "??"
    else
        if s < 10 then
        return "0"..s;
        else
        return s;
        end
    end
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
    elseif grade == "Grade_Failed" then return "F"
    else return "--"
    end;
end;

--//================================================================

function FormatGradePIU(grade)
    if grade == "Grade_Tier01" then return "SS"
    elseif grade == "Grade_Tier02" then return "S"
    elseif grade == "Grade_Tier03" then return "S"
    elseif grade == "Grade_Tier04" then return "A"
    elseif grade == "Grade_Tier05" then return "B"
    elseif grade == "Grade_Tier06" then return "C"
    elseif grade == "Grade_Tier07" then return "D"
    elseif grade == "Grade_Tier08" then return "F"
    elseif grade == "Grade_Failed" then return "F"
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