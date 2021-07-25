-- maf
-- https://github.com/bjornbytes/maf
-- MIT License


-- Modified for DOS2 by LaughingLeader, mainly name casing and EmmyLua support for VSCode.

---@class Vector3
local Vector3
---@class Quaternion
local Quaternion

---@type Vector3
local forward
---@type Vector3
local vtmp1
---@type Vector3
local vtmp2
---@type Quaternion
local qtmp1

Vector3 = {
	__call = function(_, x, y, z)
		return setmetatable({ x = x or 0, y = y or 0, z = z or 0 }, Vector3)
	end,

	__tostring = function(v)
		return string.format('(%f, %f, %f)', v.x, v.y, v.z)
	end,

	__add = function(v, u) return self:Add(u, Vector3()) end,
	__sub = function(v, u) return self:Sub(u, Vector3()) end,
	__mul = function(v, u)
		if Vector3.IsVector3(u) then return self:Mul(u, Vector3())
		elseif type(u) == 'number' then return self:Scale(u, Vector3())
		else error('vec3s can only be multiplied by vec3s and numbers') end
	end,
	__div = function(v, u)
		if Vector3.IsVector3(u) then return self:Div(u, Vector3())
		elseif type(u) == 'number' then return self:Scale(1 / u, Vector3())
		else error('vec3s can only be divided by vec3s and numbers') end
	end,
	__unm = function(v) return self:Scale(-1) end,
	__len = function(v) return self:Length() end
}
Vector3.__index = Vector3

function Vector3:IsVector3(x)
	return getmetatable(x) == Vector3
end

function Vector3:Clone(v)
	return Vector3(self.x, self.y, self.z)
end

---@return number,number,number
function Vector3:Unpack(v)
	return self.x, self.y, self.z
end

---@param x number
---@param y number
---@param z number
---@return Vector3
function Vector3:Set(x, y, z)
	if Vector3.IsVector3(x) then x, y, z = x.x, x.y, x.z end
	self.x = x
	self.y = y
	self.z = z
	return self
end

---@param u Vector3
---@param out Vector3|nil
function Vector3:Add(u, out)
	out = out or self
	out.x = self.x + u.x
	out.y = self.y + u.y
	out.z = self.z + u.z
	return out
end

---@param u Vector3
---@param out Vector3|nil
function Vector3:Sub(u, out)
	out = out or self
	out.x = self.x - u.x
	out.y = self.y - u.y
	out.z = self.z - u.z
	return out
end

---@param u Vector3
---@param out Vector3|nil
function Vector3:Mul(u, out)
	out = out or self
	out.x = self.x * u.x
	out.y = self.y * u.y
	out.z = self.z * u.z
	return out
end

---@param u Vector3
---@param out Vector3|nil
function Vector3:Div(u, out)
	out = out or self
	out.x = self.x / u.x
	out.y = self.y / u.y
	out.z = self.z / u.z
	return out
end

---@param s number
---@param out Vector3|nil
function Vector3:Scale(s, out)
	out = out or self
	out.x = self.x * s
	out.y = self.y * s
	out.z = self.z * s
	return out
end

function Vector3:Length(v)
	return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

---@param out Vector3
function Vector3:Normalize(out)
	out = out or self
	local len = self:Length()
	return len == 0 and self or self:Scale(1 / len, out)
end

---@param u Vector3
---@return number
function Vector3:Distance(u)
	return Vector3.sub(u, vtmp1):Length()
end

---@param u Vector3
function Vector3:Angle(u)
	return math.acos(self:Dot(u) / (self:Length() + u:Length()))
end

---@param u Vector3
function Vector3:Dot(u)
	return self.x * u.x + self.y * u.y + self.z * u.z
end

---@param u Vector3
---@param out Vector3|nil
function Vector3:Cross(u, out)
	out = out or self
	local a, b, c = self.x, self.y, self.z
	out.x = b * u.z - c * u.y
	out.y = c * u.x - a * u.z
	out.z = a * u.y - b * u.x
	return out
