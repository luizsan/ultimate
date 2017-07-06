--//================================================================
--[[
        param.Input = "Prev", "Next"
        param.Player = PLAYER_1, PLAYER_2
        param.Option = {
            Type = "pref", "config", "options"
            Field = field name
            Config = config file (if needed)
            Default = "baz", 0, etc
            Choices = { true, false, "foo", "bar", 5 }
            Range = { Min = 0, Max = 10, Step = 1 }
        };
]]--
--//================================================================

function ConfigRange(conf, field, default, min, max, step)
    return {
        Name = field,
        Type = "range",
        Field = field, 
        Config = conf, 
        Default = default, 
        Range = { Min = min, Max = max, Step = step } ,
    }
end;

function ConfigChoices(conf, field, default, choices)
    return { 
        Name = field,
        Type = "choices",
        Field = field, 
        Config = conf, 
        Default = default, 
        Choices = choices,
    }
end;

function ConfigBool(conf, field, default)
    return { 
        Name = field,
        Type = "bool",
        Field = field, 
        Config = conf, 
        Default = default, 
        Choices = { true, false },
    }
end;

function ConfigAction(label, func)
    return { 
        Name = label,
        Type = "action",
        Action = func,
    }
end;

function ConfigExit(label)
    return { 
        Name = label
    }
end;

function GetConfig(param)
    local pn = param and param.Player or nil;
    local conf = param.Option.Config;
    local field = param.Option.Field;
    local ret = get_element_by_path(conf:get_data(pn), field)
    return ret ~= nil and ret or false
end;

local function ChangeConfig(param)
    local pn = param and param.Player or nil;
    local conf = param.Option.Config;
    local field = param.Option.Field;
    local default = param.Option.Default;
    local current;

    current = GetConfig(param);
    if type(current) == "number" then
        current = math.round(current * 1000000)/1000000
    end;

    if param.Option.Choices and #param.Option.Choices > 1 then
        local choices = param.Option.Choices;
        local entry = GetEntry(current,choices);
        if param.Input == "Prev" then entry = entry-1; end;
        if param.Input == "Next" then entry = entry+1; end;
        if entry < 1 then entry = #choices; end;
        if entry > #choices then entry = 1; end;
        newvalue = choices[entry];

    elseif param.Option.Range then
        local min = param.Option.Range.Min;
        local max = param.Option.Range.Max;
        local step = param.Option.Range.Step;
        if param.Input == "Prev" then newvalue = current - step; end;
        if param.Input == "Next" then newvalue = current + step; end;
        newvalue = clamp(newvalue, min, max);
        newvalue = math.round(newvalue * 1000000)/1000000
    else
        LuaError("Invalid option choices/range");
    end;

    set_element_by_path(conf:get_data(pn), field, newvalue);
    conf:set_dirty(pn);

end;

function PropertyActor()
    return Def.ActorFrame{
        ChangePropertyMessageCommand=function(self,param)
            if param and param.Input then
                ChangeConfig(param);
                MESSAGEMAN:Broadcast("PropertyChanged", param);
            end;
        end;
    };
end;