--|=== Helper File (External)
--| -----------------------

--| HCHelper v1.0
--|
--|=== Change Log :
--| ---------------
--| * v1.0 - 29 Juli 2021
--| - Split evey function by category

function Monitor(mes)
	if isempty(mes) then return end
	return hc.monitor_string..mes
end

function MonitorColor(dat)
	colorlist = {
		['red'] = 1382830, --#
		['green'] = 52480,
		['green2'] = 6737152,				
		['blue'] = 12016200,
		['yellow'] = 172217,		
		['orange'] = 36095,
		['pink'] = 16711935,						
		['purple'] = 13828244
	}
	-- check dat
	for key,value in next, colorlist, nil do
		if key == dat then
			do return value end
		end
	end
	return 255
end

--| HeaderHelper v1.0
--|
--|=== Change Log :
--| ---------------
--| * v1.0 - 29 Juli 2021
--| - Split evey function by category

--| Rewrite Answer Header
function RewriteAnswerHeader(config)

	local new_answer_header	= hc.answer_header
	-- Remove Header Last-Modified
	if LastModifiedExist(new_answer_header) == true and config['del_last_modified'] == true then
		new_answer_header = re.replace(new_answer_header, '[lL]ast-[mM]odified: .*?\r\n', nil)
	end
	-- Remove Server: Handycache...
	if ServerExist(new_answer_header) == true and config['del_server'] == true then
		new_answer_header = re.replace(new_answer_header, 'Server: HandyCache.*?\r\n', nil)
	end
	if config['add_cache_control'] == true then
		-- check cache-control
		if CacheControlExist(new_answer_header) then
			-- if exist replace value
			hc.answer_header = re.replace(hc.answer_header, [[[Cc]ache-[Cc]ontrol: \K[^\r\n]+]], 'max-age=31536000')
		else
			-- if not exist create new
			hc.answer_header = re.replace(hc.answer_header, [[\r\n]], '\r\nCache-Control: max-age=31536000\r\n')
			-- #debugging
			-- hc.monitor_string = 'cc.inject'
		end
	end
	-- add Header Access-Control-Allow-Origin:
	if config['add_cors'] == true then
		-- check if access-control-allow-origin exist > delete
		if AccessControlAllowOriginExist(new_answer_header) == true then
			-- delete if exist if header duplicate request will be error
			-- remove Access Control if detect two access control cors will be error
			new_answer_header = re.replace(new_answer_header, 'Access-Control-Allow-Origin: .*?\r\n', nil)
		end
	end	
	--  return for re-process again on call function
	return new_answer_header
end

