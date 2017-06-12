local style;
local master;
local source;

if (Var "LoadingScreen") == "ScreenThemeSettings" then
	source = PLAYER_2;
	style = 'TwoPlayersTwoSides';
	master = PLAYER_2;
else
	source = GAMESTATE:GetHumanPlayers();
	style = GAMESTATE:GetCurrentStyle():GetStyleType();
	master = GAMESTATE:GetMasterPlayerNumber();
end;

local posY = SCREEN_CENTER_Y+(THEME:GetMetric("Player","ReceptorArrowsYStandard"))-46;

local lifeP1 = 0.5
local lifeP2 = 0.5
local lifeMaster = 0.5


local t = Def.ActorFrame{
	InitCommand=cmd(SetUpdateFunction,UpdateGameplay);

	OnCommand=function(self)
		Global.disqualified = false;
		if IsRoutine() then
			if Global.master == PLAYER_1 then
				find_pactor_in_gameplay(SCREENMAN:GetTopScreen(), PLAYER_2):hibernate(math.huge);
			else
				find_pactor_in_gameplay(SCREENMAN:GetTopScreen(), PLAYER_1):hibernate(math.huge);
			end;
		end;
	end;
	
	PausedMessageCommand=function(self) Global.disqualified = true; end;
	LifeChangedMessageCommand=function(self,params)
	
		if params.Player == PLAYER_1 then
			lifeP1=params.LifeMeter:GetLife();
		end
		if params.Player == PLAYER_2 then
			lifeP2=params.LifeMeter:GetLife();
		end
		
		if master == PLAYER_1 then lifeMaster = lifeP1 
		elseif master == PLAYER_2 then lifeMaster = lifeP2 end;

	end;

}

