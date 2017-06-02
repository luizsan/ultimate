local player = Var "Player";
local pulse = cmd(stoptweening;zoomx,1.3;zoomy,1.5;decelerate,0.075;zoom,1;sleep,0.825;linear,0.12;zoom,0.5);
local fadeout = cmd(stoptweening;sleep,0.9;linear,0.15;diffusealpha,0);


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
			self:stoptweening();
			self:visible(false);
			self:diffusealpha(0.5);
			if not combo or combo < 4 then self:visible(false); else self:visible(true); end
			fadeout(self);
		end;
	};


	--accuracy
	LoadFont("corbel")..{
		Text="Accuracy";
		InitCommand=cmd(diffusealpha,0;textglowmode,"TextGlowMode_Inner");
		OnCommand=cmd(horizalign,right;diffuse,0.8,0.8,0.8,0;diffusetopedge,1,1,1,0;strokecolor,0,0,0,0.66;zoom,0.433;x,46;y,2);
		ComboCommand=function(self,param)
			local combo = param.Misses or param.Combo
			local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player);
			local accuracy = string.format("%.2f",stats:GetActualDancePoints()/stats:GetCurrentPossibleDancePoints()*100)

			--SCREENMAN:SystemMessage("total possible: "..stats:GetPossibleDancePoints().."\ncurrent possible: "..stats:GetCurrentPossibleDancePoints().."\ncurrent actual: "..stats:GetActualDancePoints())

			self:stoptweening();
			self:settext(accuracy.."%  Accuracy");
			self:diffusealpha(1);
			if not combo then self:visible(false); else self:visible(true); end
			fadeout(self);
		end;
	};

	--combo
	LoadFont("regen silver")..{
		OnCommand=cmd(horizalign,right;strokecolor,0,0,0,1;zoomx,0.825;zoomy,0.725;y,22;x,10);
		ComboCommand=function(self,param)
			local combo = param.Misses or param.Combo
			
			self:stoptweening();
			self:visible(false);
				
			self:diffuse(1,1,1,1);
			
			if param.Misses then self:diffuse(1,0,0.2,1); end;
			
			if combo then
				self:settext(string.rep("0",3-string.len(combo))..combo);
			end;
			
			if not combo or combo < 4 then self:visible(false); else self:visible(true); end
			fadeout(self);
		end;
	};

	--label
	LoadFont("regen small")..{
		OnCommand=cmd(horizalign,left;strokecolor,0,0,0,0.95;zoomx,0.72;zoomy,0.64;vertspacing,-18;x,15;y,22);
		ComboCommand=function(self,param)
			local combo = param.Misses or param.Combo
			local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player);
			
			self:stoptweening();
			self:diffuse(1,1,1,1);
			
			if stats:FullComboOfScore("TapNoteScore_W1") then
				self:settext("superb\ncombo");
			elseif stats:FullComboOfScore("TapNoteScore_W2") then
				self:settext("perfect\ncombo");
			elseif stats:FullComboOfScore("TapNoteScore_W3") then
				self:settext("full\ncombo");
			elseif param.Combo then
				self:settext("\ncombo");
			elseif param.Misses then
				self:diffuse(1,0,0.2,1);
				self:settext("miss\ncombo");
			end;

			if not combo or combo < 4 then self:visible(false); else self:visible(true); end
			fadeout(self);
		end;
	};


};

return t