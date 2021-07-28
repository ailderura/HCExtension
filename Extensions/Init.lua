--[[<HCExtension>
@name 			Init
@author			Faan
@version 		28 Juli 2021 - v1.1
@description 	All Variable store Here for Easy Configuration
@event			Init
</HCExtension>]]

--|=== Change Log :
--| ---------------
--| * v1.0 - Juli 2021
--| - Created
--| - optimize code
--| * v1.1 - 28 Juli 2021
--| - Implode all variable by file

-- For File : HideURL v2.lua
local HideListVarGlobal = [[:5228|:443|^.*gwarnet\.com|watson\.telemetry\.microsoft\.com|ldmnq\.com|\/.*_204|facebook\.com\/ajax\/]]
-- |_204|edge\-chat|\.*gwarnet\.com|\/youtubei\/v1\/log_event|facebook.com/api/graphql/|google.com/chrome-sync|facebook\.com\/ajax\/|data\.bilibili.com/log/|gstatic.com

-- For File : NgeYoutube Video Save-Hit.lua
local YoutubeVarGlobal = {	
	['DriveLetter'] 				= '', -- if empty can save on default folder cache. to external dir insert : "C:\\"
	['RewriteURL'] 					= '_YoutubeWUZZ/', 
	['RewriteString'] 				= '_YoutubeWUZZ',
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

-- For File : Save-Hit.lua
local SaveHitVarGlobal = {
	['RewriteURL'] = '_StaticContent/', --#
	['Skip'] = [[chromium/filters\.js\?|bitsum\.com/.*\.exe|\.qq\.com|/callback\.js|gcpvuclip.*\.ts]],
	['SaveHit'] = [[\.(gif|jpe?g|png|webp|bmp|ico|svg(z)?|js|css|eot|woff(2)?|ttf|tif(f)?|otf)(\?|$)]],
	['ForceSaveHit'] = [[\.(gif|jpe?g|png|webp|bmp|ico|svg(z)?)$]],
} --#

function Init()
	-- Build Table for set global
	DataGlobal = {	
		['HideListVarGlobal'] = HideListVarGlobal, --#
		['YoutubeVarGlobal'] = YoutubeVarGlobal,
		['SaveHitVarGlobal'] = SaveHitVarGlobal
	}
	-- set global var
	hc.set_global('DataGlobal',DataGlobal)
end