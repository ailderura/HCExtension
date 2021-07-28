--[[ <HCExtension>
@name			Youtube [Rewrite-Body]
@author			Faan
@version		Juli 2021 - v1.0
@description	Youtube Manipulation answer_body
@rule			youtube\.com
@event 			BeforeRequestHeaderSend
</HCExtension> ]]

--|=== Integrate File
--| -----------------
--| - _Helper.lua
--| - Init.lua
--| 
--|=== Change Log :
--| ---------------
--| * v1.0 - Juli 2021
--| - Created
--| - This extension not working fully when using hc 645 because request url can be hidden on any time
--| - All manipulation answer_body didn't work when url is hidden on log monitor
--| - optimize code

require '_Helper'

local VarInit = hc.get_global('DataGlobal')

function BeforeRequestHeaderSend()

	-- allow ssl handling to prevent error on hc 645
	-- hc.ssl_handling_enabled ([[^.*youtube\.com\/($|watch\?v|results\?|channel|feed|s\/player\/.*\/base\.js)]], '.*')

	-- if url contain in regexlist
	-- #message : add more path for manipulation data answer_body
	if re.find(hc.url,[[^.*youtube\.com\/($|watch\?v|results\?|channel|feed|s\/player\/.*\/base\.js)]]) then
		-- manipulation header Accept-Encoding value for the answer_body can be readed
		hc.request_header = re.replace(hc.request_header, [[[Aa]ccept\-[Ee]ncoding:\s\K[^\r\n]+]], 'gzip, deflate')
		-- Call BeforeAnswerBodySend for manipualtion answer_body
		hc.call_me_for('BeforeAnswerBodySend', 'BeforeAnswerBodySend')	
	end
end

function BeforeAnswerBodySend()
	-- # This process call from BeforeRequestHeaderSend
	if VarInit['YoutubeVarGlobal']['RestrictMode'] then
		RestrictMode()
	end		
	if VarInit['YoutubeVarGlobal']['AutoPlayOFF'] then
		AutoPlayOFF()			
	end	
	if VarInit['YoutubeVarGlobal']['RemoveAds'] then
		RemoveAds()			
	end
	if VarInit['YoutubeVarGlobal']['SetQuality_method'] == 'var' then
		-- Call function Set Quality
		SetQualityVar(VarInit['YoutubeVarGlobal']['SetQuality_method_var'])
	elseif VarInit['YoutubeVarGlobal']['SetQuality_method'] == 'basejs' then --#
		-- if on url youtube.com...base.js
		if re.find(hc.url, [[^.*youtube.com/s/player/.*/base.js]]) then
			-- Call function SetQualityBaseJS
			SetQualityBaseJS(VarInit['YoutubeVarGlobal']['SetQuality_method_basejs'])			
		end	
	end	
end

function RestrictMode()
	hc.answer_body = string.gsub(hc.answer_body, '"lockedSafetyMode":false', '"lockedSafetyMode":true')
end

function AutoPlayOFF()
	-- build table autoplay js
	autoplay_js = {
		['\"autoplay\"'] = '\"auto_play\"' --#
	}
	-- loop table autoplay js
	for key,value in next, autoplay_js, nil do
		hc.answer_body = string.gsub(hc.answer_body, key , value)		
	end	
end

function RemoveAds()	
	-- build table ads js
	table_ads_js = {
		['playerAds'] = 'player_Ads', --#
		['playbackTracking'] = 'playback_Tracking', 
		['cards'] = 'card_s', 
		['attestation'] = 'atte_station', 
		['messages'] = 'message_s',
		['endscreenRenderer'] = 'endscreen_Renderer', 
		['adPlacements'] = 'ad_Placements', 
		['adInfoDialogEndpoint'] = 'ad_InfoDialogEndpoint', 
		['promotedSparklesWebRenderer'] = 'promoted_SparklesWebRenderer', 
		['adSignalsInfo'] = 'ad_SignalsInfo', 
		['LANDING_PAGE_PROMO'] = 'LANDINGPAGE_PROMO', 
		['SPONSORSHIPS_OFFER'] = 'SPONSORSHIPSOFFER', 
		['carouselAdRenderer'] = 'carousel_AdRenderer',
		['compactPromotedVideoRenderer'] = 'compactPromoted_VideoRenderer',	
	}
	-- loop table ads js
	for key,value in next, table_ads_js, nil do
		hc.answer_body = string.gsub(hc.answer_body, key , value)		
	end	

	-- remove <link rel="preload" ... as=fetch>
	-- #message : youtube will blank > need correct regex
	-- hc.answer_body = string.gsub(hc.answer_body, [[<link rel="preload"(.*)as="fetch">]], "")	

	-- remove ads using css
	code_css = [[<style> 
	#masthead-ad, .ytd-player-legacy-desktop-watch-ads-renderer, .video-ads {display: none !important;} 
	</style>]]
	hc.answer_body = string.gsub(hc.answer_body, '<head>', '<head>'..code_css) 
end

function SetQualityVar(setquality)
	-- #message : Quality default
	hc.answer_body = string.gsub(hc.answer_body, "html5_default_quality_cap\\u003d[0-9]+", "html5_default_quality_cap\\u003d"..setquality['default']) 
	-- #message : Min Quality in Control Button
	hc.answer_body = string.gsub(hc.answer_body, "html5_min_selectable_quality_ordinal\\u003d[0-9.]+", "html5_min_selectable_quality_ordinal\\u003d"..setquality['min'])
	-- #message : Max Quality in Control Button
	hc.answer_body = string.gsub(hc.answer_body, "html5_max_selectable_quality_ordinal\\u003d[0-9.]+", "html5_max_selectable_quality_ordinal\\u003d"..setquality['max'])

end

function SetQualityBaseJS(setquality)	
	-- #message : this code don't work, its only next idea
	hc.answer_body = string.gsub(hc.answer_body, "quality:\"auto\"", "quality:\""..setquality.."\"")
	-- #debugging
	-- hc.monitor_string = Monitor('quality.js')
end