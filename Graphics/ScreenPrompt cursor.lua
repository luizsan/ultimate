return Def.ActorFrame{

    LoadActor(THEME:GetPathG("","glow"))..{
       InitCommand=cmd(setsize,164,64;cropbottom,0.5;valign,0.25;diffuse,HighlightColor(0.2));
    },

    Def.Quad{
       InitCommand=cmd(y,16;setsize,164,1;fadeleft,0.5;faderight,0.5;diffuse,HighlightColor());
    },

};