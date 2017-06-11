local stagestats;
local stageindex;

local pss = {
    [PLAYER_1] = nil,
    [PLAYER_2] = nil,
}

local stats = {
    [PLAYER_1] = nil,
    [PLAYER_2] = nil,
}

local digits = 0;

local tablestats = {};
local labelstats = {};

local number_zoom = 0.5;


local function FetchStatsForPlayer(pn)

    local stats;
    local curstats; 
    local pss; 
    local dp; 

    if GAMESTATE:IsSideJoined(pn) then
        curstats = STATSMAN:GetCurStageStats();
        pss = curstats:GetPlayerStageStats(pn);
        curdp = pss:GetActualDancePoints();
        maxdp = pss:GetCurrentPossibleDancePoints();
        dp = curdp / clamp(maxdp,1,maxdp);

        stats = {
            ["Percent"]  = string.format("%.2f",dp*100), 
            ["Score"]    = IsGame("pump") and PostProcessPIUScores(pn) or pss:GetScore(), 
            ["Combo"]    = pss:MaxCombo(), 
            ["W1"]       = pss:GetTapNoteScores('TapNoteScore_W1'),
            ["W2"]       = pss:GetTapNoteScores('TapNoteScore_W2'), 
            ["W3"]       = pss:GetTapNoteScores('TapNoteScore_W3'), 
            ["W4"]       = pss:GetTapNoteScores('TapNoteScore_W4'), 
            ["W5"]       = pss:GetTapNoteScores('TapNoteScore_W5'),
            ["Miss"]     = pss:GetTapNoteScores('TapNoteScore_Miss'), 
            ["Hold"]     = pss:GetTapNoteScores('TapNoteScore_CheckpointHit'),
            ["HoldMiss"] = pss:GetTapNoteScores('TapNoteScore_CheckpointMiss'), 
            ["Mines"]    = pss:GetTapNoteScores('TapNoteScore_HitMine'), 
            ["Avoided"]  = pss:GetTapNoteScores('TapNoteScore_AvoidMine'), 
            ["LetGo"]    = pss:GetHoldNoteScores('HoldNoteScore_LetGo'), 
            ["Held"]     = pss:GetHoldNoteScores('HoldNoteScore_Held'),
            ["MissHold"] = pss:GetHoldNoteScores('HoldNoteScore_MissedHold'),
            ["Digits"]   = 0,
        };
    else
        stats = {
            ["Percent"]  = 0,
            ["Score"]    = 0,
            ["Combo"]    = 0,
            ["W1"]       = 0,
            ["W2"]       = 0,
            ["W3"]       = 0,
            ["W4"]       = 0,
            ["W5"]       = 0,
            ["Miss"]     = 0,
            ["Hold"]     = 0,
            ["HoldMiss"] = 0,
            ["Mines"]    = 0,
            ["Avoided"]  = 0,
            ["LetGo"]    = 0,
            ["Held"]     = 0,
            ["MissHold"] = 0,
            ["Digits"]   = 0,
        };  
    end;

    if(PREFSMAN:GetPreference("AllowW1") == "AllowW1_Never") then
        stats["W2"] = stats["W2"] + stats["Hold"];
    else
        stats["W1"] = stats["W1"] + stats["Hold"];
    end;

    local digits = string.len(
        math.max(
            stats["Combo"],
            stats["W1"],
            stats["W2"],
            stats["W3"],
            stats["W4"],
            stats["W5"],
            stats["Miss"]
        )
    );

    stats["Digits"] = math.max(3,digits);

    stats["Miss"] = stats["Miss"] + stats["HoldMiss"];
    stats["Miss"] = stats["Miss"] + stats["MissHold"];
    return stats;
end;

local function FetchSubStats(pn)
    local table = {
        ["Percent"] = stats[pn]["Percent"] .. "%",
        ["Held"] = stats[pn]["Held"] .. " / " .. stats[pn]["LetGo"],
        ["Mines"] = stats[pn]["Mines"] .. " / " .. (stats[pn]["Mines"] + stats[pn]["Avoided"]),
    };
    return table;
end;

local dance_grade = {
    { Label = "Superb",     Key = "W1",        Color = color("#ffc4ed"),      Enabled = PREFSMAN:GetPreference("AllowW1") ~= "AllowW1_Never" },
    { Label = "Perfect",    Key = "W2",        Color = color("#6ccfff"),      Enabled = true },
    { Label = "Great",      Key = "W3",        Color = color("#a9ff63"),      Enabled = true },
    { Label = "Good",       Key = "W4",        Color = color("#ffd075"),      Enabled = true },
    { Label = "Bad",        Key = "W5",        Color = color("#ae84cf"),      Enabled = true },
    { Label = "Miss",       Key = "Miss",      Color = color("#ff5252"),      Enabled = true },
    { Label = "Max Combo",  Key = "Combo",     Color = color("#ffffff"),      Enabled = true },
    { Label = "Score",      Key = "Score",     Color = color("#ffffff"),      Enabled = true },
};

