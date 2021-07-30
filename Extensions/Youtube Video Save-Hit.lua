--[[ <HCExtension>
@name			Youtube & GoogleDrive Video [Save-Hit]
@author			Faan
@version		18 Juli 2021 - v1.2
@description	Save-Hit Youtube & GoogleDrive Video
@exception		live=1&
@rule 			^.*\.((googlevideo|drive\.google|youtube)\.com\/)videoplayback\?
@rule			youtube\.com
@event 			Init
@event 			URLToFileNameConverting
@event 			BeforeViewInMonitor
@event 			RequestHeaderReceived
</HCExtension> ]]

require "Helper"

function Init()
	hc_static.YoutubeVarGlobal = {	
		['DriveLetter'] 				= '', -- if empty can save on default folder cache. to external dir insert : "C:\\"
		['RewriteURL'] 					= '_YoutubeWUZZ/', 
		['RewriteString'] 				= '_YoutubeWUZZ',
		['LimitSize'] 					= 30, -- 30Mb	
	} --#
	-- set var for cache folder location		
	hc_static.DriveLetter = hc_static.YoutubeVarGlobal['DriveLetter']
	if not hc_static.DriveLetter then hc_static.DriveLetter = hc.cache_path end -- if DriveLetter None set to default folder cache
	hc_static.TempPath = hc_static.DriveLetter..hc_static.YoutubeVarGlobal['RewriteString']..'\\_Temp\\'
end

function RequestHeaderReceived()
	-- #message : this code disable becaouse googlevideo have static identity, when reload string not change on lmt parameter ! 
	-- site youtube.com
	-- if re.find(hc.url, [[youtube\.com]]) then 
		-- Call YoutubeIDtoGoogleVideo >> set session youtubeid from parameter
		-- YoutubeIDtoGoogleVideo('page-streamingstats')
		-- Call BeforeAnswerBodySend
		-- hc.call_me_for('BeforeAnswerBodySend', 'BeforeAnswerBodySend')	
	-- end
	-- site googlevideo
	if re.match(hc.url, hc_static.YoutubeVarGlobal['RewriteURL']) then				
		-- if content not hit and method = 'GET' 
		if Hit() == false and hc.method == 'GET' then
			-- Call Save for checking content for saveable
			hc.call_me_for('AnswerHeaderReceived', 'Save')
		end
	end
end

function Hit()
	-- cache exist and cache size > 0 
	-- #message : add other validation for best performance
	if isExist(hc.cache_file_name) and hc.cache_file_size > 0 then
		-- video as range
		if re.find(hc.url, [[\/range\/.*\/([0-9]+)-([0-9]+)-([0-9]+)]]) then
			-- get value from previous re.find
			range_url_start = re.substr(2)
			range_url_end = re.substr(3)
			range_url_size = range_url_end - range_url_start + 1
			-- validation cache file size == range from url
			if hc.cache_file_size == range_url_size then
				ProcessHit('yt.hit.200')
				return true
			end
		-- video as norange		
		elseif re.find(hc.url, [[\/norange\/]]) then --#
			ProcessHit('yt.hit.206')
			return true
		-- video as norange		
		elseif re.find(hc.url, [[\/gdrive\/]]) then --#
			ProcessHit('gdrive.hit.206')
			return true
		-- video as norange		
		elseif re.find(hc.url, [[\/range-sq\/]]) then --#
			ProcessHit('range.sq.hit.200')
			return true
		end		
	end
	return false
end

function ProcessHit(log)
	hc.monitor_string = Monitor(log)
	hc.monitor_text_color = MonitorColor('blue')
	hc.action = 'dont_update'
	-- Call BeforeAnswerHeaderSend for manipulation hc.answer_header (cors inject)
	hc.call_me_for('BeforeAnswerHeaderSend','BeforeAnswerHeaderSend')
end

