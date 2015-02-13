local json = require("json")



function print_lua_table(lua_table, indent)
    if lua_table == nil or type(lua_table) ~= "table" then
        return
    end

    indent = indent or 0
    for k, v in pairs(lua_table) do
        if type(k) == "string" then
            k = string.format("%q", k)
        end
        local szSuffix = ""
        if type(v) == "table" then
            szSuffix = "{"
        end
        local szPrefix = string.rep("    ", indent)
        formatting = szPrefix.."["..k.."]".." = "..szSuffix
        if type(v) == "table" then
            print(tostring(formatting))
            print_lua_table(v, indent + 1)
            print(tostring(szPrefix.."},"))
        else
            local szValue = ""
            if type(v) == "string" then
                szValue = string.format("%q", v)
            else
                szValue = tostring(v)
            end
            print(tostring(formatting..szValue..","))
        end
    end
end

function print_(lua_value)
	if type(lua_value) ~= "table" then
		print(lua_value)
    else
		print("{	")
		print_lua_table(lua_value, 1)
		print("}")
	end

end


local print = print_
local test_result2 = json.Unmarshal({ f="{-4}" , d = {[3] = "sfd", [-3] = {-1.0,  1.23E+10, 1205626556356353654}, {dd = "43\r5"},  "34"}, sggd = {}, dg= false, 6})

print(test_result2)

local test_result1,error_msg = json.Marshal('{"-3": [-1,null,1.205626556356354e+018]}}')
print(test_result1)
print(error_msg)

--local print = print_
--local test_result1,error_msg = json.Marshal('{ "fd":"cthf" , "d" : {"gh" : "sfd", "arr"  :[22332,3, 4 ] , "haha": false}, "num" : 6006700}')
--local test_result1,error_msg = json.Marshal('{"d": [{"dd": "435"}]}')

--local test_result1, error_msg =  json.Marshal("3455.3")
--print(test_result1)
--print(error_msg)







