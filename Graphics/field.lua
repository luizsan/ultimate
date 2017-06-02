local t = Def.ActorFrame{}
local snow = 120; --number of particles


for i=1,snow do 

local size = math.random(2,4);

t[#t+1] = Def.Quad{
	InitCommand=cmd(zoomto,size,size);
	OnCommand=cmd(x,math.random(-40,SCREEN_WIDTH);y,-40;sleep,i/10;queuecommand,"Fall");
	FallCommand=function(self)
		self:stoptweening();
		
		self:x(math.random(-40,SCREEN_WIDTH));
		self:y(-40);
		
		self:bob();
		self:effectmagnitude(math.random(1,10),0,0);
		
		self:linear(size*5);
		self:addy(SCREEN_HEIGHT+40);
		self:sleep(math.random(1,5));
		self:queuecommand("Fall");
	end;


};

end;

t[#t+1] = Def.Actor{
	OnCommand=cmd(sleep,GAMESTATE:GetCurrentSong():GetStepsSeconds()+5);
};

return t;