function BeforeAnswerHeaderSend()
new_answer_header = RewriteAnswerHeader({
	['del_last_modified'] = true,
	['del_server'] = true,	
	['add_cache_control'] = true,		
	['add_cors'] = true
	}) --#
	-- cors for googlevideo #important, prevent error when load cache
	if re.match(hc.url, hc_static.YoutubeVarGlobal['RewriteURL']) then -- # cors for youtube
		-- add Header for vertification url with youtube.com/watch
		if OriginExist(hc.request_header) then
			local origin = GetOrigin(hc.request_header)
			build_header = 'Access-Control-Allow-Origin: '..origin..'\r\n'
			build_header = build_header..'Access-Control-Allow-Credentials: true\r\n'		
			build_header = build_header..'Timing-Allow-Origin: '..origin..'\r\n'				
			build_header = build_header..'Access-Control-Expose-Headers: Client-Protocol, Content-Length, Content-Type, X-Bandwidth-Est, X-Bandwidth-Est2, X-Bandwidth-Est3, X-Bandwidth-App-Limited, X-Bandwidth-Est-App-Limited, X-Bandwidth-Est-Comp, X-Bandwidth-Avg, X-Head-Time-Millis, X-Head-Time-Sec, X-Head-Seqnum, X-Response-Itag, X-Restrict-Formats-Hint, X-Sequence-Num, X-Segment-Lmt, X-Walltime-Ms\r\n'			
			-- else
			-- 	build_header = 'Access-Control-Allow-Origin: https://www.youtube.com\r\n'
			-- 	build_header = build_header..'Access-Control-Allow-Credentials: true\r\n'		
			-- 	build_header = build_header..'Timing-Allow-Origin: https://www.youtube.com\r\n'				
			-- 	build_header = build_header..'Access-Control-Expose-Headers: Client-Protocol, Content-Length, Content-Type, X-Bandwidth-Est, X-Bandwidth-Est2, X-Bandwidth-Est3, X-Bandwidth-App-Limited, X-Bandwidth-Est-App-Limited, X-Bandwidth-Est-Comp, X-Bandwidth-Avg, X-Head-Time-Millis, X-Head-Time-Sec, X-Head-Seqnum, X-Response-Itag, X-Restrict-Formats-Hint, X-Sequence-Num, X-Segment-Lmt, X-Walltime-Ms\r\n'			
		end
	end
	if not isempty(build_header) then
		-- set hc.answer_header with new_answer_header
		hc.answer_header = re.replace(new_answer_header, [[\r\n\r\n]], '\r\n'..build_header..'\r\n')
		-- #debugging
		-- hc.monitor_string = Monitor('cors.inject')	
	end
end

function Save()
	-- video as range
	if re.find(hc.url, [[\/range\/]]) then
		ProcessSave('yt.save.200')
	-- video as range sq
	elseif re.find(hc.url, [[\/range-sq\/]]) then
		ProcessSave('yt.save.sq.200')
	-- video as norange		
	elseif re.find(hc.url, [[\/norange\/]]) then --#
		if IsSaveable206(hc.answer_header) then
			ProcessSave('yt.save.206')
		else
			hc.monitor_string = Monitor('yt.skip.206')
		end
	-- video as gdrive		
	elseif re.find(hc.url, [[\/gdrive\/]]) then --#
		if IsSaveable206(hc.answer_header) then
			ProcessSave('gdrive.save.206')
		else
			hc.monitor_string = Monitor('gdrive.skip.206')
		end
	else
		hc.monitor_text_color = MonitorColor('purple')
	end
end

function ProcessSave(log)
	hc.monitor_string = Monitor(log)
	hc.monitor_text_color = MonitorColor('green2')
	hc.action = 'save'
end

-- #message : this code disable becaouse googlevideo have static identity when reload string not change on lmt parameter ! 
function BeforeAnswerBodySend()
	-- Call YoutubeIDtoGoogleVideo for manipualtion answer_body >> rewrite googlevideo >> inject parameter on page watch
	-- YoutubeIDtoGoogleVideo('page-watch')	
	-- Call YoutubeIDtoGoogleVideo for manipualtion answer_body >> rewrite googlevideo >> inject parameter on base.js
	-- YoutubeIDtoGoogleVideo('recode-js')
end

function YoutubeIDtoGoogleVideo(option)
	-- on path youtube.com/watch & option page-watch
	-- #message : method#1 >> when visit page youtube.com/watch >> replace all videoplayback url >> when on googlevideo domain get youtube id parameter
	if option == 'page-watch' and re.find(hc.url, [[youtube.com/watch]]) then
		-- get youtube id from url
		ytb_identity = re.find(hc.url, [[v=(.{11})]], 1)
		-- replace videoplayback with inject parameter ytb_identity  
		hc.answer_body = string.gsub(hc.answer_body, 'videoplayback%%3F', 'videoplayback%%3Fytb_identity%%3D'..ytb_identity..'%%26')
		hc.answer_body = string.gsub(hc.answer_body, 'videoplayback%?', 'videoplayback?ytb_identity='..ytb_identity..'&')		
		-- #debugging
		-- hc.monitor_string = Monitor('yt.id.inject'..ytb_identity)
	-- on path youtube/api/stats/qoe?event=streamingstats and exist param cpn and docid & option page-click
	-- #message : method#2 >> set unique var global with value youtube id >> when on googlevideo domain validate using parameter >> cpn from youtube-site == cpn from googlevideo
	elseif option == 'page-streamingstats' and re.find(hc.url, [[youtube.com\/(api\/stats\/qoe\?event=streamingstats).*&(cpn=).*(docid=).*]]) then --#
    	-- extract url   
    	getparams = parseurl(hc.url)
    	param_cpn = getparams['cpn']
    	param_docid = getparams['docid']    	
    	-- get ytb_identity from parameter
    	if param_cpn and param_docid then 
    		-- set var 
    		ytb_identity = param_docid	
    		-- check if cpn not exist in temp folder >> for no reprocess again
    		if param_cpn and not isFileExist(hc_static.TempPath..param_cpn) then --#		
				-- set session to create file in temp folder
				hc.prepare_path(hc_static.TempPath)
				local cpn_write = io.open(hc_static.TempPath..param_cpn, "w")
				cpn_write:write(ytb_identity)
				cpn_write:close()
				-- #debugging
				-- hc.monitor_string = Monitor('write_cpn')
				-- hc.monitor_text_color = MonitorColor('red')
			end	
		else
			-- #debugging >> if url remove params on future
			if not param_cpn and not param_docid then
				hc.monitor_string = Monitor('param cpn & docid mising')
			elseif not param_cpn then--#
				hc.monitor_string = Monitor('param cpn mising')
			elseif not param_docid then--#
				hc.monitor_string = Monitor('docid mising')								
			end
		end
	-- onpath youtube.com...base.js
	-- #message : method#3 >> recode base.js and add youtube id to googlevideo url >> when on googlevideo get youtube id parameter
	elseif re.find(hc.url, [[^.*youtube.com/s/player/.*/base.js]]) and option == 'recode-js' then --#
		-- hc.answer_body = string.gsub(hc.answer_body, 'xhr%.send%(c%.body%)', 'xhr.send(c.body + "&babhi=1")')
		-- hc.monitor_string = Monitor('base.js')
	end	