end

---@param u Vector3
---@param t number
---@param out Vector3|nil
function Vector3:Lerp(u, t, out)
	out = out or self
	out.x = self.x + (u.x - self.x) * t
	out.y = self.y + (u.y - self.y) * t
	out.z = self.z + (u.z - self.z) * t
	return out
end

---@param u Vector3
---@param out Vector3|nil
function Vector3:Project(u, out)
	out = out or self
	local unorm = vtmp1
	u:Normalize(unorm)
	local dot = self:Dot(unorm)
	out.x = unorm.x * dot
	out.y = unorm.y * dot
	out.z = unorm.z * dot
	return out
end

---@param q Quaternion
---@param out Vector3|nil
function Vector3:Rotate(q, out)
	out = out or self
	local u, c, o = vtmp1, vtmp2, out
	u.x, u.y, u.z = q.x, q.y, q.z
	o.x, o.y, o.z = out.x, out.y, out.z
	u:Cross(c)
	local uu = u:Dot(u)
	local uv = u:Dot(out)
	o:Scale(q.w * q.w - uu)
	u:Scale(2 * uv)
	c:Scale(2 * q.w)
	return o:Add(u:Add(c))
end

Quaternion = {
	__call = function(_, x, y, z, w)
		return setmetatable({ x = x or 0.0, y = y or 0.0, z = z or 0.0, w = w or 1.0 }, Quaternion)
	end,

	__tostring = function(q)
		return string.format('(%f, %f, %f, %f)', q.x, q.y, q.z, q.w)
	end,

	__add = function(q, r) return q:Add(r, Quaternion()) end,
	__sub = function(q, r) return q:Sub(r, Quaternion()) end,
	__mul = function(q, r)
		if Quaternion.IsQuaternion(r) then return q:Mul(r, Quaternion())
		elseif Vector3.IsVector3(r) then return r:Rotate(q, Vector3())
		else error('quats can only be multiplied by quats and vec3s') end
	end,
	__unm = function(q) return q:Scale(-1) end,
	__len = function(q) return q:Length() end,
}

Quaternion.__index = Quaternion

function Quaternion:IsQuaternion(x)
	return getmetatable(x) == Quaternion
end

function Quaternion:Clone()
	return Quaternion(self.x, self.y, self.z, self.w)
end

---@return number,number,number
function Quaternion:Unpack()
	return self.x, self.y, self.z, self.w
end

---@param x number
---@param y number
---@param z number
---@param w number
function Quaternion:Set(x, y, z, w)
	if Quaternion.IsQuaternion(x) then x, y, z, w = x.x, x.y, x.z, x.w end
	self.x = x
	self.y = y
	self.z = z
	self.w = w
	return self
end

---@param angle number
---@param x number
---@param y number
---@param z number
function Quaternion:FromAngleAxis(angle, x, y, z)
	return Quaternion():SetAngleAxis(angle, x, y, z)
end

---@param angle number
---@param x number
---@param y number
---@param z number
function Quaternion:SetAngleAxis(angle, x, y, z)
	if Vector3.IsVector3(x) then x, y, z = x.x, x.y, x.z end
	local s = math.sin(angle * .5)
	local c = math.cos(angle * .5)
	self.x = x * s
	self.y = y * s
	self.z = z * s
	self.w = c
	return self
end

function Quaternion:GetAngleAxis()
	if self.w > 1 or self.w < -1 then self:Normalize() end
	local s = math.sqrt(1 - self.w * self.w)
	s = s < .0001 and 1 or 1 / s
	return 2 * math.acos(self.w), self.x * s, self.y * s, self.z * s
end

---@param u Vector3
---@param v Vector3
function Quaternion:Between(u, v)
	return Quaternion():SetBetween(u, v)
end

