--[[ <HCExtension>
@name			Save-Hit [Cache-Control & Rewrite]
@author			Faan
@version		30 Juli 2021 - v1.2.r1
@description	Save-Hit by Cache-Control & Rewrite
@exception 		fbcdn\.net\/v\/.*_n\.(mp4|webm)
@exception 		^.*\.((googlevideo|drive\.google|youtube)\.com\/)videoplayback\?
@rule			^https?://
@event 			Init
@event 			BeforeViewInMonitor
@event			RequestHeaderReceived
</HCExtension> ]]

require 'Helper'

function Init()
	hc_static.SaveHitVarGlobal = {
		['RewriteURL'] = '_StaticContent/', --#
		['Skip'] = [[chromium/filters\.js\?|bitsum\.com/.*\.exe|\.qq\.com|/callback\.js|gcpvuclip.*\.ts]],
		['Extension'] = [[\.(gif|jpe?g|png|webp|bmp|ico|svg(z)?|js|css|eot|woff(2)?|ttf|tif(f)?|otf)(\?|$)]],
		['Extension_Force'] = [[\.(gif|jpe?g|png|webp|bmp|ico|svg(z)?)(\?|$)|(.*)\?(v[0-9.]+|v=|ver=)]],
	} --#
end

function RequestHeaderReceived()
	-- validate url in skip list, if exist > whitelist
	if isExist(hc_static.SaveHitVarGlobal['Skip']) == true and re.find(hc.url, hc_static.SaveHitVarGlobal['Skip']) then --#
		hc.white_mask='WSDORU'
		hc.monitor_string = Monitor('wl')
	else	
		-- validate if url have criteria to process
		if hc.method == 'GET' and re.match(hc.url, hc_static.SaveHitVarGlobal['Extension']) or re.match(hc.url, hc_static.SaveHitVarGlobal['RewriteURL']) then
			-- call URLTransforming
			hc.call_me_for('URLToFileNameConverting','URLToFileNameConverting')
			-- if method GET and content not hit / Save-HIT Logic
			if Hit() == false then
				-- Call Save for checking content for saveable
				hc.call_me_for('AnswerHeaderReceived','Save')
			end
		end
	end
end

function Hit()
	-- cache exist | cache size > 0 | url not have path validate-use-clen 
	if isExist(hc.cache_file_name) == true and hc.cache_file_size > 0 and not re.match(hc.url, [[\/validate-use-clen\/]]) then
		ProcessHit('loaded')
		return true
	end
	return false
end

function ProcessHit(log)
	hc.action = 'dont_update'
	hc.monitor_text_color = MonitorColor('blue')
	hc.monitor_string = Monitor(log)
	-- Call BeforeAnswerHeaderSend for manipulation hc.answer_header (cors inject)
	hc.call_me_for('BeforeAnswerHeaderSend','BeforeAnswerHeaderSend')
end

function BeforeAnswerHeaderSend()
	new_answer_header = RewriteAnswerHeader({ --#
		['del_last_modified'] = true,
		['del_server'] = false,
		['add_cache_control'] = true,
		['add_cors'] = true
	}) --#

	--  set cors origin answer_header from origin request_header if exist
	if OriginExist(hc.request_header) then
		local origin = GetOrigin(hc.request_header)
		build_header = 'Access-Control-Allow-Origin: '..origin..'\r\n'
	else
		-- set default if not have header origin on request_header
		build_header = 'Access-Control-Allow-Origin: *\r\n'
	end

	-- set hc.answer_header with new_answer_header
	hc.answer_header = re.replace(new_answer_header, [[\r\n\r\n]], '\r\n'..build_header..'\r\n')
	-- #debugging
	-- hc.monitor_string = Monitor('cors.inject')
end

function Save()

	-- skip if respon is 304 (cache browser) | 302 = skip url has redirect by header
	if GetAnswerCode(hc.answer_header) == 304 or GetAnswerCode(hc.answer_header) == 302 then do return end end

	--  if url have path validate-use-clen > process validate cache using content length > if Valid > skip
	if re.match(hc.url, [[\/validate-use-clen\/]]) and ValidateUseClen() == true then do return end end

	-- if url has Rewrite > save
	if re.match(hc.url, hc_static.SaveHitVarGlobal['RewriteURL']) then --#
		ProcessSave('save.rw')
	-- check answer_header if cache-control is saveable 
	elseif isSaveableCC(hc.answer_header) == true then 
		-- save from url who contain regex ListSaveHit
		if re.match(hc.url, hc_static.SaveHitVarGlobal['Extension']) then
			ProcessSave('save.cc.ext')
		else
			-- hc.action = 'dont_save'
			hc.monitor_text_color = MonitorColor('red')
			hc.monitor_string = Monitor('out.criteria.in.cc')
		end
	-- force save without cc & rewrite
	elseif re.match(hc.url, hc_static.SaveHitVarGlobal['Extension_Force']) then --#
		ProcessSave('save.force')		
	else
		-- hc.action = 'dont_save'
		hc.monitor_text_color = MonitorColor('purple')
		hc.monitor_string = Monitor('out.criteria')
	end
end

function ProcessSave(log)
	-- if answer code 206 > check isaveable206
	if GetAnswerCode(hc.answer_header) == 206 and not IsSaveable206(hc.answer_header) then
		hc.monitor_string = Monitor('skip.206')
		hc.monitor_text_color = MonitorColor('purple')
		do return end -- # skip process
	else
		-- add string 206 to log 
		if GetAnswerCode(hc.answer_header) == 206 then log = log..'.206' end
		hc.action = 'save'
		hc.monitor_string = Monitor(log)
		hc.monitor_text_color = MonitorColor('green')
	end
