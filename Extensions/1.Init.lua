--[[<HCExtension>
@name 			Init
@author			Faan
@version 		Juli 2021 - v1.0
@description 	All Variable store Here for Easy Configuration
@event			Init
</HCExtension>]]

--|=== Change Log :
--| ---------------
--| * v1.0 - Juli 2021
--| - Created
--| - optimize code

-- For File : HideURL v2.lua
local HideList = [[:5228|:443|^.*gwarnet\.com|watson\.telemetry\.microsoft\.com|ldmnq\.com|\/.*_204]]
-- |_204|edge\-chat|\.*gwarnet\.com|\/youtubei\/v1\/log_event|facebook.com/api/graphql/|google.com/chrome-sync|facebook\.com/ajax/|data\.bilibili.com/log/|gstatic.com

-- For File : NgeFacebook Video Save-Hit.lua /  NgeYoutube Video Save-Hit.lua
local Storage = {	
	['DriveLetter'] = 'C:\\' -- if empty can save on default folder cache. to external dir insert : "C:\\"
} --# 

-- For File : NgeYoutube Init.lua
local InitYoutube = {	
	['RestrictMode'] 				= false, -- boolean
	['AutoPlayOFF'] 				= false, -- boolean
	['RemoveAds'] 					= false,-- boolean
	['SetQuality_method'] 			=  'var', -- var / basejs
	['SetQuality_method_basejs'] 	= 'small', -- string small,medium,large,hd720, ...
	['SetQuality_method_var'] 		= {
		['default'] = 360, -- number 144,240,360,480,720
		['min'] = 360, -- number 144,240,360,480,720 -- MIN > MAX = SINGLE FILE
		['max'] = 360  --number 144,240,360,480,720
	} --#
} --# 

-- For File : NgeYoutube Video Save-Hit.lua
local RewriteYoutube = {	
	['asURL'] = '_YoutubeWUZZ/', --#
	['asString'] = '_YoutubeWUZZ'
} --# 

-- For File : Save-Hit.lua
local RewriteFirstURL = {
	['asURL'] = '_StaticContent/', --#
} --#

-- For File : Save-Hit.lua
local ListSaveHit = [[\.(gif|jpe?g|png|webp|bmp|ico|svg(z)?|js|css|eot|woff(2)?|ttf|tif(f)?|otf)(\?|$)]]
local SkipSaveHit = [[chromium/filters\.js\?|bitsum\.com/.*\.exe|\.qq\.com|/callback\.js|gcpvuclip.*\.ts]]

function Init()
	-- Build Table for set global
	DataGlobal = {	
		['RewriteGdriveVid'] = RewriteGdriveVid, --#
		['HideList'] = HideList,
		['Storage'] = Storage,				
		['InitYoutube'] = InitYoutube,		
		['RewriteYoutube'] = RewriteYoutube,		
		['RewriteFirstURL'] = RewriteFirstURL,
		['ListSaveHit'] = ListSaveHit,
		['SkipSaveHit'] = SkipSaveHit
	}
	-- set global var
	hc.set_global('DataGlobal',DataGlobal)
end