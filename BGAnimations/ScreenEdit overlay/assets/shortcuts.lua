-- This provides a few key shortcuts for common editing tasks like changing
-- the current speed mod, toggling assist clap, and toggling between normal
-- music rate and half music rate.

-- This is intended as ScreenEdit overlay.lua.  If the theme you are using
-- already has ScreenEdit overlay.lua, consult the theme author about adding
-- this functionality.
-- lua is easier for this stuff than C++, and doesn't require making a new
-- release, so I don't feel like putting this in the general edit mode.

-- Original author: Kyzentun

-- Editing notes:
-- toggle_clap_key, toggle_half_rate_key, speed_mod_inc_key,
-- speed_mod_dec_key, and speed_mod_change_scale_key are meant to be set by
-- the user to whatever keys they want.
-- But finding keys not already used by edit mode can be difficult.
-- Edit mode uses the up and down keys mapped for each player for scrolling.
-- This also includes the MenuUp and MenuDown keys.
-- The left button for each player seems to delete an arrow, I have no idea
-- why.
-- So if one of the up/down keys is used for one of the keys in this file,
-- then both things will happen, which is inconvenient.
-- The back button for each player is used to bring up the options menu.
-- Edit mode leaves the following keys unused: y, i, s, d, f, g, h, j, k, z,
--   x, c
-- The keys on the numpad appear to all be unused too.
-- Set show_cur_press to true to turn on an actor that will tell you the name
-- of a key that is pressed.
-- It may be tempting to use alt for speed_mod_change_scale_key because it is
-- a modifier key, but that will cause you problems when you use alt+tab to
-- switch to something else and stepmania doesn't see the key release.  So
-- don't use alt.
-- I am not responsible for any problems that arise from accidentally mapping
-- a key that turns out to do something unexpected in edit mode.  It's a
-- hairy beast, test your chosen keys carefully to make sure they don't do
-- anything.

-- If clap or half rate end up still on after you leave edit mode, whoops.
-- Didn't happen to me when I tried it, so I think the options get reset
-- correctly.

-- half_rate, speed_mod_inc, speed_mod_scale, and default_speed_mod can be
-- edited, but the default values seem reasonable to me.

-- The actors inside main_frame should be edited by the themer adding this to
-- their theme.  The actors given are simple BitmapTexts with no animations.
-- Each actor must have a SetStatusCommand to respond to each type of change.
-- Note also that each actor sets a corresponding variable so that the input
-- handler can run the SetStatus command when something happens.

local toggle_clap_key= "j"
local toggle_half_rate_key= "h"
local speed_mod_inc_key= "g"
local speed_mod_dec_key= "f"
local speed_mod_change_scale_key= "k"
local show_cur_press= false

local half_rate= .5
local speed_mod_inc= 10
local speed_mod_scale= 10
local default_speed_mod= 400

local speed_mod_scale_active= false

local song_options= GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred")
local player_state= GAMESTATE:GetPlayerState(PLAYER_1)
local player_options= player_state:GetPlayerOptions("ModsLevel_Preferred")

local speed_status_actor= false
local speed_inc_status_actor= false
local clap_status_actor= false
local rate_status_actor= false
local cur_press_status_actor= false

local function get_speed_inc()
    if speed_mod_scale_active then
        return speed_mod_scale * speed_mod_inc
    else
        return speed_mod_inc
    end
end

local function get_mmod()
    local mmod= player_options:MMod()
    if not mmod then mmod= default_speed_mod end
    return mmod
end

local function set_mmod(mmod)
    player_options:MMod(mmod)
    player_state:ApplyPreferredOptionsToOtherLevels()
    speed_status_actor:playcommand("SetStatus", {mmod= mmod})
end

local function apply_scale_active(active)
    speed_mod_scale_active= active
    speed_inc_status_actor:playcommand("SetStatus", {scale_active= speed_mod_scale_active})
end

local function apply_clap(clap)
    song_options:AssistClap(clap)
    GAMESTATE:ApplyPreferredSongOptionsToOtherLevels()
    clap_status_actor:playcommand("SetStatus", {clap= clap})
