local t = Def.ActorFrame{}

local spacing = 244;
local originY = SCREEN_BOTTOM-70+10;


--//================================================================
-- filter words 

function FilterStepmaker(maker)
	local filter = false;
	local bannedwords = {
		"blank",
		"beginner",
		"easy",
		"medium",
		"normal",
		"standard",
		"hard",
		"crazy",
		"heavy",
		"oni",
		"challenge",
		"freestyle",
		"nightmare",
		"steps",
		"solo",
		"single",
		"double",
		"routine",
		"halfdouble",
		"half-double",
		"performance"
	};

	for i=1,#bannedwords do
		if string.lower(tostring(maker)) == bannedwords[i] then
			filter = true;
		end
	end;	
	if filter then return "" else return tostring(maker) end;
end;

--//================================================================

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do 
		
	t[#t+1] = Def.ActorFrame{
		StateChangedMessageCommand=function(self)
			self:visible(GAMESTATE:IsSideJoined(pn));
			self:stoptweening();
			self:decelerate(0.2);
			if Global.state == "GroupSelect" then 
				self:diffusealpha(0);
			else
				self:diffusealpha(1);
			end;
		end;

		LoadActor(THEME:GetPathG("","dim"))..{
			InitCommand=cmd(zoomto,364,96;y,originY-2;diffuse,BoostColor(Global.bgcolor,0.75);fadeleft,0.66666;faderight,0.66666;playcommand,"SetX");
			SetXCommand=function(self) self:x(SCREEN_CENTER_X+((spacing-30)*pnSide(pn))); end;
		};
		
		LoadActor(THEME:GetPathG("","separator"))..{
			InitCommand=cmd(zoom,0.45;y,originY-5;diffuse,0,0,0,0.5;playcommand,"SetX");
			SetXCommand=function(self) self:x(SCREEN_CENTER_X+((spacing+1)*pnSide(pn))); end;
		};

		LoadFont("regen silver")..{
				InitCommand=cmd(zoom,0.5;y,originY-2;strokecolor,0.15,0.15,0.15,1;playcommand,"SetX";playcommand,"MusicWheel");
				SetXCommand=function(self) if pn == PLAYER_1 then self:x(SCREEN_CENTER_X-spacing-8-17); elseif pn == PLAYER_2 then self:x(SCREEN_CENTER_X+spacing+10+17); end; end;
				StepsChangedMessageCommand=function(self)
					if Global.pncursteps[pn] and GAMESTATE:IsSideJoined(pn) then
						local value = FormatMeter(Global.pncursteps[pn]:GetMeter());
						self:settext(value);		
					end;
				end;
		};
		
		LoadFont("regen silver")..{
				InitCommand=cmd(vertalign,bottom;zoom,0.33;y,originY-10;strokecolor,0.2,0.2,0.2,1;vertspacing,-30.9;playcommand,"SetX");--;playcommand,"MusicWheel");
				SetXCommand=function(self) if pn == PLAYER_1 then self:x(SCREEN_CENTER_X-spacing-8-18); elseif pn == PLAYER_2 then self:x(SCREEN_CENTER_X+spacing+10+17); end; end;
				StepsChangedMessageCommand=function(self)
					if Global.pncursteps[pn] and GAMESTATE:IsSideJoined(pn) then
						self:settext(string.lower(PureType(Global.pncursteps[pn])));
					
						local tint;
						local steps = Global.pncursteps[pn];

						if PureType(steps) == "Single" then
							tint = {0.95,0.75,0.1,1};				
						elseif PureType(steps) == "Double" then
							tint = {0.2,0.9,0.2,1};	
						elseif PureType(steps) == "Halfdouble" then
							self:settext("halfdb");
							tint = {0.8,0.1,0.6,1};	
						elseif PureType(steps) == "Routine" then
							tint = {0.3,0.85,1,1};
						elseif PureType(steps) == "Solo" or PureType(steps) == "Couple" then
							tint = {1,0.5,0.5,1};
						end
						
						self:diffuse(tint);
						self:diffusetopedge(BoostColor(tint,8));
						self:strokecolor(BoostColor(tint,0.2));
					end;
				end;
		};
		
		LoadFont("neotech")..{
				InitCommand=cmd(horizalign,left;zoom,0.4;y,originY-13;strokecolor,0.2,0.2,0.2,1;maxwidth,560;playcommand,"SetX";playcommand,"MusicWheel");
				SetXCommand=function(self) if pn == PLAYER_1 then self:x(SCREEN_CENTER_X-spacing+8); self:horizalign(left); elseif pn == PLAYER_2 then self:x(SCREEN_CENTER_X+spacing-10); self:horizalign(right); end; end;
				StepsChangedMessageCommand=function(self)
					if Global.pncursteps[pn] and GAMESTATE:IsSideJoined(pn) then
						local maker = Global.pncursteps[pn]:GetAuthorCredit()
						maker = FilterStepmaker(maker);
						
						if tostring(maker)=="" then
							self:settext("<Unknown Step Author>");
							self:diffuse(0.7,0.7,0.7,0.8);
						else
							self:settext("Steps by "..maker);
							self:diffuse(1,1,1,1);
						end
					end;
				end;
		};
		
		LoadFont("neotech")..{
				InitCommand=cmd(horizalign,left;zoom,0.4;y,originY;diffuse,BoostColor(PlayerColor(pn),0.95);strokecolor,BoostColor(PlayerColor(pn),0.25);maxwidth,560;playcommand,"SetX";playcommand,"MusicWheel");
				SetXCommand=function(self) if pn == PLAYER_1 then self:x(SCREEN_CENTER_X-spacing+8); self:horizalign(left); elseif pn == PLAYER_2 then self:x(SCREEN_CENTER_X+spacing-10); self:horizalign(right); end; end;
				StepsChangedMessageCommand=function(self)
					if Global.pncursteps[pn] and GAMESTATE:IsSideJoined(pn) then
						--self:settext("Avg. notes/sec: "..AvgNotesSec(steps,pn));
						self:settext("Total notes: "..TotalNotes(Global.pncursteps[pn],pn));
					end;
				end;
		};
		
	};
		
	
end;


return t