local sub_sections = {
    { Label = "Accuracy",   Key = "Percent",   Enabled = true },
    { Label = "OK  /  NG",  Key = "Held",      Enabled = ShowHoldJudgments()  },
};

if(PREFSMAN:GetPreference("AllowW1") == "AllowW1_Never") then
    dance_grade[1].Enabled = false;
end;

local t = Def.ActorFrame{
    InitCommand=function(self)
        stagestats = STATSMAN:GetCurStageStats()
        stageindex = stagestats:GetStageIndex();
        for pn in ivalues({ PLAYER_1, PLAYER_2 }) do
            pss[pn] = stagestats:GetPlayerStageStats(pn);
            stats[pn] = FetchStatsForPlayer(pn);
        end
    end
};

local originY = SCREEN_CENTER_Y-122;
local labels = Def.ActorFrame{ InitCommand=cmd(y,originY); }
local numbers = Def.ActorFrame{ InitCommand=cmd(y,originY); }
local subdata = Def.ActorFrame{ InitCommand=cmd(y,originY); }

local labelspacing = 24;
local numberspacing = 72;

-- create labels
for n=1,#dance_grade do
    labels[#labels+1] = Def.ActorFrame{
    InitCommand=cmd(x,SCREEN_CENTER_X;y,labelspacing * (n-1);zoom,0.5);
    OnCommand=cmd(diffusealpha,0;sleep,n/10;linear,0.3;diffusealpha,1);

        Def.Quad{
            InitCommand=cmd(zoomto,720,44;diffuse,BoostColor(dance_grade[n].Color,0.15);fadeleft,0.5;faderight,0.5);
            OnCommand=function(self)
                if n == #dance_grade then
                    self:diffuse(0,0,0,1);
                end;
                self:diffusealpha(0.66666666);
            end;
        },

        -- label
        Def.BitmapText{
            Font = "regen strong";
            InitCommand=cmd(zoom,0.875);
            OnCommand=function(self)
                self:settext(string.upper(dance_grade[n].Label));
                self:shadowlengthy(1.5);

                if dance_grade[n].Enabled then
                    self:diffuse(BoostColor(dance_grade[n].Color, 0.8));
                    self:diffusetopedge(BoostColor(dance_grade[n].Color, 1.5));
                    self:strokecolor(BoostColor(dance_grade[n].Color, 0.2));
                else
                    self:diffuse(0.5,0.5,0.5,1);
                    self:diffusetopedge(0.75,0.75,0.75,1);
                    self:strokecolor(0.2,0.2,0.2,1);
                end;

                if n == #dance_grade then
                    self:strokecolor(0,0,0,0.25);
                end;
            end;
        },
    }

end;