--[[

for pn in ivalues(source) do

	if Var "LoadingScreen" == "ScreenGameplay" then
	t[#t+1] = LoadActor("decoration")..{
		InitCommand=cmd(horizalign,left;vertalign,top;zoomy,0.475;blend,Blend.Add;diffuse,0.75,0.9,1,0.66;diffusebottomedge,0.66,0.85,1,0.25);
		OnCommand=function(self)
			if pn == PLAYER_1 then self:zoomx(0.725); self:x(SCREEN_LEFT); elseif pn == PLAYER_2 then self:x(SCREEN_RIGHT); self:zoomx(-0.725) end;
		end;
	};
	
	end;
end


if style == 'StyleType_OnePlayerTwoSides' or 
	style == 'StyleType_TwoPlayersSharedSides' then
	
			t[#t+1] = LoadActor("basemeter")..{
				InitCommand=cmd(y,posY-8;zoomx,0.45;zoomy,-0.45;CenterX;zoomx,(SCREEN_WIDTH-90)/400;diffuse,0.4,0.4,0.4,0.7;animate,false);
				LifeChangedMessageCommand=function(self) if lifeMaster <= 0.2 then self:setstate(1); else self:setstate(0); end; end;
			};
			
			t[#t+1] = Def.Quad{
				InitCommand=cmd(y,posY;x,SCREEN_CENTER_X;zoomto,100,20;horizalign,left;bounce;effectmagnitude,(SCREEN_WIDTH/15)*-1,0,0;effectclock,"bgm";effecttiming,1,0,0,0;MaskSource;);
				LifeChangedMessageCommand=function(self)
					self:x((lifeMaster-0.5)*(SCREEN_WIDTH-90) + (SCREEN_WIDTH/2));
							if lifeMaster==1 then
								self:visible(false);
							else
								self:visible(true);
							end
				end;
			};

			t[#t+1] = LoadActor("basemeter")..{
				InitCommand=cmd(y,posY+5;zoom,0.475;x,50;horizalign,left;zoomx,(SCREEN_WIDTH-90)/400;cropright,0.5;MaskDest;blend,Blend.Add;animate,false);
				LifeChangedMessageCommand=function(self)
				self:cropright(1-lifeMaster);
				end;
			};

			t[#t+1] = LoadActor("basemeter")..{
				InitCommand=cmd(x,50;y,posY+5;horizalign,right;zoom,0.475;;zoomx,10/400;blend,Blend.Add;animate,false);
			};
			
			
			
				t[#t+1] = LoadActor("hot_lores")..{
					InitCommand=cmd(y,math.ceil(posY);CenterX;diffuse,0.5,0.75,0.95,0);
					OnCommand=cmd(zoomto,SCREEN_WIDTH-90,39.1;customtexturerect,0,0,1,1;blend,Blend.Add;texcoordvelocity,0.33,0);
					LifeChangedMessageCommand=function(self) if lifeMaster == 1 then self:stoptweening(); self:decelerate(1); self:diffusealpha(1);
					else self:stoptweening(); self:decelerate(0.1); self:diffusealpha(0); end;
					end;
				};
				
				
				
			for pn=1,2 do

								t[#t+1] = LoadActor("mask")..{
								InitCommand=cmd(y,posY;zoomx,0.475;zoomy,0.42;horizalign,left);
								OnCommand=function(self) 
										if pn == 1 then self:x(SCREEN_LEFT-10);
										elseif pn == 2 then self:x(SCREEN_RIGHT+10); end;
										self:zoomx(0.475*pnSide(pn)*-1);
									end;
								};
								
								t[#t+1] = LoadActor("corner")..{
									InitCommand=cmd(y,posY-0.5;zoom,0.375;horizalign,left);
									OnCommand=function(self) 
										if pn == 1 then self:x(SCREEN_LEFT+40);
										elseif pn == 2 then self:x(SCREEN_RIGHT-40); end;
										self:zoomx(0.375*pnSide(pn)*-1);
									end;
									LifeChangedMessageCommand=function(self) if lifeMaster <= 0.2 then self:diffuseshift(); self:effectcolor1(1,1,1,1); self:effectcolor2(1,0.5,0.33,1); self:effectperiod(0.05); else self:stopeffect(); end; end;
								};
			end
		
			
								t[#t+1] = LoadActor("frame")..{
									InitCommand=cmd(y,posY-0.5;CenterX);
									OnCommand=cmd(zoomto,SCREEN_WIDTH-155,100*0.375;customtexturerect,0,0,1,1);
									LifeChangedMessageCommand=function(self) if lifeMaster <= 0.2 then self:diffuseshift(); self:effectcolor1(1,1,1,1); self:effectcolor2(1,0.5,0.33,1); self:effectperiod(0.05); else self:stopeffect(); end; end;
								};
								
							t[#t+1] = LoadActor("tip")..{
									InitCommand=cmd(y,math.ceil(posY)+4;animate,false;;blend,Blend.Add);
									OnCommand=cmd(zoomy,0.475;zoomx,0.666);
									LifeChangedMessageCommand=function(self) 
									if lifeMaster <= 0.2 then self:setstate(1) self:visible(true) else self:setstate(0) end;
									self:x((lifeMaster-0.5)*(SCREEN_WIDTH-102) + (SCREEN_WIDTH/2));
									end;
							};
							
							t[#t+1] = LoadActor("tip")..{
									InitCommand=cmd(y,math.ceil(posY)+4;animate,false;diffusealpha,0.25);
									OnCommand=cmd(zoomy,0.475;zoomx,0.666);
									LifeChangedMessageCommand=function(self) 
									if lifeMaster <= 0.2 then self:setstate(1) self:visible(true) else self:setstate(0) end;
									self:x((lifeMaster-0.5)*(SCREEN_WIDTH-102) + (SCREEN_WIDTH/2));
									end;
							};
				
else

			for pn in ivalues(source) do

					t[#t+1] = Def.ActorFrame{
					InitCommand=cmd(horizalign,left;);
					OnCommand=function(self) 
						if pn == PLAYER_1 then self:zoomx(1); self:x(SCREEN_LEFT+40);
						elseif pn == PLAYER_2 then self:zoomx(-1); self:x(SCREEN_RIGHT-40); end; end;	
						
						
						
						
							LoadActor("basemeter")..{
								InitCommand=cmd(horizalign,left;y,posY-8;zoomy,-0.45;;zoomx,(((SCREEN_WIDTH-130)/400)/2);diffuse,0.4,0.4,0.4,0.7;animate,false);
								LifeChangedMessageCommand=function(self) 
								if pn	 == PLAYER_1 then lifeSelf = lifeP1; 
								self:player(pn);
								elseif pn == PLAYER_2 then lifeSelf = lifeP2; end;
								if lifeSelf <= 0.2 then self:setstate(1); else self:setstate(0); end; end;
								};
			
			
							LoadActor("basemeter")..{
								InitCommand=cmd(x,14;y,posY+5;horizalign,right;zoom,0.475;;zoomx,10/400;blend,Blend.Add;animate,false);
							};
			
			
							 Def.Quad{
								InitCommand=cmd(y,posY;x,0.5*((SCREEN_WIDTH-120)/2);horizalign,left;zoomto,40,20;horizalign,left;bounce;effectmagnitude,-40,0,0;effectclock,"bgm";effecttiming,1,0,0,0;MaskSource;);
								LifeChangedMessageCommand=function(self)
									self:stoptweening();
									self:decelerate(0.25);
									local lifeSelf;
									if pn == PLAYER_1 then lifeSelf = lifeP1 elseif pn == PLAYER_2 then lifeSelf = lifeP2 end; 
									self:x(  8+  lifeSelf*((SCREEN_WIDTH-120)/2)    );
									if lifeSelf == 1 then self:visible(false) else self:visible(true) end;
								end;
							};

							
							LoadActor("basemeter")..{
								InitCommand=cmd(x,14;y,posY+5;horizalign,left;zoom,0.475;;zoomx,((SCREEN_WIDTH-156)/400)/2;cropright,0.5;MaskDest;blend,Blend.Add;animate,false);
								LifeChangedMessageCommand=function(self)
								local lifeSelf;
								if pn == PLAYER_1 then lifeSelf = lifeP1 elseif pn == PLAYER_2 then lifeSelf = lifeP2 end; 
								self:cropright(1-lifeSelf);
								--if lifeSelf <= 0.2 then self:setstate(1) else self:setstate(0); end;
								end;
							};

							
							LoadActor("hot_lores")..{
									InitCommand=cmd(y,math.ceil(posY);horizalign,left;diffuse,0.5,0.75,0.95,0);
									OnCommand=cmd(zoomto,(SCREEN_WIDTH-130)/2,39.1;customtexturerect,0,0,1,1;blend,Blend.Add;texcoordvelocity,0.33,0);
									LifeChangedMessageCommand=function(self) 
									local lifeSelf;
									if pn == PLAYER_1 then lifeSelf = lifeP1 elseif pn == PLAYER_2 then lifeSelf = lifeP2 end; 
									if lifeSelf == 1 then self:stoptweening(); self:decelerate(1); self:diffusealpha(1);
									else self:stoptweening(); self:decelerate(0.1); self:diffusealpha(0); end;
									end;
							};

			
							LoadActor("mask")..{
							InitCommand=cmd(y,posY;zoomx,0.475;zoomy,0.42;horizalign,left;x,-50);
							};
						
							
							 LoadActor("corner")..{
									InitCommand=cmd(y,posY-0.5;zoom,0.375;horizalign,left);
									LifeChangedMessageCommand=function(self) 
									local lifeSelf;
									if pn == PLAYER_1 then lifeSelf = lifeP1 elseif pn == PLAYER_2 then lifeSelf = lifeP2 end;
									if lifeSelf <= 0.2 then self:diffuseshift(); self:effectcolor1(1,1,1,1); self:effectcolor2(1,0.5,0.33,1); self:effectperiod(0.05); else self:stopeffect(); end; end;
							};
							
							
							LoadActor("frame")..{
									InitCommand=cmd(y,posY-0.5;horizalign,left;x,37.5);
									OnCommand=cmd(zoomto,(SCREEN_WIDTH-238)/2-10,100*0.375;customtexturerect,0,0,1,1);
									LifeChangedMessageCommand=function(self) 
									local lifeSelf;
									if pn == PLAYER_1 then lifeSelf = lifeP1 elseif pn == PLAYER_2 then lifeSelf = lifeP2 end; 
									if lifeSelf <= 0.2 then self:diffuseshift(); self:effectcolor1(1,1,1,1); self:effectcolor2(1,0.5,0.33,1); self:effectperiod(0.05); else self:stopeffect(); end; end;
							};
							
							
							 LoadActor("center")..{
									InitCommand=cmd(y,posY-0.5;zoom,0.375;zoomx,-0.375;horizalign,left;x,(SCREEN_WIDTH-108)/2);
									LifeChangedMessageCommand=function(self) 
									local lifeSelf;
									if pn == PLAYER_1 then lifeSelf = lifeP1; elseif pn == PLAYER_2 then lifeSelf = lifeP2; end;
									if lifeSelf <= 0.2 then self:diffuseshift(); self:effectcolor1(1,1,1,1); self:effectcolor2(1,0.5,0.33,1); self:effectperiod(0.05); else self:stopeffect(); end; end;
							};
											
							LoadActor("tip")..{
									InitCommand=cmd(y,math.ceil(posY)+5;animate,false;;blend,Blend.Add);
									OnCommand=cmd(zoomy,0.475;zoomx,0.666;x,12+ 0.5*((SCREEN_WIDTH-160)/2)  );
									LifeChangedMessageCommand=function(self) 
									local lifeSelf;
									if pn == PLAYER_1 then lifeSelf = lifeP1 elseif pn == PLAYER_2 then lifeSelf = lifeP2 end;
									if lifeSelf == 0 then self:visible(false); else self:visible(true); end;
									if lifeSelf <= 0.2 then self:setstate(1) self:visible(true) else self:setstate(0) end;
									self:x(  12+ lifeSelf*((SCREEN_WIDTH-160)/2)    );
									end;
							};
							LoadActor("tip")..{
									InitCommand=cmd(y,math.ceil(posY)+5;animate,false;diffusealpha,0.25);
									OnCommand=cmd(zoomy,0.475;zoomx,0.666;x,12+ 0.5*((SCREEN_WIDTH-160)/2) );
									LifeChangedMessageCommand=function(self) 
									local lifeSelf;
									if pn == PLAYER_1 then lifeSelf = lifeP1 elseif pn == PLAYER_2 then lifeSelf = lifeP2 end;
									if lifeSelf == 0 then self:visible(false); else self:visible(true); end;
									if lifeSelf <= 0.2 then self:setstate(1) self:visible(true) else self:setstate(0) end;
									self:x(  12+ lifeSelf*((SCREEN_WIDTH-160)/2)    );
									end;
							};
							
							
				
				
					};
		
			end	
end;

]]




t[#t+1] = Def.Quad{
	OnCommand=function(self,params)
		local s = SCREENMAN:GetTopScreen();
		local player = s:GetChild("Player" .. ToEnumShortString(Global.master))
		local field = player:GetChild("NoteField");

		self:x(player:GetX());
		self:y(player:GetY());
		self:zoomto(field:get_width(), 16);
	end;
}

t[#t+1] = LoadActor("assets/pause");

if not VersionBranch("5.0") then
	t[#t+1] = notefield_prefs_actor();
	t[#t+1] = notefield_mods_actor()
end;

return t;