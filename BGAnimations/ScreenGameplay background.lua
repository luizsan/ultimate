local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
local defbg = tconf.DefaultBG;
local bgdif = tconf.BGBrightness/100;

if defbg then
    return LoadActor(THEME:GetPathG("Common fallback","background"))..{
        InitCommand=cmd(FullScreen;diffuse,bgdif,bgdif,bgdif,1);
    }
else
    return Def.ActorFrame {
        Name = ":thinking:";
    };
end;