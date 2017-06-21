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

function OptionPlayerNotefieldRange(name, field, default, min, max, step)
    return { Name = name, Type = "config", Field = field, Config = notefield_prefs_config, Default = default, Range = { Min = min, Max = max, Step = step } }
end;

function OptionPlayerNotefieldChoices(name, field, default, choices)
    return { Name = name, Type = "config", Field = field, Config = notefield_prefs_config, Default = default, Choices = choices }
end;

function OptionPreferenceRange(name, field, default, min, max, step)
    return { Name = name, Type = "pref", Field = field, Default = default, Range = { Min = min, Max = max, Step = step } };
end;

function OptionPreferenceChoices(name, field, default, choices)
    return { Name = name, Type = "pref", Field = field, Default = default, Choices = choices };
end;

function OptionPlayerModsRange(name, field, default, min, max, step, propagate)
    return { Name = name, Type = "pmods", Field = field, Default = default, Range = { Min = min, Max = max, Step = step }, Propagate = propagate ~= nil and propagate or false };
end;

function OptionPlayerModsChoices(name, field, default, choices, propagate)
    return { Name = name, Type = "pmods", Field = field, Default = default, Choices = choices, Propagate = propagate ~= nil and propagate or false };
end;

function OptionSongModsRange(name, field, default, min, max, step)
    return { Name = name, Type = "smods", Field = field, Default = default, Range = { Min = min, Max = max, Step = step } };
end;

function OptionSongModsChoices(name, field, default, choices)
    return { Name = name, Type = "smods", Field = field, Default = default, Choices = choices };
end;

function OptionBack()
    return { Name = "Return" }
end;

function GetConfig(param)
    local pn = param and param.Player or Global.master or GAMESTATE:GetMasterPlayerNumber();
    if not pn or not param.Option then return nil end

    local conf = param.Option.Config;
    local field = param.Option.Field;
    local conf_type = param.Option.Type;

    if conf_type == "pref" then 
        return PREFSMAN:GetPreference(field);
    elseif conf_type == "config" then 
        return get_element_by_path(conf:get_data(pn), field) or 0
    elseif conf_type == "pmods" then
        local pmods = GAMESTATE:GetPlayerState(pn):get_player_options_no_defect("ModsLevel_Preferred");
        return pmods[field](pmods)
    elseif conf_type == "smods" then
        local smods = GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred");
        return smods[field](smods)
    end;

    return nil;
end;

local function ChangeConfig(param)
    local pn = param and param.Player;
    if not pn then return end

    local conf = param.Option.Config;
    local field = param.Option.Field;
    local conf_type = param.Option.Type;
    local default = param.Option.Default;
    local current;

    current = GetConfig(param)
    if type(current) == "number" then
        current = (math.round(current*1000000)/1000000)
    end; 

    if param.Option.Choices then
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
    else
        LuaError("Invalid option choices/range");
    end;



    if conf_type == "pref" then
        PREFSMAN:SetPreference(field, newvalue);

    elseif conf_type == "config" then
        set_element_by_path(conf:get_data(pn), field, newvalue);
        conf:set_dirty(pn);

    elseif conf_type == "pmods" then
        local pstate = GAMESTATE:GetPlayerState(pn)
        local plops = pstate:get_player_options_no_defect("ModsLevel_Preferred")
        plops[field](plops, newvalue)
        pstate:ApplyPreferredOptionsToOtherLevels()

        if param.Propagate and SideJoined(OtherPlayer[pn]) then
            local otherpn = OtherPlayer[pn];
            local otherpnstate = GAMESTATE:GetPlayerState(otherpn)
            local otherpnops = otherpnstate:get_player_options_no_defect("ModsLevel_Preferred")
            otherpnops[field](otherpnops, newvalue)
            otherpn:ApplyPreferredOptionsToOtherLevels()
        end;

    elseif conf_type == "smods" then
        local song_ops= GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred")
        song_ops[field](song_ops, newvalue)
        GAMESTATE:ApplyPreferredSongOptionsToOtherLevels()

    end;

end;

function PropertyActor()
    return Def.ActorFrame{
        ChangePropertyMessageCommand=function(self,param)
            if param and param.Player and param.Input then
                ChangeConfig(param);
                MESSAGEMAN:Broadcast("PropertyChanged",param);
            end;
        end;
    };
end;