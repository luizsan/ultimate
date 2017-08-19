return Def.ActorFrame{  
    LoadActor(THEME:GetPathB("ScreenWithMenuElements", "decorations")),
    LoadActor(THEME:GetPathB("ScreenWithMenuElements", "background"))..{
        InitCommand=cmd(diffusealpha,0);
        OnCommand=cmd(linear,0.25;diffusealpha,1);
    }
}