end

function BeforeViewInMonitor()
	-- check if googlevideo
	if re.match(hc.url, [[^.*\.((googlevideo|drive\.google|youtube)\.com\/)videoplayback\?]]) then
		-- extract url
		getparams = parseurl(hc.url)
		param_ytb_identity = getparams['ytb_identity']
		param_cpn = getparams['cpn']

		-- skip if param clen > 30Mb
		if getparams['clen'] and tonumber(getparams['clen']) >= hc_static.YoutubeVarGlobal['LimitSize'] * 1024 * 1024 then 
			hc.monitor_text_color = MonitorColor('pink')
			hc.monitor_string = Monitor('skip.big.size')
			do return end 
		end

		-- set ytb_identity from parameter on googlevideo
		if param_ytb_identity then
			ytb_identity = param_ytb_identity			
			-- #debugging
			-- hc.monitor_string = Monitor('yt_id.parameter')
		-- set ytb_identity from cpn on temp folder 
		elseif param_cpn and isFileExist(hc_static.TempPath..param_cpn) then --#
			local cpn_read = io.open(hc_static.TempPath..param_cpn, "r") 
			ytb_identity = cpn_read:read('*a')
			cpn_read:close()
			-- #debugging
			-- hc.monitor_string = Monitor('yt_id.cpn')
		elseif getparams['lmt'] then --# check if param lmt exist 
			--# if nothing ytb_identity > create unique identity from googlevideo parameter static when page reload this parameter not change !!!
			ytb_identity = getparams['lmt']
			-- #debugging
			-- hc.monitor_string = Monitor('yt_id.??')			
		end

		-- if ytb_identity exist
		if not isempty(ytb_identity) then	
			-- call other param
			param_itag = getparams['itag']
			param_range = getparams['range']
			param_ptk = getparams['ptk']

			if param_itag and param_range then  -- # range content
				-- rewrite url StaticURL/video_id-range/itag - range
				reWrite(hc_static.YoutubeVarGlobal['RewriteURL']..'range/'..ytb_identity..'/'..param_itag..'-'..param_range,false)
			elseif param_itag and param_ptk then --# single content
				-- rewrite url >> StaticURL/video_id-norange/video_id-itag
				reWrite(hc_static.YoutubeVarGlobal['RewriteURL']..'norange/'..ytb_identity..'/'..ytb_identity..'-'..param_itag..'.mp4',false)
			elseif param_itag and getparams['source'] ~= 'yt_otf' then --# gdrive
				-- rewrite url >> StaticURL/video_id-gdrive/video_id-itag
				reWrite(hc_static.YoutubeVarGlobal['RewriteURL']..'gdrive/'..ytb_identity..'/'..ytb_identity..'-'..param_itag..'.mp4',false)				
			elseif param_itag and getparams['sq'] and getparams['source'] == 'yt_otf' then -- # range-sq (url not contain param range but sq is dynamical value)
				-- rewrite url >> StaticURL/video_id-range-sq/itag - sq - rn
				reWrite(hc_static.YoutubeVarGlobal['RewriteURL']..'range-sq/'..ytb_identity..'/'..param_itag..'-'..getparams['sq']..'-'..getparams['rn'],false)								
			else
				-- #debugging
				hc.monitor_text_color = MonitorColor('red')
				-- hc.monitor_string = Monitor('whaticandowiththisurl?')
			end
		end
	end
end

function URLToFileNameConverting()
	-- check if on rewrite url >> googlevideo
	if re.find(hc.url, hc_static.YoutubeVarGlobal['RewriteURL']) then
		-- set cache file name with drive letter custom
		hc.preform_cache_file_name(hc_static.DriveLetter..hc.prepare_url(hc.url))	
	end
end