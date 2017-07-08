--//================================================================

local theme_conf_default = {
    BGBrightness = 100,
    DefaultBG = false,
    CenterPlayer = false,
    MusicRate = 1.0,
    FailType = "delayed",
    FailMissCombo = true,
    AllowW1 = true,
    TimingDifficulty = 4,
    LifeDifficulty = 4,
}

THEMECONFIG = create_lua_config{
    name = "THEMECONFIG", 
    file = "theme_config.lua",
    default = theme_conf_default,
}

THEMECONFIG:load("ProfileSlot_Invalid");
THEMECONFIG:set_dirty("ProfileSlot_Invalid");
THEMECONFIG:save("ProfileSlot_Invalid");

--//================================================================

function ResetThemeSettings()
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.BGBrightness = 100;
    tconf.DefaultBackground = false;
    tconf.CenterPlayer = false;
    tconf.MusicRate = 1.0;
    tconf.FailType = "delayed";
    tconf.FailMissCombo = true;
    tconf.AllowW1 = true;
    tconf.TimingDifficulty = 4;
    tconf.LifeDifficulty = 4;
    THEMECONFIG:save();
end;

--//================================================================

function ResetDisplayOptions()
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.BGBrightness = 100;
    tconf.DefaultBackground = false;
    tconf.CenterPlayer = false;
    THEMECONFIG:save();
end;

function ResetSongOptions()
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.MusicRate = 1.0;
    tconf.FailType = "delayed";
    tconf.FailMissCombo = true;
    THEMECONFIG:save();
end;

function ResetJudgmentOptions()
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.AllowW1 = true;
    tconf.TimingDifficulty = 4;
    tconf.LifeDifficulty = 4;
    THEMECONFIG:save();
end;

--//================================================================

function ApplyThemeSettings()
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");

    tconf.BGBrightness      = clamp(tconf.BGBrightness,0,100);
    tconf.MusicRate         = clamp(tconf.MusicRate,0.5,2.0);
    tconf.TimingDifficulty  = clamp(tconf.TimingDifficulty,1,9);
    tconf.LifeDifficulty    = clamp(tconf.LifeDifficulty,1,7);
    if string.lower(tconf.FailType) ~= "delayed" and
       string.lower(tconf.FailType) ~= "immediate" and
       string.lower(tconf.FailType) ~= "off" then
       tconf.FailType = "delayed";
    end;

    -------------------------------------------------------------------------------------------------------
    local timing_mapping = { 1.5, 1.33, 1.16, 1.00, 0.84, 0.66, 0.50, 0.33, 0.20 };
    local life_mapping = { 1.6, 1.40, 1.20, 1.00, 0.80, 0.60, 0.40 };

    PREFSMAN:SetPreference("BGBrightness",          tconf.DefaultBG and 0 or math.round(tconf.BGBrightness*100)/10000);
    PREFSMAN:SetPreference("Center1Player",         tconf.CenterPlayer);
    PREFSMAN:SetPreference("TimingWindowScale",     timing_mapping[tconf.TimingDifficulty] );
    PREFSMAN:SetPreference("LifeDifficultyScale",   life_mapping[tconf.LifeDifficulty] );
    PREFSMAN:SetPreference("AllowW1",               tconf.AllowW1 and "AllowW1_Everywhere" or "AllowW1_Never" );

    -------------------------------------------------------------------------------------------------------
    local sops= GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred");
    sops:MusicRate(tconf.MusicRate);
    GAMESTATE:ApplyPreferredSongOptionsToOtherLevels();

    -------------------------------------------------------------------------------------------------------
    local fail_mapping  = {
        ["immediate"]   = "FailType_Immediate",
        ["delayed"]     = "FailType_ImmediateContinue",
        ["off"]         = "FailType_Off",
    };

    for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
        local pstate = GAMESTATE:GetPlayerState(pn);
        local plops = pstate:get_player_options_no_defect("ModsLevel_Preferred");
        plops:FailSetting(fail_mapping[string.lower(tconf.FailType)])
        pstate:ApplyPreferredOptionsToOtherLevels();
    end;

end;

--//================================================================

local player_conf_default= {
    ShowOffsetMeter = false,
    ShowEarlyLate = false,
    ShowJudgmentList = false,
    ShowPacemaker = false,
    PacemakerTarget = "none",
    ScreenFilter = 0,
    SpeedModifier = 25,
}

NOTESCONFIG = notefield_prefs_config;
PLAYERCONFIG = create_lua_config{
    name = "PLAYERCONFIG", 
    file = "player_config.lua",
    default = player_conf_default,
}

add_standard_lua_config_save_load_hooks(PLAYERCONFIG);

--//================================================================

function ResetPlayerSpeed(pn)
    local nconf = NOTESCONFIG:get_data(pn);
    local pconf = PLAYERCONFIG:get_data(pn);
    nconf.speed_mod = 250;
    pconf.SpeedModifier = 25;
    nconf.speed_type = "maximum";

    NOTESCONFIG:save(pn);
    PLAYERCONFIG:save(pn);