end

function ValidateUseClen()
	if hc.cache_file_size == GetContentLength(hc.answer_header) then
		ProcessHit('loaded.sync')
		return true
	end
	return false
end

function URLToFileNameConverting()
	-- register new file cache name
	hc.preform_cache_file_name(hc.cache_path..ConvertURLToSaveable(hc.url,true)) 
end

function BeforeViewInMonitor()

	-- skip if not get method
	if hc.method ~= 'GET' then do return end end

	-- set var url
	local url = hc.url
	local rwUrl = hc_static.SaveHitVarGlobal['RewriteURL']

	--[[ Website ]]--
	
	if re.find(url, [[^.*(fbcdn.net\/safe_image.php)\?.*&(w=.*)&url=(https|http)%3A%2F%2F(.*)&cfs.*]]) then -- facebook external image
		reWrite(rwUrl..re.substr(1)..'/'..urldecode(re.substr(4))..'-'..re.substr(2),true)
	elseif re.find(url, [[^.*(fbcdn.net\/)(.*)((\/.*)\.(kf))]]) then -- facebook emoji
		reWrite(rwUrl..re.substr(1)..hc.crc32(re.substr(2))..re.substr(3),true)
	elseif not re.find(url, [[^.*fbcdn\.net\/.*live-dash]]) and re.find(url, [[^.*(fbcdn.net\/)(.*)((\/.*)\.(m4v|m4a))]]) then -- facebook video m4a/mp4v
		reWrite(rwUrl..re.substr(1)..hc.crc32(re.substr(2))..re.substr(3),true)		
	elseif re.find(url, [[^.*(encrypted-tbn[0-9]\.gstatic\.com\/images)\?(.*)]]) then --# google image
		reWrite(rwUrl..re.substr(1)..'/'..re.substr(2),true)
	elseif re.find(url, [[^.*(lh[0-9]\.googleusercontent\.com\/(.*\/)?([\w+-]+)=([\w+-]+))]]) then --# google image
		reWrite(rwUrl..re.substr(1),true)
	elseif re.find(url, [[^.*(fonts.googleapis.com\/)css([0-9]+)?\?(.*)]]) then --# google font
		reWrite(rwUrl..re.substr(1)..re.substr(3)..'.css',true)
	elseif re.find(url, [[^.*(drive\.google\.com\/_\/drive_fe\/.*)]]) then --# google drive js
		reWrite(rwUrl..re.substr(1),true)
	elseif re.find(url, [[^.*(yt[0-9]\.ggpht\.com\/.*)]]) then --# youtube external image 
		reWrite(rwUrl..re.substr(1),true)	
	elseif re.find(url, [[^.*(gravatar.com\/avatar\/)(.*)]]) then --# gravatar image
		reWrite(rwUrl..re.substr(1)..re.substr(2),true)	
	elseif re.find(url, [[^.*(s[0-9+]\.wp\.com\/)_static\/\?\?\/?(.*)]]) then --# wp static >> s2.wp.com/_static/??
		reWrite(rwUrl..re.substr(1)..re.substr(2),true)
	elseif re.find(url, [[^.*\/\/(t.*\.rbxcdn\.com\/.*)]]) then --# roblox cdn
		reWrite(rwUrl..'roblox-cdn/'..re.substr(1),true)
	elseif re.find(url, [[^.*((tiktokcdn\.com\/(obj\/)?(tos-.*))\?.*|(tiktokcdn\.com\/obj\/.*)\?.*)]]) then --# tiktok cdn
		reWrite(rwUrl..re.substr(1),true)		
	elseif re.find(url, [[^.*(githubusercontent\.com\/.*)]]) then --# github avatar
		reWrite(rwUrl..re.substr(1),true)
	elseif re.find(url, [[^.*(tiktok(cdn)?.com\/).*(tos-.*)(\/.*)\/.*&br=([0-9]+)&bt=([0-9]+).*]]) then --# tiktok video
		reWrite(rwUrl..'_TiktokVid'..re.substr(4)..'-'..re.substr(5)..'-'..re.substr(6)..'.mp4',true)

	--[[ CERT SITE ]]--

	elseif re.find(url, [[^.*((digicert|amazontrust).com\/.*)]]) then -- # certificate site
		reWrite(rwUrl..re.substr(1),true)

	--[[ UPDATE CHROME ]]--

	elseif re.find(url, [[^.*((gvt[0-9]+|(dl\.)?google)\.com\/.*(chromewebstore|chrome_component)\/.*)]]) then 
		reWrite(rwUrl..'chrome-update/'..re.substr(1),true)	
	elseif re.find(url, [[^.*(googleapis.com\/update-delta\/.*)]]) then  --#
		reWrite(rwUrl..'chrome-update/'..re.substr(1),true)

	--[[ PATCH GAME ]]--

	elseif re.find(url, [[^.*(cdn2.pointblank.id\/Indonesia\/PointBlank\/Live_Client\/.*|zpt-id.zepetto.com\/ID\/PointBlank\/Live\/.*)]]) then --# point blank
		reWrite(rwUrl..re.substr(1),true)
	elseif re.find(url, [[^.*(ml\.youngjoygame\.com/.*\.(unity3d|zip|bnk|bytes))]]) then  --# mobile legend
		reWrite(rwUrl..'validate-use-clen/'..re.substr(1),true) --#
	end	

end