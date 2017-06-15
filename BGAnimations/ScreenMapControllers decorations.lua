local t = Def.ActorFrame{}

t[#t+1] = LoadActor(THEME:GetPathG("","bg"))..{
    InitCommand=cmd(FullScreen;croptop,0.75;fadetop,0.1;diffuse,Global.bgcolor);
}

t[#t+1] = LoadActor(THEME:GetPathB("ScreenWithMenuElements", "decorations"));



return t;