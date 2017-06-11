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
		InitCommand=cmd(x,SCREEN_CENTER_X + 260 * pnSide(pn);y,SCREEN_BOTTOM-64);
		OnCommand=cmd(stoptweening;diffusealpha,0;sleep,0.5;linear,0.5;diffusealpha,1);
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
			InitCommand=cmd(zoomto,364,96;diffuse,BoostColor(Global.bgcolor,0.75);fadeleft,0.66666;faderight,0.66666;x,64 + pnSide(pn));
		};
		
		LoadActor(THEME:GetPathG("","separator"))..{
			InitCommand=cmd(zoom,0.45;x,24 * -pnSide(pn);diffuse,0,0,0,0.5);
		};

		-- meter
		Def.BitmapText{
				Font = "regen silver";
				InitCommand=cmd(zoom,0.5;strokecolor,0.15,0.15,0.15,1);
				OnCommand=cmd(playcommand,"Refresh");
				StepsChangedMessageCommand=cmd(playcommand,"Refresh");
				RefreshCommand=function(self)
					if Global.pncursteps[pn] and GAMESTATE:IsSideJoined(pn) then
						local value = FormatMeter(Global.pncursteps[pn]:GetMeter());
						self:settext(value);		
					end;
				end;
		};
		
		-- stepstype
		Def.BitmapText{
				Font = "regen silver";
				InitCommand=cmd(vertalign,bottom;zoom,0.33;strokecolor,0.2,0.2,0.2,1;y,-8);
				OnCommand=cmd(playcommand,"Refresh");
				StepsChangedMessageCommand=cmd(playcommand,"Refresh");
				RefreshCommand=function(self)
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
		
		-- maker
		Def.BitmapText{
				Font = "neotech";
				InitCommand=cmd(horizalign,pnAlign(pn);x,34 * -pnSide(pn);y,-11;zoom,0.4;strokecolor,0.2,0.2,0.2,1;maxwidth,560);
				OnCommand=cmd(playcommand,"Refresh");
				StepsChangedMessageCommand=cmd(playcommand,"Refresh");
				RefreshCommand=function(self)
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
		
		-- notes
		Def.BitmapText{
				Font = "neotech";
				InitCommand=cmd(horizalign,pnAlign(pn);x,34 * -pnSide(pn);y,3;zoom,0.4;diffuse,BoostColor(PlayerColor(pn),0.95);strokecolor,BoostColor(PlayerColor(pn),0.25);maxwidth,560);
				OnCommand=cmd(playcommand,"Refresh");
				StepsChangedMessageCommand=cmd(playcommand,"Refresh");
				RefreshCommand=function(self)
					if Global.pncursteps[pn] and GAMESTATE:IsSideJoined(pn) then
						--self:settext("Avg. notes/sec: "..AvgNotesSec(steps,pn));
						self:settext("Total notes: "..TotalNotes(Global.pncursteps[pn],pn));
					end;
				end;
		};
		
	};
		
	
end;


return t