-- create data
for pn in ivalues(GAMESTATE:GetHumanPlayers()) do

    -- numbers
    for n=1,#dance_grade do
        numbers[#numbers+1] = Def.ActorFrame{
        InitCommand=cmd(x,SCREEN_CENTER_X;y,labelspacing * (n-1));
        OnCommand=cmd(diffusealpha,0;sleep,n/10;linear,0.3;diffusealpha,1);

            Def.RollingNumbers{
                Font = "eval numbers";
                InitCommand=cmd(zoom,number_zoom;x,numberspacing*pnSide(pn);horizalign,pnAlign(OtherPlayer[pn]);strokecolor,0.125,0.125,0.125,0.5);
                OnCommand=function(self)
                    self:set_chars_wide(math.max(stats[PLAYER_1]["Digits"],stats[PLAYER_2]["Digits"]));
                    self:set_leading_attribute{Diffuse= color("#777777FF")};
                    self:set_number_attribute{Diffuse= color("#FFFFFFFF")};
                    self:set_approach_seconds(1.25);

                    if dance_grade[n].Enabled then
                        self:target_number(stats[pn][dance_grade[n].Key]);
                    else
                        self:set_leading_attribute{Diffuse = color("#77777788")};
                        self:set_number_attribute{Diffuse = color("#77777788")};
                        self:target_number(0);
                    end;
                end;
            }
        }

    end;

    -- sub data
    for n=1,#sub_sections do
        subdata[#subdata+1] = Def.ActorFrame{
            InitCommand=cmd(y,100 + (n-1) * 40;x,SCREEN_CENTER_X + (210*pnSide(pn)));
            OnCommand=cmd(diffusealpha,0;sleep,1 + (n/10);linear,0.3;diffusealpha,1);

            Def.BitmapText{
                Name = "SUB LABEL";
                Font = "regen strong";
                InitCommand=cmd(vertalign,bottom;strokecolor,0.2,0.2,0.2,0.8;zoomy,0.3;zoomx,0.32;y,-18;shadowlength,1);
                OnCommand=function(self)
                    self:settext(string.upper(sub_sections[n].Label));

                    if sub_sections[n].Enabled then
                        self:diffuse(1,1,1,1);
                        self:strokecolor(0.25,0.25,0.25,1);
                    else
                        self:diffuse(0.6,0.6,0.6,1);
                        self:strokecolor(0.2,0.2,0.2,1);
                    end;
                end;
            },

            Def.BitmapText{
                Name = "SUB";
                Font = "eval numbers";
                InitCommand=cmd(vertalign,bottom;strokecolor,0.2,0.2,0.2,0.5;zoom,number_zoom;shadowlength,1);
                OnCommand=function(self)
                    if pss[pn] then 
                        local substats = FetchSubStats(pn);
                        local value = substats[sub_sections[n].Key];
                        
                        self:shadowlength(1); 
                        self:settext(string.upper(value));

                        if sub_sections[n].Key == "Percent" then
                            self:diffuse(PlayerColor(pn));
                            self:strokecolor(BoostColor(PlayerColor(pn),0.25));
                        else
                            if sub_sections[n].Enabled then
                                self:diffuse(1,1,1,1);
                                self:strokecolor(0.25,0.25,0.25,1);
                            else
                                self:settext("-");
                                self:diffuse(0.6,0.6,0.6,1);
                                self:strokecolor(0.2,0.2,0.2,1);
                            end;
                        end;
                    end;
                end;
            }
        }
    end;

    -- grade
    subdata[#subdata+1] = Def.ActorFrame{
        InitCommand=cmd(y,20;x,SCREEN_CENTER_X + (210*pnSide(pn)));
        OnCommand=cmd(diffusealpha,0;zoom,2;sleep,2;linear,0.15;diffusealpha,1;zoom,1);

        Def.BitmapText{
            Name = "GRADE";
            Font = "bebas neue";
            InitCommand=cmd(strokecolor,0.2,0.2,0.2,0.8;zoomy,0.55;zoomx,0.65;skewx,-0.15);
            OnCommand=function(self)
                if pss[pn] then 
                    if IsGame("pump") then
                        self:settext(FormatGradePIU(PIUGrading(pn)));
                    else
                        self:settext(FormatGrade(pss[pn]:GetGrade()));
                    end;
                    self:diffuse(PlayerColor(pn));
                    self:strokecolor(BoostColor(PlayerColor(pn),0.25)); 
                end;
            end;
        },
        Def.BitmapText{
            Name = "AWARD";
            Font = "neotech";
            InitCommand=cmd(strokecolor,0.2,0.2,0.2,0.8;zoom,0.4;y,24);
            OnCommand=function(self)
                if pss[pn] then 
                    self:settext(FormatAward(pss[pn]:GetStageAward()));
                    self:diffuseshift();
                    self:effectcolor1(PlayerColor(pn));
                    self:effectcolor2(1,1,1,1);
                    self:effectperiod(0.5);
                    self:strokecolor(BoostColor(PlayerColor(pn),0.25)); 
                end;
            end;
        },
    }

    -- separator 1
    t[#t+1] = Def.Quad{
        InitCommand=cmd(zoomto,560,1;diffuse,1,1,1,0.2;x,SCREEN_CENTER_X;y,297);
    }

end;

local o_zoom = 0.3175;
local soptions = Def.ActorFrame{
    InitCommand=cmd(y,SCREEN_CENTER_Y + 64;x,SCREEN_CENTER_X);
    OnCommand=cmd(stoptweening;diffusealpha,0;sleep,0.75;linear,0.5;diffusealpha,0.5);

    -- rate
    Def.BitmapText{
        Font = "regen strong";
        InitCommand=cmd(horizalign,left;vertalign,top;zoom,o_zoom;x,-274;
            strokecolor,0.2,0.2,0.2,1;shadowlength,1.25);
        OnCommand=function(self)
            local s_options = GAMESTATE:GetSongOptionsObject("ModsLevel_Current");
            self:settext(string.upper("Music Rate: " .. math.round(s_options:MusicRate()*100).."%"));
        end;
    },

    -- failtype
    Def.BitmapText{
        Font = "regen strong";
        InitCommand=cmd(horizalign,right;vertalign,top;zoom,o_zoom;x,274;
            strokecolor,0.2,0.2,0.2,1;shadowlength,1.25);
        OnCommand=function(self)
            local p_options = GAMESTATE:GetPlayerState(Global.master):GetPlayerOptions("ModsLevel_Current");
            self:settext(string.upper("Fail Type: " .. FormatFailType(p_options:FailSetting())));
        end;
    },

    -- gamemode
    Def.BitmapText{
        Font = "regen strong";
        InitCommand=cmd(vertalign,top;zoom,o_zoom;
            strokecolor,0.2,0.2,0.2,1;shadowlength,1.25);
        OnCommand=function(self)
            local game = GAMESTATE:GetCurrentGame():GetName();
            self:settext(string.upper("Game: " .. game));
        end;
    },
}



t[#t+1] = labels;
t[#t+1] = numbers;
t[#t+1] = subdata;
t[#t+1] = soptions;





return t;