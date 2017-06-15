local t = Def.ActorFrame{}

local dp_spacing = 14;
local spacing = 260;
local originY = SCREEN_CENTER_Y + 86;

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
    if SideJoined(pn) then

        t[#t+1] = Def.ActorFrame{
            InitCommand=cmd(x,SCREEN_CENTER_X + (spacing * pnSide(pn));y,originY;diffusealpha,0);
             OnCommand=cmd(diffusealpha,0;sleep,2.5;linear,0.3;diffusealpha,1);


            -- machine label
            Def.BitmapText{
                Font = Fonts.eval["Scores"];
                Text = "Machine Best";
                InitCommand=cmd(horizalign,pnAlign(pn);zoom,0.42;diffuse,PlayerColor(pn);strokecolor,BoostColor(PlayerColor(pn),0.25));
            },

            -- machine
            Def.BitmapText{
                Font = Fonts.eval["Scores"];
                InitCommand=cmd(horizalign,pnAlign(pn);zoom,0.42;strokecolor,0.2,0.2,0.2,1;y,dp_spacing);
                OnCommand=function(self)
                    local machine = PROFILEMAN:GetMachineProfile();
                    local score = GetTopScoreForProfile(Global.song, Global.pncursteps[pn], machine);
                    if score then
                        self:settext(FormatDP(score:GetPercentDP()));
                    else
                        self:diffuse(0.6,0.6,0.6,1);
                        self:settext("<none>");
                    end;
                end;
            },
        };

        t[#t+1] = Def.ActorFrame{
            InitCommand=cmd(x,SCREEN_CENTER_X + (spacing * pnSide(pn));y,originY+36;diffusealpha,0);
             OnCommand=cmd(diffusealpha,0;sleep,2.5;linear,0.3;diffusealpha,1);

            -- pb label
            Def.BitmapText{
                Font = Fonts.eval["Scores"];
                Text = "Your Best";
                InitCommand=cmd(horizalign,pnAlign(pn);zoom,0.42;diffuse,PlayerColor(pn);strokecolor,BoostColor(PlayerColor(pn),0.25));
            },

            -- pb
            Def.BitmapText{
                Font = Fonts.eval["Scores"];
                InitCommand=cmd(horizalign,pnAlign(pn);zoom,0.42;strokecolor,0.2,0.2,0.2,1;y,dp_spacing);
                OnCommand=function(self)
                    local player = PROFILEMAN:GetProfile(pn);
                    local score = GetTopScoreForProfile(Global.song, Global.pncursteps[pn], player);
                    if score then
                        self:settext(FormatDP(score:GetPercentDP()));
                    else
                        self:diffuse(0.6,0.6,0.6,1);
                        self:settext("<none>");
                    end;
                end;
            },

        };

    end;
end;

return t;