end;

function ResetPlayerZoom(pn)
    local nconf = NOTESCONFIG:get_data(pn);
    nconf.zoom = 1;
    nconf.zoom_x = 1;
    nconf.zoom_y = 1;
    nconf.zoom_z = 1;

    NOTESCONFIG:save(pn);
end;

function ResetPlayerRotation(pn)
    local nconf = NOTESCONFIG:get_data(pn);
    nconf.rotation_x = 0;
    nconf.rotation_y = 0;
    nconf.rotation_z = 0;

    NOTESCONFIG:save(pn);
end;

function ResetPlayerView(pn)
    local nconf = NOTESCONFIG:get_data(pn);
    nconf.reverse = 1;
    nconf.yoffset = 140;
    nconf.fov = 60;

    NOTESCONFIG:save(pn);
end;

function ResetPlayerDisplay(pn)
    local nconf = NOTESCONFIG:get_data(pn);
    nconf.hidden = false;
    nconf.sudden = false;
    nconf.hidden_offset = 120;
    nconf.sudden_offset = 190;
    nconf.fade_distance = 40;
    nconf.glow_during_fade = true;

    NOTESCONFIG:save(pn);
end;

function ResetPlayerTransform(pn)
    ResetPlayerZoom(pn)
    ResetPlayerRotation(pn)
    ResetPlayerView(pn)
end;


--//================================================================

-- modified functions from _fallback/Scripts/03 notefield_prefs.lua
-- bring xmods a bit closer in scale  to cmod and mmod so they don't go 
-- unreasonably fast under the same values. tl;dr: xmods/100.
function apply_notefield_prefs_nopn(read_bpm, field, prefs)
    local torad= math.pi / 180
    if prefs.speed_type then
        if prefs.speed_type == "maximum" then
            field:set_speed_mod(false, prefs.speed_mod, read_bpm)
        elseif prefs.speed_type == "constant" then
            field:set_speed_mod(true, prefs.speed_mod)
        else
            field:set_speed_mod(false, prefs.speed_mod/100)
        end
    end
    field:set_base_values{
        fov_x= prefs.vanish_x,
        fov_y= prefs.vanish_y,
        fov_z= prefs.fov,
        transform_rot_x= prefs.rotation_x*torad,
        transform_rot_y= prefs.rotation_y*torad,
        transform_rot_z= prefs.rotation_z*torad,
        transform_zoom= prefs.zoom,
        transform_zoom_x= prefs.zoom_x,
        transform_zoom_y= prefs.zoom_y,
        transform_zoom_z= prefs.zoom_z,
    }
    -- Use the y zoom to adjust the y offset to put the receptors in the same
    -- place.
    local adjusted_offset= prefs.yoffset / (prefs.zoom * prefs.zoom_y)
    for i, col in ipairs(field:get_columns()) do
        col:set_base_values{
            reverse= prefs.reverse,
            reverse_offset= adjusted_offset,
        }
    end
    if prefs.hidden then
        field:set_hidden_mod(prefs.hidden_offset, prefs.fade_dist, prefs.glow_during_fade)
    else
        field:clear_hidden_mod()
    end
    if prefs.sudden then
        field:set_sudden_mod(prefs.sudden_offset, prefs.fade_dist, prefs.glow_during_fade)
    else
        field:clear_sudden_mod()
    end
end

function apply_notefield_prefs(pn, field, prefs)
    local pstate= GAMESTATE:GetPlayerState(pn)
    apply_notefield_prefs_nopn(pstate:get_read_bpm(), field, prefs)
    local poptions= pstate:get_player_options_no_defect("ModsLevel_Song")
    if prefs.speed_type == "maximum" then
        poptions:MMod(prefs.speed_mod, 1000)
    elseif prefs.speed_type == "constant" then
        poptions:CMod(prefs.speed_mod, 1000)
    else
        poptions:XMod(prefs.speed_mod/100, 1000)
    end
    local reverse= scale(prefs.reverse, 1, -1, 0, 1)
    poptions:Reverse(reverse, 1000)
    -- -1 tilt = +30 rotation_x
    local tilt= prefs.rotation_x / -30
    if prefs.reverse < 0 then
        tilt = tilt * -1
    end
    poptions:Tilt(tilt, 1000)
    local mini= (1 - prefs.zoom) * 2, 1000
    if tilt > 0 then
        mini = mini * scale(tilt, 0, 1, 1, .9)
    else
        mini = mini * scale(tilt, 0, -1, 1, .9)
    end
    poptions:Mini(mini, 1000)
    local steps= GAMESTATE:GetCurrentSteps(pn)
    if steps and steps:HasAttacks() then
        pstate:set_needs_defective_field(true)
    end
    if GAMESTATE:IsCourseMode() then
        local course= GAMESTATE:GetCurrentCourse()
        if course and course:HasMods() or course:HasTimedMods() then
            pstate:set_needs_defective_field(true)
        end
    end
end


