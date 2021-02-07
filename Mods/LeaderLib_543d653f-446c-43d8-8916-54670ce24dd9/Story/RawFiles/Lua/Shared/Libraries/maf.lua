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

	__add = function(v, u) return v:Add(u, Vector3()) end,
	__sub = function(v, u) return v:Sub(u, Vector3()) end,
	__mul = function(v, u)
		if Vector3.IsVector3(u) then return v:Mul(u, Vector3())
		elseif type(u) == 'number' then return v:Scale(u, Vector3())
		else error('vec3s can only be multiplied by vec3s and numbers') end
	end,
	__div = function(v, u)
		if Vector3.IsVector3(u) then return v:Div(u, Vector3())
		elseif type(u) == 'number' then return v:Scale(1 / u, Vector3())
		else error('vec3s can only be divided by vec3s and numbers') end
	end,
	__unm = function(v) return v:Scale(-1) end,
	__len = function(v) return v:Length() end
}
Vector3.__index = Vector3

function Vector3:IsVector3(x)
	return getmetatable(x) == Vector3
end

---@param v Vector3
function Vector3:Clone(v)
	return Vector3(v.x, v.y, v.z)
end

---@param v Vector3
---@return number,number,number
function Vector3:Unpack(v)
	return v.x, v.y, v.z
end

---@param v Vector3
---@param x number
---@param y number
---@param z number
---@return Vector3
function Vector3:Set(v, x, y, z)
	if Vector3.IsVector3(x) then x, y, z = x.x, x.y, x.z end
	v.x = x
	v.y = y
	v.z = z
	return v
end

---@param v Vector3
---@param u Vector3
---@param out Vector3|nil
function Vector3:Add(v, u, out)
	out = out or v
	out.x = v.x + u.x
	out.y = v.y + u.y
	out.z = v.z + u.z
	return out
end

---@param v Vector3
---@param u Vector3
---@param out Vector3|nil
function Vector3:Sub(v, u, out)
	out = out or v
	out.x = v.x - u.x
	out.y = v.y - u.y
	out.z = v.z - u.z
	return out
end

---@param v Vector3
---@param u Vector3
---@param out Vector3|nil
function Vector3:Mul(v, u, out)
	out = out or v
	out.x = v.x * u.x
	out.y = v.y * u.y
	out.z = v.z * u.z
	return out
end

---@param v Vector3
---@param u Vector3
---@param out Vector3|nil
function Vector3:Div(v, u, out)
	out = out or v
	out.x = v.x / u.x
	out.y = v.y / u.y
	out.z = v.z / u.z
	return out
end

---@param v Vector3
---@param s number
---@param out Vector3|nil
function Vector3:Scale(v, s, out)
	out = out or v
	out.x = v.x * s
	out.y = v.y * s
	out.z = v.z * s
	return out
end

---@param v Vector3
function Vector3:Length(v)
	return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
end

---@param v Vector3
---@param out Vector3
function Vector3:Normalize(v, out)
	out = out or v
	local len = v:Length()
	return len == 0 and v or v:Scale(1 / len, out)
end

---@param v Vector3
---@param u Vector3
function Vector3:Distance(v, u)
	return Vector3.sub(v, u, vtmp1):Length()
end

---@param v Vector3
---@param u Vector3
function Vector3:Angle(v, u)
	return math.acos(v:Dot(u) / (v:Length() + u:Length()))
end

---@param v Vector3
---@param u Vector3
function Vector3:Dot(v, u)
	return v.x * u.x + v.y * u.y + v.z * u.z
end

---@param v Vector3
---@param u Vector3
---@param out Vector3|nil
function Vector3:Cross(v, u, out)
	out = out or v
	local a, b, c = v.x, v.y, v.z
	out.x = b * u.z - c * u.y
	out.y = c * u.x - a * u.z
	out.z = a * u.y - b * u.x
	return out
end

---@param v Vector3
---@param u Vector3
---@param t number
---@param out Vector3|nil
function Vector3:Lerp(v, u, t, out)
	out = out or v
	out.x = v.x + (u.x - v.x) * t
	out.y = v.y + (u.y - v.y) * t
	out.z = v.z + (u.z - v.z) * t
	return out
end

---@param v Vector3
---@param u Vector3
---@param out Vector3|nil
function Vector3:Project(v, u, out)
	out = out or v
	local unorm = vtmp1
	u:Normalize(unorm)
	local dot = v:Dot(unorm)
	out.x = unorm.x * dot
	out.y = unorm.y * dot
	out.z = unorm.z * dot
	return out
end

---@param v Vector3
---@param q Quaternion
---@param out Vector3|nil
function Vector3:Rotate(v, q, out)
	out = out or v
	local u, c, o = vtmp1, vtmp2, out
	u.x, u.y, u.z = q.x, q.y, q.z
	o.x, o.y, o.z = v.x, v.y, v.z
	u:Cross(v, c)
	local uu = u:Dot(u)
	local uv = u:Dot(v)
	o:Scale(q.w * q.w - uu)
	u:Scale(2 * uv)
	c:Scale(2 * q.w)
	return o:Add(u:Add(c))
end