---@param u Vector3
---@param v Vector3
function Quaternion:SetBetween(u, v)
	local dot = u:Dot(v)
	if dot > .99999 then
		self.x, self.y, self.z, self.w = 0, 0, 0, 1
		return self
	elseif dot < -.99999 then
		vtmp1.x, vtmp1.y, vtmp1.z = 1, 0, 0
		vtmp1:Cross(u)
		if #vtmp1 < .00001 then
			vtmp1.x, vtmp1.y, vtmp1.z = 0, 1, 0
			vtmp1:Cross(u)
		end
		vtmp1:Normalize()
		return self:SetAngleAxis(math.pi, vtmp1)
	end
	
	self.x, self.y, self.z = u.x, u.y, u.z
	Vector3.cross(v)
	self.w = 1 + dot
	return self:Normalize()
end

---@param x number
---@param y number
---@param z number
function Quaternion:FromDirection(x, y, z)
	return Quaternion():SetDirection(x, y, z)
end

---@param x number
---@param y number
---@param z number
function Quaternion:SetDirection(x, y, z)
	if Vector3.IsVector3(x) then x, y, z = x.x, x.y, x.z end
	vtmp2.x, vtmp2.y, vtmp2.z = x, y, z
	return self:SetBetween(forward, vtmp2)
end

---@param r Quaternion
---@param out Quaternion
function Quaternion:Add(r, out)
	out = out or self
	out.x = self.x + r.x
	out.y = self.y + r.y
	out.z = self.z + r.z
	out.w = self.w + r.w
	return out
end

---@param r Quaternion
---@param out Quaternion
function Quaternion:Sub(r, out)
	out = out or self
	out.x = self.x - r.x
	out.y = self.y - r.y
	out.z = self.z - r.z
	out.w = self.w - r.w
	return out
end

---@param r Quaternion
---@param out Quaternion
function Quaternion:Mul(r, out)
	out = out or self
	local qx, qy, qz, qw = self:Unpack()
	local rx, ry, rz, rw = r:Unpack()
	out.x = qx * rw + qw * rx + qy * rz - qz * ry
	out.y = qy * rw + qw * ry + qz * rx - qx * rz
	out.z = qz * rw + qw * rz + qx * ry - qy * rx
	out.w = qw * rw - qx * rx - qy * ry - qz * rz
	return out
end

---@param s number
---@param out Quaternion
function Quaternion:Scale(s, out)
	out = out or self
	out.x = self.x * s
	out.y = self.y * s
	out.z = self.z * s
	out.w = self.w * s
	return out
end

function Quaternion:Length()
	return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w)
end

---@param out Quaternion
function Quaternion:Normalize(out)
	out = out or self
	local len = self:Length()
	return len == 0 and self or self:Scale(1 / len, out)
end

---@param r Quaternion
---@param t number
---@param out Quaternion
function Quaternion:Lerp(r, t, out)
	out = out or self
	r:Scale(t, qtmp1)
	self:Scale(1 - t, out)
	return out:Add(qtmp1)
end

---@param r Quaternion
---@param t number
---@param out Quaternion
function Quaternion:Slerp(r, t, out)
	out = out or self
	
	local dot = self.x * r.x + self.y * r.y + self.z * r.z + self.w * r.w
	if dot < 0 then
		dot = -dot
		r:Scale(-1)
	end
	
	if 1 - dot < .0001 then
		return self:Lerp(r, t, out)
	end
	
	local theta = math.acos(dot)
	self:Scale(math.sin((1 - t) * theta), out)
	r:Scale(math.sin(t * theta), qtmp1)
	return out:Add(qtmp1):Scale(1 / math.sin(theta))
end

setmetatable(Vector3, Vector3)
setmetatable(Quaternion, Quaternion)

forward = Vector3(0, 0, -1)
vtmp1 = Vector3()
vtmp2 = Vector3()
qtmp1 = Quaternion()

return {
	Vector3 = Vector3,
	Quaternion = Quaternion,
	Vector = Vector3,
	Rotation = Quaternion
}