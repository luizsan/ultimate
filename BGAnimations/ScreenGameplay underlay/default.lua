local t = Def.ActorFrame{}

t[#t+1] = LoadActor("assets/filter");
t[#t+1] = LoadActor("assets/counter")..{
    InitCommand=cmd(diffusealpha,0);
    OnCommand=cmd(sleep,1;decelerate,0.5;diffusealpha,1);
};

return t;