--[[ <HCExtension>
@name			Youtube [Rewrite-Body]
@author			Faan
@version		Juli 2021 - v1.1
@description	Youtube Manipulation answer_body
@rule			youtube\.com
@event 			Init
@event 			BeforeRequestHeaderSend
</HCExtension> ]]

require 'Helper'

function Init()
	hc_static.YoutubeVarGlobal = {	
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
end

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
	if hc_static.YoutubeVarGlobal['RestrictMode'] then
		RestrictMode()
	end		
	if hc_static.YoutubeVarGlobal['AutoPlayOFF'] then
		AutoPlayOFF()			
	end	
	if hc_static.YoutubeVarGlobal['RemoveAds'] then
		RemoveAds()			
	end
	if hc_static.YoutubeVarGlobal['SetQuality_method'] == 'var' then
		-- Call function Set Quality
		SetQualityVar(hc_static.YoutubeVarGlobal['SetQuality_method_var'])
	elseif hc_static.YoutubeVarGlobal['SetQuality_method'] == 'basejs' then --#
		-- if on url youtube.com...base.js
		if re.find(hc.url, [[^.*youtube.com/s/player/.*/base.js]]) then
			-- Call function SetQualityBaseJS
			SetQualityBaseJS(hc_static.YoutubeVarGlobal['SetQuality_method_basejs'])			
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