end

local function apply_rate(rate)
    song_options:MusicRate(rate)
    GAMESTATE:ApplyPreferredSongOptionsToOtherLevels()
    rate_status_actor:playcommand("SetStatus", {rate= rate})
end

local function input(event)
    local button= ToEnumShortString(event.DeviceInput.button)
    if event.type == "InputEventType_FirstPress" then
        if show_cur_press then
            cur_press_status_actor:playcommand("SetStatus", {button= button})
        end
        if button == speed_mod_change_scale_key then
            apply_scale_active(true)
        elseif button == toggle_clap_key then
            local clap_status= not song_options:AssistClap()
            apply_clap(clap_status)
        elseif button == toggle_half_rate_key then
            local rate= song_options:MusicRate()
            if rate < 1 then
                rate= 1
            else
                rate= half_rate
            end
            apply_rate(rate)
        elseif button == speed_mod_inc_key then
            set_mmod(get_mmod() + get_speed_inc())
        elseif button == speed_mod_dec_key then
            set_mmod(get_mmod() - get_speed_inc())
        end
    elseif event.type == "InputEventType_Release" then
        if button == speed_mod_change_scale_key then
            apply_scale_active(false)
        end
    end
end

local function init_actor()
    return Def.Actor{
        OnCommand= function(self)
            SCREENMAN:GetTopScreen():AddInputCallback(input)
            set_mmod(get_mmod())
            apply_scale_active()
            apply_clap(false)
            apply_rate(1)
        end
    }
end

local main_frame= Def.ActorFrame{
    init_actor(),
    OnCommand= function(self)
        self:zoom(.5):xy(_screen.cx*.4, 16)
    end,
    Def.BitmapText{
        Font= "Common Normal", InitCommand= function(self)
            cur_press_status_actor= self
            self:xy(0, 104)
        end,
        SetStatusCommand= function(self, param)
            self:settextf('"%s"', param.button)
        end,
    },
    Def.ActorFrame{
        InitCommand= function(self)
            speed_inc_status_actor= self
            self:xy(0, 8)
        end,
        Def.BitmapText{
            Font= "Common Normal", InitCommand= function(self)
                self:y(-8):zoom(.5)
                    :settextf("(*%d: %s)", speed_mod_scale, speed_mod_change_scale_key)
            end,
        },
        Def.BitmapText{
            Font= "Common Normal", InitCommand= function(self)
                self:x(25):horizalign(left)
            end,
            SetStatusCommand= function(self, param)
                local inc= get_speed_inc()
                self:settextf("+%d (%s)", inc, speed_mod_inc_key)
            end,
        },
        Def.BitmapText{
            Font= "Common Normal", InitCommand= function(self)
                self:x(-25):horizalign(right)
            end,
            SetStatusCommand= function(self, param)
                local inc= get_speed_inc()
                self:settextf("(%s) -%d", speed_mod_dec_key, inc)
            end,
        },
    },
    Def.BitmapText{
        Font= "Common Normal", InitCommand= function(self)
            speed_status_actor= self
            self:xy(0, 32)
        end,
        SetStatusCommand= function(self, param)
            self:settextf("Speed: m%d", param.mmod)
        end
    },
    Def.BitmapText{
        Font= "Common Normal", InitCommand= function(self)
            clap_status_actor= self
            self:xy(0, 56)
        end,
        SetStatusCommand= function(self, param)
            if param.clap then
                self:settextf("(%s) Clap: On", toggle_clap_key)
            else
                self:settextf("(%s) Clap: Off", toggle_clap_key)
            end
        end,
    },
    Def.BitmapText{
        Font= "Common Normal", InitCommand= function(self)
            rate_status_actor= self
            self:xy(0, 80)
        end,
        SetStatusCommand= function(self, param)
            self:settextf("(%s) Rate: %.2f", toggle_half_rate_key, param.rate)
        end,
    },
}

return main_frame
