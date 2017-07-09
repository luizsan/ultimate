local player = Var "Player"
local pulse = cmd(stoptweening;zoomx,1.3;zoomy,1.5;decelerate,0.075;zoom,1;sleep,0.725;linear,0.12;zoom,0.5;sleep,0.5;linear,0.15;zoom,0.25);
local fadeout = cmd(stoptweening;sleep,0.8;linear,0.15;diffusealpha,0);
local reverse_judgment = PLAYERCONFIG:get_data(player).ReverseJudgment;

local t = Def.ActorFrame{

	InitCommand=function(self) self:draworder(500); end;
	JudgmentMessageCommand=function(self,param) 
		if param.TapNoteScore == "TapNoteScore_HitMine" or param.TapNoteScore == "TapNoteScore_AvoidMine" then return end;
		if param.Player == player and param.TapNoteScore then pulse(self); end; 
	end;


		LoadActor(THEME:GetPathG("","dim"))..{
			InitCommand=cmd(y,4;zoomx,0.325;zoomy,0.135;diffuse,0.2,0.2,0.2,0;fadeleft,0.45;faderight,0.45);
			ComboCommand=function(self,param)
				local combo = param.Misses or param.Combo
				if not combo or combo < 4 then self:visible(false); else self:visible(true); end
				self:stoptweening();
				self:diffusealpha(0.5);
				fadeout(self);
			end;
		};

		--accuracy
		Def.BitmapText{
			Font = Fonts.player["Accuracy"];
			Text="Accuracy";
			InitCommand=cmd(textglowmode,"TextGlowMode_Inner");
			OnCommand=cmd(horizalign,right;diffuse,0.8,0.8,0.8,1;diffusetopedge,1,1,1,1;strokecolor,0,0,0,0.66;diffusealpha,0;zoom,0.433;x,46;y,2);
			ComboCommand=function(self,param)
				local accuracy = string.format("%.2f", 100)
				local combo = param.Misses or param.Combo
				local stats = nil;

				if param.Player or player then
					if param.currentDP and param.possibleDP then
						if param.possibleDP > 0 then
							accuracy = string.format("%.2f",(param.currentDP/param.possibleDP)*100)
						else
							accuracy = string.format("%.2f",100)
						end
					else
						stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player);
						accuracy = string.format("%.2f",(stats:GetActualDancePoints()/stats:GetCurrentPossibleDancePoints())*100)
					end;
				end

				self:stoptweening();
				self:diffusealpha(1);
				self:settext(accuracy.."%  Accuracy");
				if not combo then self:visible(false); else self:visible(true); end
				fadeout(self);
			end;
		};

		--combo
		Def.BitmapText{
			Font = Fonts.player["Combo"];
			OnCommand=cmd(horizalign,right;diffuse,1,1,1,0;strokecolor,0,0,0,1;zoomx,0.825;zoomy,0.725;y,22;x,10);
			ComboCommand=function(self,param)
				self:stoptweening();

				self:diffuse(1,1,1,1); 
				if (not reverse_judgment and param.Misses) or (reverse_judgment and param.Combo) then
					self:diffuse(1,0,0.2,1); 
				end;

				local combo = param.Misses or param.Combo;
				if combo then
					self:settext(string.rep("0",3-string.len(combo))..combo);
				end;
				if not combo or combo < 4 then self:visible(false); else self:visible(true); end;
				fadeout(self);
			end;
		};

		--label
		Def.BitmapText{
			Font = Fonts.player["Label"];
			OnCommand=cmd(horizalign,left;diffuse,1,1,1,0;strokecolor,0,0,0,0.95;zoomx,0.72;zoomy,0.64;vertspacing,-18;x,15;y,22);
			ComboCommand=function(self,param)
				local combo = param.Misses or param.Combo;
				local stats = nil;

				self:stoptweening();
				self:diffuse(1,1,1,1);

				if param.Player or player then
					stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player);
					if stats:FullComboOfScore("TapNoteScore_W1") then
						self:settext("superb\ncombo");
					elseif stats:FullComboOfScore("TapNoteScore_W2") then
						self:settext("perfect\ncombo");
					elseif stats:FullComboOfScore("TapNoteScore_W3") then
						self:settext("full\ncombo");
					elseif param.Combo then
						self:settext("\ncombo");
					elseif param.Misses then
						self:settext("miss\ncombo");
					end;
				end

				if (not reverse_judgment and param.Misses) or (reverse_judgment and param.Combo) then
					self:diffuse(1,0,0.2,1);
				end;

				if not combo or combo < 4 then self:visible(false); else self:visible(true); end;
				fadeout(self);
			end;
		};

	};

return t