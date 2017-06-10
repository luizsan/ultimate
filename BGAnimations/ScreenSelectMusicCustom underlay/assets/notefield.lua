
local curTime = -1;
local bpm = 60;
local curskin = {
    [PLAYER_1] = "",
    [PLAYER_2] = "",
}

local startup = GetTimeSinceStart()
local function UnscaledDelta()
    local dt = GetTimeSinceStart() - startup;
    startup = GetTimeSinceStart();
    return dt;
end;

local function UpdateTime(self, delta)
    --local _start = Global.song:GetSampleStart();
    --local _length = Global.song:GetSampleLength();
    --local _end = Global.song:MusicLengthSeconds();
    curTime = GAMESTATE:GetCurMusicSeconds();
    MESSAGEMAN:Broadcast("UpdateNotefield");
end

local t = Def.ActorFrame{
    InitCommand=function(self)
        self:SetUpdateFunction(UpdateTime);
    end;
} 

local tex = Def.ActorFrameTexture{
    InitCommand= function(self)
        self:setsize(_screen.w, _screen.h)
        self:SetTextureName("notefield_overlay")
        self:EnableAlphaBuffer(true);
        self:EnablePreserveTexture(false)
        self:Create();
    end;
}

-- <Kyzentun> Luizsan: Yeah, it's touchy about the order.  I tried to make it less 
-- touchy in the notefield_targets branch, but good luck finding someone to build that.


for pn in ivalues(GAMESTATE:GetHumanPlayers()) do

    tex[#tex+1] = Def.NoteField{
        NoteskinSelectedMessageCommand=cmd(playcommand,"Refresh");
        StepsChangedMessageCommand=cmd(playcommand,"Refresh");
        SpeedChangedMessageCommand=cmd(playcommand,"Refresh");
        FolderChangedMessageCommand=cmd(playcommand,"Refresh");
        RefreshCommand=function(self)
            if GAMESTATE:IsSideJoined(pn) then
                local steps = Global.pncursteps[pn] or GAMESTATE:GetCurrentSteps(pn);

                local skin = GetPreferredNoteskin(pn);
                local prefs = notefield_prefs_config:get_data(pn);

                self:set_vanish_type("FieldVanishType_RelativeToSelf")

                if curskin[pn] ~= skin then
                    self:set_skin(skin, {});
                    curskin = skin;
                end;

                self:set_steps(steps);

                local speed = prefs.speed_mod;
                local mode = prefs.speed_type;
                local bpm = Global.song:GetDisplayBpms()[2];

                local st = PureType(steps);
                if st == "Double" or st == "Routine" then
                    self:set_base_values{
                        transform_pos_x = _screen.cx, 
                        transform_pos_y = _screen.cy,
                    }
                else
                    self:set_base_values{
                        transform_pos_x = _screen.cx + (_screen.w * 0.25 * pnSide(pn)), 
                        transform_pos_y = _screen.cy,
                    }
                end;

                apply_notefield_prefs_nopn(bpm, self, prefs)
                self:set_curr_second(curTime);  
            end;
        end;

        UpdateNotefieldMessageCommand=function(self)
            if GAMESTATE:IsSideJoined(pn) then
                self:set_curr_second(curTime);
            end;
        end;
    };

end;

t[#t+1] = tex;

t[#t+1] = Def.Sprite{
    Texture = "notefield_overlay";
    InitCommand=cmd(zoom,0.5;xy,_screen.cx,_screen.cy-48;diffusealpha,0);
    OnCommand=cmd(playcommand,"Reload");
    MusicWheelMessageCommand=cmd(playcommand,"Reload");
    ReloadCommand=cmd(stoptweening;diffusealpha,0;sleep,0.6;linear,0.25;diffusealpha,0.75);
}


return t;