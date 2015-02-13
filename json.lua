--[[ @author: zoomin
     @date: 2015-02-07
	 This is netease homework for lua json.
	 ]]

local json = {}


local tinsert = table.insert
local tconcat = table.concat
local sformat = string.format
local smatch = string.match
local ssub = string.sub
local sgsub = string.gsub
local sfind = string.find
local slen = string.len
-----------------------------------------------
--- Json string to Lua variable
-- @param json_str : json string
-- @return Lua variable
-----------------------------------------------
function json.Marshal(json_str)
	local lua_val = nil
	local error_msg = ""

	if json_str == "null" then            --nil
		lua_val = nil
	elseif json_str == "false" then       --boolean
		lua_val = false
	elseif json_str == "true" then
		lua_val = true
	elseif tonumber(json_str) then     --number
        lua_val = tonumber(json_str)
	elseif smatch(json_str,'^".*"$') or   smatch(json_str,"^'.*'$") then      --str
		lua_val = json_str
	else
		lua_val, error_msg = str_2_table(json_str)
	end
	return lua_val, error_msg
end



function str_2_table(table_str)
    --step1: replace str value and space for splitting
	local strList = {}
    local quot = '"'
	if sfind(table_str, "'") then
		quot = "'"
	end

	-- check "'" or '"' in pairs
	local resStr, n = sgsub(table_str, quot, quot)
	if n % 2 ~= 0 then
		return nil, "quotation not match!"
	end
	-- replace str val
	local count = 0
	if quot == '"' then
		table_str = sgsub(table_str, '"(.-)"', function(w) tinsert(strList, w) count = count + 1 return '"'..tostring(count)..'"' end)
	else
		table_str = sgsub(table_str, "'(.-)'", function(w) tinsert(strList, w) count = count + 1 return "'"..tostring(count).."'" end)
	end
	-- remove space
	table_str = sgsub(table_str, " ", "")

	--step2: global wrong format check
	-- illegal character
	local illegalPos = sfind(sgsub(table_str,"-",""), "[^]'\":{,%w}[]")
	if illegalPos then
		return nil, "illegal character: \""..ssub(table_str, illegalPos, illegalPos).."\" at position: "..illegalPos
	end

	-- check "[" and ']' in pairs
	local resStr1, n1 = sgsub(table_str, "[[]", "[[]")
	local resStr2, n2 = sgsub(table_str, "[]]", "[]]")
	if n1 ~= n2 then
		return nil, "\"[\" and \"]\" not match!"
	end

	-- check "{" and '}' in pairs
	local resStr3, n3 = sgsub(table_str, "{", "{")
	local resStr4, n4 = sgsub(table_str, "}", "}")
	if n3 ~= n4 then
		return nil, "\"{\" and \"}\" not match!"
	end

	--step3: split
	return str_split(table_str, strList)
end

function str_split(table_str, strList)
	if not sfind(table_str, "[]{,}[]") then   --single item
		local valstr, isOk = handle_val(table_str, strList)
		if isOk then
			return valstr, ""
		else
			return nil, "value "..table_str.." in wrong format"
		end
	end
	-- handle data
		-- check how many children on this level
	local braceStk = {}
    local spos = 1
	local tpos = 1
	local count = 1
	local childS = {}
	--isArray
	--local fatherLBrace, fatherRBrace = "[", "]"

	--if smatch(table_str,'^{.*}$') then
	--	fatherLBrace, fatherRBrace = "{", "}"
	--end

	local fatherLBrace, fatherRBrace = "{", "}"
	table_str = sgsub(table_str, "[[]", "{")
	table_str = sgsub(table_str, "[]]", "}")

	local cutStr = table_str
	while true do
		local tblLen = slen(cutStr)
		if tblLen <= 0 then
			break
		end

		local tmpChar = ssub(cutStr, 1, 1)
		cutStr = ssub(cutStr, 2, tblLen)

		if tmpChar == fatherLBrace then
			if table.getn(braceStk) == 0 then
				spos = count + 1
			end
			tinsert(braceStk, tmpChar)
		elseif tmpChar == fatherRBrace then
			if table.getn(braceStk) > 0 then
				table.remove(braceStk)
			end
		elseif 	tmpChar == "," and table.getn(braceStk) == 1 then
			tpos = count - 1
			tinsert(childS, ssub(table_str, spos, tpos))
			spos = count + 1
		end
		count = count + 1
	end

	tinsert(childS, ssub(table_str, spos, count - 2))


    -- process result
	local resContainer = {}
	local tblIndex = nil
	for i, v in ipairs(childS) do
		local equalpos = sfind(childS[i], ":")
		if equalpos and not smatch(childS[i],'^{.*}$') then
			pkeystr = ssub(childS[i], 1, equalpos - 1)
			childS[i] = ssub(childS[i], equalpos + 1)

			if not check_key(pkeystr) then
				return nil, "key "..pkeystr.." in wrong format"
			end
			local tmptbl = {}
			tblIndex = sgsub(pkeystr, "['\"]", "")
		end

		local curRes, curError = str_split(childS[i], strList)
		if curError ~= "" then
			return nil, curError
		end
		if curRes ~= nil then
			if tblIndex then
				resContainer[strList[tonumber(tblIndex)]] = curRes
			else
				tinsert(resContainer, curRes)
			end
		end
	end

	return resContainer, ""

