1.公有接口和作业所述相同
  test.lua 中重定义了print方法，方便打印lua table
	注意：转义字符没有处理
2.私有方法包括了
	a.  str_2_table(table_str)
	  当传入的json是lua table类型时，调用该方法处理
	b.  str_split(table_str, strList)
       分割string转lua table
    c. table_2_str(lua_table)
		lua table 转string