--| Rewrite URL
function reWrite(we,res)
	if re.match(url, [[^https?://.*]]) then
		-- ex regex : GET http://site.com/ HTTP/1.1
		hc.request_header = re.replace(hc.request_header, [[^(GET\s)[^\s]+(\sHTTP/[\d\.]+\r\n)]], '\\1'..we..'\\2')
		if res then
			hc.monitor_string = hc.monitor_string..'rw'
		end
	end
end

--| Header Headers Validation

function isSaveable(res)
	if re.match(res, '[cC]ache-[cC]ontrol: (public|(max-age|s-maxage)=[^ 0]+[0-9]+|immutable)') then d = true else d = false end return d
end

function isContentRangeStart(res)
	if re.match(res, [[^[cC]ontent-[rR]ange:\sbytes\s0-.*]]) then d = true else d = false end return d
end

function AccessControlAllowOriginExist(res)
	if re.match(res, '^Access-Control-Allow-Origin: .*') then d = true else d = false end return d
end

function LastModifiedExist(res)
	if re.match(res, '[lL]ast-[mM]odified: .*?') then d = true else d = false end return d
end

function ServerExist(res)
	if re.match(res, [[^Server: HandyCache[^\r\n]+]]) then d = true else d = false end return d
end

function CacheControlExist(res)
	if re.match(res, [[[Cc]ache-[Cc]ontrol]]) then d = true else d = false end return d
end

function OriginExist(res)
	if re.match(res, [[[oO]rigin:]]) then d = true else d = false end return d
end

--| Helper Header Extract

--|
--| Header about URL
--|

function GetURL(s)
	_,_,x = string.find(s, '[gG]ET *([^;\r\n]+) HTTP/')
	if x==nil then return -1 else return x end
end

function GetAnswerCode(s)
	_,_,x = string.find(s, 'HTTP/1%.%d +(%d+)')
	if x==nil then return -1 else return tonumber(x) end
end

function GetReferer(s)
	_,_,x = string.find(s, [[Referer:(.*?)]])
	if x==nil then return -1 else return x end
end

function GetContentType(s)
	_,_,x = string.find(s, '[cC]ontent%-[tT]ype: *(.-) *\r?\n')
	if x==nil then return -1 else return string.lower(x) end
end

function GetHost(s)
	_,_,x = string.find(s, '[hH]ost: *([^;\r\n]+)')
	if x==nil then return -1 else return x end
end

--|
--| Header Browser
--|

function GetUserAgent(s)
	_,_,x = string.find(s, '[uU]ser%-[aA]gent: *([^\r\n]+)')
	if x==nil then return -1 else return x end
end


--|
--| Header Storage
--|

function GetCookie(s)
	_,_,x = string.find(s, '[cC]ookie: *([^\r\n]+)')
	if x==nil then return -1 else return x end
end

--|
--| Header Range - Length
--|

function GetContentLength(s)
	_,_,x = string.find(s, '[cC]ontent%-[lL]ength: *(%d+)')
	if x==nil then return -1 else return tonumber(x) end
end

function GetContentRange(s)
	-- _,_,x = string.find(s, '[cC]ontent-[rR]ange:.*/(%d+)')
	_,_,x = string.find(s, '[cC]ontent%-[rR]ange: *([^;\r\n]+)')
	if x==nil then return -1 else return x end
end

function GetAcceptRanges(s)
	_,_,x = string.find(s, '[aA]ccept%-[rR]anges: *([^;\r\n]+)')
	if x==nil then return -1 else return x end
end

--|
--| Header Validation
--|

function GetContentEncoding(s)
	_,_,x = string.find(s, '[cC]ontent%-[eE]ncoding: *(.-) *\r?\n')
	if x==nil then return -1 else return string.lower(x) end
end

function GetOrigin(s)
	_,_,x = string.find(s, '[oO]rigin: *([^;\r\n]+)')
	if x==nil then return -1 else return x end
	-- return re.find(s, '(?-s)(^Origin: (.+))', 2)
end


function GetCacheControl(s)
	_,_,x = string.find(s, '[cC]ache%-[cC]ontrol: *([^;\r\n]+)')
	if x==nil then return -1 else return x end
end

function GetAccept(s)
	_,_,x = string.find(s, '[aA]ccept: *([^;\r\n]+)')
	if x==nil then return -1 else return string.lower(x) end
end

function GetAcceptEncoding(s)
	_,_,x = string.find(s, '[aA]ccept%-[eE]ncoding: *([^;\r\n]+)')
	if x==nil then return -1 else return string.lower(x) end
end

--| URLHelper v1.0
--|
--|=== Change Log :
--| ---------------
--| * v1.0 - 29 Juli 2021
--| - Split evey function by category

function urldecode(s)
	s = s:gsub('+', ' ')
	:gsub('%%(%x%x)', function(h)
		return string.char(tonumber(h, 16))
		end)
	return s
end

function parseurl(s)
	local ans = {}
	for k,v in s:gmatch('([^&=?]-)=([^&=?]+)' ) do
		ans[ k ] = urldecode(v)
	end
	return ans
end

function ConvertURLToSaveable(url,showlog)

	-- Remove Protocol From URL
	new_name = re.replace(url, [[^(?:https?:\/\/)?(?:www[0-9]+\.)?(\?|.+|$)]], '\\1') -- # remove prefix https|http|www for save file outside folder https! 
	new_name = re.replace(new_name, [[(\\|\:|\*|\"|\<|\>|\|)]], nil, true) -- # remove symbol they can't be write on windows
	new_name = re.replace(new_name, [[:[0-9]+]], nil, true) -- # remove port from url

	-- convert if exist parameter to uique string using crc32 and set to filename
	if re.find(new_name, [[(\/\?|\?|\,|\:|\;)]]) then
		fullpath = re.replace(new_name, [[(^.*?)(\/\?|\?|\,|\:|\;).*]], '\\1')
		parameter = re.replace(new_name, [[^.*?((/\?|\?|\,|\:|\;).*)]], '\\1')
		xcrc = hc.crc32(parameter)
		prextransform = hc.prepare_url(fullpath)
		xtransform = hc.cache_path..prextransform..'\\'..xcrc
		if showlog then hc.monitor_string = 'u1' end
	else
		prextransform = hc.prepare_url(new_name)
		xtransform = hc.cache_path..prextransform
		if showlog then hc.monitor_string = 'u2' end
	end

	return xtransform
end

--| ValideHelper v1.0
--|
--|=== Change Log :
--| ---------------
--| * v1.0 - 29 Juli 2021
--| - Split evey function by category

function isExist(s)
	if string.len(s) >= 1 then d = true else d = false end return d
end

function isempty(s)
	return s == nil or s == ''
end

function isInt(n)
	return (type(n) == "number") and (math.floor(n) == n)
end

function isFileExist(name)
	local f=io.open(name,"r")
	if f~=nil then io.close(f) return true else return false end
end