end

function check_key(key_str)
	if key_str ~= nil and (smatch(key_str,'^".*"$') or   smatch(key_str,"^'.*'$")) then    --string
		return true
	else
		return false
	end
end

function handle_val(val_str, strList)
	local dotstr, dotnum = sgsub(val_str, "[.]", "[.]")

	local json_str = nil
	if smatch(val_str,'^".*"$') or   smatch(val_str,"^'.*'$") then    --string
		local tblIndex = sgsub(val_str, "['\"]", "")
		return strList[tonumber(tblIndex)], true
	elseif val_str == "null" then            --nil
		return nil, true
	elseif val_str == "false" then       --boolean
		return false, true
	elseif val_str == "true" then
		return true, true
	elseif dotnum <= 1 and tonumber(val_str) then        --number
        return tonumber(val_str), true
	elseif val_str == "" then
		return nil, true
	else
		return "", false
	end
end

-----------------------------------------------
--- Lua variable to json string
-- @param lua_val : lua variable
-- @return json string
-----------------------------------------------
function json.Unmarshal(lua_val)
	json_str = ""
	if lua_val ~= nil then
		if type(lua_val) ~= "table" then       -- string needs to add quotation
			if type(lua_val) == "string" then
				json_str = string.format("%q", lua_val)
			elseif type(lua_val) == "number" then
				json_str = sformat('%.16g', v)
			else
				json_str = tostring(lua_val)
            end
		else
			json_str = table_2_str(lua_val)
        end
	else
		json_str = "null"         -- nil --> null
	end
	return json_str
end



function table_2_str(lua_table)
	-- empty table
	if next(lua_table) == nil then
		return "{}"
	end

	-- if it's an array format
	local isArray = true
	for k, v in pairs(lua_table) do
		if type(k) ~= "number" or k <= 0 then
			isArray = false
		    break
		end
    end

    local container = {}
    for k, v in pairs(lua_table) do
		if isArray then
			-- handle key
			local keystr = "null"

			--handle value

			local valuestr = nil

			if type(v) == "string" then
				valuestr = sformat("%q", tostring(v))
			elseif type(v) == "number" then
				valuestr = sformat('%.16g', v)
			elseif type(v) == "boolean" then
				valuestr = tostring(v)
			elseif type(v) == "table" then
				valuestr = table_2_str(v)
			end

			tinsert(container, sformat("%s,%s", keystr, valuestr))
		else
			-- handle key
			local keystr = nil
			if type(k) == "string" or type(k) == "number" then
				keystr = sformat("%q", k)
			end

			-- handle value
			local valuestr = nil
			if type(v) == "string" then
				valuestr = sformat("%q", tostring(v))
			elseif type(v) == "number" then
				valuestr = sformat('%.16g', v)
			elseif type(v) == "boolean" then
				valuestr = tostring(v)
			elseif type(v) == "table" then
				valuestr = table_2_str(v)
			end
			if keystr then
				tinsert(container, sformat("%s: %s", keystr, valuestr))
			end
		end
    end


	if isArray then
		return sformat("[%s]", tconcat(container, ","))
	else
		return sformat("{%s}", tconcat(container, ","))
	end
end


return json


