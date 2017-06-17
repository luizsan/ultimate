local t = Def.ActorFrame{}

local spacing = 272;
local originY = SCREEN_BOTTOM-64

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
		InitCommand=cmd(x,SCREEN_CENTER_X + spacing * pnSide(pn);y,originY);
		OnCommand=cmd(stoptweening;diffusealpha,0;sleep,0.5;linear,0.5;diffusealpha,1;visible,SideJoined(pn));
		StateChangedMessageCommand=function(self)
			self:stoptweening();
			self:decelerate(0.2);
			if Global.state == "GroupSelect" then 
				self:diffusealpha(0);
			else
				self:diffusealpha(1);
			end;
		end;

		LoadActor(THEME:GetPathG("","dim"))..{
			InitCommand=cmd(zoomto,364,96;diffuse,BoostColor(Global.bgcolor,0.75);fadeleft,0.66666;faderight,0.66666;x,64 * -pnSide(pn));
		};
		
		LoadActor(THEME:GetPathG("","separator"))..{
			InitCommand=cmd(zoom,0.45;x,25 * -pnSide(pn);y,-2;diffuse,0,0,0,0.5);
		};

		-- meter
		Def.BitmapText{
				Font = Fonts.cursteps["Meter"];
				InitCommand=cmd(zoom,0.5;strokecolor,0.15,0.15,0.15,1);
				OnCommand=cmd(playcommand,"Refresh");
				StepsChangedMessageCommand=cmd(playcommand,"Refresh");
				RefreshCommand=function(self)
					if Global.pncursteps[pn] then
						local steps = Global.pncursteps[pn] 
						if TotalNotes(steps,pn) == 0 then
							self:settext("00");
						else
							local value = FormatMeter(steps:GetMeter());
							self:settext(FormatMeter(steps:GetMeter()));
						end		
					end;
				end;
		};
		
		-- stepstype
		Def.BitmapText{
				Font = Fonts.cursteps["Type"];
				InitCommand=cmd(vertalign,bottom;zoom,0.3;strokecolor,0.2,0.2,0.2,0.5;y,-10;x,-1);
				OnCommand=cmd(playcommand,"Refresh");
				StepsChangedMessageCommand=cmd(playcommand,"Refresh");
				RefreshCommand=function(self)
					if Global.pncursteps[pn] then
						local steps = Global.pncursteps[pn]
						self:settext(string.upper(PureType(steps)));
					
						local tint = StepsColor(steps);

						if PureType(steps) == "Halfdouble" then
							self:settext(string.upper("halfdb"));
						end
						
						self:diffuse(tint);
						self:diffusetopedge(BoostColor(tint,8));
						self:strokecolor(BoostColor(tint,0.3));
					end;
				end;
		};
		
		-- maker
		Def.BitmapText{
				Font = Fonts.cursteps["Info"];
				InitCommand=cmd(horizalign,pnAlign(pn);x,36 * -pnSide(pn);y,-11;zoom,0.4;strokecolor,0.2,0.2,0.2,1;maxwidth,560);
				OnCommand=cmd(playcommand,"Refresh");
				StepsChangedMessageCommand=cmd(playcommand,"Refresh");
				RefreshCommand=function(self)
					if Global.pncursteps[pn] then
						local steps = Global.pncursteps[pn]
						local maker = steps:GetAuthorCredit()
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
				Font = Fonts.cursteps["Info"];
				InitCommand=cmd(horizalign,pnAlign(pn);x,36 * -pnSide(pn);y,3;zoom,0.4;diffuse,BoostColor(PlayerColor(pn),0.95);strokecolor,BoostColor(PlayerColor(pn),0.3);maxwidth,560);
				OnCommand=cmd(playcommand,"Refresh");
				StepsChangedMessageCommand=cmd(playcommand,"Refresh");
				RefreshCommand=function(self)
					if Global.pncursteps[pn] then
						local steps = Global.pncursteps[pn]
						self:settext("Avg. notes/sec: "..AvgNotesSec(steps,pn));
						--self:settext("Total notes: "..TotalNotes(steps,pn));
						--self:settext("Predicted meter: "..steps:PredictMeter());
					end;
				end;
		};
		
	};
		
	
end;


return t