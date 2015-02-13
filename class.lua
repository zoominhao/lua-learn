------------------------------------------------------------
--Stack Class
------------------------------------------------------------
Stack = {size = 0, container = {}}
Stack.__index = Stack
-- method
function Stack:create()
	local stk = {}
	setmetatable(stk, Stack)
	return stk
end

function Stack:push(item)
	self.size = self.size + 1
	self.container[self.size] = item
end

function Stack:pop()
	if self.size > 0 then
		self.container[self.size] = nil
		self.size = self.size - 1
	else
		print("Stack is empty, pop failed!")
	end
end

function Stack:top()
	if self.size > 0 then
		local val = self.container[self.size]
		return val
	else
		return nil
	end
end

function Stack:empty()
	if self.size == 0 then
		return true
	else
		return false
	end
end

function Stack:clear()
	while self.size > 0 do
		self:pop()
	end
end

------------------------------------------------------------
--Stack Class
------------------------------------------------------------