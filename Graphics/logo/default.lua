local t = Def.ActorFrame{}

t[#t+1] = LoadActor("base");
t[#t+1] = LoadActor("glow")..{
	InitCommand=cmd(diffusealpha,0;queuecommand,"Loop");
	LoopCommand=cmd(stoptweening;linear,1.25;diffusealpha,1;linear,1.5;diffusealpha,0;sleep,3)
};
t[#t+1] = LoadActor("glow")..{
	InitCommand=cmd(fadeleft,0;faderight,1;queuecommand,"Loop");
	LoopCommand=cmd(stoptweening;cropleft,0;cropright,1;fadeleft,0;faderight,1;linear,1.25;cropright,0.1;fadeleft,0.5;faderight,0.5;linear,1.25;cropleft,0.9;cropright,0;linear,1.25;cropleft,1;cropright,0;fadeleft,1;faderight,0;;sleep,3)
};
t[#t+1] = LoadActor("blur")..{
	InitCommand=cmd(fadeleft,0;faderight,1;queuecommand,"Loop");
	LoopCommand=cmd(stoptweening;cropleft,0;cropright,1;fadeleft,0;faderight,1;linear,1.25;cropright,0.1;fadeleft,0.5;faderight,0.5;linear,1.25;cropleft,0.9;cropright,0;linear,1.25;cropleft,1;cropright,0;fadeleft,1;faderight,0;sleep,3)
};

return t;