Quaternion = {
	__call = function(_, x, y, z, w)
		return setmetatable({ x = x, y = y, z = z, w = w }, Quaternion)
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

---@param q Quaternion
function Quaternion:Clone(q)
	return Quaternion(q.x, q.y, q.z, q.w)
end

---@param q Quaternion
---@return number,number,number
function Quaternion:Unpack(q)
	return q.x, q.y, q.z, q.w
end

---@param q Quaternion
---@param x number
---@param y number
---@param z number
---@param w number
function Quaternion:Set(q, x, y, z, w)
	if Quaternion.IsQuaternion(x) then x, y, z, w = x.x, x.y, x.z, x.w end
	q.x = x
	q.y = y
	q.z = z
	q.w = w
	return q
end

---@param angle number
---@param x number
---@param y number
---@param z number
function Quaternion:FromAngleAxis(angle, x, y, z)
	return Quaternion():SetAngleAxis(angle, x, y, z)
end

---@param q Quaternion
---@param angle number
---@param x number
---@param y number
---@param z number
function Quaternion:SetAngleAxis(q, angle, x, y, z)
	if Vector3.IsVector3(x) then x, y, z = x.x, x.y, x.z end
	local s = math.sin(angle * .5)
	local c = math.cos(angle * .5)
	q.x = x * s
	q.y = y * s
	q.z = z * s
	q.w = c
	return q
end

---@param q Quaternion
function Quaternion:GetAngleAxis(q)
	if q.w > 1 or q.w < -1 then q:Normalize() end
	local s = math.sqrt(1 - q.w * q.w)
	s = s < .0001 and 1 or 1 / s
	return 2 * math.acos(q.w), q.x * s, q.y * s, q.z * s
end

---@param u Vector3
---@param v Vector3
function Quaternion:Between(u, v)
	return Quaternion():SetBetween(u, v)
end

---@param q Quaternion
---@param u Vector3
---@param v Vector3
function Quaternion:SetBetween(q, u, v)
	local dot = u:Dot(v)
	if dot > .99999 then
		q.x, q.y, q.z, q.w = 0, 0, 0, 1
		return q
	elseif dot < -.99999 then
		vtmp1.x, vtmp1.y, vtmp1.z = 1, 0, 0
		vtmp1:Cross(u)
		if #vtmp1 < .00001 then
			vtmp1.x, vtmp1.y, vtmp1.z = 0, 1, 0
			vtmp1:Cross(u)
		end
		vtmp1:Normalize()
		return q:SetAngleAxis(math.pi, vtmp1)
	end
	
	q.x, q.y, q.z = u.x, u.y, u.z
	Vector3.cross(q, v)
	q.w = 1 + dot
	return q:Normalize()
end

---@param x number
---@param y number
---@param z number
function Quaternion:FromDirection(x, y, z)
	return Quaternion():SetDirection(x, y, z)
end

---@param q Quaternion
---@param x number
---@param y number
---@param z number
function Quaternion:SetDirection(q, x, y, z)
	if Vector3.IsVector3(x) then x, y, z = x.x, x.y, x.z end
	vtmp2.x, vtmp2.y, vtmp2.z = x, y, z
	return q:SetBetween(forward, vtmp2)
end

---@param q Quaternion
---@param r Quaternion
---@param out Quaternion
function Quaternion:Add(q, r, out)
	out = out or q
	out.x = q.x + r.x
	out.y = q.y + r.y
	out.z = q.z + r.z
	out.w = q.w + r.w
	return out
end

---@param q Quaternion
---@param r Quaternion
---@param out Quaternion
function Quaternion:Sub(q, r, out)
	out = out or q
	out.x = q.x - r.x
	out.y = q.y - r.y
	out.z = q.z - r.z
	out.w = q.w - r.w
	return out
end

---@param q Quaternion
---@param r Quaternion
---@param out Quaternion
function Quaternion:Mul(q, r, out)
	out = out or q
	local qx, qy, qz, qw = q:Unpack()
	local rx, ry, rz, rw = r:Unpack()
	out.x = qx * rw + qw * rx + qy * rz - qz * ry
	out.y = qy * rw + qw * ry + qz * rx - qx * rz
	out.z = qz * rw + qw * rz + qx * ry - qy * rx
	out.w = qw * rw - qx * rx - qy * ry - qz * rz
	return out
end

---@param q Quaternion
---@param s number
---@param out Quaternion
function Quaternion:Scale(q, s, out)
	out = out or q
	out.x = q.x * s
	out.y = q.y * s
	out.z = q.z * s
	out.w = q.w * s
	return out
end

---@param q Quaternion
function Quaternion:Length(q)
	return math.sqrt(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w)
end

---@param q Quaternion
---@param out Quaternion
function Quaternion:Normalize(q, out)
	out = out or q
	local len = q:Length()
	return len == 0 and q or q:Scale(1 / len, out)
end

---@param q Quaternion
---@param r Quaternion
---@param t number
---@param out Quaternion
function Quaternion:Lerp(q, r, t, out)
	out = out or q
	r:Scale(t, qtmp1)
	q:Scale(1 - t, out)
	return out:Add(qtmp1)
end

---@param q Quaternion
---@param r Quaternion
---@param t number
---@param out Quaternion
function Quaternion:Slerp(q, r, t, out)
	out = out or q
	
	local dot = q.x * r.x + q.y * r.y + q.z * r.z + q.w * r.w
	if dot < 0 then
		dot = -dot
		r:Scale(-1)
	end
	
	if 1 - dot < .0001 then
		return q:Lerp(r, t, out)
	end
	
	local theta = math.acos(dot)
	q:Scale(math.sin((1 - t) * theta), out)
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