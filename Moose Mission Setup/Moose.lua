env.info( '*** MOOSE STATIC INCLUDE START *** ' )
env.info( 'Moose Generation Timestamp: 20171010_2135' )

--- Various routines
-- @module routines
-- @author Flightcontrol

env.setErrorMessageBoxEnabled(false)

--- Extract of MIST functions.
-- @author Grimes

routines = {}


-- don't change these
routines.majorVersion = 3
routines.minorVersion = 3
routines.build = 22

-----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
-- Utils- conversion, Lua utils, etc.
routines.utils = {}

--from http://lua-users.org/wiki/CopyTable
routines.utils.deepCopy = function(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	local objectreturn = _copy(object)
	return objectreturn
end


-- porting in Slmod's serialize_slmod2
routines.utils.oneLineSerialize = function(tbl)  -- serialization of a table all on a single line, no comments, made to replace old get_table_string function

	lookup_table = {}
	
	local function _Serialize( tbl )

		if type(tbl) == 'table' then --function only works for tables!
		
			if lookup_table[tbl] then
				return lookup_table[object]
			end

			local tbl_str = {}
			
			lookup_table[tbl] = tbl_str
			
			tbl_str[#tbl_str + 1] = '{'

			for ind,val in pairs(tbl) do -- serialize its fields
				local ind_str = {}
				if type(ind) == "number" then
					ind_str[#ind_str + 1] = '['
					ind_str[#ind_str + 1] = tostring(ind)
					ind_str[#ind_str + 1] = ']='
				else --must be a string
					ind_str[#ind_str + 1] = '['
					ind_str[#ind_str + 1] = routines.utils.basicSerialize(ind)
					ind_str[#ind_str + 1] = ']='
				end

				local val_str = {}
				if ((type(val) == 'number') or (type(val) == 'boolean')) then
					val_str[#val_str + 1] = tostring(val)
					val_str[#val_str + 1] = ','
					tbl_str[#tbl_str + 1] = table.concat(ind_str)
					tbl_str[#tbl_str + 1] = table.concat(val_str)
			elseif type(val) == 'string' then
					val_str[#val_str + 1] = routines.utils.basicSerialize(val)
					val_str[#val_str + 1] = ','
					tbl_str[#tbl_str + 1] = table.concat(ind_str)
					tbl_str[#tbl_str + 1] = table.concat(val_str)
				elseif type(val) == 'nil' then -- won't ever happen, right?
					val_str[#val_str + 1] = 'nil,'
					tbl_str[#tbl_str + 1] = table.concat(ind_str)
					tbl_str[#tbl_str + 1] = table.concat(val_str)
				elseif type(val) == 'table' then
					if ind == "__index" then
					--	tbl_str[#tbl_str + 1] = "__index"
					--	tbl_str[#tbl_str + 1] = ','   --I think this is right, I just added it
					else

						val_str[#val_str + 1] = _Serialize(val)
						val_str[#val_str + 1] = ','   --I think this is right, I just added it
						tbl_str[#tbl_str + 1] = table.concat(ind_str)
						tbl_str[#tbl_str + 1] = table.concat(val_str)
					end
				elseif type(val) == 'function' then
				--	tbl_str[#tbl_str + 1] = "function " .. tostring(ind)
				--	tbl_str[#tbl_str + 1] = ','   --I think this is right, I just added it
				else
--					env.info('unable to serialize value type ' .. routines.utils.basicSerialize(type(val)) .. ' at index ' .. tostring(ind))
--					env.info( debug.traceback() )
				end
	
			end
			tbl_str[#tbl_str + 1] = '}'
			return table.concat(tbl_str)
		else
			return tostring(tbl)
		end
	end
	
	local objectreturn = _Serialize(tbl)
	return objectreturn
end

--porting in Slmod's "safestring" basic serialize
routines.utils.basicSerialize = function(s)
	if s == nil then
		return "\"\""
	else
		if ((type(s) == 'number') or (type(s) == 'boolean') or (type(s) == 'function') or (type(s) == 'table') or (type(s) == 'userdata') ) then
			return tostring(s)
		elseif type(s) == 'string' then
			s = string.format('%q', s)
			return s
		end
	end
end


routines.utils.toDegree = function(angle)
	return angle*180/math.pi
end

routines.utils.toRadian = function(angle)
	return angle*math.pi/180
end

routines.utils.metersToNM = function(meters)
	return meters/1852
end

routines.utils.metersToFeet = function(meters)
	return meters/0.3048
end

routines.utils.NMToMeters = function(NM)
	return NM*1852
end

routines.utils.feetToMeters = function(feet)
	return feet*0.3048
end

routines.utils.mpsToKnots = function(mps)
	return mps*3600/1852
end

routines.utils.mpsToKmph = function(mps)
	return mps*3.6
end

routines.utils.knotsToMps = function(knots)
	return knots*1852/3600
end

routines.utils.kmphToMps = function(kmph)
	return kmph/3.6
end

function routines.utils.makeVec2(Vec3)
	if Vec3.z then
		return {x = Vec3.x, y = Vec3.z}
	else
		return {x = Vec3.x, y = Vec3.y}  -- it was actually already vec2.
	end
end

function routines.utils.makeVec3(Vec2, y)
	if not Vec2.z then
		if not y then
			y = 0
		end
		return {x = Vec2.x, y = y, z = Vec2.y}
	else
		return {x = Vec2.x, y = Vec2.y, z = Vec2.z}  -- it was already Vec3, actually.
	end
end

function routines.utils.makeVec3GL(Vec2, offset)
	local adj = offset or 0

	if not Vec2.z then
		return {x = Vec2.x, y = (land.getHeight(Vec2) + adj), z = Vec2.y}
	else
		return {x = Vec2.x, y = (land.getHeight({x = Vec2.x, y = Vec2.z}) + adj), z = Vec2.z}
	end
end

routines.utils.zoneToVec3 = function(zone)
	local new = {}
	if type(zone) == 'table' and zone.point then
		new.x = zone.point.x
		new.y = zone.point.y
		new.z = zone.point.z
		return new
	elseif type(zone) == 'string' then
		zone = trigger.misc.getZone(zone)
		if zone then
			new.x = zone.point.x
			new.y = zone.point.y
			new.z = zone.point.z
			return new
		end
	end
end

-- gets heading-error corrected direction from point along vector vec.
function routines.utils.getDir(vec, point)
	local dir = math.atan2(vec.z, vec.x)
	dir = dir + routines.getNorthCorrection(point)
	if dir < 0 then
		dir = dir + 2*math.pi  -- put dir in range of 0 to 2*pi
	end
	return dir
end

-- gets distance in meters between two points (2 dimensional)
function routines.utils.get2DDist(point1, point2)
	point1 = routines.utils.makeVec3(point1)
	point2 = routines.utils.makeVec3(point2)
	return routines.vec.mag({x = point1.x - point2.x, y = 0, z = point1.z - point2.z})
end

-- gets distance in meters between two points (3 dimensional)
function routines.utils.get3DDist(point1, point2)
	return routines.vec.mag({x = point1.x - point2.x, y = point1.y - point2.y, z = point1.z - point2.z})
end





--3D Vector manipulation
routines.vec = {}

routines.vec.add = function(vec1, vec2)
	return {x = vec1.x + vec2.x, y = vec1.y + vec2.y, z = vec1.z + vec2.z}
end

routines.vec.sub = function(vec1, vec2)
	return {x = vec1.x - vec2.x, y = vec1.y - vec2.y, z = vec1.z - vec2.z}
end

routines.vec.scalarMult = function(vec, mult)
	return {x = vec.x*mult, y = vec.y*mult, z = vec.z*mult}
end

routines.vec.scalar_mult = routines.vec.scalarMult

routines.vec.dp = function(vec1, vec2)
	return vec1.x*vec2.x + vec1.y*vec2.y + vec1.z*vec2.z
end

routines.vec.cp = function(vec1, vec2)
	return { x = vec1.y*vec2.z - vec1.z*vec2.y, y = vec1.z*vec2.x - vec1.x*vec2.z, z = vec1.x*vec2.y - vec1.y*vec2.x}
end

routines.vec.mag = function(vec)
	return (vec.x^2 + vec.y^2 + vec.z^2)^0.5
end

routines.vec.getUnitVec = function(vec)
	local mag = routines.vec.mag(vec)
	return { x = vec.x/mag, y = vec.y/mag, z = vec.z/mag }
end

routines.vec.rotateVec2 = function(vec2, theta)
	return { x = vec2.x*math.cos(theta) - vec2.y*math.sin(theta), y = vec2.x*math.sin(theta) + vec2.y*math.cos(theta)}
end
---------------------------------------------------------------------------------------------------------------------------




-- acc- the accuracy of each easting/northing.  0, 1, 2, 3, 4, or 5.
routines.tostringMGRS = function(MGRS, acc)
	if acc == 0 then
		return MGRS.UTMZone .. ' ' .. MGRS.MGRSDigraph
	else
		return MGRS.UTMZone .. ' ' .. MGRS.MGRSDigraph .. ' ' .. string.format('%0' .. acc .. 'd', routines.utils.round(MGRS.Easting/(10^(5-acc)), 0))
		       .. ' ' .. string.format('%0' .. acc .. 'd', routines.utils.round(MGRS.Northing/(10^(5-acc)), 0))
	end
end

--[[acc:
in DM: decimal point of minutes.
In DMS: decimal point of seconds.
position after the decimal of the least significant digit:
So:
42.32 - acc of 2.
]]
routines.tostringLL = function(lat, lon, acc, DMS)

	local latHemi, lonHemi
	if lat > 0 then
		latHemi = 'N'
	else
		latHemi = 'S'
	end

	if lon > 0 then
		lonHemi = 'E'
	else
		lonHemi = 'W'
	end

	lat = math.abs(lat)
	lon = math.abs(lon)

	local latDeg = math.floor(lat)
	local latMin = (lat - latDeg)*60

	local lonDeg = math.floor(lon)
	local lonMin = (lon - lonDeg)*60

	if DMS then  -- degrees, minutes, and seconds.
		local oldLatMin = latMin
		latMin = math.floor(latMin)
		local latSec = routines.utils.round((oldLatMin - latMin)*60, acc)

		local oldLonMin = lonMin
		lonMin = math.floor(lonMin)
		local lonSec = routines.utils.round((oldLonMin - lonMin)*60, acc)

		if latSec == 60 then
			latSec = 0
			latMin = latMin + 1
		end

		if lonSec == 60 then
			lonSec = 0
			lonMin = lonMin + 1
		end

		local secFrmtStr -- create the formatting string for the seconds place
		if acc <= 0 then  -- no decimal place.
			secFrmtStr = '%02d'
		else
			local width = 3 + acc  -- 01.310 - that's a width of 6, for example.
			secFrmtStr = '%0' .. width .. '.' .. acc .. 'f'
		end

		return string.format('%02d', latDeg) .. ' ' .. string.format('%02d', latMin) .. '\' ' .. string.format(secFrmtStr, latSec) .. '"' .. latHemi .. '   '
		       .. string.format('%02d', lonDeg) .. ' ' .. string.format('%02d', lonMin) .. '\' ' .. string.format(secFrmtStr, lonSec) .. '"' .. lonHemi

	else  -- degrees, decimal minutes.
		latMin = routines.utils.round(latMin, acc)
		lonMin = routines.utils.round(lonMin, acc)

		if latMin == 60 then
			latMin = 0
			latDeg = latDeg + 1
		end

		if lonMin == 60 then
			lonMin = 0
			lonDeg = lonDeg + 1
		end

		local minFrmtStr -- create the formatting string for the minutes place
		if acc <= 0 then  -- no decimal place.
			minFrmtStr = '%02d'
		else
			local width = 3 + acc  -- 01.310 - that's a width of 6, for example.
			minFrmtStr = '%0' .. width .. '.' .. acc .. 'f'
		end

		return string.format('%02d', latDeg) .. ' ' .. string.format(minFrmtStr, latMin) .. '\'' .. latHemi .. '   '
	   .. string.format('%02d', lonDeg) .. ' ' .. string.format(minFrmtStr, lonMin) .. '\'' .. lonHemi

	end
end

--[[ required: az - radian
     required: dist - meters
	 optional: alt - meters (set to false or nil if you don't want to use it).
	 optional: metric - set true to get dist and alt in km and m.
	 precision will always be nearest degree and NM or km.]]
routines.tostringBR = function(az, dist, alt, metric)
	az = routines.utils.round(routines.utils.toDegree(az), 0)

	if metric then
		dist = routines.utils.round(dist/1000, 2)
	else
		dist = routines.utils.round(routines.utils.metersToNM(dist), 2)
	end

	local s = string.format('%03d', az) .. ' for ' .. dist

	if alt then
		if metric then
			s = s .. ' at ' .. routines.utils.round(alt, 0)
		else
			s = s .. ' at ' .. routines.utils.round(routines.utils.metersToFeet(alt), 0)
		end
	end
	return s
end

routines.getNorthCorrection = function(point)  --gets the correction needed for true north
	if not point.z then --Vec2; convert to Vec3
		point.z = point.y
		point.y = 0
	end
	local lat, lon = coord.LOtoLL(point)
	local north_posit = coord.LLtoLO(lat + 1, lon)
	return math.atan2(north_posit.z - point.z, north_posit.x - point.x)
end


do
	local idNum = 0

	--Simplified event handler
	routines.addEventHandler = function(f) --id is optional!
		local handler = {}
		idNum = idNum + 1
		handler.id = idNum
		handler.f = f
		handler.onEvent = function(self, event)
			self.f(event)
		end
		world.addEventHandler(handler)
	end

	routines.removeEventHandler = function(id)
		for key, handler in pairs(world.eventHandlers) do
			if handler.id and handler.id == id then
				world.eventHandlers[key] = nil
				return true
			end
		end
		return false
	end
end

-- need to return a Vec3 or Vec2?
function routines.getRandPointInCircle(point, radius, innerRadius)
	local theta = 2*math.pi*math.random()
	local rad = math.random() + math.random()
	if rad > 1 then
		rad = 2 - rad
	end

	local radMult
	if innerRadius and innerRadius <= radius then
		radMult = (radius - innerRadius)*rad + innerRadius
	else
		radMult = radius*rad
	end

	if not point.z then --might as well work with vec2/3
		point.z = point.y
	end

	local rndCoord
	if radius > 0 then
		rndCoord = {x = math.cos(theta)*radMult + point.x, y = math.sin(theta)*radMult + point.z}
	else
		rndCoord = {x = point.x, y = point.z}
	end
	return rndCoord
end

routines.goRoute = function(group, path)
	local misTask = {
		id = 'Mission',
		params = {
			route = {
				points = routines.utils.deepCopy(path),
			},
		},
	}
	if type(group) == 'string' then
		group = Group.getByName(group)
	end
	local groupCon = group:getController()
	if groupCon then
		groupCon:setTask(misTask)
		return true
	end

	Controller.setTask(groupCon, misTask)
	return false
end


-- Useful atomic functions from mist, ported.

routines.ground = {}
routines.fixedWing = {}
routines.heli = {}

routines.ground.buildWP = function(point, overRideForm, overRideSpeed)

	local wp = {}
	wp.x = point.x

	if point.z then
		wp.y = point.z
	else
		wp.y = point.y
	end
	local form, speed

	if point.speed and not overRideSpeed then
		wp.speed = point.speed
	elseif type(overRideSpeed) == 'number' then
		wp.speed = overRideSpeed
	else
		wp.speed = routines.utils.kmphToMps(20)
	end

	if point.form and not overRideForm then
		form = point.form
	else
		form = overRideForm
	end

	if not form then
		wp.action = 'Cone'
	else
		form = string.lower(form)
		if form == 'off_road' or form == 'off road' then
			wp.action = 'Off Road'
		elseif form == 'on_road' or form == 'on road' then
			wp.action = 'On Road'
		elseif form == 'rank' or form == 'line_abrest' or form == 'line abrest' or form == 'lineabrest'then
			wp.action = 'Rank'
		elseif form == 'cone' then
			wp.action = 'Cone'
		elseif form == 'diamond' then
			wp.action = 'Diamond'
		elseif form == 'vee' then
			wp.action = 'Vee'
		elseif form == 'echelon_left' or form == 'echelon left' or form == 'echelonl' then
			wp.action = 'EchelonL'
		elseif form == 'echelon_right' or form == 'echelon right' or form == 'echelonr' then
			wp.action = 'EchelonR'
		else
			wp.action = 'Cone' -- if nothing matched
		end
	end

	wp.type = 'Turning Point'

	return wp

end

routines.fixedWing.buildWP = function(point, WPtype, speed, alt, altType)

	local wp = {}
	wp.x = point.x

	if point.z then
		wp.y = point.z
	else
		wp.y = point.y
	end

	if alt and type(alt) == 'number' then
		wp.alt = alt
	else
		wp.alt = 2000
	end

	if altType then
		altType = string.lower(altType)
		if altType == 'radio' or 'agl' then
			wp.alt_type = 'RADIO'
		elseif altType == 'baro' or 'asl' then
			wp.alt_type = 'BARO'
		end
	else
		wp.alt_type = 'RADIO'
	end

	if point.speed then
		speed = point.speed
	end

	if point.type then
		WPtype = point.type
	end

	if not speed then
		wp.speed = routines.utils.kmphToMps(500)
	else
		wp.speed = speed
	end

	if not WPtype then
		wp.action =  'Turning Point'
	else
		WPtype = string.lower(WPtype)
		if WPtype == 'flyover' or WPtype == 'fly over' or WPtype == 'fly_over' then
			wp.action =  'Fly Over Point'
		elseif WPtype == 'turningpoint' or WPtype == 'turning point' or WPtype == 'turning_point' then
			wp.action =  'Turning Point'
		else
			wp.action = 'Turning Point'
		end
	end

	wp.type = 'Turning Point'
	return wp
end

routines.heli.buildWP = function(point, WPtype, speed, alt, altType)

	local wp = {}
	wp.x = point.x

	if point.z then
		wp.y = point.z
	else
		wp.y = point.y
	end

	if alt and type(alt) == 'number' then
		wp.alt = alt
	else
		wp.alt = 500
	end

	if altType then
		altType = string.lower(altType)
		if altType == 'radio' or 'agl' then
			wp.alt_type = 'RADIO'
		elseif altType == 'baro' or 'asl' then
			wp.alt_type = 'BARO'
		end
	else
		wp.alt_type = 'RADIO'
	end

	if point.speed then
		speed = point.speed
	end

	if point.type then
		WPtype = point.type
	end

	if not speed then
		wp.speed = routines.utils.kmphToMps(200)
	else
		wp.speed = speed
	end

	if not WPtype then
		wp.action =  'Turning Point'
	else
		WPtype = string.lower(WPtype)
		if WPtype == 'flyover' or WPtype == 'fly over' or WPtype == 'fly_over' then
			wp.action =  'Fly Over Point'
		elseif WPtype == 'turningpoint' or WPtype == 'turning point' or WPtype == 'turning_point' then
			wp.action = 'Turning Point'
		else
			wp.action =  'Turning Point'
		end
	end

	wp.type = 'Turning Point'
	return wp
end

routines.groupToRandomPoint = function(vars)
	local group = vars.group --Required
	local point = vars.point --required
	local radius = vars.radius or 0
	local innerRadius = vars.innerRadius
	local form = vars.form or 'Cone'
	local heading = vars.heading or math.random()*2*math.pi
	local headingDegrees = vars.headingDegrees
	local speed = vars.speed or routines.utils.kmphToMps(20)


	local useRoads
	if not vars.disableRoads then
		useRoads = true
	else
		useRoads = false
	end

	local path = {}

	if headingDegrees then
		heading = headingDegrees*math.pi/180
	end

	if heading >= 2*math.pi then
		heading = heading - 2*math.pi
	end

	local rndCoord = routines.getRandPointInCircle(point, radius, innerRadius)

	local offset = {}
	local posStart = routines.getLeadPos(group)

	offset.x = routines.utils.round(math.sin(heading - (math.pi/2)) * 50 + rndCoord.x, 3)
	offset.z = routines.utils.round(math.cos(heading + (math.pi/2)) * 50 + rndCoord.y, 3)
	path[#path + 1] = routines.ground.buildWP(posStart, form, speed)


	if useRoads == true and ((point.x - posStart.x)^2 + (point.z - posStart.z)^2)^0.5 > radius * 1.3 then
		path[#path + 1] = routines.ground.buildWP({['x'] = posStart.x + 11, ['z'] = posStart.z + 11}, 'off_road', speed)
		path[#path + 1] = routines.ground.buildWP(posStart, 'on_road', speed)
		path[#path + 1] = routines.ground.buildWP(offset, 'on_road', speed)
	else
		path[#path + 1] = routines.ground.buildWP({['x'] = posStart.x + 25, ['z'] = posStart.z + 25}, form, speed)
	end

	path[#path + 1] = routines.ground.buildWP(offset, form, speed)
	path[#path + 1] = routines.ground.buildWP(rndCoord, form, speed)

	routines.goRoute(group, path)

	return
end

routines.groupRandomDistSelf = function(gpData, dist, form, heading, speed)
	local pos = routines.getLeadPos(gpData)
	local fakeZone = {}
	fakeZone.radius = dist or math.random(300, 1000)
	fakeZone.point = {x = pos.x, y, pos.y, z = pos.z}
	routines.groupToRandomZone(gpData, fakeZone, form, heading, speed)

	return
end

routines.groupToRandomZone = function(gpData, zone, form, heading, speed)
	if type(gpData) == 'string' then
		gpData = Group.getByName(gpData)
	end

	if type(zone) == 'string' then
		zone = trigger.misc.getZone(zone)
	elseif type(zone) == 'table' and not zone.radius then
		zone = trigger.misc.getZone(zone[math.random(1, #zone)])
	end

	if speed then
		speed = routines.utils.kmphToMps(speed)
	end

	local vars = {}
	vars.group = gpData
	vars.radius = zone.radius
	vars.form = form
	vars.headingDegrees = heading
	vars.speed = speed
	vars.point = routines.utils.zoneToVec3(zone)

	routines.groupToRandomPoint(vars)

	return
end

routines.isTerrainValid = function(coord, terrainTypes) -- vec2/3 and enum or table of acceptable terrain types
	if coord.z then
		coord.y = coord.z
	end
	local typeConverted = {}

	if type(terrainTypes) == 'string' then -- if its a string it does this check
		for constId, constData in pairs(land.SurfaceType) do
			if string.lower(constId) == string.lower(terrainTypes) or string.lower(constData) == string.lower(terrainTypes) then
				table.insert(typeConverted, constId)
			end
		end
	elseif type(terrainTypes) == 'table' then -- if its a table it does this check
		for typeId, typeData in pairs(terrainTypes) do
			for constId, constData in pairs(land.SurfaceType) do
				if string.lower(constId) == string.lower(typeData) or string.lower(constData) == string.lower(typeId) then
					table.insert(typeConverted, constId)
				end
			end
		end
	end
	for validIndex, validData in pairs(typeConverted) do
		if land.getSurfaceType(coord) == land.SurfaceType[validData] then
			return true
		end
	end
	return false
end

routines.groupToPoint = function(gpData, point, form, heading, speed, useRoads)
	if type(point) == 'string' then
		point = trigger.misc.getZone(point)
	end
	if speed then
		speed = routines.utils.kmphToMps(speed)
	end

	local vars = {}
	vars.group = gpData
	vars.form = form
	vars.headingDegrees = heading
	vars.speed = speed
	vars.disableRoads = useRoads
	vars.point = routines.utils.zoneToVec3(point)
	routines.groupToRandomPoint(vars)

	return
end


routines.getLeadPos = function(group)
	if type(group) == 'string' then -- group name
		group = Group.getByName(group)
	end

	local units = group:getUnits()

	local leader = units[1]
	if not leader then  -- SHOULD be good, but if there is a bug, this code future-proofs it then.
		local lowestInd = math.huge
		for ind, unit in pairs(units) do
			if ind < lowestInd then
				lowestInd = ind
				leader = unit
			end
		end
	end
	if leader and Unit.isExist(leader) then  -- maybe a little too paranoid now...
		return leader:getPosition().p
	end
end

--[[ vars for routines.getMGRSString:
vars.units - table of unit names (NOT unitNameTable- maybe this should change).
vars.acc - integer between 0 and 5, inclusive
]]
routines.getMGRSString = function(vars)
	local units = vars.units
	local acc = vars.acc or 5
	local avgPos = routines.getAvgPos(units)
	if avgPos then
		return routines.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(avgPos)), acc)
	end
end

--[[ vars for routines.getLLString
vars.units - table of unit names (NOT unitNameTable- maybe this should change).
vars.acc - integer, number of numbers after decimal place
vars.DMS - if true, output in degrees, minutes, seconds.  Otherwise, output in degrees, minutes.


]]
routines.getLLString = function(vars)
	local units = vars.units
	local acc = vars.acc or 3
	local DMS = vars.DMS
	local avgPos = routines.getAvgPos(units)
	if avgPos then
		local lat, lon = coord.LOtoLL(avgPos)
		return routines.tostringLL(lat, lon, acc, DMS)
	end
end

--[[
vars.zone - table of a zone name.
vars.ref -  vec3 ref point, maybe overload for vec2 as well?
vars.alt - boolean, if used, includes altitude in string
vars.metric - boolean, gives distance in km instead of NM.
]]
routines.getBRStringZone = function(vars)
	local zone = trigger.misc.getZone( vars.zone )
	local ref = routines.utils.makeVec3(vars.ref, 0)  -- turn it into Vec3 if it is not already.
	local alt = vars.alt
	local metric = vars.metric
	if zone then
		local vec = {x = zone.point.x - ref.x, y = zone.point.y - ref.y, z = zone.point.z - ref.z}
		local dir = routines.utils.getDir(vec, ref)
		local dist = routines.utils.get2DDist(zone.point, ref)
		if alt then
			alt = zone.y
		end
		return routines.tostringBR(dir, dist, alt, metric)
	else
		env.info( 'routines.getBRStringZone: error: zone is nil' )
	end
end

--[[
vars.units- table of unit names (NOT unitNameTable- maybe this should change).
vars.ref -  vec3 ref point, maybe overload for vec2 as well?
vars.alt - boolean, if used, includes altitude in string
vars.metric - boolean, gives distance in km instead of NM.
]]
routines.getBRString = function(vars)
	local units = vars.units
	local ref = routines.utils.makeVec3(vars.ref, 0)  -- turn it into Vec3 if it is not already.
	local alt = vars.alt
	local metric = vars.metric
	local avgPos = routines.getAvgPos(units)
	if avgPos then
		local vec = {x = avgPos.x - ref.x, y = avgPos.y - ref.y, z = avgPos.z - ref.z}
		local dir = routines.utils.getDir(vec, ref)
		local dist = routines.utils.get2DDist(avgPos, ref)
		if alt then
			alt = avgPos.y
		end
		return routines.tostringBR(dir, dist, alt, metric)
	end
end


-- Returns the Vec3 coordinates of the average position of the concentration of units most in the heading direction.
--[[ vars for routines.getLeadingPos:
vars.units - table of unit names
vars.heading - direction
vars.radius - number
vars.headingDegrees - boolean, switches heading to degrees
]]
routines.getLeadingPos = function(vars)
	local units = vars.units
	local heading = vars.heading
	local radius = vars.radius
	if vars.headingDegrees then
		heading = routines.utils.toRadian(vars.headingDegrees)
	end

	local unitPosTbl = {}
	for i = 1, #units do
		local unit = Unit.getByName(units[i])
		if unit and unit:isExist() then
			unitPosTbl[#unitPosTbl + 1] = unit:getPosition().p
		end
	end
	if #unitPosTbl > 0 then  -- one more more units found.
		-- first, find the unit most in the heading direction
		local maxPos = -math.huge

		local maxPosInd  -- maxPos - the furthest in direction defined by heading; maxPosInd =
		for i = 1, #unitPosTbl do
			local rotatedVec2 = routines.vec.rotateVec2(routines.utils.makeVec2(unitPosTbl[i]), heading)
			if (not maxPos) or maxPos < rotatedVec2.x then
				maxPos = rotatedVec2.x
				maxPosInd = i
			end
		end

		--now, get all the units around this unit...
		local avgPos
		if radius then
			local maxUnitPos = unitPosTbl[maxPosInd]
			local avgx, avgy, avgz, totNum = 0, 0, 0, 0
			for i = 1, #unitPosTbl do
				if routines.utils.get2DDist(maxUnitPos, unitPosTbl[i]) <= radius then
					avgx = avgx + unitPosTbl[i].x
					avgy = avgy + unitPosTbl[i].y
					avgz = avgz + unitPosTbl[i].z
					totNum = totNum + 1
				end
			end
			avgPos = { x = avgx/totNum, y = avgy/totNum, z = avgz/totNum}
		else
			avgPos = unitPosTbl[maxPosInd]
		end

		return avgPos
	end
end


--[[ vars for routines.getLeadingMGRSString:
vars.units - table of unit names
vars.heading - direction
vars.radius - number
vars.headingDegrees - boolean, switches heading to degrees
vars.acc - number, 0 to 5.
]]
routines.getLeadingMGRSString = function(vars)
	local pos = routines.getLeadingPos(vars)
	if pos then
		local acc = vars.acc or 5
		return routines.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(pos)), acc)
	end
end

--[[ vars for routines.getLeadingLLString:
vars.units - table of unit names
vars.heading - direction, number
vars.radius - number
vars.headingDegrees - boolean, switches heading to degrees
vars.acc - number of digits after decimal point (can be negative)
vars.DMS -  boolean, true if you want DMS.
]]
routines.getLeadingLLString = function(vars)
	local pos = routines.getLeadingPos(vars)
	if pos then
		local acc = vars.acc or 3
		local DMS = vars.DMS
		local lat, lon = coord.LOtoLL(pos)
		return routines.tostringLL(lat, lon, acc, DMS)
	end
end



--[[ vars for routines.getLeadingBRString:
vars.units - table of unit names
vars.heading - direction, number
vars.radius - number
vars.headingDegrees - boolean, switches heading to degrees
vars.metric - boolean, if true, use km instead of NM.
vars.alt - boolean, if true, include altitude.
vars.ref - vec3/vec2 reference point.
]]
routines.getLeadingBRString = function(vars)
	local pos = routines.getLeadingPos(vars)
	if pos then
		local ref = vars.ref
		local alt = vars.alt
		local metric = vars.metric

		local vec = {x = pos.x - ref.x, y = pos.y - ref.y, z = pos.z - ref.z}
		local dir = routines.utils.getDir(vec, ref)
		local dist = routines.utils.get2DDist(pos, ref)
		if alt then
			alt = pos.y
		end
		return routines.tostringBR(dir, dist, alt, metric)
	end
end

--[[ vars for routines.message.add
	vars.text = 'Hello World'
	vars.displayTime = 20
	vars.msgFor = {coa = {'red'}, countries = {'Ukraine', 'Georgia'}, unitTypes = {'A-10C'}}

]]

--[[ vars for routines.msgMGRS
vars.units - table of unit names (NOT unitNameTable- maybe this should change).
vars.acc - integer between 0 and 5, inclusive
vars.text - text in the message
vars.displayTime - self explanatory
vars.msgFor - scope
]]
routines.msgMGRS = function(vars)
	local units = vars.units
	local acc = vars.acc
	local text = vars.text
	local displayTime = vars.displayTime
	local msgFor = vars.msgFor

	local s = routines.getMGRSString{units = units, acc = acc}
	local newText
	if string.find(text, '%%s') then  -- look for %s
		newText = string.format(text, s)  -- insert the coordinates into the message
	else  -- else, just append to the end.
		newText = text .. s
	end

	routines.message.add{
		text = newText,
		displayTime = displayTime,
		msgFor = msgFor
	}
end

--[[ vars for routines.msgLL
vars.units - table of unit names (NOT unitNameTable- maybe this should change) (Yes).
vars.acc - integer, number of numbers after decimal place
vars.DMS - if true, output in degrees, minutes, seconds.  Otherwise, output in degrees, minutes.
vars.text - text in the message
vars.displayTime - self explanatory
vars.msgFor - scope
]]
routines.msgLL = function(vars)
	local units = vars.units  -- technically, I don't really need to do this, but it helps readability.
	local acc = vars.acc
	local DMS = vars.DMS
	local text = vars.text
	local displayTime = vars.displayTime
	local msgFor = vars.msgFor

	local s = routines.getLLString{units = units, acc = acc, DMS = DMS}
	local newText
	if string.find(text, '%%s') then  -- look for %s
		newText = string.format(text, s)  -- insert the coordinates into the message
	else  -- else, just append to the end.
		newText = text .. s
	end

	routines.message.add{
		text = newText,
		displayTime = displayTime,
		msgFor = msgFor
	}

end


--[[
vars.units- table of unit names (NOT unitNameTable- maybe this should change).
vars.ref -  vec3 ref point, maybe overload for vec2 as well?
vars.alt - boolean, if used, includes altitude in string
vars.metric - boolean, gives distance in km instead of NM.
vars.text - text of the message
vars.displayTime
vars.msgFor - scope
]]
routines.msgBR = function(vars)
	local units = vars.units  -- technically, I don't really need to do this, but it helps readability.
	local ref = vars.ref -- vec2/vec3 will be handled in routines.getBRString
	local alt = vars.alt
	local metric = vars.metric
	local text = vars.text
	local displayTime = vars.displayTime
	local msgFor = vars.msgFor

	local s = routines.getBRString{units = units, ref = ref, alt = alt, metric = metric}
	local newText
	if string.find(text, '%%s') then  -- look for %s
		newText = string.format(text, s)  -- insert the coordinates into the message
	else  -- else, just append to the end.
		newText = text .. s
	end

	routines.message.add{
		text = newText,
		displayTime = displayTime,
		msgFor = msgFor
	}

end


--------------------------------------------------------------------------------------------
-- basically, just sub-types of routines.msgBR... saves folks the work of getting the ref point.
--[[
vars.units- table of unit names (NOT unitNameTable- maybe this should change).
vars.ref -  string red, blue
vars.alt - boolean, if used, includes altitude in string
vars.metric - boolean, gives distance in km instead of NM.
vars.text - text of the message
vars.displayTime
vars.msgFor - scope
]]
routines.msgBullseye = function(vars)
	if string.lower(vars.ref) == 'red' then
		vars.ref = routines.DBs.missionData.bullseye.red
		routines.msgBR(vars)
	elseif string.lower(vars.ref) == 'blue' then
		vars.ref = routines.DBs.missionData.bullseye.blue
		routines.msgBR(vars)
	end
end

--[[
vars.units- table of unit names (NOT unitNameTable- maybe this should change).
vars.ref -  unit name of reference point
vars.alt - boolean, if used, includes altitude in string
vars.metric - boolean, gives distance in km instead of NM.
vars.text - text of the message
vars.displayTime
vars.msgFor - scope
]]

routines.msgBRA = function(vars)
	if Unit.getByName(vars.ref) then
		vars.ref = Unit.getByName(vars.ref):getPosition().p
		if not vars.alt then
			vars.alt = true
		end
		routines.msgBR(vars)
	end
end
--------------------------------------------------------------------------------------------

--[[ vars for routines.msgLeadingMGRS:
vars.units - table of unit names
vars.heading - direction
vars.radius - number
vars.headingDegrees - boolean, switches heading to degrees (optional)
vars.acc - number, 0 to 5.
vars.text - text of the message
vars.displayTime
vars.msgFor - scope
]]
routines.msgLeadingMGRS = function(vars)
	local units = vars.units  -- technically, I don't really need to do this, but it helps readability.
	local heading = vars.heading
	local radius = vars.radius
	local headingDegrees = vars.headingDegrees
	local acc = vars.acc
	local text = vars.text
	local displayTime = vars.displayTime
	local msgFor = vars.msgFor

	local s = routines.getLeadingMGRSString{units = units, heading = heading, radius = radius, headingDegrees = headingDegrees, acc = acc}
	local newText
	if string.find(text, '%%s') then  -- look for %s
		newText = string.format(text, s)  -- insert the coordinates into the message
	else  -- else, just append to the end.
		newText = text .. s
	end

	routines.message.add{
		text = newText,
		displayTime = displayTime,
		msgFor = msgFor
	}


end
--[[ vars for routines.msgLeadingLL:
vars.units - table of unit names
vars.heading - direction, number
vars.radius - number
vars.headingDegrees - boolean, switches heading to degrees (optional)
vars.acc - number of digits after decimal point (can be negative)
vars.DMS -  boolean, true if you want DMS. (optional)
vars.text - text of the message
vars.displayTime
vars.msgFor - scope
]]
routines.msgLeadingLL = function(vars)
	local units = vars.units  -- technically, I don't really need to do this, but it helps readability.
	local heading = vars.heading
	local radius = vars.radius
	local headingDegrees = vars.headingDegrees
	local acc = vars.acc
	local DMS = vars.DMS
	local text = vars.text
	local displayTime = vars.displayTime
	local msgFor = vars.msgFor

	local s = routines.getLeadingLLString{units = units, heading = heading, radius = radius, headingDegrees = headingDegrees, acc = acc, DMS = DMS}
	local newText
	if string.find(text, '%%s') then  -- look for %s
		newText = string.format(text, s)  -- insert the coordinates into the message
	else  -- else, just append to the end.
		newText = text .. s
	end

	routines.message.add{
		text = newText,
		displayTime = displayTime,
		msgFor = msgFor
	}

end

--[[
vars.units - table of unit names
vars.heading - direction, number
vars.radius - number
vars.headingDegrees - boolean, switches heading to degrees  (optional)
vars.metric - boolean, if true, use km instead of NM. (optional)
vars.alt - boolean, if true, include altitude. (optional)
vars.ref - vec3/vec2 reference point.
vars.text - text of the message
vars.displayTime
vars.msgFor - scope
]]
routines.msgLeadingBR = function(vars)
	local units = vars.units  -- technically, I don't really need to do this, but it helps readability.
	local heading = vars.heading
	local radius = vars.radius
	local headingDegrees = vars.headingDegrees
	local metric = vars.metric
	local alt = vars.alt
	local ref = vars.ref -- vec2/vec3 will be handled in routines.getBRString
	local text = vars.text
	local displayTime = vars.displayTime
	local msgFor = vars.msgFor

	local s = routines.getLeadingBRString{units = units, heading = heading, radius = radius, headingDegrees = headingDegrees, metric = metric, alt = alt, ref = ref}
	local newText
	if string.find(text, '%%s') then  -- look for %s
		newText = string.format(text, s)  -- insert the coordinates into the message
	else  -- else, just append to the end.
		newText = text .. s
	end

	routines.message.add{
		text = newText,
		displayTime = displayTime,
		msgFor = msgFor
	}
end


function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end


function routines.IsPartOfGroupInZones( CargoGroup, LandingZones )
--trace.f()

	local CurrentZoneID = nil

	if CargoGroup then
		local CargoUnits = CargoGroup:getUnits()
		for CargoUnitID, CargoUnit in pairs( CargoUnits ) do
			if CargoUnit and CargoUnit:getLife() >= 1.0 then
				CurrentZoneID = routines.IsUnitInZones( CargoUnit, LandingZones )
				if CurrentZoneID then
					break
				end
			end
		end
	end

--trace.r( "", "", { CurrentZoneID } )
	return CurrentZoneID
end



function routines.IsUnitInZones( TransportUnit, LandingZones )
--trace.f("", "routines.IsUnitInZones" )

    local TransportZoneResult = nil
	local TransportZonePos = nil
	local TransportZone = nil

    -- fill-up some local variables to support further calculations to determine location of units within the zone.
	if TransportUnit then
		local TransportUnitPos = TransportUnit:getPosition().p
		if type( LandingZones ) == "table" then
			for LandingZoneID, LandingZoneName in pairs( LandingZones ) do
				TransportZone = trigger.misc.getZone( LandingZoneName )
				if TransportZone then
					TransportZonePos = {radius = TransportZone.radius, x = TransportZone.point.x, y = TransportZone.point.y, z = TransportZone.point.z}
					if  ((( TransportUnitPos.x - TransportZonePos.x)^2 + (TransportUnitPos.z - TransportZonePos.z)^2)^0.5 <= TransportZonePos.radius) then
						TransportZoneResult = LandingZoneID
						break
					end
				end
			end
		else
			TransportZone = trigger.misc.getZone( LandingZones )
			TransportZonePos = {radius = TransportZone.radius, x = TransportZone.point.x, y = TransportZone.point.y, z = TransportZone.point.z}
			if  ((( TransportUnitPos.x - TransportZonePos.x)^2 + (TransportUnitPos.z - TransportZonePos.z)^2)^0.5 <= TransportZonePos.radius) then
				TransportZoneResult = 1
			end
		end
		if TransportZoneResult then
			--trace.i( "routines", "TransportZone:" .. TransportZoneResult )
		else
			--trace.i( "routines", "TransportZone:nil logic" )
		end
		return TransportZoneResult
	else
		--trace.i( "routines", "TransportZone:nil hard" )
		return nil
	end
end

function routines.IsUnitNearZonesRadius( TransportUnit, LandingZones, ZoneRadius )
--trace.f("", "routines.IsUnitInZones" )

  local TransportZoneResult = nil
  local TransportZonePos = nil
  local TransportZone = nil

    -- fill-up some local variables to support further calculations to determine location of units within the zone.
  if TransportUnit then
    local TransportUnitPos = TransportUnit:getPosition().p
    if type( LandingZones ) == "table" then
      for LandingZoneID, LandingZoneName in pairs( LandingZones ) do
        TransportZone = trigger.misc.getZone( LandingZoneName )
        if TransportZone then
          TransportZonePos = {radius = TransportZone.radius, x = TransportZone.point.x, y = TransportZone.point.y, z = TransportZone.point.z}
          if  ((( TransportUnitPos.x - TransportZonePos.x)^2 + (TransportUnitPos.z - TransportZonePos.z)^2)^0.5 <= ZoneRadius ) then
            TransportZoneResult = LandingZoneID
            break
          end
        end
      end
    else
      TransportZone = trigger.misc.getZone( LandingZones )
      TransportZonePos = {radius = TransportZone.radius, x = TransportZone.point.x, y = TransportZone.point.y, z = TransportZone.point.z}
      if  ((( TransportUnitPos.x - TransportZonePos.x)^2 + (TransportUnitPos.z - TransportZonePos.z)^2)^0.5 <= ZoneRadius ) then
        TransportZoneResult = 1
      end
    end
    if TransportZoneResult then
      --trace.i( "routines", "TransportZone:" .. TransportZoneResult )
    else
      --trace.i( "routines", "TransportZone:nil logic" )
    end
    return TransportZoneResult
  else
    --trace.i( "routines", "TransportZone:nil hard" )
    return nil
  end
end


function routines.IsStaticInZones( TransportStatic, LandingZones )
--trace.f()

    local TransportZoneResult = nil
	local TransportZonePos = nil
	local TransportZone = nil

    -- fill-up some local variables to support further calculations to determine location of units within the zone.
    local TransportStaticPos = TransportStatic:getPosition().p
	if type( LandingZones ) == "table" then
		for LandingZoneID, LandingZoneName in pairs( LandingZones ) do
			TransportZone = trigger.misc.getZone( LandingZoneName )
			if TransportZone then
				TransportZonePos = {radius = TransportZone.radius, x = TransportZone.point.x, y = TransportZone.point.y, z = TransportZone.point.z}
				if  ((( TransportStaticPos.x - TransportZonePos.x)^2 + (TransportStaticPos.z - TransportZonePos.z)^2)^0.5 <= TransportZonePos.radius) then
					TransportZoneResult = LandingZoneID
					break
				end
			end
		end
	else
		TransportZone = trigger.misc.getZone( LandingZones )
		TransportZonePos = {radius = TransportZone.radius, x = TransportZone.point.x, y = TransportZone.point.y, z = TransportZone.point.z}
		if  ((( TransportStaticPos.x - TransportZonePos.x)^2 + (TransportStaticPos.z - TransportZonePos.z)^2)^0.5 <= TransportZonePos.radius) then
			TransportZoneResult = 1
		end
	end

--trace.r( "", "", { TransportZoneResult } )
    return TransportZoneResult
end


function routines.IsUnitInRadius( CargoUnit, ReferencePosition, Radius )
--trace.f()

  local Valid = true

  -- fill-up some local variables to support further calculations to determine location of units within the zone.
  local CargoPos = CargoUnit:getPosition().p
  local ReferenceP = ReferencePosition.p

  if  (((CargoPos.x - ReferenceP.x)^2 + (CargoPos.z - ReferenceP.z)^2)^0.5 <= Radius) then
  else
    Valid = false
  end

  return Valid
end

function routines.IsPartOfGroupInRadius( CargoGroup, ReferencePosition, Radius )
--trace.f()

  local Valid = true

  Valid = routines.ValidateGroup( CargoGroup, "CargoGroup", Valid )

  -- fill-up some local variables to support further calculations to determine location of units within the zone
  local CargoUnits = CargoGroup:getUnits()
  for CargoUnitId, CargoUnit in pairs( CargoUnits ) do
    local CargoUnitPos = CargoUnit:getPosition().p
--    env.info( 'routines.IsPartOfGroupInRadius: CargoUnitPos.x = ' .. CargoUnitPos.x .. ' CargoUnitPos.z = ' .. CargoUnitPos.z )
    local ReferenceP = ReferencePosition.p
--    env.info( 'routines.IsPartOfGroupInRadius: ReferenceGroupPos.x = ' .. ReferenceGroupPos.x .. ' ReferenceGroupPos.z = ' .. ReferenceGroupPos.z )

    if  ((( CargoUnitPos.x - ReferenceP.x)^2 + (CargoUnitPos.z - ReferenceP.z)^2)^0.5 <= Radius) then
    else
      Valid = false
      break
    end
  end

  return Valid
end


function routines.ValidateString( Variable, VariableName, Valid )
--trace.f()

  if  type( Variable ) == "string" then
    if Variable == "" then
      error( "routines.ValidateString: error: " .. VariableName .. " must be filled out!" )
      Valid = false
    end
  else
    error( "routines.ValidateString: error: " .. VariableName .. " is not a string." )
    Valid = false
  end

--trace.r( "", "", { Valid } )
  return Valid
end

function routines.ValidateNumber( Variable, VariableName, Valid )
--trace.f()

  if  type( Variable ) == "number" then
  else
    error( "routines.ValidateNumber: error: " .. VariableName .. " is not a number." )
    Valid = false
  end

--trace.r( "", "", { Valid } )
  return Valid

end

function routines.ValidateGroup( Variable, VariableName, Valid )
--trace.f()

	if Variable == nil then
		error( "routines.ValidateGroup: error: " .. VariableName .. " is a nil value!" )
		Valid = false
	end

--trace.r( "", "", { Valid } )
	return Valid
end

function routines.ValidateZone( LandingZones, VariableName, Valid )
--trace.f()

	if LandingZones == nil then
		error( "routines.ValidateGroup: error: " .. VariableName .. " is a nil value!" )
		Valid = false
	end

	if type( LandingZones ) == "table" then
		for LandingZoneID, LandingZoneName in pairs( LandingZones ) do
			if trigger.misc.getZone( LandingZoneName ) == nil then
				error( "routines.ValidateGroup: error: Zone " .. LandingZoneName .. " does not exist!" )
				Valid = false
				break
			end
		end
	else
		if trigger.misc.getZone( LandingZones ) == nil then
			error( "routines.ValidateGroup: error: Zone " .. LandingZones .. " does not exist!" )
			Valid = false
		end
	end

--trace.r( "", "", { Valid } )
	return Valid
end

function routines.ValidateEnumeration( Variable, VariableName, Enum, Valid )
--trace.f()

  local ValidVariable = false

  for EnumId, EnumData in pairs( Enum ) do
    if Variable == EnumData then
      ValidVariable = true
      break
    end
  end

  if  ValidVariable then
  else
    error( 'TransportValidateEnum: " .. VariableName .. " is not a valid type.' .. Variable )
    Valid = false
  end

--trace.r( "", "", { Valid } )
  return Valid
end

function routines.getGroupRoute(groupIdent, task)   -- same as getGroupPoints but returns speed and formation type along with vec2 of point}
		-- refactor to search by groupId and allow groupId and groupName as inputs
	local gpId = groupIdent
	if type(groupIdent) == 'string' and not tonumber(groupIdent) then
		gpId = _DATABASE.Templates.Groups[groupIdent].groupId
	end
	
	for coa_name, coa_data in pairs(env.mission.coalition) do
		if (coa_name == 'red' or coa_name == 'blue') and type(coa_data) == 'table' then			
			if coa_data.country then --there is a country table
				for cntry_id, cntry_data in pairs(coa_data.country) do
					for obj_type_name, obj_type_data in pairs(cntry_data) do
						if obj_type_name == "helicopter" or obj_type_name == "ship" or obj_type_name == "plane" or obj_type_name == "vehicle" then	-- only these types have points						
							if ((type(obj_type_data) == 'table') and obj_type_data.group and (type(obj_type_data.group) == 'table') and (#obj_type_data.group > 0)) then  --there's a group!				
								for group_num, group_data in pairs(obj_type_data.group) do		
									if group_data and group_data.groupId == gpId  then -- this is the group we are looking for
										if group_data.route and group_data.route.points and #group_data.route.points > 0 then
											local points = {}
											
											for point_num, point in pairs(group_data.route.points) do
												local routeData = {}
												if not point.point then
													routeData.x = point.x
													routeData.y = point.y
												else
													routeData.point = point.point  --it's possible that the ME could move to the point = Vec2 notation.
												end
												routeData.form = point.action
												routeData.speed = point.speed
												routeData.alt = point.alt
												routeData.alt_type = point.alt_type
												routeData.airdromeId = point.airdromeId
												routeData.helipadId = point.helipadId
												routeData.type = point.type
												routeData.action = point.action
												if task then
													routeData.task = point.task
												end
												points[point_num] = routeData
											end
											
											return points
										end
										return
									end  --if group_data and group_data.name and group_data.name == 'groupname'
								end --for group_num, group_data in pairs(obj_type_data.group) do		
							end --if ((type(obj_type_data) == 'table') and obj_type_data.group and (type(obj_type_data.group) == 'table') and (#obj_type_data.group > 0)) then	
						end --if obj_type_name == "helicopter" or obj_type_name == "ship" or obj_type_name == "plane" or obj_type_name == "vehicle" or obj_type_name == "static" then
					end --for obj_type_name, obj_type_data in pairs(cntry_data) do
				end --for cntry_id, cntry_data in pairs(coa_data.country) do
			end --if coa_data.country then --there is a country table
		end --if coa_name == 'red' or coa_name == 'blue' and type(coa_data) == 'table' then	
	end --for coa_name, coa_data in pairs(mission.coalition) do
end

routines.ground.patrolRoute = function(vars)
	
	
	local tempRoute = {}
	local useRoute = {}
	local gpData = vars.gpData
	if type(gpData) == 'string' then
		gpData = Group.getByName(gpData)
	end
	
	local useGroupRoute 
	if not vars.useGroupRoute then
		useGroupRoute = vars.gpData
	else
		useGroupRoute = vars.useGroupRoute
	end
	local routeProvided = false
	if not vars.route then
		if useGroupRoute then
			tempRoute = routines.getGroupRoute(useGroupRoute)
		end
	else
		useRoute = vars.route
		local posStart = routines.getLeadPos(gpData)
		useRoute[1] = routines.ground.buildWP(posStart, useRoute[1].action, useRoute[1].speed)
		routeProvided = true
	end
	
	
	local overRideSpeed = vars.speed or 'default'
	local pType = vars.pType 
	local offRoadForm = vars.offRoadForm or 'default'
	local onRoadForm = vars.onRoadForm or 'default'
		
	if routeProvided == false and #tempRoute > 0 then
		local posStart = routines.getLeadPos(gpData)
		
		
		useRoute[#useRoute + 1] = routines.ground.buildWP(posStart, offRoadForm, overRideSpeed)
		for i = 1, #tempRoute do
			local tempForm = tempRoute[i].action
			local tempSpeed = tempRoute[i].speed
			
			if offRoadForm == 'default' then
				tempForm = tempRoute[i].action
			end
			if onRoadForm == 'default' then
				onRoadForm = 'On Road'
			end
			if (string.lower(tempRoute[i].action) == 'on road' or  string.lower(tempRoute[i].action) == 'onroad' or string.lower(tempRoute[i].action) == 'on_road') then
				tempForm = onRoadForm
			else
				tempForm = offRoadForm
			end
			
			if type(overRideSpeed) == 'number' then
				tempSpeed = overRideSpeed
			end
			
			
			useRoute[#useRoute + 1] = routines.ground.buildWP(tempRoute[i], tempForm, tempSpeed)
		end
			
		if pType and string.lower(pType) == 'doubleback' then
			local curRoute = routines.utils.deepCopy(useRoute)
			for i = #curRoute, 2, -1 do
				useRoute[#useRoute + 1] = routines.ground.buildWP(curRoute[i], curRoute[i].action, curRoute[i].speed)
			end
		end
		
		useRoute[1].action = useRoute[#useRoute].action -- make it so the first WP matches the last WP
	end
	
	local cTask3 = {}
	local newPatrol = {}
	newPatrol.route = useRoute
	newPatrol.gpData = gpData:getName()
	cTask3[#cTask3 + 1] = 'routines.ground.patrolRoute('
	cTask3[#cTask3 + 1] = routines.utils.oneLineSerialize(newPatrol)
	cTask3[#cTask3 + 1] = ')'
	cTask3 = table.concat(cTask3)
	local tempTask = {
		id = 'WrappedAction', 
		params = { 
			action = {
				id = 'Script',
				params = {
					command = cTask3, 
					
				},
			},
		},
	}

		
	useRoute[#useRoute].task = tempTask
	routines.goRoute(gpData, useRoute)
	
	return
end

routines.ground.patrol = function(gpData, pType, form, speed)
	local vars = {}
	
	if type(gpData) == 'table' and gpData:getName() then
		gpData = gpData:getName()
	end
	
	vars.useGroupRoute = gpData
	vars.gpData = gpData
	vars.pType = pType
	vars.offRoadForm = form
	vars.speed = speed
	
	routines.ground.patrolRoute(vars)

	return
end

function routines.GetUnitHeight( CheckUnit )
--trace.f( "routines" )

	local UnitPoint = CheckUnit:getPoint()
	local UnitPosition = { x = UnitPoint.x, y = UnitPoint.z }
	local UnitHeight = UnitPoint.y

	local LandHeight = land.getHeight( UnitPosition )

	--env.info(( 'CarrierHeight: LandHeight = ' .. LandHeight .. ' CarrierHeight = ' .. CarrierHeight ))

	--trace.f( "routines", "Unit Height = " .. UnitHeight - LandHeight )
	
	return UnitHeight - LandHeight

end



Su34Status = { status = {} }
boardMsgRed = { statusMsg = "" }
boardMsgAll = { timeMsg = "" }
SpawnSettings = {}
Su34MenuPath = {}
Su34Menus = 0


function Su34AttackCarlVinson(groupName)
--trace.menu("", "Su34AttackCarlVinson")
	local groupSu34 = Group.getByName( groupName )
	local controllerSu34 = groupSu34.getController(groupSu34)
	local groupCarlVinson = Group.getByName("US Carl Vinson #001")
	controllerSu34.setOption( controllerSu34, AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.OPEN_FIRE )
	controllerSu34.setOption( controllerSu34, AI.Option.Air.id.REACTION_ON_THREAT, AI.Option.Air.val.REACTION_ON_THREAT.EVADE_FIRE )
	if groupCarlVinson ~= nil then
		controllerSu34.pushTask(controllerSu34,{id = 'AttackGroup', params = { groupId = groupCarlVinson:getID(), expend = AI.Task.WeaponExpend.ALL, attackQtyLimit = true}})
	end
	Su34Status.status[groupName] = 1
	MessageToRed( string.format('%s: ',groupName) .. 'Attacking carrier Carl Vinson. ', 10, 'RedStatus' .. groupName )
end

function Su34AttackWest(groupName)
--trace.f("","Su34AttackWest")
	local groupSu34 = Group.getByName( groupName )
	local controllerSu34 = groupSu34.getController(groupSu34)
	local groupShipWest1 = Group.getByName("US Ship West #001")
	local groupShipWest2 = Group.getByName("US Ship West #002")
	controllerSu34.setOption( controllerSu34, AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.OPEN_FIRE )
	controllerSu34.setOption( controllerSu34, AI.Option.Air.id.REACTION_ON_THREAT, AI.Option.Air.val.REACTION_ON_THREAT.EVADE_FIRE )
	if groupShipWest1 ~= nil then
		controllerSu34.pushTask(controllerSu34,{id = 'AttackGroup', params = { groupId = groupShipWest1:getID(), expend = AI.Task.WeaponExpend.ALL, attackQtyLimit = true}})
	end
	if groupShipWest2 ~= nil then
		controllerSu34.pushTask(controllerSu34,{id = 'AttackGroup', params = { groupId = groupShipWest2:getID(), expend = AI.Task.WeaponExpend.ALL, attackQtyLimit = true}})
	end
	Su34Status.status[groupName] = 2
	MessageToRed( string.format('%s: ',groupName) .. 'Attacking invading ships in the west. ', 10, 'RedStatus' .. groupName )
end

function Su34AttackNorth(groupName)
--trace.menu("","Su34AttackNorth")
	local groupSu34 = Group.getByName( groupName )
	local controllerSu34 = groupSu34.getController(groupSu34)
	local groupShipNorth1 = Group.getByName("US Ship North #001")
	local groupShipNorth2 = Group.getByName("US Ship North #002")
	local groupShipNorth3 = Group.getByName("US Ship North #003")
	controllerSu34.setOption( controllerSu34, AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.OPEN_FIRE )
	controllerSu34.setOption( controllerSu34, AI.Option.Air.id.REACTION_ON_THREAT, AI.Option.Air.val.REACTION_ON_THREAT.EVADE_FIRE )
	if groupShipNorth1 ~= nil then
		controllerSu34.pushTask(controllerSu34,{id = 'AttackGroup', params = { groupId = groupShipNorth1:getID(), expend = AI.Task.WeaponExpend.ALL, attackQtyLimit = false}})
	end
	if groupShipNorth2 ~= nil then
		controllerSu34.pushTask(controllerSu34,{id = 'AttackGroup', params = { groupId = groupShipNorth2:getID(), expend = AI.Task.WeaponExpend.ALL, attackQtyLimit = false}})
	end
	if groupShipNorth3 ~= nil then
		controllerSu34.pushTask(controllerSu34,{id = 'AttackGroup', params = { groupId = groupShipNorth3:getID(), expend = AI.Task.WeaponExpend.ALL, attackQtyLimit = false}})
	end
	Su34Status.status[groupName] = 3
	MessageToRed( string.format('%s: ',groupName) .. 'Attacking invading ships in the north. ', 10, 'RedStatus' .. groupName )
end

function Su34Orbit(groupName)
--trace.menu("","Su34Orbit")
	local groupSu34 = Group.getByName( groupName )
	local controllerSu34 = groupSu34:getController()
	controllerSu34.setOption( controllerSu34, AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_HOLD )
	controllerSu34.setOption( controllerSu34, AI.Option.Air.id.REACTION_ON_THREAT, AI.Option.Air.val.REACTION_ON_THREAT.EVADE_FIRE )
	controllerSu34:pushTask( {id = 'ControlledTask', params = { task = { id = 'Orbit', params = { pattern = AI.Task.OrbitPattern.RACE_TRACK } }, stopCondition = { duration = 600 } } } )
	Su34Status.status[groupName] = 4
	MessageToRed( string.format('%s: ',groupName) .. 'In orbit and awaiting further instructions. ', 10, 'RedStatus' .. groupName )
end

function Su34TakeOff(groupName)
--trace.menu("","Su34TakeOff")
	local groupSu34 = Group.getByName( groupName )
	local controllerSu34 = groupSu34:getController()
	controllerSu34.setOption( controllerSu34, AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_HOLD )
	controllerSu34.setOption( controllerSu34, AI.Option.Air.id.REACTION_ON_THREAT, AI.Option.Air.val.REACTION_ON_THREAT.BYPASS_AND_ESCAPE )
	Su34Status.status[groupName] = 8
	MessageToRed( string.format('%s: ',groupName) .. 'Take-Off. ', 10, 'RedStatus' .. groupName )
end

function Su34Hold(groupName)
--trace.menu("","Su34Hold")
	local groupSu34 = Group.getByName( groupName )
	local controllerSu34 = groupSu34:getController()
	controllerSu34.setOption( controllerSu34, AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_HOLD )
	controllerSu34.setOption( controllerSu34, AI.Option.Air.id.REACTION_ON_THREAT, AI.Option.Air.val.REACTION_ON_THREAT.BYPASS_AND_ESCAPE )
	Su34Status.status[groupName] = 5
	MessageToRed( string.format('%s: ',groupName) .. 'Holding Weapons. ', 10, 'RedStatus' .. groupName )
end

function Su34RTB(groupName)
--trace.menu("","Su34RTB")
	Su34Status.status[groupName] = 6
	MessageToRed( string.format('%s: ',groupName) .. 'Return to Krasnodar. ', 10, 'RedStatus' .. groupName )
end

function Su34Destroyed(groupName)
--trace.menu("","Su34Destroyed")
	Su34Status.status[groupName] = 7
	MessageToRed( string.format('%s: ',groupName) .. 'Destroyed. ', 30, 'RedStatus' .. groupName )
end

function GroupAlive( groupName )
--trace.menu("","GroupAlive")
	local groupTest = Group.getByName( groupName )

	local groupExists = false

	if groupTest then
		groupExists = groupTest:isExist()
	end

	--trace.r( "", "", { groupExists } )
	return groupExists
end

function Su34IsDead()
--trace.f()

end

function Su34OverviewStatus()
--trace.menu("","Su34OverviewStatus")
	local msg = ""
	local currentStatus = 0
	local Exists = false

	for groupName, currentStatus in pairs(Su34Status.status) do

		env.info(('Su34 Overview Status: GroupName = ' .. groupName ))
		Alive = GroupAlive( groupName )

		if Alive then
			if currentStatus == 1 then
				msg = msg .. string.format("%s: ",groupName)
				msg = msg .. "Attacking carrier Carl Vinson. "
			elseif currentStatus == 2 then
				msg = msg .. string.format("%s: ",groupName)
				msg = msg .. "Attacking supporting ships in the west. "
			elseif currentStatus == 3 then
				msg = msg .. string.format("%s: ",groupName)
				msg = msg .. "Attacking invading ships in the north. "
			elseif currentStatus == 4 then
				msg = msg .. string.format("%s: ",groupName)
				msg = msg .. "In orbit and awaiting further instructions. "
			elseif currentStatus == 5 then
				msg = msg .. string.format("%s: ",groupName)
				msg = msg .. "Holding Weapons. "
			elseif currentStatus == 6 then
				msg = msg .. string.format("%s: ",groupName)
				msg = msg .. "Return to Krasnodar. "
			elseif currentStatus == 7 then
				msg = msg .. string.format("%s: ",groupName)
				msg = msg .. "Destroyed. "
			elseif currentStatus == 8 then
				msg = msg .. string.format("%s: ",groupName)
				msg = msg .. "Take-Off. "
			end
		else
			if currentStatus == 7 then
				msg = msg .. string.format("%s: ",groupName)
				msg = msg .. "Destroyed. "
			else
				Su34Destroyed(groupName)
			end
		end
	end

	boardMsgRed.statusMsg = msg
end


function UpdateBoardMsg()
--trace.f()
	Su34OverviewStatus()
	MessageToRed( boardMsgRed.statusMsg, 15, 'RedStatus' )
end

function MusicReset( flg )
--trace.f()
	trigger.action.setUserFlag(95,flg)
end

function PlaneActivate(groupNameFormat, flg)
--trace.f()
	local groupName = groupNameFormat .. string.format("#%03d", trigger.misc.getUserFlag(flg))
	--trigger.action.outText(groupName,10)
	trigger.action.activateGroup(Group.getByName(groupName))
end

function Su34Menu(groupName)
--trace.f()

	--env.info(( 'Su34Menu(' .. groupName .. ')' ))
	local groupSu34 = Group.getByName( groupName )

	if Su34Status.status[groupName] == 1 or
	   Su34Status.status[groupName] == 2 or
	   Su34Status.status[groupName] == 3 or
	   Su34Status.status[groupName] == 4 or
	   Su34Status.status[groupName] == 5 then
		if Su34MenuPath[groupName] == nil then
			if planeMenuPath == nil then
				planeMenuPath = missionCommands.addSubMenuForCoalition(
					coalition.side.RED,
					"SU-34 anti-ship flights",
					nil
				)
			end
			Su34MenuPath[groupName] = missionCommands.addSubMenuForCoalition(
				coalition.side.RED,
				"Flight " .. groupName,
				planeMenuPath
			)

			missionCommands.addCommandForCoalition(
				coalition.side.RED,
				"Attack carrier Carl Vinson",
				Su34MenuPath[groupName],
				Su34AttackCarlVinson,
				groupName
			)

			missionCommands.addCommandForCoalition(
				coalition.side.RED,
				"Attack ships in the west",
				Su34MenuPath[groupName],
				Su34AttackWest,
				groupName
			)

			missionCommands.addCommandForCoalition(
				coalition.side.RED,
				"Attack ships in the north",
				Su34MenuPath[groupName],
				Su34AttackNorth,
				groupName
			)

			missionCommands.addCommandForCoalition(
				coalition.side.RED,
				"Hold position and await instructions",
				Su34MenuPath[groupName],
				Su34Orbit,
				groupName
			)

			missionCommands.addCommandForCoalition(
				coalition.side.RED,
				"Report status",
				Su34MenuPath[groupName],
				Su34OverviewStatus
			)
		end
	else
		if Su34MenuPath[groupName] then
			missionCommands.removeItemForCoalition(coalition.side.RED, Su34MenuPath[groupName])
		end
	end
end

--- Obsolete function, but kept to rework in framework.

function ChooseInfantry ( TeleportPrefixTable, TeleportMax )
--trace.f("Spawn")
	--env.info(( 'ChooseInfantry: ' ))

	TeleportPrefixTableCount = #TeleportPrefixTable
	TeleportPrefixTableIndex = math.random( 1, TeleportPrefixTableCount )

	--env.info(( 'ChooseInfantry: TeleportPrefixTableIndex = ' .. TeleportPrefixTableIndex .. ' TeleportPrefixTableCount = ' .. TeleportPrefixTableCount  .. ' TeleportMax = ' .. TeleportMax ))

	local TeleportFound = false
	local TeleportLoop = true
	local Index = TeleportPrefixTableIndex
	local TeleportPrefix = ''

	while TeleportLoop do
		TeleportPrefix = TeleportPrefixTable[Index]
		if SpawnSettings[TeleportPrefix] then
			if SpawnSettings[TeleportPrefix]['SpawnCount'] - 1 < TeleportMax then
				SpawnSettings[TeleportPrefix]['SpawnCount'] = SpawnSettings[TeleportPrefix]['SpawnCount'] + 1
				TeleportFound = true
			else
				TeleportFound = false
			end
		else
			SpawnSettings[TeleportPrefix] = {}
			SpawnSettings[TeleportPrefix]['SpawnCount'] = 0
			TeleportFound = true
		end
		if TeleportFound then
			TeleportLoop = false
		else
			if Index < TeleportPrefixTableCount then
				Index = Index + 1
			else
				TeleportLoop = false
			end
		end
		--env.info(( 'ChooseInfantry: Loop 1 - TeleportPrefix = ' .. TeleportPrefix .. ' Index = ' .. Index ))
	end

	if TeleportFound == false then
		TeleportLoop = true
		Index = 1
		while TeleportLoop do
			TeleportPrefix = TeleportPrefixTable[Index]
			if SpawnSettings[TeleportPrefix] then
				if SpawnSettings[TeleportPrefix]['SpawnCount'] - 1 < TeleportMax then
					SpawnSettings[TeleportPrefix]['SpawnCount'] = SpawnSettings[TeleportPrefix]['SpawnCount'] + 1
					TeleportFound = true
				else
					TeleportFound = false
				end
			else
				SpawnSettings[TeleportPrefix] = {}
				SpawnSettings[TeleportPrefix]['SpawnCount'] = 0
				TeleportFound = true
			end
			if TeleportFound then
				TeleportLoop = false
			else
				if Index < TeleportPrefixTableIndex then
					Index = Index + 1
				else
					TeleportLoop = false
				end
			end
		--env.info(( 'ChooseInfantry: Loop 2 - TeleportPrefix = ' .. TeleportPrefix .. ' Index = ' .. Index ))
		end
	end

	local TeleportGroupName = ''
	if TeleportFound == true then
		TeleportGroupName = TeleportPrefix .. string.format("#%03d", SpawnSettings[TeleportPrefix]['SpawnCount'] )
	else
		TeleportGroupName = ''
	end

	--env.info(('ChooseInfantry: TeleportGroupName = ' .. TeleportGroupName ))
	--env.info(('ChooseInfantry: return'))

	return TeleportGroupName
end

SpawnedInfantry = 0

function LandCarrier ( CarrierGroup, LandingZonePrefix )
--trace.f()
	--env.info(( 'LandCarrier: ' ))
	--env.info(( 'LandCarrier: CarrierGroup = ' .. CarrierGroup:getName() ))
	--env.info(( 'LandCarrier: LandingZone = ' .. LandingZonePrefix ))

	local controllerGroup = CarrierGroup:getController()

	local LandingZone = trigger.misc.getZone(LandingZonePrefix)
	local LandingZonePos = {}
	LandingZonePos.x = LandingZone.point.x + math.random(LandingZone.radius * -1, LandingZone.radius)
	LandingZonePos.y = LandingZone.point.z + math.random(LandingZone.radius * -1, LandingZone.radius)

	controllerGroup:pushTask( { id = 'Land', params = { point = LandingZonePos, durationFlag = true, duration = 10 } } )

	--env.info(( 'LandCarrier: end' ))
end

EscortCount = 0
function EscortCarrier ( CarrierGroup, EscortPrefix, EscortLastWayPoint, EscortEngagementDistanceMax, EscortTargetTypes )
--trace.f()
	--env.info(( 'EscortCarrier: ' ))
	--env.info(( 'EscortCarrier: CarrierGroup = ' .. CarrierGroup:getName() ))
	--env.info(( 'EscortCarrier: EscortPrefix = ' .. EscortPrefix ))

	local CarrierName = CarrierGroup:getName()

	local EscortMission = {}
	local CarrierMission = {}

	local EscortMission =  SpawnMissionGroup( EscortPrefix )
	local CarrierMission = SpawnMissionGroup( CarrierGroup:getName() )

	if EscortMission ~= nil and CarrierMission ~= nil then

		EscortCount = EscortCount + 1
		EscortMissionName = string.format( EscortPrefix .. '#Escort %s', CarrierName )
		EscortMission.name = EscortMissionName
		EscortMission.groupId = nil
		EscortMission.lateActivation = false
		EscortMission.taskSelected = false

		local EscortUnits = #EscortMission.units
		for u = 1, EscortUnits do
			EscortMission.units[u].name = string.format( EscortPrefix .. '#Escort %s %02d', CarrierName, u )
			EscortMission.units[u].unitId = nil
		end


		EscortMission.route.points[1].task =  { id = "ComboTask",
                                                params =
                                                {
                                                    tasks =
                                                    {
                                                        [1] =
                                                        {
                                                            enabled = true,
                                                            auto = false,
                                                            id = "Escort",
                                                            number = 1,
                                                            params =
                                                            {
                                                                lastWptIndexFlagChangedManually = false,
                                                                groupId = CarrierGroup:getID(),
                                                                lastWptIndex = nil,
                                                                lastWptIndexFlag = false,
																engagementDistMax = EscortEngagementDistanceMax,
																targetTypes = EscortTargetTypes,
                                                                pos =
                                                                {
                                                                    y = 20,
                                                                    x = 20,
                                                                    z = 0,
                                                                } -- end of ["pos"]
                                                            } -- end of ["params"]
                                                        } -- end of [1]
                                                    } -- end of ["tasks"]
                                                } -- end of ["params"]
                                            } -- end of ["task"]

		SpawnGroupAdd( EscortPrefix, EscortMission )

	end
end

function SendMessageToCarrier( CarrierGroup, CarrierMessage )
--trace.f()

	if CarrierGroup ~= nil then
		MessageToGroup( CarrierGroup, CarrierMessage, 30, 'Carrier/' .. CarrierGroup:getName() )
	end

end

function MessageToGroup( MsgGroup, MsgText, MsgTime, MsgName )
--trace.f()

	if type(MsgGroup) == 'string' then
		--env.info( 'MessageToGroup: Converted MsgGroup string "' .. MsgGroup .. '" into a Group structure.' )
		MsgGroup = Group.getByName( MsgGroup )
	end

	if MsgGroup ~= nil then
		local MsgTable = {}
		MsgTable.text = MsgText
		MsgTable.displayTime = MsgTime
		MsgTable.msgFor = { units = { MsgGroup:getUnits()[1]:getName() } }
		MsgTable.name = MsgName
		--routines.message.add( MsgTable )
		--env.info(('MessageToGroup: Message sent to ' .. MsgGroup:getUnits()[1]:getName() .. ' -> ' .. MsgText ))
	end
end

function MessageToUnit( UnitName, MsgText, MsgTime, MsgName )
--trace.f()

	if UnitName ~= nil then
		local MsgTable = {}
		MsgTable.text = MsgText
		MsgTable.displayTime = MsgTime
		MsgTable.msgFor = { units = { UnitName } }
		MsgTable.name = MsgName
		--routines.message.add( MsgTable )
	end
end

function MessageToAll( MsgText, MsgTime, MsgName )
--trace.f()

	MESSAGE:New( MsgText, MsgTime, "Message" ):ToCoalition( coalition.side.RED ):ToCoalition( coalition.side.BLUE )
end

function MessageToRed( MsgText, MsgTime, MsgName )
--trace.f()

	MESSAGE:New( MsgText, MsgTime, "To Red Coalition" ):ToCoalition( coalition.side.RED )
end

function MessageToBlue( MsgText, MsgTime, MsgName )
--trace.f()

	MESSAGE:New( MsgText, MsgTime, "To Blue Coalition" ):ToCoalition( coalition.side.RED )
end

function getCarrierHeight( CarrierGroup )
--trace.f()

	if CarrierGroup ~= nil then
		if table.getn(CarrierGroup:getUnits()) == 1 then
			local CarrierUnit = CarrierGroup:getUnits()[1]
			local CurrentPoint = CarrierUnit:getPoint()

			local CurrentPosition = { x = CurrentPoint.x, y = CurrentPoint.z }
			local CarrierHeight = CurrentPoint.y

			local LandHeight = land.getHeight( CurrentPosition )

			--env.info(( 'CarrierHeight: LandHeight = ' .. LandHeight .. ' CarrierHeight = ' .. CarrierHeight ))

			return CarrierHeight - LandHeight
		else
			return 999999
		end
	else
		return 999999
	end

end

function GetUnitHeight( CheckUnit )
--trace.f()

	local UnitPoint = CheckUnit:getPoint()
	local UnitPosition = { x = CurrentPoint.x, y = CurrentPoint.z }
	local UnitHeight = CurrentPoint.y

	local LandHeight = land.getHeight( CurrentPosition )

	--env.info(( 'CarrierHeight: LandHeight = ' .. LandHeight .. ' CarrierHeight = ' .. CarrierHeight ))

	return UnitHeight - LandHeight

end


_MusicTable = {}
_MusicTable.Files = {}
_MusicTable.Queue = {}
_MusicTable.FileCnt = 0


function MusicRegister( SndRef, SndFile, SndTime )
--trace.f()

	env.info(( 'MusicRegister: SndRef = ' .. SndRef ))
	env.info(( 'MusicRegister: SndFile = ' .. SndFile ))
	env.info(( 'MusicRegister: SndTime = ' .. SndTime ))


	_MusicTable.FileCnt = _MusicTable.FileCnt + 1

	_MusicTable.Files[_MusicTable.FileCnt] = {}
	_MusicTable.Files[_MusicTable.FileCnt].Ref = SndRef
	_MusicTable.Files[_MusicTable.FileCnt].File = SndFile
	_MusicTable.Files[_MusicTable.FileCnt].Time = SndTime

	if not _MusicTable.Function then
		_MusicTable.Function = routines.scheduleFunction( MusicScheduler, { }, timer.getTime() + 10, 10)
	end

end

function MusicToPlayer( SndRef, PlayerName, SndContinue )
--trace.f()

	--env.info(( 'MusicToPlayer: SndRef = ' .. SndRef  ))

	local PlayerUnits = AlivePlayerUnits()
	for PlayerUnitIdx, PlayerUnit in pairs(PlayerUnits) do
		local PlayerUnitName = PlayerUnit:getPlayerName()
		--env.info(( 'MusicToPlayer: PlayerUnitName = ' .. PlayerUnitName  ))
		if PlayerName == PlayerUnitName then
			PlayerGroup = PlayerUnit:getGroup()
			if PlayerGroup then
				--env.info(( 'MusicToPlayer: PlayerGroup = ' .. PlayerGroup:getName() ))
				MusicToGroup( SndRef, PlayerGroup, SndContinue )
			end
			break
		end
	end

	--env.info(( 'MusicToPlayer: end'  ))

end

function MusicToGroup( SndRef, SndGroup, SndContinue )
--trace.f()

	--env.info(( 'MusicToGroup: SndRef = ' .. SndRef  ))

	if SndGroup ~= nil then
		if _MusicTable and _MusicTable.FileCnt > 0 then
			if SndGroup:isExist() then
				if MusicCanStart(SndGroup:getUnit(1):getPlayerName()) then
					--env.info(( 'MusicToGroup: OK for Sound.'  ))
					local SndIdx = 0
					if SndRef == '' then
						--env.info(( 'MusicToGroup: SndRef as empty. Queueing at random.'  ))
						SndIdx = math.random( 1, _MusicTable.FileCnt )
					else
						for SndIdx = 1, _MusicTable.FileCnt do
							if _MusicTable.Files[SndIdx].Ref == SndRef then
								break
							end
						end
					end
					--env.info(( 'MusicToGroup: SndIdx =  ' .. SndIdx ))
					--env.info(( 'MusicToGroup: Queueing Music ' .. _MusicTable.Files[SndIdx].File .. ' for Group ' ..  SndGroup:getID() ))
					trigger.action.outSoundForGroup( SndGroup:getID(), _MusicTable.Files[SndIdx].File )
					MessageToGroup( SndGroup, 'Playing ' .. _MusicTable.Files[SndIdx].File, 15, 'Music-' .. SndGroup:getUnit(1):getPlayerName() )

					local SndQueueRef = SndGroup:getUnit(1):getPlayerName()
					if _MusicTable.Queue[SndQueueRef] == nil then
						_MusicTable.Queue[SndQueueRef] = {}
					end
					_MusicTable.Queue[SndQueueRef].Start = timer.getTime()
					_MusicTable.Queue[SndQueueRef].PlayerName = SndGroup:getUnit(1):getPlayerName()
					_MusicTable.Queue[SndQueueRef].Group = SndGroup
					_MusicTable.Queue[SndQueueRef].ID = SndGroup:getID()
					_MusicTable.Queue[SndQueueRef].Ref = SndIdx
					_MusicTable.Queue[SndQueueRef].Continue = SndContinue
					_MusicTable.Queue[SndQueueRef].Type = Group
				end
			end
		end
	end
end

function MusicCanStart(PlayerName)
--trace.f()

	--env.info(( 'MusicCanStart:' ))

	local MusicOut = false

	if _MusicTable['Queue'] ~= nil and _MusicTable.FileCnt > 0  then
		--env.info(( 'MusicCanStart: PlayerName = ' .. PlayerName ))
		local PlayerFound = false
		local MusicStart = 0
		local MusicTime = 0
		for SndQueueIdx, SndQueue in pairs( _MusicTable.Queue ) do
			if SndQueue.PlayerName == PlayerName then
				PlayerFound = true
				MusicStart = SndQueue.Start
				MusicTime = _MusicTable.Files[SndQueue.Ref].Time
				break
			end
		end
		if PlayerFound then
			--env.info(( 'MusicCanStart: MusicStart = ' .. MusicStart ))
			--env.info(( 'MusicCanStart: MusicTime = ' .. MusicTime ))
			--env.info(( 'MusicCanStart: timer.getTime() = ' .. timer.getTime() ))

			if MusicStart + MusicTime <= timer.getTime() then
				MusicOut = true
			end
		else
			MusicOut = true
		end
	end

	if MusicOut then
		--env.info(( 'MusicCanStart: true' ))
	else
		--env.info(( 'MusicCanStart: false' ))
	end

	return MusicOut
end

function MusicScheduler()
--trace.scheduled("", "MusicScheduler")

	--env.info(( 'MusicScheduler:' ))
	if _MusicTable['Queue'] ~= nil and _MusicTable.FileCnt > 0  then
		--env.info(( 'MusicScheduler: Walking Sound Queue.'))
		for SndQueueIdx, SndQueue in pairs( _MusicTable.Queue ) do
			if SndQueue.Continue then
				if MusicCanStart(SndQueue.PlayerName) then
					--env.info(('MusicScheduler: MusicToGroup'))
					MusicToPlayer( '', SndQueue.PlayerName, true )
				end
			end
		end
	end

end


env.info(( 'Init: Scripts Loaded v1.1' ))

--- This module contains derived utilities taken from the MIST framework, 
-- which are excellent tools to be reused in an OO environment!.
-- 
-- ### Authors: 
-- 
--   * Grimes : Design & Programming of the MIST framework.
--   
-- ### Contributions:
-- 
--   * FlightControl : Rework to OO framework 
-- 
-- @module Utils


--- @type SMOKECOLOR
-- @field Green
-- @field Red
-- @field White
-- @field Orange
-- @field Blue
 
SMOKECOLOR = trigger.smokeColor -- #SMOKECOLOR

--- @type FLARECOLOR
-- @field Green
-- @field Red
-- @field White
-- @field Yellow

FLARECOLOR = trigger.flareColor -- #FLARECOLOR

--- Utilities static class.
-- @type UTILS
UTILS = {
  _MarkID = 1
}

--- Function to infer instance of an object
--
-- ### Examples:
--
--    * UTILS.IsInstanceOf( 'some text', 'string' ) will return true
--    * UTILS.IsInstanceOf( some_function, 'function' ) will return true
--    * UTILS.IsInstanceOf( 10, 'number' ) will return true
--    * UTILS.IsInstanceOf( false, 'boolean' ) will return true
--    * UTILS.IsInstanceOf( nil, 'nil' ) will return true
--
--    * UTILS.IsInstanceOf( ZONE:New( 'some zone', ZONE ) will return true
--    * UTILS.IsInstanceOf( ZONE:New( 'some zone', 'ZONE' ) will return true
--    * UTILS.IsInstanceOf( ZONE:New( 'some zone', 'zone' ) will return true
--    * UTILS.IsInstanceOf( ZONE:New( 'some zone', 'BASE' ) will return true
--
--    * UTILS.IsInstanceOf( ZONE:New( 'some zone', 'GROUP' ) will return false
--
--
-- @param object is the object to be evaluated
-- @param className is the name of the class to evaluate (can be either a string or a Moose class)
-- @return #boolean
UTILS.IsInstanceOf = function( object, className )
  -- Is className NOT a string ?
  if not type( className ) == 'string' then
  
    -- Is className a Moose class ?
    if type( className ) == 'table' and className.IsInstanceOf ~= nil then
    
      -- Get the name of the Moose class as a string
      className = className.ClassName
      
    -- className is neither a string nor a Moose class, throw an error
    else
    
      -- I'm not sure if this should take advantage of MOOSE logging function, or throw an error for pcall
      local err_str = 'className parameter should be a string; parameter received: '..type( className )
      self:E( err_str )
      return false
      -- error( err_str )
      
    end
  end
  
  -- Is the object a Moose class instance ?
  if type( object ) == 'table' and object.IsInstanceOf ~= nil then
  
    -- Use the IsInstanceOf method of the BASE class
    return object:IsInstanceOf( className )
  else
  
    -- If the object is not an instance of a Moose class, evaluate against lua basic data types
    local basicDataTypes = { 'string', 'number', 'function', 'boolean', 'nil', 'table' }
    for _, basicDataType in ipairs( basicDataTypes ) do
      if className == basicDataType then
        return type( object ) == basicDataType
      end
    end
  end
  
  -- Check failed
  return false
end


--from http://lua-users.org/wiki/CopyTable
UTILS.DeepCopy = function(object)
  local lookup_table = {}
  local function _copy(object)
    if type(object) ~= "table" then
      return object
    elseif lookup_table[object] then
      return lookup_table[object]
    end
    local new_table = {}
    lookup_table[object] = new_table
    for index, value in pairs(object) do
      new_table[_copy(index)] = _copy(value)
    end
    return setmetatable(new_table, getmetatable(object))
  end
  local objectreturn = _copy(object)
  return objectreturn
end


-- porting in Slmod's serialize_slmod2
UTILS.OneLineSerialize = function( tbl )  -- serialization of a table all on a single line, no comments, made to replace old get_table_string function

  lookup_table = {}
  
  local function _Serialize( tbl )

    if type(tbl) == 'table' then --function only works for tables!
    
      if lookup_table[tbl] then
        return lookup_table[object]
      end

      local tbl_str = {}
      
      lookup_table[tbl] = tbl_str
      
      tbl_str[#tbl_str + 1] = '{'

      for ind,val in pairs(tbl) do -- serialize its fields
        local ind_str = {}
        if type(ind) == "number" then
          ind_str[#ind_str + 1] = '['
          ind_str[#ind_str + 1] = tostring(ind)
          ind_str[#ind_str + 1] = ']='
        else --must be a string
          ind_str[#ind_str + 1] = '['
          ind_str[#ind_str + 1] = routines.utils.basicSerialize(ind)
          ind_str[#ind_str + 1] = ']='
        end

        local val_str = {}
        if ((type(val) == 'number') or (type(val) == 'boolean')) then
          val_str[#val_str + 1] = tostring(val)
          val_str[#val_str + 1] = ','
          tbl_str[#tbl_str + 1] = table.concat(ind_str)
          tbl_str[#tbl_str + 1] = table.concat(val_str)
      elseif type(val) == 'string' then
          val_str[#val_str + 1] = routines.utils.basicSerialize(val)
          val_str[#val_str + 1] = ','
          tbl_str[#tbl_str + 1] = table.concat(ind_str)
          tbl_str[#tbl_str + 1] = table.concat(val_str)
        elseif type(val) == 'nil' then -- won't ever happen, right?
          val_str[#val_str + 1] = 'nil,'
          tbl_str[#tbl_str + 1] = table.concat(ind_str)
          tbl_str[#tbl_str + 1] = table.concat(val_str)
        elseif type(val) == 'table' then
          if ind == "__index" then
          --  tbl_str[#tbl_str + 1] = "__index"
          --  tbl_str[#tbl_str + 1] = ','   --I think this is right, I just added it
          else

            val_str[#val_str + 1] = _Serialize(val)
            val_str[#val_str + 1] = ','   --I think this is right, I just added it
            tbl_str[#tbl_str + 1] = table.concat(ind_str)
            tbl_str[#tbl_str + 1] = table.concat(val_str)
          end
        elseif type(val) == 'function' then
          tbl_str[#tbl_str + 1] = "f() " .. tostring(ind)
          tbl_str[#tbl_str + 1] = ','   --I think this is right, I just added it
        else
          env.info('unable to serialize value type ' .. routines.utils.basicSerialize(type(val)) .. ' at index ' .. tostring(ind))
          env.info( debug.traceback() )
        end
  
      end
      tbl_str[#tbl_str + 1] = '}'
      return table.concat(tbl_str)
    else
      return tostring(tbl)
    end
  end
  
  local objectreturn = _Serialize(tbl)
  return objectreturn
end

--porting in Slmod's "safestring" basic serialize
UTILS.BasicSerialize = function(s)
  if s == nil then
    return "\"\""
  else
    if ((type(s) == 'number') or (type(s) == 'boolean') or (type(s) == 'function') or (type(s) == 'table') or (type(s) == 'userdata') ) then
      return tostring(s)
    elseif type(s) == 'string' then
      s = string.format('%q', s)
      return s
    end
  end
end


UTILS.ToDegree = function(angle)
  return angle*180/math.pi
end

UTILS.ToRadian = function(angle)
  return angle*math.pi/180
end

UTILS.MetersToNM = function(meters)
  return meters/1852
end

UTILS.MetersToFeet = function(meters)
  return meters/0.3048
end

UTILS.NMToMeters = function(NM)
  return NM*1852
end

UTILS.FeetToMeters = function(feet)
  return feet*0.3048
end

UTILS.MpsToKnots = function(mps)
  return mps*3600/1852
end

UTILS.MpsToKmph = function(mps)
  return mps*3.6
end

UTILS.KnotsToMps = function(knots)
  return knots*1852/3600
end

UTILS.KnotsToKmph = function(knots)
  return knots* 1.852
end

UTILS.KmphToMps = function(kmph)
  return kmph/3.6
end

--[[acc:
in DM: decimal point of minutes.
In DMS: decimal point of seconds.
position after the decimal of the least significant digit:
So:
42.32 - acc of 2.
]]
UTILS.tostringLL = function( lat, lon, acc, DMS)

  local latHemi, lonHemi
  if lat > 0 then
    latHemi = 'N'
  else
    latHemi = 'S'
  end

  if lon > 0 then
    lonHemi = 'E'
  else
    lonHemi = 'W'
  end

  lat = math.abs(lat)
  lon = math.abs(lon)

  local latDeg = math.floor(lat)
  local latMin = (lat - latDeg)*60

  local lonDeg = math.floor(lon)
  local lonMin = (lon - lonDeg)*60

  if DMS then  -- degrees, minutes, and seconds.
    local oldLatMin = latMin
    latMin = math.floor(latMin)
    local latSec = UTILS.Round((oldLatMin - latMin)*60, acc)

    local oldLonMin = lonMin
    lonMin = math.floor(lonMin)
    local lonSec = UTILS.Round((oldLonMin - lonMin)*60, acc)

    if latSec == 60 then
      latSec = 0
      latMin = latMin + 1
    end

    if lonSec == 60 then
      lonSec = 0
      lonMin = lonMin + 1
    end

    local secFrmtStr -- create the formatting string for the seconds place
    secFrmtStr = '%02d'
--    if acc <= 0 then  -- no decimal place.
--      secFrmtStr = '%02d'
--    else
--      local width = 3 + acc  -- 01.310 - that's a width of 6, for example.
--      secFrmtStr = '%0' .. width .. '.' .. acc .. 'f'
--    end

    return string.format('%02d', latDeg) .. ' ' .. string.format('%02d', latMin) .. '\' ' .. string.format(secFrmtStr, latSec) .. '"' .. latHemi .. '   '
           .. string.format('%02d', lonDeg) .. ' ' .. string.format('%02d', lonMin) .. '\' ' .. string.format(secFrmtStr, lonSec) .. '"' .. lonHemi

  else  -- degrees, decimal minutes.
    latMin = UTILS.Round(latMin, acc)
    lonMin = UTILS.Round(lonMin, acc)

    if latMin == 60 then
      latMin = 0
      latDeg = latDeg + 1
    end

    if lonMin == 60 then
      lonMin = 0
      lonDeg = lonDeg + 1
    end

    local minFrmtStr -- create the formatting string for the minutes place
    if acc <= 0 then  -- no decimal place.
      minFrmtStr = '%02d'
    else
      local width = 3 + acc  -- 01.310 - that's a width of 6, for example.
      minFrmtStr = '%0' .. width .. '.' .. acc .. 'f'
    end

    return string.format('%02d', latDeg) .. ' ' .. string.format(minFrmtStr, latMin) .. '\'' .. latHemi .. '   '
     .. string.format('%02d', lonDeg) .. ' ' .. string.format(minFrmtStr, lonMin) .. '\'' .. lonHemi

  end
end

-- acc- the accuracy of each easting/northing.  0, 1, 2, 3, 4, or 5.
UTILS.tostringMGRS = function(MGRS, acc) --R2.1
  if acc == 0 then
    return MGRS.UTMZone .. ' ' .. MGRS.MGRSDigraph
  else
    return MGRS.UTMZone .. ' ' .. MGRS.MGRSDigraph .. ' ' .. string.format('%0' .. acc .. 'd', UTILS.Round(MGRS.Easting/(10^(5-acc)), 0))
           .. ' ' .. string.format('%0' .. acc .. 'd', UTILS.Round(MGRS.Northing/(10^(5-acc)), 0))
  end
end


--- From http://lua-users.org/wiki/SimpleRound
-- use negative idp for rounding ahead of decimal place, positive for rounding after decimal place
function UTILS.Round( num, idp )
  local mult = 10 ^ ( idp or 0 )
  return math.floor( num * mult + 0.5 ) / mult
end

-- porting in Slmod's dostring
function UTILS.DoString( s )
  local f, err = loadstring( s )
  if f then
    return true, f()
  else
    return false, err
  end
end

-- Here is a customized version of pairs, which I called spairs because it iterates over the table in a sorted order.
function UTILS.spairs( t, order )
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

-- get a new mark ID for markings
function UTILS.GetMarkID()

  UTILS._MarkID = UTILS._MarkID + 1
  return UTILS._MarkID

end


-- Test if a Vec2 is in a radius of another Vec2
function UTILS.IsInRadius( InVec2, Vec2, Radius )

  local InRadius = ( ( InVec2.x - Vec2.x ) ^2 + ( InVec2.y - Vec2.y ) ^2 ) ^ 0.5 <= Radius

  return InRadius
end

-- Test if a Vec3 is in the sphere of another Vec3
function UTILS.IsInSphere( InVec3, Vec3, Radius )

  local InSphere = ( ( InVec3.x - Vec3.x ) ^2 + ( InVec3.y - Vec3.y ) ^2 + ( InVec3.z - Vec3.z ) ^2 ) ^ 0.5 <= Radius

  return InSphere
end
--- **Core** -- BASE forms **the basis of the MOOSE framework**. Each class within the MOOSE framework derives from BASE.
-- 
-- ![Banner Image](..\Presentations\BASE\Dia1.JPG)
-- 
-- ===
-- 
-- ### Author: **Sven Van de Velde (FlightControl)**
-- ### Contributions: 
-- 
-- ====
-- 
-- @module Base



local _TraceOnOff = true
local _TraceLevel = 1
local _TraceAll = false
local _TraceClass = {}
local _TraceClassMethod = {}

local _ClassID = 0

--- @type BASE
-- @field ClassName The name of the class.
-- @field ClassID The ID number of the class.
-- @field ClassNameAndID The name of the class concatenated with the ID number of the class.

--- # 1) #BASE class
-- 
-- All classes within the MOOSE framework are derived from the BASE class. 
--  
-- BASE provides facilities for :
-- 
--   * The construction and inheritance of MOOSE classes.
--   * The class naming and numbering system.
--   * The class hierarchy search system.
--   * The tracing of information or objects during mission execution for debuggin purposes.
--   * The subscription to DCS events for event handling in MOOSE objects.
-- 
-- Note: The BASE class is an abstract class and is not meant to be used directly.
-- 
-- ## 1.1) BASE constructor
-- 
-- Any class derived from BASE, will use the @{Base#BASE.New} constructor embedded in the @{Base#BASE.Inherit} method. 
-- See an example at the @{Base#BASE.New} method how this is done.
-- 
-- ## 1.2) Trace information for debugging
-- 
-- The BASE class contains trace methods to trace progress within a mission execution of a certain object.
-- These trace methods are inherited by each MOOSE class interiting BASE, soeach object created from derived class from BASE can use the tracing methods to trace its execution.
-- 
-- Any type of information can be passed to these tracing methods. See the following examples:
-- 
--     self:E( "Hello" )
-- 
-- Result in the word "Hello" in the dcs.log.
-- 
--     local Array = { 1, nil, "h", { "a","b" }, "x" }
--     self:E( Array )
--     
-- Results with the text [1]=1,[3]="h",[4]={[1]="a",[2]="b"},[5]="x"} in the dcs.log.   
-- 
--     local Object1 = "Object1"
--     local Object2 = 3
--     local Object3 = { Object 1, Object 2 }
--     self:E( { Object1, Object2, Object3 } )
--     
-- Results with the text [1]={[1]="Object",[2]=3,[3]={[1]="Object",[2]=3}} in the dcs.log.
--     
--     local SpawnObject = SPAWN:New( "Plane" )
--     local GroupObject = GROUP:FindByName( "Group" )
--     self:E( { Spawn = SpawnObject, Group = GroupObject } )
-- 
-- Results with the text [1]={Spawn={....),Group={...}} in the dcs.log.  
-- 
-- Below a more detailed explanation of the different method types for tracing.
-- 
-- ### 1.2.1) Tracing methods categories
--
-- There are basically 3 types of tracing methods available:
-- 
--   * @{#BASE.F}: Used to trace the entrance of a function and its given parameters. An F is indicated at column 44 in the DCS.log file.
--   * @{#BASE.T}: Used to trace further logic within a function giving optional variables or parameters. A T is indicated at column 44 in the DCS.log file.
--   * @{#BASE.E}: Used to always trace information giving optional variables or parameters. An E is indicated at column 44 in the DCS.log file.
-- 
-- ### 1.2.2) Tracing levels
--
-- There are 3 tracing levels within MOOSE.  
-- These tracing levels were defined to avoid bulks of tracing to be generated by lots of objects.
-- 
-- As such, the F and T methods have additional variants to trace level 2 and 3 respectively:
--
--   * @{#BASE.F2}: Trace the beginning of a function and its given parameters with tracing level 2.
--   * @{#BASE.F3}: Trace the beginning of a function and its given parameters with tracing level 3.
--   * @{#BASE.T2}: Trace further logic within a function giving optional variables or parameters with tracing level 2.
--   * @{#BASE.T3}: Trace further logic within a function giving optional variables or parameters with tracing level 3.
-- 
-- ### 1.2.3) Trace activation.
-- 
-- Tracing can be activated in several ways:
-- 
--   * Switch tracing on or off through the @{#BASE.TraceOnOff}() method.
--   * Activate all tracing through the @{#BASE.TraceAll}() method.
--   * Activate only the tracing of a certain class (name) through the @{#BASE.TraceClass}() method.
--   * Activate only the tracing of a certain method of a certain class through the @{#BASE.TraceClassMethod}() method.
--   * Activate only the tracing of a certain level through the @{#BASE.TraceLevel}() method.
-- 
-- ### 1.2.4) Check if tracing is on.
-- 
-- The method @{#BASE.IsTrace}() will validate if tracing is activated or not.
-- 
-- ## 1.3 DCS simulator Event Handling
-- 
-- The BASE class provides methods to catch DCS Events. These are events that are triggered from within the DCS simulator, 
-- and handled through lua scripting. MOOSE provides an encapsulation to handle these events more efficiently.
-- 
-- ### 1.3.1 Subscribe / Unsubscribe to DCS Events
-- 
-- At first, the mission designer will need to **Subscribe** to a specific DCS event for the class.
-- So, when the DCS event occurs, the class will be notified of that event.
-- There are two methods which you use to subscribe to or unsubscribe from an event.
-- 
--   * @{#BASE.HandleEvent}(): Subscribe to a DCS Event.
--   * @{#BASE.UnHandleEvent}(): Unsubscribe from a DCS Event.
-- 
-- ### 1.3.2 Event Handling of DCS Events
-- 
-- Once the class is subscribed to the event, an **Event Handling** method on the object or class needs to be written that will be called
-- when the DCS event occurs. The Event Handling method receives an @{Event#EVENTDATA} structure, which contains a lot of information
-- about the event that occurred.
-- 
-- Find below an example of the prototype how to write an event handling function for two units: 
--
--      local Tank1 = UNIT:FindByName( "Tank A" )
--      local Tank2 = UNIT:FindByName( "Tank B" )
--      
--      -- Here we subscribe to the Dead events. So, if one of these tanks dies, the Tank1 or Tank2 objects will be notified.
--      Tank1:HandleEvent( EVENTS.Dead )
--      Tank2:HandleEvent( EVENTS.Dead )
--      
--      --- This function is an Event Handling function that will be called when Tank1 is Dead.
--      -- @param Wrapper.Unit#UNIT self 
--      -- @param Core.Event#EVENTDATA EventData
--      function Tank1:OnEventDead( EventData )
--
--        self:SmokeGreen()
--      end
--
--      --- This function is an Event Handling function that will be called when Tank2 is Dead.
--      -- @param Wrapper.Unit#UNIT self 
--      -- @param Core.Event#EVENTDATA EventData
--      function Tank2:OnEventDead( EventData )
--
--        self:SmokeBlue()
--      end
-- 
-- 
-- 
-- See the @{Event} module for more information about event handling.
-- 
-- ## 1.4) Class identification methods
-- 
-- BASE provides methods to get more information of each object:
-- 
--   * @{#BASE.GetClassID}(): Gets the ID (number) of the object. Each object created is assigned a number, that is incremented by one.
--   * @{#BASE.GetClassName}(): Gets the name of the object, which is the name of the class the object was instantiated from.
--   * @{#BASE.GetClassNameAndID}(): Gets the name and ID of the object.
-- 
-- ## 1.5) All objects derived from BASE can have "States"
-- 
-- A mechanism is in place in MOOSE, that allows to let the objects administer **states**.  
-- States are essentially properties of objects, which are identified by a **Key** and a **Value**.  
-- 
-- The method @{#BASE.SetState}() can be used to set a Value with a reference Key to the object.  
-- To **read or retrieve** a state Value based on a Key, use the @{#BASE.GetState} method.  
-- 
-- These two methods provide a very handy way to keep state at long lasting processes.
-- Values can be stored within the objects, and later retrieved or changed when needed.
-- There is one other important thing to note, the @{#BASE.SetState}() and @{#BASE.GetState} methods
-- receive as the **first parameter the object for which the state needs to be set**.
-- Thus, if the state is to be set for the same object as the object for which the method is used, then provide the same
-- object name to the method.
-- 
-- ## 1.10) Inheritance
-- 
-- The following methods are available to implement inheritance
-- 
--   * @{#BASE.Inherit}: Inherits from a class.
--   * @{#BASE.GetParent}: Returns the parent object from the object it is handling, or nil if there is no parent object.
-- 
-- ===
-- 
-- @field #BASE BASE
-- 
BASE = {
  ClassName = "BASE",
  ClassID = 0,
  Events = {},
  States = {},
}


--- @field #BASE.__
BASE.__ = {}

--- @field #BASE._
BASE._ = {
  Schedules = {} --- Contains the Schedulers Active
}

--- The Formation Class
-- @type FORMATION
-- @field Cone A cone formation.
FORMATION = {
  Cone = "Cone",
  Vee = "Vee" 
}



--- BASE constructor.  
-- 
-- This is an example how to use the BASE:New() constructor in a new class definition when inheriting from BASE.
--  
--     function EVENT:New()
--       local self = BASE:Inherit( self, BASE:New() ) -- #EVENT
--       return self
--     end
--       
-- @param #BASE self
-- @return #BASE
function BASE:New()
  local self = routines.utils.deepCopy( self ) -- Create a new self instance

	_ClassID = _ClassID + 1
	self.ClassID = _ClassID
	
	-- This is for "private" methods...
	-- When a __ is passed to a method as "self", the __index will search for the method on the public method list too!
--  if rawget( self, "__" ) then
    --setmetatable( self, { __index = self.__ } )
--  end
	
	return self
end

--- This is the worker method to inherit from a parent class.
-- @param #BASE self
-- @param Child is the Child class that inherits.
-- @param #BASE Parent is the Parent class that the Child inherits from.
-- @return #BASE Child
function BASE:Inherit( Child, Parent )
	local Child = routines.utils.deepCopy( Child )

	if Child ~= nil then

  -- This is for "private" methods...
  -- When a __ is passed to a method as "self", the __index will search for the method on the public method list of the same object too!
    if rawget( Child, "__" ) then
      setmetatable( Child, { __index = Child.__  } )
      setmetatable( Child.__, { __index = Parent } )
    else
      setmetatable( Child, { __index = Parent } )
    end
    
		--Child:_SetDestructor()
	end
	return Child
end


local function getParent( Child )
  local Parent = nil
  
  if Child.ClassName == 'BASE' then
    Parent = nil
  else
    if rawget( Child, "__" ) then
      Parent = getmetatable( Child.__ ).__index
    else
      Parent = getmetatable( Child ).__index
    end 
  end
  return Parent
end


--- This is the worker method to retrieve the Parent class.  
-- Note that the Parent class must be passed to call the parent class method.
-- 
--     self:GetParent(self):ParentMethod()
--     
--     
-- @param #BASE self
-- @param #BASE Child is the Child class from which the Parent class needs to be retrieved.
-- @return #BASE
function BASE:GetParent( Child, FromClass )


  local Parent
  -- BASE class has no parent
  if Child.ClassName == 'BASE' then
    Parent = nil
  else
  
    self:E({FromClass = FromClass})
    self:E({Child = Child.ClassName})
    if FromClass then
      while( Child.ClassName ~= "BASE" and Child.ClassName ~= FromClass.ClassName ) do
        Child = getParent( Child )
        self:E({Child.ClassName})
      end
    end  
    if Child.ClassName == 'BASE' then
      Parent = nil
    else
      Parent = getParent( Child )
    end
  end
  self:E({Parent.ClassName})
  return Parent
end

--- This is the worker method to check if an object is an (sub)instance of a class.
--
-- ### Examples:
--
--    * ZONE:New( 'some zone' ):IsInstanceOf( ZONE ) will return true
--    * ZONE:New( 'some zone' ):IsInstanceOf( 'ZONE' ) will return true
--    * ZONE:New( 'some zone' ):IsInstanceOf( 'zone' ) will return true
--    * ZONE:New( 'some zone' ):IsInstanceOf( 'BASE' ) will return true
--
--    * ZONE:New( 'some zone' ):IsInstanceOf( 'GROUP' ) will return false
-- 
-- @param #BASE self
-- @param ClassName is the name of the class or the class itself to run the check against
-- @return #boolean
function BASE:IsInstanceOf( ClassName )

  -- Is className NOT a string ?
  if type( ClassName ) ~= 'string' then
  
    -- Is className a Moose class ?
    if type( ClassName ) == 'table' and ClassName.ClassName ~= nil then
    
      -- Get the name of the Moose class as a string
      ClassName = ClassName.ClassName
      
    -- className is neither a string nor a Moose class, throw an error
    else
    
      -- I'm not sure if this should take advantage of MOOSE logging function, or throw an error for pcall
      local err_str = 'className parameter should be a string; parameter received: '..type( ClassName )
      self:E( err_str )
      -- error( err_str )
      return false
      
    end
  end
  
  ClassName = string.upper( ClassName )

  if string.upper( self.ClassName ) == ClassName then
    return true
  end

  local Parent = getParent(self)

  while Parent do

    if string.upper( Parent.ClassName ) == ClassName then
      return true
    end

    Parent = getParent( Parent )

  end

  return false

end
--- Get the ClassName + ClassID of the class instance.
-- The ClassName + ClassID is formatted as '%s#%09d'. 
-- @param #BASE self
-- @return #string The ClassName + ClassID of the class instance.
function BASE:GetClassNameAndID()
  return string.format( '%s#%09d', self.ClassName, self.ClassID )
end

--- Get the ClassName of the class instance.
-- @param #BASE self
-- @return #string The ClassName of the class instance.
function BASE:GetClassName()
  return self.ClassName
end

--- Get the ClassID of the class instance.
-- @param #BASE self
-- @return #string The ClassID of the class instance.
function BASE:GetClassID()
  return self.ClassID
end

do -- Event Handling

  --- Returns the event dispatcher
  -- @param #BASE self
  -- @return Core.Event#EVENT
  function BASE:EventDispatcher()
  
    return _EVENTDISPATCHER
  end
  
  
  --- Get the Class @{Event} processing Priority.
  -- The Event processing Priority is a number from 1 to 10, 
  -- reflecting the order of the classes subscribed to the Event to be processed.
  -- @param #BASE self
  -- @return #number The @{Event} processing Priority.
  function BASE:GetEventPriority()
    return self._.EventPriority or 5
  end
  
  --- Set the Class @{Event} processing Priority.
  -- The Event processing Priority is a number from 1 to 10, 
  -- reflecting the order of the classes subscribed to the Event to be processed.
  -- @param #BASE self
  -- @param #number EventPriority The @{Event} processing Priority.
  -- @return self
  function BASE:SetEventPriority( EventPriority )
    self._.EventPriority = EventPriority
  end
  
  --- Remove all subscribed events
  -- @param #BASE self
  -- @return #BASE
  function BASE:EventRemoveAll()
  
    self:EventDispatcher():RemoveAll( self )
    
    return self
  end
  
  --- Subscribe to a DCS Event.
  -- @param #BASE self
  -- @param Core.Event#EVENTS Event
  -- @param #function EventFunction (optional) The function to be called when the event occurs for the unit.
  -- @return #BASE
  function BASE:HandleEvent( Event, EventFunction )
  
    self:EventDispatcher():OnEventGeneric( EventFunction, self, Event )
    
    return self
  end
  
  --- UnSubscribe to a DCS event.
  -- @param #BASE self
  -- @param Core.Event#EVENTS Event
  -- @return #BASE
  function BASE:UnHandleEvent( Event )
  
    self:EventDispatcher():RemoveEvent( self, Event )
    
    return self
  end
  
  -- Event handling function prototypes
  
  --- Occurs whenever any unit in a mission fires a weapon. But not any machine gun or autocannon based weapon, those are handled by EVENT.ShootingStart.
  -- @function [parent=#BASE] OnEventShot
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs whenever an object is hit by a weapon.
  -- initiator : The unit object the fired the weapon
  -- weapon: Weapon object that hit the target
  -- target: The Object that was hit. 
  -- @function [parent=#BASE] OnEventHit
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs when an aircraft takes off from an airbase, farp, or ship.
  -- initiator : The unit that tookoff
  -- place: Object from where the AI took-off from. Can be an Airbase Object, FARP, or Ships 
  -- @function [parent=#BASE] OnEventTakeoff
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs when an aircraft lands at an airbase, farp or ship
  -- initiator : The unit that has landed
  -- place: Object that the unit landed on. Can be an Airbase Object, FARP, or Ships 
  -- @function [parent=#BASE] OnEventLand
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs when any aircraft crashes into the ground and is completely destroyed.
  -- initiator : The unit that has crashed 
  -- @function [parent=#BASE] OnEventCrash
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs when a pilot ejects from an aircraft
  -- initiator : The unit that has ejected 
  -- @function [parent=#BASE] OnEventEjection
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs when an aircraft connects with a tanker and begins taking on fuel.
  -- initiator : The unit that is receiving fuel. 
  -- @function [parent=#BASE] OnEventRefueling
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs when an object is dead.
  -- initiator : The unit that is dead. 
  -- @function [parent=#BASE] OnEventDead
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs when an object is completely destroyed.
  -- initiator : The unit that is was destroyed. 
  -- @function [parent=#BASE] OnEvent
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs when the pilot of an aircraft is killed. Can occur either if the player is alive and crashes or if a weapon kills the pilot without completely destroying the plane.
  -- initiator : The unit that the pilot has died in. 
  -- @function [parent=#BASE] OnEventPilotDead
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs when a ground unit captures either an airbase or a farp.
  -- initiator : The unit that captured the base
  -- place: The airbase that was captured, can be a FARP or Airbase. When calling place:getCoalition() the faction will already be the new owning faction. 
  -- @function [parent=#BASE] OnEventBaseCaptured
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs when a mission starts 
  -- @function [parent=#BASE] OnEventMissionStart
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs when a mission ends
  -- @function [parent=#BASE] OnEventMissionEnd
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs when an aircraft is finished taking fuel.
  -- initiator : The unit that was receiving fuel. 
  -- @function [parent=#BASE] OnEventRefuelingStop
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs when any object is spawned into the mission.
  -- initiator : The unit that was spawned 
  -- @function [parent=#BASE] OnEventBirth
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs when any system fails on a human controlled aircraft.
  -- initiator : The unit that had the failure 
  -- @function [parent=#BASE] OnEventHumanFailure
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs when any aircraft starts its engines.
  -- initiator : The unit that is starting its engines. 
  -- @function [parent=#BASE] OnEventEngineStartup
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs when any aircraft shuts down its engines.
  -- initiator : The unit that is stopping its engines. 
  -- @function [parent=#BASE] OnEventEngineShutdown
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs when any player assumes direct control of a unit.
  -- initiator : The unit that is being taken control of. 
  -- @function [parent=#BASE] OnEventPlayerEnterUnit
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs when any player relieves control of a unit to the AI.
  -- initiator : The unit that the player left. 
  -- @function [parent=#BASE] OnEventPlayerLeaveUnit
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs when any unit begins firing a weapon that has a high rate of fire. Most common with aircraft cannons (GAU-8), autocannons, and machine guns.
  -- initiator : The unit that is doing the shooing.
  -- target: The unit that is being targeted. 
  -- @function [parent=#BASE] OnEventShootingStart
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

  --- Occurs when any unit stops firing its weapon. Event will always correspond with a shooting start event.
  -- initiator : The unit that was doing the shooing. 
  -- @function [parent=#BASE] OnEventShootingEnd
  -- @param #BASE self
  -- @param Core.Event#EVENTDATA EventData The EventData structure.

end
 

--- Creation of a Birth Event.
-- @param #BASE self
-- @param Dcs.DCSTypes#Time EventTime The time stamp of the event.
-- @param Dcs.DCSWrapper.Object#Object Initiator The initiating object of the event.
-- @param #string IniUnitName The initiating unit name.
-- @param place
-- @param subplace
function BASE:CreateEventBirth( EventTime, Initiator, IniUnitName, place, subplace )
	self:F( { EventTime, Initiator, IniUnitName, place, subplace } )

	local Event = {
		id = world.event.S_EVENT_BIRTH,
		time = EventTime,
		initiator = Initiator,
		IniUnitName = IniUnitName,
		place = place,
		subplace = subplace
		}

	world.onEvent( Event )
end

--- Creation of a Crash Event.
-- @param #BASE self
-- @param Dcs.DCSTypes#Time EventTime The time stamp of the event.
-- @param Dcs.DCSWrapper.Object#Object Initiator The initiating object of the event.
function BASE:CreateEventCrash( EventTime, Initiator )
	self:F( { EventTime, Initiator } )

	local Event = {
		id = world.event.S_EVENT_CRASH,
		time = EventTime,
		initiator = Initiator,
		}

	world.onEvent( Event )
end

--- Creation of a Takeoff Event.
-- @param #BASE self
-- @param Dcs.DCSTypes#Time EventTime The time stamp of the event.
-- @param Dcs.DCSWrapper.Object#Object Initiator The initiating object of the event.
function BASE:CreateEventTakeoff( EventTime, Initiator )
  self:F( { EventTime, Initiator } )

  local Event = {
    id = world.event.S_EVENT_TAKEOFF,
    time = EventTime,
    initiator = Initiator,
    }

  world.onEvent( Event )
end

-- TODO: Complete Dcs.DCSTypes#Event structure.                       
--- The main event handling function... This function captures all events generated for the class.
-- @param #BASE self
-- @param Dcs.DCSTypes#Event event
function BASE:onEvent(event)
  --self:F( { BaseEventCodes[event.id], event } )

	if self then
		for EventID, EventObject in pairs( self.Events ) do
			if EventObject.EventEnabled then
				--env.info( 'onEvent Table EventObject.Self = ' .. tostring(EventObject.Self) )
				--env.info( 'onEvent event.id = ' .. tostring(event.id) )
				--env.info( 'onEvent EventObject.Event = ' .. tostring(EventObject.Event) )
				if event.id == EventObject.Event then
					if self == EventObject.Self then
						if event.initiator and event.initiator:isExist() then
							event.IniUnitName = event.initiator:getName()
						end
						if event.target and event.target:isExist() then
							event.TgtUnitName = event.target:getName()
						end
						--self:T( { BaseEventCodes[event.id], event } )
						--EventObject.EventFunction( self, event )
					end
				end
			end
		end
	end
end

do -- Scheduling

  --- Schedule a new time event. Note that the schedule will only take place if the scheduler is *started*. Even for a single schedule event, the scheduler needs to be started also.
  -- @param #BASE self
  -- @param #number Start Specifies the amount of seconds that will be waited before the scheduling is started, and the event function is called.
  -- @param #function SchedulerFunction The event function to be called when a timer event occurs. The event function needs to accept the parameters specified in SchedulerArguments.
  -- @param #table ... Optional arguments that can be given as part of scheduler. The arguments need to be given as a table { param1, param 2, ... }.
  -- @return #number The ScheduleID of the planned schedule.
  function BASE:ScheduleOnce( Start, SchedulerFunction, ... )
    self:F2( { Start } )
    self:T3( { ... } )
  
    local ObjectName = "-"
    ObjectName = self.ClassName .. self.ClassID
    
    self:F3( { "ScheduleOnce: ", ObjectName,  Start } )
    self.SchedulerObject = self
    
    local ScheduleID = _SCHEDULEDISPATCHER:AddSchedule( 
      self, 
      SchedulerFunction,
      { ... },
      Start,
      nil,
      nil,
      nil
    )
    
    self._.Schedules[#self.Schedules+1] = ScheduleID
  
    return self._.Schedules
  end

  --- Schedule a new time event. Note that the schedule will only take place if the scheduler is *started*. Even for a single schedule event, the scheduler needs to be started also.
  -- @param #BASE self
  -- @param #number Start Specifies the amount of seconds that will be waited before the scheduling is started, and the event function is called.
  -- @param #number Repeat Specifies the interval in seconds when the scheduler will call the event function.
  -- @param #number RandomizeFactor Specifies a randomization factor between 0 and 1 to randomize the Repeat.
  -- @param #number Stop Specifies the amount of seconds when the scheduler will be stopped.
  -- @param #function SchedulerFunction The event function to be called when a timer event occurs. The event function needs to accept the parameters specified in SchedulerArguments.
  -- @param #table ... Optional arguments that can be given as part of scheduler. The arguments need to be given as a table { param1, param 2, ... }.
  -- @return #number The ScheduleID of the planned schedule.
  function BASE:ScheduleRepeat( Start, Repeat, RandomizeFactor, Stop, SchedulerFunction, ... )
    self:F2( { Start } )
    self:T3( { ... } )
  
    local ObjectName = "-"
    ObjectName = self.ClassName .. self.ClassID
    
    self:F3( { "ScheduleRepeat: ", ObjectName, Start, Repeat, RandomizeFactor, Stop } )
    self.SchedulerObject = self
    
    local ScheduleID = _SCHEDULEDISPATCHER:AddSchedule( 
      self, 
      SchedulerFunction,
      { ... },
      Start,
      Repeat,
      RandomizeFactor,
      Stop
    )
    
    self._.Schedules[SchedulerFunction] = ScheduleID
  
    return self._.Schedules
  end

  --- Stops the Schedule.
  -- @param #BASE self
  -- @param #function SchedulerFunction The event function to be called when a timer event occurs. The event function needs to accept the parameters specified in SchedulerArguments.
  function BASE:ScheduleStop( SchedulerFunction )
  
    self:F3( { "ScheduleStop:" } )
    
  _SCHEDULEDISPATCHER:Stop( self, self._.Schedules[SchedulerFunction] )
  end

end


--- Set a state or property of the Object given a Key and a Value.
-- Note that if the Object is destroyed, nillified or garbage collected, then the Values and Keys will also be gone.
-- @param #BASE self
-- @param Object The object that will hold the Value set by the Key.
-- @param Key The key that is used as a reference of the value. Note that the key can be a #string, but it can also be any other type!
-- @param Value The value to is stored in the object.
-- @return The Value set.
-- @return #nil The Key was not found and thus the Value could not be retrieved.
function BASE:SetState( Object, Key, Value )

  local ClassNameAndID = Object:GetClassNameAndID()

  self.States[ClassNameAndID] = self.States[ClassNameAndID] or {}
  self.States[ClassNameAndID][Key] = Value
  
  return self.States[ClassNameAndID][Key]
end


--- Get a Value given a Key from the Object.
-- Note that if the Object is destroyed, nillified or garbage collected, then the Values and Keys will also be gone.
-- @param #BASE self
-- @param Object The object that holds the Value set by the Key.
-- @param Key The key that is used to retrieve the value. Note that the key can be a #string, but it can also be any other type!
-- @return The Value retrieved.
function BASE:GetState( Object, Key )

  local ClassNameAndID = Object:GetClassNameAndID()

  if self.States[ClassNameAndID] then
    local Value = self.States[ClassNameAndID][Key] or false
    return Value
  end
  
  return nil
end

function BASE:ClearState( Object, StateName )

  local ClassNameAndID = Object:GetClassNameAndID()
  if self.States[ClassNameAndID] then
    self.States[ClassNameAndID][StateName] = nil
  end
end

-- Trace section

-- Log a trace (only shown when trace is on)
-- TODO: Make trace function using variable parameters.

--- Set trace on or off
-- Note that when trace is off, no debug statement is performed, increasing performance!
-- When Moose is loaded statically, (as one file), tracing is switched off by default.
-- So tracing must be switched on manually in your mission if you are using Moose statically.
-- When moose is loading dynamically (for moose class development), tracing is switched on by default.
-- @param #BASE self
-- @param #boolean TraceOnOff Switch the tracing on or off.
-- @usage
-- -- Switch the tracing On
-- BASE:TraceOnOff( true )
-- 
-- -- Switch the tracing Off
-- BASE:TraceOnOff( false )
function BASE:TraceOnOff( TraceOnOff )
  _TraceOnOff = TraceOnOff
end


--- Enquires if tracing is on (for the class).
-- @param #BASE self
-- @return #boolean
function BASE:IsTrace()

  if debug and ( _TraceAll == true ) or ( _TraceClass[self.ClassName] or _TraceClassMethod[self.ClassName] ) then
    return true
  else
    return false
  end
end

--- Set trace level
-- @param #BASE self
-- @param #number Level
function BASE:TraceLevel( Level )
  _TraceLevel = Level
  self:E( "Tracing level " .. Level )
end

--- Trace all methods in MOOSE
-- @param #BASE self
-- @param #boolean TraceAll true = trace all methods in MOOSE.
function BASE:TraceAll( TraceAll )
  
  _TraceAll = TraceAll
  
  if _TraceAll then
    self:E( "Tracing all methods in MOOSE " )
  else
    self:E( "Switched off tracing all methods in MOOSE" )
  end
end

--- Set tracing for a class
-- @param #BASE self
-- @param #string Class
function BASE:TraceClass( Class )
  _TraceClass[Class] = true
  _TraceClassMethod[Class] = {}
  self:E( "Tracing class " .. Class )
end

--- Set tracing for a specific method of  class
-- @param #BASE self
-- @param #string Class
-- @param #string Method
function BASE:TraceClassMethod( Class, Method )
  if not _TraceClassMethod[Class] then
    _TraceClassMethod[Class] = {}
    _TraceClassMethod[Class].Method = {}
  end
  _TraceClassMethod[Class].Method[Method] = true
  self:E( "Tracing method " .. Method .. " of class " .. Class )
end

--- Trace a function call. This function is private.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:_F( Arguments, DebugInfoCurrentParam, DebugInfoFromParam )

  if debug and ( _TraceAll == true ) or ( _TraceClass[self.ClassName] or _TraceClassMethod[self.ClassName] ) then

    local DebugInfoCurrent = DebugInfoCurrentParam and DebugInfoCurrentParam or debug.getinfo( 2, "nl" )
    local DebugInfoFrom = DebugInfoFromParam and DebugInfoFromParam or debug.getinfo( 3, "l" )
    
    local Function = "function"
    if DebugInfoCurrent.name then
      Function = DebugInfoCurrent.name
    end
    
    if _TraceAll == true or _TraceClass[self.ClassName] or _TraceClassMethod[self.ClassName].Method[Function] then
      local LineCurrent = 0
      if DebugInfoCurrent.currentline then
        LineCurrent = DebugInfoCurrent.currentline
      end
      local LineFrom = 0
      if DebugInfoFrom then
        LineFrom = DebugInfoFrom.currentline
      end
      env.info( string.format( "%6d(%6d)/%1s:%20s%05d.%s(%s)" , LineCurrent, LineFrom, "F", self.ClassName, self.ClassID, Function, routines.utils.oneLineSerialize( Arguments ) ) )
    end
  end
end

--- Trace a function call. Must be at the beginning of the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:F( Arguments )

  if debug and _TraceOnOff then
    local DebugInfoCurrent = debug.getinfo( 2, "nl" )
    local DebugInfoFrom = debug.getinfo( 3, "l" )
  
    if _TraceLevel >= 1 then
      self:_F( Arguments, DebugInfoCurrent, DebugInfoFrom )
    end
  end  
end


--- Trace a function call level 2. Must be at the beginning of the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:F2( Arguments )

  if debug and _TraceOnOff then
    local DebugInfoCurrent = debug.getinfo( 2, "nl" )
    local DebugInfoFrom = debug.getinfo( 3, "l" )
  
    if _TraceLevel >= 2 then
      self:_F( Arguments, DebugInfoCurrent, DebugInfoFrom )
    end
  end  
end

--- Trace a function call level 3. Must be at the beginning of the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:F3( Arguments )

  if debug and _TraceOnOff then
    local DebugInfoCurrent = debug.getinfo( 2, "nl" )
    local DebugInfoFrom = debug.getinfo( 3, "l" )
  
    if _TraceLevel >= 3 then
      self:_F( Arguments, DebugInfoCurrent, DebugInfoFrom )
    end
  end  
end

--- Trace a function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:_T( Arguments, DebugInfoCurrentParam, DebugInfoFromParam )

	if debug and ( _TraceAll == true ) or ( _TraceClass[self.ClassName] or _TraceClassMethod[self.ClassName] ) then

    local DebugInfoCurrent = DebugInfoCurrentParam and DebugInfoCurrentParam or debug.getinfo( 2, "nl" )
    local DebugInfoFrom = DebugInfoFromParam and DebugInfoFromParam or debug.getinfo( 3, "l" )
		
		local Function = "function"
		if DebugInfoCurrent.name then
			Function = DebugInfoCurrent.name
		end

    if _TraceAll == true or _TraceClass[self.ClassName] or _TraceClassMethod[self.ClassName].Method[Function] then
      local LineCurrent = 0
      if DebugInfoCurrent.currentline then
        LineCurrent = DebugInfoCurrent.currentline
      end
  		local LineFrom = 0
  		if DebugInfoFrom then
  		  LineFrom = DebugInfoFrom.currentline
  	  end
  		env.info( string.format( "%6d(%6d)/%1s:%20s%05d.%s" , LineCurrent, LineFrom, "T", self.ClassName, self.ClassID, routines.utils.oneLineSerialize( Arguments ) ) )
    end
	end
end

--- Trace a function logic level 1. Can be anywhere within the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:T( Arguments )

  if debug and _TraceOnOff then
    local DebugInfoCurrent = debug.getinfo( 2, "nl" )
    local DebugInfoFrom = debug.getinfo( 3, "l" )
  
    if _TraceLevel >= 1 then
      self:_T( Arguments, DebugInfoCurrent, DebugInfoFrom )
    end
  end    
end


--- Trace a function logic level 2. Can be anywhere within the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:T2( Arguments )

  if debug and _TraceOnOff then
    local DebugInfoCurrent = debug.getinfo( 2, "nl" )
    local DebugInfoFrom = debug.getinfo( 3, "l" )
  
    if _TraceLevel >= 2 then
      self:_T( Arguments, DebugInfoCurrent, DebugInfoFrom )
    end
  end
end

--- Trace a function logic level 3. Can be anywhere within the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:T3( Arguments )

  if debug and _TraceOnOff then
    local DebugInfoCurrent = debug.getinfo( 2, "nl" )
    local DebugInfoFrom = debug.getinfo( 3, "l" )
  
    if _TraceLevel >= 3 then
      self:_T( Arguments, DebugInfoCurrent, DebugInfoFrom )
    end
  end
end

--- Log an exception which will be traced always. Can be anywhere within the function logic.
-- @param #BASE self
-- @param Arguments A #table or any field.
function BASE:E( Arguments )

  if debug then
  	local DebugInfoCurrent = debug.getinfo( 2, "nl" )
  	local DebugInfoFrom = debug.getinfo( 3, "l" )
  	
  	local Function = "function"
  	if DebugInfoCurrent.name then
  		Function = DebugInfoCurrent.name
  	end
  
  	local LineCurrent = DebugInfoCurrent.currentline
    local LineFrom = -1 
  	if DebugInfoFrom then
  	  LineFrom = DebugInfoFrom.currentline
  	end
  
  	env.info( string.format( "%6d(%6d)/%1s:%20s%05d.%s(%s)" , LineCurrent, LineFrom, "E", self.ClassName, self.ClassID, Function, routines.utils.oneLineSerialize( Arguments ) ) )
  end
  
end



--- old stuff

--function BASE:_Destructor()
--  --self:E("_Destructor")
--
--  --self:EventRemoveAll()
--end


-- THIS IS WHY WE NEED LUA 5.2 ...
--function BASE:_SetDestructor()
--
--  -- TODO: Okay, this is really technical...
--  -- When you set a proxy to a table to catch __gc, weak tables don't behave like weak...
--  -- Therefore, I am parking this logic until I've properly discussed all this with the community.
--
--  local proxy = newproxy(true)
--  local proxyMeta = getmetatable(proxy)
--
--  proxyMeta.__gc = function ()
--    env.info("In __gc for " .. self:GetClassNameAndID() )
--    if self._Destructor then
--        self:_Destructor()
--    end
--  end
--
--  -- keep the userdata from newproxy reachable until the object
--  -- table is about to be garbage-collected - then the __gc hook
--  -- will be invoked and the destructor called
--  rawset( self, '__proxy', proxy )
--  
--end--- **Core (WIP)** -- Manage user flags.
--
-- ====
-- 
-- Management of DCS User Flags.
-- 
-- ====
-- 
-- ### Author: **Sven Van de Velde (FlightControl)**
-- 
-- ====
-- 
-- @module UserFlag

do -- UserFlag

  --- @type USERFLAG
  -- @extends Core.Base#BASE


  --- # USERFLAG class, extends @{Base#BASE}
  -- 
  -- Management of DCS User Flags.
  -- 
  -- ## 1. USERFLAG constructor
  --   
  --   * @{#USERFLAG.New}(): Creates a new USERFLAG object.
  -- 
  -- @field #USERFLAG
  USERFLAG = {
    ClassName = "USERFLAG",
  }
  
  --- USERFLAG Constructor.
  -- @param #USERFLAG self
  -- @param #string UserFlagName The name of the userflag, which is a free text string.
  -- @return #USERFLAG
  function USERFLAG:New( UserFlagName ) --R2.3
  
    local self = BASE:Inherit( self, BASE:New() ) -- #USERFLAG

    self.UserFlagName = UserFlagName

    return self
  end


  --- Set the userflag to a given Number.
  -- @param #USERFLAG self
  -- @param #number Number The number value to be checked if it is the same as the userflag.
  -- @return #USERFLAG The userflag instance.
  -- @usage
  --   local BlueVictory = USERFLAG:New( "VictoryBlue" )
  --   BlueVictory:Set( 100 ) -- Set the UserFlag VictoryBlue to 100.
  --   
  function USERFLAG:Set( Number ) --R2.3
    
    trigger.misc.setUserFlag( self.UserFlagName )
    
    return self
  end  

  
  --- Get the userflag Number.
  -- @param #USERFLAG self
  -- @return #number Number The number value to be checked if it is the same as the userflag.
  -- @usage
  --   local BlueVictory = USERFLAG:New( "VictoryBlue" )
  --   local BlueVictoryValue = BlueVictory:Get() -- Get the UserFlag VictoryBlue value.
  --   
  function USERFLAG:Set( Number ) --R2.3
    
    return trigger.misc.getUserFlag( self.UserFlagName )
  end  

  
  
  --- Check if the userflag has a value of Number.
  -- @param #USERFLAG self
  -- @param #number Number The number value to be checked if it is the same as the userflag.
  -- @return #boolean true if the Number is the value of the userflag.
  -- @usage
  --   local BlueVictory = USERFLAG:New( "VictoryBlue" )
  --   if BlueVictory:Is( 1 ) then
  --     return "Blue has won"
  --   end
  function USERFLAG:Is( Number ) --R2.3
    
    return trigger.misc.getUserFlag( self.UserFlagName ) == Number
    
  end  

end--- **Core (WIP)** -- Manage user sound.
--
-- ====
-- 
-- Management of DCS User Sound.
-- 
-- ====
-- 
-- ### Author: **Sven Van de Velde (FlightControl)**
-- 
-- ====
-- 
-- @module UserSound

do -- UserSound

  --- @type USERSOUND
  -- @extends Core.Base#BASE


  --- # USERSOUND class, extends @{Base#BASE}
  -- 
  -- Management of DCS User Sound.
  -- 
  -- ## 1. USERSOUND constructor
  --   
  --   * @{#USERSOUND.New}(): Creates a new USERSOUND object.
  -- 
  -- @field #USERSOUND
  USERSOUND = {
    ClassName = "USERSOUND",
  }
  
  --- USERSOUND Constructor.
  -- @param #USERSOUND self
  -- @param #string UserSoundFileName The filename of the usersound.
  -- @return #USERSOUND
  function USERSOUND:New( UserSoundFileName ) --R2.3
  
    local self = BASE:Inherit( self, BASE:New() ) -- #USERSOUND

    self.UserSoundFileName = UserSoundFileName

    return self
  end


  --- Set usersound filename.
  -- @param #USERSOUND self
  -- @param #string UserSoundFileName The filename of the usersound.
  -- @return #USERSOUND The usersound instance.
  -- @usage
  --   local BlueVictory = USERSOUND:New( "BlueVictory.ogg" )
  --   BlueVictory:SetFileName( "BlueVictoryLoud.ogg" ) -- Set the BlueVictory to change the file name to play a louder sound.
  --   
  function USERSOUND:SetFileName( UserSoundFileName ) --R2.3
    
    self.UserSoundFileName = UserSoundFileName

    return self
  end  

  


  --- Play the usersound to all players.
  -- @param #USERSOUND self
  -- @return #USERSOUND The usersound instance.
  -- @usage
  --   local BlueVictory = USERSOUND:New( "BlueVictory.ogg" )
  --   BlueVictory:ToAll() -- Play the sound that Blue has won.
  --   
  function USERSOUND:ToAll() --R2.3
    
    trigger.action.outSound( self.UserSoundFileName )
    
    return self
  end  

  
  --- Play the usersound to the given coalition.
  -- @param #USERSOUND self
  -- @param Dcs.DCScoalition#coalition Coalition The coalition to play the usersound to.
  -- @return #USERSOUND The usersound instance.
  -- @usage
  --   local BlueVictory = USERSOUND:New( "BlueVictory.ogg" )
  --   BlueVictory:ToCoalition( coalition.side.BLUE ) -- Play the sound that Blue has won to the blue coalition.
  --   
  function USERSOUND:ToCoalition( Coalition ) --R2.3
    
    trigger.action.outSoundForCoalition(Coalition, self.UserSoundFileName )
    
    return self
  end  


  --- Play the usersound to the given country.
  -- @param #USERSOUND self
  -- @param Dcs.DCScountry#country Country The country to play the usersound to.
  -- @return #USERSOUND The usersound instance.
  -- @usage
  --   local BlueVictory = USERSOUND:New( "BlueVictory.ogg" )
  --   BlueVictory:ToCountry( country.id.USA ) -- Play the sound that Blue has won to the USA country.
  --   
  function USERSOUND:ToCountry( Country ) --R2.3
    
    trigger.action.outSoundForCountry( Country, self.UserSoundFileName )
    
    return self
  end  


  --- Play the usersound to the given @{Group}.
  -- @param #USERSOUND self
  -- @param Wrapper.Group#GROUP Group The @{Group} to play the usersound to.
  -- @return #USERSOUND The usersound instance.
  -- @usage
  --   local BlueVictory = USERSOUND:New( "BlueVictory.ogg" )
  --   local PlayerGroup = GROUP:FindByName( "PlayerGroup" ) -- Search for the active group named "PlayerGroup", that contains a human player.
  --   BlueVictory:ToGroup( PlayerGroup ) -- Play the sound that Blue has won to the player group.
  --   
  function USERSOUND:ToGroup( Group ) --R2.3
    
    trigger.action.outSoundForGroup( Group:GetID(), self.UserSoundFileName )
    
    return self
  end  

end--- The REPORT class
-- @type REPORT
-- @extends Core.Base#BASE
REPORT = {
  ClassName = "REPORT",
  Title = "",
}

--- Create a new REPORT.
-- @param #REPORT self
-- @param #string Title
-- @return #REPORT
function REPORT:New( Title )

  local self = BASE:Inherit( self, BASE:New() ) -- #REPORT

  self.Report = {}

  self:SetTitle( Title or "" )  
  self:SetIndent( 3 )

  return self
end

--- Has the REPORT Text?
-- @param #REPORT self
-- @return #boolean
function REPORT:HasText() --R2.1
  
  return #self.Report > 0
end


--- Set indent of a REPORT.
-- @param #REPORT self
-- @param #number Indent
-- @return #REPORT
function REPORT:SetIndent( Indent ) --R2.1
  self.Indent = Indent
  return self
end


--- Add a new line to a REPORT.
-- @param #REPORT self
-- @param #string Text
-- @return #REPORT
function REPORT:Add( Text )
  self.Report[#self.Report+1] = Text
  return self
end

--- Add a new line to a REPORT.
-- @param #REPORT self
-- @param #string Text
-- @return #REPORT
function REPORT:AddIndent( Text ) --R2.1
  self.Report[#self.Report+1] = string.rep(" ", self.Indent ) .. Text:gsub("\n","\n"..string.rep( " ", self.Indent ) )
  return self
end

--- Produces the text of the report, taking into account an optional delimeter, which is \n by default.
-- @param #REPORT self
-- @param #string Delimiter (optional) A delimiter text.
-- @return #string The report text.
function REPORT:Text( Delimiter )
  Delimiter = Delimiter or "\n"
  local ReportText = ( self.Title ~= "" and self.Title .. Delimiter or self.Title ) .. table.concat( self.Report, Delimiter ) or ""
  return ReportText
end

--- Sets the title of the report.
-- @param #REPORT self
-- @param #string Title The title of the report.
-- @return #REPORT
function REPORT:SetTitle( Title )
  self.Title = Title  
  return self
end

--- Gets the amount of report items contained in the report.
-- @param #REPORT self
-- @return #number Returns the number of report items contained in the report. 0 is returned if no report items are contained in the report. The title is not counted for.
function REPORT:GetCount()
  return #self.Report
end
--- **Core** -- SCHEDULER prepares and handles the **execution of functions over scheduled time (intervals)**.
--
-- ![Banner Image](..\Presentations\SCHEDULER\Dia1.JPG)
-- 
-- ===
-- 
-- SCHEDULER manages the **scheduling of functions**:
-- 
--    * optionally in an optional specified time interval, 
--    * optionally **repeating** with a specified time repeat interval, 
--    * optionally **randomizing** with a specified time interval randomization factor, 
--    * optionally **stop** the repeating after a specified time interval. 
--
-- ===
-- 
-- # Demo Missions
-- 
-- ### [SCHEDULER Demo Missions source code](https://github.com/FlightControl-Master/MOOSE_MISSIONS/tree/master-release/SCH%20-%20Scheduler)
-- 
-- ### [SCHEDULER Demo Missions, only for beta testers](https://github.com/FlightControl-Master/MOOSE_MISSIONS/tree/master/SCH%20-%20Scheduler)
--
-- ### [ALL Demo Missions pack of the last release](https://github.com/FlightControl-Master/MOOSE_MISSIONS/releases)
-- 
-- ====
-- 
-- # YouTube Channel
-- 
-- ### [SCHEDULER YouTube Channel (none)]()
-- 
-- ====
--
-- ### Contributions: 
-- 
--   * FlightControl : Concept & Testing
-- 
-- ### Authors: 
-- 
--   * FlightControl : Design & Programming
-- 
-- ===
--
-- @module Scheduler


--- The SCHEDULER class
-- @type SCHEDULER
-- @field #number ScheduleID the ID of the scheduler.
-- @extends Core.Base#BASE


--- # SCHEDULER class, extends @{Base#BASE}
-- 
-- The SCHEDULER class creates schedule.
-- 
-- A SCHEDULER can manage **multiple** (repeating) schedules. Each planned or executing schedule has a unique **ScheduleID**.
-- The ScheduleID is returned when the method @{#SCHEDULER.Schedule}() is called.
-- It is recommended to store the ScheduleID in a variable, as it is used in the methods @{SCHEDULER.Start}() and @{SCHEDULER.Stop}(),
-- which can start and stop specific repeating schedules respectively within a SCHEDULER object.
--
-- ## SCHEDULER constructor
-- 
-- The SCHEDULER class is quite easy to use, but note that the New constructor has variable parameters:
-- 
-- The @{#SCHEDULER.New}() method returns 2 variables:
--   
--  1. The SCHEDULER object reference.
--  2. The first schedule planned in the SCHEDULER object.
-- 
-- To clarify the different appliances, lets have a look at the following examples: 
--  
-- ### Construct a SCHEDULER object without a persistent schedule.
-- 
--   * @{#SCHEDULER.New}( nil ): Setup a new SCHEDULER object, which is persistently executed after garbage collection.
-- 
--     SchedulerObject = SCHEDULER:New()
--     SchedulerID = SchedulerObject:Schedule( nil, ScheduleFunction, {} )
-- 
-- The above example creates a new SchedulerObject, but does not schedule anything.
-- A separate schedule is created by using the SchedulerObject using the method :Schedule..., which returns a ScheduleID
-- 
-- ### Construct a SCHEDULER object without a volatile schedule, but volatile to the Object existence...
-- 
--   * @{#SCHEDULER.New}( Object ): Setup a new SCHEDULER object, which is linked to the Object. When the Object is nillified or destroyed, the SCHEDULER object will also be destroyed and stopped after garbage collection.
-- 
--     ZoneObject = ZONE:New( "ZoneName" )
--     SchedulerObject = SCHEDULER:New( ZoneObject )
--     SchedulerID = SchedulerObject:Schedule( ZoneObject, ScheduleFunction, {} )
--     ...
--     ZoneObject = nil
--     garbagecollect()
-- 
-- The above example creates a new SchedulerObject, but does not schedule anything, and is bound to the existence of ZoneObject, which is a ZONE.
-- A separate schedule is created by using the SchedulerObject using the method :Schedule()..., which returns a ScheduleID
-- Later in the logic, the ZoneObject is put to nil, and garbage is collected.
-- As a result, the ScheduleObject will cancel any planned schedule.
--      
-- ### Construct a SCHEDULER object with a persistent schedule.
-- 
--   * @{#SCHEDULER.New}( nil, Function, FunctionArguments, Start, ... ): Setup a new persistent SCHEDULER object, and start a new schedule for the Function with the defined FunctionArguments according the Start and sequent parameters.
--   
--     SchedulerObject, SchedulerID = SCHEDULER:New( nil, ScheduleFunction, {} )
--     
-- The above example creates a new SchedulerObject, and does schedule the first schedule as part of the call.
-- Note that 2 variables are returned here: SchedulerObject, ScheduleID...
--   
-- ### Construct a SCHEDULER object without a schedule, but volatile to the Object existence...
-- 
--   * @{#SCHEDULER.New}( Object, Function, FunctionArguments, Start, ... ): Setup a new SCHEDULER object, linked to Object, and start a new schedule for the Function with the defined FunctionArguments according the Start and sequent parameters.
--
--     ZoneObject = ZONE:New( "ZoneName" )
--     SchedulerObject, SchedulerID = SCHEDULER:New( ZoneObject, ScheduleFunction, {} )
--     SchedulerID = SchedulerObject:Schedule( ZoneObject, ScheduleFunction, {} )
--     ...
--     ZoneObject = nil
--     garbagecollect()
--     
-- The above example creates a new SchedulerObject, and schedules a method call (ScheduleFunction), 
-- and is bound to the existence of ZoneObject, which is a ZONE object (ZoneObject).
-- Both a ScheduleObject and a SchedulerID variable are returned.
-- Later in the logic, the ZoneObject is put to nil, and garbage is collected.
-- As a result, the ScheduleObject will cancel the planned schedule.
--  
-- ## SCHEDULER timer stopping and (re-)starting.
--
-- The SCHEDULER can be stopped and restarted with the following methods:
--
--  * @{#SCHEDULER.Start}(): (Re-)Start the schedules within the SCHEDULER object. If a CallID is provided to :Start(), only the schedule referenced by CallID will be (re-)started.
--  * @{#SCHEDULER.Stop}(): Stop the schedules within the SCHEDULER object. If a CallID is provided to :Stop(), then only the schedule referenced by CallID will be stopped.
--
--     ZoneObject = ZONE:New( "ZoneName" )
--     SchedulerObject, SchedulerID = SCHEDULER:New( ZoneObject, ScheduleFunction, {} )
--     SchedulerID = SchedulerObject:Schedule( ZoneObject, ScheduleFunction, {}, 10, 10 )
--     ...
--     SchedulerObject:Stop( SchedulerID )
--     ...
--     SchedulerObject:Start( SchedulerID )
--     
-- The above example creates a new SchedulerObject, and does schedule the first schedule as part of the call.
-- Note that 2 variables are returned here: SchedulerObject, ScheduleID...  
-- Later in the logic, the repeating schedule with SchedulerID is stopped.  
-- A bit later, the repeating schedule with SchedulerId is (re)-started.  
-- 
-- ## Create a new schedule
-- 
-- With the method @{#SCHEDULER.Schedule}() a new time event can be scheduled. 
-- This method is used by the :New() constructor when a new schedule is planned.
-- 
-- Consider the following code fragment of the SCHEDULER object creation.
-- 
--     ZoneObject = ZONE:New( "ZoneName" )
--     SchedulerObject = SCHEDULER:New( ZoneObject )
-- 
-- Several parameters can be specified that influence the behaviour of a Schedule.
-- 
-- ### A single schedule, immediately executed
-- 
--     SchedulerID = SchedulerObject:Schedule( ZoneObject, ScheduleFunction, {} )
-- 
-- The above example schedules a new ScheduleFunction call to be executed asynchronously, within milleseconds ...
-- 
-- ### A single schedule, planned over time
-- 
--     SchedulerID = SchedulerObject:Schedule( ZoneObject, ScheduleFunction, {}, 10 )
--     
-- The above example schedules a new ScheduleFunction call to be executed asynchronously, within 10 seconds ...
-- 
-- ### A schedule with a repeating time interval, planned over time
-- 
--     SchedulerID = SchedulerObject:Schedule( ZoneObject, ScheduleFunction, {}, 10, 60 )
--     
-- The above example schedules a new ScheduleFunction call to be executed asynchronously, within 10 seconds, 
-- and repeating 60 every seconds ...
-- 
-- ### A schedule with a repeating time interval, planned over time, with time interval randomization
-- 
--     SchedulerID = SchedulerObject:Schedule( ZoneObject, ScheduleFunction, {}, 10, 60, 0.5 )
--     
-- The above example schedules a new ScheduleFunction call to be executed asynchronously, within 10 seconds, 
-- and repeating 60 seconds, with a 50% time interval randomization ...
-- So the repeating time interval will be randomized using the **0.5**,  
-- and will calculate between **60 - ( 60 * 0.5 )** and **60 + ( 60 * 0.5 )** for each repeat, 
-- which is in this example between **30** and **90** seconds.
-- 
-- ### A schedule with a repeating time interval, planned over time, with time interval randomization, and stop after a time interval
-- 
--     SchedulerID = SchedulerObject:Schedule( ZoneObject, ScheduleFunction, {}, 10, 60, 0.5, 300 )
--     
-- The above example schedules a new ScheduleFunction call to be executed asynchronously, within 10 seconds, 
-- The schedule will repeat every 60 seconds.
-- So the repeating time interval will be randomized using the **0.5**,  
-- and will calculate between **60 - ( 60 * 0.5 )** and **60 + ( 60 * 0.5 )** for each repeat, 
-- which is in this example between **30** and **90** seconds.
-- The schedule will stop after **300** seconds.
-- 
-- @field #SCHEDULER
SCHEDULER = {
  ClassName = "SCHEDULER",
  Schedules = {},
}

--- SCHEDULER constructor.
-- @param #SCHEDULER self
-- @param #table SchedulerObject Specified for which Moose object the timer is setup. If a value of nil is provided, a scheduler will be setup without an object reference.
-- @param #function SchedulerFunction The event function to be called when a timer event occurs. The event function needs to accept the parameters specified in SchedulerArguments.
-- @param #table SchedulerArguments Optional arguments that can be given as part of scheduler. The arguments need to be given as a table { param1, param 2, ... }.
-- @param #number Start Specifies the amount of seconds that will be waited before the scheduling is started, and the event function is called.
-- @param #number Repeat Specifies the interval in seconds when the scheduler will call the event function.
-- @param #number RandomizeFactor Specifies a randomization factor between 0 and 1 to randomize the Repeat.
-- @param #number Stop Specifies the amount of seconds when the scheduler will be stopped.
-- @return #SCHEDULER self.
-- @return #number The ScheduleID of the planned schedule.
function SCHEDULER:New( SchedulerObject, SchedulerFunction, SchedulerArguments, Start, Repeat, RandomizeFactor, Stop )
  
  local self = BASE:Inherit( self, BASE:New() ) -- #SCHEDULER
  self:F2( { Start, Repeat, RandomizeFactor, Stop } )

  local ScheduleID = nil
  
  self.MasterObject = SchedulerObject
  
  if SchedulerFunction then
    ScheduleID = self:Schedule( SchedulerObject, SchedulerFunction, SchedulerArguments, Start, Repeat, RandomizeFactor, Stop )
  end

  return self, ScheduleID
end

--function SCHEDULER:_Destructor()
--  --self:E("_Destructor")
--
--  _SCHEDULEDISPATCHER:RemoveSchedule( self.CallID )
--end

--- Schedule a new time event. Note that the schedule will only take place if the scheduler is *started*. Even for a single schedule event, the scheduler needs to be started also.
-- @param #SCHEDULER self
-- @param #table SchedulerObject Specified for which Moose object the timer is setup. If a value of nil is provided, a scheduler will be setup without an object reference.
-- @param #function SchedulerFunction The event function to be called when a timer event occurs. The event function needs to accept the parameters specified in SchedulerArguments.
-- @param #table SchedulerArguments Optional arguments that can be given as part of scheduler. The arguments need to be given as a table { param1, param 2, ... }.
-- @param #number Start Specifies the amount of seconds that will be waited before the scheduling is started, and the event function is called.
-- @param #number Repeat Specifies the interval in seconds when the scheduler will call the event function.
-- @param #number RandomizeFactor Specifies a randomization factor between 0 and 1 to randomize the Repeat.
-- @param #number Stop Specifies the amount of seconds when the scheduler will be stopped.
-- @return #number The ScheduleID of the planned schedule.
function SCHEDULER:Schedule( SchedulerObject, SchedulerFunction, SchedulerArguments, Start, Repeat, RandomizeFactor, Stop )
  self:F2( { Start, Repeat, RandomizeFactor, Stop } )
  self:T3( { SchedulerArguments } )

  local ObjectName = "-"
  if SchedulerObject and SchedulerObject.ClassName and SchedulerObject.ClassID then 
    ObjectName = SchedulerObject.ClassName .. SchedulerObject.ClassID
  end
  self:F3( { "Schedule :", ObjectName, tostring( SchedulerObject ),  Start, Repeat, RandomizeFactor, Stop } )
  self.SchedulerObject = SchedulerObject
  
  local ScheduleID = _SCHEDULEDISPATCHER:AddSchedule( 
    self, 
    SchedulerFunction,
    SchedulerArguments,
    Start,
    Repeat,
    RandomizeFactor,
    Stop
  )
  
  self.Schedules[#self.Schedules+1] = ScheduleID

  return ScheduleID
end

--- (Re-)Starts the schedules or a specific schedule if a valid ScheduleID is provided.
-- @param #SCHEDULER self
-- @param #number ScheduleID (optional) The ScheduleID of the planned (repeating) schedule.
function SCHEDULER:Start( ScheduleID )
  self:F3( { ScheduleID } )

  _SCHEDULEDISPATCHER:Start( self, ScheduleID )
end

--- Stops the schedules or a specific schedule if a valid ScheduleID is provided.
-- @param #SCHEDULER self
-- @param #number ScheduleID (optional) The ScheduleID of the planned (repeating) schedule.
function SCHEDULER:Stop( ScheduleID )
  self:F3( { ScheduleID } )

  _SCHEDULEDISPATCHER:Stop( self, ScheduleID )
end

--- Removes a specific schedule if a valid ScheduleID is provided.
-- @param #SCHEDULER self
-- @param #number ScheduleID (optional) The ScheduleID of the planned (repeating) schedule.
function SCHEDULER:Remove( ScheduleID )
  self:F3( { ScheduleID } )

  _SCHEDULEDISPATCHER:Remove( self, ScheduleID )
end

--- Clears all pending schedules.
-- @param #SCHEDULER self
function SCHEDULER:Clear()
  self:F3( )

  _SCHEDULEDISPATCHER:Clear( self )
end














--- **Core** -- SCHEDULEDISPATCHER dispatches the different schedules.
-- 
-- ===
-- 
-- Takes care of the creation and dispatching of scheduled functions for SCHEDULER objects.
-- 
-- This class is tricky and needs some thorought explanation.
-- SCHEDULE classes are used to schedule functions for objects, or as persistent objects.
-- The SCHEDULEDISPATCHER class ensures that:
-- 
--   - Scheduled functions are planned according the SCHEDULER object parameters.
--   - Scheduled functions are repeated when requested, according the SCHEDULER object parameters.
--   - Scheduled functions are automatically removed when the schedule is finished, according the SCHEDULER object parameters.
-- 
-- The SCHEDULEDISPATCHER class will manage SCHEDULER object in memory during garbage collection:
--   - When a SCHEDULER object is not attached to another object (that is, it's first :Schedule() parameter is nil), then the SCHEDULER  
--     object is _persistent_ within memory.
--   - When a SCHEDULER object *is* attached to another object, then the SCHEDULER object is _not persistent_ within memory after a garbage collection!
-- The none persistency of SCHEDULERS attached to objects is required to allow SCHEDULER objects to be garbage collectged, when the parent object is also desroyed or nillified and garbage collected.
-- Even when there are pending timer scheduled functions to be executed for the SCHEDULER object,  
-- these will not be executed anymore when the SCHEDULER object has been destroyed.
-- 
-- The SCHEDULEDISPATCHER allows multiple scheduled functions to be planned and executed for one SCHEDULER object.
-- The SCHEDULER object therefore keeps a table of "CallID's", which are returned after each planning of a new scheduled function by the SCHEDULEDISPATCHER.
-- The SCHEDULER object plans new scheduled functions through the @{Scheduler#SCHEDULER.Schedule}() method. 
-- The Schedule() method returns the CallID that is the reference ID for each planned schedule.
-- 
-- ===
-- 
-- ### Contributions: -
-- ### Authors: FlightControl : Design & Programming
-- 
-- @module ScheduleDispatcher

--- The SCHEDULEDISPATCHER structure
-- @type SCHEDULEDISPATCHER
SCHEDULEDISPATCHER = {
  ClassName = "SCHEDULEDISPATCHER",
  CallID = 0,
}

function SCHEDULEDISPATCHER:New()
  local self = BASE:Inherit( self, BASE:New() )
  self:F3()
  return self
end

--- Add a Schedule to the ScheduleDispatcher.
-- The development of this method was really tidy.
-- It is constructed as such that a garbage collection is executed on the weak tables, when the Scheduler is nillified.
-- Nothing of this code should be modified without testing it thoroughly.
-- @param #SCHEDULEDISPATCHER self
-- @param Core.Scheduler#SCHEDULER Scheduler
function SCHEDULEDISPATCHER:AddSchedule( Scheduler, ScheduleFunction, ScheduleArguments, Start, Repeat, Randomize, Stop )
  self:F2( { Scheduler, ScheduleFunction, ScheduleArguments, Start, Repeat, Randomize, Stop } )

  self.CallID = self.CallID + 1
  local CallID = self.CallID .. "#" .. ( Scheduler.MasterObject and Scheduler.MasterObject.GetClassNameAndID and Scheduler.MasterObject:GetClassNameAndID() or "" ) or ""

  -- Initialize the ObjectSchedulers array, which is a weakly coupled table.
  -- If the object used as the key is nil, then the garbage collector will remove the item from the Functions array.
  self.PersistentSchedulers = self.PersistentSchedulers or {}

  -- Initialize the ObjectSchedulers array, which is a weakly coupled table.
  -- If the object used as the key is nil, then the garbage collector will remove the item from the Functions array.
  self.ObjectSchedulers = self.ObjectSchedulers or setmetatable( {}, { __mode = "v" } ) 
  
  if Scheduler.MasterObject then
    self.ObjectSchedulers[CallID] = Scheduler
    self:F3( { CallID = CallID, ObjectScheduler = tostring(self.ObjectSchedulers[CallID]), MasterObject = tostring(Scheduler.MasterObject) } )
  else
    self.PersistentSchedulers[CallID] = Scheduler
    self:F3( { CallID = CallID, PersistentScheduler = self.PersistentSchedulers[CallID] } )
  end
  
  self.Schedule = self.Schedule or setmetatable( {}, { __mode = "k" } )
  self.Schedule[Scheduler] = self.Schedule[Scheduler] or {}
  self.Schedule[Scheduler][CallID] = {}
  self.Schedule[Scheduler][CallID].Function = ScheduleFunction
  self.Schedule[Scheduler][CallID].Arguments = ScheduleArguments
  self.Schedule[Scheduler][CallID].StartTime = timer.getTime() + ( Start or 0 )
  self.Schedule[Scheduler][CallID].Start = Start + .1
  self.Schedule[Scheduler][CallID].Repeat = Repeat or 0
  self.Schedule[Scheduler][CallID].Randomize = Randomize or 0
  self.Schedule[Scheduler][CallID].Stop = Stop

  self:T3( self.Schedule[Scheduler][CallID] )

  self.Schedule[Scheduler][CallID].CallHandler = function( CallID )
    self:F2( CallID )

    local ErrorHandler = function( errmsg )
      env.info( "Error in timer function: " .. errmsg )
      if debug ~= nil then
        env.info( debug.traceback() )
      end
      return errmsg
    end
    
    local Scheduler = self.ObjectSchedulers[CallID]
    if not Scheduler then
      Scheduler = self.PersistentSchedulers[CallID]
    end
    
    --self:T3( { Scheduler = Scheduler } )
    
    if Scheduler then

      local MasterObject = tostring(Scheduler.MasterObject) 
      local Schedule = self.Schedule[Scheduler][CallID]
      
      --self:T3( { Schedule = Schedule } )

      local ScheduleObject = Scheduler.SchedulerObject
      --local ScheduleObjectName = Scheduler.SchedulerObject:GetNameAndClassID()
      local ScheduleFunction = Schedule.Function
      local ScheduleArguments = Schedule.Arguments
      local Start = Schedule.Start
      local Repeat = Schedule.Repeat or 0
      local Randomize = Schedule.Randomize or 0
      local Stop = Schedule.Stop or 0
      local ScheduleID = Schedule.ScheduleID
      
      local Status, Result
      if ScheduleObject then
        local function Timer()
          return ScheduleFunction( ScheduleObject, unpack( ScheduleArguments ) ) 
        end
        Status, Result = xpcall( Timer, ErrorHandler )
      else
        local function Timer()
          return ScheduleFunction( unpack( ScheduleArguments ) ) 
        end
        Status, Result = xpcall( Timer, ErrorHandler )
      end
      
      local CurrentTime = timer.getTime()
      local StartTime = Schedule.StartTime

      self:F3( { Master = MasterObject, CurrentTime = CurrentTime, StartTime = StartTime, Start = Start, Repeat = Repeat, Randomize = Randomize, Stop = Stop } )
      
      
      if Status and (( Result == nil ) or ( Result and Result ~= false ) ) then
        if Repeat ~= 0 and ( ( Stop == 0 ) or ( Stop ~= 0 and CurrentTime <= StartTime + Stop ) ) then
          local ScheduleTime =
            CurrentTime +
            Repeat +
            math.random(
              - ( Randomize * Repeat / 2 ),
              ( Randomize * Repeat  / 2 )
            ) +
            0.01
          --self:T3( { Repeat = CallID, CurrentTime, ScheduleTime, ScheduleArguments } )
          return ScheduleTime -- returns the next time the function needs to be called.
        else
          self:Stop( Scheduler, CallID )
        end
      else
        self:Stop( Scheduler, CallID )
      end
    else
      self:E( "Scheduled obsolete call for CallID: " .. CallID )
    end
    
    return nil
  end
  
  self:Start( Scheduler, CallID )
  
  return CallID
end

function SCHEDULEDISPATCHER:RemoveSchedule( Scheduler, CallID )
  self:F2( { Remove = CallID, Scheduler = Scheduler } )

  if CallID then
    self:Stop( Scheduler, CallID )
    self.Schedule[Scheduler][CallID] = nil
  end
end

function SCHEDULEDISPATCHER:Start( Scheduler, CallID )
  self:F2( { Start = CallID, Scheduler = Scheduler } )

  if CallID then
    local Schedule = self.Schedule[Scheduler]
    -- Only start when there is no ScheduleID defined!
    -- This prevents to "Start" the scheduler twice with the same CallID...
    if not Schedule[CallID].ScheduleID then
      Schedule[CallID].StartTime = timer.getTime()  -- Set the StartTime field to indicate when the scheduler started.
      Schedule[CallID].ScheduleID = timer.scheduleFunction( 
        Schedule[CallID].CallHandler, 
        CallID, 
        timer.getTime() + Schedule[CallID].Start 
      )
    end
  else
    for CallID, Schedule in pairs( self.Schedule[Scheduler] or {} ) do
      self:Start( Scheduler, CallID ) -- Recursive
    end
  end
end

function SCHEDULEDISPATCHER:Stop( Scheduler, CallID )
  self:F2( { Stop = CallID, Scheduler = Scheduler } )

  if CallID then
    local Schedule = self.Schedule[Scheduler]
    -- Only stop when there is a ScheduleID defined for the CallID.
    -- So, when the scheduler was stopped before, do nothing.
    if Schedule[CallID].ScheduleID then
      timer.removeFunction( Schedule[CallID].ScheduleID )
      Schedule[CallID].ScheduleID = nil
    end
  else
    for CallID, Schedule in pairs( self.Schedule[Scheduler] or {} ) do
      self:Stop( Scheduler, CallID ) -- Recursive
    end
  end
end

function SCHEDULEDISPATCHER:Clear( Scheduler )
  self:F2( { Scheduler = Scheduler } )

  for CallID, Schedule in pairs( self.Schedule[Scheduler] or {} ) do
    self:Stop( Scheduler, CallID ) -- Recursive
  end
end



--- **Core** -- EVENT models DCS **event dispatching** using a **publish-subscribe** model.
-- 
-- ![Banner Image](..\Presentations\EVENT\Dia1.JPG)
-- 
-- ===
-- 
-- # 1) Event Handling Overview
-- 
-- ![Objects](..\Presentations\EVENT\Dia2.JPG)
-- 
-- Within a running mission, various DCS events occur. Units are dynamically created, crash, die, shoot stuff, get hit etc.
-- This module provides a mechanism to dispatch those events occuring within your running mission, to the different objects orchestrating your mission.
-- 
-- ![Objects](..\Presentations\EVENT\Dia3.JPG)
-- 
-- Objects can subscribe to different events. The Event dispatcher will publish the received DCS events to the subscribed MOOSE objects, in a specified order.
-- In this way, the subscribed MOOSE objects are kept in sync with your evolving running mission.
-- 
-- ## 1.1) Event Dispatching
-- 
-- ![Objects](..\Presentations\EVENT\Dia4.JPG)
-- 
-- The _EVENTDISPATCHER object is automatically created within MOOSE, 
-- and handles the dispatching of DCS Events occurring 
-- in the simulator to the subscribed objects 
-- in the correct processing order.
--
-- ![Objects](..\Presentations\EVENT\Dia5.JPG)
-- 
-- There are 5 levels of kind of objects that the _EVENTDISPATCHER services:
-- 
--  * _DATABASE object: The core of the MOOSE objects. Any object that is created, deleted or updated, is done in this database.
--  * SET_ derived classes: Subsets of the _DATABASE object. These subsets are updated by the _EVENTDISPATCHER as the second priority.
--  * UNIT objects: UNIT objects can subscribe to DCS events. Each DCS event will be directly published to teh subscribed UNIT object.
--  * GROUP objects: GROUP objects can subscribe to DCS events. Each DCS event will be directly published to the subscribed GROUP object.
--  * Any other object: Various other objects can subscribe to DCS events. Each DCS event triggered will be published to each subscribed object.
-- 
-- ![Objects](..\Presentations\EVENT\Dia6.JPG)
-- 
-- For most DCS events, the above order of updating will be followed.
-- 
-- ![Objects](..\Presentations\EVENT\Dia7.JPG)
-- 
-- But for some DCS events, the publishing order is reversed. This is due to the fact that objects need to be **erased** instead of added.
-- 
-- ## 1.2) Event Handling
-- 
-- ![Objects](..\Presentations\EVENT\Dia8.JPG)
-- 
-- The actual event subscribing and handling is not facilitated through the _EVENTDISPATCHER, but it is done through the @{BASE} class, @{UNIT} class and @{GROUP} class.
-- The _EVENTDISPATCHER is a component that is quietly working in the background of MOOSE.
-- 
-- ![Objects](..\Presentations\EVENT\Dia9.JPG)
-- 
-- The BASE class provides methods to catch DCS Events. These are events that are triggered from within the DCS simulator, 
-- and handled through lua scripting. MOOSE provides an encapsulation to handle these events more efficiently.
-- 
-- ### 1.2.1 Subscribe / Unsubscribe to DCS Events
-- 
-- At first, the mission designer will need to **Subscribe** to a specific DCS event for the class.
-- So, when the DCS event occurs, the class will be notified of that event.
-- There are two functions which you use to subscribe to or unsubscribe from an event.
-- 
--   * @{Base#BASE.HandleEvent}(): Subscribe to a DCS Event.
--   * @{Base#BASE.UnHandleEvent}(): Unsubscribe from a DCS Event.
--   
-- Note that for a UNIT, the event will be handled **for that UNIT only**!
-- Note that for a GROUP, the event will be handled **for all the UNITs in that GROUP only**!
-- 
-- For all objects of other classes, the subscribed events will be handled for **all UNITs within the Mission**!
-- So if a UNIT within the mission has the subscribed event for that object, 
-- then the object event handler will receive the event for that UNIT!
-- 
-- ### 1.3.2 Event Handling of DCS Events
-- 
-- Once the class is subscribed to the event, an **Event Handling** method on the object or class needs to be written that will be called
-- when the DCS event occurs. The Event Handling method receives an @{Event#EVENTDATA} structure, which contains a lot of information
-- about the event that occurred.
-- 
-- Find below an example of the prototype how to write an event handling function for two units: 
--
--      local Tank1 = UNIT:FindByName( "Tank A" )
--      local Tank2 = UNIT:FindByName( "Tank B" )
--      
--      -- Here we subscribe to the Dead events. So, if one of these tanks dies, the Tank1 or Tank2 objects will be notified.
--      Tank1:HandleEvent( EVENTS.Dead )
--      Tank2:HandleEvent( EVENTS.Dead )
--      
--      --- This function is an Event Handling function that will be called when Tank1 is Dead.
--      -- @param Wrapper.Unit#UNIT self 
--      -- @param Core.Event#EVENTDATA EventData
--      function Tank1:OnEventDead( EventData )
--
--        self:SmokeGreen()
--      end
--
--      --- This function is an Event Handling function that will be called when Tank2 is Dead.
--      -- @param Wrapper.Unit#UNIT self 
--      -- @param Core.Event#EVENTDATA EventData
--      function Tank2:OnEventDead( EventData )
--
--        self:SmokeBlue()
--      end
-- 
-- ### 1.3.3 Event Handling methods that are automatically called upon subscribed DCS events
-- 
-- ![Objects](..\Presentations\EVENT\Dia10.JPG)
-- 
-- The following list outlines which EVENTS item in the structure corresponds to which Event Handling method.
-- Always ensure that your event handling methods align with the events being subscribed to, or nothing will be executed.
-- 
-- # 2) EVENTS type
-- 
-- The EVENTS structure contains names for all the different DCS events that objects can subscribe to using the 
-- @{Base#BASE.HandleEvent}() method.
-- 
-- # 3) EVENTDATA type
-- 
-- The @{Event#EVENTDATA} structure contains all the fields that are populated with event information before 
-- an Event Handler method is being called by the event dispatcher.
-- The Event Handler received the EVENTDATA object as a parameter, and can be used to investigate further the different events.
-- There are basically 4 main categories of information stored in the EVENTDATA structure:
-- 
--    * Initiator Unit data: Several fields documenting the initiator unit related to the event.
--    * Target Unit data: Several fields documenting the target unit related to the event.
--    * Weapon data: Certain events populate weapon information.
--    * Place data: Certain events populate place information.
-- 
--      --- This function is an Event Handling function that will be called when Tank1 is Dead.
--      -- EventData is an EVENTDATA structure.
--      -- We use the EventData.IniUnit to smoke the tank Green.
--      -- @param Wrapper.Unit#UNIT self 
--      -- @param Core.Event#EVENTDATA EventData
--      function Tank1:OnEventDead( EventData )
--
--        EventData.IniUnit:SmokeGreen()
--      end
-- 
-- 
-- Find below an overview which events populate which information categories:
-- 
-- ![Objects](..\Presentations\EVENT\Dia14.JPG)
-- 
-- **IMPORTANT NOTE:** Some events can involve not just UNIT objects, but also STATIC objects!!! 
-- In that case the initiator or target unit fields will refer to a STATIC object!
-- In case a STATIC object is involved, the documentation indicates which fields will and won't not be populated.
-- The fields **IniObjectCategory** and **TgtObjectCategory** contain the indicator which **kind of object is involved** in the event.
-- You can use the enumerator **Object.Category.UNIT** and **Object.Category.STATIC** to check on IniObjectCategory and TgtObjectCategory.
-- Example code snippet:
--      
--      if Event.IniObjectCategory == Object.Category.UNIT then
--       ...
--      end
--      if Event.IniObjectCategory == Object.Category.STATIC then
--       ...
--      end 
-- 
-- When a static object is involved in the event, the Group and Player fields won't be populated.
-- 
-- ===
-- 
-- ### Author: **Sven Van de Velde (FlightControl)**
-- ### Contributions: 
-- 
-- ====
--
-- @module Event


--- The EVENT structure
-- @type EVENT
-- @field #EVENT.Events Events
-- @extends Core.Base#BASE
EVENT = {
  ClassName = "EVENT",
  ClassID = 0,
}

world.event.S_EVENT_NEW_CARGO = world.event.S_EVENT_MAX + 1000
world.event.S_EVENT_DELETE_CARGO = world.event.S_EVENT_MAX + 1001

--- The different types of events supported by MOOSE.
-- Use this structure to subscribe to events using the @{Base#BASE.HandleEvent}() method.
-- @type EVENTS
EVENTS = {
  Shot =              world.event.S_EVENT_SHOT,
  Hit =               world.event.S_EVENT_HIT,
  Takeoff =           world.event.S_EVENT_TAKEOFF,
  Land =              world.event.S_EVENT_LAND,
  Crash =             world.event.S_EVENT_CRASH,
  Ejection =          world.event.S_EVENT_EJECTION,
  Refueling =         world.event.S_EVENT_REFUELING,
  Dead =              world.event.S_EVENT_DEAD,
  PilotDead =         world.event.S_EVENT_PILOT_DEAD,
  BaseCaptured =      world.event.S_EVENT_BASE_CAPTURED,
  MissionStart =      world.event.S_EVENT_MISSION_START,
  MissionEnd =        world.event.S_EVENT_MISSION_END,
  TookControl =       world.event.S_EVENT_TOOK_CONTROL,
  RefuelingStop =     world.event.S_EVENT_REFUELING_STOP,
  Birth =             world.event.S_EVENT_BIRTH,
  HumanFailure =      world.event.S_EVENT_HUMAN_FAILURE,
  EngineStartup =     world.event.S_EVENT_ENGINE_STARTUP,
  EngineShutdown =    world.event.S_EVENT_ENGINE_SHUTDOWN,
  PlayerEnterUnit =   world.event.S_EVENT_PLAYER_ENTER_UNIT,
  PlayerLeaveUnit =   world.event.S_EVENT_PLAYER_LEAVE_UNIT,
  PlayerComment =     world.event.S_EVENT_PLAYER_COMMENT,
  ShootingStart =     world.event.S_EVENT_SHOOTING_START,
  ShootingEnd =       world.event.S_EVENT_SHOOTING_END,
  NewCargo =          world.event.S_EVENT_NEW_CARGO,
  DeleteCargo =       world.event.S_EVENT_DELETE_CARGO,
}

--- The Event structure
-- Note that at the beginning of each field description, there is an indication which field will be populated depending on the object type involved in the Event:
--   
--   * A (Object.Category.)UNIT : A UNIT object type is involved in the Event.
--   * A (Object.Category.)STATIC : A STATIC object type is involved in the Event.µ
--   
-- @type EVENTDATA
-- @field #number id The identifier of the event.
-- 
-- @field Dcs.DCSUnit#Unit initiator (UNIT/STATIC/SCENERY) The initiating @{Dcs.DCSUnit#Unit} or @{Dcs.DCSStaticObject#StaticObject}.
-- @field Dcs.DCSObject#Object.Category IniObjectCategory (UNIT/STATIC/SCENERY) The initiator object category ( Object.Category.UNIT or Object.Category.STATIC ).
-- @field Dcs.DCSUnit#Unit IniDCSUnit (UNIT/STATIC) The initiating @{DCSUnit#Unit} or @{DCSStaticObject#StaticObject}.
-- @field #string IniDCSUnitName (UNIT/STATIC) The initiating Unit name.
-- @field Wrapper.Unit#UNIT IniUnit (UNIT/STATIC) The initiating MOOSE wrapper @{Unit#UNIT} of the initiator Unit object.
-- @field #string IniUnitName (UNIT/STATIC) The initiating UNIT name (same as IniDCSUnitName).
-- @field Dcs.DCSGroup#Group IniDCSGroup (UNIT) The initiating {DCSGroup#Group}.
-- @field #string IniDCSGroupName (UNIT) The initiating Group name.
-- @field Wrapper.Group#GROUP IniGroup (UNIT) The initiating MOOSE wrapper @{Group#GROUP} of the initiator Group object.
-- @field #string IniGroupName UNIT) The initiating GROUP name (same as IniDCSGroupName).
-- @field #string IniPlayerName (UNIT) The name of the initiating player in case the Unit is a client or player slot.
-- @field Dcs.DCScoalition#coalition.side IniCoalition (UNIT) The coalition of the initiator.
-- @field Dcs.DCSUnit#Unit.Category IniCategory (UNIT) The category of the initiator.
-- @field #string IniTypeName (UNIT) The type name of the initiator.
-- 
-- @field Dcs.DCSUnit#Unit target (UNIT/STATIC) The target @{Dcs.DCSUnit#Unit} or @{DCSStaticObject#StaticObject}.
-- @field Dcs.DCSObject#Object.Category TgtObjectCategory (UNIT/STATIC) The target object category ( Object.Category.UNIT or Object.Category.STATIC ).
-- @field Dcs.DCSUnit#Unit TgtDCSUnit (UNIT/STATIC) The target @{DCSUnit#Unit} or @{DCSStaticObject#StaticObject}.
-- @field #string TgtDCSUnitName (UNIT/STATIC) The target Unit name.
-- @field Wrapper.Unit#UNIT TgtUnit (UNIT/STATIC) The target MOOSE wrapper @{Unit#UNIT} of the target Unit object.
-- @field #string TgtUnitName (UNIT/STATIC) The target UNIT name (same as TgtDCSUnitName).
-- @field Dcs.DCSGroup#Group TgtDCSGroup (UNIT) The target {DCSGroup#Group}.
-- @field #string TgtDCSGroupName (UNIT) The target Group name.
-- @field Wrapper.Group#GROUP TgtGroup (UNIT) The target MOOSE wrapper @{Group#GROUP} of the target Group object.
-- @field #string TgtGroupName (UNIT) The target GROUP name (same as TgtDCSGroupName).
-- @field #string TgtPlayerName (UNIT) The name of the target player in case the Unit is a client or player slot.
-- @field Dcs.DCScoalition#coalition.side TgtCoalition (UNIT) The coalition of the target.
-- @field Dcs.DCSUnit#Unit.Category TgtCategory (UNIT) The category of the target.
-- @field #string TgtTypeName (UNIT) The type name of the target.
-- 
-- @field weapon The weapon used during the event.
-- @field Weapon
-- @field WeaponName
-- @field WeaponTgtDCSUnit



local _EVENTMETA = {
   [world.event.S_EVENT_SHOT] = {
     Order = 1,
     Side = "I",
     Event = "OnEventShot",
     Text = "S_EVENT_SHOT" 
   },
   [world.event.S_EVENT_HIT] = {
     Order = 1,
     Side = "T",
     Event = "OnEventHit",
     Text = "S_EVENT_HIT" 
   },
   [world.event.S_EVENT_TAKEOFF] = {
     Order = 1,
     Side = "I",
     Event = "OnEventTakeoff",
     Text = "S_EVENT_TAKEOFF" 
   },
   [world.event.S_EVENT_LAND] = {
     Order = 1,
     Side = "I",
     Event = "OnEventLand",
     Text = "S_EVENT_LAND" 
   },
   [world.event.S_EVENT_CRASH] = {
     Order = -1,
     Side = "I",
     Event = "OnEventCrash",
     Text = "S_EVENT_CRASH" 
   },
   [world.event.S_EVENT_EJECTION] = {
     Order = 1,
     Side = "I",
     Event = "OnEventEjection",
     Text = "S_EVENT_EJECTION" 
   },
   [world.event.S_EVENT_REFUELING] = {
     Order = 1,
     Side = "I",
     Event = "OnEventRefueling",
     Text = "S_EVENT_REFUELING" 
   },
   [world.event.S_EVENT_DEAD] = {
     Order = -1,
     Side = "I",
     Event = "OnEventDead",
     Text = "S_EVENT_DEAD" 
   },
   [world.event.S_EVENT_PILOT_DEAD] = {
     Order = 1,
     Side = "I",
     Event = "OnEventPilotDead",
     Text = "S_EVENT_PILOT_DEAD" 
   },
   [world.event.S_EVENT_BASE_CAPTURED] = {
     Order = 1,
     Side = "I",
     Event = "OnEventBaseCaptured",
     Text = "S_EVENT_BASE_CAPTURED" 
   },
   [world.event.S_EVENT_MISSION_START] = {
     Order = 1,
     Side = "N",
     Event = "OnEventMissionStart",
     Text = "S_EVENT_MISSION_START" 
   },
   [world.event.S_EVENT_MISSION_END] = {
     Order = 1,
     Side = "N",
     Event = "OnEventMissionEnd",
     Text = "S_EVENT_MISSION_END" 
   },
   [world.event.S_EVENT_TOOK_CONTROL] = {
     Order = 1,
     Side = "N",
     Event = "OnEventTookControl",
     Text = "S_EVENT_TOOK_CONTROL" 
   },
   [world.event.S_EVENT_REFUELING_STOP] = {
     Order = 1,
     Side = "I",
     Event = "OnEventRefuelingStop",
     Text = "S_EVENT_REFUELING_STOP" 
   },
   [world.event.S_EVENT_BIRTH] = {
     Order = 1,
     Side = "I",
     Event = "OnEventBirth",
     Text = "S_EVENT_BIRTH" 
   },
   [world.event.S_EVENT_HUMAN_FAILURE] = {
     Order = 1,
     Side = "I",
     Event = "OnEventHumanFailure",
     Text = "S_EVENT_HUMAN_FAILURE" 
   },
   [world.event.S_EVENT_ENGINE_STARTUP] = {
     Order = 1,
     Side = "I",
     Event = "OnEventEngineStartup",
     Text = "S_EVENT_ENGINE_STARTUP" 
   },
   [world.event.S_EVENT_ENGINE_SHUTDOWN] = {
     Order = 1,
     Side = "I",
     Event = "OnEventEngineShutdown",
     Text = "S_EVENT_ENGINE_SHUTDOWN" 
   },
   [world.event.S_EVENT_PLAYER_ENTER_UNIT] = {
     Order = 1,
     Side = "I",
     Event = "OnEventPlayerEnterUnit",
     Text = "S_EVENT_PLAYER_ENTER_UNIT" 
   },
   [world.event.S_EVENT_PLAYER_LEAVE_UNIT] = {
     Order = -1,
     Side = "I",
     Event = "OnEventPlayerLeaveUnit",
     Text = "S_EVENT_PLAYER_LEAVE_UNIT" 
   },
   [world.event.S_EVENT_PLAYER_COMMENT] = {
     Order = 1,
     Side = "I",
     Event = "OnEventPlayerComment",
     Text = "S_EVENT_PLAYER_COMMENT" 
   },
   [world.event.S_EVENT_SHOOTING_START] = {
     Order = 1,
     Side = "I",
     Event = "OnEventShootingStart",
     Text = "S_EVENT_SHOOTING_START" 
   },
   [world.event.S_EVENT_SHOOTING_END] = {
     Order = 1,
     Side = "I",
     Event = "OnEventShootingEnd",
     Text = "S_EVENT_SHOOTING_END" 
   },
   [EVENTS.NewCargo] = {
     Order = 1,
     Event = "OnEventNewCargo",
     Text = "S_EVENT_NEW_CARGO" 
   },
   [EVENTS.DeleteCargo] = {
     Order = 1,
     Event = "OnEventDeleteCargo",
     Text = "S_EVENT_DELETE_CARGO" 
   },
}


--- The Events structure
-- @type EVENT.Events
-- @field #number IniUnit

function EVENT:New()
  local self = BASE:Inherit( self, BASE:New() )
  self:F2()
  self.EventHandler = world.addEventHandler( self )
  return self
end


--- Initializes the Events structure for the event
-- @param #EVENT self
-- @param Dcs.DCSWorld#world.event EventID
-- @param Core.Base#BASE EventClass
-- @return #EVENT.Events
function EVENT:Init( EventID, EventClass )
  self:F3( { _EVENTMETA[EventID].Text, EventClass } )

  if not self.Events[EventID] then 
    -- Create a WEAK table to ensure that the garbage collector is cleaning the event links when the object usage is cleaned.
    self.Events[EventID] = {}
  end
  
  -- Each event has a subtable of EventClasses, ordered by EventPriority.
  local EventPriority = EventClass:GetEventPriority()
  if not self.Events[EventID][EventPriority] then
    self.Events[EventID][EventPriority] = setmetatable( {}, { __mode = "k" } )
  end 

  if not self.Events[EventID][EventPriority][EventClass] then
     self.Events[EventID][EventPriority][EventClass] = {}
  end
  return self.Events[EventID][EventPriority][EventClass]
end

--- Removes a subscription
-- @param #EVENT self
-- @param Core.Base#BASE EventClass The self instance of the class for which the event is.
-- @param Dcs.DCSWorld#world.event EventID
-- @return #EVENT.Events
function EVENT:RemoveEvent( EventClass, EventID  )

  self:F2( { "Removing subscription for class: ", EventClass:GetClassNameAndID() } )

  local EventPriority = EventClass:GetEventPriority()

  self.Events = self.Events or {}
  self.Events[EventID] = self.Events[EventID] or {}
  self.Events[EventID][EventPriority] = self.Events[EventID][EventPriority] or {}  
  self.Events[EventID][EventPriority][EventClass] = self.Events[EventID][EventPriority][EventClass]
    
  self.Events[EventID][EventPriority][EventClass] = nil
  
end

--- Resets subscriptions
-- @param #EVENT self
-- @param Core.Base#BASE EventClass The self instance of the class for which the event is.
-- @param Dcs.DCSWorld#world.event EventID
-- @return #EVENT.Events
function EVENT:Reset( EventObject ) --R2.1

  self:E( { "Resetting subscriptions for class: ", EventObject:GetClassNameAndID() } )

  local EventPriority = EventObject:GetEventPriority()
  for EventID, EventData in pairs( self.Events ) do
    if self.EventsDead then
      if self.EventsDead[EventID] then
        if self.EventsDead[EventID][EventPriority] then
          if self.EventsDead[EventID][EventPriority][EventObject] then
            self.Events[EventID][EventPriority][EventObject] = self.EventsDead[EventID][EventPriority][EventObject]
          end
        end
      end
    end
  end
end




--- Clears all event subscriptions for a @{Base#BASE} derived object.
-- @param #EVENT self
-- @param Core.Base#BASE EventObject
function EVENT:RemoveAll( EventObject  )
  self:F3( { EventObject:GetClassNameAndID() } )

  local EventClass = EventObject:GetClassNameAndID()
  local EventPriority = EventClass:GetEventPriority()
  for EventID, EventData in pairs( self.Events ) do
    self.Events[EventID][EventPriority][EventClass] = nil
  end
end



--- Create an OnDead event handler for a group
-- @param #EVENT self
-- @param #table EventTemplate
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @param EventClass The instance of the class for which the event is.
-- @param #function OnEventFunction
-- @return #EVENT
function EVENT:OnEventForTemplate( EventTemplate, EventFunction, EventClass, EventID )
  self:F2( EventTemplate.name )

  for EventUnitID, EventUnit in pairs( EventTemplate.units ) do
    self:OnEventForUnit( EventUnit.name, EventFunction, EventClass, EventID )
  end
  return self
end

--- Set a new listener for an S_EVENT_X event independent from a unit or a weapon.
-- @param #EVENT self
-- @param #function EventFunction The function to be called when the event occurs for the unit.
-- @param Core.Base#BASE EventClass The self instance of the class for which the event is captured. When the event happens, the event process will be called in this class provided.
-- @param EventID
-- @return #EVENT
function EVENT:OnEventGeneric( EventFunction, EventClass, EventID )
  self:F2( { EventID } )

  local EventData = self:Init( EventID, EventClass )
  EventData.EventFunction = EventFunction
  
  return self
end


--- Set a new listener for an S_EVENT_X event for a UNIT.
-- @param #EVENT self
-- @param #string UnitName The name of the UNIT.
-- @param #function EventFunction The function to be called when the event occurs for the GROUP.
-- @param Core.Base#BASE EventClass The self instance of the class for which the event is.
-- @param EventID
-- @return #EVENT
function EVENT:OnEventForUnit( UnitName, EventFunction, EventClass, EventID )
  self:F2( UnitName )

  local EventData = self:Init( EventID, EventClass )
  EventData.EventUnit = true
  EventData.EventFunction = EventFunction
  return self
end

--- Set a new listener for an S_EVENT_X event for a GROUP.
-- @param #EVENT self
-- @param #string GroupName The name of the GROUP.
-- @param #function EventFunction The function to be called when the event occurs for the GROUP.
-- @param Core.Base#BASE EventClass The self instance of the class for which the event is.
-- @param EventID
-- @return #EVENT
function EVENT:OnEventForGroup( GroupName, EventFunction, EventClass, EventID, ... )
  self:E( GroupName )

  local Event = self:Init( EventID, EventClass )
  Event.EventGroup = true
  Event.EventFunction = EventFunction
  Event.Params = arg
  return self
end

do -- OnBirth

  --- Create an OnBirth event handler for a group
  -- @param #EVENT self
  -- @param Wrapper.Group#GROUP EventGroup
  -- @param #function EventFunction The function to be called when the event occurs for the unit.
  -- @param EventClass The self instance of the class for which the event is.
  -- @return #EVENT
  function EVENT:OnBirthForTemplate( EventTemplate, EventFunction, EventClass )
    self:F2( EventTemplate.name )
  
    self:OnEventForTemplate( EventTemplate, EventFunction, EventClass, EVENTS.Birth )
    
    return self
  end
  
end

do -- OnCrash

  --- Create an OnCrash event handler for a group
  -- @param #EVENT self
  -- @param Wrapper.Group#GROUP EventGroup
  -- @param #function EventFunction The function to be called when the event occurs for the unit.
  -- @param EventClass The self instance of the class for which the event is.
  -- @return #EVENT
  function EVENT:OnCrashForTemplate( EventTemplate, EventFunction, EventClass )
    self:F2( EventTemplate.name )
  
    self:OnEventForTemplate( EventTemplate, EventFunction, EventClass, EVENTS.Crash )
  
    return self
  end

end

do -- OnDead
 
  --- Create an OnDead event handler for a group
  -- @param #EVENT self
  -- @param Wrapper.Group#GROUP EventGroup
  -- @param #function EventFunction The function to be called when the event occurs for the unit.
  -- @param EventClass The self instance of the class for which the event is.
  -- @return #EVENT
  function EVENT:OnDeadForTemplate( EventTemplate, EventFunction, EventClass )
    self:F2( EventTemplate.name )
    
    self:OnEventForTemplate( EventTemplate, EventFunction, EventClass, EVENTS.Dead )
  
    return self
  end
  
end


do -- OnLand
  --- Create an OnLand event handler for a group
  -- @param #EVENT self
  -- @param #table EventTemplate
  -- @param #function EventFunction The function to be called when the event occurs for the unit.
  -- @param EventClass The self instance of the class for which the event is.
  -- @return #EVENT
  function EVENT:OnLandForTemplate( EventTemplate, EventFunction, EventClass )
    self:F2( EventTemplate.name )
  
    self:OnEventForTemplate( EventTemplate, EventFunction, EventClass, EVENTS.Land )
    
    return self
  end
  
end

do -- OnTakeOff
  --- Create an OnTakeOff event handler for a group
  -- @param #EVENT self
  -- @param #table EventTemplate
  -- @param #function EventFunction The function to be called when the event occurs for the unit.
  -- @param EventClass The self instance of the class for which the event is.
  -- @return #EVENT
  function EVENT:OnTakeOffForTemplate( EventTemplate, EventFunction, EventClass )
    self:F2( EventTemplate.name )
  
    self:OnEventForTemplate( EventTemplate, EventFunction, EventClass, EVENTS.Takeoff )
  
    return self
  end
  
end

do -- OnEngineShutDown

  --- Create an OnDead event handler for a group
  -- @param #EVENT self
  -- @param #table EventTemplate
  -- @param #function EventFunction The function to be called when the event occurs for the unit.
  -- @param EventClass The self instance of the class for which the event is.
  -- @return #EVENT
  function EVENT:OnEngineShutDownForTemplate( EventTemplate, EventFunction, EventClass )
    self:F2( EventTemplate.name )
  
    self:OnEventForTemplate( EventTemplate, EventFunction, EventClass, EVENTS.EngineShutdown )
    
    return self
  end
  
end

do -- Event Creation

  --- Creation of a New Cargo Event.
  -- @param #EVENT self
  -- @param AI.AI_Cargo#AI_CARGO Cargo The Cargo created.
  function EVENT:CreateEventNewCargo( Cargo )
    self:F( { Cargo } )
  
    local Event = {
      id = EVENTS.NewCargo,
      time = timer.getTime(),
      cargo = Cargo,
      }
  
    world.onEvent( Event )
  end

  --- Creation of a Cargo Deletion Event.
  -- @param #EVENT self
  -- @param AI.AI_Cargo#AI_CARGO Cargo The Cargo created.
  function EVENT:CreateEventDeleteCargo( Cargo )
    self:F( { Cargo } )
  
    local Event = {
      id = EVENTS.DeleteCargo,
      time = timer.getTime(),
      cargo = Cargo,
      }
  
    world.onEvent( Event )
  end

  --- Creation of a S_EVENT_PLAYER_ENTER_UNIT Event.
  -- @param #EVENT self
  -- @param Wrapper.Unit#UNIT PlayerUnit.
  function EVENT:CreateEventPlayerEnterUnit( PlayerUnit )
    self:F( { PlayerUnit } )
  
    local Event = {
      id = EVENTS.PlayerEnterUnit,
      time = timer.getTime(),
      initiator = PlayerUnit:GetDCSObject()
      }
  
    world.onEvent( Event )
  end

end

--- @param #EVENT self
-- @param #EVENTDATA Event
function EVENT:onEvent( Event )

  local ErrorHandler = function( errmsg )

    env.info( "Error in SCHEDULER function:" .. errmsg )
    if debug ~= nil then
      env.info( debug.traceback() )
    end
    
    return errmsg
  end


  local EventMeta = _EVENTMETA[Event.id]

  if self and 
     self.Events and 
     self.Events[Event.id] and
     ( Event.initiator ~= nil or ( Event.initiator == nil and Event.id ~= EVENTS.PlayerLeaveUnit ) ) then

    if Event.initiator then    

      Event.IniObjectCategory = Event.initiator:getCategory()

      if Event.IniObjectCategory == Object.Category.UNIT then
        Event.IniDCSUnit = Event.initiator
        Event.IniDCSUnitName = Event.IniDCSUnit:getName()
        Event.IniUnitName = Event.IniDCSUnitName
        Event.IniDCSGroup = Event.IniDCSUnit:getGroup()
        Event.IniUnit = UNIT:FindByName( Event.IniDCSUnitName )
        if not Event.IniUnit then
          -- Unit can be a CLIENT. Most likely this will be the case ...
          Event.IniUnit = CLIENT:FindByName( Event.IniDCSUnitName, '', true )
        end
        Event.IniDCSGroupName = ""
        if Event.IniDCSGroup and Event.IniDCSGroup:isExist() then
          Event.IniDCSGroupName = Event.IniDCSGroup:getName()
          Event.IniGroup = GROUP:FindByName( Event.IniDCSGroupName )
          if Event.IniGroup then
            Event.IniGroupName = Event.IniDCSGroupName
          end
        end
        Event.IniPlayerName = Event.IniDCSUnit:getPlayerName()
        Event.IniCoalition = Event.IniDCSUnit:getCoalition()
        Event.IniTypeName = Event.IniDCSUnit:getTypeName()
        Event.IniCategory = Event.IniDCSUnit:getDesc().category
      end
      
      if Event.IniObjectCategory == Object.Category.STATIC then
        Event.IniDCSUnit = Event.initiator
        Event.IniDCSUnitName = Event.IniDCSUnit:getName()
        Event.IniUnitName = Event.IniDCSUnitName
        Event.IniUnit = STATIC:FindByName( Event.IniDCSUnitName, false )
        Event.IniCoalition = Event.IniDCSUnit:getCoalition()
        Event.IniCategory = Event.IniDCSUnit:getDesc().category
        Event.IniTypeName = Event.IniDCSUnit:getTypeName()
      end

      if Event.IniObjectCategory == Object.Category.SCENERY then
        Event.IniDCSUnit = Event.initiator
        Event.IniDCSUnitName = Event.IniDCSUnit:getName()
        Event.IniUnitName = Event.IniDCSUnitName
        Event.IniUnit = SCENERY:Register( Event.IniDCSUnitName, Event.initiator )
        Event.IniCategory = Event.IniDCSUnit:getDesc().category
        Event.IniTypeName = Event.initiator:isExist() and Event.IniDCSUnit:getTypeName() or "SCENERY" -- TODO: Bug fix for 2.1!
      end
    end
    
    if Event.target then

      Event.TgtObjectCategory = Event.target:getCategory()

      if Event.TgtObjectCategory == Object.Category.UNIT then 
        Event.TgtDCSUnit = Event.target
        Event.TgtDCSGroup = Event.TgtDCSUnit:getGroup()
        Event.TgtDCSUnitName = Event.TgtDCSUnit:getName()
        Event.TgtUnitName = Event.TgtDCSUnitName
        Event.TgtUnit = UNIT:FindByName( Event.TgtDCSUnitName )
        Event.TgtDCSGroupName = ""
        if Event.TgtDCSGroup and Event.TgtDCSGroup:isExist() then
          Event.TgtDCSGroupName = Event.TgtDCSGroup:getName()
          Event.TgtGroup = GROUP:FindByName( Event.TgtDCSGroupName )
          if Event.TgtGroup then
            Event.TgtGroupName = Event.TgtDCSGroupName
          end
        end
        Event.TgtPlayerName = Event.TgtDCSUnit:getPlayerName()
        Event.TgtCoalition = Event.TgtDCSUnit:getCoalition()
        Event.TgtCategory = Event.TgtDCSUnit:getDesc().category
        Event.TgtTypeName = Event.TgtDCSUnit:getTypeName()
      end
      
      if Event.TgtObjectCategory == Object.Category.STATIC then
        Event.TgtDCSUnit = Event.target
        Event.TgtDCSUnitName = Event.TgtDCSUnit:getName()
        Event.TgtUnitName = Event.TgtDCSUnitName
        Event.TgtUnit = STATIC:FindByName( Event.TgtDCSUnitName )
        Event.TgtCoalition = Event.TgtDCSUnit:getCoalition()
        Event.TgtCategory = Event.TgtDCSUnit:getDesc().category
        Event.TgtTypeName = Event.TgtDCSUnit:getTypeName()
      end

      if Event.TgtObjectCategory == Object.Category.SCENERY then
        Event.TgtDCSUnit = Event.target
        Event.TgtDCSUnitName = Event.TgtDCSUnit:getName()
        Event.TgtUnitName = Event.TgtDCSUnitName
        Event.TgtUnit = SCENERY:Register( Event.TgtDCSUnitName, Event.target )
        Event.TgtCategory = Event.TgtDCSUnit:getDesc().category
        Event.TgtTypeName = Event.TgtDCSUnit:getTypeName()
      end
    end
    
    if Event.weapon then
      Event.Weapon = Event.weapon
      Event.WeaponName = Event.Weapon:getTypeName()
      Event.WeaponUNIT = CLIENT:Find( Event.Weapon, '', true ) -- Sometimes, the weapon is a player unit!
      Event.WeaponPlayerName = Event.WeaponUNIT and Event.Weapon:getPlayerName()
      Event.WeaponCoalition = Event.WeaponUNIT and Event.Weapon:getCoalition()
      Event.WeaponCategory = Event.WeaponUNIT and Event.Weapon:getDesc().category
      Event.WeaponTypeName = Event.WeaponUNIT and Event.Weapon:getTypeName()
      --Event.WeaponTgtDCSUnit = Event.Weapon:getTarget()
    end
    
    if Event.cargo then
      Event.Cargo = Event.cargo
      Event.CargoName = Event.cargo.Name
    end
    
    local PriorityOrder = EventMeta.Order
    local PriorityBegin = PriorityOrder == -1 and 5 or 1
    local PriorityEnd = PriorityOrder == -1 and 1 or 5

    if Event.IniObjectCategory ~= Object.Category.STATIC then
      self:E( { EventMeta.Text, Event, Event.IniDCSUnitName, Event.TgtDCSUnitName, PriorityOrder } )
    end
    
    for EventPriority = PriorityBegin, PriorityEnd, PriorityOrder do
    
      if self.Events[Event.id][EventPriority] then
      
        -- Okay, we got the event from DCS. Now loop the SORTED self.EventSorted[] table for the received Event.id, and for each EventData registered, check if a function needs to be called.
        for EventClass, EventData in pairs( self.Events[Event.id][EventPriority] ) do

          --if Event.IniObjectCategory ~= Object.Category.STATIC then
          --  self:E( { "Evaluating: ", EventClass:GetClassNameAndID() } )
          --end
          
          Event.IniGroup = GROUP:FindByName( Event.IniDCSGroupName )
          Event.TgtGroup = GROUP:FindByName( Event.TgtDCSGroupName )
        
          -- If the EventData is for a UNIT, the call directly the EventClass EventFunction for that UNIT.
          if EventData.EventUnit then

            -- So now the EventClass must be a UNIT class!!! We check if it is still "Alive".
            if EventClass:IsAlive() or
               Event.id == EVENTS.Crash or 
               Event.id == EVENTS.Dead then
            
              local UnitName = EventClass:GetName()

              if ( EventMeta.Side == "I" and UnitName == Event.IniDCSUnitName ) or 
                 ( EventMeta.Side == "T" and UnitName == Event.TgtDCSUnitName ) then
                 
                -- First test if a EventFunction is Set, otherwise search for the default function
                if EventData.EventFunction then
              
                  if Event.IniObjectCategory ~= 3 then
                    self:E( { "Calling EventFunction for UNIT ", EventClass:GetClassNameAndID(), ", Unit ", Event.IniUnitName, EventPriority } )
                  end
                                  
                  local Result, Value = xpcall( 
                    function() 
                      return EventData.EventFunction( EventClass, Event ) 
                    end, ErrorHandler )
    
                else
    
                  -- There is no EventFunction defined, so try to find if a default OnEvent function is defined on the object.
                  local EventFunction = EventClass[ EventMeta.Event ]
                  if EventFunction and type( EventFunction ) == "function" then
                    
                    -- Now call the default event function.
                    if Event.IniObjectCategory ~= 3 then
                      self:E( { "Calling " .. EventMeta.Event .. " for Class ", EventClass:GetClassNameAndID(), EventPriority } )
                    end
                                  
                    local Result, Value = xpcall( 
                      function() 
                        return EventFunction( EventClass, Event ) 
                      end, ErrorHandler )
                  end
                end
              end
            else
              -- The EventClass is not alive anymore, we remove it from the EventHandlers...
              self:RemoveEvent( EventClass, Event.id )
            end                      
          else

            -- If the EventData is for a GROUP, the call directly the EventClass EventFunction for the UNIT in that GROUP.
            if EventData.EventGroup then

              -- So now the EventClass must be a GROUP class!!! We check if it is still "Alive".
              if EventClass:IsAlive() or
                 Event.id == EVENTS.Crash or
                 Event.id == EVENTS.Dead then

                -- We can get the name of the EventClass, which is now always a GROUP object.
                local GroupName = EventClass:GetName()
  
                if ( EventMeta.Side == "I" and GroupName == Event.IniDCSGroupName ) or 
                   ( EventMeta.Side == "T" and GroupName == Event.TgtDCSGroupName ) then

                  -- First test if a EventFunction is Set, otherwise search for the default function
                  if EventData.EventFunction then
    
                    if Event.IniObjectCategory ~= 3 then
                      self:E( { "Calling EventFunction for GROUP ", EventClass:GetClassNameAndID(), ", Unit ", Event.IniUnitName, EventPriority } )
                    end
                                      
                    local Result, Value = xpcall( 
                      function() 
                        return EventData.EventFunction( EventClass, Event, unpack( EventData.Params ) ) 
                      end, ErrorHandler )
      
                  else
      
                    -- There is no EventFunction defined, so try to find if a default OnEvent function is defined on the object.
                    local EventFunction = EventClass[ EventMeta.Event ]
                    if EventFunction and type( EventFunction ) == "function" then
                      
                      -- Now call the default event function.
                      if Event.IniObjectCategory ~= 3 then
                        self:E( { "Calling " .. EventMeta.Event .. " for GROUP ", EventClass:GetClassNameAndID(), EventPriority } )
                      end
                                          
                      local Result, Value = xpcall( 
                        function() 
                          return EventFunction( EventClass, Event, unpack( EventData.Params ) ) 
                        end, ErrorHandler )
                    end
                  end
                end
              else
                -- The EventClass is not alive anymore, we remove it from the EventHandlers...
                --self:RemoveEvent( EventClass, Event.id )  
              end
            else
          
              -- If the EventData is not bound to a specific unit, then call the EventClass EventFunction.
              -- Note that here the EventFunction will need to implement and determine the logic for the relevant source- or target unit, or weapon.
              if not EventData.EventUnit then
              
                -- First test if a EventFunction is Set, otherwise search for the default function
                if EventData.EventFunction then
                  
                  -- There is an EventFunction defined, so call the EventFunction.
                  if Event.IniObjectCategory ~= 3 then
                    self:F2( { "Calling EventFunction for Class ", EventClass:GetClassNameAndID(), EventPriority } )
                  end                
                  local Result, Value = xpcall( 
                    function() 
                      return EventData.EventFunction( EventClass, Event ) 
                    end, ErrorHandler )
                else
                  
                  -- There is no EventFunction defined, so try to find if a default OnEvent function is defined on the object.
                  local EventFunction = EventClass[ EventMeta.Event ]
                  if EventFunction and type( EventFunction ) == "function" then
                    
                    -- Now call the default event function.
                    if Event.IniObjectCategory ~= 3 then
                      self:F2( { "Calling " .. EventMeta.Event .. " for Class ", EventClass:GetClassNameAndID(), EventPriority } )
                    end
                                  
                    local Result, Value = xpcall( 
                      function() 
                        local Result, Value = EventFunction( EventClass, Event )
                        return Result, Value 
                      end, ErrorHandler )
                  end
                end
              
              end
            end
          end
        end
      end
    end
  else
    self:E( { EventMeta.Text, Event } )    
  end
  
  Event = nil
end

--- The EVENTHANDLER structure
-- @type EVENTHANDLER
-- @extends Core.Base#BASE
EVENTHANDLER = {
  ClassName = "EVENTHANDLER",
  ClassID = 0,
}

--- The EVENTHANDLER constructor
-- @param #EVENTHANDLER self
-- @return #EVENTHANDLER
function EVENTHANDLER:New()
  self = BASE:Inherit( self, BASE:New() ) -- #EVENTHANDLER
  return self
end
--- **Core** -- **SETTINGS** classe defines the format settings management for measurement.
--
-- ![Banner Image](..\Presentations\SETTINGS\Dia1.JPG)
--
-- ====
--
-- # Demo Missions
--
-- ### [SETTINGS Demo Missions source code]()
--
-- ### [SETTINGS Demo Missions, only for beta testers]()
--
-- ### [ALL Demo Missions pack of the last release](https://github.com/FlightControl-Master/MOOSE_MISSIONS/releases)
--
-- ====
--
-- # YouTube Channel
--
-- ### [SETTINGS YouTube Channel]()
--
-- ===
-- 
-- ### Author: **Sven Van de Velde (FlightControl)**
-- ### Contributions: 
-- 
-- ====
--
-- @module Settings


--- @type SETTINGS
-- @field #number LL_Accuracy
-- @field #boolean LL_DMS
-- @field #number MGRS_Accuracy
-- @field #string A2GSystem
-- @field #string A2ASystem
-- @extends Core.Base#BASE

--- # SETTINGS class, extends @{Base#BASE}
--
-- @field #SETTINGS
SETTINGS = {
  ClassName = "SETTINGS",
}



do -- SETTINGS

  --- SETTINGS constructor.
  -- @param #SETTINGS self
  -- @return #SETTINGS
  function SETTINGS:Set( PlayerName ) 

    if PlayerName == nil then
      local self = BASE:Inherit( self, BASE:New() ) -- #SETTINGS
      self:SetMetric() -- Defaults
      self:SetA2G_BR() -- Defaults
      self:SetA2A_BRAA() -- Defaults
      self:SetLL_Accuracy( 3 ) -- Defaults
      self:SetMGRS_Accuracy( 5 ) -- Defaults
      self:SetMessageTime( MESSAGE.Type.Briefing, 180 )
      self:SetMessageTime( MESSAGE.Type.Detailed, 60 )
      self:SetMessageTime( MESSAGE.Type.Information, 30 )
      self:SetMessageTime( MESSAGE.Type.Overview, 60 )
      self:SetMessageTime( MESSAGE.Type.Update, 15 )
      return self
    else
      local Settings = _DATABASE:GetPlayerSettings( PlayerName )
      if not Settings then
        Settings = BASE:Inherit( self, BASE:New() ) -- #SETTINGS
        _DATABASE:SetPlayerSettings( PlayerName, Settings )
      end
      return Settings
    end
  end
  
 
  --- Sets the SETTINGS metric.
  -- @param #SETTINGS self
  function SETTINGS:SetMetric()
    self.Metric = true
  end
 
  --- Gets if the SETTINGS is metric.
  -- @param #SETTINGS self
  -- @return #boolean true if metric.
  function SETTINGS:IsMetric()
    return ( self.Metric ~= nil and self.Metric == true ) or ( self.Metric == nil and _SETTINGS:IsMetric() )
  end

  --- Sets the SETTINGS imperial.
  -- @param #SETTINGS self
  function SETTINGS:SetImperial()
    self.Metric = false
  end
 
  --- Gets if the SETTINGS is imperial.
  -- @param #SETTINGS self
  -- @return #boolean true if imperial.
  function SETTINGS:IsImperial()
    return ( self.Metric ~= nil and self.Metric == false ) or ( self.Metric == nil and _SETTINGS:IsMetric() )
  end

  --- Sets the SETTINGS LL accuracy.
  -- @param #SETTINGS self
  -- @param #number LL_Accuracy
  -- @return #SETTINGS
  function SETTINGS:SetLL_Accuracy( LL_Accuracy )
    self.LL_Accuracy = LL_Accuracy
  end

  --- Gets the SETTINGS LL accuracy.
  -- @param #SETTINGS self
  -- @return #number
  function SETTINGS:GetLL_DDM_Accuracy()
    return self.LL_DDM_Accuracy or _SETTINGS:GetLL_DDM_Accuracy()
  end

  --- Sets the SETTINGS MGRS accuracy.
  -- @param #SETTINGS self
  -- @param #number MGRS_Accuracy
  -- @return #SETTINGS
  function SETTINGS:SetMGRS_Accuracy( MGRS_Accuracy )
    self.MGRS_Accuracy = MGRS_Accuracy
  end

  --- Gets the SETTINGS MGRS accuracy.
  -- @param #SETTINGS self
  -- @return #number
  function SETTINGS:GetMGRS_Accuracy()
    return self.MGRS_Accuracy or _SETTINGS:GetMGRS_Accuracy()
  end
  
  --- Sets the SETTINGS Message Display Timing of a MessageType
  -- @param #SETTINGS self
  -- @param Core.Message#MESSAGE MessageType The type of the message.
  -- @param #number MessageTime The display time duration in seconds of the MessageType.
  function SETTINGS:SetMessageTime( MessageType, MessageTime )
    self.MessageTypeTimings = self.MessageTypeTimings or {}
    self.MessageTypeTimings[MessageType] = MessageTime
  end
  
  
  --- Gets the SETTINGS Message Display Timing of a MessageType
  -- @param #SETTINGS self
  -- @param Core.Message#MESSAGE MessageType The type of the message.
  -- @return #number
  function SETTINGS:GetMessageTime( MessageType )
    return ( self.MessageTypeTimings and self.MessageTypeTimings[MessageType] ) or _SETTINGS:GetMessageTime( MessageType )
  end

  --- Sets A2G LL DMS
  -- @param #SETTINGS self
  -- @return #SETTINGS
  function SETTINGS:SetA2G_LL_DMS()
    self.A2GSystem = "LL DMS"
  end

  --- Sets A2G LL DDM
  -- @param #SETTINGS self
  -- @return #SETTINGS
  function SETTINGS:SetA2G_LL_DDM()
    self.A2GSystem = "LL DDM"
  end

  --- Is LL DMS
  -- @param #SETTINGS self
  -- @return #boolean true if LL DMS
  function SETTINGS:IsA2G_LL_DMS()
    return ( self.A2GSystem and self.A2GSystem == "LL DMS" ) or ( not self.A2GSystem and _SETTINGS:IsA2G_LL_DMS() )
  end

  --- Is LL DDM
  -- @param #SETTINGS self
  -- @return #boolean true if LL DDM
  function SETTINGS:IsA2G_LL_DDM()
    return ( self.A2GSystem and self.A2GSystem == "LL DDM" ) or ( not self.A2GSystem and _SETTINGS:IsA2G_LL_DDM() )
  end

  --- Sets A2G MGRS
  -- @param #SETTINGS self
  -- @return #SETTINGS
  function SETTINGS:SetA2G_MGRS()
    self.A2GSystem = "MGRS"
  end

  --- Is MGRS
  -- @param #SETTINGS self
  -- @return #boolean true if MGRS
  function SETTINGS:IsA2G_MGRS()
    return ( self.A2GSystem and self.A2GSystem == "MGRS" ) or ( not self.A2GSystem and _SETTINGS:IsA2G_MGRS() )
  end

  --- Sets A2G BRA
  -- @param #SETTINGS self
  -- @return #SETTINGS
  function SETTINGS:SetA2G_BR()
    self.A2GSystem = "BR"
  end

  --- Is BRA
  -- @param #SETTINGS self
  -- @return #boolean true if BRA
  function SETTINGS:IsA2G_BR()
    return ( self.A2GSystem and self.A2GSystem == "BR" ) or ( not self.A2GSystem and _SETTINGS:IsA2G_BR() )
  end

  --- Sets A2A BRA
  -- @param #SETTINGS self
  -- @return #SETTINGS
  function SETTINGS:SetA2A_BRAA()
    self.A2ASystem = "BRAA"
  end

  --- Is BRA
  -- @param #SETTINGS self
  -- @return #boolean true if BRA
  function SETTINGS:IsA2A_BRAA()
    self:E( { BRA = ( self.A2ASystem and self.A2ASystem == "BRAA" ) or ( not self.A2ASystem and _SETTINGS:IsA2A_BRAA() ) } )
    return ( self.A2ASystem and self.A2ASystem == "BRAA" ) or ( not self.A2ASystem and _SETTINGS:IsA2A_BRAA() )
  end

  --- Sets A2A BULLS
  -- @param #SETTINGS self
  -- @return #SETTINGS
  function SETTINGS:SetA2A_BULLS()
    self.A2ASystem = "BULLS"
  end

  --- Is BULLS
  -- @param #SETTINGS self
  -- @return #boolean true if BULLS
  function SETTINGS:IsA2A_BULLS()
    return ( self.A2ASystem and self.A2ASystem == "BULLS" ) or ( not self.A2ASystem and _SETTINGS:IsA2A_BULLS() )
  end

  --- Sets A2A LL DMS
  -- @param #SETTINGS self
  -- @return #SETTINGS
  function SETTINGS:SetA2A_LL_DMS()
    self.A2ASystem = "LL DMS"
  end

  --- Sets A2A LL DDM
  -- @param #SETTINGS self
  -- @return #SETTINGS
  function SETTINGS:SetA2A_LL_DDM()
    self.A2ASystem = "LL DDM"
  end

  --- Is LL DMS
  -- @param #SETTINGS self
  -- @return #boolean true if LL DMS
  function SETTINGS:IsA2A_LL_DMS()
    return ( self.A2ASystem and self.A2ASystem == "LL DMS" ) or ( not self.A2ASystem and _SETTINGS:IsA2A_LL_DMS() )
  end

  --- Is LL DDM
  -- @param #SETTINGS self
  -- @return #boolean true if LL DDM
  function SETTINGS:IsA2A_LL_DDM()
    return ( self.A2ASystem and self.A2ASystem == "LL DDM" ) or ( not self.A2ASystem and _SETTINGS:IsA2A_LL_DDM() )
  end

  --- Sets A2A MGRS
  -- @param #SETTINGS self
  -- @return #SETTINGS
  function SETTINGS:SetA2A_MGRS()
    self.A2ASystem = "MGRS"
  end

  --- Is MGRS
  -- @param #SETTINGS self
  -- @return #boolean true if MGRS
  function SETTINGS:IsA2A_MGRS()
    return ( self.A2ASystem and self.A2ASystem == "MGRS" ) or ( not self.A2ASystem and _SETTINGS:IsA2A_MGRS() )
  end

  --- @param #SETTINGS self
  -- @return #SETTINGS
  function SETTINGS:SetSystemMenu( MenuGroup, RootMenu )

    local MenuText = "System Settings"
    
    local MenuTime = timer.getTime()
    
    local SettingsMenu = MENU_GROUP:New( MenuGroup, MenuText, RootMenu ):SetTime( MenuTime )

    local A2GCoordinateMenu = MENU_GROUP:New( MenuGroup, "A2G Coordinate System", SettingsMenu ):SetTime( MenuTime )
  
    
    if not self:IsA2G_LL_DMS() then
      MENU_GROUP_COMMAND:New( MenuGroup, "Lat/Lon Degree Min Sec (LL DMS)", A2GCoordinateMenu, self.A2GMenuSystem, self, MenuGroup, RootMenu, "LL DMS" ):SetTime( MenuTime )
    end
    
    if not self:IsA2G_LL_DDM() then
      MENU_GROUP_COMMAND:New( MenuGroup, "Lat/Lon Degree Dec Min (LL DDM)", A2GCoordinateMenu, self.A2GMenuSystem, self, MenuGroup, RootMenu, "LL DDM" ):SetTime( MenuTime )
    end
    
    if self:IsA2G_LL_DDM() then
      MENU_GROUP_COMMAND:New( MenuGroup, "LL DDM Accuracy 1", A2GCoordinateMenu, self.MenuLL_DDM_Accuracy, self, MenuGroup, RootMenu, 1 ):SetTime( MenuTime )
      MENU_GROUP_COMMAND:New( MenuGroup, "LL DDM Accuracy 2", A2GCoordinateMenu, self.MenuLL_DDM_Accuracy, self, MenuGroup, RootMenu, 2 ):SetTime( MenuTime )
      MENU_GROUP_COMMAND:New( MenuGroup, "LL DDM Accuracy 3", A2GCoordinateMenu, self.MenuLL_DDM_Accuracy, self, MenuGroup, RootMenu, 3 ):SetTime( MenuTime )
    end
    
    if not self:IsA2G_BR() then
      MENU_GROUP_COMMAND:New( MenuGroup, "Bearing, Range (BR)", A2GCoordinateMenu, self.A2GMenuSystem, self, MenuGroup, RootMenu, "BR" ):SetTime( MenuTime )
    end
    
    if not self:IsA2G_MGRS() then
      MENU_GROUP_COMMAND:New( MenuGroup, "Military Grid (MGRS)", A2GCoordinateMenu, self.A2GMenuSystem, self, MenuGroup, RootMenu, "MGRS" ):SetTime( MenuTime )
    end
    
    if self:IsA2G_MGRS() then
      MENU_GROUP_COMMAND:New( MenuGroup, "MGRS Accuracy 1", A2GCoordinateMenu, self.MenuMGRS_Accuracy, self, MenuGroup, RootMenu, 1 ):SetTime( MenuTime )
      MENU_GROUP_COMMAND:New( MenuGroup, "MGRS Accuracy 2", A2GCoordinateMenu, self.MenuMGRS_Accuracy, self, MenuGroup, RootMenu, 2 ):SetTime( MenuTime )
      MENU_GROUP_COMMAND:New( MenuGroup, "MGRS Accuracy 3", A2GCoordinateMenu, self.MenuMGRS_Accuracy, self, MenuGroup, RootMenu, 3 ):SetTime( MenuTime )
      MENU_GROUP_COMMAND:New( MenuGroup, "MGRS Accuracy 4", A2GCoordinateMenu, self.MenuMGRS_Accuracy, self, MenuGroup, RootMenu, 4 ):SetTime( MenuTime )
      MENU_GROUP_COMMAND:New( MenuGroup, "MGRS Accuracy 5", A2GCoordinateMenu, self.MenuMGRS_Accuracy, self, MenuGroup, RootMenu, 5 ):SetTime( MenuTime )
    end

    local A2ACoordinateMenu = MENU_GROUP:New( MenuGroup, "A2A Coordinate System", SettingsMenu ):SetTime( MenuTime )

    if not self:IsA2A_LL_DMS() then
      MENU_GROUP_COMMAND:New( MenuGroup, "Lat/Lon Degree Min Sec (LL DMS)", A2ACoordinateMenu, self.A2AMenuSystem, self, MenuGroup, RootMenu, "LL DMS" ):SetTime( MenuTime )
    end

    if not self:IsA2A_LL_DDM() then
      MENU_GROUP_COMMAND:New( MenuGroup, "Lat/Lon Degree Dec Min (LL DDM)", A2ACoordinateMenu, self.A2AMenuSystem, self, MenuGroup, RootMenu, "LL DDM" ):SetTime( MenuTime )
    end

    if self:IsA2A_LL_DDM() then
      MENU_GROUP_COMMAND:New( MenuGroup, "LL DDM Accuracy 1", A2ACoordinateMenu, self.MenuLL_DDM_Accuracy, self, MenuGroup, RootMenu, 1 ):SetTime( MenuTime )
      MENU_GROUP_COMMAND:New( MenuGroup, "LL DDM Accuracy 2", A2ACoordinateMenu, self.MenuLL_DDM_Accuracy, self, MenuGroup, RootMenu, 2 ):SetTime( MenuTime )
      MENU_GROUP_COMMAND:New( MenuGroup, "LL DDM Accuracy 3", A2ACoordinateMenu, self.MenuLL_DDM_Accuracy, self, MenuGroup, RootMenu, 3 ):SetTime( MenuTime )
    end    

    if not self:IsA2A_BULLS() then
      MENU_GROUP_COMMAND:New( MenuGroup, "Bullseye (BULLS)", A2ACoordinateMenu, self.A2AMenuSystem, self, MenuGroup, RootMenu, "BULLS" ):SetTime( MenuTime )
    end
    
    if not self:IsA2A_BRAA() then
      MENU_GROUP_COMMAND:New( MenuGroup, "Bearing Range Altitude Aspect (BRAA)", A2ACoordinateMenu, self.A2AMenuSystem, self, MenuGroup, RootMenu, "BRAA" ):SetTime( MenuTime )
    end
    
    if not self:IsA2A_MGRS() then
      MENU_GROUP_COMMAND:New( MenuGroup, "Military Grid (MGRS)", A2ACoordinateMenu, self.A2AMenuSystem, self, MenuGroup, RootMenu, "MGRS" ):SetTime( MenuTime )
    end

    if self:IsA2A_MGRS() then
      MENU_GROUP_COMMAND:New( MenuGroup, "MGRS Accuracy 1", A2ACoordinateMenu, self.MenuMGRS_Accuracy, self, MenuGroup, RootMenu, 1 ):SetTime( MenuTime )
      MENU_GROUP_COMMAND:New( MenuGroup, "MGRS Accuracy 2", A2ACoordinateMenu, self.MenuMGRS_Accuracy, self, MenuGroup, RootMenu, 2 ):SetTime( MenuTime )
      MENU_GROUP_COMMAND:New( MenuGroup, "MGRS Accuracy 3", A2ACoordinateMenu, self.MenuMGRS_Accuracy, self, MenuGroup, RootMenu, 3 ):SetTime( MenuTime )
      MENU_GROUP_COMMAND:New( MenuGroup, "MGRS Accuracy 4", A2ACoordinateMenu, self.MenuMGRS_Accuracy, self, MenuGroup, RootMenu, 4 ):SetTime( MenuTime )
      MENU_GROUP_COMMAND:New( MenuGroup, "MGRS Accuracy 5", A2ACoordinateMenu, self.MenuMGRS_Accuracy, self, MenuGroup, RootMenu, 5 ):SetTime( MenuTime )
    end        
  
    local MetricsMenu = MENU_GROUP:New( MenuGroup, "Measures and Weights System", SettingsMenu ):SetTime( MenuTime )
    
    if self:IsMetric() then
      MENU_GROUP_COMMAND:New( MenuGroup, "Imperial (Miles,Feet)", MetricsMenu, self.MenuMWSystem, self, MenuGroup, RootMenu, false ):SetTime( MenuTime )
    end
    
    if self:IsImperial() then
      MENU_GROUP_COMMAND:New( MenuGroup, "Metric (Kilometers,Meters)", MetricsMenu, self.MenuMWSystem, self, MenuGroup, RootMenu, true ):SetTime( MenuTime )
    end    
    
    local MessagesMenu = MENU_GROUP:New( MenuGroup, "Messages and Reports", SettingsMenu ):SetTime( MenuTime )

    local UpdateMessagesMenu = MENU_GROUP:New( MenuGroup, "Update Messages", MessagesMenu ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "Off", UpdateMessagesMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Update, 0 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "5 seconds", UpdateMessagesMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Update, 5 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "10 seconds", UpdateMessagesMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Update, 10 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "15 seconds", UpdateMessagesMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Update, 15 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "30 seconds", UpdateMessagesMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Update, 30 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "1 minute", UpdateMessagesMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Update, 60 ):SetTime( MenuTime )

    local InformationMessagesMenu = MENU_GROUP:New( MenuGroup, "Information Messages", MessagesMenu ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "5 seconds", InformationMessagesMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Information, 5 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "10 seconds", InformationMessagesMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Information, 10 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "15 seconds", InformationMessagesMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Information, 15 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "30 seconds", InformationMessagesMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Information, 30 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "1 minute", InformationMessagesMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Information, 60 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "2 minutes", InformationMessagesMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Information, 120 ):SetTime( MenuTime )

    local BriefingReportsMenu = MENU_GROUP:New( MenuGroup, "Briefing Reports", MessagesMenu ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "15 seconds", BriefingReportsMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Briefing, 15 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "30 seconds", BriefingReportsMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Briefing, 30 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "1 minute", BriefingReportsMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Briefing, 60 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "2 minutes", BriefingReportsMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Briefing, 120 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "3 minutes", BriefingReportsMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Briefing, 180 ):SetTime( MenuTime )

    local OverviewReportsMenu = MENU_GROUP:New( MenuGroup, "Overview Reports", MessagesMenu ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "15 seconds", OverviewReportsMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Overview, 15 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "30 seconds", OverviewReportsMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Overview, 30 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "1 minute", OverviewReportsMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Overview, 60 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "2 minutes", OverviewReportsMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Overview, 120 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "3 minutes", OverviewReportsMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.Overview, 180 ):SetTime( MenuTime )

    local DetailedReportsMenu = MENU_GROUP:New( MenuGroup, "Detailed Reports", MessagesMenu ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "15 seconds", DetailedReportsMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.DetailedReportsMenu, 15 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "30 seconds", DetailedReportsMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.DetailedReportsMenu, 30 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "1 minute", DetailedReportsMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.DetailedReportsMenu, 60 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "2 minutes", DetailedReportsMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.DetailedReportsMenu, 120 ):SetTime( MenuTime )
    MENU_GROUP_COMMAND:New( MenuGroup, "3 minutes", DetailedReportsMenu, self.MenuMessageTimingsSystem, self, MenuGroup, RootMenu, MESSAGE.Type.DetailedReportsMenu, 180 ):SetTime( MenuTime )
    

    SettingsMenu:Remove( MenuTime )
    
    return self
  end

  --- @param #SETTINGS self
  -- @param RootMenu
  -- @param Wrapper.Client#CLIENT PlayerUnit
  -- @param #string MenuText
  -- @return #SETTINGS
  function SETTINGS:SetPlayerMenu( PlayerUnit )

    local PlayerGroup = PlayerUnit:GetGroup()
    local PlayerName = PlayerUnit:GetPlayerName()
    local PlayerNames = PlayerGroup:GetPlayerNames()

    local PlayerMenu = MENU_GROUP:New( PlayerGroup, 'Settings "' .. PlayerName .. '"' )
    
    self.PlayerMenu = PlayerMenu

    local A2GCoordinateMenu = MENU_GROUP:New( PlayerGroup, "A2G Coordinate System", PlayerMenu )
  
    if not self:IsA2G_LL_DMS() then
      MENU_GROUP_COMMAND:New( PlayerGroup, "Lat/Lon Degree Min Sec (LL DMS)", A2GCoordinateMenu, self.MenuGroupA2GSystem, self, PlayerUnit, PlayerGroup, PlayerName, "LL DMS" )
    end
  
    if not self:IsA2G_LL_DDM() then
      MENU_GROUP_COMMAND:New( PlayerGroup, "Lat/Lon Degree Dec Min (LL DDM)", A2GCoordinateMenu, self.MenuGroupA2GSystem, self, PlayerUnit, PlayerGroup, PlayerName, "LL DDM" )
    end
  
    if self:IsA2G_LL_DDM() then
      MENU_GROUP_COMMAND:New( PlayerGroup, "LL DDM Accuracy 1", A2GCoordinateMenu, self.MenuGroupLL_DDM_AccuracySystem, self, PlayerUnit, PlayerGroup, PlayerName, 1 )
      MENU_GROUP_COMMAND:New( PlayerGroup, "LL DDM Accuracy 2", A2GCoordinateMenu, self.MenuGroupLL_DDM_AccuracySystem, self, PlayerUnit, PlayerGroup, PlayerName, 2 )
      MENU_GROUP_COMMAND:New( PlayerGroup, "LL DDM Accuracy 3", A2GCoordinateMenu, self.MenuGroupLL_DDM_AccuracySystem, self, PlayerUnit, PlayerGroup, PlayerName, 3 )
    end
    
    if not self:IsA2G_BR() then
      MENU_GROUP_COMMAND:New( PlayerGroup, "Bearing, Range (BR)", A2GCoordinateMenu, self.MenuGroupA2GSystem, self, PlayerUnit, PlayerGroup, PlayerName, "BR" )
    end
    
    if not self:IsA2G_MGRS() then
      MENU_GROUP_COMMAND:New( PlayerGroup, "Military Grid (MGRS)", A2GCoordinateMenu, self.MenuGroupA2GSystem, self, PlayerUnit, PlayerGroup, PlayerName, "MGRS" )
    end    

    if self:IsA2G_MGRS() then
      MENU_GROUP_COMMAND:New( PlayerGroup, "MGRS Accuracy 1", A2GCoordinateMenu, self.MenuGroupMGRS_AccuracySystem, self, PlayerUnit, PlayerGroup, PlayerName, 1 )
      MENU_GROUP_COMMAND:New( PlayerGroup, "MGRS Accuracy 2", A2GCoordinateMenu, self.MenuGroupMGRS_AccuracySystem, self, PlayerUnit, PlayerGroup, PlayerName, 2 )
      MENU_GROUP_COMMAND:New( PlayerGroup, "MGRS Accuracy 3", A2GCoordinateMenu, self.MenuGroupMGRS_AccuracySystem, self, PlayerUnit, PlayerGroup, PlayerName, 3 )
      MENU_GROUP_COMMAND:New( PlayerGroup, "MGRS Accuracy 4", A2GCoordinateMenu, self.MenuGroupMGRS_AccuracySystem, self, PlayerUnit, PlayerGroup, PlayerName, 4 )
      MENU_GROUP_COMMAND:New( PlayerGroup, "MGRS Accuracy 5", A2GCoordinateMenu, self.MenuGroupMGRS_AccuracySystem, self, PlayerUnit, PlayerGroup, PlayerName, 5 )
    end

    local A2ACoordinateMenu = MENU_GROUP:New( PlayerGroup, "A2A Coordinate System", PlayerMenu )


    if not self:IsA2A_LL_DMS() then
      MENU_GROUP_COMMAND:New( PlayerGroup, "Lat/Lon Degree Min Sec (LL DMS)", A2GCoordinateMenu, self.MenuGroupA2GSystem, self, PlayerUnit, PlayerGroup, PlayerName, "LL DMS" )
    end
  
    if not self:IsA2A_LL_DDM() then
      MENU_GROUP_COMMAND:New( PlayerGroup, "Lat/Lon Degree Dec Min (LL DDM)", A2GCoordinateMenu, self.MenuGroupA2GSystem, self, PlayerUnit, PlayerGroup, PlayerName, "LL DDM" )
    end
  
    if self:IsA2A_LL_DDM() then
      MENU_GROUP_COMMAND:New( PlayerGroup, "LL DDM Accuracy 1", A2GCoordinateMenu, self.MenuGroupLL_DDM_AccuracySystem, self, PlayerUnit, PlayerGroup, PlayerName, 1 )
      MENU_GROUP_COMMAND:New( PlayerGroup, "LL DDM Accuracy 2", A2GCoordinateMenu, self.MenuGroupLL_DDM_AccuracySystem, self, PlayerUnit, PlayerGroup, PlayerName, 2 )
      MENU_GROUP_COMMAND:New( PlayerGroup, "LL DDM Accuracy 3", A2GCoordinateMenu, self.MenuGroupLL_DDM_AccuracySystem, self, PlayerUnit, PlayerGroup, PlayerName, 3 )
    end

    if not self:IsA2A_BULLS() then
      MENU_GROUP_COMMAND:New( PlayerGroup, "Bullseye (BULLS)", A2ACoordinateMenu, self.MenuGroupA2ASystem, self, PlayerUnit, PlayerGroup, PlayerName, "BULLS" )
    end
    
    if not self:IsA2A_BRAA() then
      MENU_GROUP_COMMAND:New( PlayerGroup, "Bearing Range Altitude Aspect (BRAA)", A2ACoordinateMenu, self.MenuGroupA2ASystem, self, PlayerUnit, PlayerGroup, PlayerName, "BRAA" )
    end
    
    if not self:IsA2A_MGRS() then
      MENU_GROUP_COMMAND:New( PlayerGroup, "Military Grid (MGRS)", A2ACoordinateMenu, self.MenuGroupA2ASystem, self, PlayerUnit, PlayerGroup, PlayerName, "MGRS" )
    end
    
    if self:IsA2A_MGRS() then
      MENU_GROUP_COMMAND:New( PlayerGroup, "Military Grid (MGRS) Accuracy 1", A2ACoordinateMenu, self.MenuGroupMGRS_AccuracySystem, self, PlayerUnit, PlayerGroup, PlayerName, 1 )
      MENU_GROUP_COMMAND:New( PlayerGroup, "Military Grid (MGRS) Accuracy 2", A2ACoordinateMenu, self.MenuGroupMGRS_AccuracySystem, self, PlayerUnit, PlayerGroup, PlayerName, 2 )
      MENU_GROUP_COMMAND:New( PlayerGroup, "Military Grid (MGRS) Accuracy 3", A2ACoordinateMenu, self.MenuGroupMGRS_AccuracySystem, self, PlayerUnit, PlayerGroup, PlayerName, 3 )
      MENU_GROUP_COMMAND:New( PlayerGroup, "Military Grid (MGRS) Accuracy 4", A2ACoordinateMenu, self.MenuGroupMGRS_AccuracySystem, self, PlayerUnit, PlayerGroup, PlayerName, 4 )
      MENU_GROUP_COMMAND:New( PlayerGroup, "Military Grid (MGRS) Accuracy 5", A2ACoordinateMenu, self.MenuGroupMGRS_AccuracySystem, self, PlayerUnit, PlayerGroup, PlayerName, 5 )
    end    

    local MetricsMenu = MENU_GROUP:New( PlayerGroup, "Measures and Weights System", PlayerMenu )
    
    if self:IsMetric() then
      MENU_GROUP_COMMAND:New( PlayerGroup, "Imperial (Miles,Feet)", MetricsMenu, self.MenuGroupMWSystem, self, PlayerUnit, PlayerGroup, PlayerName, false )
    end
    
    if self:IsImperial() then
      MENU_GROUP_COMMAND:New( PlayerGroup, "Metric (Kilometers,Meters)", MetricsMenu, self.MenuGroupMWSystem, self, PlayerUnit, PlayerGroup, PlayerName, true )
    end    


    local MessagesMenu = MENU_GROUP:New( PlayerGroup, "Messages and Reports", PlayerMenu )

    local UpdateMessagesMenu = MENU_GROUP:New( PlayerGroup, "Update Messages", MessagesMenu )
    MENU_GROUP_COMMAND:New( PlayerGroup, "Off", UpdateMessagesMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Update, 0 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "5 seconds", UpdateMessagesMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Update, 5 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "10 seconds", UpdateMessagesMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Update, 10 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "15 seconds", UpdateMessagesMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Update, 15 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "30 seconds", UpdateMessagesMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Update, 30 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "1 minute", UpdateMessagesMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Update, 60 )

    local InformationMessagesMenu = MENU_GROUP:New( PlayerGroup, "Information Messages", MessagesMenu )
    MENU_GROUP_COMMAND:New( PlayerGroup, "5 seconds", InformationMessagesMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Information, 5 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "10 seconds", InformationMessagesMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Information, 10 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "15 seconds", InformationMessagesMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Information, 15 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "30 seconds", InformationMessagesMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Information, 30 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "1 minute", InformationMessagesMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Information, 60 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "2 minutes", InformationMessagesMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Information, 120 )

    local BriefingReportsMenu = MENU_GROUP:New( PlayerGroup, "Briefing Reports", MessagesMenu )
    MENU_GROUP_COMMAND:New( PlayerGroup, "15 seconds", BriefingReportsMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Briefing, 15 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "30 seconds", BriefingReportsMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Briefing, 30 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "1 minute", BriefingReportsMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Briefing, 60 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "2 minutes", BriefingReportsMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Briefing, 120 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "3 minutes", BriefingReportsMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Briefing, 180 )

    local OverviewReportsMenu = MENU_GROUP:New( PlayerGroup, "Overview Reports", MessagesMenu )
    MENU_GROUP_COMMAND:New( PlayerGroup, "15 seconds", OverviewReportsMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Overview, 15 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "30 seconds", OverviewReportsMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Overview, 30 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "1 minute", OverviewReportsMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Overview, 60 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "2 minutes", OverviewReportsMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Overview, 120 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "3 minutes", OverviewReportsMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.Overview, 180 )

    local DetailedReportsMenu = MENU_GROUP:New( PlayerGroup, "Detailed Reports", MessagesMenu )
    MENU_GROUP_COMMAND:New( PlayerGroup, "15 seconds", DetailedReportsMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.DetailedReportsMenu, 15 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "30 seconds", DetailedReportsMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.DetailedReportsMenu, 30 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "1 minute", DetailedReportsMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.DetailedReportsMenu, 60 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "2 minutes", DetailedReportsMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.DetailedReportsMenu, 120 )
    MENU_GROUP_COMMAND:New( PlayerGroup, "3 minutes", DetailedReportsMenu, self.MenuGroupMessageTimingsSystem, self, PlayerUnit, PlayerGroup, PlayerName, MESSAGE.Type.DetailedReportsMenu, 180 )

    
    return self
  end

  --- @param #SETTINGS self
  -- @param RootMenu
  -- @param Wrapper.Client#CLIENT PlayerUnit
  -- @return #SETTINGS
  function SETTINGS:RemovePlayerMenu( PlayerUnit )

    if self.PlayerMenu then
      self.PlayerMenu:Remove()
    end
    
    return self
  end


  --- @param #SETTINGS self
  function SETTINGS:A2GMenuSystem( MenuGroup, RootMenu, A2GSystem )
    self.A2GSystem = A2GSystem
    MESSAGE:New( string.format("Settings: Default A2G coordinate system set to %s for all players!", A2GSystem ), 5 ):ToAll()
    self:SetSystemMenu( MenuGroup, RootMenu )
  end

  --- @param #SETTINGS self
  function SETTINGS:A2AMenuSystem( MenuGroup, RootMenu, A2ASystem )
    self.A2ASystem = A2ASystem
    MESSAGE:New( string.format("Settings: Default A2A coordinate system set to %s for all players!", A2ASystem ), 5 ):ToAll()
    self:SetSystemMenu( MenuGroup, RootMenu )
  end

  --- @param #SETTINGS self
  function SETTINGS:MenuLL_DDM_Accuracy( MenuGroup, RootMenu, LL_Accuracy )
    self.LL_Accuracy = LL_Accuracy
    MESSAGE:New( string.format("Settings: Default LL accuracy set to %s for all players!", LL_Accuracy ), 5 ):ToAll()
    self:SetSystemMenu( MenuGroup, RootMenu )
  end

  --- @param #SETTINGS self
  function SETTINGS:MenuMGRS_Accuracy( MenuGroup, RootMenu, MGRS_Accuracy )
    self.MGRS_Accuracy = MGRS_Accuracy
    MESSAGE:New( string.format("Settings: Default MGRS accuracy set to %s for all players!", MGRS_Accuracy ), 5 ):ToAll()
    self:SetSystemMenu( MenuGroup, RootMenu )
  end

  --- @param #SETTINGS self
  function SETTINGS:MenuMWSystem( MenuGroup, RootMenu, MW )
    self.Metric = MW
    MESSAGE:New( string.format("Settings: Default measurement format set to %s for all players!", MW and "Metric" or "Imperial" ), 5 ):ToAll()
    self:SetSystemMenu( MenuGroup, RootMenu )
  end

  --- @param #SETTINGS self
  function SETTINGS:MenuMessageTimingsSystem( MenuGroup, RootMenu, MessageType, MessageTime )
    self:SetMessageTime( MessageType, MessageTime )
    MESSAGE:New( string.format( "Settings: Default message time set for %s to %d.", MessageType, MessageTime ), 5 ):ToAll()
  end

  do
    --- @param #SETTINGS self
    function SETTINGS:MenuGroupA2GSystem( PlayerUnit, PlayerGroup, PlayerName, A2GSystem )
      BASE:E( {self, PlayerUnit:GetName(), A2GSystem} )
      self.A2GSystem = A2GSystem
      MESSAGE:New( string.format( "Settings: A2G format set to %s for player %s.", A2GSystem, PlayerName ), 5 ):ToGroup( PlayerGroup )
      self:RemovePlayerMenu(PlayerUnit)
      self:SetPlayerMenu(PlayerUnit)
    end
  
    --- @param #SETTINGS self
    function SETTINGS:MenuGroupA2ASystem( PlayerUnit, PlayerGroup, PlayerName, A2ASystem )
      self.A2ASystem = A2ASystem
      MESSAGE:New( string.format( "Settings: A2A format set to %s for player %s.", A2ASystem, PlayerName ), 5 ):ToGroup( PlayerGroup )
      self:RemovePlayerMenu(PlayerUnit)
      self:SetPlayerMenu(PlayerUnit)
    end
  
    --- @param #SETTINGS self
    function SETTINGS:MenuGroupLL_DDM_AccuracySystem( PlayerUnit, PlayerGroup, PlayerName, LL_Accuracy )
      self.LL_Accuracy = LL_Accuracy
      MESSAGE:New( string.format( "Settings: A2G LL format accuracy set to %d for player %s.", LL_Accuracy, PlayerName ), 5 ):ToGroup( PlayerGroup )
      self:RemovePlayerMenu(PlayerUnit)
      self:SetPlayerMenu(PlayerUnit)
    end
  
    --- @param #SETTINGS self
    function SETTINGS:MenuGroupMGRS_AccuracySystem( PlayerUnit, PlayerGroup, PlayerName, MGRS_Accuracy )
      self.MGRS_Accuracy = MGRS_Accuracy
      MESSAGE:New( string.format( "Settings: A2G MGRS format accuracy set to %d for player %s.", MGRS_Accuracy, PlayerName ), 5 ):ToGroup( PlayerGroup )
      self:RemovePlayerMenu(PlayerUnit)
      self:SetPlayerMenu(PlayerUnit)
    end

    --- @param #SETTINGS self
    function SETTINGS:MenuGroupMWSystem( PlayerUnit, PlayerGroup, PlayerName, MW )
      self.Metric = MW
      MESSAGE:New( string.format( "Settings: Measurement format set to %s for player %s.", MW and "Metric" or "Imperial", PlayerName ), 5 ):ToGroup( PlayerGroup )
      self:RemovePlayerMenu(PlayerUnit)
      self:SetPlayerMenu(PlayerUnit)
    end

    --- @param #SETTINGS self
    function SETTINGS:MenuGroupMessageTimingsSystem( PlayerUnit, PlayerGroup, PlayerName, MessageType, MessageTime )
      self:SetMessageTime( MessageType, MessageTime )
      MESSAGE:New( string.format( "Settings: Default message time set for %s to %d.", MessageType, MessageTime ), 5 ):ToGroup( PlayerGroup )
    end
  
  end

end


--- **Core** -- MENU_ classes model the definition of **hierarchical menu structures** and **commands for players** within a mission.
-- 
-- ===
-- 
-- DCS Menus can be managed using the MENU classes. 
-- The advantage of using MENU classes is that it hides the complexity of dealing with menu management in more advanced scanerios where you need to 
-- set menus and later remove them, and later set them again. You'll find while using use normal DCS scripting functions, that setting and removing
-- menus is not a easy feat if you have complex menu hierarchies defined. 
-- Using the MOOSE menu classes, the removal and refreshing of menus are nicely being handled within these classes, and becomes much more easy.
-- On top, MOOSE implements **variable parameter** passing for command menus. 
-- 
-- There are basically two different MENU class types that you need to use:
-- 
-- ### To manage **main menus**, the classes begin with **MENU_**:
-- 
--   * @{Menu#MENU_MISSION}: Manages main menus for whole mission file.
--   * @{Menu#MENU_COALITION}: Manages main menus for whole coalition.
--   * @{Menu#MENU_GROUP}: Manages main menus for GROUPs.
--   * @{Menu#MENU_CLIENT}: Manages main menus for CLIENTs. This manages menus for units with the skill level "Client".
--   
-- ### To manage **command menus**, which are menus that allow the player to issue **functions**, the classes begin with **MENU_COMMAND_**:
--   
--   * @{Menu#MENU_MISSION_COMMAND}: Manages command menus for whole mission file.
--   * @{Menu#MENU_COALITION_COMMAND}: Manages command menus for whole coalition.
--   * @{Menu#MENU_GROUP_COMMAND}: Manages command menus for GROUPs.
--   * @{Menu#MENU_CLIENT_COMMAND}: Manages command menus for CLIENTs. This manages menus for units with the skill level "Client".
-- 
-- ===
--- 
-- ### Author: **Sven Van de Velde (FlightControl)**
-- ### Contributions: 
-- 
-- ====
--   
-- @module Menu


do -- MENU_BASE

  --- @type MENU_BASE
  -- @extends Base#BASE

  --- # MENU_BASE class, extends @{Base#BASE}
  -- The MENU_BASE class defines the main MENU class where other MENU classes are derived from.
  -- This is an abstract class, so don't use it.
  -- @field #MENU_BASE
  MENU_BASE = {
    ClassName = "MENU_BASE",
    MenuPath = nil,
    MenuText = "",
    MenuParentPath = nil
  }
  
  --- Consructor
  -- @param #MENU_BASE
  -- @return #MENU_BASE
  function MENU_BASE:New( MenuText, ParentMenu )
  
    local MenuParentPath = {}
    if ParentMenu ~= nil then
      MenuParentPath = ParentMenu.MenuPath
    end

  	local self = BASE:Inherit( self, BASE:New() )
  
  	self.MenuPath = nil 
  	self.MenuText = MenuText
  	self.MenuParentPath = MenuParentPath
    self.Menus = {}
    self.MenuCount = 0
    self.MenuRemoveParent = false
    self.MenuTime = timer.getTime()
  	
  	return self
  end
  
  --- Gets a @{Menu} from a parent @{Menu}
  -- @param #MENU_BASE self
  -- @param #string MenuText The text of the child menu.
  -- @return #MENU_BASE
  function MENU_BASE:GetMenu( MenuText )
    self:F2( { Menu = self.Menus[MenuText] } )
    return self.Menus[MenuText]
  end
  
  --- Sets a @{Menu} to remove automatically the parent menu when the menu removed is the last child menu of that parent @{Menu}.
  -- @param #MENU_BASE self
  -- @param #boolean RemoveParent If true, the parent menu is automatically removed when this menu is the last child menu of that parent @{Menu}.
  -- @return #MENU_BASE
  function MENU_BASE:SetRemoveParent( RemoveParent )
    self:F2( { RemoveParent } )
    self.MenuRemoveParent = RemoveParent
    return self
  end
  
  
  --- Sets a time stamp for later prevention of menu removal.
  -- @param #MENU_BASE self
  -- @param MenuTime
  -- @return #MENU_BASE
  function MENU_BASE:SetTime( MenuTime )
    self.MenuTime = MenuTime
    return self
  end
  
  --- Sets a tag for later selection of menu refresh.
  -- @param #MENU_BASE self
  -- @param #string MenuTag A Tag or Key that will filter only menu items set with this key.
  -- @return #MENU_BASE
  function MENU_BASE:SetTag( MenuTag )
    self.MenuTag = MenuTag
    return self
  end
  
end

do -- MENU_COMMAND_BASE

  --- @type MENU_COMMAND_BASE
  -- @field #function MenuCallHandler
  -- @extends Core.Menu#MENU_BASE
  
  --- # MENU_COMMAND_BASE class, extends @{Base#BASE}
  -- ----------------------------------------------------------
  -- The MENU_COMMAND_BASE class defines the main MENU class where other MENU COMMAND_ 
  -- classes are derived from, in order to set commands.
  -- 
  -- @field #MENU_COMMAND_BASE
  MENU_COMMAND_BASE = {
    ClassName = "MENU_COMMAND_BASE",
    CommandMenuFunction = nil,
    CommandMenuArgument = nil,
    MenuCallHandler = nil,
  }
  
  --- Constructor
  -- @param #MENU_COMMAND_BASE
  -- @return #MENU_COMMAND_BASE
  function MENU_COMMAND_BASE:New( MenuText, ParentMenu, CommandMenuFunction, CommandMenuArguments )
  
  	local self = BASE:Inherit( self, MENU_BASE:New( MenuText, ParentMenu ) ) -- #MENU_COMMAND_BASE

    -- When a menu function goes into error, DCS displays an obscure menu message.
    -- This error handler catches the menu error and displays the full call stack.
    local ErrorHandler = function( errmsg )
      env.info( "MOOSE error in MENU COMMAND function: " .. errmsg )
      if debug ~= nil then
        env.info( debug.traceback() )
      end
      return errmsg
    end
  
    self:SetCommandMenuFunction( CommandMenuFunction )
    self:SetCommandMenuArguments( CommandMenuArguments )
    self.MenuCallHandler = function()
      local function MenuFunction() 
        return self.CommandMenuFunction( unpack( self.CommandMenuArguments ) )
      end
      local Status, Result = xpcall( MenuFunction, ErrorHandler )
    end
  	
  	return self
  end
  
  --- This sets the new command function of a menu, 
  -- so that if a menu is regenerated, or if command function changes,
  -- that the function set for the menu is loosely coupled with the menu itself!!!
  -- If the function changes, no new menu needs to be generated if the menu text is the same!!!
  -- @param #MENU_COMMAND_BASE
  -- @return #MENU_COMMAND_BASE
  function MENU_COMMAND_BASE:SetCommandMenuFunction( CommandMenuFunction )
    self.CommandMenuFunction = CommandMenuFunction
    return self
  end

  --- This sets the new command arguments of a menu, 
  -- so that if a menu is regenerated, or if command arguments change,
  -- that the arguments set for the menu are loosely coupled with the menu itself!!!
  -- If the arguments change, no new menu needs to be generated if the menu text is the same!!!
  -- @param #MENU_COMMAND_BASE
  -- @return #MENU_COMMAND_BASE
  function MENU_COMMAND_BASE:SetCommandMenuArguments( CommandMenuArguments )
    self.CommandMenuArguments = CommandMenuArguments
    return self
  end

end


do -- MENU_MISSION

  --- @type MENU_MISSION
  -- @extends Core.Menu#MENU_BASE

  --- # MENU_MISSION class, extends @{Menu#MENU_BASE}
  -- 
  -- The MENU_MISSION class manages the main menus for a complete mission.  
  -- You can add menus with the @{#MENU_MISSION.New} method, which constructs a MENU_MISSION object and returns you the object reference.
  -- Using this object reference, you can then remove ALL the menus and submenus underlying automatically with @{#MENU_MISSION.Remove}.
  -- @field #MENU_MISSION
  MENU_MISSION = {
    ClassName = "MENU_MISSION"
  }
  
  --- MENU_MISSION constructor. Creates a new MENU_MISSION object and creates the menu for a complete mission file.
  -- @param #MENU_MISSION self
  -- @param #string MenuText The text for the menu.
  -- @param #table ParentMenu The parent menu. This parameter can be ignored if you want the menu to be located at the perent menu of DCS world (under F10 other).
  -- @return #MENU_MISSION
  function MENU_MISSION:New( MenuText, ParentMenu )
  
    local self = BASE:Inherit( self, MENU_BASE:New( MenuText, ParentMenu ) )
    
    self:F( { MenuText, ParentMenu } )
  
    self.MenuText = MenuText
    self.ParentMenu = ParentMenu
    
    self.Menus = {}
  
    self:T( { MenuText } )
  
    self.MenuPath = missionCommands.addSubMenu( MenuText, self.MenuParentPath )
  
    self:T( { self.MenuPath } )
  
    if ParentMenu and ParentMenu.Menus then
      ParentMenu.Menus[self.MenuPath] = self
    end

    return self
  end
  
  --- Removes the sub menus recursively of this MENU_MISSION. Note that the main menu is kept!
  -- @param #MENU_MISSION self
  -- @return #MENU_MISSION
  function MENU_MISSION:RemoveSubMenus()
    self:F( self.MenuPath )
  
    for MenuID, Menu in pairs( self.Menus ) do
      Menu:Remove()
    end
  
  end
  
  --- Removes the main menu and the sub menus recursively of this MENU_MISSION.
  -- @param #MENU_MISSION self
  -- @return #nil
  function MENU_MISSION:Remove()
    self:F( self.MenuPath )
  
    self:RemoveSubMenus()
    missionCommands.removeItem( self.MenuPath )
    if self.ParentMenu then
      self.ParentMenu.Menus[self.MenuPath] = nil
    end
  
    return nil
  end

end

do -- MENU_MISSION_COMMAND
  
  --- @type MENU_MISSION_COMMAND
  -- @extends Core.Menu#MENU_COMMAND_BASE
  
  --- # MENU_MISSION_COMMAND class, extends @{Menu#MENU_COMMAND_BASE}
  --   
  -- The MENU_MISSION_COMMAND class manages the command menus for a complete mission, which allow players to execute functions during mission execution.  
  -- You can add menus with the @{#MENU_MISSION_COMMAND.New} method, which constructs a MENU_MISSION_COMMAND object and returns you the object reference.
  -- Using this object reference, you can then remove ALL the menus and submenus underlying automatically with @{#MENU_MISSION_COMMAND.Remove}.
  -- 
  -- @field #MENU_MISSION_COMMAND
  MENU_MISSION_COMMAND = {
    ClassName = "MENU_MISSION_COMMAND"
  }
  
  --- MENU_MISSION constructor. Creates a new radio command item for a complete mission file, which can invoke a function with parameters.
  -- @param #MENU_MISSION_COMMAND self
  -- @param #string MenuText The text for the menu.
  -- @param Menu#MENU_MISSION ParentMenu The parent menu.
  -- @param CommandMenuFunction A function that is called when the menu key is pressed.
  -- @param CommandMenuArgument An argument for the function. There can only be ONE argument given. So multiple arguments must be wrapped into a table. See the below example how to do this.
  -- @return #MENU_MISSION_COMMAND self
  function MENU_MISSION_COMMAND:New( MenuText, ParentMenu, CommandMenuFunction, ... )
  
    local self = BASE:Inherit( self, MENU_COMMAND_BASE:New( MenuText, ParentMenu, CommandMenuFunction, arg ) )
    
    self.MenuText = MenuText
    self.ParentMenu = ParentMenu
  
    self:T( { MenuText, CommandMenuFunction, arg } )
    
  
    self.MenuPath = missionCommands.addCommand( MenuText, self.MenuParentPath, self.MenuCallHandler )
   
    ParentMenu.Menus[self.MenuPath] = self
    
    return self
  end
  
  --- Removes a radio command item for a coalition
  -- @param #MENU_MISSION_COMMAND self
  -- @return #nil
  function MENU_MISSION_COMMAND:Remove()
    self:F( self.MenuPath )
  
    missionCommands.removeItem( self.MenuPath )
    if self.ParentMenu then
      self.ParentMenu.Menus[self.MenuPath] = nil
    end
    return nil
  end

end



do -- MENU_COALITION

  --- @type MENU_COALITION
  -- @extends Core.Menu#MENU_BASE
  
  --- # MENU_COALITION class, extends @{Menu#MENU_BASE}
  -- 
  -- The @{Menu#MENU_COALITION} class manages the main menus for coalitions.  
  -- You can add menus with the @{#MENU_COALITION.New} method, which constructs a MENU_COALITION object and returns you the object reference.
  -- Using this object reference, you can then remove ALL the menus and submenus underlying automatically with @{#MENU_COALITION.Remove}.
  -- 
  --
  -- @usage
  --  -- This demo creates a menu structure for the planes within the red coalition.
  --  -- To test, join the planes, then look at the other radio menus (Option F10).
  --  -- Then switch planes and check if the menu is still there.
  --
  --  local Plane1 = CLIENT:FindByName( "Plane 1" )
  --  local Plane2 = CLIENT:FindByName( "Plane 2" )
  --
  --
  --  -- This would create a menu for the red coalition under the main DCS "Others" menu.
  --  local MenuCoalitionRed = MENU_COALITION:New( coalition.side.RED, "Manage Menus" )
  --
  --
  --  local function ShowStatus( StatusText, Coalition )
  --
  --    MESSAGE:New( Coalition, 15 ):ToRed()
  --    Plane1:Message( StatusText, 15 )
  --    Plane2:Message( StatusText, 15 )
  --  end
  --
  --  local MenuStatus -- Menu#MENU_COALITION
  --  local MenuStatusShow -- Menu#MENU_COALITION_COMMAND
  --
  --  local function RemoveStatusMenu()
  --    MenuStatus:Remove()
  --  end
  --
  --  local function AddStatusMenu()
  --    
  --    -- This would create a menu for the red coalition under the MenuCoalitionRed menu object.
  --    MenuStatus = MENU_COALITION:New( coalition.side.RED, "Status for Planes" )
  --    MenuStatusShow = MENU_COALITION_COMMAND:New( coalition.side.RED, "Show Status", MenuStatus, ShowStatus, "Status of planes is ok!", "Message to Red Coalition" )
  --  end
  --
  --  local MenuAdd = MENU_COALITION_COMMAND:New( coalition.side.RED, "Add Status Menu", MenuCoalitionRed, AddStatusMenu )
  --  local MenuRemove = MENU_COALITION_COMMAND:New( coalition.side.RED, "Remove Status Menu", MenuCoalitionRed, RemoveStatusMenu )
  --  
  --  @field #MENU_COALITION
  MENU_COALITION = {
    ClassName = "MENU_COALITION"
  }
  
  --- MENU_COALITION constructor. Creates a new MENU_COALITION object and creates the menu for a complete coalition.
  -- @param #MENU_COALITION self
  -- @param Dcs.DCSCoalition#coalition.side Coalition The coalition owning the menu.
  -- @param #string MenuText The text for the menu.
  -- @param #table ParentMenu The parent menu. This parameter can be ignored if you want the menu to be located at the perent menu of DCS world (under F10 other).
  -- @return #MENU_COALITION self
  function MENU_COALITION:New( Coalition, MenuText, ParentMenu )
  
    local self = BASE:Inherit( self, MENU_BASE:New( MenuText, ParentMenu ) )
    
    self:F( { Coalition, MenuText, ParentMenu } )
  
    self.Coalition = Coalition
    self.MenuText = MenuText
    self.ParentMenu = ParentMenu
    
    self.Menus = {}
  
    self:T( { MenuText } )
  
    self.MenuPath = missionCommands.addSubMenuForCoalition( Coalition, MenuText, self.MenuParentPath )
  
    self:T( { self.MenuPath } )
  
    if ParentMenu and ParentMenu.Menus then
      ParentMenu.Menus[self.MenuPath] = self
    end

    return self
  end
  
  --- Removes the sub menus recursively of this MENU_COALITION. Note that the main menu is kept!
  -- @param #MENU_COALITION self
  -- @return #MENU_COALITION
  function MENU_COALITION:RemoveSubMenus()
    self:F( self.MenuPath )
  
    for MenuID, Menu in pairs( self.Menus ) do
      Menu:Remove()
    end
  
  end
  
  --- Removes the main menu and the sub menus recursively of this MENU_COALITION.
  -- @param #MENU_COALITION self
  -- @return #nil
  function MENU_COALITION:Remove()
    self:F( self.MenuPath )
  
    self:RemoveSubMenus()
    missionCommands.removeItemForCoalition( self.Coalition, self.MenuPath )
    if self.ParentMenu then
      self.ParentMenu.Menus[self.MenuPath] = nil
    end
  
    return nil
  end

end

do -- MENU_COALITION_COMMAND
  
  --- @type MENU_COALITION_COMMAND
  -- @extends Core.Menu#MENU_COMMAND_BASE
  
  --- # MENU_COALITION_COMMAND class, extends @{Menu#MENU_COMMAND_BASE}
  -- 
  -- The MENU_COALITION_COMMAND class manages the command menus for coalitions, which allow players to execute functions during mission execution.  
  -- You can add menus with the @{#MENU_COALITION_COMMAND.New} method, which constructs a MENU_COALITION_COMMAND object and returns you the object reference.
  -- Using this object reference, you can then remove ALL the menus and submenus underlying automatically with @{#MENU_COALITION_COMMAND.Remove}.
  --
  -- @field #MENU_COALITION_COMMAND
  MENU_COALITION_COMMAND = {
    ClassName = "MENU_COALITION_COMMAND"
  }
  
  --- MENU_COALITION constructor. Creates a new radio command item for a coalition, which can invoke a function with parameters.
  -- @param #MENU_COALITION_COMMAND self
  -- @param Dcs.DCSCoalition#coalition.side Coalition The coalition owning the menu.
  -- @param #string MenuText The text for the menu.
  -- @param Menu#MENU_COALITION ParentMenu The parent menu.
  -- @param CommandMenuFunction A function that is called when the menu key is pressed.
  -- @param CommandMenuArgument An argument for the function. There can only be ONE argument given. So multiple arguments must be wrapped into a table. See the below example how to do this.
  -- @return #MENU_COALITION_COMMAND
  function MENU_COALITION_COMMAND:New( Coalition, MenuText, ParentMenu, CommandMenuFunction, ... )
  
    local self = BASE:Inherit( self, MENU_COMMAND_BASE:New( MenuText, ParentMenu, CommandMenuFunction, arg ) )
    
    self.MenuCoalition = Coalition
    self.MenuText = MenuText
    self.ParentMenu = ParentMenu
  
    self:T( { MenuText, CommandMenuFunction, arg } )
    
  
    self.MenuPath = missionCommands.addCommandForCoalition( self.MenuCoalition, MenuText, self.MenuParentPath, self.MenuCallHandler )
   
    ParentMenu.Menus[self.MenuPath] = self
    
    return self
  end
  
  --- Removes a radio command item for a coalition
  -- @param #MENU_COALITION_COMMAND self
  -- @return #nil
  function MENU_COALITION_COMMAND:Remove()
    self:F( self.MenuPath )
  
    missionCommands.removeItemForCoalition( self.MenuCoalition, self.MenuPath )
    if self.ParentMenu then
      self.ParentMenu.Menus[self.MenuPath] = nil
    end
    return nil
  end

end

do -- MENU_CLIENT

  -- This local variable is used to cache the menus registered under clients.
  -- Menus don't dissapear when clients are destroyed and restarted.
  -- So every menu for a client created must be tracked so that program logic accidentally does not create
  -- the same menus twice during initialization logic.
  -- These menu classes are handling this logic with this variable.
  local _MENUCLIENTS = {}
  
  --- MENU_COALITION constructor. Creates a new radio command item for a coalition, which can invoke a function with parameters.
  -- @type MENU_CLIENT
  -- @extends Core.Menu#MENU_BASE


  --- # MENU_CLIENT class, extends @{Menu#MENU_BASE}
  -- 
  -- The MENU_CLIENT class manages the main menus for coalitions.  
  -- You can add menus with the @{#MENU_CLIENT.New} method, which constructs a MENU_CLIENT object and returns you the object reference.
  -- Using this object reference, you can then remove ALL the menus and submenus underlying automatically with @{#MENU_CLIENT.Remove}.
  -- 
  -- @usage
  --  -- This demo creates a menu structure for the two clients of planes.
  --  -- Each client will receive a different menu structure.
  --  -- To test, join the planes, then look at the other radio menus (Option F10).
  --  -- Then switch planes and check if the menu is still there.
  --  -- And play with the Add and Remove menu options.
  --  
  --  -- Note that in multi player, this will only work after the DCS clients bug is solved.
  --
  --  local function ShowStatus( PlaneClient, StatusText, Coalition )
  --
  --    MESSAGE:New( Coalition, 15 ):ToRed()
  --    PlaneClient:Message( StatusText, 15 )
  --  end
  --
  --  local MenuStatus = {}
  --
  --  local function RemoveStatusMenu( MenuClient )
  --    local MenuClientName = MenuClient:GetName()
  --    MenuStatus[MenuClientName]:Remove()
  --  end
  --
  --  --- @param Wrapper.Client#CLIENT MenuClient
  --  local function AddStatusMenu( MenuClient )
  --    local MenuClientName = MenuClient:GetName()
  --    -- This would create a menu for the red coalition under the MenuCoalitionRed menu object.
  --    MenuStatus[MenuClientName] = MENU_CLIENT:New( MenuClient, "Status for Planes" )
  --    MENU_CLIENT_COMMAND:New( MenuClient, "Show Status", MenuStatus[MenuClientName], ShowStatus, MenuClient, "Status of planes is ok!", "Message to Red Coalition" )
  --  end
  --
  --  SCHEDULER:New( nil,
  --    function()
  --      local PlaneClient = CLIENT:FindByName( "Plane 1" )
  --      if PlaneClient and PlaneClient:IsAlive() then
  --        local MenuManage = MENU_CLIENT:New( PlaneClient, "Manage Menus" )
  --        MENU_CLIENT_COMMAND:New( PlaneClient, "Add Status Menu Plane 1", MenuManage, AddStatusMenu, PlaneClient )
  --        MENU_CLIENT_COMMAND:New( PlaneClient, "Remove Status Menu Plane 1", MenuManage, RemoveStatusMenu, PlaneClient )
  --      end
  --    end, {}, 10, 10 )
  --
  --  SCHEDULER:New( nil,
  --    function()
  --      local PlaneClient = CLIENT:FindByName( "Plane 2" )
  --      if PlaneClient and PlaneClient:IsAlive() then
  --        local MenuManage = MENU_CLIENT:New( PlaneClient, "Manage Menus" )
  --        MENU_CLIENT_COMMAND:New( PlaneClient, "Add Status Menu Plane 2", MenuManage, AddStatusMenu, PlaneClient )
  --        MENU_CLIENT_COMMAND:New( PlaneClient, "Remove Status Menu Plane 2", MenuManage, RemoveStatusMenu, PlaneClient )
  --      end
  --    end, {}, 10, 10 )
  --    
  -- @field #MENU_CLIENT
  MENU_CLIENT = {
    ClassName = "MENU_CLIENT"
  }
  
  --- MENU_CLIENT constructor. Creates a new radio menu item for a client.
  -- @param #MENU_CLIENT self
  -- @param Wrapper.Client#CLIENT Client The Client owning the menu.
  -- @param #string MenuText The text for the menu.
  -- @param #table ParentMenu The parent menu.
  -- @return #MENU_CLIENT self
  function MENU_CLIENT:New( Client, MenuText, ParentMenu )
  
  	-- Arrange meta tables
  	local MenuParentPath = {}
  	if ParentMenu ~= nil then
  	  MenuParentPath = ParentMenu.MenuPath
  	end
  
  	local self = BASE:Inherit( self, MENU_BASE:New( MenuText, MenuParentPath ) )
  	self:F( { Client, MenuText, ParentMenu } )
  
    self.MenuClient = Client
    self.MenuClientGroupID = Client:GetClientGroupID()
    self.MenuParentPath = MenuParentPath
    self.MenuText = MenuText
    self.ParentMenu = ParentMenu
    
    self.Menus = {}
  
    if not _MENUCLIENTS[self.MenuClientGroupID] then
      _MENUCLIENTS[self.MenuClientGroupID] = {}
    end
    
    local MenuPath = _MENUCLIENTS[self.MenuClientGroupID]
  
    self:T( { Client:GetClientGroupName(), MenuPath[table.concat(MenuParentPath)], MenuParentPath, MenuText } )
  
    local MenuPathID = table.concat(MenuParentPath) .. "/" .. MenuText
    if MenuPath[MenuPathID] then
      missionCommands.removeItemForGroup( self.MenuClient:GetClientGroupID(), MenuPath[MenuPathID] )
    end
  
  	self.MenuPath = missionCommands.addSubMenuForGroup( self.MenuClient:GetClientGroupID(), MenuText, MenuParentPath )
  	MenuPath[MenuPathID] = self.MenuPath
  
    self:T( { Client:GetClientGroupName(), self.MenuPath } )
  
    if ParentMenu and ParentMenu.Menus then
      ParentMenu.Menus[self.MenuPath] = self
    end
  	return self
  end
  
  --- Removes the sub menus recursively of this @{#MENU_CLIENT}.
  -- @param #MENU_CLIENT self
  -- @return #MENU_CLIENT self
  function MENU_CLIENT:RemoveSubMenus()
    self:F( self.MenuPath )
  
    for MenuID, Menu in pairs( self.Menus ) do
      Menu:Remove()
    end
  
  end
  
  --- Removes the sub menus recursively of this MENU_CLIENT.
  -- @param #MENU_CLIENT self
  -- @return #nil
  function MENU_CLIENT:Remove()
    self:F( self.MenuPath )
  
    self:RemoveSubMenus()
  
    if not _MENUCLIENTS[self.MenuClientGroupID] then
      _MENUCLIENTS[self.MenuClientGroupID] = {}
    end
    
    local MenuPath = _MENUCLIENTS[self.MenuClientGroupID]
  
    if MenuPath[table.concat(self.MenuParentPath) .. "/" .. self.MenuText] then
      MenuPath[table.concat(self.MenuParentPath) .. "/" .. self.MenuText] = nil
    end
    
    missionCommands.removeItemForGroup( self.MenuClient:GetClientGroupID(), self.MenuPath )
    self.ParentMenu.Menus[self.MenuPath] = nil
    return nil
  end
  
  
  --- @type MENU_CLIENT_COMMAND
  -- @extends Core.Menu#MENU_COMMAND

  --- # MENU_CLIENT_COMMAND class, extends @{Menu#MENU_COMMAND_BASE}
  --
  -- The MENU_CLIENT_COMMAND class manages the command menus for coalitions, which allow players to execute functions during mission execution.  
  -- You can add menus with the @{#MENU_CLIENT_COMMAND.New} method, which constructs a MENU_CLIENT_COMMAND object and returns you the object reference.
  -- Using this object reference, you can then remove ALL the menus and submenus underlying automatically with @{#MENU_CLIENT_COMMAND.Remove}.
  -- 
  -- @field #MENU_CLIENT_COMMAND
  MENU_CLIENT_COMMAND = {
    ClassName = "MENU_CLIENT_COMMAND"
  }
  
  --- MENU_CLIENT_COMMAND constructor. Creates a new radio command item for a client, which can invoke a function with parameters.
  -- @param #MENU_CLIENT_COMMAND self
  -- @param Wrapper.Client#CLIENT Client The Client owning the menu.
  -- @param #string MenuText The text for the menu.
  -- @param #MENU_BASE ParentMenu The parent menu.
  -- @param CommandMenuFunction A function that is called when the menu key is pressed.
  -- @return Menu#MENU_CLIENT_COMMAND self
  function MENU_CLIENT_COMMAND:New( Client, MenuText, ParentMenu, CommandMenuFunction, ... )
  
  	-- Arrange meta tables
  	
  	local MenuParentPath = {}
  	if ParentMenu ~= nil then
  		MenuParentPath = ParentMenu.MenuPath
  	end
  
  	local self = BASE:Inherit( self, MENU_COMMAND_BASE:New( MenuText, MenuParentPath, CommandMenuFunction, arg ) ) -- Menu#MENU_CLIENT_COMMAND
  	
    self.MenuClient = Client
    self.MenuClientGroupID = Client:GetClientGroupID()
    self.MenuParentPath = MenuParentPath
    self.MenuText = MenuText
    self.ParentMenu = ParentMenu
  
    if not _MENUCLIENTS[self.MenuClientGroupID] then
      _MENUCLIENTS[self.MenuClientGroupID] = {}
    end
    
    local MenuPath = _MENUCLIENTS[self.MenuClientGroupID]
  
    self:T( { Client:GetClientGroupName(), MenuPath[table.concat(MenuParentPath)], MenuParentPath, MenuText, CommandMenuFunction, arg } )
  
    local MenuPathID = table.concat(MenuParentPath) .. "/" .. MenuText
    if MenuPath[MenuPathID] then
      missionCommands.removeItemForGroup( self.MenuClient:GetClientGroupID(), MenuPath[MenuPathID] )
    end
    
  	self.MenuPath = missionCommands.addCommandForGroup( self.MenuClient:GetClientGroupID(), MenuText, MenuParentPath, self.MenuCallHandler )
    MenuPath[MenuPathID] = self.MenuPath
   
    if ParentMenu and ParentMenu.Menus then
    	ParentMenu.Menus[self.MenuPath] = self
    end
  	
  	return self
  end
  
  --- Removes a menu structure for a client.
  -- @param #MENU_CLIENT_COMMAND self
  -- @return #nil
  function MENU_CLIENT_COMMAND:Remove()
    self:F( self.MenuPath )
  
    if not _MENUCLIENTS[self.MenuClientGroupID] then
      _MENUCLIENTS[self.MenuClientGroupID] = {}
    end
    
    local MenuPath = _MENUCLIENTS[self.MenuClientGroupID]
  
    if MenuPath[table.concat(self.MenuParentPath) .. "/" .. self.MenuText] then
      MenuPath[table.concat(self.MenuParentPath) .. "/" .. self.MenuText] = nil
    end
    
    missionCommands.removeItemForGroup( self.MenuClient:GetClientGroupID(), self.MenuPath )
    self.ParentMenu.Menus[self.MenuPath] = nil
    return nil
  end
end

--- MENU_GROUP

do
  -- This local variable is used to cache the menus registered under groups.
  -- Menus don't dissapear when groups for players are destroyed and restarted.
  -- So every menu for a client created must be tracked so that program logic accidentally does not create.
  -- the same menus twice during initialization logic.
  -- These menu classes are handling this logic with this variable.
  local _MENUGROUPS = {}

  --- @type MENU_GROUP
  -- @extends Core.Menu#MENU_BASE
  
  
  --- #MENU_GROUP class, extends @{Menu#MENU_BASE}
  -- 
  -- The MENU_GROUP class manages the main menus for coalitions.  
  -- You can add menus with the @{#MENU_GROUP.New} method, which constructs a MENU_GROUP object and returns you the object reference.
  -- Using this object reference, you can then remove ALL the menus and submenus underlying automatically with @{#MENU_GROUP.Remove}.
  -- 
  -- @usage
  --  -- This demo creates a menu structure for the two groups of planes.
  --  -- Each group will receive a different menu structure.
  --  -- To test, join the planes, then look at the other radio menus (Option F10).
  --  -- Then switch planes and check if the menu is still there.
  --  -- And play with the Add and Remove menu options.
  --  
  --  -- Note that in multi player, this will only work after the DCS groups bug is solved.
  --
  --  local function ShowStatus( PlaneGroup, StatusText, Coalition )
  --
  --    MESSAGE:New( Coalition, 15 ):ToRed()
  --    PlaneGroup:Message( StatusText, 15 )
  --  end
  --
  --  local MenuStatus = {}
  --
  --  local function RemoveStatusMenu( MenuGroup )
  --    local MenuGroupName = MenuGroup:GetName()
  --    MenuStatus[MenuGroupName]:Remove()
  --  end
  --
  --  --- @param Wrapper.Group#GROUP MenuGroup
  --  local function AddStatusMenu( MenuGroup )
  --    local MenuGroupName = MenuGroup:GetName()
  --    -- This would create a menu for the red coalition under the MenuCoalitionRed menu object.
  --    MenuStatus[MenuGroupName] = MENU_GROUP:New( MenuGroup, "Status for Planes" )
  --    MENU_GROUP_COMMAND:New( MenuGroup, "Show Status", MenuStatus[MenuGroupName], ShowStatus, MenuGroup, "Status of planes is ok!", "Message to Red Coalition" )
  --  end
  --
  --  SCHEDULER:New( nil,
  --    function()
  --      local PlaneGroup = GROUP:FindByName( "Plane 1" )
  --      if PlaneGroup and PlaneGroup:IsAlive() then
  --        local MenuManage = MENU_GROUP:New( PlaneGroup, "Manage Menus" )
  --        MENU_GROUP_COMMAND:New( PlaneGroup, "Add Status Menu Plane 1", MenuManage, AddStatusMenu, PlaneGroup )
  --        MENU_GROUP_COMMAND:New( PlaneGroup, "Remove Status Menu Plane 1", MenuManage, RemoveStatusMenu, PlaneGroup )
  --      end
  --    end, {}, 10, 10 )
  --
  --  SCHEDULER:New( nil,
  --    function()
  --      local PlaneGroup = GROUP:FindByName( "Plane 2" )
  --      if PlaneGroup and PlaneGroup:IsAlive() then
  --        local MenuManage = MENU_GROUP:New( PlaneGroup, "Manage Menus" )
  --        MENU_GROUP_COMMAND:New( PlaneGroup, "Add Status Menu Plane 2", MenuManage, AddStatusMenu, PlaneGroup )
  --        MENU_GROUP_COMMAND:New( PlaneGroup, "Remove Status Menu Plane 2", MenuManage, RemoveStatusMenu, PlaneGroup )
  --      end
  --    end, {}, 10, 10 )
  --
  -- @field #MENU_GROUP
  MENU_GROUP = {
    ClassName = "MENU_GROUP"
  }
  
  --- MENU_GROUP constructor. Creates a new radio menu item for a group.
  -- @param #MENU_GROUP self
  -- @param Wrapper.Group#GROUP MenuGroup The Group owning the menu.
  -- @param #string MenuText The text for the menu.
  -- @param #table ParentMenu The parent menu.
  -- @return #MENU_GROUP self
  function MENU_GROUP:New( MenuGroup, MenuText, ParentMenu )
  
    -- Determine if the menu was not already created and already visible at the group.
    -- If it is visible, then return the cached self, otherwise, create self and cache it.
    
    MenuGroup._Menus = MenuGroup._Menus or {}
    local Path = ( ParentMenu and ( table.concat( ParentMenu.MenuPath or {}, "@" ) .. "@" .. MenuText ) ) or MenuText 
    if MenuGroup._Menus[Path] then
      self = MenuGroup._Menus[Path]
    else
      self = BASE:Inherit( self, MENU_BASE:New( MenuText, ParentMenu ) )
      --if MenuGroup:IsAlive() then
        MenuGroup._Menus[Path] = self
      --end

      self.MenuGroup = MenuGroup
      self.Path = Path
      self.MenuGroupID = MenuGroup:GetID()
      self.MenuText = MenuText
      self.ParentMenu = ParentMenu

      self:T( { "Adding Menu ", MenuText, self.MenuParentPath } )
      self.MenuPath = missionCommands.addSubMenuForGroup( self.MenuGroupID, MenuText, self.MenuParentPath )

      if self.ParentMenu and self.ParentMenu.Menus then
        self.ParentMenu.Menus[MenuText] = self
        self:F( { self.ParentMenu.Menus, MenuText } )
        self.ParentMenu.MenuCount = self.ParentMenu.MenuCount + 1
      end
    end
    
    --self:F( { MenuGroup:GetName(), MenuText, ParentMenu.MenuPath } )

    return self
  end
  
  --- Removes the sub menus recursively of this MENU_GROUP.
  -- @param #MENU_GROUP self
  -- @param MenuTime
  -- @param MenuTag A Tag or Key to filter the menus to be refreshed with the Tag set.
  -- @return #MENU_GROUP self
  function MENU_GROUP:RemoveSubMenus( MenuTime, MenuTag )
    --self:F2( { self.MenuPath, MenuTime, self.MenuTime } )
  
    self:T( { "Removing Group SubMenus:", MenuTime, MenuTag, self.MenuGroup:GetName(), self.MenuPath } )
    for MenuText, Menu in pairs( self.Menus ) do
      Menu:Remove( MenuTime, MenuTag )
    end
  
  end


  --- Removes the main menu and sub menus recursively of this MENU_GROUP.
  -- @param #MENU_GROUP self
  -- @param MenuTime
  -- @param MenuTag A Tag or Key to filter the menus to be refreshed with the Tag set.
  -- @return #nil
  function MENU_GROUP:Remove( MenuTime, MenuTag )
    --self:F2( { self.MenuGroupID, self.MenuPath, MenuTime, self.MenuTime } )
  
    self:RemoveSubMenus( MenuTime, MenuTag )
    
    if not MenuTime or self.MenuTime ~= MenuTime then
      if ( not MenuTag ) or ( MenuTag and self.MenuTag and MenuTag == self.MenuTag ) then
        if self.MenuGroup._Menus[self.Path] then
          self = self.MenuGroup._Menus[self.Path]
        
          missionCommands.removeItemForGroup( self.MenuGroupID, self.MenuPath )
          if self.ParentMenu then
            self.ParentMenu.Menus[self.MenuText] = nil
            self.ParentMenu.MenuCount = self.ParentMenu.MenuCount - 1
            if self.ParentMenu.MenuCount == 0 then
              if self.MenuRemoveParent == true then
                self:T2( "Removing Parent Menu " )
                self.ParentMenu:Remove()
              end
            end
          end
        end
        self:T( { "Removing Group Menu:", MenuGroup = self.MenuGroup:GetName() } )
        self.MenuGroup._Menus[self.Path] = nil
        self = nil
      end
    end
  
    return nil
  end
  
  
  --- @type MENU_GROUP_COMMAND
  -- @extends Core.Menu#MENU_COMMAND_BASE
  
  --- # MENU_GROUP_COMMAND class, extends @{Menu#MENU_COMMAND_BASE}
  -- 
  -- The @{Menu#MENU_GROUP_COMMAND} class manages the command menus for coalitions, which allow players to execute functions during mission execution.  
  -- You can add menus with the @{#MENU_GROUP_COMMAND.New} method, which constructs a MENU_GROUP_COMMAND object and returns you the object reference.
  -- Using this object reference, you can then remove ALL the menus and submenus underlying automatically with @{#MENU_GROUP_COMMAND.Remove}.
  --
  -- @field #MENU_GROUP_COMMAND
  MENU_GROUP_COMMAND = {
    ClassName = "MENU_GROUP_COMMAND"
  }
  
  --- Creates a new radio command item for a group
  -- @param #MENU_GROUP_COMMAND self
  -- @param Wrapper.Group#GROUP MenuGroup The Group owning the menu.
  -- @param MenuText The text for the menu.
  -- @param ParentMenu The parent menu.
  -- @param CommandMenuFunction A function that is called when the menu key is pressed.
  -- @param CommandMenuArgument An argument for the function.
  -- @return #MENU_GROUP_COMMAND
  function MENU_GROUP_COMMAND:New( MenuGroup, MenuText, ParentMenu, CommandMenuFunction, ... )
   
    MenuGroup._Menus = MenuGroup._Menus or {}
    local Path = ( ParentMenu and ( table.concat( ParentMenu.MenuPath or {}, "@" ) .. "@" .. MenuText ) ) or MenuText
    if MenuGroup._Menus[Path] then
      self = MenuGroup._Menus[Path]
      --self:E( { Path=Path } ) 
      --self:E( { self.MenuTag, self.MenuTime, "Re-using Group Command Menu:", MenuGroup:GetName(), MenuText } )
      self:SetCommandMenuFunction( CommandMenuFunction )
      self:SetCommandMenuArguments( arg )
      return self
    end
    self = BASE:Inherit( self, MENU_COMMAND_BASE:New( MenuText, ParentMenu, CommandMenuFunction, arg ) )
    
    --if MenuGroup:IsAlive() then
      MenuGroup._Menus[Path] = self
    --end

    --self:E({Path=Path}) 
    self.Path = Path
    self.MenuGroup = MenuGroup
    self.MenuGroupID = MenuGroup:GetID()
    self.MenuText = MenuText
    self.ParentMenu = ParentMenu

    self:F( { "Adding Group Command Menu:", MenuGroup = MenuGroup:GetName(), MenuText = MenuText, MenuPath = self.MenuParentPath } )
    self.MenuPath = missionCommands.addCommandForGroup( self.MenuGroupID, MenuText, self.MenuParentPath, self.MenuCallHandler )

    if self.ParentMenu and self.ParentMenu.Menus then
      self.ParentMenu.Menus[MenuText] = self
      self.ParentMenu.MenuCount = self.ParentMenu.MenuCount + 1
      self:F2( { ParentMenu.Menus, MenuText } )
    end
--    end

    return self
  end
  
  --- Removes a menu structure for a group.
  -- @param #MENU_GROUP_COMMAND self
  -- @param MenuTime
  -- @param MenuTag A Tag or Key to filter the menus to be refreshed with the Tag set.
  -- @return #nil
  function MENU_GROUP_COMMAND:Remove( MenuTime, MenuTag )
    --self:F2( { self.MenuGroupID, self.MenuPath, MenuTime, self.MenuTime } )

    --self:E( { MenuTag = MenuTag, MenuTime = self.MenuTime, Path = self.Path } )
    if not MenuTime or self.MenuTime ~= MenuTime then
      if ( not MenuTag ) or ( MenuTag and self.MenuTag and MenuTag == self.MenuTag ) then
        if self.MenuGroup._Menus[self.Path] then
          self = self.MenuGroup._Menus[self.Path]
      
          missionCommands.removeItemForGroup( self.MenuGroupID, self.MenuPath )
          --self:E( { "Removing Group Command Menu:", MenuGroup = self.MenuGroup:GetName(), MenuText = self.MenuText, MenuPath = self.Path } )
  
          self.ParentMenu.Menus[self.MenuText] = nil
          self.ParentMenu.MenuCount = self.ParentMenu.MenuCount - 1
          if self.ParentMenu.MenuCount == 0 then
            if self.MenuRemoveParent == true then
              self:T2( "Removing Parent Menu " )
              self.ParentMenu:Remove()
            end
          end
  
          self.MenuGroup._Menus[self.Path] = nil
          self = nil
        end
      end
    end
    
    return nil
  end

end

--- **Core** -- ZONE classes define **zones** within your mission of **various forms**, with **various capabilities**.
-- 
-- ![Banner Image](..\Presentations\ZONE\Dia1.JPG)
-- 
-- ====
-- 
-- There are essentially two core functions that zones accomodate:
-- 
--   * Test if an object is within the zone boundaries.
--   * Provide the zone behaviour. Some zones are static, while others are moveable.
-- 
-- The object classes are using the zone classes to test the zone boundaries, which can take various forms:
-- 
--   * Test if completely within the zone.
--   * Test if partly within the zone (for @{Group#GROUP} objects).
--   * Test if not in the zone.
--   * Distance to the nearest intersecting point of the zone.
--   * Distance to the center of the zone.
--   * ...
-- 
-- Each of these ZONE classes have a zone name, and specific parameters defining the zone type:
--   
--   * @{#ZONE_BASE}: The ZONE_BASE class defining the base for all other zone classes.
--   * @{#ZONE_RADIUS}: The ZONE_RADIUS class defined by a zone name, a location and a radius.
--   * @{#ZONE}: The ZONE class, defined by the zone name as defined within the Mission Editor.
--   * @{#ZONE_UNIT}: The ZONE_UNIT class defines by a zone around a @{Unit#UNIT} with a radius.
--   * @{#ZONE_GROUP}: The ZONE_GROUP class defines by a zone around a @{Group#GROUP} with a radius.
--   * @{#ZONE_POLYGON}: The ZONE_POLYGON class defines by a sequence of @{Group#GROUP} waypoints within the Mission Editor, forming a polygon.
--
-- ==== 
-- 
-- ### Author: **Sven Van de Velde (FlightControl)**
-- ### Contributions: 
-- 
-- ====
-- 
-- @module Zone


--- @type ZONE_BASE
-- @field #string ZoneName Name of the zone.
-- @field #number ZoneProbability A value between 0 and 1. 0 = 0% and 1 = 100% probability.
-- @extends Core.Base#BASE


--- # ZONE_BASE class, extends @{Base#BASE}
-- 
-- This class is an abstract BASE class for derived classes, and is not meant to be instantiated.
-- 
-- ## Each zone has a name:
-- 
--   * @{#ZONE_BASE.GetName}(): Returns the name of the zone.
--   * @{#ZONE_BASE.SetName}(): Sets the name of the zone.
--   
-- 
-- ## Each zone implements two polymorphic functions defined in @{Zone#ZONE_BASE}:
-- 
--   * @{#ZONE_BASE.IsVec2InZone}(): Returns if a 2D vector is within the zone.
--   * @{#ZONE_BASE.IsVec3InZone}(): Returns if a 3D vector is within the zone.
--   * @{#ZONE_BASE.IsPointVec2InZone}(): Returns if a 2D point vector is within the zone.
--   * @{#ZONE_BASE.IsPointVec3InZone}(): Returns if a 3D point vector is within the zone.
--   
-- ## A zone has a probability factor that can be set to randomize a selection between zones:
-- 
--   * @{#ZONE_BASE.SetZoneProbability}(): Set the randomization probability of a zone to be selected, taking a value between 0 and 1 ( 0 = 0%, 1 = 100% )
--   * @{#ZONE_BASE.GetZoneProbability}(): Get the randomization probability of a zone to be selected, passing a value between 0 and 1 ( 0 = 0%, 1 = 100% )
--   * @{#ZONE_BASE.GetZoneMaybe}(): Get the zone taking into account the randomization probability. nil is returned if this zone is not a candidate.
-- 
-- ## A zone manages vectors:
-- 
--   * @{#ZONE_BASE.GetVec2}(): Returns the 2D vector coordinate of the zone.
--   * @{#ZONE_BASE.GetVec3}(): Returns the 3D vector coordinate of the zone.
--   * @{#ZONE_BASE.GetPointVec2}(): Returns the 2D point vector coordinate of the zone.
--   * @{#ZONE_BASE.GetPointVec3}(): Returns the 3D point vector coordinate of the zone.
--   * @{#ZONE_BASE.GetRandomVec2}(): Define a random 2D vector within the zone.
--   * @{#ZONE_BASE.GetRandomPointVec2}(): Define a random 2D point vector within the zone.
--   * @{#ZONE_BASE.GetRandomPointVec3}(): Define a random 3D point vector within the zone.
-- 
-- ## A zone has a bounding square:
-- 
--   * @{#ZONE_BASE.GetBoundingSquare}(): Get the outer most bounding square of the zone.
-- 
-- ## A zone can be marked: 
-- 
--   * @{#ZONE_BASE.SmokeZone}(): Smokes the zone boundaries in a color.
--   * @{#ZONE_BASE.FlareZone}(): Flares the zone boundaries in a color.
-- 
-- @field #ZONE_BASE
ZONE_BASE = {
  ClassName = "ZONE_BASE",
  ZoneName = "",
  ZoneProbability = 1,
  }


--- The ZONE_BASE.BoundingSquare
-- @type ZONE_BASE.BoundingSquare
-- @field Dcs.DCSTypes#Distance x1 The lower x coordinate (left down)
-- @field Dcs.DCSTypes#Distance y1 The lower y coordinate (left down)
-- @field Dcs.DCSTypes#Distance x2 The higher x coordinate (right up)
-- @field Dcs.DCSTypes#Distance y2 The higher y coordinate (right up)


--- ZONE_BASE constructor
-- @param #ZONE_BASE self
-- @param #string ZoneName Name of the zone.
-- @return #ZONE_BASE self
function ZONE_BASE:New( ZoneName )
  local self = BASE:Inherit( self, BASE:New() )
  self:F( ZoneName )

  self.ZoneName = ZoneName
  
  return self
end

--- Returns the name of the zone.
-- @param #ZONE_BASE self
-- @return #string The name of the zone.
function ZONE_BASE:GetName()
  self:F2()

  return self.ZoneName
end


--- Sets the name of the zone.
-- @param #ZONE_BASE self
-- @param #string ZoneName The name of the zone.
-- @return #ZONE_BASE
function ZONE_BASE:SetName( ZoneName )
  self:F2()

  self.ZoneName = ZoneName
end

--- Returns if a Vec2 is within the zone.
-- @param #ZONE_BASE self
-- @param Dcs.DCSTypes#Vec2 Vec2 The Vec2 to test.
-- @return #boolean true if the Vec2 is within the zone.
function ZONE_BASE:IsVec2InZone( Vec2 )
  self:F2( Vec2 )

  return false
end

--- Returns if a Vec3 is within the zone.
-- @param #ZONE_BASE self
-- @param Dcs.DCSTypes#Vec3 Vec3 The point to test.
-- @return #boolean true if the Vec3 is within the zone.
function ZONE_BASE:IsVec3InZone( Vec3 )
  self:F2( Vec3 )

  local InZone = self:IsVec2InZone( { x = Vec3.x, y = Vec3.z } )

  return InZone
end

--- Returns if a PointVec2 is within the zone.
-- @param #ZONE_BASE self
-- @param Core.Point#POINT_VEC2 PointVec2 The PointVec2 to test.
-- @return #boolean true if the PointVec2 is within the zone.
function ZONE_BASE:IsPointVec2InZone( PointVec2 )
  self:F2( PointVec2 )
  
  local InZone = self:IsVec2InZone( PointVec2:GetVec2() )

  return InZone
end

--- Returns if a PointVec3 is within the zone.
-- @param #ZONE_BASE self
-- @param Core.Point#POINT_VEC3 PointVec3 The PointVec3 to test.
-- @return #boolean true if the PointVec3 is within the zone.
function ZONE_BASE:IsPointVec3InZone( PointVec3 )
  self:F2( PointVec3 )

  local InZone = self:IsPointVec2InZone( PointVec3 )

  return InZone
end


--- Returns the @{DCSTypes#Vec2} coordinate of the zone.
-- @param #ZONE_BASE self
-- @return #nil.
function ZONE_BASE:GetVec2()
  self:F2( self.ZoneName )

  return nil 
end

--- Returns a @{Point#POINT_VEC2} of the zone.
-- @param #ZONE_BASE self
-- @param Dcs.DCSTypes#Distance Height The height to add to the land height where the center of the zone is located.
-- @return Core.Point#POINT_VEC2 The PointVec2 of the zone.
function ZONE_BASE:GetPointVec2()
  self:F2( self.ZoneName )
  
  local Vec2 = self:GetVec2()

  local PointVec2 = POINT_VEC2:NewFromVec2( Vec2 )

  self:T2( { PointVec2 } )
  
  return PointVec2  
end


--- Returns a @{Point#COORDINATE} of the zone.
-- @param #ZONE_BASE self
-- @return Core.Point#COORDINATE The Coordinate of the zone.
function ZONE_BASE:GetCoordinate()
  self:F2( self.ZoneName )
  
  local Vec2 = self:GetVec2()

  local Coordinate = COORDINATE:NewFromVec2( Vec2 )

  self:T2( { Coordinate } )
  
  return Coordinate  
end


--- Returns the @{DCSTypes#Vec3} of the zone.
-- @param #ZONE_BASE self
-- @param Dcs.DCSTypes#Distance Height The height to add to the land height where the center of the zone is located.
-- @return Dcs.DCSTypes#Vec3 The Vec3 of the zone.
function ZONE_BASE:GetVec3( Height )
  self:F2( self.ZoneName )
  
  Height = Height or 0
  
  local Vec2 = self:GetVec2()

  local Vec3 = { x = Vec2.x, y = Height and Height or land.getHeight( self:GetVec2() ), z = Vec2.y }

  self:T2( { Vec3 } )
  
  return Vec3  
end

--- Returns a @{Point#POINT_VEC3} of the zone.
-- @param #ZONE_BASE self
-- @param Dcs.DCSTypes#Distance Height The height to add to the land height where the center of the zone is located.
-- @return Core.Point#POINT_VEC3 The PointVec3 of the zone.
function ZONE_BASE:GetPointVec3( Height )
  self:F2( self.ZoneName )
  
  local Vec3 = self:GetVec3( Height )

  local PointVec3 = POINT_VEC3:NewFromVec3( Vec3 )

  self:T2( { PointVec3 } )
  
  return PointVec3  
end

--- Returns a @{Point#COORDINATE} of the zone.
-- @param #ZONE_BASE self
-- @param Dcs.DCSTypes#Distance Height The height to add to the land height where the center of the zone is located.
-- @return Core.Point#COORDINATE The Coordinate of the zone.
function ZONE_BASE:GetCoordinate( Height ) --R2.1
  self:F2( self.ZoneName )
  
  local Vec3 = self:GetVec3( Height )

  local PointVec3 = COORDINATE:NewFromVec3( Vec3 )

  self:T2( { PointVec3 } )
  
  return PointVec3  
end


--- Define a random @{DCSTypes#Vec2} within the zone.
-- @param #ZONE_BASE self
-- @return Dcs.DCSTypes#Vec2 The Vec2 coordinates.
function ZONE_BASE:GetRandomVec2()
  return nil
end

--- Define a random @{Point#POINT_VEC2} within the zone.
-- @param #ZONE_BASE self
-- @return Core.Point#POINT_VEC2 The PointVec2 coordinates.
function ZONE_BASE:GetRandomPointVec2()
  return nil
end

--- Define a random @{Point#POINT_VEC3} within the zone.
-- @param #ZONE_BASE self
-- @return Core.Point#POINT_VEC3 The PointVec3 coordinates.
function ZONE_BASE:GetRandomPointVec3()
  return nil
end

--- Get the bounding square the zone.
-- @param #ZONE_BASE self
-- @return #nil The bounding square.
function ZONE_BASE:GetBoundingSquare()
  --return { x1 = 0, y1 = 0, x2 = 0, y2 = 0 }
  return nil
end

--- Bound the zone boundaries with a tires.
-- @param #ZONE_BASE self
function ZONE_BASE:BoundZone()
  self:F2()

end

--- Smokes the zone boundaries in a color.
-- @param #ZONE_BASE self
-- @param Utilities.Utils#SMOKECOLOR SmokeColor The smoke color.
function ZONE_BASE:SmokeZone( SmokeColor )
  self:F2( SmokeColor )

end

--- Set the randomization probability of a zone to be selected.
-- @param #ZONE_BASE self
-- @param ZoneProbability A value between 0 and 1. 0 = 0% and 1 = 100% probability.
function ZONE_BASE:SetZoneProbability( ZoneProbability )
  self:F2( ZoneProbability )
  
  self.ZoneProbability = ZoneProbability or 1
  return self
end

--- Get the randomization probability of a zone to be selected.
-- @param #ZONE_BASE self
-- @return #number A value between 0 and 1. 0 = 0% and 1 = 100% probability.
function ZONE_BASE:GetZoneProbability()
  self:F2()
  
  return self.ZoneProbability
end

--- Get the zone taking into account the randomization probability of a zone to be selected.
-- @param #ZONE_BASE self
-- @return #ZONE_BASE The zone is selected taking into account the randomization probability factor.
-- @return #nil The zone is not selected taking into account the randomization probability factor.
function ZONE_BASE:GetZoneMaybe()
  self:F2()
  
  local Randomization = math.random()
  if Randomization <= self.ZoneProbability then
    return self
  else
    return nil
  end
end


--- The ZONE_RADIUS class, defined by a zone name, a location and a radius.
-- @type ZONE_RADIUS
-- @field Dcs.DCSTypes#Vec2 Vec2 The current location of the zone.
-- @field Dcs.DCSTypes#Distance Radius The radius of the zone.
-- @extends #ZONE_BASE

--- # ZONE_RADIUS class, extends @{Zone#ZONE_BASE}
-- 
-- The ZONE_RADIUS class defined by a zone name, a location and a radius.
-- This class implements the inherited functions from Core.Zone#ZONE_BASE taking into account the own zone format and properties.
-- 
-- ## ZONE_RADIUS constructor
-- 
--   * @{#ZONE_RADIUS.New}(): Constructor.
--   
-- ## Manage the radius of the zone
-- 
--   * @{#ZONE_RADIUS.SetRadius}(): Sets the radius of the zone.
--   * @{#ZONE_RADIUS.GetRadius}(): Returns the radius of the zone.
-- 
-- ## Manage the location of the zone
-- 
--   * @{#ZONE_RADIUS.SetVec2}(): Sets the @{DCSTypes#Vec2} of the zone.
--   * @{#ZONE_RADIUS.GetVec2}(): Returns the @{DCSTypes#Vec2} of the zone.
--   * @{#ZONE_RADIUS.GetVec3}(): Returns the @{DCSTypes#Vec3} of the zone, taking an additional height parameter.
-- 
-- ## Zone point randomization
-- 
-- Various functions exist to find random points within the zone.
-- 
--   * @{#ZONE_RADIUS.GetRandomVec2}(): Gets a random 2D point in the zone.
--   * @{#ZONE_RADIUS.GetRandomPointVec2}(): Gets a @{Point#POINT_VEC2} object representing a random 2D point in the zone.
--   * @{#ZONE_RADIUS.GetRandomPointVec3}(): Gets a @{Point#POINT_VEC3} object representing a random 3D point in the zone. Note that the height of the point is at landheight.
-- 
-- @field #ZONE_RADIUS
ZONE_RADIUS = {
	ClassName="ZONE_RADIUS",
	}

--- Constructor of @{#ZONE_RADIUS}, taking the zone name, the zone location and a radius.
-- @param #ZONE_RADIUS self
-- @param #string ZoneName Name of the zone.
-- @param Dcs.DCSTypes#Vec2 Vec2 The location of the zone.
-- @param Dcs.DCSTypes#Distance Radius The radius of the zone.
-- @return #ZONE_RADIUS self
function ZONE_RADIUS:New( ZoneName, Vec2, Radius )
	local self = BASE:Inherit( self, ZONE_BASE:New( ZoneName ) ) -- #ZONE_RADIUS
	self:F( { ZoneName, Vec2, Radius } )

	self.Radius = Radius
	self.Vec2 = Vec2
	
	return self
end

--- Bounds the zone with tires.
-- @param #ZONE_RADIUS self
-- @param #number Points (optional) The amount of points in the circle.
-- @param #boolean UnBound If true the tyres will be destroyed.
-- @return #ZONE_RADIUS self
function ZONE_RADIUS:BoundZone( Points, CountryID, UnBound )

  local Point = {}
  local Vec2 = self:GetVec2()

  Points = Points and Points or 360

  local Angle
  local RadialBase = math.pi*2
  
  --
  for Angle = 0, 360, (360 / Points ) do
    local Radial = Angle * RadialBase / 360
    Point.x = Vec2.x + math.cos( Radial ) * self:GetRadius()
    Point.y = Vec2.y + math.sin( Radial ) * self:GetRadius()
    
    local CountryName = _DATABASE.COUNTRY_NAME[CountryID]
    
    local Tire = {
        ["country"] = CountryName, 
        ["category"] = "Fortifications",
        ["canCargo"] = false,
        ["shape_name"] = "H-tyre_B_WF",
        ["type"] = "Black_Tyre_WF",
        --["unitId"] = Angle + 10000,
        ["y"] = Point.y,
        ["x"] = Point.x,
        ["name"] = string.format( "%s-Tire #%0d", self:GetName(), Angle ),
        ["heading"] = 0,
    } -- end of ["group"]

    local Group = coalition.addStaticObject( CountryID, Tire )
    if UnBound and UnBound == true then
      Group:destroy()
    end
  end

  return self
end


--- Smokes the zone boundaries in a color.
-- @param #ZONE_RADIUS self
-- @param Utilities.Utils#SMOKECOLOR SmokeColor The smoke color.
-- @param #number Points (optional) The amount of points in the circle.
-- @return #ZONE_RADIUS self
function ZONE_RADIUS:SmokeZone( SmokeColor, Points )
  self:F2( SmokeColor )

  local Point = {}
  local Vec2 = self:GetVec2()

  Points = Points and Points or 360

  local Angle
  local RadialBase = math.pi*2
  
  for Angle = 0, 360, 360 / Points do
    local Radial = Angle * RadialBase / 360
    Point.x = Vec2.x + math.cos( Radial ) * self:GetRadius()
    Point.y = Vec2.y + math.sin( Radial ) * self:GetRadius()
    POINT_VEC2:New( Point.x, Point.y ):Smoke( SmokeColor )
  end

  return self
end


--- Flares the zone boundaries in a color.
-- @param #ZONE_RADIUS self
-- @param Utilities.Utils#FLARECOLOR FlareColor The flare color.
-- @param #number Points (optional) The amount of points in the circle.
-- @param Dcs.DCSTypes#Azimuth Azimuth (optional) Azimuth The azimuth of the flare.
-- @return #ZONE_RADIUS self
function ZONE_RADIUS:FlareZone( FlareColor, Points, Azimuth )
  self:F2( { FlareColor, Azimuth } )

  local Point = {}
  local Vec2 = self:GetVec2()
  
  Points = Points and Points or 360

  local Angle
  local RadialBase = math.pi*2
  
  for Angle = 0, 360, 360 / Points do
    local Radial = Angle * RadialBase / 360
    Point.x = Vec2.x + math.cos( Radial ) * self:GetRadius()
    Point.y = Vec2.y + math.sin( Radial ) * self:GetRadius()
    POINT_VEC2:New( Point.x, Point.y ):Flare( FlareColor, Azimuth )
  end

  return self
end

--- Returns the radius of the zone.
-- @param #ZONE_RADIUS self
-- @return Dcs.DCSTypes#Distance The radius of the zone.
function ZONE_RADIUS:GetRadius()
  self:F2( self.ZoneName )

  self:T2( { self.Radius } )

  return self.Radius
end

--- Sets the radius of the zone.
-- @param #ZONE_RADIUS self
-- @param Dcs.DCSTypes#Distance Radius The radius of the zone.
-- @return Dcs.DCSTypes#Distance The radius of the zone.
function ZONE_RADIUS:SetRadius( Radius )
  self:F2( self.ZoneName )

  self.Radius = Radius
  self:T2( { self.Radius } )

  return self.Radius
end

--- Returns the @{DCSTypes#Vec2} of the zone.
-- @param #ZONE_RADIUS self
-- @return Dcs.DCSTypes#Vec2 The location of the zone.
function ZONE_RADIUS:GetVec2()
	self:F2( self.ZoneName )

	self:T2( { self.Vec2 } )
	
	return self.Vec2	
end

--- Sets the @{DCSTypes#Vec2} of the zone.
-- @param #ZONE_RADIUS self
-- @param Dcs.DCSTypes#Vec2 Vec2 The new location of the zone.
-- @return Dcs.DCSTypes#Vec2 The new location of the zone.
function ZONE_RADIUS:SetVec2( Vec2 )
  self:F2( self.ZoneName )
  
  self.Vec2 = Vec2

  self:T2( { self.Vec2 } )
  
  return self.Vec2 
end

--- Returns the @{DCSTypes#Vec3} of the ZONE_RADIUS.
-- @param #ZONE_RADIUS self
-- @param Dcs.DCSTypes#Distance Height The height to add to the land height where the center of the zone is located.
-- @return Dcs.DCSTypes#Vec3 The point of the zone.
function ZONE_RADIUS:GetVec3( Height )
  self:F2( { self.ZoneName, Height } )

  Height = Height or 0
  local Vec2 = self:GetVec2()

  local Vec3 = { x = Vec2.x, y = land.getHeight( self:GetVec2() ) + Height, z = Vec2.y }

  self:T2( { Vec3 } )
  
  return Vec3  
end


--- Scan the zone
-- @param #ZONE_RADIUS self
-- @param ObjectCategories
-- @param Coalition
function ZONE_RADIUS:Scan( ObjectCategories )

  self.ScanData = {}
  self.ScanData.Coalitions = {}
  self.ScanData.Scenery = {}

  local ZoneCoord = self:GetCoordinate()
  local ZoneRadius = self:GetRadius()
  
  self:E({ZoneCoord = ZoneCoord, ZoneRadius = ZoneRadius, ZoneCoordLL = ZoneCoord:ToStringLLDMS()})

  local SphereSearch = {
    id = world.VolumeType.SPHERE,
      params = {
      point = ZoneCoord:GetVec3(),
      radius = ZoneRadius,
      }
    }

  local function EvaluateZone( ZoneObject )
    if ZoneObject:isExist() then
      local ObjectCategory = ZoneObject:getCategory()
      if ( ObjectCategory == Object.Category.UNIT and ZoneObject:isActive() ) or 
         ObjectCategory == Object.Category.STATIC then
        local CoalitionDCSUnit = ZoneObject:getCoalition()
        self.ScanData.Coalitions[CoalitionDCSUnit] = true
        self:E( { Name = ZoneObject:getName(), Coalition = CoalitionDCSUnit } )
      end
      if ObjectCategory == Object.Category.SCENERY then
        local SceneryType = ZoneObject:getTypeName()
        local SceneryName = ZoneObject:getName()
        self.ScanData.Scenery[SceneryType] = self.ScanData.Scenery[SceneryType] or {}
        self.ScanData.Scenery[SceneryType][SceneryName] = SCENERY:Register( SceneryName, ZoneObject )
        self:E( { SCENERY =  self.ScanData.Scenery[SceneryType][SceneryName] } )
      end
    end
    return true
  end

  world.searchObjects( ObjectCategories, SphereSearch, EvaluateZone )
  
end


function ZONE_RADIUS:CountScannedCoalitions()

  local Count = 0
  
  for CoalitionID, Coalition in pairs( self.ScanData.Coalitions ) do
    Count = Count + 1
  end
  return Count
end


--- Get Coalitions of the units in the Zone, or Check if there are units of the given Coalition in the Zone.
-- Returns nil if there are none ot two Coalitions in the zone!
-- Returns one Coalition if there are only Units of one Coalition in the Zone.
-- Returns the Coalition for the given Coalition if there are units of the Coalition in the Zone
-- @param #ZONE_RADIUS self
-- @return #table
function ZONE_RADIUS:GetScannedCoalition( Coalition )

  if Coalition then
    return self.ScanData.Coalitions[Coalition]
  else
    local Count = 0
    local ReturnCoalition = nil
    
    for CoalitionID, Coalition in pairs( self.ScanData.Coalitions ) do
      Count = Count + 1
      ReturnCoalition = CoalitionID
    end
    
    if Count ~= 1 then
      ReturnCoalition = nil
    end
    
    return ReturnCoalition
  end
end


function ZONE_RADIUS:GetScannedSceneryType( SceneryType )
  return self.ScanData.Scenery[SceneryType]
end


function ZONE_RADIUS:GetScannedScenery()
  return self.ScanData.Scenery
end


--- Is All in Zone of Coalition?
-- @param #ZONE_RADIUS self
-- @param Coalition
-- @return #boolean
function ZONE_RADIUS:IsAllInZoneOfCoalition( Coalition )

  return self:CountScannedCoalitions() == 1 and self:GetScannedCoalition( Coalition ) == true
end


--- Is All in Zone of Other Coalition?
-- @param #ZONE_RADIUS self
-- @param Coalition
-- @return #boolean
function ZONE_RADIUS:IsAllInZoneOfOtherCoalition( Coalition )

  self:E( { Coalitions = self.Coalitions, Count = self:CountScannedCoalitions() } )
  return self:CountScannedCoalitions() == 1 and self:GetScannedCoalition( Coalition ) == nil
end


--- Is Some in Zone of Coalition?
-- @param #ZONE_RADIUS self
-- @param Coalition
-- @return #boolean
function ZONE_RADIUS:IsSomeInZoneOfCoalition( Coalition )

  return self:CountScannedCoalitions() > 1 and self:GetScannedCoalition( Coalition ) == true
end


--- Is None in Zone of Coalition?
-- @param #ZONE_RADIUS self
-- @param Coalition
-- @return #boolean
function ZONE_RADIUS:IsNoneInZoneOfCoalition( Coalition )

  return self:GetScannedCoalition( Coalition ) == nil
end


--- Is None in Zone?
-- @param #ZONE_RADIUS self
-- @return #boolean
function ZONE_RADIUS:IsNoneInZone()

  return self:CountScannedCoalitions() == 0
end




--- Searches the zone
-- @param #ZONE_RADIUS self
-- @param ObjectCategories A list of categories, which are members of Object.Category
-- @param EvaluateFunction
function ZONE_RADIUS:SearchZone( EvaluateFunction, ObjectCategories )

  local SearchZoneResult = true

  local ZoneCoord = self:GetCoordinate()
  local ZoneRadius = self:GetRadius()
  
  self:E({ZoneCoord = ZoneCoord, ZoneRadius = ZoneRadius, ZoneCoordLL = ZoneCoord:ToStringLLDMS()})

  local SphereSearch = {
    id = world.VolumeType.SPHERE,
      params = {
      point = ZoneCoord:GetVec3(),
      radius = ZoneRadius / 2,
      }
    }

  local function EvaluateZone( ZoneDCSUnit )
  
    env.info( ZoneDCSUnit:getName() ) 
  
    local ZoneUnit = UNIT:Find( ZoneDCSUnit )

    return EvaluateFunction( ZoneUnit )
  end

  world.searchObjects( Object.Category.UNIT, SphereSearch, EvaluateZone )

end

--- Returns if a location is within the zone.
-- @param #ZONE_RADIUS self
-- @param Dcs.DCSTypes#Vec2 Vec2 The location to test.
-- @return #boolean true if the location is within the zone.
function ZONE_RADIUS:IsVec2InZone( Vec2 )
  self:F2( Vec2 )
  
  local ZoneVec2 = self:GetVec2()
  
  if ZoneVec2 then
    if (( Vec2.x - ZoneVec2.x )^2 + ( Vec2.y - ZoneVec2.y ) ^2 ) ^ 0.5 <= self:GetRadius() then
      return true
    end
  end
  
  return false
end

--- Returns if a point is within the zone.
-- @param #ZONE_RADIUS self
-- @param Dcs.DCSTypes#Vec3 Vec3 The point to test.
-- @return #boolean true if the point is within the zone.
function ZONE_RADIUS:IsVec3InZone( Vec3 )
  self:F2( Vec3 )

  local InZone = self:IsVec2InZone( { x = Vec3.x, y = Vec3.z } )

  return InZone
end

--- Returns a random Vec2 location within the zone.
-- @param #ZONE_RADIUS self
-- @param #number inner (optional) Minimal distance from the center of the zone. Default is 0.
-- @param #number outer (optional) Maximal distance from the outer edge of the zone. Default is the radius of the zone.
-- @return Dcs.DCSTypes#Vec2 The random location within the zone.
function ZONE_RADIUS:GetRandomVec2( inner, outer )
	self:F( self.ZoneName, inner, outer )

	local Point = {}
	local Vec2 = self:GetVec2()
	local _inner = inner or 0
	local _outer = outer or self:GetRadius()

	local angle = math.random() * math.pi * 2;
	Point.x = Vec2.x + math.cos( angle ) * math.random(_inner, _outer);
	Point.y = Vec2.y + math.sin( angle ) * math.random(_inner, _outer);
	
	self:T( { Point } )
	
	return Point
end

--- Returns a @{Point#POINT_VEC2} object reflecting a random 2D location within the zone.
-- @param #ZONE_RADIUS self
-- @param #number inner (optional) Minimal distance from the center of the zone. Default is 0.
-- @param #number outer (optional) Maximal distance from the outer edge of the zone. Default is the radius of the zone.
-- @return Core.Point#POINT_VEC2 The @{Point#POINT_VEC2} object reflecting the random 3D location within the zone.
function ZONE_RADIUS:GetRandomPointVec2( inner, outer )
  self:F( self.ZoneName, inner, outer )

  local PointVec2 = POINT_VEC2:NewFromVec2( self:GetRandomVec2() )

  self:T3( { PointVec2 } )
  
  return PointVec2
end

--- Returns a @{Point#POINT_VEC3} object reflecting a random 3D location within the zone.
-- @param #ZONE_RADIUS self
-- @param #number inner (optional) Minimal distance from the center of the zone. Default is 0.
-- @param #number outer (optional) Maximal distance from the outer edge of the zone. Default is the radius of the zone.
-- @return Core.Point#POINT_VEC3 The @{Point#POINT_VEC3} object reflecting the random 3D location within the zone.
function ZONE_RADIUS:GetRandomPointVec3( inner, outer )
  self:F( self.ZoneName, inner, outer )

  local PointVec3 = POINT_VEC3:NewFromVec2( self:GetRandomVec2() )

  self:T3( { PointVec3 } )
  
  return PointVec3
end


--- Returns a @{Point#COORDINATE} object reflecting a random 3D location within the zone.
-- @param #ZONE_RADIUS self
-- @param #number inner (optional) Minimal distance from the center of the zone. Default is 0.
-- @param #number outer (optional) Maximal distance from the outer edge of the zone. Default is the radius of the zone.
-- @return Core.Point#COORDINATE
function ZONE_RADIUS:GetRandomCoordinate( inner, outer )
  self:F( self.ZoneName, inner, outer )

  local Coordinate = COORDINATE:NewFromVec2( self:GetRandomVec2() )

  self:T3( { Coordinate = Coordinate } )
  
  return Coordinate
end



--- @type ZONE
-- @extends #ZONE_RADIUS


--- # ZONE class, extends @{Zone#ZONE_RADIUS}
-- 
-- The ZONE class, defined by the zone name as defined within the Mission Editor.
-- This class implements the inherited functions from @{#ZONE_RADIUS} taking into account the own zone format and properties.
-- 
-- @field #ZONE 
ZONE = {
  ClassName="ZONE",
  }


--- Constructor of ZONE, taking the zone name.
-- @param #ZONE self
-- @param #string ZoneName The name of the zone as defined within the mission editor.
-- @return #ZONE
function ZONE:New( ZoneName )

  local Zone = trigger.misc.getZone( ZoneName )
  
  if not Zone then
    error( "Zone " .. ZoneName .. " does not exist." )
    return nil
  end

  local self = BASE:Inherit( self, ZONE_RADIUS:New( ZoneName, { x = Zone.point.x, y = Zone.point.z }, Zone.radius ) )
  self:F( ZoneName )

  self.Zone = Zone
  
  return self
end


--- @type ZONE_UNIT
-- @field Wrapper.Unit#UNIT ZoneUNIT
-- @extends Core.Zone#ZONE_RADIUS

--- # ZONE_UNIT class, extends @{Zone#ZONE_RADIUS}
-- 
-- The ZONE_UNIT class defined by a zone around a @{Unit#UNIT} with a radius.
-- This class implements the inherited functions from @{#ZONE_RADIUS} taking into account the own zone format and properties.
-- 
-- @field #ZONE_UNIT
ZONE_UNIT = {
  ClassName="ZONE_UNIT",
  }
  
--- Constructor to create a ZONE_UNIT instance, taking the zone name, a zone unit and a radius.
-- @param #ZONE_UNIT self
-- @param #string ZoneName Name of the zone.
-- @param Wrapper.Unit#UNIT ZoneUNIT The unit as the center of the zone.
-- @param Dcs.DCSTypes#Distance Radius The radius of the zone.
-- @return #ZONE_UNIT self
function ZONE_UNIT:New( ZoneName, ZoneUNIT, Radius )
  local self = BASE:Inherit( self, ZONE_RADIUS:New( ZoneName, ZoneUNIT:GetVec2(), Radius ) )
  self:F( { ZoneName, ZoneUNIT:GetVec2(), Radius } )

  self.ZoneUNIT = ZoneUNIT
  self.LastVec2 = ZoneUNIT:GetVec2()
  
  return self
end


--- Returns the current location of the @{Unit#UNIT}.
-- @param #ZONE_UNIT self
-- @return Dcs.DCSTypes#Vec2 The location of the zone based on the @{Unit#UNIT}location.
function ZONE_UNIT:GetVec2()
  self:F2( self.ZoneName )
  
  local ZoneVec2 = self.ZoneUNIT:GetVec2()
  if ZoneVec2 then
    self.LastVec2 = ZoneVec2
    return ZoneVec2
  else
    return self.LastVec2
  end

  self:T2( { ZoneVec2 } )

  return nil  
end

--- Returns a random location within the zone.
-- @param #ZONE_UNIT self
-- @return Dcs.DCSTypes#Vec2 The random location within the zone.
function ZONE_UNIT:GetRandomVec2()
  self:F( self.ZoneName )

  local RandomVec2 = {}
  local Vec2 = self.ZoneUNIT:GetVec2()
  
  if not Vec2 then
    Vec2 = self.LastVec2
  end

  local angle = math.random() * math.pi*2;
  RandomVec2.x = Vec2.x + math.cos( angle ) * math.random() * self:GetRadius();
  RandomVec2.y = Vec2.y + math.sin( angle ) * math.random() * self:GetRadius();
  
  self:T( { RandomVec2 } )
  
  return RandomVec2
end

--- Returns the @{DCSTypes#Vec3} of the ZONE_UNIT.
-- @param #ZONE_UNIT self
-- @param Dcs.DCSTypes#Distance Height The height to add to the land height where the center of the zone is located.
-- @return Dcs.DCSTypes#Vec3 The point of the zone.
function ZONE_UNIT:GetVec3( Height )
  self:F2( self.ZoneName )
  
  Height = Height or 0
  
  local Vec2 = self:GetVec2()

  local Vec3 = { x = Vec2.x, y = land.getHeight( self:GetVec2() ) + Height, z = Vec2.y }

  self:T2( { Vec3 } )
  
  return Vec3  
end

--- @type ZONE_GROUP
-- @extends #ZONE_RADIUS


--- # ZONE_GROUP class, extends @{Zone#ZONE_RADIUS}
-- 
-- The ZONE_GROUP class defines by a zone around a @{Group#GROUP} with a radius. The current leader of the group defines the center of the zone.
-- This class implements the inherited functions from @{Zone#ZONE_RADIUS} taking into account the own zone format and properties.
-- 
-- @field #ZONE_GROUP
ZONE_GROUP = {
  ClassName="ZONE_GROUP",
  }
  
--- Constructor to create a ZONE_GROUP instance, taking the zone name, a zone @{Group#GROUP} and a radius.
-- @param #ZONE_GROUP self
-- @param #string ZoneName Name of the zone.
-- @param Wrapper.Group#GROUP ZoneGROUP The @{Group} as the center of the zone.
-- @param Dcs.DCSTypes#Distance Radius The radius of the zone.
-- @return #ZONE_GROUP self
function ZONE_GROUP:New( ZoneName, ZoneGROUP, Radius )
  local self = BASE:Inherit( self, ZONE_RADIUS:New( ZoneName, ZoneGROUP:GetVec2(), Radius ) )
  self:F( { ZoneName, ZoneGROUP:GetVec2(), Radius } )

  self._.ZoneGROUP = ZoneGROUP
  
  return self
end


--- Returns the current location of the @{Group}.
-- @param #ZONE_GROUP self
-- @return Dcs.DCSTypes#Vec2 The location of the zone based on the @{Group} location.
function ZONE_GROUP:GetVec2()
  self:F( self.ZoneName )
  
  local ZoneVec2 = self._.ZoneGROUP:GetVec2()

  self:T( { ZoneVec2 } )
  
  return ZoneVec2
end

--- Returns a random location within the zone of the @{Group}.
-- @param #ZONE_GROUP self
-- @return Dcs.DCSTypes#Vec2 The random location of the zone based on the @{Group} location.
function ZONE_GROUP:GetRandomVec2()
  self:F( self.ZoneName )

  local Point = {}
  local Vec2 = self._.ZoneGROUP:GetVec2()

  local angle = math.random() * math.pi*2;
  Point.x = Vec2.x + math.cos( angle ) * math.random() * self:GetRadius();
  Point.y = Vec2.y + math.sin( angle ) * math.random() * self:GetRadius();
  
  self:T( { Point } )
  
  return Point
end

--- Returns a @{Point#POINT_VEC2} object reflecting a random 2D location within the zone.
-- @param #ZONE_GROUP self
-- @param #number inner (optional) Minimal distance from the center of the zone. Default is 0.
-- @param #number outer (optional) Maximal distance from the outer edge of the zone. Default is the radius of the zone.
-- @return Core.Point#POINT_VEC2 The @{Point#POINT_VEC2} object reflecting the random 3D location within the zone.
function ZONE_GROUP:GetRandomPointVec2( inner, outer )
  self:F( self.ZoneName, inner, outer )

  local PointVec2 = POINT_VEC2:NewFromVec2( self:GetRandomVec2() )

  self:T3( { PointVec2 } )
  
  return PointVec2
end


--- @type ZONE_POLYGON_BASE
-- --@field #ZONE_POLYGON_BASE.ListVec2 Polygon The polygon defined by an array of @{DCSTypes#Vec2}.
-- @extends #ZONE_BASE


--- # ZONE_POLYGON_BASE class, extends @{Zone#ZONE_BASE}
-- 
-- The ZONE_POLYGON_BASE class defined by a sequence of @{Group#GROUP} waypoints within the Mission Editor, forming a polygon.
-- This class implements the inherited functions from @{Zone#ZONE_RADIUS} taking into account the own zone format and properties.
-- This class is an abstract BASE class for derived classes, and is not meant to be instantiated.
-- 
-- ## Zone point randomization
-- 
-- Various functions exist to find random points within the zone.
-- 
--   * @{#ZONE_POLYGON_BASE.GetRandomVec2}(): Gets a random 2D point in the zone.
--   * @{#ZONE_POLYGON_BASE.GetRandomPointVec2}(): Return a @{Point#POINT_VEC2} object representing a random 2D point within the zone.
--   * @{#ZONE_POLYGON_BASE.GetRandomPointVec3}(): Return a @{Point#POINT_VEC3} object representing a random 3D point at landheight within the zone.
-- 
-- @field #ZONE_POLYGON_BASE
ZONE_POLYGON_BASE = {
  ClassName="ZONE_POLYGON_BASE",
  }

--- A points array.
-- @type ZONE_POLYGON_BASE.ListVec2
-- @list <Dcs.DCSTypes#Vec2>

--- Constructor to create a ZONE_POLYGON_BASE instance, taking the zone name and an array of @{DCSTypes#Vec2}, forming a polygon.
-- The @{Group#GROUP} waypoints define the polygon corners. The first and the last point are automatically connected.
-- @param #ZONE_POLYGON_BASE self
-- @param #string ZoneName Name of the zone.
-- @param #ZONE_POLYGON_BASE.ListVec2 PointsArray An array of @{DCSTypes#Vec2}, forming a polygon..
-- @return #ZONE_POLYGON_BASE self
function ZONE_POLYGON_BASE:New( ZoneName, PointsArray )
  local self = BASE:Inherit( self, ZONE_BASE:New( ZoneName ) )
  self:F( { ZoneName, PointsArray } )

  local i = 0
  
  self._.Polygon = {}
  
  for i = 1, #PointsArray do
    self._.Polygon[i] = {}
    self._.Polygon[i].x = PointsArray[i].x
    self._.Polygon[i].y = PointsArray[i].y
  end

  return self
end

--- Returns the center location of the polygon.
-- @param #ZONE_GROUP self
-- @return Dcs.DCSTypes#Vec2 The location of the zone based on the @{Group} location.
function ZONE_POLYGON_BASE:GetVec2()
  self:F( self.ZoneName )

  local Bounds = self:GetBoundingSquare()
  
  return { x = ( Bounds.x2 + Bounds.x1 ) / 2, y = ( Bounds.y2 + Bounds.y1 ) / 2 }  
end

--- Flush polygon coordinates as a table in DCS.log.
-- @param #ZONE_POLYGON_BASE self
-- @return #ZONE_POLYGON_BASE self
function ZONE_POLYGON_BASE:Flush()
  self:F2()

  self:E( { Polygon = self.ZoneName, Coordinates = self._.Polygon } )

  return self
end

--- Smokes the zone boundaries in a color.
-- @param #ZONE_POLYGON_BASE self
-- @param #boolean UnBound If true, the tyres will be destroyed.
-- @return #ZONE_POLYGON_BASE self
function ZONE_POLYGON_BASE:BoundZone( UnBound )

  local i 
  local j 
  local Segments = 10
  
  i = 1
  j = #self._.Polygon
  
  while i <= #self._.Polygon do
    self:T( { i, j, self._.Polygon[i], self._.Polygon[j] } )
    
    local DeltaX = self._.Polygon[j].x - self._.Polygon[i].x
    local DeltaY = self._.Polygon[j].y - self._.Polygon[i].y
    
    for Segment = 0, Segments do -- We divide each line in 5 segments and smoke a point on the line.
      local PointX = self._.Polygon[i].x + ( Segment * DeltaX / Segments )
      local PointY = self._.Polygon[i].y + ( Segment * DeltaY / Segments )
      local Tire = {
          ["country"] = "USA", 
          ["category"] = "Fortifications",
          ["canCargo"] = false,
          ["shape_name"] = "H-tyre_B_WF",
          ["type"] = "Black_Tyre_WF",
          ["y"] = PointY,
          ["x"] = PointX,
          ["name"] = string.format( "%s-Tire #%0d", self:GetName(), ((i - 1) * Segments) + Segment ),
          ["heading"] = 0,
      } -- end of ["group"]
      
      local Group = coalition.addStaticObject( country.id.USA, Tire )
      if UnBound and UnBound == true then
        Group:destroy()
      end
      
    end
    j = i
    i = i + 1
  end

  return self
end



--- Smokes the zone boundaries in a color.
-- @param #ZONE_POLYGON_BASE self
-- @param Utilities.Utils#SMOKECOLOR SmokeColor The smoke color.
-- @return #ZONE_POLYGON_BASE self
function ZONE_POLYGON_BASE:SmokeZone( SmokeColor )
  self:F2( SmokeColor )

  local i 
  local j 
  local Segments = 10
  
  i = 1
  j = #self._.Polygon
  
  while i <= #self._.Polygon do
    self:T( { i, j, self._.Polygon[i], self._.Polygon[j] } )
    
    local DeltaX = self._.Polygon[j].x - self._.Polygon[i].x
    local DeltaY = self._.Polygon[j].y - self._.Polygon[i].y
    
    for Segment = 0, Segments do -- We divide each line in 5 segments and smoke a point on the line.
      local PointX = self._.Polygon[i].x + ( Segment * DeltaX / Segments )
      local PointY = self._.Polygon[i].y + ( Segment * DeltaY / Segments )
      POINT_VEC2:New( PointX, PointY ):Smoke( SmokeColor )
    end
    j = i
    i = i + 1
  end

  return self
end




--- Returns if a location is within the zone.
-- Source learned and taken from: https://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html
-- @param #ZONE_POLYGON_BASE self
-- @param Dcs.DCSTypes#Vec2 Vec2 The location to test.
-- @return #boolean true if the location is within the zone.
function ZONE_POLYGON_BASE:IsVec2InZone( Vec2 )
  self:F2( Vec2 )

  local Next 
  local Prev 
  local InPolygon = false
  
  Next = 1
  Prev = #self._.Polygon
  
  while Next <= #self._.Polygon do
    self:T( { Next, Prev, self._.Polygon[Next], self._.Polygon[Prev] } )
    if ( ( ( self._.Polygon[Next].y > Vec2.y ) ~= ( self._.Polygon[Prev].y > Vec2.y ) ) and
         ( Vec2.x < ( self._.Polygon[Prev].x - self._.Polygon[Next].x ) * ( Vec2.y - self._.Polygon[Next].y ) / ( self._.Polygon[Prev].y - self._.Polygon[Next].y ) + self._.Polygon[Next].x ) 
       ) then
       InPolygon = not InPolygon
    end
    self:T2( { InPolygon = InPolygon } )
    Prev = Next
    Next = Next + 1
  end

  self:T( { InPolygon = InPolygon } )
  return InPolygon
end

--- Define a random @{DCSTypes#Vec2} within the zone.
-- @param #ZONE_POLYGON_BASE self
-- @return Dcs.DCSTypes#Vec2 The Vec2 coordinate.
function ZONE_POLYGON_BASE:GetRandomVec2()
  self:F2()

  --- It is a bit tricky to find a random point within a polygon. Right now i am doing it the dirty and inefficient way...
  local Vec2Found = false
  local Vec2
  local BS = self:GetBoundingSquare()
  
  self:T2( BS )
  
  while Vec2Found == false do
    Vec2 = { x = math.random( BS.x1, BS.x2 ), y = math.random( BS.y1, BS.y2 ) }
    self:T2( Vec2 )
    if self:IsVec2InZone( Vec2 ) then
      Vec2Found = true
    end
  end
  
  self:T2( Vec2 )

  return Vec2
end

--- Return a @{Point#POINT_VEC2} object representing a random 2D point at landheight within the zone.
-- @param #ZONE_POLYGON_BASE self
-- @return @{Point#POINT_VEC2}
function ZONE_POLYGON_BASE:GetRandomPointVec2()
  self:F2()

  local PointVec2 = POINT_VEC2:NewFromVec2( self:GetRandomVec2() )
  
  self:T2( PointVec2 )

  return PointVec2
end

--- Return a @{Point#POINT_VEC3} object representing a random 3D point at landheight within the zone.
-- @param #ZONE_POLYGON_BASE self
-- @return @{Point#POINT_VEC3}
function ZONE_POLYGON_BASE:GetRandomPointVec3()
  self:F2()

  local PointVec3 = POINT_VEC3:NewFromVec2( self:GetRandomVec2() )
  
  self:T2( PointVec3 )

  return PointVec3
end


--- Return a @{Point#COORDINATE} object representing a random 3D point at landheight within the zone.
-- @param #ZONE_POLYGON_BASE self
-- @return Core.Point#COORDINATE
function ZONE_POLYGON_BASE:GetRandomCoordinate()
  self:F2()

  local Coordinate = COORDINATE:NewFromVec2( self:GetRandomVec2() )
  
  self:T2( Coordinate )

  return Coordinate
end


--- Get the bounding square the zone.
-- @param #ZONE_POLYGON_BASE self
-- @return #ZONE_POLYGON_BASE.BoundingSquare The bounding square.
function ZONE_POLYGON_BASE:GetBoundingSquare()

  local x1 = self._.Polygon[1].x
  local y1 = self._.Polygon[1].y
  local x2 = self._.Polygon[1].x
  local y2 = self._.Polygon[1].y
  
  for i = 2, #self._.Polygon do
    self:T2( { self._.Polygon[i], x1, y1, x2, y2 } )
    x1 = ( x1 > self._.Polygon[i].x ) and self._.Polygon[i].x or x1
    x2 = ( x2 < self._.Polygon[i].x ) and self._.Polygon[i].x or x2
    y1 = ( y1 > self._.Polygon[i].y ) and self._.Polygon[i].y or y1
    y2 = ( y2 < self._.Polygon[i].y ) and self._.Polygon[i].y or y2
    
  end

  return { x1 = x1, y1 = y1, x2 = x2, y2 = y2 }
end


--- @type ZONE_POLYGON
-- @extends #ZONE_POLYGON_BASE


--- # ZONE_POLYGON class, extends @{Zone#ZONE_POLYGON_BASE}
-- 
-- The ZONE_POLYGON class defined by a sequence of @{Group#GROUP} waypoints within the Mission Editor, forming a polygon.
-- This class implements the inherited functions from @{Zone#ZONE_RADIUS} taking into account the own zone format and properties.
-- 
-- @field #ZONE_POLYGON
ZONE_POLYGON = {
  ClassName="ZONE_POLYGON",
  }

--- Constructor to create a ZONE_POLYGON instance, taking the zone name and the @{Group#GROUP} defined within the Mission Editor.
-- The @{Group#GROUP} waypoints define the polygon corners. The first and the last point are automatically connected by ZONE_POLYGON.
-- @param #ZONE_POLYGON self
-- @param #string ZoneName Name of the zone.
-- @param Wrapper.Group#GROUP ZoneGroup The GROUP waypoints as defined within the Mission Editor define the polygon shape.
-- @return #ZONE_POLYGON self
function ZONE_POLYGON:New( ZoneName, ZoneGroup )

  local GroupPoints = ZoneGroup:GetTaskRoute()

  local self = BASE:Inherit( self, ZONE_POLYGON_BASE:New( ZoneName, GroupPoints ) )
  self:F( { ZoneName, ZoneGroup, self._.Polygon } )

  return self
end


--- Constructor to create a ZONE_POLYGON instance, taking the zone name and the **name** of the @{Group#GROUP} defined within the Mission Editor.
-- The @{Group#GROUP} waypoints define the polygon corners. The first and the last point are automatically connected by ZONE_POLYGON.
-- @param #ZONE_POLYGON self
-- @param #string ZoneName Name of the zone.
-- @param #string GroupName The group name of the GROUP defining the waypoints within the Mission Editor to define the polygon shape.
-- @return #ZONE_POLYGON self
function ZONE_POLYGON:NewFromGroupName( ZoneName, GroupName )

  local ZoneGroup = GROUP:FindByName( GroupName )

  local GroupPoints = ZoneGroup:GetTaskRoute()

  local self = BASE:Inherit( self, ZONE_POLYGON_BASE:New( ZoneName, GroupPoints ) )
  self:F( { ZoneName, ZoneGroup, self._.Polygon } )

  return self
end

--- **Core** -- DATABASE manages the database of mission objects. 
-- 
-- ====
-- 
-- 1) @{#DATABASE} class, extends @{Base#BASE}
-- ===================================================
-- Mission designers can use the DATABASE class to refer to:
-- 
--  * STATICS
--  * UNITS
--  * GROUPS
--  * CLIENTS
--  * AIRBASES
--  * PLAYERSJOINED
--  * PLAYERS
--  * CARGOS
--  
-- On top, for internal MOOSE administration purposes, the DATBASE administers the Unit and Group TEMPLATES as defined within the Mission Editor.
-- 
-- Moose will automatically create one instance of the DATABASE class into the **global** object _DATABASE.
-- Moose refers to _DATABASE within the framework extensively, but you can also refer to the _DATABASE object within your missions if required.
-- 
-- 1.1) DATABASE iterators
-- -----------------------
-- You can iterate the database with the available iterator methods.
-- The iterator methods will walk the DATABASE set, and call for each element within the set a function that you provide.
-- The following iterator methods are currently available within the DATABASE:
-- 
--   * @{#DATABASE.ForEachUnit}: Calls a function for each @{UNIT} it finds within the DATABASE.
--   * @{#DATABASE.ForEachGroup}: Calls a function for each @{GROUP} it finds within the DATABASE.
--   * @{#DATABASE.ForEachPlayer}: Calls a function for each alive player it finds within the DATABASE.
--   * @{#DATABASE.ForEachPlayerJoined}: Calls a function for each joined player it finds within the DATABASE.
--   * @{#DATABASE.ForEachClient}: Calls a function for each @{CLIENT} it finds within the DATABASE.
--   * @{#DATABASE.ForEachClientAlive}: Calls a function for each alive @{CLIENT} it finds within the DATABASE.
-- 
-- ===
-- 
-- 
-- ### Author: **Sven Van de Velde (FlightControl)**
-- ### Contributions: 
-- 
-- ====
-- @module Database


--- DATABASE class
-- @type DATABASE
-- @extends Core.Base#BASE
DATABASE = {
  ClassName = "DATABASE",
  Templates = {
    Units = {},
    Groups = {},
    Statics = {},
    ClientsByName = {},
    ClientsByID = {},
  },
  UNITS = {},
  UNITS_Index = {},
  STATICS = {},
  GROUPS = {},
  PLAYERS = {},
  PLAYERSJOINED = {},
  PLAYERUNITS = {},
  CLIENTS = {},
  CARGOS = {},
  AIRBASES = {},
  COUNTRY_ID = {},
  COUNTRY_NAME = {},
  NavPoints = {},
  PLAYERSETTINGS = {},
  ZONENAMES = {},
  HITS = {},
  DESTROYS = {},
}

local _DATABASECoalition =
  {
    [1] = "Red",
    [2] = "Blue",
  }

local _DATABASECategory =
  {
    ["plane"] = Unit.Category.AIRPLANE,
    ["helicopter"] = Unit.Category.HELICOPTER,
    ["vehicle"] = Unit.Category.GROUND_UNIT,
    ["ship"] = Unit.Category.SHIP,
    ["static"] = Unit.Category.STRUCTURE,
  }


--- Creates a new DATABASE object, building a set of units belonging to a coalitions, categories, countries, types or with defined prefix names.
-- @param #DATABASE self
-- @return #DATABASE
-- @usage
-- -- Define a new DATABASE Object. This DBObject will contain a reference to all Group and Unit Templates defined within the ME and the DCSRTE.
-- DBObject = DATABASE:New()
function DATABASE:New()

  -- Inherits from BASE
  local self = BASE:Inherit( self, BASE:New() ) -- #DATABASE

  self:SetEventPriority( 1 )
  
  self:HandleEvent( EVENTS.Birth, self._EventOnBirth )
  self:HandleEvent( EVENTS.Dead, self._EventOnDeadOrCrash )
  self:HandleEvent( EVENTS.Crash, self._EventOnDeadOrCrash )
  self:HandleEvent( EVENTS.Hit, self.AccountHits )
  self:HandleEvent( EVENTS.NewCargo )
  self:HandleEvent( EVENTS.DeleteCargo )
  
  -- Follow alive players and clients
  self:HandleEvent( EVENTS.PlayerEnterUnit, self._EventOnPlayerEnterUnit )
  self:HandleEvent( EVENTS.PlayerLeaveUnit, self._EventOnPlayerLeaveUnit )
  
  self:_RegisterTemplates()
  self:_RegisterGroupsAndUnits()
  self:_RegisterClients()
  self:_RegisterStatics()
  --self:_RegisterPlayers()
  self:_RegisterAirbases()

  self.UNITS_Position = 0
  
  --- @param #DATABASE self
  local function CheckPlayers( self )
  
    local CoalitionsData = { AlivePlayersRed = coalition.getPlayers( coalition.side.RED ), AlivePlayersBlue = coalition.getPlayers( coalition.side.BLUE ) }
    for CoalitionId, CoalitionData in pairs( CoalitionsData ) do
      --self:E( { "CoalitionData:", CoalitionData } )
      for UnitId, UnitData in pairs( CoalitionData ) do
        if UnitData and UnitData:isExist() then
        
          local UnitName = UnitData:getName()
          local PlayerName = UnitData:getPlayerName()
          local PlayerUnit = UNIT:Find( UnitData )
          --self:T( { "UnitData:", UnitData, UnitName, PlayerName, PlayerUnit } )

          if PlayerName and PlayerName ~= "" then
            if self.PLAYERS[PlayerName] == nil or self.PLAYERS[PlayerName] ~= UnitName then
              --self:E( { "Add player for unit:", UnitName, PlayerName } )
              self:AddPlayer( UnitName, PlayerName )
              --_EVENTDISPATCHER:CreateEventPlayerEnterUnit( PlayerUnit )
              local Settings = SETTINGS:Set( PlayerName )
              Settings:SetPlayerMenu( PlayerUnit )
            end
          end
        end
      end
    end
  end
  
  self:E( "Scheduling" )
  PlayerCheckSchedule = SCHEDULER:New( nil, CheckPlayers, { self }, 1, 1 )
  
  return self
end

--- Finds a Unit based on the Unit Name.
-- @param #DATABASE self
-- @param #string UnitName
-- @return Wrapper.Unit#UNIT The found Unit.
function DATABASE:FindUnit( UnitName )

  local UnitFound = self.UNITS[UnitName]
  return UnitFound
end


--- Adds a Unit based on the Unit Name in the DATABASE.
-- @param #DATABASE self
function DATABASE:AddUnit( DCSUnitName )

  if not  self.UNITS[DCSUnitName] then
    local UnitRegister = UNIT:Register( DCSUnitName )
    self.UNITS[DCSUnitName] = UNIT:Register( DCSUnitName )
    
    table.insert( self.UNITS_Index, DCSUnitName )
  end
  
  return self.UNITS[DCSUnitName]
end


--- Deletes a Unit from the DATABASE based on the Unit Name.
-- @param #DATABASE self
function DATABASE:DeleteUnit( DCSUnitName )

  self.UNITS[DCSUnitName] = nil 
end

--- Adds a Static based on the Static Name in the DATABASE.
-- @param #DATABASE self
function DATABASE:AddStatic( DCSStaticName )

  if not self.STATICS[DCSStaticName] then
    self.STATICS[DCSStaticName] = STATIC:Register( DCSStaticName )
  end
end


--- Deletes a Static from the DATABASE based on the Static Name.
-- @param #DATABASE self
function DATABASE:DeleteStatic( DCSStaticName )

  --self.STATICS[DCSStaticName] = nil 
end

--- Finds a STATIC based on the StaticName.
-- @param #DATABASE self
-- @param #string StaticName
-- @return Wrapper.Static#STATIC The found STATIC.
function DATABASE:FindStatic( StaticName )

  local StaticFound = self.STATICS[StaticName]
  return StaticFound
end

--- Finds a AIRBASE based on the AirbaseName.
-- @param #DATABASE self
-- @param #string AirbaseName
-- @return Wrapper.Airbase#AIRBASE The found AIRBASE.
function DATABASE:FindAirbase( AirbaseName )

  local AirbaseFound = self.AIRBASES[AirbaseName]
  return AirbaseFound
end

--- Adds a Airbase based on the Airbase Name in the DATABASE.
-- @param #DATABASE self
-- @param #string AirbaseName The name of the airbase
function DATABASE:AddAirbase( AirbaseName )

  if not self.AIRBASES[AirbaseName] then
    self.AIRBASES[AirbaseName] = AIRBASE:Register( AirbaseName )
  end
end


--- Deletes a Airbase from the DATABASE based on the Airbase Name.
-- @param #DATABASE self
-- @param #string AirbaseName The name of the airbase
function DATABASE:DeleteAirbase( AirbaseName )

  self.AIRBASES[AirbaseName] = nil 
end

--- Finds an AIRBASE based on the AirbaseName.
-- @param #DATABASE self
-- @param #string AirbaseName
-- @return Wrapper.Airbase#AIRBASE The found AIRBASE.
function DATABASE:FindAirbase( AirbaseName )

  local AirbaseFound = self.AIRBASES[AirbaseName]
  return AirbaseFound
end

--- Adds a Cargo based on the Cargo Name in the DATABASE.
-- @param #DATABASE self
-- @param #string CargoName The name of the airbase
function DATABASE:AddCargo( Cargo )

  if not self.CARGOS[Cargo.Name] then
    self.CARGOS[Cargo.Name] = Cargo
  end
end


--- Deletes a Cargo from the DATABASE based on the Cargo Name.
-- @param #DATABASE self
-- @param #string CargoName The name of the airbase
function DATABASE:DeleteCargo( CargoName )

  self.CARGOS[CargoName] = nil 
end

--- Finds an CARGO based on the CargoName.
-- @param #DATABASE self
-- @param #string CargoName
-- @return Wrapper.Cargo#CARGO The found CARGO.
function DATABASE:FindCargo( CargoName )

  local CargoFound = self.CARGOS[CargoName]
  return CargoFound
end


--- Finds a CLIENT based on the ClientName.
-- @param #DATABASE self
-- @param #string ClientName
-- @return Wrapper.Client#CLIENT The found CLIENT.
function DATABASE:FindClient( ClientName )

  local ClientFound = self.CLIENTS[ClientName]
  return ClientFound
end


--- Adds a CLIENT based on the ClientName in the DATABASE.
-- @param #DATABASE self
function DATABASE:AddClient( ClientName )

  if not self.CLIENTS[ClientName] then
    self.CLIENTS[ClientName] = CLIENT:Register( ClientName )
  end

  return self.CLIENTS[ClientName]
end


--- Finds a GROUP based on the GroupName.
-- @param #DATABASE self
-- @param #string GroupName
-- @return Wrapper.Group#GROUP The found GROUP.
function DATABASE:FindGroup( GroupName )

  local GroupFound = self.GROUPS[GroupName]
  return GroupFound
end


--- Adds a GROUP based on the GroupName in the DATABASE.
-- @param #DATABASE self
function DATABASE:AddGroup( GroupName )

  if not self.GROUPS[GroupName] then
    self:E( { "Add GROUP:", GroupName } )
    self.GROUPS[GroupName] = GROUP:Register( GroupName )
  end  
  
  return self.GROUPS[GroupName] 
end

--- Adds a player based on the Player Name in the DATABASE.
-- @param #DATABASE self
function DATABASE:AddPlayer( UnitName, PlayerName )

  if PlayerName then
    self:E( { "Add player for unit:", UnitName, PlayerName } )
    self.PLAYERS[PlayerName] = UnitName
    self.PLAYERUNITS[UnitName] = PlayerName
    self.PLAYERSJOINED[PlayerName] = PlayerName
  end
end

--- Deletes a player from the DATABASE based on the Player Name.
-- @param #DATABASE self
function DATABASE:DeletePlayer( UnitName, PlayerName )

  if PlayerName then
    self:E( { "Clean player:", PlayerName } )
    self.PLAYERS[PlayerName] = nil
    self.PLAYERUNITS[UnitName] = PlayerName
  end
end


--- Instantiate new Groups within the DCSRTE.
-- This method expects EXACTLY the same structure as a structure within the ME, and needs 2 additional fields defined:
-- SpawnCountryID, SpawnCategoryID
-- This method is used by the SPAWN class.
-- @param #DATABASE self
-- @param #table SpawnTemplate
-- @return #DATABASE self
function DATABASE:Spawn( SpawnTemplate )
  self:F( SpawnTemplate.name )

  self:T( { SpawnTemplate.SpawnCountryID, SpawnTemplate.SpawnCategoryID } )

  -- Copy the spawn variables of the template in temporary storage, nullify, and restore the spawn variables.
  local SpawnCoalitionID = SpawnTemplate.CoalitionID
  local SpawnCountryID = SpawnTemplate.CountryID
  local SpawnCategoryID = SpawnTemplate.CategoryID

  -- Nullify
  SpawnTemplate.CoalitionID = nil
  SpawnTemplate.CountryID = nil
  SpawnTemplate.CategoryID = nil

  self:_RegisterGroupTemplate( SpawnTemplate, SpawnCoalitionID, SpawnCategoryID, SpawnCountryID  )

  self:T3( SpawnTemplate )
  coalition.addGroup( SpawnCountryID, SpawnCategoryID, SpawnTemplate )

  -- Restore
  SpawnTemplate.CoalitionID = SpawnCoalitionID
  SpawnTemplate.CountryID = SpawnCountryID
  SpawnTemplate.CategoryID = SpawnCategoryID

  -- Ensure that for the spawned group and its units, there are GROUP and UNIT objects created in the DATABASE.
  local SpawnGroup = self:AddGroup( SpawnTemplate.name )
  for UnitID, UnitData in pairs( SpawnTemplate.units ) do
    self:AddUnit( UnitData.name )
  end
  
  return SpawnGroup
end

--- Set a status to a Group within the Database, this to check crossing events for example.
function DATABASE:SetStatusGroup( GroupName, Status )
  self:F2( Status )

  self.Templates.Groups[GroupName].Status = Status
end

--- Get a status to a Group within the Database, this to check crossing events for example.
function DATABASE:GetStatusGroup( GroupName )
  self:F2( Status )

  if self.Templates.Groups[GroupName] then
    return self.Templates.Groups[GroupName].Status
  else
    return ""
  end
end

--- Private method that registers new Group Templates within the DATABASE Object.
-- @param #DATABASE self
-- @param #table GroupTemplate
-- @return #DATABASE self
function DATABASE:_RegisterGroupTemplate( GroupTemplate, CoalitionID, CategoryID, CountryID )

  local GroupTemplateName = env.getValueDictByKey(GroupTemplate.name)
  
  local TraceTable = {}

  if not self.Templates.Groups[GroupTemplateName] then
    self.Templates.Groups[GroupTemplateName] = {}
    self.Templates.Groups[GroupTemplateName].Status = nil
  end
  
  -- Delete the spans from the route, it is not needed and takes memory.
  if GroupTemplate.route and GroupTemplate.route.spans then 
    GroupTemplate.route.spans = nil
  end
  
  GroupTemplate.CategoryID = CategoryID
  GroupTemplate.CoalitionID = CoalitionID
  GroupTemplate.CountryID = CountryID
  
  self.Templates.Groups[GroupTemplateName].GroupName = GroupTemplateName
  self.Templates.Groups[GroupTemplateName].Template = GroupTemplate
  self.Templates.Groups[GroupTemplateName].groupId = GroupTemplate.groupId
  self.Templates.Groups[GroupTemplateName].UnitCount = #GroupTemplate.units
  self.Templates.Groups[GroupTemplateName].Units = GroupTemplate.units
  self.Templates.Groups[GroupTemplateName].CategoryID = CategoryID
  self.Templates.Groups[GroupTemplateName].CoalitionID = CoalitionID
  self.Templates.Groups[GroupTemplateName].CountryID = CountryID

  
  TraceTable[#TraceTable+1] = "Group"
  TraceTable[#TraceTable+1] = self.Templates.Groups[GroupTemplateName].GroupName

  TraceTable[#TraceTable+1] = "Coalition"
  TraceTable[#TraceTable+1] = self.Templates.Groups[GroupTemplateName].CoalitionID
  TraceTable[#TraceTable+1] = "Category"
  TraceTable[#TraceTable+1] = self.Templates.Groups[GroupTemplateName].CategoryID
  TraceTable[#TraceTable+1] = "Country"
  TraceTable[#TraceTable+1] = self.Templates.Groups[GroupTemplateName].CountryID

  TraceTable[#TraceTable+1] = "Units"

  for unit_num, UnitTemplate in pairs( GroupTemplate.units ) do

    UnitTemplate.name = env.getValueDictByKey(UnitTemplate.name)
    
    self.Templates.Units[UnitTemplate.name] = {}
    self.Templates.Units[UnitTemplate.name].UnitName = UnitTemplate.name
    self.Templates.Units[UnitTemplate.name].Template = UnitTemplate
    self.Templates.Units[UnitTemplate.name].GroupName = GroupTemplateName
    self.Templates.Units[UnitTemplate.name].GroupTemplate = GroupTemplate
    self.Templates.Units[UnitTemplate.name].GroupId = GroupTemplate.groupId
    self.Templates.Units[UnitTemplate.name].CategoryID = CategoryID
    self.Templates.Units[UnitTemplate.name].CoalitionID = CoalitionID
    self.Templates.Units[UnitTemplate.name].CountryID = CountryID

    if UnitTemplate.skill and (UnitTemplate.skill == "Client" or UnitTemplate.skill == "Player") then
      self.Templates.ClientsByName[UnitTemplate.name] = UnitTemplate
      self.Templates.ClientsByName[UnitTemplate.name].CategoryID = CategoryID
      self.Templates.ClientsByName[UnitTemplate.name].CoalitionID = CoalitionID
      self.Templates.ClientsByName[UnitTemplate.name].CountryID = CountryID
      self.Templates.ClientsByID[UnitTemplate.unitId] = UnitTemplate
    end
    
    TraceTable[#TraceTable+1] = self.Templates.Units[UnitTemplate.name].UnitName 
  end

  self:E( TraceTable )
end

function DATABASE:GetGroupTemplate( GroupName )
  local GroupTemplate = self.Templates.Groups[GroupName].Template
  GroupTemplate.SpawnCoalitionID = self.Templates.Groups[GroupName].CoalitionID
  GroupTemplate.SpawnCategoryID = self.Templates.Groups[GroupName].CategoryID
  GroupTemplate.SpawnCountryID = self.Templates.Groups[GroupName].CountryID
  return GroupTemplate
end

--- Private method that registers new Static Templates within the DATABASE Object.
-- @param #DATABASE self
-- @param #table GroupTemplate
-- @return #DATABASE self
function DATABASE:_RegisterStaticTemplate( StaticTemplate, CoalitionID, CategoryID, CountryID )

  local TraceTable = {}

  local StaticTemplateName = env.getValueDictByKey(StaticTemplate.name)
  
  self.Templates.Statics[StaticTemplateName] = self.Templates.Statics[StaticTemplateName] or {}
  
  StaticTemplate.CategoryID = CategoryID
  StaticTemplate.CoalitionID = CoalitionID
  StaticTemplate.CountryID = CountryID
  
  self.Templates.Statics[StaticTemplateName].StaticName = StaticTemplateName
  self.Templates.Statics[StaticTemplateName].GroupTemplate = StaticTemplate
  self.Templates.Statics[StaticTemplateName].UnitTemplate = StaticTemplate.units[1]
  self.Templates.Statics[StaticTemplateName].CategoryID = CategoryID
  self.Templates.Statics[StaticTemplateName].CoalitionID = CoalitionID
  self.Templates.Statics[StaticTemplateName].CountryID = CountryID

  
  TraceTable[#TraceTable+1] = "Static"
  TraceTable[#TraceTable+1] = self.Templates.Statics[StaticTemplateName].GroupName

  TraceTable[#TraceTable+1] = "Coalition"
  TraceTable[#TraceTable+1] = self.Templates.Statics[StaticTemplateName].CoalitionID
  TraceTable[#TraceTable+1] = "Category"
  TraceTable[#TraceTable+1] = self.Templates.Statics[StaticTemplateName].CategoryID
  TraceTable[#TraceTable+1] = "Country"
  TraceTable[#TraceTable+1] = self.Templates.Statics[StaticTemplateName].CountryID

  self:E( TraceTable )
end


--- @param #DATABASE self
function DATABASE:GetStaticUnitTemplate( StaticName )
  local StaticTemplate = self.Templates.Statics[StaticName].UnitTemplate
  StaticTemplate.SpawnCoalitionID = self.Templates.Statics[StaticName].CoalitionID
  StaticTemplate.SpawnCategoryID = self.Templates.Statics[StaticName].CategoryID
  StaticTemplate.SpawnCountryID = self.Templates.Statics[StaticName].CountryID
  return StaticTemplate
end


function DATABASE:GetGroupNameFromUnitName( UnitName )
  return self.Templates.Units[UnitName].GroupName
end

function DATABASE:GetGroupTemplateFromUnitName( UnitName )
  return self.Templates.Units[UnitName].GroupTemplate
end

function DATABASE:GetCoalitionFromClientTemplate( ClientName )
  return self.Templates.ClientsByName[ClientName].CoalitionID
end

function DATABASE:GetCategoryFromClientTemplate( ClientName )
  return self.Templates.ClientsByName[ClientName].CategoryID
end

function DATABASE:GetCountryFromClientTemplate( ClientName )
  return self.Templates.ClientsByName[ClientName].CountryID
end

--- Airbase

function DATABASE:GetCoalitionFromAirbase( AirbaseName )
  return self.AIRBASES[AirbaseName]:GetCoalition()
end

function DATABASE:GetCategoryFromAirbase( AirbaseName )
  return self.AIRBASES[AirbaseName]:GetCategory()
end



--- Private method that registers all alive players in the mission.
-- @param #DATABASE self
-- @return #DATABASE self
function DATABASE:_RegisterPlayers()

  local CoalitionsData = { AlivePlayersRed = coalition.getPlayers( coalition.side.RED ), AlivePlayersBlue = coalition.getPlayers( coalition.side.BLUE ) }
  for CoalitionId, CoalitionData in pairs( CoalitionsData ) do
    for UnitId, UnitData in pairs( CoalitionData ) do
      self:T3( { "UnitData:", UnitData } )
      if UnitData and UnitData:isExist() then
        local UnitName = UnitData:getName()
        local PlayerName = UnitData:getPlayerName()
        if not self.PLAYERS[PlayerName] then
          self:E( { "Add player for unit:", UnitName, PlayerName } )
          self:AddPlayer( UnitName, PlayerName )
        end
      end
    end
  end
  
  return self
end


--- Private method that registers all Groups and Units within in the mission.
-- @param #DATABASE self
-- @return #DATABASE self
function DATABASE:_RegisterGroupsAndUnits()

  local CoalitionsData = { GroupsRed = coalition.getGroups( coalition.side.RED ), GroupsBlue = coalition.getGroups( coalition.side.BLUE ) }
  for CoalitionId, CoalitionData in pairs( CoalitionsData ) do
    for DCSGroupId, DCSGroup in pairs( CoalitionData ) do

      if DCSGroup:isExist() then
        local DCSGroupName = DCSGroup:getName()
  
        self:E( { "Register Group:", DCSGroupName } )
        self:AddGroup( DCSGroupName )

        for DCSUnitId, DCSUnit in pairs( DCSGroup:getUnits() ) do
  
          local DCSUnitName = DCSUnit:getName()
          self:E( { "Register Unit:", DCSUnitName } )
          self:AddUnit( DCSUnitName )
        end
      else
        self:E( { "Group does not exist: ",  DCSGroup } )
      end
      
    end
  end

  return self
end

--- Private method that registers all Units of skill Client or Player within in the mission.
-- @param #DATABASE self
-- @return #DATABASE self
function DATABASE:_RegisterClients()

  for ClientName, ClientTemplate in pairs( self.Templates.ClientsByName ) do
    self:E( { "Register Client:", ClientName } )
    self:AddClient( ClientName )
  end
  
  return self
end

--- @param #DATABASE self
function DATABASE:_RegisterStatics()

  local CoalitionsData = { GroupsRed = coalition.getStaticObjects( coalition.side.RED ), GroupsBlue = coalition.getStaticObjects( coalition.side.BLUE ) }
  for CoalitionId, CoalitionData in pairs( CoalitionsData ) do
    for DCSStaticId, DCSStatic in pairs( CoalitionData ) do

      if DCSStatic:isExist() then
        local DCSStaticName = DCSStatic:getName()
  
        self:E( { "Register Static:", DCSStaticName } )
        self:AddStatic( DCSStaticName )
      else
        self:E( { "Static does not exist: ",  DCSStatic } )
      end
    end
  end

  return self
end

--- @param #DATABASE self
function DATABASE:_RegisterAirbases()

  local CoalitionsData = { AirbasesRed = coalition.getAirbases( coalition.side.RED ), AirbasesBlue = coalition.getAirbases( coalition.side.BLUE ), AirbasesNeutral = coalition.getAirbases( coalition.side.NEUTRAL ) }
  for CoalitionId, CoalitionData in pairs( CoalitionsData ) do
    for DCSAirbaseId, DCSAirbase in pairs( CoalitionData ) do

      local DCSAirbaseName = DCSAirbase:getName()

      self:E( { "Register Airbase:", DCSAirbaseName } )
      self:AddAirbase( DCSAirbaseName )
    end
  end

  return self
end


--- Events

--- Handles the OnBirth event for the alive units set.
-- @param #DATABASE self
-- @param Core.Event#EVENTDATA Event
function DATABASE:_EventOnBirth( Event )
  self:F2( { Event } )

  if Event.IniDCSUnit then
    if Event.IniObjectCategory == 3 then
      self:AddStatic( Event.IniDCSUnitName )    
    else
      if Event.IniObjectCategory == 1 then
        self:AddUnit( Event.IniDCSUnitName )
        self:AddGroup( Event.IniDCSGroupName )
      end
    end
    --self:_EventOnPlayerEnterUnit( Event )
  end
end


--- Handles the OnDead or OnCrash event for alive units set.
-- @param #DATABASE self
-- @param Core.Event#EVENTDATA Event
function DATABASE:_EventOnDeadOrCrash( Event )
  self:F2( { Event } )

  if Event.IniDCSUnit then
    if Event.IniObjectCategory == 3 then
      if self.STATICS[Event.IniDCSUnitName] then
        self:DeleteStatic( Event.IniDCSUnitName )
      end    
    else
      if Event.IniObjectCategory == 1 then
        if self.UNITS[Event.IniDCSUnitName] then
          self:DeleteUnit( Event.IniDCSUnitName )
        end
      end
    end
  end
  
  self:AccountDestroys( Event )
end


--- Handles the OnPlayerEnterUnit event to fill the active players table (with the unit filter applied).
-- @param #DATABASE self
-- @param Core.Event#EVENTDATA Event
function DATABASE:_EventOnPlayerEnterUnit( Event )
  self:F2( { Event } )

  if Event.IniUnit then
    if Event.IniObjectCategory == 1 then
      self:AddUnit( Event.IniDCSUnitName )
      self:AddGroup( Event.IniDCSGroupName )
      local PlayerName = Event.IniUnit:GetPlayerName()
      if not self.PLAYERS[PlayerName] then
        self:AddPlayer( Event.IniUnitName, PlayerName )
      end
      local Settings = SETTINGS:Set( PlayerName )
      Settings:SetPlayerMenu( Event.IniUnit )
    end
  end
end


--- Handles the OnPlayerLeaveUnit event to clean the active players table.
-- @param #DATABASE self
-- @param Core.Event#EVENTDATA Event
function DATABASE:_EventOnPlayerLeaveUnit( Event )
  self:F2( { Event } )

  if Event.IniUnit then
    if Event.IniObjectCategory == 1 then
      local PlayerName = Event.IniUnit:GetPlayerName()
      if self.PLAYERS[PlayerName] then
        local Settings = SETTINGS:Set( PlayerName )
        Settings:RemovePlayerMenu( Event.IniUnit )
        self:DeletePlayer( Event.IniUnit, PlayerName )
      end
    end
  end
end

--- Iterators

--- Iterate the DATABASE and call an iterator function for the given set, providing the Object for each element within the set and optional parameters.
-- @param #DATABASE self
-- @param #function IteratorFunction The function that will be called when there is an alive player in the database.
-- @return #DATABASE self
function DATABASE:ForEach( IteratorFunction, FinalizeFunction, arg, Set )
  self:F2( arg )
  
  local function CoRoutine()
    local Count = 0
    for ObjectID, Object in pairs( Set ) do
        self:T2( Object )
        IteratorFunction( Object, unpack( arg ) )
        Count = Count + 1
--        if Count % 100 == 0 then
--          coroutine.yield( false )
--        end    
    end
    return true
  end
  
--  local co = coroutine.create( CoRoutine )
  local co = CoRoutine
  
  local function Schedule()
  
--    local status, res = coroutine.resume( co )
    local status, res = co()
    self:T3( { status, res } )
    
    if status == false then
      error( res )
    end
    if res == false then
      return true -- resume next time the loop
    end
    if FinalizeFunction then
      FinalizeFunction( unpack( arg ) )
    end
    return false
  end

  local Scheduler = SCHEDULER:New( self, Schedule, {}, 0.001, 0.001, 0 )
  
  return self
end


--- Iterate the DATABASE and call an iterator function for each **alive** STATIC, providing the STATIC and optional parameters.
-- @param #DATABASE self
-- @param #function IteratorFunction The function that will be called for each object in the database. The function needs to accept a STATIC parameter.
-- @return #DATABASE self
function DATABASE:ForEachStatic( IteratorFunction, FinalizeFunction, ... )  --R2.1
  self:F2( arg )
  
  self:ForEach( IteratorFunction, FinalizeFunction, arg, self.STATICS )

  return self
end


--- Iterate the DATABASE and call an iterator function for each **alive** UNIT, providing the UNIT and optional parameters.
-- @param #DATABASE self
-- @param #function IteratorFunction The function that will be called for each object in the database. The function needs to accept a UNIT parameter.
-- @return #DATABASE self
function DATABASE:ForEachUnit( IteratorFunction, FinalizeFunction, ... )
  self:F2( arg )
  
  self:ForEach( IteratorFunction, FinalizeFunction, arg, self.UNITS )

  return self
end


--- Iterate the DATABASE and call an iterator function for each **alive** GROUP, providing the GROUP and optional parameters.
-- @param #DATABASE self
-- @param #function IteratorFunction The function that will be called for each object in the database. The function needs to accept a GROUP parameter.
-- @return #DATABASE self
function DATABASE:ForEachGroup( IteratorFunction, FinalizeFunction, ... )
  self:F2( arg )
  
  self:ForEach( IteratorFunction, FinalizeFunction, arg, self.GROUPS )

  return self
end


--- Iterate the DATABASE and call an iterator function for each **ALIVE** player, providing the player name and optional parameters.
-- @param #DATABASE self
-- @param #function IteratorFunction The function that will be called for each object in the database. The function needs to accept the player name.
-- @return #DATABASE self
function DATABASE:ForEachPlayer( IteratorFunction, FinalizeFunction, ... )
  self:F2( arg )
  
  self:ForEach( IteratorFunction, FinalizeFunction, arg, self.PLAYERS )
  
  return self
end


--- Iterate the DATABASE and call an iterator function for each player who has joined the mission, providing the Unit of the player and optional parameters.
-- @param #DATABASE self
-- @param #function IteratorFunction The function that will be called for each object in the database. The function needs to accept a UNIT parameter.
-- @return #DATABASE self
function DATABASE:ForEachPlayerJoined( IteratorFunction, FinalizeFunction, ... )
  self:F2( arg )
  
  self:ForEach( IteratorFunction, FinalizeFunction, arg, self.PLAYERSJOINED )
  
  return self
end

--- Iterate the DATABASE and call an iterator function for each **ALIVE** player UNIT, providing the player UNIT and optional parameters.
-- @param #DATABASE self
-- @param #function IteratorFunction The function that will be called for each object in the database. The function needs to accept the player name.
-- @return #DATABASE self
function DATABASE:ForEachPlayerUnit( IteratorFunction, FinalizeFunction, ... )
  self:F2( arg )
  
  self:ForEach( IteratorFunction, FinalizeFunction, arg, self.PLAYERUNITS )
  
  return self
end


--- Iterate the DATABASE and call an iterator function for each CLIENT, providing the CLIENT to the function and optional parameters.
-- @param #DATABASE self
-- @param #function IteratorFunction The function that will be called object in the database. The function needs to accept a CLIENT parameter.
-- @return #DATABASE self
function DATABASE:ForEachClient( IteratorFunction, ... )
  self:F2( arg )
  
  self:ForEach( IteratorFunction, arg, self.CLIENTS )

  return self
end

--- Iterate the DATABASE and call an iterator function for each CARGO, providing the CARGO object to the function and optional parameters.
-- @param #DATABASE self
-- @param #function IteratorFunction The function that will be called for each object in the database. The function needs to accept a CLIENT parameter.
-- @return #DATABASE self
function DATABASE:ForEachCargo( IteratorFunction, ... )
  self:F2( arg )
  
  self:ForEach( IteratorFunction, arg, self.CARGOS )

  return self
end


--- Handles the OnEventNewCargo event.
-- @param #DATABASE self
-- @param Core.Event#EVENTDATA EventData
function DATABASE:OnEventNewCargo( EventData )
  self:F2( { EventData } )

  if EventData.Cargo then
    self:AddCargo( EventData.Cargo )
  end
end


--- Handles the OnEventDeleteCargo.
-- @param #DATABASE self
-- @param Core.Event#EVENTDATA EventData
function DATABASE:OnEventDeleteCargo( EventData )
  self:F2( { EventData } )

  if EventData.Cargo then
    self:DeleteCargo( EventData.Cargo.Name )
  end
end


--- Gets the player settings
-- @param #DATABASE self
-- @param #string PlayerName
-- @return Core.Settings#SETTINGS
function DATABASE:GetPlayerSettings( PlayerName )
  self:F2( { PlayerName } )
  return self.PLAYERSETTINGS[PlayerName]
end


--- Sets the player settings
-- @param #DATABASE self
-- @param #string PlayerName
-- @param Core.Settings#SETTINGS Settings
-- @return Core.Settings#SETTINGS
function DATABASE:SetPlayerSettings( PlayerName, Settings )
  self:F2( { PlayerName, Settings } )
  self.PLAYERSETTINGS[PlayerName] = Settings
end




--- @param #DATABASE self
function DATABASE:_RegisterTemplates()
  self:F2()

  self.Navpoints = {}
  self.UNITS = {}
  --Build routines.db.units and self.Navpoints
  for CoalitionName, coa_data in pairs(env.mission.coalition) do

    if (CoalitionName == 'red' or CoalitionName == 'blue') and type(coa_data) == 'table' then
      --self.Units[coa_name] = {}
      
      local CoalitionSide = coalition.side[string.upper(CoalitionName)]

      ----------------------------------------------
      -- build nav points DB
      self.Navpoints[CoalitionName] = {}
      if coa_data.nav_points then --navpoints
        for nav_ind, nav_data in pairs(coa_data.nav_points) do

          if type(nav_data) == 'table' then
            self.Navpoints[CoalitionName][nav_ind] = routines.utils.deepCopy(nav_data)

            self.Navpoints[CoalitionName][nav_ind]['name'] = nav_data.callsignStr  -- name is a little bit more self-explanatory.
            self.Navpoints[CoalitionName][nav_ind]['point'] = {}  -- point is used by SSE, support it.
            self.Navpoints[CoalitionName][nav_ind]['point']['x'] = nav_data.x
            self.Navpoints[CoalitionName][nav_ind]['point']['y'] = 0
            self.Navpoints[CoalitionName][nav_ind]['point']['z'] = nav_data.y
          end
      end
      end
      -------------------------------------------------
      if coa_data.country then --there is a country table
        for cntry_id, cntry_data in pairs(coa_data.country) do

          local CountryName = string.upper(cntry_data.name)
          local CountryID = cntry_data.id
          
          self.COUNTRY_ID[CountryName] = CountryID
          self.COUNTRY_NAME[CountryID] = CountryName
          
          --self.Units[coa_name][countryName] = {}
          --self.Units[coa_name][countryName]["countryId"] = cntry_data.id

          if type(cntry_data) == 'table' then  --just making sure

            for obj_type_name, obj_type_data in pairs(cntry_data) do

              if obj_type_name == "helicopter" or obj_type_name == "ship" or obj_type_name == "plane" or obj_type_name == "vehicle" or obj_type_name == "static" then --should be an unncessary check

                local CategoryName = obj_type_name

                if ((type(obj_type_data) == 'table') and obj_type_data.group and (type(obj_type_data.group) == 'table') and (#obj_type_data.group > 0)) then  --there's a group!

                  --self.Units[coa_name][countryName][category] = {}

                  for group_num, Template in pairs(obj_type_data.group) do

                    if obj_type_name ~= "static" and Template and Template.units and type(Template.units) == 'table' then  --making sure again- this is a valid group
                      self:_RegisterGroupTemplate( 
                        Template, 
                        CoalitionSide, 
                        _DATABASECategory[string.lower(CategoryName)], 
                        CountryID 
                      )
                    else
                      self:_RegisterStaticTemplate( 
                        Template, 
                        CoalitionSide, 
                        _DATABASECategory[string.lower(CategoryName)], 
                        CountryID 
                      )
                    end --if GroupTemplate and GroupTemplate.units then
                  end --for group_num, GroupTemplate in pairs(obj_type_data.group) do
                end --if ((type(obj_type_data) == 'table') and obj_type_data.group and (type(obj_type_data.group) == 'table') and (#obj_type_data.group > 0)) then
              end --if obj_type_name == "helicopter" or obj_type_name == "ship" or obj_type_name == "plane" or obj_type_name == "vehicle" or obj_type_name == "static" then
          end --for obj_type_name, obj_type_data in pairs(cntry_data) do
          end --if type(cntry_data) == 'table' then
      end --for cntry_id, cntry_data in pairs(coa_data.country) do
      end --if coa_data.country then --there is a country table
    end --if coa_name == 'red' or coa_name == 'blue' and type(coa_data) == 'table' then
  end --for coa_name, coa_data in pairs(mission.coalition) do

  for ZoneID, ZoneData in pairs( env.mission.triggers.zones ) do
    local ZoneName = ZoneData.name
    self.ZONENAMES[ZoneName] = ZoneName
  end

  return self
end

  --- Account the Hits of the Players.
  -- @param #DATABASE self
  -- @param Core.Event#EVENTDATA Event
  function DATABASE:AccountHits( Event )
    self:F( { Event } )
  
    if Event.IniPlayerName ~= nil then -- It is a player that is hitting something
      self:T( "Hitting Something" )
      
      -- What is he hitting?
      if Event.TgtCategory then
  
        -- A target got hit
        self.HITS[Event.TgtUnitName] = self.HITS[Event.TgtUnitName] or {}
        local Hit = self.HITS[Event.TgtUnitName]
        
        Hit.Players = Hit.Players or {}
        Hit.Players[Event.IniPlayerName] = true
      end
    end
    
    -- It is a weapon initiated by a player, that is hitting something
    -- This seems to occur only with scenery and static objects.
    if Event.WeaponPlayerName ~= nil then 
        self:T( "Hitting Scenery" )
      
      -- What is he hitting?
      if Event.TgtCategory then
  
        if Event.IniCoalition then -- A coalition object was hit, probably a static.
          -- A target got hit
          self.HITS[Event.TgtUnitName] = self.HITS[Event.TgtUnitName] or {}
          local Hit = self.HITS[Event.TgtUnitName]
          
          Hit.Players = Hit.Players or {}
          Hit.Players[Event.WeaponPlayerName] = true
        else -- A scenery object was hit.
        end
      end
    end
  end
  
  --- Account the destroys.
  -- @param #DATABASE self
  -- @param Core.Event#EVENTDATA Event
  function DATABASE:AccountDestroys( Event )
    self:F( { Event } )
  
    local TargetUnit = nil
    local TargetGroup = nil
    local TargetUnitName = ""
    local TargetGroupName = ""
    local TargetPlayerName = ""
    local TargetCoalition = nil
    local TargetCategory = nil
    local TargetType = nil
    local TargetUnitCoalition = nil
    local TargetUnitCategory = nil
    local TargetUnitType = nil
  
    if Event.IniDCSUnit then
  
      TargetUnit = Event.IniUnit
      TargetUnitName = Event.IniDCSUnitName
      TargetGroup = Event.IniDCSGroup
      TargetGroupName = Event.IniDCSGroupName
      TargetPlayerName = Event.IniPlayerName
  
      TargetCoalition = Event.IniCoalition
      --TargetCategory = TargetUnit:getCategory()
      --TargetCategory = TargetUnit:getDesc().category  -- Workaround
      TargetCategory = Event.IniCategory
      TargetType = Event.IniTypeName
  
      TargetUnitType = TargetType
  
      self:T( { TargetUnitName, TargetGroupName, TargetPlayerName, TargetCoalition, TargetCategory, TargetType } )
    end
  
    self:T( "Something got destroyed" )

    local Destroyed = false

    -- What is the player destroying?
    if self.HITS[Event.IniUnitName] then -- Was there a hit for this unit for this player before registered???
      

      self.DESTROYS[Event.IniUnitName] = self.DESTROYS[Event.IniUnitName] or {}
      
      self.DESTROYS[Event.IniUnitName] = true

    end
  end



--- **Core** -- SET_ classes define **collections** of objects to perform **bulk actions** and logically **group** objects.
-- 
-- ![Banner Image](..\Presentations\SET\Dia1.JPG)
-- 
-- ===
-- 
-- SET_ classes group objects of the same type into a collection, which is either:
-- 
--   * Manually managed using the **:Add...()** or **:Remove...()** methods. The initial SET can be filtered with the **@{#SET_BASE.FilterOnce}()** method
--   * Dynamically updated when new objects are created or objects are destroyed using the **@{#SET_BASE.FilterStart}()** method.
--   
-- Various types of SET_ classes are available:
-- 
--   * @{#SET_UNIT}: Defines a colleciton of @{Unit}s filtered by filter criteria.
--   * @{#SET_GROUP}: Defines a collection of @{Group}s filtered by filter criteria.
--   * @{#SET_CLIENT}: Defines a collection of @{Client}s filterd by filter criteria.
--   * @{#SET_AIRBASE}: Defines a collection of @{Airbase}s filtered by filter criteria.
-- 
-- These classes are derived from @{#SET_BASE}, which contains the main methods to manage SETs.
-- 
-- A multitude of other methods are available in SET_ classes that allow to:
-- 
--   * Validate the presence of objects in the SET.
--   * Trigger events when objects in the SET change a zone presence.
-- 
-- ====
-- 
-- ### Author: **Sven Van de Velde (FlightControl)**
-- ### Contributions: 
-- 
-- ====
-- 
-- @module Set


--- @type SET_BASE
-- @field #table Filter
-- @field #table Set
-- @field #table List
-- @field Core.Scheduler#SCHEDULER CallScheduler
-- @extends Core.Base#BASE


--- # 1) SET_BASE class, extends @{Base#BASE}
-- The @{Set#SET_BASE} class defines the core functions that define a collection of objects.
-- A SET provides iterators to iterate the SET, but will **temporarily** yield the ForEach interator loop at defined **"intervals"** to the mail simulator loop.
-- In this way, large loops can be done while not blocking the simulator main processing loop.
-- The default **"yield interval"** is after 10 objects processed.
-- The default **"time interval"** is after 0.001 seconds.
-- 
-- ## 1.1) Add or remove objects from the SET
-- 
-- Some key core functions are @{Set#SET_BASE.Add} and @{Set#SET_BASE.Remove} to add or remove objects from the SET in your logic.
-- 
-- ## 1.2) Define the SET iterator **"yield interval"** and the **"time interval"**
-- 
-- Modify the iterator intervals with the @{Set#SET_BASE.SetInteratorIntervals} method.
-- You can set the **"yield interval"**, and the **"time interval"**. (See above).
-- 
-- @field #SET_BASE SET_BASE 
SET_BASE = {
  ClassName = "SET_BASE",
  Filter = {},
  Set = {},
  List = {},
  Index = {},
}


--- Creates a new SET_BASE object, building a set of units belonging to a coalitions, categories, countries, types or with defined prefix names.
-- @param #SET_BASE self
-- @return #SET_BASE
-- @usage
-- -- Define a new SET_BASE Object. This DBObject will contain a reference to all Group and Unit Templates defined within the ME and the DCSRTE.
-- DBObject = SET_BASE:New()
function SET_BASE:New( Database )

  -- Inherits from BASE
  local self = BASE:Inherit( self, BASE:New() ) -- Core.Set#SET_BASE
  
  self.Database = Database

  self.YieldInterval = 10
  self.TimeInterval = 0.001

  self.Set = {}
  self.Index = {}
  
  self.CallScheduler = SCHEDULER:New( self )

  self:SetEventPriority( 2 )

  return self
end

--- Finds an @{Base#BASE} object based on the object Name.
-- @param #SET_BASE self
-- @param #string ObjectName
-- @return Core.Base#BASE The Object found.
function SET_BASE:_Find( ObjectName )

  local ObjectFound = self.Set[ObjectName]
  return ObjectFound
end


--- Gets the Set.
-- @param #SET_BASE self
-- @return #SET_BASE self
function SET_BASE:GetSet()
	self:F2()
	
  return self.Set
end

--- Gets a list of the Names of the Objects in the Set.
-- @param #SET_BASE self
-- @return #SET_BASE self
function SET_BASE:GetSetNames()  -- R2.3
  self:F2()
  
  local Names = {}
  
  for Name, Object in pairs( self.Set ) do
    table.insert( Names, Name )
  end
  
  return Names
end


--- Gets a list of the Objects in the Set.
-- @param #SET_BASE self
-- @return #SET_BASE self
function SET_BASE:GetSetObjects()  -- R2.3
  self:F2()
  
  local Objects = {}
  
  for Name, Object in pairs( self.Set ) do
    table.insert( Objects, Object )
  end
  
  return Objects
end


--- Adds a @{Base#BASE} object in the @{Set#SET_BASE}, using a given ObjectName as the index.
-- @param #SET_BASE self
-- @param #string ObjectName
-- @param Core.Base#BASE Object
-- @return Core.Base#BASE The added BASE Object.
function SET_BASE:Add( ObjectName, Object )
  self:F( ObjectName )

  self.Set[ObjectName] = Object
  table.insert( self.Index, ObjectName )
end

--- Adds a @{Base#BASE} object in the @{Set#SET_BASE}, using the Object Name as the index.
-- @param #SET_BASE self
-- @param Wrapper.Object#OBJECT Object
-- @return Core.Base#BASE The added BASE Object.
function SET_BASE:AddObject( Object )
  self:F2( Object.ObjectName )
  
  self:T( Object.UnitName )
  self:T( Object.ObjectName )
  self:Add( Object.ObjectName, Object )
  
end



--- Removes a @{Base#BASE} object from the @{Set#SET_BASE} and derived classes, based on the Object Name.
-- @param #SET_BASE self
-- @param #string ObjectName
function SET_BASE:Remove( ObjectName )

  local Object = self.Set[ObjectName]
  
  self:F3( { ObjectName, Object } )

  if Object then  
    for Index, Key in ipairs( self.Index ) do
      if Key == ObjectName then
        table.remove( self.Index, Index )
        self.Set[ObjectName] = nil
        break
      end
    end
    
  end
  
end

--- Gets a @{Base#BASE} object from the @{Set#SET_BASE} and derived classes, based on the Object Name.
-- @param #SET_BASE self
-- @param #string ObjectName
-- @return Core.Base#BASE
function SET_BASE:Get( ObjectName )
  self:F( ObjectName )

  local Object = self.Set[ObjectName]
  
  self:T3( { ObjectName, Object } )
  return Object
end

--- Gets the first object from the @{Set#SET_BASE} and derived classes.
-- @param #SET_BASE self
-- @return Core.Base#BASE
function SET_BASE:GetFirst()

  local ObjectName = self.Index[1]
  local FirstObject = self.Set[ObjectName]
  self:T3( { FirstObject } )
  return FirstObject 
end

--- Gets the last object from the @{Set#SET_BASE} and derived classes.
-- @param #SET_BASE self
-- @return Core.Base#BASE
function SET_BASE:GetLast()

  local ObjectName = self.Index[#self.Index]
  local LastObject = self.Set[ObjectName]
  self:T3( { LastObject } )
  return LastObject 
end

--- Gets a random object from the @{Set#SET_BASE} and derived classes.
-- @param #SET_BASE self
-- @return Core.Base#BASE
function SET_BASE:GetRandom()

  local RandomItem = self.Set[self.Index[math.random(#self.Index)]]
  self:T3( { RandomItem } )
  return RandomItem
end


--- Retrieves the amount of objects in the @{Set#SET_BASE} and derived classes.
-- @param #SET_BASE self
-- @return #number Count
function SET_BASE:Count()

  return self.Index and #self.Index or 0
end


--- Copies the Filter criteria from a given Set (for rebuilding a new Set based on an existing Set).
-- @param #SET_BASE self
-- @param #SET_BASE BaseSet
-- @return #SET_BASE
function SET_BASE:SetDatabase( BaseSet )

  -- Copy the filter criteria of the BaseSet
  local OtherFilter = routines.utils.deepCopy( BaseSet.Filter )
  self.Filter = OtherFilter
  
  -- Now base the new Set on the BaseSet
  self.Database = BaseSet:GetSet()
  return self
end



--- Define the SET iterator **"yield interval"** and the **"time interval"**.
-- @param #SET_BASE self
-- @param #number YieldInterval Sets the frequency when the iterator loop will yield after the number of objects processed. The default frequency is 10 objects processed.
-- @param #number TimeInterval Sets the time in seconds when the main logic will resume the iterator loop. The default time is 0.001 seconds.
-- @return #SET_BASE self
function SET_BASE:SetIteratorIntervals( YieldInterval, TimeInterval )

  self.YieldInterval = YieldInterval
  self.TimeInterval = TimeInterval
  
  return self
end


--- Filters for the defined collection.
-- @param #SET_BASE self
-- @return #SET_BASE self
function SET_BASE:FilterOnce()

  for ObjectName, Object in pairs( self.Database ) do

    if self:IsIncludeObject( Object ) then
      self:Add( ObjectName, Object )
    end
  end
  
  return self
end

--- Starts the filtering for the defined collection.
-- @param #SET_BASE self
-- @return #SET_BASE self
function SET_BASE:_FilterStart()

  for ObjectName, Object in pairs( self.Database ) do

    if self:IsIncludeObject( Object ) then
      self:E( { "Adding Object:", ObjectName } )
      self:Add( ObjectName, Object )
    end
  end
  
  self:HandleEvent( EVENTS.Birth, self._EventOnBirth )
  self:HandleEvent( EVENTS.Dead, self._EventOnDeadOrCrash )
  self:HandleEvent( EVENTS.Crash, self._EventOnDeadOrCrash )
  
  -- Follow alive players and clients
  self:HandleEvent( EVENTS.PlayerEnterUnit, self._EventOnPlayerEnterUnit )
  self:HandleEvent( EVENTS.PlayerLeaveUnit, self._EventOnPlayerLeaveUnit )
  
  
  return self
end

--- Starts the filtering of the Dead events for the collection.
-- @param #SET_BASE self
-- @return #SET_BASE self
function SET_BASE:FilterDeads() --R2.1 allow deads to be filtered to automatically handle deads in the collection.

  self:HandleEvent( EVENTS.Dead, self._EventOnDeadOrCrash )
  
  return self
end

--- Starts the filtering of the Crash events for the collection.
-- @param #SET_BASE self
-- @return #SET_BASE self
function SET_BASE:FilterCrashes() --R2.1 allow crashes to be filtered to automatically handle crashes in the collection.

  self:HandleEvent( EVENTS.Crash, self._EventOnDeadOrCrash )
  
  return self
end

--- Stops the filtering for the defined collection.
-- @param #SET_BASE self
-- @return #SET_BASE self
function SET_BASE:FilterStop()

  self:UnHandleEvent( EVENTS.Birth )
  self:UnHandleEvent( EVENTS.Dead )
  self:UnHandleEvent( EVENTS.Crash )
  
  return self
end

--- Iterate the SET_BASE while identifying the nearest object from a @{Point#POINT_VEC2}.
-- @param #SET_BASE self
-- @param Core.Point#POINT_VEC2 PointVec2 A @{Point#POINT_VEC2} object from where to evaluate the closest object in the set.
-- @return Core.Base#BASE The closest object.
function SET_BASE:FindNearestObjectFromPointVec2( PointVec2 )
  self:F2( PointVec2 )
  
  local NearestObject = nil
  local ClosestDistance = nil
  
  for ObjectID, ObjectData in pairs( self.Set ) do
    if NearestObject == nil then
      NearestObject = ObjectData
      ClosestDistance = PointVec2:DistanceFromVec2( ObjectData:GetVec2() )
    else
      local Distance = PointVec2:DistanceFromVec2( ObjectData:GetVec2() )
      if Distance < ClosestDistance then
        NearestObject = ObjectData
        ClosestDistance = Distance
      end
    end
  end
  
  return NearestObject
end



----- Private method that registers all alive players in the mission.
---- @param #SET_BASE self
---- @return #SET_BASE self
--function SET_BASE:_RegisterPlayers()
--
--  local CoalitionsData = { AlivePlayersRed = coalition.getPlayers( coalition.side.RED ), AlivePlayersBlue = coalition.getPlayers( coalition.side.BLUE ) }
--  for CoalitionId, CoalitionData in pairs( CoalitionsData ) do
--    for UnitId, UnitData in pairs( CoalitionData ) do
--      self:T3( { "UnitData:", UnitData } )
--      if UnitData and UnitData:isExist() then
--        local UnitName = UnitData:getName()
--        if not self.PlayersAlive[UnitName] then
--          self:E( { "Add player for unit:", UnitName, UnitData:getPlayerName() } )
--          self.PlayersAlive[UnitName] = UnitData:getPlayerName()
--        end
--      end
--    end
--  end
--  
--  return self
--end

--- Events

--- Handles the OnBirth event for the Set.
-- @param #SET_BASE self
-- @param Core.Event#EVENTDATA Event
function SET_BASE:_EventOnBirth( Event )
  self:F3( { Event } )

  if Event.IniDCSUnit then
    local ObjectName, Object = self:AddInDatabase( Event )
    self:T3( ObjectName, Object )
    if Object and self:IsIncludeObject( Object ) then
      self:Add( ObjectName, Object )
      --self:_EventOnPlayerEnterUnit( Event )
    end
  end
end

--- Handles the OnDead or OnCrash event for alive units set.
-- @param #SET_BASE self
-- @param Core.Event#EVENTDATA Event
function SET_BASE:_EventOnDeadOrCrash( Event )
  self:F3( { Event } )

  if Event.IniDCSUnit then
    local ObjectName, Object = self:FindInDatabase( Event )
    if ObjectName then
      self:Remove( ObjectName )
    end
  end
end

--- Handles the OnPlayerEnterUnit event to fill the active players table (with the unit filter applied).
-- @param #SET_BASE self
-- @param Core.Event#EVENTDATA Event
function SET_BASE:_EventOnPlayerEnterUnit( Event )
  self:F3( { Event } )

  if Event.IniDCSUnit then
    local ObjectName, Object = self:AddInDatabase( Event )
    self:T3( ObjectName, Object )
    if self:IsIncludeObject( Object ) then
      self:Add( ObjectName, Object )
      --self:_EventOnPlayerEnterUnit( Event )
    end
  end
end

--- Handles the OnPlayerLeaveUnit event to clean the active players table.
-- @param #SET_BASE self
-- @param Core.Event#EVENTDATA Event
function SET_BASE:_EventOnPlayerLeaveUnit( Event )
  self:F3( { Event } )

  local ObjectName = Event.IniDCSUnit
  if Event.IniDCSUnit then
    if Event.IniDCSGroup then
      local GroupUnits = Event.IniDCSGroup:getUnits()
      local PlayerCount = 0
      for _, DCSUnit in pairs( GroupUnits ) do
        if DCSUnit ~= Event.IniDCSUnit then
          if DCSUnit:getPlayerName() ~= nil then
            PlayerCount = PlayerCount + 1
          end
        end
      end
      self:E(PlayerCount)
      if PlayerCount == 0 then
        self:Remove( Event.IniDCSGroupName )
      end
    end
  end
end

-- Iterators

--- Iterate the SET_BASE and derived classes and call an iterator function for the given SET_BASE, providing the Object for each element within the set and optional parameters.
-- @param #SET_BASE self
-- @param #function IteratorFunction The function that will be called.
-- @return #SET_BASE self
function SET_BASE:ForEach( IteratorFunction, arg, Set, Function, FunctionArguments )
  self:F3( arg )
  
  Set = Set or self:GetSet()
  arg = arg or {}
  
  local function CoRoutine()
    local Count = 0
    for ObjectID, ObjectData in pairs( Set ) do
      local Object = ObjectData
        self:T3( Object )
        if Function then
          if Function( unpack( FunctionArguments ), Object ) == true then
            IteratorFunction( Object, unpack( arg ) )
          end
        else
          IteratorFunction( Object, unpack( arg ) )
        end
        Count = Count + 1
--        if Count % self.YieldInterval == 0 then
--          coroutine.yield( false )
--        end    
    end
    return true
  end
  
--  local co = coroutine.create( CoRoutine )
  local co = CoRoutine
  
  local function Schedule()
  
--    local status, res = coroutine.resume( co )
    local status, res = co()
    self:T3( { status, res } )
    
    if status == false then
      error( res )
    end
    if res == false then
      return true -- resume next time the loop
    end
    
    return false
  end

  --self.CallScheduler:Schedule( self, Schedule, {}, self.TimeInterval, self.TimeInterval, 0 )
  Schedule()
  
  return self
end


----- Iterate the SET_BASE and call an interator function for each **alive** unit, providing the Unit and optional parameters.
---- @param #SET_BASE self
---- @param #function IteratorFunction The function that will be called when there is an alive unit in the SET_BASE. The function needs to accept a UNIT parameter.
---- @return #SET_BASE self
--function SET_BASE:ForEachDCSUnitAlive( IteratorFunction, ... )
--  self:F3( arg )
--  
--  self:ForEach( IteratorFunction, arg, self.DCSUnitsAlive )
--
--  return self
--end
--
----- Iterate the SET_BASE and call an interator function for each **alive** player, providing the Unit of the player and optional parameters.
---- @param #SET_BASE self
---- @param #function IteratorFunction The function that will be called when there is an alive player in the SET_BASE. The function needs to accept a UNIT parameter.
---- @return #SET_BASE self
--function SET_BASE:ForEachPlayer( IteratorFunction, ... )
--  self:F3( arg )
--  
--  self:ForEach( IteratorFunction, arg, self.PlayersAlive )
--  
--  return self
--end
--
--
----- Iterate the SET_BASE and call an interator function for each client, providing the Client to the function and optional parameters.
---- @param #SET_BASE self
---- @param #function IteratorFunction The function that will be called when there is an alive player in the SET_BASE. The function needs to accept a CLIENT parameter.
---- @return #SET_BASE self
--function SET_BASE:ForEachClient( IteratorFunction, ... )
--  self:F3( arg )
--  
--  self:ForEach( IteratorFunction, arg, self.Clients )
--
--  return self
--end


--- Decides whether to include the Object
-- @param #SET_BASE self
-- @param #table Object
-- @return #SET_BASE self
function SET_BASE:IsIncludeObject( Object )
  self:F3( Object )
  
  return true
end

--- Gets a string with all the object names.
-- @param #SET_BASE self
-- @return #string A string with the names of the objects.
function SET_BASE:GetObjectNames()
  self:F3()

  local ObjectNames = ""
  for ObjectName, Object in pairs( self.Set ) do
    ObjectNames = ObjectNames .. ObjectName .. ", "
  end
  
  return ObjectNames
end

--- Flushes the current SET_BASE contents in the log ... (for debugging reasons).
-- @param #SET_BASE self
-- @return #string A string with the names of the objects.
function SET_BASE:Flush()
  self:F3()

  local ObjectNames = ""
  for ObjectName, Object in pairs( self.Set ) do
    ObjectNames = ObjectNames .. ObjectName .. ", "
  end
  self:E( { "Objects in Set:", ObjectNames } )
  
  return ObjectNames
end


--- @type SET_GROUP
-- @extends Core.Set#SET_BASE

--- # SET_GROUP class, extends @{Set#SET_BASE}
-- 
-- Mission designers can use the @{Set#SET_GROUP} class to build sets of groups belonging to certain:
-- 
--  * Coalitions
--  * Categories
--  * Countries
--  * Starting with certain prefix strings.
--  
-- ## 1. SET_GROUP constructor
-- 
-- Create a new SET_GROUP object with the @{#SET_GROUP.New} method:
-- 
--    * @{#SET_GROUP.New}: Creates a new SET_GROUP object.
-- 
-- ## 2. Add or Remove GROUP(s) from SET_GROUP
-- 
-- GROUPS can be added and removed using the @{Set#SET_GROUP.AddGroupsByName} and @{Set#SET_GROUP.RemoveGroupsByName} respectively. 
-- These methods take a single GROUP name or an array of GROUP names to be added or removed from SET_GROUP.
-- 
-- ## 3. SET_GROUP filter criteria
-- 
-- You can set filter criteria to define the set of groups within the SET_GROUP.
-- Filter criteria are defined by:
-- 
--    * @{#SET_GROUP.FilterCoalitions}: Builds the SET_GROUP with the groups belonging to the coalition(s).
--    * @{#SET_GROUP.FilterCategories}: Builds the SET_GROUP with the groups belonging to the category(ies).
--    * @{#SET_GROUP.FilterCountries}: Builds the SET_GROUP with the gruops belonging to the country(ies).
--    * @{#SET_GROUP.FilterPrefixes}: Builds the SET_GROUP with the groups starting with the same prefix string(s).
-- 
-- For the Category Filter, extra methods have been added:
-- 
--    * @{#SET_GROUP.FilterCategoryAirplane}: Builds the SET_GROUP from airplanes.
--    * @{#SET_GROUP.FilterCategoryHelicopter}: Builds the SET_GROUP from helicopters.
--    * @{#SET_GROUP.FilterCategoryGround}: Builds the SET_GROUP from ground vehicles or infantry.
--    * @{#SET_GROUP.FilterCategoryShip}: Builds the SET_GROUP from ships.
--    * @{#SET_GROUP.FilterCategoryStructure}: Builds the SET_GROUP from structures.
-- 
--   
-- Once the filter criteria have been set for the SET_GROUP, you can start filtering using:
-- 
--    * @{#SET_GROUP.FilterStart}: Starts the filtering of the groups within the SET_GROUP and add or remove GROUP objects **dynamically**.
-- 
-- Planned filter criteria within development are (so these are not yet available):
-- 
--    * @{#SET_GROUP.FilterZones}: Builds the SET_GROUP with the groups within a @{Zone#ZONE}.
-- 
-- ## 4. SET_GROUP iterators
-- 
-- Once the filters have been defined and the SET_GROUP has been built, you can iterate the SET_GROUP with the available iterator methods.
-- The iterator methods will walk the SET_GROUP set, and call for each element within the set a function that you provide.
-- The following iterator methods are currently available within the SET_GROUP:
-- 
--   * @{#SET_GROUP.ForEachGroup}: Calls a function for each alive group it finds within the SET_GROUP.
--   * @{#SET_GROUP.ForEachGroupCompletelyInZone}: Iterate the SET_GROUP and call an iterator function for each **alive** GROUP presence completely in a @{Zone}, providing the GROUP and optional parameters to the called function.
--   * @{#SET_GROUP.ForEachGroupPartlyInZone}: Iterate the SET_GROUP and call an iterator function for each **alive** GROUP presence partly in a @{Zone}, providing the GROUP and optional parameters to the called function.
--   * @{#SET_GROUP.ForEachGroupNotInZone}: Iterate the SET_GROUP and call an iterator function for each **alive** GROUP presence not in a @{Zone}, providing the GROUP and optional parameters to the called function.
--
-- ===
-- @field #SET_GROUP SET_GROUP 
SET_GROUP = {
  ClassName = "SET_GROUP",
  Filter = {
    Coalitions = nil,
    Categories = nil,
    Countries = nil,
    GroupPrefixes = nil,
  },
  FilterMeta = {
    Coalitions = {
      red = coalition.side.RED,
      blue = coalition.side.BLUE,
      neutral = coalition.side.NEUTRAL,
    },
    Categories = {
      plane = Group.Category.AIRPLANE,
      helicopter = Group.Category.HELICOPTER,
      ground = Group.Category.GROUND, -- R2.2
      ship = Group.Category.SHIP,
      structure = Group.Category.STRUCTURE,
    },
  },
}


--- Creates a new SET_GROUP object, building a set of groups belonging to a coalitions, categories, countries, types or with defined prefix names.
-- @param #SET_GROUP self
-- @return #SET_GROUP
-- @usage
-- -- Define a new SET_GROUP Object. This DBObject will contain a reference to all alive GROUPS.
-- DBObject = SET_GROUP:New()
function SET_GROUP:New()

  -- Inherits from BASE
  local self = BASE:Inherit( self, SET_BASE:New( _DATABASE.GROUPS ) )

  return self
end

--- Add GROUP(s) to SET_GROUP.
-- @param Core.Set#SET_GROUP self
-- @param #string AddGroupNames A single name or an array of GROUP names.
-- @return self
function SET_GROUP:AddGroupsByName( AddGroupNames )

  local AddGroupNamesArray = ( type( AddGroupNames ) == "table" ) and AddGroupNames or { AddGroupNames }
  
  for AddGroupID, AddGroupName in pairs( AddGroupNamesArray ) do
    self:Add( AddGroupName, GROUP:FindByName( AddGroupName ) )
  end
    
  return self
end

--- Remove GROUP(s) from SET_GROUP.
-- @param Core.Set#SET_GROUP self
-- @param Wrapper.Group#GROUP RemoveGroupNames A single name or an array of GROUP names.
-- @return self
function SET_GROUP:RemoveGroupsByName( RemoveGroupNames )

  local RemoveGroupNamesArray = ( type( RemoveGroupNames ) == "table" ) and RemoveGroupNames or { RemoveGroupNames }
  
  for RemoveGroupID, RemoveGroupName in pairs( RemoveGroupNamesArray ) do
    self:Remove( RemoveGroupName.GroupName )
  end
    
  return self
end




--- Finds a Group based on the Group Name.
-- @param #SET_GROUP self
-- @param #string GroupName
-- @return Wrapper.Group#GROUP The found Group.
function SET_GROUP:FindGroup( GroupName )

  local GroupFound = self.Set[GroupName]
  return GroupFound
end

--- Iterate the SET_GROUP while identifying the nearest object from a @{Point#POINT_VEC2}.
-- @param #SET_GROUP self
-- @param Core.Point#POINT_VEC2 PointVec2 A @{Point#POINT_VEC2} object from where to evaluate the closest object in the set.
-- @return Wrapper.Group#GROUP The closest group.
function SET_GROUP:FindNearestGroupFromPointVec2( PointVec2 )
  self:F2( PointVec2 )
  
  local NearestGroup = nil
  local ClosestDistance = nil
  
  for ObjectID, ObjectData in pairs( self.Set ) do
    if NearestGroup == nil then
      NearestGroup = ObjectData
      ClosestDistance = PointVec2:DistanceFromVec2( ObjectData:GetVec2() )
    else
      local Distance = PointVec2:DistanceFromVec2( ObjectData:GetVec2() )
      if Distance < ClosestDistance then
        NearestGroup = ObjectData
        ClosestDistance = Distance
      end
    end
  end
  
  return NearestGroup
end


--- Builds a set of groups of coalitions.
-- Possible current coalitions are red, blue and neutral.
-- @param #SET_GROUP self
-- @param #string Coalitions Can take the following values: "red", "blue", "neutral".
-- @return #SET_GROUP self
function SET_GROUP:FilterCoalitions( Coalitions )
  if not self.Filter.Coalitions then
    self.Filter.Coalitions = {}
  end
  if type( Coalitions ) ~= "table" then
    Coalitions = { Coalitions }
  end
  for CoalitionID, Coalition in pairs( Coalitions ) do
    self.Filter.Coalitions[Coalition] = Coalition
  end
  return self
end


--- Builds a set of groups out of categories.
-- Possible current categories are plane, helicopter, ground, ship.
-- @param #SET_GROUP self
-- @param #string Categories Can take the following values: "plane", "helicopter", "ground", "ship".
-- @return #SET_GROUP self
function SET_GROUP:FilterCategories( Categories )
  if not self.Filter.Categories then
    self.Filter.Categories = {}
  end
  if type( Categories ) ~= "table" then
    Categories = { Categories }
  end
  for CategoryID, Category in pairs( Categories ) do
    self.Filter.Categories[Category] = Category
  end
  return self
end

--- Builds a set of groups out of ground category.
-- @param #SET_GROUP self
-- @return #SET_GROUP self
function SET_GROUP:FilterCategoryGround()
  self:FilterCategories( "ground" )
  return self
end

--- Builds a set of groups out of airplane category.
-- @param #SET_GROUP self
-- @return #SET_GROUP self
function SET_GROUP:FilterCategoryAirplane()
  self:FilterCategories( "plane" )
  return self
end

--- Builds a set of groups out of helicopter category.
-- @param #SET_GROUP self
-- @return #SET_GROUP self
function SET_GROUP:FilterCategoryHelicopter()
  self:FilterCategories( "helicopter" )
  return self
end

--- Builds a set of groups out of ship category.
-- @param #SET_GROUP self
-- @return #SET_GROUP self
function SET_GROUP:FilterCategoryShip()
  self:FilterCategories( "ship" )
  return self
end

--- Builds a set of groups out of structure category.
-- @param #SET_GROUP self
-- @return #SET_GROUP self
function SET_GROUP:FilterCategoryStructure()
  self:FilterCategories( "structure" )
  return self
end



--- Builds a set of groups of defined countries.
-- Possible current countries are those known within DCS world.
-- @param #SET_GROUP self
-- @param #string Countries Can take those country strings known within DCS world.
-- @return #SET_GROUP self
function SET_GROUP:FilterCountries( Countries )
  if not self.Filter.Countries then
    self.Filter.Countries = {}
  end
  if type( Countries ) ~= "table" then
    Countries = { Countries }
  end
  for CountryID, Country in pairs( Countries ) do
    self.Filter.Countries[Country] = Country
  end
  return self
end


--- Builds a set of groups of defined GROUP prefixes.
-- All the groups starting with the given prefixes will be included within the set.
-- @param #SET_GROUP self
-- @param #string Prefixes The prefix of which the group name starts with.
-- @return #SET_GROUP self
function SET_GROUP:FilterPrefixes( Prefixes )
  if not self.Filter.GroupPrefixes then
    self.Filter.GroupPrefixes = {}
  end
  if type( Prefixes ) ~= "table" then
    Prefixes = { Prefixes }
  end
  for PrefixID, Prefix in pairs( Prefixes ) do
    self.Filter.GroupPrefixes[Prefix] = Prefix
  end
  return self
end


--- Starts the filtering.
-- @param #SET_GROUP self
-- @return #SET_GROUP self
function SET_GROUP:FilterStart()

  if _DATABASE then
    self:_FilterStart()
  end
  
  
  
  return self
end

--- Handles the OnDead or OnCrash event for alive groups set.
-- Note: The GROUP object in the SET_GROUP collection will only be removed if the last unit is destroyed of the GROUP.
-- @param #SET_GROUP self
-- @param Core.Event#EVENTDATA Event
function SET_GROUP:_EventOnDeadOrCrash( Event )
  self:F3( { Event } )

  if Event.IniDCSUnit then
    local ObjectName, Object = self:FindInDatabase( Event )
    if ObjectName then
      if Event.IniDCSGroup:getSize() == 1 then -- Only remove if the last unit of the group was destroyed.
        self:Remove( ObjectName )
      end
    end
  end
end

--- Handles the Database to check on an event (birth) that the Object was added in the Database.
-- This is required, because sometimes the _DATABASE birth event gets called later than the SET_BASE birth event!
-- @param #SET_GROUP self
-- @param Core.Event#EVENTDATA Event
-- @return #string The name of the GROUP
-- @return #table The GROUP
function SET_GROUP:AddInDatabase( Event )
  self:F3( { Event } )

  if Event.IniObjectCategory == 1 then
    if not self.Database[Event.IniDCSGroupName] then
      self.Database[Event.IniDCSGroupName] = GROUP:Register( Event.IniDCSGroupName )
      self:T3( self.Database[Event.IniDCSGroupName] )
    end
  end
  
  return Event.IniDCSGroupName, self.Database[Event.IniDCSGroupName]
end

--- Handles the Database to check on any event that Object exists in the Database.
-- This is required, because sometimes the _DATABASE event gets called later than the SET_BASE event or vise versa!
-- @param #SET_GROUP self
-- @param Core.Event#EVENTDATA Event
-- @return #string The name of the GROUP
-- @return #table The GROUP
function SET_GROUP:FindInDatabase( Event )
  self:F3( { Event } )

  return Event.IniDCSGroupName, self.Database[Event.IniDCSGroupName]
end

--- Iterate the SET_GROUP and call an iterator function for each **alive** GROUP, providing the GROUP and optional parameters.
-- @param #SET_GROUP self
-- @param #function IteratorFunction The function that will be called when there is an alive GROUP in the SET_GROUP. The function needs to accept a GROUP parameter.
-- @return #SET_GROUP self
function SET_GROUP:ForEachGroup( IteratorFunction, ... )
  self:F2( arg )
  
  self:ForEach( IteratorFunction, arg, self.Set )

  return self
end

--- Iterate the SET_GROUP and call an iterator function for each **alive** GROUP presence completely in a @{Zone}, providing the GROUP and optional parameters to the called function.
-- @param #SET_GROUP self
-- @param Core.Zone#ZONE ZoneObject The Zone to be tested for.
-- @param #function IteratorFunction The function that will be called when there is an alive GROUP in the SET_GROUP. The function needs to accept a GROUP parameter.
-- @return #SET_GROUP self
function SET_GROUP:ForEachGroupCompletelyInZone( ZoneObject, IteratorFunction, ... )
  self:F2( arg )
  
  self:ForEach( IteratorFunction, arg, self.Set,
    --- @param Core.Zone#ZONE_BASE ZoneObject
    -- @param Wrapper.Group#GROUP GroupObject
    function( ZoneObject, GroupObject )
      if GroupObject:IsCompletelyInZone( ZoneObject ) then
        return true
      else
        return false
      end
    end, { ZoneObject } )

  return self
end

--- Iterate the SET_GROUP and call an iterator function for each **alive** GROUP presence partly in a @{Zone}, providing the GROUP and optional parameters to the called function.
-- @param #SET_GROUP self
-- @param Core.Zone#ZONE ZoneObject The Zone to be tested for.
-- @param #function IteratorFunction The function that will be called when there is an alive GROUP in the SET_GROUP. The function needs to accept a GROUP parameter.
-- @return #SET_GROUP self
function SET_GROUP:ForEachGroupPartlyInZone( ZoneObject, IteratorFunction, ... )
  self:F2( arg )
  
  self:ForEach( IteratorFunction, arg, self.Set,
    --- @param Core.Zone#ZONE_BASE ZoneObject
    -- @param Wrapper.Group#GROUP GroupObject
    function( ZoneObject, GroupObject )
      if GroupObject:IsPartlyInZone( ZoneObject ) then
        return true
      else
        return false
      end
    end, { ZoneObject } )

  return self
end

--- Iterate the SET_GROUP and call an iterator function for each **alive** GROUP presence not in a @{Zone}, providing the GROUP and optional parameters to the called function.
-- @param #SET_GROUP self
-- @param Core.Zone#ZONE ZoneObject The Zone to be tested for.
-- @param #function IteratorFunction The function that will be called when there is an alive GROUP in the SET_GROUP. The function needs to accept a GROUP parameter.
-- @return #SET_GROUP self
function SET_GROUP:ForEachGroupNotInZone( ZoneObject, IteratorFunction, ... )
  self:F2( arg )
  
  self:ForEach( IteratorFunction, arg, self.Set,
    --- @param Core.Zone#ZONE_BASE ZoneObject
    -- @param Wrapper.Group#GROUP GroupObject
    function( ZoneObject, GroupObject )
      if GroupObject:IsNotInZone( ZoneObject ) then
        return true
      else
        return false
      end
    end, { ZoneObject } )

  return self
end

--- Iterate the SET_GROUP and return true if all the @{Wrapper.Group#GROUP} are completely in the @{Core.Zone#ZONE}
-- @param #SET_GROUP self
-- @param Core.Zone#ZONE ZoneObject The Zone to be tested for.
-- @return #boolean true if all the @{Wrapper.Group#GROUP} are completly in the @{Core.Zone#ZONE}, false otherwise
-- @usage
-- local MyZone = ZONE:New("Zone1")
-- local MySetGroup = SET_GROUP:New()
-- MySetGroup:AddGroupsByName({"Group1", "Group2"})
--
-- if MySetGroup:AllCompletelyInZone(MyZone) then
--   MESSAGE:New("All the SET's GROUP are in zone !", 10):ToAll()
-- else
--   MESSAGE:New("Some or all SET's GROUP are outside zone !", 10):ToAll()
-- end
function SET_GROUP:AllCompletelyInZone(Zone)
  self:F2(Zone)
  local Set = self:GetSet()
  for GroupID, GroupData in pairs(Set) do -- For each GROUP in SET_GROUP
    if not GroupData:IsCompletelyInZone(Zone) then 
      return false
    end
  end
  return true
end

--- Iterate the SET_GROUP and return true if at least one of the @{Wrapper.Group#GROUP} is completely inside the @{Core.Zone#ZONE}
-- @param #SET_GROUP self
-- @param Core.Zone#ZONE ZoneObject The Zone to be tested for.
-- @return #boolean true if at least one of the @{Wrapper.Group#GROUP} is completly inside the @{Core.Zone#ZONE}, false otherwise.
-- @usage
-- local MyZone = ZONE:New("Zone1")
-- local MySetGroup = SET_GROUP:New()
-- MySetGroup:AddGroupsByName({"Group1", "Group2"})
--
-- if MySetGroup:AnyCompletelyInZone(MyZone) then
--   MESSAGE:New("At least one GROUP is completely in zone !", 10):ToAll()
-- else
--   MESSAGE:New("No GROUP is completely in zone !", 10):ToAll()
-- end
function SET_GROUP:AnyCompletelyInZone(Zone)
  self:F2(Zone)
  local Set = self:GetSet()
  for GroupID, GroupData in pairs(Set) do -- For each GROUP in SET_GROUP
    if GroupData:IsCompletelyInZone(Zone) then 
      return true
    end
  end
  return false
end

--- Iterate the SET_GROUP and return true if at least one @{#UNIT} of one @{GROUP} of the @{SET_GROUP} is in @{ZONE}
-- @param #SET_GROUP self
-- @param Core.Zone#ZONE ZoneObject The Zone to be tested for.
-- @return #boolean true if at least one of the @{Wrapper.Group#GROUP} is partly or completly inside the @{Core.Zone#ZONE}, false otherwise.
-- @usage
-- local MyZone = ZONE:New("Zone1")
-- local MySetGroup = SET_GROUP:New()
-- MySetGroup:AddGroupsByName({"Group1", "Group2"})
--
-- if MySetGroup:AnyPartlyInZone(MyZone) then
--   MESSAGE:New("At least one GROUP has at least one UNIT in zone !", 10):ToAll()
-- else
--   MESSAGE:New("No UNIT of any GROUP is in zone !", 10):ToAll()
-- end
function SET_GROUP:AnyInZone(Zone)
  self:F2(Zone)
  local Set = self:GetSet()
  for GroupID, GroupData in pairs(Set) do -- For each GROUP in SET_GROUP
    if GroupData:IsPartlyInZone(Zone) or GroupData:IsCompletelyInZone(Zone) then 
      return true
    end
  end
  return false
end

--- Iterate the SET_GROUP and return true if at least one @{GROUP} of the @{SET_GROUP} is partly in @{ZONE}.
-- Will return false if a @{GROUP} is fully in the @{ZONE}
-- @param #SET_GROUP self
-- @param Core.Zone#ZONE ZoneObject The Zone to be tested for.
-- @return #boolean true if at least one of the @{Wrapper.Group#GROUP} is partly or completly inside the @{Core.Zone#ZONE}, false otherwise.
-- @usage
-- local MyZone = ZONE:New("Zone1")
-- local MySetGroup = SET_GROUP:New()
-- MySetGroup:AddGroupsByName({"Group1", "Group2"})
--
-- if MySetGroup:AnyPartlyInZone(MyZone) then
--   MESSAGE:New("At least one GROUP is partially in the zone, but none are fully in it !", 10):ToAll()
-- else
--   MESSAGE:New("No GROUP are in zone, or one (or more) GROUP is completely in it !", 10):ToAll()
-- end
function SET_GROUP:AnyPartlyInZone(Zone)
  self:F2(Zone)
  local IsPartlyInZone = false
  local Set = self:GetSet()
  for GroupID, GroupData in pairs(Set) do -- For each GROUP in SET_GROUP
    if GroupData:IsCompletelyInZone(Zone) then
      return false
    elseif GroupData:IsPartlyInZone(Zone) then 
      IsPartlyInZone = true -- at least one GROUP is partly in zone
    end
  end
  
  if IsPartlyInZone then
    return true
  else
    return false
  end
end

--- Iterate the SET_GROUP and return true if no @{GROUP} of the @{SET_GROUP} is in @{ZONE}
-- This could also be achieved with `not SET_GROUP:AnyPartlyInZone(Zone)`, but it's easier for the 
-- mission designer to add a dedicated method
-- @param #SET_GROUP self
-- @param Core.Zone#ZONE ZoneObject The Zone to be tested for.
-- @return #boolean true if no @{Wrapper.Group#GROUP} is inside the @{Core.Zone#ZONE} in any way, false otherwise.
-- @usage
-- local MyZone = ZONE:New("Zone1")
-- local MySetGroup = SET_GROUP:New()
-- MySetGroup:AddGroupsByName({"Group1", "Group2"})
--
-- if MySetGroup:NoneInZone(MyZone) then
--   MESSAGE:New("No GROUP is completely in zone !", 10):ToAll()
-- else
--   MESSAGE:New("No UNIT of any GROUP is in zone !", 10):ToAll()
-- end
function SET_GROUP:NoneInZone(Zone)
  self:F2(Zone)
  local Set = self:GetSet()
  for GroupID, GroupData in pairs(Set) do -- For each GROUP in SET_GROUP
    if not GroupData:IsNotInZone(Zone) then -- If the GROUP is in Zone in any way
      return false
    end
  end
  return true
end

--- Iterate the SET_GROUP and count how many GROUPs are completely in the Zone
-- That could easily be done with SET_GROUP:ForEachGroupCompletelyInZone(), but this function
-- provides an easy to use shortcut...
-- @param #SET_GROUP self
-- @param Core.Zone#ZONE ZoneObject The Zone to be tested for.
-- @return #number the number of GROUPs completely in the Zone
-- @usage
-- local MyZone = ZONE:New("Zone1")
-- local MySetGroup = SET_GROUP:New()
-- MySetGroup:AddGroupsByName({"Group1", "Group2"})
--
-- MESSAGE:New("There are " .. MySetGroup:CountInZone(MyZone) .. " GROUPs in the Zone !", 10):ToAll()
function SET_GROUP:CountInZone(Zone)
  self:F2(Zone)
  local Count = 0
  local Set = self:GetSet()
  for GroupID, GroupData in pairs(Set) do -- For each GROUP in SET_GROUP
    if GroupData:IsCompletelyInZone(Zone) then 
      Count = Count + 1
    end
  end
  return Count
end

--- Iterate the SET_GROUP and count how many UNITs are completely in the Zone
-- @param #SET_GROUP self
-- @param Core.Zone#ZONE ZoneObject The Zone to be tested for.
-- @return #number the number of GROUPs completely in the Zone
-- @usage
-- local MyZone = ZONE:New("Zone1")
-- local MySetGroup = SET_GROUP:New()
-- MySetGroup:AddGroupsByName({"Group1", "Group2"})
--
-- MESSAGE:New("There are " .. MySetGroup:CountUnitInZone(MyZone) .. " UNITs in the Zone !", 10):ToAll()
function SET_GROUP:CountUnitInZone(Zone)
  self:F2(Zone)
  local Count = 0
  local Set = self:GetSet()
  for GroupID, GroupData in pairs(Set) do -- For each GROUP in SET_GROUP
    Count = Count + GroupData:CountInZone(Zone)
  end
  return Count
end

----- Iterate the SET_GROUP and call an interator function for each **alive** player, providing the Group of the player and optional parameters.
---- @param #SET_GROUP self
---- @param #function IteratorFunction The function that will be called when there is an alive player in the SET_GROUP. The function needs to accept a GROUP parameter.
---- @return #SET_GROUP self
--function SET_GROUP:ForEachPlayer( IteratorFunction, ... )
--  self:F2( arg )
--  
--  self:ForEach( IteratorFunction, arg, self.PlayersAlive )
--  
--  return self
--end
--
--
----- Iterate the SET_GROUP and call an interator function for each client, providing the Client to the function and optional parameters.
---- @param #SET_GROUP self
---- @param #function IteratorFunction The function that will be called when there is an alive player in the SET_GROUP. The function needs to accept a CLIENT parameter.
---- @return #SET_GROUP self
--function SET_GROUP:ForEachClient( IteratorFunction, ... )
--  self:F2( arg )
--  
--  self:ForEach( IteratorFunction, arg, self.Clients )
--
--  return self
--end


---
-- @param #SET_GROUP self
-- @param Wrapper.Group#GROUP MooseGroup
-- @return #SET_GROUP self
function SET_GROUP:IsIncludeObject( MooseGroup )
  self:F2( MooseGroup )
  local MooseGroupInclude = true

  if self.Filter.Coalitions then
    local MooseGroupCoalition = false
    for CoalitionID, CoalitionName in pairs( self.Filter.Coalitions ) do
      self:T3( { "Coalition:", MooseGroup:GetCoalition(), self.FilterMeta.Coalitions[CoalitionName], CoalitionName } )
      if self.FilterMeta.Coalitions[CoalitionName] and self.FilterMeta.Coalitions[CoalitionName] == MooseGroup:GetCoalition() then
        MooseGroupCoalition = true
      end
    end
    MooseGroupInclude = MooseGroupInclude and MooseGroupCoalition
  end
  
  if self.Filter.Categories then
    local MooseGroupCategory = false
    for CategoryID, CategoryName in pairs( self.Filter.Categories ) do
      self:T3( { "Category:", MooseGroup:GetCategory(), self.FilterMeta.Categories[CategoryName], CategoryName } )
      if self.FilterMeta.Categories[CategoryName] and self.FilterMeta.Categories[CategoryName] == MooseGroup:GetCategory() then
        MooseGroupCategory = true
      end
    end
    MooseGroupInclude = MooseGroupInclude and MooseGroupCategory
  end
  
  if self.Filter.Countries then
    local MooseGroupCountry = false
    for CountryID, CountryName in pairs( self.Filter.Countries ) do
      self:T3( { "Country:", MooseGroup:GetCountry(), CountryName } )
      if country.id[CountryName] == MooseGroup:GetCountry() then
        MooseGroupCountry = true
      end
    end
    MooseGroupInclude = MooseGroupInclude and MooseGroupCountry
  end

  if self.Filter.GroupPrefixes then
    local MooseGroupPrefix = false
    for GroupPrefixId, GroupPrefix in pairs( self.Filter.GroupPrefixes ) do
      self:T3( { "Prefix:", string.find( MooseGroup:GetName(), GroupPrefix, 1 ), GroupPrefix } )
      if string.find( MooseGroup:GetName(), GroupPrefix:gsub ("-", "%%-"), 1 ) then
        MooseGroupPrefix = true
      end
    end
    MooseGroupInclude = MooseGroupInclude and MooseGroupPrefix
  end

  self:T2( MooseGroupInclude )
  return MooseGroupInclude
end


do -- SET_UNIT

  --- @type SET_UNIT
  -- @extends Core.Set#SET_BASE
  
  --- # 3) SET_UNIT class, extends @{Set#SET_BASE}
  -- 
  -- Mission designers can use the SET_UNIT class to build sets of units belonging to certain:
  -- 
  --  * Coalitions
  --  * Categories
  --  * Countries
  --  * Unit types
  --  * Starting with certain prefix strings.
  --  
  -- ## 3.1) SET_UNIT constructor
  --
  -- Create a new SET_UNIT object with the @{#SET_UNIT.New} method:
  -- 
  --    * @{#SET_UNIT.New}: Creates a new SET_UNIT object.
  --   
  -- ## 3.2) Add or Remove UNIT(s) from SET_UNIT
  --
  -- UNITs can be added and removed using the @{Set#SET_UNIT.AddUnitsByName} and @{Set#SET_UNIT.RemoveUnitsByName} respectively. 
  -- These methods take a single UNIT name or an array of UNIT names to be added or removed from SET_UNIT.
  -- 
  -- ## 3.3) SET_UNIT filter criteria
  -- 
  -- You can set filter criteria to define the set of units within the SET_UNIT.
  -- Filter criteria are defined by:
  -- 
  --    * @{#SET_UNIT.FilterCoalitions}: Builds the SET_UNIT with the units belonging to the coalition(s).
  --    * @{#SET_UNIT.FilterCategories}: Builds the SET_UNIT with the units belonging to the category(ies).
  --    * @{#SET_UNIT.FilterTypes}: Builds the SET_UNIT with the units belonging to the unit type(s).
  --    * @{#SET_UNIT.FilterCountries}: Builds the SET_UNIT with the units belonging to the country(ies).
  --    * @{#SET_UNIT.FilterPrefixes}: Builds the SET_UNIT with the units starting with the same prefix string(s).
  --   
  -- Once the filter criteria have been set for the SET_UNIT, you can start filtering using:
  -- 
  --   * @{#SET_UNIT.FilterStart}: Starts the filtering of the units within the SET_UNIT.
  -- 
  -- Planned filter criteria within development are (so these are not yet available):
  -- 
  --    * @{#SET_UNIT.FilterZones}: Builds the SET_UNIT with the units within a @{Zone#ZONE}.
  -- 
  -- ## 3.4) SET_UNIT iterators
  -- 
  -- Once the filters have been defined and the SET_UNIT has been built, you can iterate the SET_UNIT with the available iterator methods.
  -- The iterator methods will walk the SET_UNIT set, and call for each element within the set a function that you provide.
  -- The following iterator methods are currently available within the SET_UNIT:
  -- 
  --   * @{#SET_UNIT.ForEachUnit}: Calls a function for each alive unit it finds within the SET_UNIT.
  --   * @{#SET_GROUP.ForEachGroupCompletelyInZone}: Iterate the SET_GROUP and call an iterator function for each **alive** GROUP presence completely in a @{Zone}, providing the GROUP and optional parameters to the called function.
  --   * @{#SET_GROUP.ForEachGroupNotInZone}: Iterate the SET_GROUP and call an iterator function for each **alive** GROUP presence not in a @{Zone}, providing the GROUP and optional parameters to the called function.
  --   
  -- Planned iterators methods in development are (so these are not yet available):
  -- 
  --   * @{#SET_UNIT.ForEachUnitInUnit}: Calls a function for each unit contained within the SET_UNIT.
  --   * @{#SET_UNIT.ForEachUnitCompletelyInZone}: Iterate and call an iterator function for each **alive** UNIT presence completely in a @{Zone}, providing the UNIT and optional parameters to the called function.
  --   * @{#SET_UNIT.ForEachUnitNotInZone}: Iterate and call an iterator function for each **alive** UNIT presence not in a @{Zone}, providing the UNIT and optional parameters to the called function.
  -- 
  -- ## 3.5 ) SET_UNIT atomic methods
  -- 
  -- Various methods exist for a SET_UNIT to perform actions or calculations and retrieve results from the SET_UNIT:
  -- 
  --   * @{#SET_UNIT.GetTypeNames}(): Retrieve the type names of the @{Unit}s in the SET, delimited by a comma.
  -- 
  -- ===
  -- @field #SET_UNIT SET_UNIT
  SET_UNIT = {
    ClassName = "SET_UNIT",
    Units = {},
    Filter = {
      Coalitions = nil,
      Categories = nil,
      Types = nil,
      Countries = nil,
      UnitPrefixes = nil,
    },
    FilterMeta = {
      Coalitions = {
        red = coalition.side.RED,
        blue = coalition.side.BLUE,
        neutral = coalition.side.NEUTRAL,
      },
      Categories = {
        plane = Unit.Category.AIRPLANE,
        helicopter = Unit.Category.HELICOPTER,
        ground = Unit.Category.GROUND_UNIT,
        ship = Unit.Category.SHIP,
        structure = Unit.Category.STRUCTURE,
      },
    },
  }
  
  
  --- Get the first unit from the set.
  -- @function [parent=#SET_UNIT] GetFirst
  -- @param #SET_UNIT self
  -- @return Wrapper.Unit#UNIT The UNIT object.
  
  --- Creates a new SET_UNIT object, building a set of units belonging to a coalitions, categories, countries, types or with defined prefix names.
  -- @param #SET_UNIT self
  -- @return #SET_UNIT
  -- @usage
  -- -- Define a new SET_UNIT Object. This DBObject will contain a reference to all alive Units.
  -- DBObject = SET_UNIT:New()
  function SET_UNIT:New()
  
    -- Inherits from BASE
    local self = BASE:Inherit( self, SET_BASE:New( _DATABASE.UNITS ) ) -- Core.Set#SET_UNIT
  
    return self
  end
  
  --- Add UNIT(s) to SET_UNIT.
  -- @param #SET_UNIT self
  -- @param #string AddUnit A single UNIT.
  -- @return #SET_UNIT self
  function SET_UNIT:AddUnit( AddUnit )
    self:F2( AddUnit:GetName() )
  
    self:Add( AddUnit:GetName(), AddUnit )
      
    return self
  end
  
  
  --- Add UNIT(s) to SET_UNIT.
  -- @param #SET_UNIT self
  -- @param #string AddUnitNames A single name or an array of UNIT names.
  -- @return #SET_UNIT self
  function SET_UNIT:AddUnitsByName( AddUnitNames )
  
    local AddUnitNamesArray = ( type( AddUnitNames ) == "table" ) and AddUnitNames or { AddUnitNames }
    
    self:T( AddUnitNamesArray )
    for AddUnitID, AddUnitName in pairs( AddUnitNamesArray ) do
      self:Add( AddUnitName, UNIT:FindByName( AddUnitName ) )
    end
      
    return self
  end
  
  --- Remove UNIT(s) from SET_UNIT.
  -- @param Core.Set#SET_UNIT self
  -- @param Wrapper.Unit#UNIT RemoveUnitNames A single name or an array of UNIT names.
  -- @return self
  function SET_UNIT:RemoveUnitsByName( RemoveUnitNames )
  
    local RemoveUnitNamesArray = ( type( RemoveUnitNames ) == "table" ) and RemoveUnitNames or { RemoveUnitNames }
    
    for RemoveUnitID, RemoveUnitName in pairs( RemoveUnitNamesArray ) do
      self:Remove( RemoveUnitName )
    end
      
    return self
  end
  
  
  --- Finds a Unit based on the Unit Name.
  -- @param #SET_UNIT self
  -- @param #string UnitName
  -- @return Wrapper.Unit#UNIT The found Unit.
  function SET_UNIT:FindUnit( UnitName )
  
    local UnitFound = self.Set[UnitName]
    return UnitFound
  end
  
  
  
  --- Builds a set of units of coalitions.
  -- Possible current coalitions are red, blue and neutral.
  -- @param #SET_UNIT self
  -- @param #string Coalitions Can take the following values: "red", "blue", "neutral".
  -- @return #SET_UNIT self
  function SET_UNIT:FilterCoalitions( Coalitions )

    self.Filter.Coalitions = {}
    if type( Coalitions ) ~= "table" then
      Coalitions = { Coalitions }
    end
    for CoalitionID, Coalition in pairs( Coalitions ) do
      self.Filter.Coalitions[Coalition] = Coalition
    end
    return self
  end
  
  
  --- Builds a set of units out of categories.
  -- Possible current categories are plane, helicopter, ground, ship.
  -- @param #SET_UNIT self
  -- @param #string Categories Can take the following values: "plane", "helicopter", "ground", "ship".
  -- @return #SET_UNIT self
  function SET_UNIT:FilterCategories( Categories )
    if not self.Filter.Categories then
      self.Filter.Categories = {}
    end
    if type( Categories ) ~= "table" then
      Categories = { Categories }
    end
    for CategoryID, Category in pairs( Categories ) do
      self.Filter.Categories[Category] = Category
    end
    return self
  end
  
  
  --- Builds a set of units of defined unit types.
  -- Possible current types are those types known within DCS world.
  -- @param #SET_UNIT self
  -- @param #string Types Can take those type strings known within DCS world.
  -- @return #SET_UNIT self
  function SET_UNIT:FilterTypes( Types )
    if not self.Filter.Types then
      self.Filter.Types = {}
    end
    if type( Types ) ~= "table" then
      Types = { Types }
    end
    for TypeID, Type in pairs( Types ) do
      self.Filter.Types[Type] = Type
    end
    return self
  end
  
  
  --- Builds a set of units of defined countries.
  -- Possible current countries are those known within DCS world.
  -- @param #SET_UNIT self
  -- @param #string Countries Can take those country strings known within DCS world.
  -- @return #SET_UNIT self
  function SET_UNIT:FilterCountries( Countries )
    if not self.Filter.Countries then
      self.Filter.Countries = {}
    end
    if type( Countries ) ~= "table" then
      Countries = { Countries }
    end
    for CountryID, Country in pairs( Countries ) do
      self.Filter.Countries[Country] = Country
    end
    return self
  end
  
  
  --- Builds a set of units of defined unit prefixes.
  -- All the units starting with the given prefixes will be included within the set.
  -- @param #SET_UNIT self
  -- @param #string Prefixes The prefix of which the unit name starts with.
  -- @return #SET_UNIT self
  function SET_UNIT:FilterPrefixes( Prefixes )
    if not self.Filter.UnitPrefixes then
      self.Filter.UnitPrefixes = {}
    end
    if type( Prefixes ) ~= "table" then
      Prefixes = { Prefixes }
    end
    for PrefixID, Prefix in pairs( Prefixes ) do
      self.Filter.UnitPrefixes[Prefix] = Prefix
    end
    return self
  end
  
  --- Builds a set of units having a radar of give types.
  -- All the units having a radar of a given type will be included within the set.
  -- @param #SET_UNIT self
  -- @param #table RadarTypes The radar types.
  -- @return #SET_UNIT self
  function SET_UNIT:FilterHasRadar( RadarTypes )
  
    self.Filter.RadarTypes = self.Filter.RadarTypes or {}
    if type( RadarTypes ) ~= "table" then
      RadarTypes = { RadarTypes }
    end
    for RadarTypeID, RadarType in pairs( RadarTypes ) do
      self.Filter.RadarTypes[RadarType] = RadarType
    end
    return self
  end
  
  --- Builds a set of SEADable units.
  -- @param #SET_UNIT self
  -- @return #SET_UNIT self
  function SET_UNIT:FilterHasSEAD()
  
    self.Filter.SEAD = true
    return self
  end
  
  
  
  --- Starts the filtering.
  -- @param #SET_UNIT self
  -- @return #SET_UNIT self
  function SET_UNIT:FilterStart()
  
    if _DATABASE then
      self:_FilterStart()
    end
    
    return self
  end
  
  --- Handles the Database to check on an event (birth) that the Object was added in the Database.
  -- This is required, because sometimes the _DATABASE birth event gets called later than the SET_BASE birth event!
  -- @param #SET_UNIT self
  -- @param Core.Event#EVENTDATA Event
  -- @return #string The name of the UNIT
  -- @return #table The UNIT
  function SET_UNIT:AddInDatabase( Event )
    self:F3( { Event } )
  
    if Event.IniObjectCategory == 1 then
      if not self.Database[Event.IniDCSUnitName] then
        self.Database[Event.IniDCSUnitName] = UNIT:Register( Event.IniDCSUnitName )
        self:T3( self.Database[Event.IniDCSUnitName] )
      end
    end
    
    return Event.IniDCSUnitName, self.Database[Event.IniDCSUnitName]
  end
  
  --- Handles the Database to check on any event that Object exists in the Database.
  -- This is required, because sometimes the _DATABASE event gets called later than the SET_BASE event or vise versa!
  -- @param #SET_UNIT self
  -- @param Core.Event#EVENTDATA Event
  -- @return #string The name of the UNIT
  -- @return #table The UNIT
  function SET_UNIT:FindInDatabase( Event )
    self:F2( { Event.IniDCSUnitName, self.Set[Event.IniDCSUnitName], Event } )
  
  
    return Event.IniDCSUnitName, self.Set[Event.IniDCSUnitName]
  end
  
  
  do -- Is Zone methods
  
    --- Check if minimal one element of the SET_UNIT is in the Zone.
    -- @param #SET_UNIT self
    -- @param Core.Zone#ZONE ZoneTest The Zone to be tested for.
    -- @return #boolean
    function SET_UNIT:IsPartiallyInZone( ZoneTest )
      
      local IsPartiallyInZone = false
      
      local function EvaluateZone( ZoneUnit )
      
        local ZoneUnitName =  ZoneUnit:GetName()
        self:E( { ZoneUnitName = ZoneUnitName } )
        if self:FindUnit( ZoneUnitName ) then
          IsPartiallyInZone = true
          self:E( { Found = true } )
          return false
        end
        
        return true
      end

      ZoneTest:SearchZone( EvaluateZone )
      
      return IsPartiallyInZone
    end
    
    
    --- Check if no element of the SET_UNIT is in the Zone.
    -- @param #SET_UNIT self
    -- @param Core.Zone#ZONE ZoneObject The Zone to be tested for.
    -- @return #boolean
    function SET_UNIT:IsNotInZone( Zone )
      
      local IsNotInZone = true
      
      local function EvaluateZone( ZoneUnit )
      
        local ZoneUnitName =  ZoneUnit:GetName()
        if self:FindUnit( ZoneUnitName ) then
          IsNotInZone = false
          return false
        end
        
        return true
      end
      
      Zone:SearchZone( EvaluateZone )
      
      return IsNotInZone
    end
    
  
    --- Check if minimal one element of the SET_UNIT is in the Zone.
    -- @param #SET_UNIT self
    -- @param #function IteratorFunction The function that will be called when there is an alive UNIT in the SET_UNIT. The function needs to accept a UNIT parameter.
    -- @return #SET_UNIT self
    function SET_UNIT:ForEachUnitInZone( IteratorFunction, ... )
      self:F2( arg )
      
      self:ForEach( IteratorFunction, arg, self.Set )
    
      return self
    end
    
  
  end
  
  
  --- Iterate the SET_UNIT and call an interator function for each **alive** UNIT, providing the UNIT and optional parameters.
  -- @param #SET_UNIT self
  -- @param #function IteratorFunction The function that will be called when there is an alive UNIT in the SET_UNIT. The function needs to accept a UNIT parameter.
  -- @return #SET_UNIT self
  function SET_UNIT:ForEachUnit( IteratorFunction, ... )
    self:F2( arg )
    
    self:ForEach( IteratorFunction, arg, self.Set )
  
    return self
  end
  
  --- Iterate the SET_UNIT **sorted *per Threat Level** and call an interator function for each **alive** UNIT, providing the UNIT and optional parameters.
  -- 
  -- @param #SET_UNIT self
  -- @param #number FromThreatLevel The TreatLevel to start the evaluation **From** (this must be a value between 0 and 10).
  -- @param #number ToThreatLevel The TreatLevel to stop the evaluation **To** (this must be a value between 0 and 10).
  -- @param #function IteratorFunction The function that will be called when there is an alive UNIT in the SET_UNIT. The function needs to accept a UNIT parameter.
  -- @return #SET_UNIT self
  -- @usage
  -- 
  --     UnitSet:ForEachUnitPerThreatLevel( 10, 0,
  --       -- @param Wrapper.Unit#UNIT UnitObject The UNIT object in the UnitSet, that will be passed to the local function for evaluation.
  --       function( UnitObject )
  --         .. logic ..
  --       end
  --     )
  -- 
  function SET_UNIT:ForEachUnitPerThreatLevel( FromThreatLevel, ToThreatLevel, IteratorFunction, ... ) --R2.1 Threat Level implementation
    self:F2( arg )
    
    local ThreatLevelSet = {}
    
    if self:Count() ~= 0 then
      for UnitName, UnitObject in pairs( self.Set ) do
        local Unit = UnitObject -- Wrapper.Unit#UNIT
      
        local ThreatLevel = Unit:GetThreatLevel()
        ThreatLevelSet[ThreatLevel] = ThreatLevelSet[ThreatLevel] or {}
        ThreatLevelSet[ThreatLevel].Set = ThreatLevelSet[ThreatLevel].Set or {}
        ThreatLevelSet[ThreatLevel].Set[UnitName] = UnitObject
        self:E( { ThreatLevel = ThreatLevel, ThreatLevelSet = ThreatLevelSet[ThreatLevel].Set } )
      end
      
      local ThreatLevelIncrement = FromThreatLevel <= ToThreatLevel and 1 or -1
      
      for ThreatLevel = FromThreatLevel, ToThreatLevel, ThreatLevelIncrement do
        self:E( { ThreatLevel = ThreatLevel } )
        local ThreatLevelItem = ThreatLevelSet[ThreatLevel]
        if ThreatLevelItem then
          self:ForEach( IteratorFunction, arg, ThreatLevelItem.Set )
        end
      end
    end
    
    return self
  end
  
  
  
  --- Iterate the SET_UNIT and call an iterator function for each **alive** UNIT presence completely in a @{Zone}, providing the UNIT and optional parameters to the called function.
  -- @param #SET_UNIT self
  -- @param Core.Zone#ZONE ZoneObject The Zone to be tested for.
  -- @param #function IteratorFunction The function that will be called when there is an alive UNIT in the SET_UNIT. The function needs to accept a UNIT parameter.
  -- @return #SET_UNIT self
  function SET_UNIT:ForEachUnitCompletelyInZone( ZoneObject, IteratorFunction, ... )
    self:F2( arg )
    
    self:ForEach( IteratorFunction, arg, self.Set,
      --- @param Core.Zone#ZONE_BASE ZoneObject
      -- @param Wrapper.Unit#UNIT UnitObject
      function( ZoneObject, UnitObject )
        if UnitObject:IsInZone( ZoneObject ) then
          return true
        else
          return false
        end
      end, { ZoneObject } )
  
    return self
  end
  
  --- Iterate the SET_UNIT and call an iterator function for each **alive** UNIT presence not in a @{Zone}, providing the UNIT and optional parameters to the called function.
  -- @param #SET_UNIT self
  -- @param Core.Zone#ZONE ZoneObject The Zone to be tested for.
  -- @param #function IteratorFunction The function that will be called when there is an alive UNIT in the SET_UNIT. The function needs to accept a UNIT parameter.
  -- @return #SET_UNIT self
  function SET_UNIT:ForEachUnitNotInZone( ZoneObject, IteratorFunction, ... )
    self:F2( arg )
    
    self:ForEach( IteratorFunction, arg, self.Set,
      --- @param Core.Zone#ZONE_BASE ZoneObject
      -- @param Wrapper.Unit#UNIT UnitObject
      function( ZoneObject, UnitObject )
        if UnitObject:IsNotInZone( ZoneObject ) then
          return true
        else
          return false
        end
      end, { ZoneObject } )
  
    return self
  end
  
  --- Returns map of unit types.
  -- @param #SET_UNIT self
  -- @return #map<#string,#number> A map of the unit types found. The key is the UnitTypeName and the value is the amount of unit types found.
  function SET_UNIT:GetUnitTypes()
    self:F2()
  
    local MT = {} -- Message Text
    local UnitTypes = {}
    
    for UnitID, UnitData in pairs( self:GetSet() ) do
      local TextUnit = UnitData -- Wrapper.Unit#UNIT
      if TextUnit:IsAlive() then
        local UnitType = TextUnit:GetTypeName()
    
        if not UnitTypes[UnitType] then
          UnitTypes[UnitType] = 1
        else
          UnitTypes[UnitType] = UnitTypes[UnitType] + 1
        end
      end
    end
  
    for UnitTypeID, UnitType in pairs( UnitTypes ) do
      MT[#MT+1] = UnitType .. " of " .. UnitTypeID
    end
  
    return UnitTypes
  end
  
  
  --- Returns a comma separated string of the unit types with a count in the  @{Set}.
  -- @param #SET_UNIT self
  -- @return #string The unit types string
  function SET_UNIT:GetUnitTypesText()
    self:F2()
  
    local MT = {} -- Message Text
    local UnitTypes = self:GetUnitTypes()
    
    for UnitTypeID, UnitType in pairs( UnitTypes ) do
      MT[#MT+1] = UnitType .. " of " .. UnitTypeID
    end
  
    return table.concat( MT, ", " )
  end
  
  --- Returns map of unit threat levels.
  -- @param #SET_UNIT self
  -- @return #table.
  function SET_UNIT:GetUnitThreatLevels()
    self:F2()
  
    local UnitThreatLevels = {}
    
    for UnitID, UnitData in pairs( self:GetSet() ) do
      local ThreatUnit = UnitData -- Wrapper.Unit#UNIT
      if ThreatUnit:IsAlive() then
        local UnitThreatLevel, UnitThreatLevelText = ThreatUnit:GetThreatLevel()
        local ThreatUnitName = ThreatUnit:GetName()
    
        UnitThreatLevels[UnitThreatLevel] = UnitThreatLevels[UnitThreatLevel] or {}
        UnitThreatLevels[UnitThreatLevel].UnitThreatLevelText = UnitThreatLevelText
        UnitThreatLevels[UnitThreatLevel].Units = UnitThreatLevels[UnitThreatLevel].Units or {}
        UnitThreatLevels[UnitThreatLevel].Units[ThreatUnitName] = ThreatUnit
      end
    end
  
    return UnitThreatLevels
  end
  
  --- Calculate the maxium A2G threat level of the SET_UNIT.
  -- @param #SET_UNIT self
  -- @return #number The maximum threatlevel
  function SET_UNIT:CalculateThreatLevelA2G()
    
    local MaxThreatLevelA2G = 0
    local MaxThreatText = ""
    for UnitName, UnitData in pairs( self:GetSet() ) do
      local ThreatUnit = UnitData -- Wrapper.Unit#UNIT
      local ThreatLevelA2G, ThreatText = ThreatUnit:GetThreatLevel()
      if ThreatLevelA2G > MaxThreatLevelA2G then
        MaxThreatLevelA2G = ThreatLevelA2G
        MaxThreatText = ThreatText
      end
    end
  
    self:F( { MaxThreatLevelA2G = MaxThreatLevelA2G, MaxThreatText = MaxThreatText } )
    return MaxThreatLevelA2G, MaxThreatText
    
  end
  
  --- Get the center coordinate of the SET_UNIT.
  -- @param #SET_UNIT self
  -- @return Core.Point#COORDINATE The center coordinate of all the units in the set, including heading in degrees and speed in mps in case of moving units.
  function SET_UNIT:GetCoordinate()
  
    local Coordinate = self:GetFirst():GetCoordinate()
    
    local x1 = Coordinate.x
    local x2 = Coordinate.x
    local y1 = Coordinate.y
    local y2 = Coordinate.y
    local z1 = Coordinate.z
    local z2 = Coordinate.z
    local MaxVelocity = 0
    local AvgHeading = nil
    local MovingCount = 0
  
    for UnitName, UnitData in pairs( self:GetSet() ) do
    
      local Unit = UnitData -- Wrapper.Unit#UNIT
      local Coordinate = Unit:GetCoordinate()
  
      x1 = ( Coordinate.x < x1 ) and Coordinate.x or x1
      x2 = ( Coordinate.x > x2 ) and Coordinate.x or x2
      y1 = ( Coordinate.y < y1 ) and Coordinate.y or y1
      y2 = ( Coordinate.y > y2 ) and Coordinate.y or y2
      z1 = ( Coordinate.y < z1 ) and Coordinate.z or z1
      z2 = ( Coordinate.y > z2 ) and Coordinate.z or z2
  
      local Velocity = Coordinate:GetVelocity()
      if Velocity ~= 0  then
        MaxVelocity = ( MaxVelocity < Velocity ) and Velocity or MaxVelocity
        local Heading = Coordinate:GetHeading()
        AvgHeading = AvgHeading and ( AvgHeading + Heading ) or Heading
        MovingCount = MovingCount + 1
      end
    end
  
    AvgHeading = AvgHeading and ( AvgHeading / MovingCount )
    
    Coordinate.x = ( x2 - x1 ) / 2 + x1
    Coordinate.y = ( y2 - y1 ) / 2 + y1
    Coordinate.z = ( z2 - z1 ) / 2 + z1
    Coordinate:SetHeading( AvgHeading )
    Coordinate:SetVelocity( MaxVelocity )
  
    self:F( { Coordinate = Coordinate } )
    return Coordinate
  
  end
  
  --- Get the maximum velocity of the SET_UNIT.
  -- @param #SET_UNIT self
  -- @return #number The speed in mps in case of moving units.
  function SET_UNIT:GetVelocity()
  
    local Coordinate = self:GetFirst():GetCoordinate()
    
    local MaxVelocity = 0
  
    for UnitName, UnitData in pairs( self:GetSet() ) do
    
      local Unit = UnitData -- Wrapper.Unit#UNIT
      local Coordinate = Unit:GetCoordinate()
  
      local Velocity = Coordinate:GetVelocity()
      if Velocity ~= 0  then
        MaxVelocity = ( MaxVelocity < Velocity ) and Velocity or MaxVelocity
      end
    end
  
    self:F( { MaxVelocity = MaxVelocity } )
    return MaxVelocity
  
  end
  
  --- Get the average heading of the SET_UNIT.
  -- @param #SET_UNIT self
  -- @return #number Heading Heading in degrees and speed in mps in case of moving units.
  function SET_UNIT:GetHeading()
  
    local HeadingSet = nil
    local MovingCount = 0
  
    for UnitName, UnitData in pairs( self:GetSet() ) do
    
      local Unit = UnitData -- Wrapper.Unit#UNIT
      local Coordinate = Unit:GetCoordinate()
  
      local Velocity = Coordinate:GetVelocity()
      if Velocity ~= 0  then
        local Heading = Coordinate:GetHeading()
        if HeadingSet == nil then
          HeadingSet = Heading
        else
          local HeadingDiff = ( HeadingSet - Heading + 180 + 360 ) % 360 - 180
          HeadingDiff = math.abs( HeadingDiff )
          if HeadingDiff > 5 then
            HeadingSet = nil
            break
          end
        end        
      end
    end
  
    return HeadingSet
  
  end
  
  
  
  --- Returns if the @{Set} has targets having a radar (of a given type).
  -- @param #SET_UNIT self
  -- @param Dcs.DCSWrapper.Unit#Unit.RadarType RadarType
  -- @return #number The amount of radars in the Set with the given type
  function SET_UNIT:HasRadar( RadarType )
    self:F2( RadarType )
  
    local RadarCount = 0
    for UnitID, UnitData in pairs( self:GetSet()) do
      local UnitSensorTest = UnitData -- Wrapper.Unit#UNIT
      local HasSensors
      if RadarType then
        HasSensors = UnitSensorTest:HasSensors( Unit.SensorType.RADAR, RadarType )
      else
        HasSensors = UnitSensorTest:HasSensors( Unit.SensorType.RADAR )
      end
      self:T3(HasSensors)
      if HasSensors then
        RadarCount = RadarCount + 1
      end
    end
  
    return RadarCount
  end
  
  --- Returns if the @{Set} has targets that can be SEADed.
  -- @param #SET_UNIT self
  -- @return #number The amount of SEADable units in the Set
  function SET_UNIT:HasSEAD()
    self:F2()
  
    local SEADCount = 0
    for UnitID, UnitData in pairs( self:GetSet()) do
      local UnitSEAD = UnitData -- Wrapper.Unit#UNIT
      if UnitSEAD:IsAlive() then
        local UnitSEADAttributes = UnitSEAD:GetDesc().attributes
    
        local HasSEAD = UnitSEAD:HasSEAD()
           
        self:T3(HasSEAD)
        if HasSEAD then
          SEADCount = SEADCount + 1
        end
      end
    end
  
    return SEADCount
  end
  
  --- Returns if the @{Set} has ground targets.
  -- @param #SET_UNIT self
  -- @return #number The amount of ground targets in the Set.
  function SET_UNIT:HasGroundUnits()
    self:F2()
  
    local GroundUnitCount = 0
    for UnitID, UnitData in pairs( self:GetSet()) do
      local UnitTest = UnitData -- Wrapper.Unit#UNIT
      if UnitTest:IsGround() then
        GroundUnitCount = GroundUnitCount + 1
      end
    end
  
    return GroundUnitCount
  end
  
  --- Returns if the @{Set} has friendly ground units.
  -- @param #SET_UNIT self
  -- @return #number The amount of ground targets in the Set.
  function SET_UNIT:HasFriendlyUnits( FriendlyCoalition )
    self:F2()
  
    local FriendlyUnitCount = 0
    for UnitID, UnitData in pairs( self:GetSet()) do
      local UnitTest = UnitData -- Wrapper.Unit#UNIT
      if UnitTest:IsFriendly( FriendlyCoalition ) then
        FriendlyUnitCount = FriendlyUnitCount + 1
      end
    end
  
    return FriendlyUnitCount
  end
  
  
  
  ----- Iterate the SET_UNIT and call an interator function for each **alive** player, providing the Unit of the player and optional parameters.
  ---- @param #SET_UNIT self
  ---- @param #function IteratorFunction The function that will be called when there is an alive player in the SET_UNIT. The function needs to accept a UNIT parameter.
  ---- @return #SET_UNIT self
  --function SET_UNIT:ForEachPlayer( IteratorFunction, ... )
  --  self:F2( arg )
  --  
  --  self:ForEach( IteratorFunction, arg, self.PlayersAlive )
  --  
  --  return self
  --end
  --
  --
  ----- Iterate the SET_UNIT and call an interator function for each client, providing the Client to the function and optional parameters.
  ---- @param #SET_UNIT self
  ---- @param #function IteratorFunction The function that will be called when there is an alive player in the SET_UNIT. The function needs to accept a CLIENT parameter.
  ---- @return #SET_UNIT self
  --function SET_UNIT:ForEachClient( IteratorFunction, ... )
  --  self:F2( arg )
  --  
  --  self:ForEach( IteratorFunction, arg, self.Clients )
  --
  --  return self
  --end
  
  
  ---
  -- @param #SET_UNIT self
  -- @param Wrapper.Unit#UNIT MUnit
  -- @return #SET_UNIT self
  function SET_UNIT:IsIncludeObject( MUnit )
    self:F2( MUnit )
    local MUnitInclude = true
  
    if self.Filter.Coalitions then
      local MUnitCoalition = false
      for CoalitionID, CoalitionName in pairs( self.Filter.Coalitions ) do
        self:E( { "Coalition:", MUnit:GetCoalition(), self.FilterMeta.Coalitions[CoalitionName], CoalitionName } )
        if self.FilterMeta.Coalitions[CoalitionName] and self.FilterMeta.Coalitions[CoalitionName] == MUnit:GetCoalition() then
          MUnitCoalition = true
        end
      end
      MUnitInclude = MUnitInclude and MUnitCoalition
    end
    
    if self.Filter.Categories then
      local MUnitCategory = false
      for CategoryID, CategoryName in pairs( self.Filter.Categories ) do
        self:T3( { "Category:", MUnit:GetDesc().category, self.FilterMeta.Categories[CategoryName], CategoryName } )
        if self.FilterMeta.Categories[CategoryName] and self.FilterMeta.Categories[CategoryName] == MUnit:GetDesc().category then
          MUnitCategory = true
        end
      end
      MUnitInclude = MUnitInclude and MUnitCategory
    end
    
    if self.Filter.Types then
      local MUnitType = false
      for TypeID, TypeName in pairs( self.Filter.Types ) do
        self:T3( { "Type:", MUnit:GetTypeName(), TypeName } )
        if TypeName == MUnit:GetTypeName() then
          MUnitType = true
        end
      end
      MUnitInclude = MUnitInclude and MUnitType
    end
    
    if self.Filter.Countries then
      local MUnitCountry = false
      for CountryID, CountryName in pairs( self.Filter.Countries ) do
        self:T3( { "Country:", MUnit:GetCountry(), CountryName } )
        if country.id[CountryName] == MUnit:GetCountry() then
          MUnitCountry = true
        end
      end
      MUnitInclude = MUnitInclude and MUnitCountry
    end
  
    if self.Filter.UnitPrefixes then
      local MUnitPrefix = false
      for UnitPrefixId, UnitPrefix in pairs( self.Filter.UnitPrefixes ) do
        self:T3( { "Prefix:", string.find( MUnit:GetName(), UnitPrefix, 1 ), UnitPrefix } )
        if string.find( MUnit:GetName(), UnitPrefix, 1 ) then
          MUnitPrefix = true
        end
      end
      MUnitInclude = MUnitInclude and MUnitPrefix
    end
  
    if self.Filter.RadarTypes then
      local MUnitRadar = false
      for RadarTypeID, RadarType in pairs( self.Filter.RadarTypes ) do
        self:T3( { "Radar:", RadarType } )
        if MUnit:HasSensors( Unit.SensorType.RADAR, RadarType ) == true then
          if MUnit:GetRadar() == true then -- This call is necessary to evaluate the SEAD capability.
            self:T3( "RADAR Found" )
          end
          MUnitRadar = true
        end
      end
      MUnitInclude = MUnitInclude and MUnitRadar
    end
  
    if self.Filter.SEAD then
      local MUnitSEAD = false
      if MUnit:HasSEAD() == true then
        self:T3( "SEAD Found" )
        MUnitSEAD = true
      end
      MUnitInclude = MUnitInclude and MUnitSEAD
    end
  
    self:T2( MUnitInclude )
    return MUnitInclude
  end
  
  
  --- Retrieve the type names of the @{Unit}s in the SET, delimited by an optional delimiter.
  -- @param #SET_UNIT self
  -- @param #string Delimiter (optional) The delimiter, which is default a comma.
  -- @return #string The types of the @{Unit}s delimited.
  function SET_UNIT:GetTypeNames( Delimiter )
  
    Delimiter = Delimiter or ", "
    local TypeReport = REPORT:New()
    local Types = {}
    
    for UnitName, UnitData in pairs( self:GetSet() ) do
    
      local Unit = UnitData -- Wrapper.Unit#UNIT
      local UnitTypeName = Unit:GetTypeName()
      
      if not Types[UnitTypeName] then
        Types[UnitTypeName] = UnitTypeName
        TypeReport:Add( UnitTypeName )
      end
    end
    
    return TypeReport:Text( Delimiter )
  end
  
end

do -- SET_STATIC

  --- @type SET_STATIC
  -- @extends Core.Set#SET_BASE
  
  --- # 3) SET_STATIC class, extends @{Set#SET_BASE}
  -- 
  -- Mission designers can use the SET_STATIC class to build sets of Statics belonging to certain:
  -- 
  --  * Coalitions
  --  * Categories
  --  * Countries
  --  * Static types
  --  * Starting with certain prefix strings.
  --  
  -- ## 3.1) SET_STATIC constructor
  --
  -- Create a new SET_STATIC object with the @{#SET_STATIC.New} method:
  -- 
  --    * @{#SET_STATIC.New}: Creates a new SET_STATIC object.
  --   
  -- ## 3.2) Add or Remove STATIC(s) from SET_STATIC
  --
  -- STATICs can be added and removed using the @{Set#SET_STATIC.AddStaticsByName} and @{Set#SET_STATIC.RemoveStaticsByName} respectively. 
  -- These methods take a single STATIC name or an array of STATIC names to be added or removed from SET_STATIC.
  -- 
  -- ## 3.3) SET_STATIC filter criteria
  -- 
  -- You can set filter criteria to define the set of units within the SET_STATIC.
  -- Filter criteria are defined by:
  -- 
  --    * @{#SET_STATIC.FilterCoalitions}: Builds the SET_STATIC with the units belonging to the coalition(s).
  --    * @{#SET_STATIC.FilterCategories}: Builds the SET_STATIC with the units belonging to the category(ies).
  --    * @{#SET_STATIC.FilterTypes}: Builds the SET_STATIC with the units belonging to the unit type(s).
  --    * @{#SET_STATIC.FilterCountries}: Builds the SET_STATIC with the units belonging to the country(ies).
  --    * @{#SET_STATIC.FilterPrefixes}: Builds the SET_STATIC with the units starting with the same prefix string(s).
  --   
  -- Once the filter criteria have been set for the SET_STATIC, you can start filtering using:
  -- 
  --   * @{#SET_STATIC.FilterStart}: Starts the filtering of the units within the SET_STATIC.
  -- 
  -- Planned filter criteria within development are (so these are not yet available):
  -- 
  --    * @{#SET_STATIC.FilterZones}: Builds the SET_STATIC with the units within a @{Zone#ZONE}.
  -- 
  -- ## 3.4) SET_STATIC iterators
  -- 
  -- Once the filters have been defined and the SET_STATIC has been built, you can iterate the SET_STATIC with the available iterator methods.
  -- The iterator methods will walk the SET_STATIC set, and call for each element within the set a function that you provide.
  -- The following iterator methods are currently available within the SET_STATIC:
  -- 
  --   * @{#SET_STATIC.ForEachStatic}: Calls a function for each alive unit it finds within the SET_STATIC.
  --   * @{#SET_GROUP.ForEachGroupCompletelyInZone}: Iterate the SET_GROUP and call an iterator function for each **alive** GROUP presence completely in a @{Zone}, providing the GROUP and optional parameters to the called function.
  --   * @{#SET_GROUP.ForEachGroupNotInZone}: Iterate the SET_GROUP and call an iterator function for each **alive** GROUP presence not in a @{Zone}, providing the GROUP and optional parameters to the called function.
  --   
  -- Planned iterators methods in development are (so these are not yet available):
  -- 
  --   * @{#SET_STATIC.ForEachStaticInZone}: Calls a function for each unit contained within the SET_STATIC.
  --   * @{#SET_STATIC.ForEachStaticCompletelyInZone}: Iterate and call an iterator function for each **alive** STATIC presence completely in a @{Zone}, providing the STATIC and optional parameters to the called function.
  --   * @{#SET_STATIC.ForEachStaticNotInZone}: Iterate and call an iterator function for each **alive** STATIC presence not in a @{Zone}, providing the STATIC and optional parameters to the called function.
  -- 
  -- ## 3.5 ) SET_STATIC atomic methods
  -- 
  -- Various methods exist for a SET_STATIC to perform actions or calculations and retrieve results from the SET_STATIC:
  -- 
  --   * @{#SET_STATIC.GetTypeNames}(): Retrieve the type names of the @{Static}s in the SET, delimited by a comma.
  -- 
  -- ===
  -- @field #SET_STATIC SET_STATIC
  SET_STATIC = {
    ClassName = "SET_STATIC",
    Statics = {},
    Filter = {
      Coalitions = nil,
      Categories = nil,
      Types = nil,
      Countries = nil,
      StaticPrefixes = nil,
    },
    FilterMeta = {
      Coalitions = {
        red = coalition.side.RED,
        blue = coalition.side.BLUE,
        neutral = coalition.side.NEUTRAL,
      },
      Categories = {
        plane = Unit.Category.AIRPLANE,
        helicopter = Unit.Category.HELICOPTER,
        ground = Unit.Category.GROUND_STATIC,
        ship = Unit.Category.SHIP,
        structure = Unit.Category.STRUCTURE,
      },
    },
  }
  
  
  --- Get the first unit from the set.
  -- @function [parent=#SET_STATIC] GetFirst
  -- @param #SET_STATIC self
  -- @return Wrapper.Static#STATIC The STATIC object.
  
  --- Creates a new SET_STATIC object, building a set of units belonging to a coalitions, categories, countries, types or with defined prefix names.
  -- @param #SET_STATIC self
  -- @return #SET_STATIC
  -- @usage
  -- -- Define a new SET_STATIC Object. This DBObject will contain a reference to all alive Statics.
  -- DBObject = SET_STATIC:New()
  function SET_STATIC:New()
  
    -- Inherits from BASE
    local self = BASE:Inherit( self, SET_BASE:New( _DATABASE.STATICS ) ) -- Core.Set#SET_STATIC
  
    return self
  end
  
  --- Add STATIC(s) to SET_STATIC.
  -- @param #SET_STATIC self
  -- @param #string AddStatic A single STATIC.
  -- @return #SET_STATIC self
  function SET_STATIC:AddStatic( AddStatic )
    self:F2( AddStatic:GetName() )
  
    self:Add( AddStatic:GetName(), AddStatic )
      
    return self
  end
  
  
  --- Add STATIC(s) to SET_STATIC.
  -- @param #SET_STATIC self
  -- @param #string AddStaticNames A single name or an array of STATIC names.
  -- @return #SET_STATIC self
  function SET_STATIC:AddStaticsByName( AddStaticNames )
  
    local AddStaticNamesArray = ( type( AddStaticNames ) == "table" ) and AddStaticNames or { AddStaticNames }
    
    self:T( AddStaticNamesArray )
    for AddStaticID, AddStaticName in pairs( AddStaticNamesArray ) do
      self:Add( AddStaticName, STATIC:FindByName( AddStaticName ) )
    end
      
    return self
  end
  
  --- Remove STATIC(s) from SET_STATIC.
  -- @param Core.Set#SET_STATIC self
  -- @param Wrapper.Static#STATIC RemoveStaticNames A single name or an array of STATIC names.
  -- @return self
  function SET_STATIC:RemoveStaticsByName( RemoveStaticNames )
  
    local RemoveStaticNamesArray = ( type( RemoveStaticNames ) == "table" ) and RemoveStaticNames or { RemoveStaticNames }
    
    for RemoveStaticID, RemoveStaticName in pairs( RemoveStaticNamesArray ) do
      self:Remove( RemoveStaticName )
    end
      
    return self
  end
  
  
  --- Finds a Static based on the Static Name.
  -- @param #SET_STATIC self
  -- @param #string StaticName
  -- @return Wrapper.Static#STATIC The found Static.
  function SET_STATIC:FindStatic( StaticName )
  
    local StaticFound = self.Set[StaticName]
    return StaticFound
  end
  
  
  
  --- Builds a set of units of coalitions.
  -- Possible current coalitions are red, blue and neutral.
  -- @param #SET_STATIC self
  -- @param #string Coalitions Can take the following values: "red", "blue", "neutral".
  -- @return #SET_STATIC self
  function SET_STATIC:FilterCoalitions( Coalitions )
    if not self.Filter.Coalitions then
      self.Filter.Coalitions = {}
    end
    if type( Coalitions ) ~= "table" then
      Coalitions = { Coalitions }
    end
    for CoalitionID, Coalition in pairs( Coalitions ) do
      self.Filter.Coalitions[Coalition] = Coalition
    end
    return self
  end
  
  
  --- Builds a set of units out of categories.
  -- Possible current categories are plane, helicopter, ground, ship.
  -- @param #SET_STATIC self
  -- @param #string Categories Can take the following values: "plane", "helicopter", "ground", "ship".
  -- @return #SET_STATIC self
  function SET_STATIC:FilterCategories( Categories )
    if not self.Filter.Categories then
      self.Filter.Categories = {}
    end
    if type( Categories ) ~= "table" then
      Categories = { Categories }
    end
    for CategoryID, Category in pairs( Categories ) do
      self.Filter.Categories[Category] = Category
    end
    return self
  end
  
  
  --- Builds a set of units of defined unit types.
  -- Possible current types are those types known within DCS world.
  -- @param #SET_STATIC self
  -- @param #string Types Can take those type strings known within DCS world.
  -- @return #SET_STATIC self
  function SET_STATIC:FilterTypes( Types )
    if not self.Filter.Types then
      self.Filter.Types = {}
    end
    if type( Types ) ~= "table" then
      Types = { Types }
    end
    for TypeID, Type in pairs( Types ) do
      self.Filter.Types[Type] = Type
    end
    return self
  end
  
  
  --- Builds a set of units of defined countries.
  -- Possible current countries are those known within DCS world.
  -- @param #SET_STATIC self
  -- @param #string Countries Can take those country strings known within DCS world.
  -- @return #SET_STATIC self
  function SET_STATIC:FilterCountries( Countries )
    if not self.Filter.Countries then
      self.Filter.Countries = {}
    end
    if type( Countries ) ~= "table" then
      Countries = { Countries }
    end
    for CountryID, Country in pairs( Countries ) do
      self.Filter.Countries[Country] = Country
    end
    return self
  end
  
  
  --- Builds a set of units of defined unit prefixes.
  -- All the units starting with the given prefixes will be included within the set.
  -- @param #SET_STATIC self
  -- @param #string Prefixes The prefix of which the unit name starts with.
  -- @return #SET_STATIC self
  function SET_STATIC:FilterPrefixes( Prefixes )
    if not self.Filter.StaticPrefixes then
      self.Filter.StaticPrefixes = {}
    end
    if type( Prefixes ) ~= "table" then
      Prefixes = { Prefixes }
    end
    for PrefixID, Prefix in pairs( Prefixes ) do
      self.Filter.StaticPrefixes[Prefix] = Prefix
    end
    return self
  end
  
  
  --- Starts the filtering.
  -- @param #SET_STATIC self
  -- @return #SET_STATIC self
  function SET_STATIC:FilterStart()
  
    if _DATABASE then
      self:_FilterStart()
    end
    
    return self
  end
  
  --- Handles the Database to check on an event (birth) that the Object was added in the Database.
  -- This is required, because sometimes the _DATABASE birth event gets called later than the SET_BASE birth event!
  -- @param #SET_STATIC self
  -- @param Core.Event#EVENTDATA Event
  -- @return #string The name of the STATIC
  -- @return #table The STATIC
  function SET_STATIC:AddInDatabase( Event )
    self:F3( { Event } )
  
    if Event.IniObjectCategory == Object.Category.STATIC then
      if not self.Database[Event.IniDCSStaticName] then
        self.Database[Event.IniDCSStaticName] = STATIC:Register( Event.IniDCSStaticName )
        self:T3( self.Database[Event.IniDCSStaticName] )
      end
    end
    
    return Event.IniDCSStaticName, self.Database[Event.IniDCSStaticName]
  end
  
  --- Handles the Database to check on any event that Object exists in the Database.
  -- This is required, because sometimes the _DATABASE event gets called later than the SET_BASE event or vise versa!
  -- @param #SET_STATIC self
  -- @param Core.Event#EVENTDATA Event
  -- @return #string The name of the STATIC
  -- @return #table The STATIC
  function SET_STATIC:FindInDatabase( Event )
    self:F2( { Event.IniDCSStaticName, self.Set[Event.IniDCSStaticName], Event } )
  
  
    return Event.IniDCSStaticName, self.Set[Event.IniDCSStaticName]
  end
  
  
  do -- Is Zone methods
  
    --- Check if minimal one element of the SET_STATIC is in the Zone.
    -- @param #SET_STATIC self
    -- @param Core.Zone#ZONE Zone The Zone to be tested for.
    -- @return #boolean
    function SET_STATIC:IsPatriallyInZone( Zone )
      
      local IsPartiallyInZone = false
      
      local function EvaluateZone( ZoneStatic )
      
        local ZoneStaticName =  ZoneStatic:GetName()
        if self:FindStatic( ZoneStaticName ) then
          IsPartiallyInZone = true
          return false
        end
        
        return true
      end
      
      return IsPartiallyInZone
    end
    
    
    --- Check if no element of the SET_STATIC is in the Zone.
    -- @param #SET_STATIC self
    -- @param Core.Zone#ZONE ZoneObject The Zone to be tested for.
    -- @return #boolean
    function SET_STATIC:IsNotInZone( Zone )
      
      local IsNotInZone = true
      
      local function EvaluateZone( ZoneStatic )
      
        local ZoneStaticName =  ZoneStatic:GetName()
        if self:FindStatic( ZoneStaticName ) then
          IsNotInZone = false
          return false
        end
        
        return true
      end
      
      Zone:Search( EvaluateZone )
      
      return IsNotInZone
    end
    
  
    --- Check if minimal one element of the SET_STATIC is in the Zone.
    -- @param #SET_STATIC self
    -- @param #function IteratorFunction The function that will be called when there is an alive STATIC in the SET_STATIC. The function needs to accept a STATIC parameter.
    -- @return #SET_STATIC self
    function SET_STATIC:ForEachStaticInZone( IteratorFunction, ... )
      self:F2( arg )
      
      self:ForEach( IteratorFunction, arg, self.Set )
    
      return self
    end
    
  
  end
  
  
  --- Iterate the SET_STATIC and call an interator function for each **alive** STATIC, providing the STATIC and optional parameters.
  -- @param #SET_STATIC self
  -- @param #function IteratorFunction The function that will be called when there is an alive STATIC in the SET_STATIC. The function needs to accept a STATIC parameter.
  -- @return #SET_STATIC self
  function SET_STATIC:ForEachStatic( IteratorFunction, ... )
    self:F2( arg )
    
    self:ForEach( IteratorFunction, arg, self.Set )
  
    return self
  end
  
  
  --- Iterate the SET_STATIC and call an iterator function for each **alive** STATIC presence completely in a @{Zone}, providing the STATIC and optional parameters to the called function.
  -- @param #SET_STATIC self
  -- @param Core.Zone#ZONE ZoneObject The Zone to be tested for.
  -- @param #function IteratorFunction The function that will be called when there is an alive STATIC in the SET_STATIC. The function needs to accept a STATIC parameter.
  -- @return #SET_STATIC self
  function SET_STATIC:ForEachStaticCompletelyInZone( ZoneObject, IteratorFunction, ... )
    self:F2( arg )
    
    self:ForEach( IteratorFunction, arg, self.Set,
      --- @param Core.Zone#ZONE_BASE ZoneObject
      -- @param Wrapper.Static#STATIC StaticObject
      function( ZoneObject, StaticObject )
        if StaticObject:IsInZone( ZoneObject ) then
          return true
        else
          return false
        end
      end, { ZoneObject } )
  
    return self
  end
  
  --- Iterate the SET_STATIC and call an iterator function for each **alive** STATIC presence not in a @{Zone}, providing the STATIC and optional parameters to the called function.
  -- @param #SET_STATIC self
  -- @param Core.Zone#ZONE ZoneObject The Zone to be tested for.
  -- @param #function IteratorFunction The function that will be called when there is an alive STATIC in the SET_STATIC. The function needs to accept a STATIC parameter.
  -- @return #SET_STATIC self
  function SET_STATIC:ForEachStaticNotInZone( ZoneObject, IteratorFunction, ... )
    self:F2( arg )
    
    self:ForEach( IteratorFunction, arg, self.Set,
      --- @param Core.Zone#ZONE_BASE ZoneObject
      -- @param Wrapper.Static#STATIC StaticObject
      function( ZoneObject, StaticObject )
        if StaticObject:IsNotInZone( ZoneObject ) then
          return true
        else
          return false
        end
      end, { ZoneObject } )
  
    return self
  end
  
  --- Returns map of unit types.
  -- @param #SET_STATIC self
  -- @return #map<#string,#number> A map of the unit types found. The key is the StaticTypeName and the value is the amount of unit types found.
  function SET_STATIC:GetStaticTypes()
    self:F2()
  
    local MT = {} -- Message Text
    local StaticTypes = {}
    
    for StaticID, StaticData in pairs( self:GetSet() ) do
      local TextStatic = StaticData -- Wrapper.Static#STATIC
      if TextStatic:IsAlive() then
        local StaticType = TextStatic:GetTypeName()
    
        if not StaticTypes[StaticType] then
          StaticTypes[StaticType] = 1
        else
          StaticTypes[StaticType] = StaticTypes[StaticType] + 1
        end
      end
    end
  
    for StaticTypeID, StaticType in pairs( StaticTypes ) do
      MT[#MT+1] = StaticType .. " of " .. StaticTypeID
    end
  
    return StaticTypes
  end
  
  
  --- Returns a comma separated string of the unit types with a count in the  @{Set}.
  -- @param #SET_STATIC self
  -- @return #string The unit types string
  function SET_STATIC:GetStaticTypesText()
    self:F2()
  
    local MT = {} -- Message Text
    local StaticTypes = self:GetStaticTypes()
    
    for StaticTypeID, StaticType in pairs( StaticTypes ) do
      MT[#MT+1] = StaticType .. " of " .. StaticTypeID
    end
  
    return table.concat( MT, ", " )
  end
  
  --- Get the center coordinate of the SET_STATIC.
  -- @param #SET_STATIC self
  -- @return Core.Point#COORDINATE The center coordinate of all the units in the set, including heading in degrees and speed in mps in case of moving units.
  function SET_STATIC:GetCoordinate()
  
    local Coordinate = self:GetFirst():GetCoordinate()
    
    local x1 = Coordinate.x
    local x2 = Coordinate.x
    local y1 = Coordinate.y
    local y2 = Coordinate.y
    local z1 = Coordinate.z
    local z2 = Coordinate.z
    local MaxVelocity = 0
    local AvgHeading = nil
    local MovingCount = 0
  
    for StaticName, StaticData in pairs( self:GetSet() ) do
    
      local Static = StaticData -- Wrapper.Static#STATIC
      local Coordinate = Static:GetCoordinate()
  
      x1 = ( Coordinate.x < x1 ) and Coordinate.x or x1
      x2 = ( Coordinate.x > x2 ) and Coordinate.x or x2
      y1 = ( Coordinate.y < y1 ) and Coordinate.y or y1
      y2 = ( Coordinate.y > y2 ) and Coordinate.y or y2
      z1 = ( Coordinate.y < z1 ) and Coordinate.z or z1
      z2 = ( Coordinate.y > z2 ) and Coordinate.z or z2
  
      local Velocity = Coordinate:GetVelocity()
      if Velocity ~= 0  then
        MaxVelocity = ( MaxVelocity < Velocity ) and Velocity or MaxVelocity
        local Heading = Coordinate:GetHeading()
        AvgHeading = AvgHeading and ( AvgHeading + Heading ) or Heading
        MovingCount = MovingCount + 1
      end
    end
  
    AvgHeading = AvgHeading and ( AvgHeading / MovingCount )
    
    Coordinate.x = ( x2 - x1 ) / 2 + x1
    Coordinate.y = ( y2 - y1 ) / 2 + y1
    Coordinate.z = ( z2 - z1 ) / 2 + z1
    Coordinate:SetHeading( AvgHeading )
    Coordinate:SetVelocity( MaxVelocity )
  
    self:F( { Coordinate = Coordinate } )
    return Coordinate
  
  end
  
  --- Get the maximum velocity of the SET_STATIC.
  -- @param #SET_STATIC self
  -- @return #number The speed in mps in case of moving units.
  function SET_STATIC:GetVelocity()
  
    return 0
  
  end
  
  --- Get the average heading of the SET_STATIC.
  -- @param #SET_STATIC self
  -- @return #number Heading Heading in degrees and speed in mps in case of moving units.
  function SET_STATIC:GetHeading()
  
    local HeadingSet = nil
    local MovingCount = 0
  
    for StaticName, StaticData in pairs( self:GetSet() ) do
    
      local Static = StaticData -- Wrapper.Static#STATIC
      local Coordinate = Static:GetCoordinate()
  
      local Velocity = Coordinate:GetVelocity()
      if Velocity ~= 0  then
        local Heading = Coordinate:GetHeading()
        if HeadingSet == nil then
          HeadingSet = Heading
        else
          local HeadingDiff = ( HeadingSet - Heading + 180 + 360 ) % 360 - 180
          HeadingDiff = math.abs( HeadingDiff )
          if HeadingDiff > 5 then
            HeadingSet = nil
            break
          end
        end        
      end
    end
  
    return HeadingSet
  
  end
  
  
  ---
  -- @param #SET_STATIC self
  -- @param Wrapper.Static#STATIC MStatic
  -- @return #SET_STATIC self
  function SET_STATIC:IsIncludeObject( MStatic )
    self:F2( MStatic )
    local MStaticInclude = true
  
    if self.Filter.Coalitions then
      local MStaticCoalition = false
      for CoalitionID, CoalitionName in pairs( self.Filter.Coalitions ) do
        self:T3( { "Coalition:", MStatic:GetCoalition(), self.FilterMeta.Coalitions[CoalitionName], CoalitionName } )
        if self.FilterMeta.Coalitions[CoalitionName] and self.FilterMeta.Coalitions[CoalitionName] == MStatic:GetCoalition() then
          MStaticCoalition = true
        end
      end
      MStaticInclude = MStaticInclude and MStaticCoalition
    end
    
    if self.Filter.Categories then
      local MStaticCategory = false
      for CategoryID, CategoryName in pairs( self.Filter.Categories ) do
        self:T3( { "Category:", MStatic:GetDesc().category, self.FilterMeta.Categories[CategoryName], CategoryName } )
        if self.FilterMeta.Categories[CategoryName] and self.FilterMeta.Categories[CategoryName] == MStatic:GetDesc().category then
          MStaticCategory = true
        end
      end
      MStaticInclude = MStaticInclude and MStaticCategory
    end
    
    if self.Filter.Types then
      local MStaticType = false
      for TypeID, TypeName in pairs( self.Filter.Types ) do
        self:T3( { "Type:", MStatic:GetTypeName(), TypeName } )
        if TypeName == MStatic:GetTypeName() then
          MStaticType = true
        end
      end
      MStaticInclude = MStaticInclude and MStaticType
    end
    
    if self.Filter.Countries then
      local MStaticCountry = false
      for CountryID, CountryName in pairs( self.Filter.Countries ) do
        self:T3( { "Country:", MStatic:GetCountry(), CountryName } )
        if country.id[CountryName] == MStatic:GetCountry() then
          MStaticCountry = true
        end
      end
      MStaticInclude = MStaticInclude and MStaticCountry
    end
  
    if self.Filter.StaticPrefixes then
      local MStaticPrefix = false
      for StaticPrefixId, StaticPrefix in pairs( self.Filter.StaticPrefixes ) do
        self:T3( { "Prefix:", string.find( MStatic:GetName(), StaticPrefix, 1 ), StaticPrefix } )
        if string.find( MStatic:GetName(), StaticPrefix, 1 ) then
          MStaticPrefix = true
        end
      end
      MStaticInclude = MStaticInclude and MStaticPrefix
    end
  
    self:T2( MStaticInclude )
    return MStaticInclude
  end
  
  
  --- Retrieve the type names of the @{Static}s in the SET, delimited by an optional delimiter.
  -- @param #SET_STATIC self
  -- @param #string Delimiter (optional) The delimiter, which is default a comma.
  -- @return #string The types of the @{Static}s delimited.
  function SET_STATIC:GetTypeNames( Delimiter )
  
    Delimiter = Delimiter or ", "
    local TypeReport = REPORT:New()
    local Types = {}
    
    for StaticName, StaticData in pairs( self:GetSet() ) do
    
      local Static = StaticData -- Wrapper.Static#STATIC
      local StaticTypeName = Static:GetTypeName()
      
      if not Types[StaticTypeName] then
        Types[StaticTypeName] = StaticTypeName
        TypeReport:Add( StaticTypeName )
      end
    end
    
    return TypeReport:Text( Delimiter )
  end
  
end


--- SET_CLIENT


--- @type SET_CLIENT
-- @extends Core.Set#SET_BASE



--- # 4) SET_CLIENT class, extends @{Set#SET_BASE}
-- 
-- Mission designers can use the @{Set#SET_CLIENT} class to build sets of units belonging to certain:
-- 
--  * Coalitions
--  * Categories
--  * Countries
--  * Client types
--  * Starting with certain prefix strings.
--  
-- ## 4.1) SET_CLIENT constructor
-- 
-- Create a new SET_CLIENT object with the @{#SET_CLIENT.New} method:
-- 
--    * @{#SET_CLIENT.New}: Creates a new SET_CLIENT object.
--   
-- ## 4.2) Add or Remove CLIENT(s) from SET_CLIENT 
-- 
-- CLIENTs can be added and removed using the @{Set#SET_CLIENT.AddClientsByName} and @{Set#SET_CLIENT.RemoveClientsByName} respectively. 
-- These methods take a single CLIENT name or an array of CLIENT names to be added or removed from SET_CLIENT.
-- 
-- ## 4.3) SET_CLIENT filter criteria
-- 
-- You can set filter criteria to define the set of clients within the SET_CLIENT.
-- Filter criteria are defined by:
-- 
--    * @{#SET_CLIENT.FilterCoalitions}: Builds the SET_CLIENT with the clients belonging to the coalition(s).
--    * @{#SET_CLIENT.FilterCategories}: Builds the SET_CLIENT with the clients belonging to the category(ies).
--    * @{#SET_CLIENT.FilterTypes}: Builds the SET_CLIENT with the clients belonging to the client type(s).
--    * @{#SET_CLIENT.FilterCountries}: Builds the SET_CLIENT with the clients belonging to the country(ies).
--    * @{#SET_CLIENT.FilterPrefixes}: Builds the SET_CLIENT with the clients starting with the same prefix string(s).
--   
-- Once the filter criteria have been set for the SET_CLIENT, you can start filtering using:
-- 
--   * @{#SET_CLIENT.FilterStart}: Starts the filtering of the clients within the SET_CLIENT.
-- 
-- Planned filter criteria within development are (so these are not yet available):
-- 
--    * @{#SET_CLIENT.FilterZones}: Builds the SET_CLIENT with the clients within a @{Zone#ZONE}.
-- 
-- ## 4.4) SET_CLIENT iterators
-- 
-- Once the filters have been defined and the SET_CLIENT has been built, you can iterate the SET_CLIENT with the available iterator methods.
-- The iterator methods will walk the SET_CLIENT set, and call for each element within the set a function that you provide.
-- The following iterator methods are currently available within the SET_CLIENT:
-- 
--   * @{#SET_CLIENT.ForEachClient}: Calls a function for each alive client it finds within the SET_CLIENT.
-- 
-- ===
-- @field #SET_CLIENT SET_CLIENT 
SET_CLIENT = {
  ClassName = "SET_CLIENT",
  Clients = {},
  Filter = {
    Coalitions = nil,
    Categories = nil,
    Types = nil,
    Countries = nil,
    ClientPrefixes = nil,
  },
  FilterMeta = {
    Coalitions = {
      red = coalition.side.RED,
      blue = coalition.side.BLUE,
      neutral = coalition.side.NEUTRAL,
    },
    Categories = {
      plane = Unit.Category.AIRPLANE,
      helicopter = Unit.Category.HELICOPTER,
      ground = Unit.Category.GROUND_UNIT,
      ship = Unit.Category.SHIP,
      structure = Unit.Category.STRUCTURE,
    },
  },
}


--- Creates a new SET_CLIENT object, building a set of clients belonging to a coalitions, categories, countries, types or with defined prefix names.
-- @param #SET_CLIENT self
-- @return #SET_CLIENT
-- @usage
-- -- Define a new SET_CLIENT Object. This DBObject will contain a reference to all Clients.
-- DBObject = SET_CLIENT:New()
function SET_CLIENT:New()
  -- Inherits from BASE
  local self = BASE:Inherit( self, SET_BASE:New( _DATABASE.CLIENTS ) )

  return self
end

--- Add CLIENT(s) to SET_CLIENT.
-- @param Core.Set#SET_CLIENT self
-- @param #string AddClientNames A single name or an array of CLIENT names.
-- @return self
function SET_CLIENT:AddClientsByName( AddClientNames )

  local AddClientNamesArray = ( type( AddClientNames ) == "table" ) and AddClientNames or { AddClientNames }
  
  for AddClientID, AddClientName in pairs( AddClientNamesArray ) do
    self:Add( AddClientName, CLIENT:FindByName( AddClientName ) )
  end
    
  return self
end

--- Remove CLIENT(s) from SET_CLIENT.
-- @param Core.Set#SET_CLIENT self
-- @param Wrapper.Client#CLIENT RemoveClientNames A single name or an array of CLIENT names.
-- @return self
function SET_CLIENT:RemoveClientsByName( RemoveClientNames )

  local RemoveClientNamesArray = ( type( RemoveClientNames ) == "table" ) and RemoveClientNames or { RemoveClientNames }
  
  for RemoveClientID, RemoveClientName in pairs( RemoveClientNamesArray ) do
    self:Remove( RemoveClientName.ClientName )
  end
    
  return self
end


--- Finds a Client based on the Client Name.
-- @param #SET_CLIENT self
-- @param #string ClientName
-- @return Wrapper.Client#CLIENT The found Client.
function SET_CLIENT:FindClient( ClientName )

  local ClientFound = self.Set[ClientName]
  return ClientFound
end



--- Builds a set of clients of coalitions.
-- Possible current coalitions are red, blue and neutral.
-- @param #SET_CLIENT self
-- @param #string Coalitions Can take the following values: "red", "blue", "neutral".
-- @return #SET_CLIENT self
function SET_CLIENT:FilterCoalitions( Coalitions )
  if not self.Filter.Coalitions then
    self.Filter.Coalitions = {}
  end
  if type( Coalitions ) ~= "table" then
    Coalitions = { Coalitions }
  end
  for CoalitionID, Coalition in pairs( Coalitions ) do
    self.Filter.Coalitions[Coalition] = Coalition
  end
  return self
end


--- Builds a set of clients out of categories.
-- Possible current categories are plane, helicopter, ground, ship.
-- @param #SET_CLIENT self
-- @param #string Categories Can take the following values: "plane", "helicopter", "ground", "ship".
-- @return #SET_CLIENT self
function SET_CLIENT:FilterCategories( Categories )
  if not self.Filter.Categories then
    self.Filter.Categories = {}
  end
  if type( Categories ) ~= "table" then
    Categories = { Categories }
  end
  for CategoryID, Category in pairs( Categories ) do
    self.Filter.Categories[Category] = Category
  end
  return self
end


--- Builds a set of clients of defined client types.
-- Possible current types are those types known within DCS world.
-- @param #SET_CLIENT self
-- @param #string Types Can take those type strings known within DCS world.
-- @return #SET_CLIENT self
function SET_CLIENT:FilterTypes( Types )
  if not self.Filter.Types then
    self.Filter.Types = {}
  end
  if type( Types ) ~= "table" then
    Types = { Types }
  end
  for TypeID, Type in pairs( Types ) do
    self.Filter.Types[Type] = Type
  end
  return self
end


--- Builds a set of clients of defined countries.
-- Possible current countries are those known within DCS world.
-- @param #SET_CLIENT self
-- @param #string Countries Can take those country strings known within DCS world.
-- @return #SET_CLIENT self
function SET_CLIENT:FilterCountries( Countries )
  if not self.Filter.Countries then
    self.Filter.Countries = {}
  end
  if type( Countries ) ~= "table" then
    Countries = { Countries }
  end
  for CountryID, Country in pairs( Countries ) do
    self.Filter.Countries[Country] = Country
  end
  return self
end


--- Builds a set of clients of defined client prefixes.
-- All the clients starting with the given prefixes will be included within the set.
-- @param #SET_CLIENT self
-- @param #string Prefixes The prefix of which the client name starts with.
-- @return #SET_CLIENT self
function SET_CLIENT:FilterPrefixes( Prefixes )
  if not self.Filter.ClientPrefixes then
    self.Filter.ClientPrefixes = {}
  end
  if type( Prefixes ) ~= "table" then
    Prefixes = { Prefixes }
  end
  for PrefixID, Prefix in pairs( Prefixes ) do
    self.Filter.ClientPrefixes[Prefix] = Prefix
  end
  return self
end




--- Starts the filtering.
-- @param #SET_CLIENT self
-- @return #SET_CLIENT self
function SET_CLIENT:FilterStart()

  if _DATABASE then
    self:_FilterStart()
  end
  
  return self
end

--- Handles the Database to check on an event (birth) that the Object was added in the Database.
-- This is required, because sometimes the _DATABASE birth event gets called later than the SET_BASE birth event!
-- @param #SET_CLIENT self
-- @param Core.Event#EVENTDATA Event
-- @return #string The name of the CLIENT
-- @return #table The CLIENT
function SET_CLIENT:AddInDatabase( Event )
  self:F3( { Event } )

  return Event.IniDCSUnitName, self.Database[Event.IniDCSUnitName]
end

--- Handles the Database to check on any event that Object exists in the Database.
-- This is required, because sometimes the _DATABASE event gets called later than the SET_BASE event or vise versa!
-- @param #SET_CLIENT self
-- @param Core.Event#EVENTDATA Event
-- @return #string The name of the CLIENT
-- @return #table The CLIENT
function SET_CLIENT:FindInDatabase( Event )
  self:F3( { Event } )

  return Event.IniDCSUnitName, self.Database[Event.IniDCSUnitName]
end

--- Iterate the SET_CLIENT and call an interator function for each **alive** CLIENT, providing the CLIENT and optional parameters.
-- @param #SET_CLIENT self
-- @param #function IteratorFunction The function that will be called when there is an alive CLIENT in the SET_CLIENT. The function needs to accept a CLIENT parameter.
-- @return #SET_CLIENT self
function SET_CLIENT:ForEachClient( IteratorFunction, ... )
  self:F2( arg )
  
  self:ForEach( IteratorFunction, arg, self.Set )

  return self
end

--- Iterate the SET_CLIENT and call an iterator function for each **alive** CLIENT presence completely in a @{Zone}, providing the CLIENT and optional parameters to the called function.
-- @param #SET_CLIENT self
-- @param Core.Zone#ZONE ZoneObject The Zone to be tested for.
-- @param #function IteratorFunction The function that will be called when there is an alive CLIENT in the SET_CLIENT. The function needs to accept a CLIENT parameter.
-- @return #SET_CLIENT self
function SET_CLIENT:ForEachClientInZone( ZoneObject, IteratorFunction, ... )
  self:F2( arg )
  
  self:ForEach( IteratorFunction, arg, self.Set,
    --- @param Core.Zone#ZONE_BASE ZoneObject
    -- @param Wrapper.Client#CLIENT ClientObject
    function( ZoneObject, ClientObject )
      if ClientObject:IsInZone( ZoneObject ) then
        return true
      else
        return false
      end
    end, { ZoneObject } )

  return self
end

--- Iterate the SET_CLIENT and call an iterator function for each **alive** CLIENT presence not in a @{Zone}, providing the CLIENT and optional parameters to the called function.
-- @param #SET_CLIENT self
-- @param Core.Zone#ZONE ZoneObject The Zone to be tested for.
-- @param #function IteratorFunction The function that will be called when there is an alive CLIENT in the SET_CLIENT. The function needs to accept a CLIENT parameter.
-- @return #SET_CLIENT self
function SET_CLIENT:ForEachClientNotInZone( ZoneObject, IteratorFunction, ... )
  self:F2( arg )
  
  self:ForEach( IteratorFunction, arg, self.Set,
    --- @param Core.Zone#ZONE_BASE ZoneObject
    -- @param Wrapper.Client#CLIENT ClientObject
    function( ZoneObject, ClientObject )
      if ClientObject:IsNotInZone( ZoneObject ) then
        return true
      else
        return false
      end
    end, { ZoneObject } )

  return self
end

---
-- @param #SET_CLIENT self
-- @param Wrapper.Client#CLIENT MClient
-- @return #SET_CLIENT self
function SET_CLIENT:IsIncludeObject( MClient )
  self:F2( MClient )

  local MClientInclude = true

  if MClient then
    local MClientName = MClient.UnitName
  
    if self.Filter.Coalitions then
      local MClientCoalition = false
      for CoalitionID, CoalitionName in pairs( self.Filter.Coalitions ) do
        local ClientCoalitionID = _DATABASE:GetCoalitionFromClientTemplate( MClientName )
        self:T3( { "Coalition:", ClientCoalitionID, self.FilterMeta.Coalitions[CoalitionName], CoalitionName } )
        if self.FilterMeta.Coalitions[CoalitionName] and self.FilterMeta.Coalitions[CoalitionName] == ClientCoalitionID then
          MClientCoalition = true
        end
      end
      self:T( { "Evaluated Coalition", MClientCoalition } )
      MClientInclude = MClientInclude and MClientCoalition
    end
    
    if self.Filter.Categories then
      local MClientCategory = false
      for CategoryID, CategoryName in pairs( self.Filter.Categories ) do
        local ClientCategoryID = _DATABASE:GetCategoryFromClientTemplate( MClientName )
        self:T3( { "Category:", ClientCategoryID, self.FilterMeta.Categories[CategoryName], CategoryName } )
        if self.FilterMeta.Categories[CategoryName] and self.FilterMeta.Categories[CategoryName] == ClientCategoryID then
          MClientCategory = true
        end
      end
      self:T( { "Evaluated Category", MClientCategory } )
      MClientInclude = MClientInclude and MClientCategory
    end
    
    if self.Filter.Types then
      local MClientType = false
      for TypeID, TypeName in pairs( self.Filter.Types ) do
        self:T3( { "Type:", MClient:GetTypeName(), TypeName } )
        if TypeName == MClient:GetTypeName() then
          MClientType = true
        end
      end
      self:T( { "Evaluated Type", MClientType } )
      MClientInclude = MClientInclude and MClientType
    end
    
    if self.Filter.Countries then
      local MClientCountry = false
      for CountryID, CountryName in pairs( self.Filter.Countries ) do
        local ClientCountryID = _DATABASE:GetCountryFromClientTemplate(MClientName)
        self:T3( { "Country:", ClientCountryID, country.id[CountryName], CountryName } )
        if country.id[CountryName] and country.id[CountryName] == ClientCountryID then
          MClientCountry = true
        end
      end
      self:T( { "Evaluated Country", MClientCountry } )
      MClientInclude = MClientInclude and MClientCountry
    end
  
    if self.Filter.ClientPrefixes then
      local MClientPrefix = false
      for ClientPrefixId, ClientPrefix in pairs( self.Filter.ClientPrefixes ) do
        self:T3( { "Prefix:", string.find( MClient.UnitName, ClientPrefix, 1 ), ClientPrefix } )
        if string.find( MClient.UnitName, ClientPrefix, 1 ) then
          MClientPrefix = true
        end
      end
      self:T( { "Evaluated Prefix", MClientPrefix } )
      MClientInclude = MClientInclude and MClientPrefix
    end
  end
  
  self:T2( MClientInclude )
  return MClientInclude
end

--- @type SET_AIRBASE
-- @extends Core.Set#SET_BASE

--- # 5) SET_AIRBASE class, extends @{Set#SET_BASE}
-- 
-- Mission designers can use the @{Set#SET_AIRBASE} class to build sets of airbases optionally belonging to certain:
-- 
--  * Coalitions
--  
-- ## 5.1) SET_AIRBASE constructor
-- 
-- Create a new SET_AIRBASE object with the @{#SET_AIRBASE.New} method:
-- 
--    * @{#SET_AIRBASE.New}: Creates a new SET_AIRBASE object.
--   
-- ## 5.2) Add or Remove AIRBASEs from SET_AIRBASE 
-- 
-- AIRBASEs can be added and removed using the @{Set#SET_AIRBASE.AddAirbasesByName} and @{Set#SET_AIRBASE.RemoveAirbasesByName} respectively. 
-- These methods take a single AIRBASE name or an array of AIRBASE names to be added or removed from SET_AIRBASE.
-- 
-- ## 5.3) SET_AIRBASE filter criteria 
-- 
-- You can set filter criteria to define the set of clients within the SET_AIRBASE.
-- Filter criteria are defined by:
-- 
--    * @{#SET_AIRBASE.FilterCoalitions}: Builds the SET_AIRBASE with the airbases belonging to the coalition(s).
--   
-- Once the filter criteria have been set for the SET_AIRBASE, you can start filtering using:
-- 
--   * @{#SET_AIRBASE.FilterStart}: Starts the filtering of the airbases within the SET_AIRBASE.
-- 
-- ## 5.4) SET_AIRBASE iterators
-- 
-- Once the filters have been defined and the SET_AIRBASE has been built, you can iterate the SET_AIRBASE with the available iterator methods.
-- The iterator methods will walk the SET_AIRBASE set, and call for each airbase within the set a function that you provide.
-- The following iterator methods are currently available within the SET_AIRBASE:
-- 
--   * @{#SET_AIRBASE.ForEachAirbase}: Calls a function for each airbase it finds within the SET_AIRBASE.
-- 
-- ===
-- @field #SET_AIRBASE SET_AIRBASE
SET_AIRBASE = {
  ClassName = "SET_AIRBASE",
  Airbases = {},
  Filter = {
    Coalitions = nil,
  },
  FilterMeta = {
    Coalitions = {
      red = coalition.side.RED,
      blue = coalition.side.BLUE,
      neutral = coalition.side.NEUTRAL,
    },
    Categories = {
      airdrome = Airbase.Category.AIRDROME,
      helipad = Airbase.Category.HELIPAD,
      ship = Airbase.Category.SHIP,
    },
  },
}


--- Creates a new SET_AIRBASE object, building a set of airbases belonging to a coalitions and categories.
-- @param #SET_AIRBASE self
-- @return #SET_AIRBASE self
-- @usage
-- -- Define a new SET_AIRBASE Object. The DatabaseSet will contain a reference to all Airbases.
-- DatabaseSet = SET_AIRBASE:New()
function SET_AIRBASE:New()
  -- Inherits from BASE
  local self = BASE:Inherit( self, SET_BASE:New( _DATABASE.AIRBASES ) )

  return self
end

--- Add AIRBASEs to SET_AIRBASE.
-- @param Core.Set#SET_AIRBASE self
-- @param #string AddAirbaseNames A single name or an array of AIRBASE names.
-- @return self
function SET_AIRBASE:AddAirbasesByName( AddAirbaseNames )

  local AddAirbaseNamesArray = ( type( AddAirbaseNames ) == "table" ) and AddAirbaseNames or { AddAirbaseNames }
  
  for AddAirbaseID, AddAirbaseName in pairs( AddAirbaseNamesArray ) do
    self:Add( AddAirbaseName, AIRBASE:FindByName( AddAirbaseName ) )
  end
    
  return self
end

--- Remove AIRBASEs from SET_AIRBASE.
-- @param Core.Set#SET_AIRBASE self
-- @param Wrapper.Airbase#AIRBASE RemoveAirbaseNames A single name or an array of AIRBASE names.
-- @return self
function SET_AIRBASE:RemoveAirbasesByName( RemoveAirbaseNames )

  local RemoveAirbaseNamesArray = ( type( RemoveAirbaseNames ) == "table" ) and RemoveAirbaseNames or { RemoveAirbaseNames }
  
  for RemoveAirbaseID, RemoveAirbaseName in pairs( RemoveAirbaseNamesArray ) do
    self:Remove( RemoveAirbaseName.AirbaseName )
  end
    
  return self
end


--- Finds a Airbase based on the Airbase Name.
-- @param #SET_AIRBASE self
-- @param #string AirbaseName
-- @return Wrapper.Airbase#AIRBASE The found Airbase.
function SET_AIRBASE:FindAirbase( AirbaseName )

  local AirbaseFound = self.Set[AirbaseName]
  return AirbaseFound
end



--- Builds a set of airbases of coalitions.
-- Possible current coalitions are red, blue and neutral.
-- @param #SET_AIRBASE self
-- @param #string Coalitions Can take the following values: "red", "blue", "neutral".
-- @return #SET_AIRBASE self
function SET_AIRBASE:FilterCoalitions( Coalitions )
  if not self.Filter.Coalitions then
    self.Filter.Coalitions = {}
  end
  if type( Coalitions ) ~= "table" then
    Coalitions = { Coalitions }
  end
  for CoalitionID, Coalition in pairs( Coalitions ) do
    self.Filter.Coalitions[Coalition] = Coalition
  end
  return self
end


--- Builds a set of airbases out of categories.
-- Possible current categories are plane, helicopter, ground, ship.
-- @param #SET_AIRBASE self
-- @param #string Categories Can take the following values: "airdrome", "helipad", "ship".
-- @return #SET_AIRBASE self
function SET_AIRBASE:FilterCategories( Categories )
  if not self.Filter.Categories then
    self.Filter.Categories = {}
  end
  if type( Categories ) ~= "table" then
    Categories = { Categories }
  end
  for CategoryID, Category in pairs( Categories ) do
    self.Filter.Categories[Category] = Category
  end
  return self
end

--- Starts the filtering.
-- @param #SET_AIRBASE self
-- @return #SET_AIRBASE self
function SET_AIRBASE:FilterStart()

  if _DATABASE then
    self:_FilterStart()
  end
  
  return self
end


--- Handles the Database to check on an event (birth) that the Object was added in the Database.
-- This is required, because sometimes the _DATABASE birth event gets called later than the SET_BASE birth event!
-- @param #SET_AIRBASE self
-- @param Core.Event#EVENTDATA Event
-- @return #string The name of the AIRBASE
-- @return #table The AIRBASE
function SET_AIRBASE:AddInDatabase( Event )
  self:F3( { Event } )

  return Event.IniDCSUnitName, self.Database[Event.IniDCSUnitName]
end

--- Handles the Database to check on any event that Object exists in the Database.
-- This is required, because sometimes the _DATABASE event gets called later than the SET_BASE event or vise versa!
-- @param #SET_AIRBASE self
-- @param Core.Event#EVENTDATA Event
-- @return #string The name of the AIRBASE
-- @return #table The AIRBASE
function SET_AIRBASE:FindInDatabase( Event )
  self:F3( { Event } )

  return Event.IniDCSUnitName, self.Database[Event.IniDCSUnitName]
end

--- Iterate the SET_AIRBASE and call an interator function for each AIRBASE, providing the AIRBASE and optional parameters.
-- @param #SET_AIRBASE self
-- @param #function IteratorFunction The function that will be called when there is an alive AIRBASE in the SET_AIRBASE. The function needs to accept a AIRBASE parameter.
-- @return #SET_AIRBASE self
function SET_AIRBASE:ForEachAirbase( IteratorFunction, ... )
  self:F2( arg )
  
  self:ForEach( IteratorFunction, arg, self.Set )

  return self
end

--- Iterate the SET_AIRBASE while identifying the nearest @{Airbase#AIRBASE} from a @{Point#POINT_VEC2}.
-- @param #SET_AIRBASE self
-- @param Core.Point#POINT_VEC2 PointVec2 A @{Point#POINT_VEC2} object from where to evaluate the closest @{Airbase#AIRBASE}.
-- @return Wrapper.Airbase#AIRBASE The closest @{Airbase#AIRBASE}.
function SET_AIRBASE:FindNearestAirbaseFromPointVec2( PointVec2 )
  self:F2( PointVec2 )
  
  local NearestAirbase = self:FindNearestObjectFromPointVec2( PointVec2 )
  return NearestAirbase
end



---
-- @param #SET_AIRBASE self
-- @param Wrapper.Airbase#AIRBASE MAirbase
-- @return #SET_AIRBASE self
function SET_AIRBASE:IsIncludeObject( MAirbase )
  self:F2( MAirbase )

  local MAirbaseInclude = true

  if MAirbase then
    local MAirbaseName = MAirbase:GetName()
  
    if self.Filter.Coalitions then
      local MAirbaseCoalition = false
      for CoalitionID, CoalitionName in pairs( self.Filter.Coalitions ) do
        local AirbaseCoalitionID = _DATABASE:GetCoalitionFromAirbase( MAirbaseName )
        self:T3( { "Coalition:", AirbaseCoalitionID, self.FilterMeta.Coalitions[CoalitionName], CoalitionName } )
        if self.FilterMeta.Coalitions[CoalitionName] and self.FilterMeta.Coalitions[CoalitionName] == AirbaseCoalitionID then
          MAirbaseCoalition = true
        end
      end
      self:T( { "Evaluated Coalition", MAirbaseCoalition } )
      MAirbaseInclude = MAirbaseInclude and MAirbaseCoalition
    end
    
    if self.Filter.Categories then
      local MAirbaseCategory = false
      for CategoryID, CategoryName in pairs( self.Filter.Categories ) do
        local AirbaseCategoryID = _DATABASE:GetCategoryFromAirbase( MAirbaseName )
        self:T3( { "Category:", AirbaseCategoryID, self.FilterMeta.Categories[CategoryName], CategoryName } )
        if self.FilterMeta.Categories[CategoryName] and self.FilterMeta.Categories[CategoryName] == AirbaseCategoryID then
          MAirbaseCategory = true
        end
      end
      self:T( { "Evaluated Category", MAirbaseCategory } )
      MAirbaseInclude = MAirbaseInclude and MAirbaseCategory
    end
  end
   
  self:T2( MAirbaseInclude )
  return MAirbaseInclude
end

--- @type SET_CARGO
-- @extends Core.Set#SET_BASE

--- # (R2.1) SET_CARGO class, extends @{Set#SET_BASE}
-- 
-- Mission designers can use the @{Set#SET_CARGO} class to build sets of cargos optionally belonging to certain:
-- 
--  * Coalitions
--  * Types
--  * Name or Prefix
--  
-- ## SET_CARGO constructor
-- 
-- Create a new SET_CARGO object with the @{#SET_CARGO.New} method:
-- 
--    * @{#SET_CARGO.New}: Creates a new SET_CARGO object.
--   
-- ## Add or Remove CARGOs from SET_CARGO 
-- 
-- CARGOs can be added and removed using the @{Set#SET_CARGO.AddCargosByName} and @{Set#SET_CARGO.RemoveCargosByName} respectively. 
-- These methods take a single CARGO name or an array of CARGO names to be added or removed from SET_CARGO.
-- 
-- ## SET_CARGO filter criteria 
-- 
-- You can set filter criteria to automatically maintain the SET_CARGO contents.
-- Filter criteria are defined by:
-- 
--    * @{#SET_CARGO.FilterCoalitions}: Builds the SET_CARGO with the cargos belonging to the coalition(s).
--    * @{#SET_CARGO.FilterPrefixes}: Builds the SET_CARGO with the cargos containing the prefix string(s).
--    * @{#SET_CARGO.FilterTypes}: Builds the SET_CARGO with the cargos belonging to the cargo type(s).
--    * @{#SET_CARGO.FilterCountries}: Builds the SET_CARGO with the cargos belonging to the country(ies).
--   
-- Once the filter criteria have been set for the SET_CARGO, you can start filtering using:
-- 
--   * @{#SET_CARGO.FilterStart}: Starts the filtering of the cargos within the SET_CARGO.
-- 
-- ## SET_CARGO iterators
-- 
-- Once the filters have been defined and the SET_CARGO has been built, you can iterate the SET_CARGO with the available iterator methods.
-- The iterator methods will walk the SET_CARGO set, and call for each cargo within the set a function that you provide.
-- The following iterator methods are currently available within the SET_CARGO:
-- 
--   * @{#SET_CARGO.ForEachCargo}: Calls a function for each cargo it finds within the SET_CARGO.
-- 
-- @field #SET_CARGO SET_CARGO
-- 
SET_CARGO = {
  ClassName = "SET_CARGO",
  Cargos = {},
  Filter = {
    Coalitions = nil,
    Types = nil,
    Countries = nil,
    ClientPrefixes = nil,
  },
  FilterMeta = {
    Coalitions = {
      red = coalition.side.RED,
      blue = coalition.side.BLUE,
      neutral = coalition.side.NEUTRAL,
    },
  },
}


--- (R2.1) Creates a new SET_CARGO object, building a set of cargos belonging to a coalitions and categories.
-- @param #SET_CARGO self
-- @return #SET_CARGO
-- @usage
-- -- Define a new SET_CARGO Object. The DatabaseSet will contain a reference to all Cargos.
-- DatabaseSet = SET_CARGO:New()
function SET_CARGO:New() --R2.1
  -- Inherits from BASE
  local self = BASE:Inherit( self, SET_BASE:New( _DATABASE.CARGOS ) ) -- #SET_CARGO

  return self
end

--- (R2.1) Add CARGOs to SET_CARGO.
-- @param Core.Set#SET_CARGO self
-- @param #string AddCargoNames A single name or an array of CARGO names.
-- @return self
function SET_CARGO:AddCargosByName( AddCargoNames ) --R2.1

  local AddCargoNamesArray = ( type( AddCargoNames ) == "table" ) and AddCargoNames or { AddCargoNames }
  
  for AddCargoID, AddCargoName in pairs( AddCargoNamesArray ) do
    self:Add( AddCargoName, CARGO:FindByName( AddCargoName ) )
  end
    
  return self
end

--- (R2.1) Remove CARGOs from SET_CARGO.
-- @param Core.Set#SET_CARGO self
-- @param Wrapper.Cargo#CARGO RemoveCargoNames A single name or an array of CARGO names.
-- @return self
function SET_CARGO:RemoveCargosByName( RemoveCargoNames ) --R2.1

  local RemoveCargoNamesArray = ( type( RemoveCargoNames ) == "table" ) and RemoveCargoNames or { RemoveCargoNames }
  
  for RemoveCargoID, RemoveCargoName in pairs( RemoveCargoNamesArray ) do
    self:Remove( RemoveCargoName.CargoName )
  end
    
  return self
end


--- (R2.1) Finds a Cargo based on the Cargo Name.
-- @param #SET_CARGO self
-- @param #string CargoName
-- @return Wrapper.Cargo#CARGO The found Cargo.
function SET_CARGO:FindCargo( CargoName ) --R2.1

  local CargoFound = self.Set[CargoName]
  return CargoFound
end



--- (R2.1) Builds a set of cargos of coalitions.
-- Possible current coalitions are red, blue and neutral.
-- @param #SET_CARGO self
-- @param #string Coalitions Can take the following values: "red", "blue", "neutral".
-- @return #SET_CARGO self
function SET_CARGO:FilterCoalitions( Coalitions ) --R2.1
  if not self.Filter.Coalitions then
    self.Filter.Coalitions = {}
  end
  if type( Coalitions ) ~= "table" then
    Coalitions = { Coalitions }
  end
  for CoalitionID, Coalition in pairs( Coalitions ) do
    self.Filter.Coalitions[Coalition] = Coalition
  end
  return self
end

--- (R2.1) Builds a set of cargos of defined cargo types.
-- Possible current types are those types known within DCS world.
-- @param #SET_CARGO self
-- @param #string Types Can take those type strings known within DCS world.
-- @return #SET_CARGO self
function SET_CARGO:FilterTypes( Types ) --R2.1
  if not self.Filter.Types then
    self.Filter.Types = {}
  end
  if type( Types ) ~= "table" then
    Types = { Types }
  end
  for TypeID, Type in pairs( Types ) do
    self.Filter.Types[Type] = Type
  end
  return self
end


--- (R2.1) Builds a set of cargos of defined countries.
-- Possible current countries are those known within DCS world.
-- @param #SET_CARGO self
-- @param #string Countries Can take those country strings known within DCS world.
-- @return #SET_CARGO self
function SET_CARGO:FilterCountries( Countries ) --R2.1
  if not self.Filter.Countries then
    self.Filter.Countries = {}
  end
  if type( Countries ) ~= "table" then
    Countries = { Countries }
  end
  for CountryID, Country in pairs( Countries ) do
    self.Filter.Countries[Country] = Country
  end
  return self
end


--- (R2.1) Builds a set of cargos of defined cargo prefixes.
-- All the cargos starting with the given prefixes will be included within the set.
-- @param #SET_CARGO self
-- @param #string Prefixes The prefix of which the cargo name starts with.
-- @return #SET_CARGO self
function SET_CARGO:FilterPrefixes( Prefixes ) --R2.1
  if not self.Filter.CargoPrefixes then
    self.Filter.CargoPrefixes = {}
  end
  if type( Prefixes ) ~= "table" then
    Prefixes = { Prefixes }
  end
  for PrefixID, Prefix in pairs( Prefixes ) do
    self.Filter.CargoPrefixes[Prefix] = Prefix
  end
  return self
end



--- (R2.1) Starts the filtering.
-- @param #SET_CARGO self
-- @return #SET_CARGO self
function SET_CARGO:FilterStart() --R2.1

  if _DATABASE then
    self:_FilterStart()
  end

  self:HandleEvent( EVENTS.NewCargo )
  self:HandleEvent( EVENTS.DeleteCargo )
  
  return self
end


--- (R2.1) Handles the Database to check on an event (birth) that the Object was added in the Database.
-- This is required, because sometimes the _DATABASE birth event gets called later than the SET_BASE birth event!
-- @param #SET_CARGO self
-- @param Core.Event#EVENTDATA Event
-- @return #string The name of the CARGO
-- @return #table The CARGO
function SET_CARGO:AddInDatabase( Event ) --R2.1
  self:F3( { Event } )

  return Event.IniDCSUnitName, self.Database[Event.IniDCSUnitName]
end

--- (R2.1) Handles the Database to check on any event that Object exists in the Database.
-- This is required, because sometimes the _DATABASE event gets called later than the SET_BASE event or vise versa!
-- @param #SET_CARGO self
-- @param Core.Event#EVENTDATA Event
-- @return #string The name of the CARGO
-- @return #table The CARGO
function SET_CARGO:FindInDatabase( Event ) --R2.1
  self:F3( { Event } )

  return Event.IniDCSUnitName, self.Database[Event.IniDCSUnitName]
end

--- (R2.1) Iterate the SET_CARGO and call an interator function for each CARGO, providing the CARGO and optional parameters.
-- @param #SET_CARGO self
-- @param #function IteratorFunction The function that will be called when there is an alive CARGO in the SET_CARGO. The function needs to accept a CARGO parameter.
-- @return #SET_CARGO self
function SET_CARGO:ForEachCargo( IteratorFunction, ... ) --R2.1
  self:F2( arg )
  
  self:ForEach( IteratorFunction, arg, self.Set )

  return self
end

--- (R2.1) Iterate the SET_CARGO while identifying the nearest @{Cargo#CARGO} from a @{Point#POINT_VEC2}.
-- @param #SET_CARGO self
-- @param Core.Point#POINT_VEC2 PointVec2 A @{Point#POINT_VEC2} object from where to evaluate the closest @{Cargo#CARGO}.
-- @return Wrapper.Cargo#CARGO The closest @{Cargo#CARGO}.
function SET_CARGO:FindNearestCargoFromPointVec2( PointVec2 ) --R2.1
  self:F2( PointVec2 )
  
  local NearestCargo = self:FindNearestObjectFromPointVec2( PointVec2 )
  return NearestCargo
end



--- (R2.1) 
-- @param #SET_CARGO self
-- @param AI.AI_Cargo#AI_CARGO MCargo
-- @return #SET_CARGO self
function SET_CARGO:IsIncludeObject( MCargo ) --R2.1
  self:F2( MCargo )

  local MCargoInclude = true

  if MCargo then
    local MCargoName = MCargo:GetName()
  
    if self.Filter.Coalitions then
      local MCargoCoalition = false
      for CoalitionID, CoalitionName in pairs( self.Filter.Coalitions ) do
        local CargoCoalitionID = MCargo:GetCoalition()
        self:T3( { "Coalition:", CargoCoalitionID, self.FilterMeta.Coalitions[CoalitionName], CoalitionName } )
        if self.FilterMeta.Coalitions[CoalitionName] and self.FilterMeta.Coalitions[CoalitionName] == CargoCoalitionID then
          MCargoCoalition = true
        end
      end
      self:T( { "Evaluated Coalition", MCargoCoalition } )
      MCargoInclude = MCargoInclude and MCargoCoalition
    end

    if self.Filter.Types then
      local MCargoType = false
      for TypeID, TypeName in pairs( self.Filter.Types ) do
        self:T3( { "Type:", MCargo:GetType(), TypeName } )
        if TypeName == MCargo:GetType() then
          MCargoType = true
        end
      end
      self:T( { "Evaluated Type", MCargoType } )
      MCargoInclude = MCargoInclude and MCargoType
    end
    
    if self.Filter.CargoPrefixes then
      local MCargoPrefix = false
      for CargoPrefixId, CargoPrefix in pairs( self.Filter.CargoPrefixes ) do
        self:T3( { "Prefix:", string.find( MCargo.Name, CargoPrefix, 1 ), CargoPrefix } )
        if string.find( MCargo.Name, CargoPrefix, 1 ) then
          MCargoPrefix = true
        end
      end
      self:T( { "Evaluated Prefix", MCargoPrefix } )
      MCargoInclude = MCargoInclude and MCargoPrefix
    end
  end
    
  self:T2( MCargoInclude )
  return MCargoInclude
end

--- (R2.1) Handles the OnEventNewCargo event for the Set.
-- @param #SET_CARGO self
-- @param Core.Event#EVENTDATA EventData
function SET_CARGO:OnEventNewCargo( EventData ) --R2.1

  if EventData.Cargo then
    if EventData.Cargo and self:IsIncludeObject( EventData.Cargo ) then
      self:Add( EventData.Cargo.Name , EventData.Cargo  )
    end
  end
end

--- (R2.1) Handles the OnDead or OnCrash event for alive units set.
-- @param #SET_CARGO self
-- @param Core.Event#EVENTDATA EventData
function SET_CARGO:OnEventDeleteCargo( EventData ) --R2.1
  self:F3( { EventData } )

  if EventData.Cargo then
    local Cargo = _DATABASE:FindCargo( EventData.Cargo.Name )
    if Cargo and Cargo.Name then
      self:Remove( Cargo.Name )
    end
  end
end

--- **Core** -- **POINT\_VEC** classes define an **extensive API** to **manage 3D points** in the simulation space.
--
-- ![Banner Image](..\Presentations\POINT\Dia1.JPG)
--
-- ====
--
-- # Demo Missions
--
-- ### [POINT_VEC Demo Missions source code]()
--
-- ### [POINT_VEC Demo Missions, only for beta testers]()
--
-- ### [ALL Demo Missions pack of the last release](https://github.com/FlightControl-Master/MOOSE_MISSIONS/releases)
--
-- ====
--
-- # YouTube Channel
--
-- ### [POINT_VEC YouTube Channel]()
--
-- ===
--
-- ### Authors:
--
--   * FlightControl : Design & Programming
--
-- ### Contributions:
--
-- @module Point





do -- COORDINATE

  --- @type COORDINATE
  -- @extends Core.Base#BASE
  
  
  --- # COORDINATE class, extends @{Base#BASE}
  --
  -- COORDINATE defines a 3D point in the simulator and with its methods, you can use or manipulate the point in 3D space.
  --
  -- ## COORDINATE constructor
  --
  -- A new COORDINATE object can be created with:
  --
  --  * @{#COORDINATE.New}(): a 3D point.
  --  * @{#COORDINATE.NewFromVec2}(): a 2D point created from a @{DCSTypes#Vec2}.
  --  * @{#COORDINATE.NewFromVec3}(): a 3D point created from a @{DCSTypes#Vec3}.
  --
  -- ## Create waypoints for routes
  --
  -- A COORDINATE can prepare waypoints for Ground and Air groups to be embedded into a Route.
  --
  --   * @{#COORDINATE.WaypointAir}(): Build an air route point.
  --   * @{#COORDINATE.WaypointGround}(): Build a ground route point.
  --
  -- Route points can be used in the Route methods of the @{Group#GROUP} class.
  --
  --
  -- ## Smoke, flare, explode, illuminate
  --
  -- At the point a smoke, flare, explosion and illumination bomb can be triggered. Use the following methods:
  --
  -- ### Smoke
  --
  --   * @{#COORDINATE.Smoke}(): To smoke the point in a certain color.
  --   * @{#COORDINATE.SmokeBlue}(): To smoke the point in blue.
  --   * @{#COORDINATE.SmokeRed}(): To smoke the point in red.
  --   * @{#COORDINATE.SmokeOrange}(): To smoke the point in orange.
  --   * @{#COORDINATE.SmokeWhite}(): To smoke the point in white.
  --   * @{#COORDINATE.SmokeGreen}(): To smoke the point in green.
  --
  -- ### Flare
  --
  --   * @{#COORDINATE.Flare}(): To flare the point in a certain color.
  --   * @{#COORDINATE.FlareRed}(): To flare the point in red.
  --   * @{#COORDINATE.FlareYellow}(): To flare the point in yellow.
  --   * @{#COORDINATE.FlareWhite}(): To flare the point in white.
  --   * @{#COORDINATE.FlareGreen}(): To flare the point in green.
  --
  -- ### Explode
  --
  --   * @{#COORDINATE.Explosion}(): To explode the point with a certain intensity.
  --
  -- ### Illuminate
  --
  --   * @{#COORDINATE.IlluminationBomb}(): To illuminate the point.
  --
  --
  -- ## Markings
  -- 
  -- Place markers (text boxes with clarifications for briefings, target locations or any other reference point) on the map for all players, coalitions or specific groups:
  -- 
  --   * @{#COORDINATE.MarkToAll}(): Place a mark to all players.
  --   * @{#COORDINATE.MarkToCoalition}(): Place a mark to a coalition.
  --   * @{#COORDINATE.MarkToCoalitionRed}(): Place a mark to the red coalition.
  --   * @{#COORDINATE.MarkToCoalitionBlue}(): Place a mark to the blue coalition.
  --   * @{#COORDINATE.MarkToGroup}(): Place a mark to a group (needs to have a client in it or a CA group (CA group is bugged)).
  --   * @{#COORDINATE.RemoveMark}(): Removes a mark from the map.
  --   
  --
  -- ## 3D calculation methods
  --
  -- Various calculation methods exist to use or manipulate 3D space. Find below a short description of each method:
  --
  -- ### Distance
  --
  --   * @{#COORDINATE.Get3DDistance}(): Obtain the distance from the current 3D point to the provided 3D point in 3D space.
  --   * @{#COORDINATE.Get2DDistance}(): Obtain the distance from the current 3D point to the provided 3D point in 2D space.
  --
  -- ### Angle
  --
  --   * @{#COORDINATE.GetAngleDegrees}(): Obtain the angle in degrees from the current 3D point with the provided 3D direction vector.
  --   * @{#COORDINATE.GetAngleRadians}(): Obtain the angle in radians from the current 3D point with the provided 3D direction vector.
  --   * @{#COORDINATE.GetDirectionVec3}(): Obtain the 3D direction vector from the current 3D point to the provided 3D point.
  --
  -- ### Translation
  --
  --   * @{#COORDINATE.Translate}(): Translate the current 3D point towards an other 3D point using the given Distance and Angle.
  --
  -- ### Get the North correction of the current location
  --
  --   * @{#COORDINATE.GetNorthCorrection}(): Obtains the north correction at the current 3D point.
  --
  --
  -- ## Point Randomization
  --
  -- Various methods exist to calculate random locations around a given 3D point.
  --
  --   * @{#COORDINATE.GetRandomVec2InRadius}(): Provides a random 2D vector around the current 3D point, in the given inner to outer band.
  --   * @{#COORDINATE.GetRandomVec3InRadius}(): Provides a random 3D vector around the current 3D point, in the given inner to outer band.
  --
  --
  -- ## Metric system
  --
  --   * @{#COORDINATE.IsMetric}(): Returns if the 3D point is Metric or Nautical Miles.
  --   * @{#COORDINATE.SetMetric}(): Sets the 3D point to Metric or Nautical Miles.
  --
  --
  -- ## Coorinate text generation
  --
  --   * @{#COORDINATE.ToStringBR}(): Generates a Bearing & Range text in the format of DDD for DI where DDD is degrees and DI is distance.
  --   * @{#COORDINATE.ToStringLL}(): Generates a Latutude & Longutude text.
  --
  -- @field #COORDINATE
  COORDINATE = {
    ClassName = "COORDINATE",
  }


  --- COORDINATE constructor.
  -- @param #COORDINATE self
  -- @param Dcs.DCSTypes#Distance x The x coordinate of the Vec3 point, pointing to the North.
  -- @param Dcs.DCSTypes#Distance y The y coordinate of the Vec3 point, pointing to the Right.
  -- @param Dcs.DCSTypes#Distance z The z coordinate of the Vec3 point, pointing to the Right.
  -- @return #COORDINATE
  function COORDINATE:New( x, y, z ) 

    local self = BASE:Inherit( self, BASE:New() ) -- #COORDINATE
    self.x = x
    self.y = y
    self.z = z
    
    return self
  end

  --- Create a new COORDINATE object from  Vec2 coordinates.
  -- @param #COORDINATE self
  -- @param Dcs.DCSTypes#Vec2 Vec2 The Vec2 point.
  -- @param Dcs.DCSTypes#Distance LandHeightAdd (optional) The default height if required to be evaluated will be the land height of the x, y coordinate. You can specify an extra height to be added to the land height.
  -- @return #COORDINATE
  function COORDINATE:NewFromVec2( Vec2, LandHeightAdd ) 

    local LandHeight = land.getHeight( Vec2 )
    
    LandHeightAdd = LandHeightAdd or 0
    LandHeight = LandHeight + LandHeightAdd

    local self = self:New( Vec2.x, LandHeight, Vec2.y ) -- #COORDINATE

    self:F2( self )

    return self

  end

  --- Create a new COORDINATE object from  Vec3 coordinates.
  -- @param #COORDINATE self
  -- @param Dcs.DCSTypes#Vec3 Vec3 The Vec3 point.
  -- @return #COORDINATE
  function COORDINATE:NewFromVec3( Vec3 ) 

    local self = self:New( Vec3.x, Vec3.y, Vec3.z ) -- #COORDINATE

    self:F2( self )

    return self
  end
  

  --- Return the coordinates of the COORDINATE in Vec3 format.
  -- @param #COORDINATE self
  -- @return Dcs.DCSTypes#Vec3 The Vec3 format coordinate.
  function COORDINATE:GetVec3()
    return { x = self.x, y = self.y, z = self.z }
  end


  --- Return the coordinates of the COORDINATE in Vec2 format.
  -- @param #COORDINATE self
  -- @return Dcs.DCSTypes#Vec2 The Vec2 format coordinate.
  function COORDINATE:GetVec2()
    return { x = self.x, y = self.z }
  end

  --TODO: check this to replace
  --- Calculate the distance from a reference @{DCSTypes#Vec2}.
  -- @param #COORDINATE self
  -- @param Dcs.DCSTypes#Vec2 Vec2Reference The reference @{DCSTypes#Vec2}.
  -- @return Dcs.DCSTypes#Distance The distance from the reference @{DCSTypes#Vec2} in meters.
  function COORDINATE:DistanceFromVec2( Vec2Reference )
    self:F2( Vec2Reference )

    local Distance = ( ( Vec2Reference.x - self.x ) ^ 2 + ( Vec2Reference.y - self.z ) ^2 ) ^0.5

    self:T2( Distance )
    return Distance
  end


  --- Add a Distance in meters from the COORDINATE orthonormal plane, with the given angle, and calculate the new COORDINATE.
  -- @param #COORDINATE self
  -- @param Dcs.DCSTypes#Distance Distance The Distance to be added in meters.
  -- @param Dcs.DCSTypes#Angle Angle The Angle in degrees.
  -- @return #COORDINATE The new calculated COORDINATE.
  function COORDINATE:Translate( Distance, Angle )
    local SX = self.x
    local SY = self.z
    local Radians = Angle / 180 * math.pi
    local TX = Distance * math.cos( Radians ) + SX
    local TY = Distance * math.sin( Radians ) + SY

    return COORDINATE:NewFromVec2( { x = TX, y = TY } )
  end

  --- Return a random Vec2 within an Outer Radius and optionally NOT within an Inner Radius of the COORDINATE.
  -- @param #COORDINATE self
  -- @param Dcs.DCSTypes#Distance OuterRadius
  -- @param Dcs.DCSTypes#Distance InnerRadius
  -- @return Dcs.DCSTypes#Vec2 Vec2
  function COORDINATE:GetRandomVec2InRadius( OuterRadius, InnerRadius )
    self:F2( { OuterRadius, InnerRadius } )

    local Theta = 2 * math.pi * math.random()
    local Radials = math.random() + math.random()
    if Radials > 1 then
      Radials = 2 - Radials
    end

    local RadialMultiplier
    if InnerRadius and InnerRadius <= OuterRadius then
      RadialMultiplier = ( OuterRadius - InnerRadius ) * Radials + InnerRadius
    else
      RadialMultiplier = OuterRadius * Radials
    end

    local RandomVec2
    if OuterRadius > 0 then
      RandomVec2 = { x = math.cos( Theta ) * RadialMultiplier + self.x, y = math.sin( Theta ) * RadialMultiplier + self.z }
    else
      RandomVec2 = { x = self.x, y = self.z }
    end

    return RandomVec2
  end


  --- Return a random Vec3 within an Outer Radius and optionally NOT within an Inner Radius of the COORDINATE.
  -- @param #COORDINATE self
  -- @param Dcs.DCSTypes#Distance OuterRadius
  -- @param Dcs.DCSTypes#Distance InnerRadius
  -- @return Dcs.DCSTypes#Vec3 Vec3
  function COORDINATE:GetRandomVec3InRadius( OuterRadius, InnerRadius )

    local RandomVec2 = self:GetRandomVec2InRadius( OuterRadius, InnerRadius )
    local y = self.y + math.random( InnerRadius, OuterRadius )
    local RandomVec3 = { x = RandomVec2.x, y = y, z = RandomVec2.y }

    return RandomVec3
  end
  
  --- Return the height of the land at the coordinate.
  -- @param #COORDINATE self
  -- @return #number
  function COORDINATE:GetLandHeight()
    local Vec2 = { x = self.x, y = self.z }
    return land.getHeight( Vec2 )
  end


  --- Set the heading of the coordinate, if applicable.
  -- @param #COORDINATE self
  function COORDINATE:SetHeading( Heading )
    self.Heading = Heading
  end
  
  
  --- Get the heading of the coordinate, if applicable.
  -- @param #COORDINATE self
  -- @return #number or nil
  function COORDINATE:GetHeading()
    return self.Heading
  end

  
  --- Set the velocity of the COORDINATE.
  -- @param #COORDINATE self
  -- @param #string Velocity Velocity in meters per second.
  function COORDINATE:SetVelocity( Velocity )
    self.Velocity = Velocity
  end

  
  --- Return the velocity of the COORDINATE.
  -- @param #COORDINATE self
  -- @return #number Velocity in meters per second.
  function COORDINATE:GetVelocity()
    local Velocity = self.Velocity
    return Velocity or 0
  end

  
  --- Return velocity text of the COORDINATE.
  -- @param #COORDINATE self
  -- @return #string
  function COORDINATE:GetMovingText( Settings )

    return self:GetVelocityText( Settings ) .. ", " .. self:GetHeadingText( Settings )
  end


  --- Return a direction vector Vec3 from COORDINATE to the COORDINATE.
  -- @param #COORDINATE self
  -- @param #COORDINATE TargetCoordinate The target COORDINATE.
  -- @return Dcs.DCSTypes#Vec3 DirectionVec3 The direction vector in Vec3 format.
  function COORDINATE:GetDirectionVec3( TargetCoordinate )
    return { x = TargetCoordinate.x - self.x, y = TargetCoordinate.y - self.y, z = TargetCoordinate.z - self.z }
  end


  --- Get a correction in radians of the real magnetic north of the COORDINATE.
  -- @param #COORDINATE self
  -- @return #number CorrectionRadians The correction in radians.
  function COORDINATE:GetNorthCorrectionRadians()
    local TargetVec3 = self:GetVec3()
    local lat, lon = coord.LOtoLL(TargetVec3)
    local north_posit = coord.LLtoLO(lat + 1, lon)
    return math.atan2( north_posit.z - TargetVec3.z, north_posit.x - TargetVec3.x )
  end


  --- Return an angle in radians from the COORDINATE using a direction vector in Vec3 format.
  -- @param #COORDINATE self
  -- @param Dcs.DCSTypes#Vec3 DirectionVec3 The direction vector in Vec3 format.
  -- @return #number DirectionRadians The angle in radians.
  function COORDINATE:GetAngleRadians( DirectionVec3 )
    local DirectionRadians = math.atan2( DirectionVec3.z, DirectionVec3.x )
    --DirectionRadians = DirectionRadians + self:GetNorthCorrectionRadians()
    if DirectionRadians < 0 then
      DirectionRadians = DirectionRadians + 2 * math.pi  -- put dir in range of 0 to 2*pi ( the full circle )
    end
    return DirectionRadians
  end

  --- Return an angle in degrees from the COORDINATE using a direction vector in Vec3 format.
  -- @param #COORDINATE self
  -- @param Dcs.DCSTypes#Vec3 DirectionVec3 The direction vector in Vec3 format.
  -- @return #number DirectionRadians The angle in degrees.
  function COORDINATE:GetAngleDegrees( DirectionVec3 )
    local AngleRadians = self:GetAngleRadians( DirectionVec3 )
    local Angle = UTILS.ToDegree( AngleRadians )
    return Angle
  end


  --- Return the 2D distance in meters between the target COORDINATE and the COORDINATE.
  -- @param #COORDINATE self
  -- @param #COORDINATE TargetCoordinate The target COORDINATE.
  -- @return Dcs.DCSTypes#Distance Distance The distance in meters.
  function COORDINATE:Get2DDistance( TargetCoordinate )
    local TargetVec3 = TargetCoordinate:GetVec3()
    local SourceVec3 = self:GetVec3()
    return ( ( TargetVec3.x - SourceVec3.x ) ^ 2 + ( TargetVec3.z - SourceVec3.z ) ^ 2 ) ^ 0.5
  end


  --- Return the 3D distance in meters between the target COORDINATE and the COORDINATE.
  -- @param #COORDINATE self
  -- @param #COORDINATE TargetCoordinate The target COORDINATE.
  -- @return Dcs.DCSTypes#Distance Distance The distance in meters.
  function COORDINATE:Get3DDistance( TargetCoordinate )
    local TargetVec3 = TargetCoordinate:GetVec3()
    local SourceVec3 = self:GetVec3()
    return ( ( TargetVec3.x - SourceVec3.x ) ^ 2 + ( TargetVec3.y - SourceVec3.y ) ^ 2 + ( TargetVec3.z - SourceVec3.z ) ^ 2 ) ^ 0.5
  end


  --- Provides a bearing text in degrees.
  -- @param #COORDINATE self
  -- @param #number AngleRadians The angle in randians.
  -- @param #number Precision The precision.
  -- @param Core.Settings#SETTINGS Settings
  -- @return #string The bearing text in degrees.
  function COORDINATE:GetBearingText( AngleRadians, Precision, Settings )

    local Settings = Settings or _SETTINGS -- Core.Settings#SETTINGS

    local AngleDegrees = UTILS.Round( UTILS.ToDegree( AngleRadians ), Precision )
  
    local s = string.format( '%03d°', AngleDegrees ) 
    
    return s
  end

  --- Provides a distance text expressed in the units of measurement.
  -- @param #COORDINATE self
  -- @param #number Distance The distance in meters.
  -- @param Core.Settings#SETTINGS Settings
  -- @return #string The distance text expressed in the units of measurement.
  function COORDINATE:GetDistanceText( Distance, Settings )

    local Settings = Settings or _SETTINGS -- Core.Settings#SETTINGS

    local DistanceText

    if Settings:IsMetric() then
      DistanceText = " for " .. UTILS.Round( Distance / 1000, 2 ) .. " km"
    else
      DistanceText = " for " .. UTILS.Round( UTILS.MetersToNM( Distance ), 2 ) .. " miles"
    end
    
    return DistanceText
  end

  --- Return the altitude text of the COORDINATE.
  -- @param #COORDINATE self
  -- @return #string Altitude text.
  function COORDINATE:GetAltitudeText( Settings )
    local Altitude = self.y
    local Settings = Settings or _SETTINGS
    if Altitude ~= 0 then
      if Settings:IsMetric() then
        return " at " .. UTILS.Round( self.y, -3 ) .. " meters"
      else
        return " at " .. UTILS.Round( UTILS.MetersToFeet( self.y ), -3 ) .. " feet"
      end
    else
      return ""
    end
  end



  --- Return the velocity text of the COORDINATE.
  -- @param #COORDINATE self
  -- @return #string Velocity text.
  function COORDINATE:GetVelocityText( Settings )
    local Velocity = self:GetVelocity()
    local Settings = Settings or _SETTINGS
    if Velocity then
      if Settings:IsMetric() then
        return string.format( " moving at %d km/h", UTILS.MpsToKmph( Velocity ) )
      else
        return string.format( " moving at %d mi/h", UTILS.MpsToKmph( Velocity ) / 1.852 )
      end
    else
      return " stationary"
    end
  end


  --- Return the heading text of the COORDINATE.
  -- @param #COORDINATE self
  -- @return #string Heading text.
  function COORDINATE:GetHeadingText( Settings )
    local Heading = self:GetHeading()
    if Heading then
      return string.format( " bearing %3d°", Heading )
    else
      return " bearing unknown"
    end
  end


  --- Provides a Bearing / Range string
  -- @param #COORDINATE self
  -- @param #number AngleRadians The angle in randians
  -- @param #number Distance The distance
  -- @param Core.Settings#SETTINGS Settings
  -- @return #string The BR Text
  function COORDINATE:GetBRText( AngleRadians, Distance, Settings )

    local Settings = Settings or _SETTINGS -- Core.Settings#SETTINGS

    local BearingText = self:GetBearingText( AngleRadians, 0, Settings )
    local DistanceText = self:GetDistanceText( Distance, Settings )
    
    local BRText = BearingText .. DistanceText

    return BRText
  end

  --- Provides a Bearing / Range / Altitude string
  -- @param #COORDINATE self
  -- @param #number AngleRadians The angle in randians
  -- @param #number Distance The distance
  -- @param Core.Settings#SETTINGS Settings
  -- @return #string The BRA Text
  function COORDINATE:GetBRAText( AngleRadians, Distance, Settings )

    local Settings = Settings or _SETTINGS -- Core.Settings#SETTINGS

    local BearingText = self:GetBearingText( AngleRadians, 0, Settings )
    local DistanceText = self:GetDistanceText( Distance, Settings )
    local AltitudeText = self:GetAltitudeText( Settings )

    local BRAText = BearingText .. DistanceText .. AltitudeText -- When the POINT is a VEC2, there will be no altitude shown.

    return BRAText
  end



  --- Add a Distance in meters from the COORDINATE horizontal plane, with the given angle, and calculate the new COORDINATE.
  -- @param #COORDINATE self
  -- @param Dcs.DCSTypes#Distance Distance The Distance to be added in meters.
  -- @param Dcs.DCSTypes#Angle Angle The Angle in degrees.
  -- @return #COORDINATE The new calculated COORDINATE.
  function COORDINATE:Translate( Distance, Angle )
    local SX = self.x
    local SZ = self.z
    local Radians = Angle / 180 * math.pi
    local TX = Distance * math.cos( Radians ) + SX
    local TZ = Distance * math.sin( Radians ) + SZ

    return COORDINATE:New( TX, self.y, TZ )
  end



  --- Build an air type route point.
  -- @param #COORDINATE self
  -- @param #COORDINATE.RoutePointAltType AltType The altitude type.
  -- @param #COORDINATE.RoutePointType Type The route point type.
  -- @param #COORDINATE.RoutePointAction Action The route point action.
  -- @param Dcs.DCSTypes#Speed Speed Airspeed in km/h.
  -- @param #boolean SpeedLocked true means the speed is locked.
  -- @return #table The route point.
  function COORDINATE:WaypointAir( AltType, Type, Action, Speed, SpeedLocked )
    self:F2( { AltType, Type, Action, Speed, SpeedLocked } )

    local RoutePoint = {}
    RoutePoint.x = self.x
    RoutePoint.y = self.z
    RoutePoint.alt = self.y
    RoutePoint.alt_type = AltType or "RADIO"

    RoutePoint.type = Type or nil
    RoutePoint.action = Action or nil

    RoutePoint.speed = ( Speed and Speed / 3.6 ) or ( 500 / 3.6 )
    RoutePoint.speed_locked = true

    --  ["task"] =
    --  {
    --      ["id"] = "ComboTask",
    --      ["params"] =
    --      {
    --          ["tasks"] =
    --          {
    --          }, -- end of ["tasks"]
    --      }, -- end of ["params"]
    --  }, -- end of ["task"]


    RoutePoint.task = {}
    RoutePoint.task.id = "ComboTask"
    RoutePoint.task.params = {}
    RoutePoint.task.params.tasks = {}


    return RoutePoint
  end

  --- Build an ground type route point.
  -- @param #COORDINATE self
  -- @param #number Speed (optional) Speed in km/h. The default speed is 999 km/h.
  -- @param #string Formation (optional) The route point Formation, which is a text string that specifies exactly the Text in the Type of the route point, like "Vee", "Echelon Right".
  -- @return #table The route point.
  function COORDINATE:WaypointGround( Speed, Formation )
    self:F2( { Formation, Speed } )

    local RoutePoint = {}
    RoutePoint.x = self.x
    RoutePoint.y = self.z

    RoutePoint.action = Formation or ""


    RoutePoint.speed = ( Speed or 999 ) / 3.6
    RoutePoint.speed_locked = true

    --  ["task"] =
    --  {
    --      ["id"] = "ComboTask",
    --      ["params"] =
    --      {
    --          ["tasks"] =
    --          {
    --          }, -- end of ["tasks"]
    --      }, -- end of ["params"]
    --  }, -- end of ["task"]


    RoutePoint.task = {}
    RoutePoint.task.id = "ComboTask"
    RoutePoint.task.params = {}
    RoutePoint.task.params.tasks = {}


    return RoutePoint
  end

  --- Creates an explosion at the point of a certain intensity.
  -- @param #COORDINATE self
  -- @param #number ExplosionIntensity
  function COORDINATE:Explosion( ExplosionIntensity )
    self:F2( { ExplosionIntensity } )
    trigger.action.explosion( self:GetVec3(), ExplosionIntensity )
  end

  --- Creates an illumination bomb at the point.
  -- @param #COORDINATE self
  function COORDINATE:IlluminationBomb()
    self:F2()
    trigger.action.illuminationBomb( self:GetVec3() )
  end


  --- Smokes the point in a color.
  -- @param #COORDINATE self
  -- @param Utilities.Utils#SMOKECOLOR SmokeColor
  function COORDINATE:Smoke( SmokeColor )
    self:F2( { SmokeColor } )
    trigger.action.smoke( self:GetVec3(), SmokeColor )
  end

  --- Smoke the COORDINATE Green.
  -- @param #COORDINATE self
  function COORDINATE:SmokeGreen()
    self:F2()
    self:Smoke( SMOKECOLOR.Green )
  end

  --- Smoke the COORDINATE Red.
  -- @param #COORDINATE self
  function COORDINATE:SmokeRed()
    self:F2()
    self:Smoke( SMOKECOLOR.Red )
  end

  --- Smoke the COORDINATE White.
  -- @param #COORDINATE self
  function COORDINATE:SmokeWhite()
    self:F2()
    self:Smoke( SMOKECOLOR.White )
  end

  --- Smoke the COORDINATE Orange.
  -- @param #COORDINATE self
  function COORDINATE:SmokeOrange()
    self:F2()
    self:Smoke( SMOKECOLOR.Orange )
  end

  --- Smoke the COORDINATE Blue.
  -- @param #COORDINATE self
  function COORDINATE:SmokeBlue()
    self:F2()
    self:Smoke( SMOKECOLOR.Blue )
  end

  --- Flares the point in a color.
  -- @param #COORDINATE self
  -- @param Utilities.Utils#FLARECOLOR FlareColor
  -- @param Dcs.DCSTypes#Azimuth (optional) Azimuth The azimuth of the flare direction. The default azimuth is 0.
  function COORDINATE:Flare( FlareColor, Azimuth )
    self:F2( { FlareColor } )
    trigger.action.signalFlare( self:GetVec3(), FlareColor, Azimuth and Azimuth or 0 )
  end

  --- Flare the COORDINATE White.
  -- @param #COORDINATE self
  -- @param Dcs.DCSTypes#Azimuth (optional) Azimuth The azimuth of the flare direction. The default azimuth is 0.
  function COORDINATE:FlareWhite( Azimuth )
    self:F2( Azimuth )
    self:Flare( FLARECOLOR.White, Azimuth )
  end

  --- Flare the COORDINATE Yellow.
  -- @param #COORDINATE self
  -- @param Dcs.DCSTypes#Azimuth (optional) Azimuth The azimuth of the flare direction. The default azimuth is 0.
  function COORDINATE:FlareYellow( Azimuth )
    self:F2( Azimuth )
    self:Flare( FLARECOLOR.Yellow, Azimuth )
  end

  --- Flare the COORDINATE Green.
  -- @param #COORDINATE self
  -- @param Dcs.DCSTypes#Azimuth (optional) Azimuth The azimuth of the flare direction. The default azimuth is 0.
  function COORDINATE:FlareGreen( Azimuth )
    self:F2( Azimuth )
    self:Flare( FLARECOLOR.Green, Azimuth )
  end

  --- Flare the COORDINATE Red.
  -- @param #COORDINATE self
  function COORDINATE:FlareRed( Azimuth )
    self:F2( Azimuth )
    self:Flare( FLARECOLOR.Red, Azimuth )
  end
  
  do -- Markings
  
    --- Mark to All
    -- @param #COORDINATE self
    -- @param #string MarkText Free format text that shows the marking clarification.
    -- @return #number The resulting Mark ID which is a number.
    -- @usage
    --   local TargetCoord = TargetGroup:GetCoordinate()
    --   local MarkID = TargetCoord:MarkToAll( "This is a target for all players" )
    function COORDINATE:MarkToAll( MarkText )
      local MarkID = UTILS.GetMarkID()
      trigger.action.markToAll( MarkID, MarkText, self:GetVec3() )
      return MarkID
    end

    --- Mark to Coalition
    -- @param #COORDINATE self
    -- @param #string MarkText Free format text that shows the marking clarification.
    -- @param Coalition
    -- @return #number The resulting Mark ID which is a number.
    -- @usage
    --   local TargetCoord = TargetGroup:GetCoordinate()
    --   local MarkID = TargetCoord:MarkToCoalition( "This is a target for the red coalition", coalition.side.RED )
    function COORDINATE:MarkToCoalition( MarkText, Coalition )
      local MarkID = UTILS.GetMarkID()
      trigger.action.markToCoalition( MarkID, MarkText, self:GetVec3(), Coalition )
      return MarkID
    end

    --- Mark to Red Coalition
    -- @param #COORDINATE self
    -- @param #string MarkText Free format text that shows the marking clarification.
    -- @return #number The resulting Mark ID which is a number.
    -- @usage
    --   local TargetCoord = TargetGroup:GetCoordinate()
    --   local MarkID = TargetCoord:MarkToCoalitionRed( "This is a target for the red coalition" )
    function COORDINATE:MarkToCoalitionRed( MarkText )
      return self:MarkToCoalition( MarkText, coalition.side.RED )
    end

    --- Mark to Blue Coalition
    -- @param #COORDINATE self
    -- @param #string MarkText Free format text that shows the marking clarification.
    -- @return #number The resulting Mark ID which is a number.
    -- @usage
    --   local TargetCoord = TargetGroup:GetCoordinate()
    --   local MarkID = TargetCoord:MarkToCoalitionBlue( "This is a target for the blue coalition" )
    function COORDINATE:MarkToCoalitionBlue( MarkText )
      return self:MarkToCoalition( MarkText, coalition.side.BLUE )
    end

    --- Mark to Group
    -- @param #COORDINATE self
    -- @param #string MarkText Free format text that shows the marking clarification.
    -- @param Wrapper.Group#GROUP MarkGroup The @{Group} that receives the mark.
    -- @return #number The resulting Mark ID which is a number.
    -- @usage
    --   local TargetCoord = TargetGroup:GetCoordinate()
    --   local MarkGroup = GROUP:FindByName( "AttackGroup" )
    --   local MarkID = TargetCoord:MarkToGroup( "This is a target for the attack group", AttackGroup )
    function COORDINATE:MarkToGroup( MarkText, MarkGroup )
      local MarkID = UTILS.GetMarkID()
      trigger.action.markToGroup( MarkID, MarkText, self:GetVec3(), MarkGroup:GetID() )
      return MarkID
    end
    
    --- Remove a mark
    -- @param #COORDINATE self
    -- @param #number MarkID The ID of the mark to be removed.
    -- @usage
    --   local TargetCoord = TargetGroup:GetCoordinate()
    --   local MarkGroup = GROUP:FindByName( "AttackGroup" )
    --   local MarkID = TargetCoord:MarkToGroup( "This is a target for the attack group", AttackGroup )
    --   <<< logic >>>
    --   RemoveMark( MarkID ) -- The mark is now removed
    function COORDINATE:RemoveMark( MarkID )
      trigger.action.removeMark( MarkID )
    end
  
  end -- Markings
  

  --- Returns if a Coordinate has Line of Sight (LOS) with the ToCoordinate.
  -- @param #COORDINATE self
  -- @param #COORDINATE ToCoordinate
  -- @return #boolean true If the ToCoordinate has LOS with the Coordinate, otherwise false.
  function COORDINATE:IsLOS( ToCoordinate )

    -- Measurement of visibility should not be from the ground, so Adding a hypotethical 2 meters to each Coordinate.
    local FromVec3 = self:GetVec3()
    FromVec3.y = FromVec3.y + 2

    local ToVec3 = ToCoordinate:GetVec3()
    ToVec3.y = ToVec3.y + 2

    local IsLOS = land.isVisible( FromVec3, ToVec3 )

    return IsLOS
  end


  --- Returns if a Coordinate is in a certain Radius of this Coordinate in 2D plane using the X and Z axis.
  -- @param #COORDINATE self
  -- @param #COORDINATE ToCoordinate The coordinate that will be tested if it is in the radius of this coordinate.
  -- @param #number Radius The radius of the circle on the 2D plane around this coordinate.
  -- @return #boolean true if in the Radius.
  function COORDINATE:IsInRadius( Coordinate, Radius )

    local InVec2 = self:GetVec2()
    local Vec2 = Coordinate:GetVec2()
    
    local InRadius = UTILS.IsInRadius( InVec2, Vec2, Radius)

    return InRadius
  end


  --- Returns if a Coordinate is in a certain radius of this Coordinate in 3D space using the X, Y and Z axis.
  -- So Radius defines the radius of the a Sphere in 3D space around this coordinate.
  -- @param #COORDINATE self
  -- @param #COORDINATE ToCoordinate The coordinate that will be tested if it is in the radius of this coordinate.
  -- @param #number Radius The radius of the sphere in the 3D space around this coordinate.
  -- @return #boolean true if in the Sphere.
  function COORDINATE:IsInSphere( Coordinate, Radius )

    local InVec3 = self:GetVec3()
    local Vec3 = Coordinate:GetVec3()
    
    local InSphere = UTILS.IsInSphere( InVec3, Vec3, Radius)

    return InSphere
  end


  --- Return a BR string from a COORDINATE to the COORDINATE.
  -- @param #COORDINATE self
  -- @param #COORDINATE TargetCoordinate The target COORDINATE.
  -- @return #string The BR text.
  function COORDINATE:ToStringBR( FromCoordinate, Settings )
    local DirectionVec3 = FromCoordinate:GetDirectionVec3( self )
    local AngleRadians =  self:GetAngleRadians( DirectionVec3 )
    local Distance = self:Get2DDistance( FromCoordinate )
    return "BR, " .. self:GetBRText( AngleRadians, Distance, Settings )
  end

  --- Return a BRAA string from a COORDINATE to the COORDINATE.
  -- @param #COORDINATE self
  -- @param #COORDINATE TargetCoordinate The target COORDINATE.
  -- @return #string The BR text.
  function COORDINATE:ToStringBRA( FromCoordinate, Settings )
    local DirectionVec3 = FromCoordinate:GetDirectionVec3( self )
    local AngleRadians =  self:GetAngleRadians( DirectionVec3 )
    local Distance = FromCoordinate:Get2DDistance( self )
    local Altitude = self:GetAltitudeText()
    return "BRA, " .. self:GetBRAText( AngleRadians, Distance, Settings )
  end

  --- Return a BULLS string from a COORDINATE to the BULLS of the coalition.
  -- @param #COORDINATE self
  -- @param Dcs.DCSCoalition#coalition.side Coalition The coalition.
  -- @return #string The BR text.
  function COORDINATE:ToStringBULLS( Coalition, Settings )
    local TargetCoordinate = COORDINATE:NewFromVec3( coalition.getMainRefPoint( Coalition ) )
    local DirectionVec3 = self:GetDirectionVec3( TargetCoordinate )
    local AngleRadians =  self:GetAngleRadians( DirectionVec3 )
    local Distance = self:Get2DDistance( TargetCoordinate )
    local Altitude = self:GetAltitudeText()
    return "BULLS, " .. self:GetBRText( AngleRadians, Distance, Settings )
  end

  --- Return an aspect string from a COORDINATE to the Angle of the object.
  -- @param #COORDINATE self
  -- @param #COORDINATE TargetCoordinate The target COORDINATE.
  -- @return #string The Aspect string, which is Hot, Cold or Flanking.
  function COORDINATE:ToStringAspect( TargetCoordinate )
    local Heading = self.Heading
    local DirectionVec3 = self:GetDirectionVec3( TargetCoordinate )
    local Angle = self:GetAngleDegrees( DirectionVec3 )
    
    if Heading then
      local Aspect = Angle - Heading
      if Aspect > -135 and Aspect <= -45 then
        return "Flanking"
      end
      if Aspect > -45 and Aspect <= 45 then
        return "Hot"
      end
      if Aspect > 45 and Aspect <= 135 then
        return "Flanking"
      end
      if Aspect > 135 or Aspect <= -135 then
        return "Cold"
      end
    end
    return ""
  end

  --- Provides a Lat Lon string in Degree Minute Second format.
  -- @param #COORDINATE self
  -- @param Core.Settings#SETTINGS Settings (optional) Settings
  -- @return #string The LL DMS Text
  function COORDINATE:ToStringLLDMS( Settings ) 

    local LL_Accuracy = Settings and Settings.LL_Accuracy or _SETTINGS.LL_Accuracy
    local lat, lon = coord.LOtoLL( self:GetVec3() )
    return "LL DMS, " .. UTILS.tostringLL( lat, lon, LL_Accuracy, true )
  end

  --- Provides a Lat Lon string in Degree Decimal Minute format.
  -- @param #COORDINATE self
  -- @param Core.Settings#SETTINGS Settings (optional) Settings
  -- @return #string The LL DDM Text
  function COORDINATE:ToStringLLDDM( Settings )

    local LL_Accuracy = Settings and Settings.LL_Accuracy or _SETTINGS.LL_Accuracy
    local lat, lon = coord.LOtoLL( self:GetVec3() )
    return "LL DDM, " .. UTILS.tostringLL( lat, lon, LL_Accuracy, false )
  end

  --- Provides a MGRS string
  -- @param #COORDINATE self
  -- @param Core.Settings#SETTINGS Settings (optional) Settings
  -- @return #string The MGRS Text
  function COORDINATE:ToStringMGRS( Settings ) --R2.1 Fixes issue #424.

    local MGRS_Accuracy = Settings and Settings.MGRS_Accuracy or _SETTINGS.MGRS_Accuracy
    local lat, lon = coord.LOtoLL( self:GetVec3() )
    local MGRS = coord.LLtoMGRS( lat, lon )
    return "MGRS, " .. UTILS.tostringMGRS( MGRS, MGRS_Accuracy )
  end

  --- Provides a coordinate string of the point, based on a coordinate format system:
  --   * Uses default settings in COORDINATE.
  --   * Can be overridden if for a GROUP containing x clients, a menu was selected to override the default.
  -- @param #COORDINATE self
  -- @param Wrapper.Controllable#CONTROLLABLE Controllable
  -- @param Core.Settings#SETTINGS Settings
  -- @return #string The coordinate Text in the configured coordinate system.
  function COORDINATE:ToStringFromRP( ReferenceCoord, ReferenceName, Controllable, Settings ) -- R2.2
  
    self:E( { ReferenceCoord = ReferenceCoord, ReferenceName = ReferenceName } )

    local Settings = Settings or ( Controllable and _DATABASE:GetPlayerSettings( Controllable:GetPlayerName() ) ) or _SETTINGS
    
    local IsAir = Controllable and Controllable:IsAirPlane() or false

    if IsAir then
      local DirectionVec3 = ReferenceCoord:GetDirectionVec3( self )
      local AngleRadians =  self:GetAngleRadians( DirectionVec3 )
      local Distance = self:Get2DDistance( ReferenceCoord )
      return "Targets are the last seen " .. self:GetBRText( AngleRadians, Distance, Settings ) .. " from " .. ReferenceName
    else
      local DirectionVec3 = ReferenceCoord:GetDirectionVec3( self )
      local AngleRadians =  self:GetAngleRadians( DirectionVec3 )
      local Distance = self:Get2DDistance( ReferenceCoord )
      return "Target are located " .. self:GetBRText( AngleRadians, Distance, Settings ) .. " from " .. ReferenceName
    end
    
    return nil

  end

  --- Provides a coordinate string of the point, based on the A2G coordinate format system.
  -- @param #COORDINATE self
  -- @param Wrapper.Controllable#CONTROLLABLE Controllable
  -- @param Core.Settings#SETTINGS Settings
  -- @return #string The coordinate Text in the configured coordinate system.
  function COORDINATE:ToStringA2G( Controllable, Settings ) -- R2.2
  
    self:F( { Controllable = Controllable and Controllable:GetName() } )

    local Settings = Settings or ( Controllable and _DATABASE:GetPlayerSettings( Controllable:GetPlayerName() ) ) or _SETTINGS

    if Settings:IsA2G_BR()  then
      -- If no Controllable is given to calculate the BR from, then MGRS will be used!!!
      if Controllable then
        local Coordinate = Controllable:GetCoordinate()
        return Controllable and self:ToStringBR( Coordinate, Settings ) or self:ToStringMGRS( Settings )
      else
        return self:ToStringMGRS( Settings )
      end
    end
    if Settings:IsA2G_LL_DMS()  then
      return self:ToStringLLDMS( Settings )
    end
    if Settings:IsA2G_LL_DDM()  then
      return self:ToStringLLDDM( Settings )
    end
    if Settings:IsA2G_MGRS() then
      return self:ToStringMGRS( Settings )
    end

    return nil

  end


  --- Provides a coordinate string of the point, based on the A2A coordinate format system.
  -- @param #COORDINATE self
  -- @param Wrapper.Controllable#CONTROLLABLE Controllable
  -- @param Core.Settings#SETTINGS Settings
  -- @return #string The coordinate Text in the configured coordinate system.
  function COORDINATE:ToStringA2A( Controllable, Settings ) -- R2.2
  
    self:F( { Controllable = Controllable and Controllable:GetName() } )

    local Settings = Settings or ( Controllable and _DATABASE:GetPlayerSettings( Controllable:GetPlayerName() ) ) or _SETTINGS

    if Settings:IsA2A_BRAA()  then
      if Controllable then
        local Coordinate = Controllable:GetCoordinate()
        return self:ToStringBRA( Coordinate, Settings ) 
      else
        return self:ToStringMGRS( Settings )
      end
    end
    if Settings:IsA2A_BULLS() then
      local Coalition = Controllable:GetCoalition()
      return self:ToStringBULLS( Coalition, Settings )
    end
    if Settings:IsA2A_LL_DMS()  then
      return self:ToStringLLDMS( Settings )
    end
    if Settings:IsA2A_LL_DDM()  then
      return self:ToStringLLDDM( Settings )
    end
    if Settings:IsA2A_MGRS() then
      return self:ToStringMGRS( Settings )
    end

    return nil

  end

  --- Provides a coordinate string of the point, based on a coordinate format system:
  --   * Uses default settings in COORDINATE.
  --   * Can be overridden if for a GROUP containing x clients, a menu was selected to override the default.
  -- @param #COORDINATE self
  -- @param Wrapper.Controllable#CONTROLLABLE Controllable
  -- @param Core.Settings#SETTINGS Settings
  -- @param Tasking.Task#TASK Task The task for which coordinates need to be calculated.
  -- @return #string The coordinate Text in the configured coordinate system.
  function COORDINATE:ToString( Controllable, Settings, Task ) -- R2.2
  
    self:F( { Controllable = Controllable and Controllable:GetName() } )

    local Settings = Settings or ( Controllable and _DATABASE:GetPlayerSettings( Controllable:GetPlayerName() ) ) or _SETTINGS

    local ModeA2A = false
    
    if Task then
      if Task:IsInstanceOf( TASK_A2A ) then
        ModeA2A = true
      else
        if Task:IsInstanceOf( TASK_A2G ) then
          ModeA2A = false
        else
          if Task:IsInstanceOf( TASK_CARGO ) then
            ModeA2A = false
          else
            ModeA2A = false
          end
        end
      end
    else
      local IsAir = Controllable and Controllable:IsAirPlane() or false
      if IsAir  then
        ModeA2A = true
      else
        ModeA2A = false
      end
    end
    

    if ModeA2A == true then
      return self:ToStringA2A( Controllable, Settings )
    else
      return self:ToStringA2G( Controllable, Settings )
    end
    
    return nil

  end

end

do -- POINT_VEC3

  --- The POINT_VEC3 class
  -- @type POINT_VEC3
  -- @field #number x The x coordinate in 3D space.
  -- @field #number y The y coordinate in 3D space.
  -- @field #number z The z coordiante in 3D space.
  -- @field Utilities.Utils#SMOKECOLOR SmokeColor
  -- @field Utilities.Utils#FLARECOLOR FlareColor
  -- @field #POINT_VEC3.RoutePointAltType RoutePointAltType
  -- @field #POINT_VEC3.RoutePointType RoutePointType
  -- @field #POINT_VEC3.RoutePointAction RoutePointAction
  -- @extends Core.Point#COORDINATE
  
  
  --- # POINT_VEC3 class, extends @{Point#COORDINATE}
  --
  -- POINT_VEC3 defines a 3D point in the simulator and with its methods, you can use or manipulate the point in 3D space.
  --
  -- **Important Note:** Most of the functions in this section were taken from MIST, and reworked to OO concepts.
  -- In order to keep the credibility of the the author,
  -- I want to emphasize that the formulas embedded in the MIST framework were created by Grimes or previous authors,
  -- who you can find on the Eagle Dynamics Forums.
  --
  --
  -- ## POINT_VEC3 constructor
  --
  -- A new POINT_VEC3 object can be created with:
  --
  --  * @{#POINT_VEC3.New}(): a 3D point.
  --  * @{#POINT_VEC3.NewFromVec3}(): a 3D point created from a @{DCSTypes#Vec3}.
  --
  --
  -- ## Manupulate the X, Y, Z coordinates of the POINT_VEC3
  --
  -- A POINT_VEC3 class works in 3D space. It contains internally an X, Y, Z coordinate.
  -- Methods exist to manupulate these coordinates.
  --
  -- The current X, Y, Z axis can be retrieved with the methods @{#POINT_VEC3.GetX}(), @{#POINT_VEC3.GetY}(), @{#POINT_VEC3.GetZ}() respectively.
  -- The methods @{#POINT_VEC3.SetX}(), @{#POINT_VEC3.SetY}(), @{#POINT_VEC3.SetZ}() change the respective axis with a new value.
  -- The current axis values can be changed by using the methods @{#POINT_VEC3.AddX}(), @{#POINT_VEC3.AddY}(), @{#POINT_VEC3.AddZ}()
  -- to add or substract a value from the current respective axis value.
  -- Note that the Set and Add methods return the current POINT_VEC3 object, so these manipulation methods can be chained... For example:
  --
  --      local Vec3 = PointVec3:AddX( 100 ):AddZ( 150 ):GetVec3()
  --
  --
  -- ## 3D calculation methods
  --
  -- Various calculation methods exist to use or manipulate 3D space. Find below a short description of each method:
  --
  --
  -- ## Point Randomization
  --
  -- Various methods exist to calculate random locations around a given 3D point.
  --
  --   * @{#POINT_VEC3.GetRandomPointVec3InRadius}(): Provides a random 3D point around the current 3D point, in the given inner to outer band.
  --
  --
  -- @field #POINT_VEC3
  POINT_VEC3 = {
    ClassName = "POINT_VEC3",
    Metric = true,
    RoutePointAltType = {
      BARO = "BARO",
    },
    RoutePointType = {
      TakeOffParking = "TakeOffParking",
      TurningPoint = "Turning Point",
    },
    RoutePointAction = {
      FromParkingArea = "From Parking Area",
      TurningPoint = "Turning Point",
    },
  }

  --- RoutePoint AltTypes
  -- @type POINT_VEC3.RoutePointAltType
  -- @field BARO "BARO"

  --- RoutePoint Types
  -- @type POINT_VEC3.RoutePointType
  -- @field TakeOffParking "TakeOffParking"
  -- @field TurningPoint "Turning Point"

  --- RoutePoint Actions
  -- @type POINT_VEC3.RoutePointAction
  -- @field FromParkingArea "From Parking Area"
  -- @field TurningPoint "Turning Point"

  -- Constructor.

  --- Create a new POINT_VEC3 object.
  -- @param #POINT_VEC3 self
  -- @param Dcs.DCSTypes#Distance x The x coordinate of the Vec3 point, pointing to the North.
  -- @param Dcs.DCSTypes#Distance y The y coordinate of the Vec3 point, pointing Upwards.
  -- @param Dcs.DCSTypes#Distance z The z coordinate of the Vec3 point, pointing to the Right.
  -- @return Core.Point#POINT_VEC3
  function POINT_VEC3:New( x, y, z )

    local self = BASE:Inherit( self, COORDINATE:New( x, y, z ) ) -- Core.Point#POINT_VEC3
    self:F2( self )
    
    return self
  end

  --- Create a new POINT_VEC3 object from Vec2 coordinates.
  -- @param #POINT_VEC3 self
  -- @param Dcs.DCSTypes#Vec2 Vec2 The Vec2 point.
  -- @param Dcs.DCSTypes#Distance LandHeightAdd (optional) Add a landheight.
  -- @return Core.Point#POINT_VEC3 self
  function POINT_VEC3:NewFromVec2( Vec2, LandHeightAdd )

    local self = BASE:Inherit( self, COORDINATE:NewFromVec2( Vec2, LandHeightAdd ) ) -- Core.Point#POINT_VEC3
    self:F2( self )

    return self
  end


  --- Create a new POINT_VEC3 object from  Vec3 coordinates.
  -- @param #POINT_VEC3 self
  -- @param Dcs.DCSTypes#Vec3 Vec3 The Vec3 point.
  -- @return Core.Point#POINT_VEC3 self
  function POINT_VEC3:NewFromVec3( Vec3 )

    local self = BASE:Inherit( self, COORDINATE:NewFromVec3( Vec3 ) ) -- Core.Point#POINT_VEC3
    self:F2( self )
  
    return self
  end



  --- Return the x coordinate of the POINT_VEC3.
  -- @param #POINT_VEC3 self
  -- @return #number The x coodinate.
  function POINT_VEC3:GetX()
    return self.x
  end

  --- Return the y coordinate of the POINT_VEC3.
  -- @param #POINT_VEC3 self
  -- @return #number The y coodinate.
  function POINT_VEC3:GetY()
    return self.y
  end

  --- Return the z coordinate of the POINT_VEC3.
  -- @param #POINT_VEC3 self
  -- @return #number The z coodinate.
  function POINT_VEC3:GetZ()
    return self.z
  end

  --- Set the x coordinate of the POINT_VEC3.
  -- @param #POINT_VEC3 self
  -- @param #number x The x coordinate.
  -- @return #POINT_VEC3
  function POINT_VEC3:SetX( x )
    self.x = x
    return self
  end

  --- Set the y coordinate of the POINT_VEC3.
  -- @param #POINT_VEC3 self
  -- @param #number y The y coordinate.
  -- @return #POINT_VEC3
  function POINT_VEC3:SetY( y )
    self.y = y
    return self
  end

  --- Set the z coordinate of the POINT_VEC3.
  -- @param #POINT_VEC3 self
  -- @param #number z The z coordinate.
  -- @return #POINT_VEC3
  function POINT_VEC3:SetZ( z )
    self.z = z
    return self
  end

  --- Add to the x coordinate of the POINT_VEC3.
  -- @param #POINT_VEC3 self
  -- @param #number x The x coordinate value to add to the current x coodinate.
  -- @return #POINT_VEC3
  function POINT_VEC3:AddX( x )
    self.x = self.x + x
    return self
  end

  --- Add to the y coordinate of the POINT_VEC3.
  -- @param #POINT_VEC3 self
  -- @param #number y The y coordinate value to add to the current y coodinate.
  -- @return #POINT_VEC3
  function POINT_VEC3:AddY( y )
    self.y = self.y + y
    return self
  end

  --- Add to the z coordinate of the POINT_VEC3.
  -- @param #POINT_VEC3 self
  -- @param #number z The z coordinate value to add to the current z coodinate.
  -- @return #POINT_VEC3
  function POINT_VEC3:AddZ( z )
    self.z = self.z +z
    return self
  end

  --- Return a random POINT_VEC3 within an Outer Radius and optionally NOT within an Inner Radius of the POINT_VEC3.
  -- @param #POINT_VEC3 self
  -- @param Dcs.DCSTypes#Distance OuterRadius
  -- @param Dcs.DCSTypes#Distance InnerRadius
  -- @return #POINT_VEC3
  function POINT_VEC3:GetRandomPointVec3InRadius( OuterRadius, InnerRadius )

    return POINT_VEC3:NewFromVec3( self:GetRandomVec3InRadius( OuterRadius, InnerRadius ) )
  end

end

do -- POINT_VEC2

  --- @type POINT_VEC2
  -- @field Dcs.DCSTypes#Distance x The x coordinate in meters.
  -- @field Dcs.DCSTypes#Distance y the y coordinate in meters.
  -- @extends Core.Point#COORDINATE
  
  --- # POINT_VEC2 class, extends @{Point#COORDINATE}
  --
  -- The @{Point#POINT_VEC2} class defines a 2D point in the simulator. The height coordinate (if needed) will be the land height + an optional added height specified.
  --
  -- ## POINT_VEC2 constructor
  --
  -- A new POINT_VEC2 instance can be created with:
  --
  --  * @{Point#POINT_VEC2.New}(): a 2D point, taking an additional height parameter.
  --  * @{Point#POINT_VEC2.NewFromVec2}(): a 2D point created from a @{DCSTypes#Vec2}.
  --
  -- ## Manupulate the X, Altitude, Y coordinates of the 2D point
  --
  -- A POINT_VEC2 class works in 2D space, with an altitude setting. It contains internally an X, Altitude, Y coordinate.
  -- Methods exist to manupulate these coordinates.
  --
  -- The current X, Altitude, Y axis can be retrieved with the methods @{#POINT_VEC2.GetX}(), @{#POINT_VEC2.GetAlt}(), @{#POINT_VEC2.GetY}() respectively.
  -- The methods @{#POINT_VEC2.SetX}(), @{#POINT_VEC2.SetAlt}(), @{#POINT_VEC2.SetY}() change the respective axis with a new value.
  -- The current Lat(itude), Alt(itude), Lon(gitude) values can also be retrieved with the methods @{#POINT_VEC2.GetLat}(), @{#POINT_VEC2.GetAlt}(), @{#POINT_VEC2.GetLon}() respectively.
  -- The current axis values can be changed by using the methods @{#POINT_VEC2.AddX}(), @{#POINT_VEC2.AddAlt}(), @{#POINT_VEC2.AddY}()
  -- to add or substract a value from the current respective axis value.
  -- Note that the Set and Add methods return the current POINT_VEC2 object, so these manipulation methods can be chained... For example:
  --
  --      local Vec2 = PointVec2:AddX( 100 ):AddY( 2000 ):GetVec2()
  --
  -- @field #POINT_VEC2
  POINT_VEC2 = {
    ClassName = "POINT_VEC2",
  }
  


  --- POINT_VEC2 constructor.
  -- @param #POINT_VEC2 self
  -- @param Dcs.DCSTypes#Distance x The x coordinate of the Vec3 point, pointing to the North.
  -- @param Dcs.DCSTypes#Distance y The y coordinate of the Vec3 point, pointing to the Right.
  -- @param Dcs.DCSTypes#Distance LandHeightAdd (optional) The default height if required to be evaluated will be the land height of the x, y coordinate. You can specify an extra height to be added to the land height.
  -- @return Core.Point#POINT_VEC2
  function POINT_VEC2:New( x, y, LandHeightAdd )

    local LandHeight = land.getHeight( { ["x"] = x, ["y"] = y } )

    LandHeightAdd = LandHeightAdd or 0
    LandHeight = LandHeight + LandHeightAdd

    local self = BASE:Inherit( self, COORDINATE:New( x, LandHeight, y ) ) -- Core.Point#POINT_VEC2
    self:F2( self )

    return self
  end

  --- Create a new POINT_VEC2 object from  Vec2 coordinates.
  -- @param #POINT_VEC2 self
  -- @param Dcs.DCSTypes#Vec2 Vec2 The Vec2 point.
  -- @return Core.Point#POINT_VEC2 self
  function POINT_VEC2:NewFromVec2( Vec2, LandHeightAdd )

    local LandHeight = land.getHeight( Vec2 )

    LandHeightAdd = LandHeightAdd or 0
    LandHeight = LandHeight + LandHeightAdd

    local self = BASE:Inherit( self, COORDINATE:NewFromVec2( Vec2, LandHeightAdd ) ) -- #POINT_VEC2
    self:F2( self )

    return self
  end

  --- Create a new POINT_VEC2 object from  Vec3 coordinates.
  -- @param #POINT_VEC2 self
  -- @param Dcs.DCSTypes#Vec3 Vec3 The Vec3 point.
  -- @return Core.Point#POINT_VEC2 self
  function POINT_VEC2:NewFromVec3( Vec3 )

    local self = BASE:Inherit( self, COORDINATE:NewFromVec3( Vec3 ) ) -- #POINT_VEC2
    self:F2( self )

    return self
  end

  --- Return the x coordinate of the POINT_VEC2.
  -- @param #POINT_VEC2 self
  -- @return #number The x coodinate.
  function POINT_VEC2:GetX()
    return self.x
  end

  --- Return the y coordinate of the POINT_VEC2.
  -- @param #POINT_VEC2 self
  -- @return #number The y coodinate.
  function POINT_VEC2:GetY()
    return self.z
  end

  --- Set the x coordinate of the POINT_VEC2.
  -- @param #POINT_VEC2 self
  -- @param #number x The x coordinate.
  -- @return #POINT_VEC2
  function POINT_VEC2:SetX( x )
    self.x = x
    return self
  end

  --- Set the y coordinate of the POINT_VEC2.
  -- @param #POINT_VEC2 self
  -- @param #number y The y coordinate.
  -- @return #POINT_VEC2
  function POINT_VEC2:SetY( y )
    self.z = y
    return self
  end

  --- Return Return the Lat(itude) coordinate of the POINT_VEC2 (ie: (parent)POINT_VEC3.x).
  -- @param #POINT_VEC2 self
  -- @return #number The x coodinate.
  function POINT_VEC2:GetLat()
    return self.x
  end

  --- Set the Lat(itude) coordinate of the POINT_VEC2 (ie: POINT_VEC3.x).
  -- @param #POINT_VEC2 self
  -- @param #number x The x coordinate.
  -- @return #POINT_VEC2
  function POINT_VEC2:SetLat( x )
    self.x = x
    return self
  end

  --- Return the Lon(gitude) coordinate of the POINT_VEC2 (ie: (parent)POINT_VEC3.z).
  -- @param #POINT_VEC2 self
  -- @return #number The y coodinate.
  function POINT_VEC2:GetLon()
    return self.z
  end

  --- Set the Lon(gitude) coordinate of the POINT_VEC2 (ie: POINT_VEC3.z).
  -- @param #POINT_VEC2 self
  -- @param #number y The y coordinate.
  -- @return #POINT_VEC2
  function POINT_VEC2:SetLon( z )
    self.z = z
    return self
  end

  --- Return the altitude (height) of the land at the POINT_VEC2.
  -- @param #POINT_VEC2 self
  -- @return #number The land altitude.
  function POINT_VEC2:GetAlt()
    return self.y ~= 0 or land.getHeight( { x = self.x, y = self.z } )
  end

  --- Set the altitude of the POINT_VEC2.
  -- @param #POINT_VEC2 self
  -- @param #number Altitude The land altitude. If nothing (nil) is given, then the current land altitude is set.
  -- @return #POINT_VEC2
  function POINT_VEC2:SetAlt( Altitude )
    self.y = Altitude or land.getHeight( { x = self.x, y = self.z } )
    return self
  end

  --- Add to the x coordinate of the POINT_VEC2.
  -- @param #POINT_VEC2 self
  -- @param #number x The x coordinate.
  -- @return #POINT_VEC2
  function POINT_VEC2:AddX( x )
    self.x = self.x + x
    return self
  end

  --- Add to the y coordinate of the POINT_VEC2.
  -- @param #POINT_VEC2 self
  -- @param #number y The y coordinate.
  -- @return #POINT_VEC2
  function POINT_VEC2:AddY( y )
    self.z = self.z + y
    return self
  end

  --- Add to the current land height an altitude.
  -- @param #POINT_VEC2 self
  -- @param #number Altitude The Altitude to add. If nothing (nil) is given, then the current land altitude is set.
  -- @return #POINT_VEC2
  function POINT_VEC2:AddAlt( Altitude )
    self.y = land.getHeight( { x = self.x, y = self.z } ) + Altitude or 0
    return self
  end


  --- Return a random POINT_VEC2 within an Outer Radius and optionally NOT within an Inner Radius of the POINT_VEC2.
  -- @param #POINT_VEC2 self
  -- @param Dcs.DCSTypes#Distance OuterRadius
  -- @param Dcs.DCSTypes#Distance InnerRadius
  -- @return #POINT_VEC2
  function POINT_VEC2:GetRandomPointVec2InRadius( OuterRadius, InnerRadius )
    self:F2( { OuterRadius, InnerRadius } )

    return POINT_VEC2:NewFromVec2( self:GetRandomVec2InRadius( OuterRadius, InnerRadius ) )
  end

  -- TODO: Check this to replace
  --- Calculate the distance from a reference @{#POINT_VEC2}.
  -- @param #POINT_VEC2 self
  -- @param #POINT_VEC2 PointVec2Reference The reference @{#POINT_VEC2}.
  -- @return Dcs.DCSTypes#Distance The distance from the reference @{#POINT_VEC2} in meters.
  function POINT_VEC2:DistanceFromPointVec2( PointVec2Reference )
    self:F2( PointVec2Reference )

    local Distance = ( ( PointVec2Reference.x - self.x ) ^ 2 + ( PointVec2Reference.z - self.z ) ^2 ) ^ 0.5

    self:T2( Distance )
    return Distance
  end

end


--- **Core** -- MESSAGE class takes are of the **real-time notifications** and **messages to players** during a simulation.
-- 
-- ![Banner Image](..\Presentations\MESSAGE\Dia1.JPG)
-- 
-- ===
-- 
-- @module Message

--- The MESSAGE class
-- @type MESSAGE
-- @extends Core.Base#BASE

--- # MESSAGE class, extends @{Base#BASE}
-- 
-- Message System to display Messages to Clients, Coalitions or All.
-- Messages are shown on the display panel for an amount of seconds, and will then disappear.
-- Messages can contain a category which is indicating the category of the message.
-- 
-- ## MESSAGE construction
-- 
-- Messages are created with @{Message#MESSAGE.New}. Note that when the MESSAGE object is created, no message is sent yet.
-- To send messages, you need to use the To functions.
-- 
-- ## Send messages to an audience
-- 
-- Messages are sent:
--
--   * To a @{Client} using @{Message#MESSAGE.ToClient}().
--   * To a @{Group} using @{Message#MESSAGE.ToGroup}()
--   * To a coalition using @{Message#MESSAGE.ToCoalition}().
--   * To the red coalition using @{Message#MESSAGE.ToRed}().
--   * To the blue coalition using @{Message#MESSAGE.ToBlue}().
--   * To all Players using @{Message#MESSAGE.ToAll}().
-- 
-- ## Send conditionally to an audience
-- 
-- Messages can be sent conditionally to an audience (when a condition is true):
--   
--   * To all players using @{Message#MESSAGE.ToAllIf}().
--   * To a coalition using @{Message#MESSAGE.ToCoalitionIf}().
-- 
-- ====
--  
-- ### Author: **Sven Van de Velde (FlightControl)**
-- ### Contributions: 
-- 
-- ====
-- 
-- @field #MESSAGE
MESSAGE = {
	ClassName = "MESSAGE", 
	MessageCategory = 0,
	MessageID = 0,
}

--- Message Types
-- @type MESSAGE.Type
MESSAGE.Type = {
  Update = "Update",
  Information = "Information",
  Briefing = "Briefing Report",
  Overview = "Overview Report",
  Detailed = "Detailed Report"
}


--- Creates a new MESSAGE object. Note that these MESSAGE objects are not yet displayed on the display panel. You must use the functions @{ToClient} or @{ToCoalition} or @{ToAll} to send these Messages to the respective recipients.
-- @param self
-- @param #string MessageText is the text of the Message.
-- @param #number MessageDuration is a number in seconds of how long the MESSAGE should be shown on the display panel.
-- @param #string MessageCategory (optional) is a string expressing the "category" of the Message. The category will be shown as the first text in the message followed by a ": ".
-- @return #MESSAGE
-- @usage
-- -- Create a series of new Messages.
-- -- MessageAll is meant to be sent to all players, for 25 seconds, and is classified as "Score".
-- -- MessageRED is meant to be sent to the RED players only, for 10 seconds, and is classified as "End of Mission", with ID "Win".
-- -- MessageClient1 is meant to be sent to a Client, for 25 seconds, and is classified as "Score", with ID "Score".
-- -- MessageClient1 is meant to be sent to a Client, for 25 seconds, and is classified as "Score", with ID "Score".
-- MessageAll = MESSAGE:New( "To all Players: BLUE has won! Each player of BLUE wins 50 points!",  25, "End of Mission" )
-- MessageRED = MESSAGE:New( "To the RED Players: You receive a penalty because you've killed one of your own units", 25, "Penalty" )
-- MessageClient1 = MESSAGE:New( "Congratulations, you've just hit a target",  25, "Score" )
-- MessageClient2 = MESSAGE:New( "Congratulations, you've just killed a target", 25, "Score")
function MESSAGE:New( MessageText, MessageDuration, MessageCategory )
	local self = BASE:Inherit( self, BASE:New() )
	self:F( { MessageText, MessageDuration, MessageCategory } )


  self.MessageType = nil
  
  -- When no MessageCategory is given, we don't show it as a title...	
	if MessageCategory and MessageCategory ~= "" then
	  if MessageCategory:sub(-1) ~= "\n" then
      self.MessageCategory = MessageCategory .. ": "
    else
      self.MessageCategory = MessageCategory:sub( 1, -2 ) .. ":\n" 
    end
  else
    self.MessageCategory = ""
  end

	self.MessageDuration = MessageDuration or 5
	self.MessageTime = timer.getTime()
	self.MessageText = MessageText:gsub("^\n","",1):gsub("\n$","",1)
	
	self.MessageSent = false
	self.MessageGroup = false
	self.MessageCoalition = false

	return self
end


--- Creates a new MESSAGE object of a certain type. 
-- Note that these MESSAGE objects are not yet displayed on the display panel. 
-- You must use the functions @{ToClient} or @{ToCoalition} or @{ToAll} to send these Messages to the respective recipients.
-- The message display times are automatically defined based on the timing settings in the @{Settings} menu.
-- @param self
-- @param #string MessageText is the text of the Message.
-- @param #MESSAGE.Type MessageType The type of the message.
-- @return #MESSAGE
-- @usage
--   MessageAll = MESSAGE:NewType( "To all Players: BLUE has won! Each player of BLUE wins 50 points!", MESSAGE.Type.Information )
--   MessageRED = MESSAGE:NewType( "To the RED Players: You receive a penalty because you've killed one of your own units", MESSAGE.Type.Information )
--   MessageClient1 = MESSAGE:NewType( "Congratulations, you've just hit a target", MESSAGE.Type.Update )
--   MessageClient2 = MESSAGE:NewType( "Congratulations, you've just killed a target", MESSAGE.Type.Update )
function MESSAGE:NewType( MessageText, MessageType )

  local self = BASE:Inherit( self, BASE:New() )
  self:F( { MessageText } )
  
  self.MessageType = MessageType

  self.MessageTime = timer.getTime()
  self.MessageText = MessageText:gsub("^\n","",1):gsub("\n$","",1)
  
  return self
end





--- Sends a MESSAGE to a Client Group. Note that the Group needs to be defined within the ME with the skillset "Client" or "Player".
-- @param #MESSAGE self
-- @param Wrapper.Client#CLIENT Client is the Group of the Client.
-- @return #MESSAGE
-- @usage
-- -- Send the 2 messages created with the @{New} method to the Client Group.
-- -- Note that the Message of MessageClient2 is overwriting the Message of MessageClient1.
-- ClientGroup = Group.getByName( "ClientGroup" )
--
-- MessageClient1 = MESSAGE:New( "Congratulations, you've just hit a target", "Score", 25, "Score" ):ToClient( ClientGroup )
-- MessageClient2 = MESSAGE:New( "Congratulations, you've just killed a target", "Score", 25, "Score" ):ToClient( ClientGroup )
-- or
-- MESSAGE:New( "Congratulations, you've just hit a target", "Score", 25, "Score" ):ToClient( ClientGroup )
-- MESSAGE:New( "Congratulations, you've just killed a target", "Score", 25, "Score" ):ToClient( ClientGroup )
-- or
-- MessageClient1 = MESSAGE:New( "Congratulations, you've just hit a target", "Score", 25, "Score" )
-- MessageClient2 = MESSAGE:New( "Congratulations, you've just killed a target", "Score", 25, "Score" )
-- MessageClient1:ToClient( ClientGroup )
-- MessageClient2:ToClient( ClientGroup )
function MESSAGE:ToClient( Client, Settings )
	self:F( Client )

	if Client and Client:GetClientGroupID() then

    if self.MessageType then
      local Settings = Settings or ( Client and _DATABASE:GetPlayerSettings( Client:GetPlayerName() ) ) or _SETTINGS -- Core.Settings#SETTINGS
      self.MessageDuration = Settings:GetMessageTime( self.MessageType )
      self.MessageCategory = "" -- self.MessageType .. ": "
    end

    if self.MessageDuration ~= 0 then
  		local ClientGroupID = Client:GetClientGroupID()
  		self:T( self.MessageCategory .. self.MessageText:gsub("\n$",""):gsub("\n$","") .. " / " .. self.MessageDuration )
  		trigger.action.outTextForGroup( ClientGroupID, self.MessageCategory .. self.MessageText:gsub("\n$",""):gsub("\n$",""), self.MessageDuration )
		end
	end
	
	return self
end

--- Sends a MESSAGE to a Group. 
-- @param #MESSAGE self
-- @param Wrapper.Group#GROUP Group is the Group.
-- @return #MESSAGE
function MESSAGE:ToGroup( Group, Settings )
  self:F( Group.GroupName )

  if Group then
    
    if self.MessageType then
      local Settings = Settings or ( Group and _DATABASE:GetPlayerSettings( Group:GetPlayerName() ) ) or _SETTINGS -- Core.Settings#SETTINGS
      self.MessageDuration = Settings:GetMessageTime( self.MessageType )
      self.MessageCategory = "" -- self.MessageType .. ": "
    end

    if self.MessageDuration ~= 0 then
      self:T( self.MessageCategory .. self.MessageText:gsub("\n$",""):gsub("\n$","") .. " / " .. self.MessageDuration )
      trigger.action.outTextForGroup( Group:GetID(), self.MessageCategory .. self.MessageText:gsub("\n$",""):gsub("\n$",""), self.MessageDuration )
    end
  end
  
  return self
end
--- Sends a MESSAGE to the Blue coalition.
-- @param #MESSAGE self 
-- @return #MESSAGE
-- @usage
-- -- Send a message created with the @{New} method to the BLUE coalition.
-- MessageBLUE = MESSAGE:New( "To the BLUE Players: You receive a penalty because you've killed one of your own units", "Penalty", 25, "Score" ):ToBlue()
-- or
-- MESSAGE:New( "To the BLUE Players: You receive a penalty because you've killed one of your own units", "Penalty", 25, "Score" ):ToBlue()
-- or
-- MessageBLUE = MESSAGE:New( "To the BLUE Players: You receive a penalty because you've killed one of your own units", "Penalty", 25, "Score" )
-- MessageBLUE:ToBlue()
function MESSAGE:ToBlue()
	self:F()

	self:ToCoalition( coalition.side.BLUE )
	
	return self
end

--- Sends a MESSAGE to the Red Coalition. 
-- @param #MESSAGE self
-- @return #MESSAGE
-- @usage
-- -- Send a message created with the @{New} method to the RED coalition.
-- MessageRED = MESSAGE:New( "To the RED Players: You receive a penalty because you've killed one of your own units", "Penalty", 25, "Score" ):ToRed()
-- or
-- MESSAGE:New( "To the RED Players: You receive a penalty because you've killed one of your own units", "Penalty", 25, "Score" ):ToRed()
-- or
-- MessageRED = MESSAGE:New( "To the RED Players: You receive a penalty because you've killed one of your own units", "Penalty", 25, "Score" )
-- MessageRED:ToRed()
function MESSAGE:ToRed( )
	self:F()

	self:ToCoalition( coalition.side.RED )
	
	return self
end

--- Sends a MESSAGE to a Coalition. 
-- @param #MESSAGE self
-- @param CoalitionSide needs to be filled out by the defined structure of the standard scripting engine @{coalition.side}. 
-- @return #MESSAGE
-- @usage
-- -- Send a message created with the @{New} method to the RED coalition.
-- MessageRED = MESSAGE:New( "To the RED Players: You receive a penalty because you've killed one of your own units", "Penalty", 25, "Score" ):ToCoalition( coalition.side.RED )
-- or
-- MESSAGE:New( "To the RED Players: You receive a penalty because you've killed one of your own units", "Penalty", 25, "Score" ):ToCoalition( coalition.side.RED )
-- or
-- MessageRED = MESSAGE:New( "To the RED Players: You receive a penalty because you've killed one of your own units", "Penalty", 25, "Score" )
-- MessageRED:ToCoalition( coalition.side.RED )
function MESSAGE:ToCoalition( CoalitionSide, Settings )
	self:F( CoalitionSide )

  if self.MessageType then
    local Settings = Settings or _SETTINGS -- Core.Settings#SETTINGS
    self.MessageDuration = Settings:GetMessageTime( self.MessageType )
    self.MessageCategory = "" -- self.MessageType .. ": "
  end

	if CoalitionSide then
    if self.MessageDuration ~= 0 then
  		self:T( self.MessageCategory .. self.MessageText:gsub("\n$",""):gsub("\n$","") .. " / " .. self.MessageDuration )
  		trigger.action.outTextForCoalition( CoalitionSide, self.MessageText:gsub("\n$",""):gsub("\n$",""), self.MessageDuration )
    end
	end
	
	return self
end

--- Sends a MESSAGE to a Coalition if the given Condition is true. 
-- @param #MESSAGE self
-- @param CoalitionSide needs to be filled out by the defined structure of the standard scripting engine @{coalition.side}. 
-- @return #MESSAGE
function MESSAGE:ToCoalitionIf( CoalitionSide, Condition )
  self:F( CoalitionSide )

  if Condition and Condition == true then
    self:ToCoalition( CoalitionSide )
  end
  
  return self
end

--- Sends a MESSAGE to all players. 
-- @param #MESSAGE self
-- @return #MESSAGE
-- @usage
-- -- Send a message created to all players.
-- MessageAll = MESSAGE:New( "To all Players: BLUE has won! Each player of BLUE wins 50 points!", "End of Mission", 25, "Win" ):ToAll()
-- or
-- MESSAGE:New( "To all Players: BLUE has won! Each player of BLUE wins 50 points!", "End of Mission", 25, "Win" ):ToAll()
-- or
-- MessageAll = MESSAGE:New( "To all Players: BLUE has won! Each player of BLUE wins 50 points!", "End of Mission", 25, "Win" )
-- MessageAll:ToAll()
function MESSAGE:ToAll()
  self:F()

  if self.MessageType then
    local Settings = Settings or _SETTINGS -- Core.Settings#SETTINGS
    self.MessageDuration = Settings:GetMessageTime( self.MessageType )
    self.MessageCategory = "" -- self.MessageType .. ": "
  end

  if self.MessageDuration ~= 0 then
    self:T( self.MessageCategory .. self.MessageText:gsub("\n$",""):gsub("\n$","") .. " / " .. self.MessageDuration )
    trigger.action.outText( self.MessageCategory .. self.MessageText:gsub("\n$",""):gsub("\n$",""), self.MessageDuration )
  end

  return self
end


--- Sends a MESSAGE to all players if the given Condition is true.
-- @param #MESSAGE self
-- @return #MESSAGE
function MESSAGE:ToAllIf( Condition )

  if Condition and Condition == true then
    self:ToAll()
  end

	return self
end
--- **Core** -- The **FSM** (**F**inite **S**tate **M**achine) class and derived **FSM\_** classes 
-- are design patterns allowing efficient (long-lasting) processes and workflows.
-- 
-- ![Banner Image](..\Presentations\FSM\Dia1.JPG)
-- 
-- ===
-- 
-- A Finite State Machine (FSM) models a process flow that transitions between various **States** through triggered **Events**.
-- 
-- A FSM can only be in one of a finite number of states. 
-- The machine is in only one state at a time; the state it is in at any given time is called the **current state**. 
-- It can change from one state to another when initiated by an **__internal__ or __external__ triggering event**, which is called a **transition**. 
-- An **FSM implementation** is defined by **a list of its states**, **its initial state**, and **the triggering events** for **each possible transition**.
-- An FSM implementation is composed out of **two parts**, a set of **state transition rules**, and an implementation set of **state transition handlers**, implementing those transitions.
-- 
-- The FSM class supports a **hierarchical implementation of a Finite State Machine**, 
-- that is, it allows to **embed existing FSM implementations in a master FSM**.
-- FSM hierarchies allow for efficient FSM re-use, **not having to re-invent the wheel every time again** when designing complex processes.
-- 
-- ![Workflow Example](..\Presentations\FSM\Dia2.JPG)
-- 
-- The above diagram shows a graphical representation of a FSM implementation for a **Task**, which guides a Human towards a Zone,
-- orders him to destroy x targets and account the results.
-- Other examples of ready made FSM could be: 
-- 
--   * route a plane to a zone flown by a human
--   * detect targets by an AI and report to humans
--   * account for destroyed targets by human players
--   * handle AI infantry to deploy from or embark to a helicopter or airplane or vehicle 
--   * let an AI patrol a zone
-- 
-- The **MOOSE framework** uses extensively the FSM class and derived FSM\_ classes, 
-- because **the goal of MOOSE is to simplify mission design complexity for mission building**.
-- By efficiently utilizing the FSM class and derived classes, MOOSE allows mission designers to quickly build processes.
-- **Ready made FSM-based implementations classes** exist within the MOOSE framework that **can easily be re-used, 
-- and tailored** by mission designers through **the implementation of Transition Handlers**.
-- Each of these FSM implementation classes start either with:
-- 
--   * an acronym **AI\_**, which indicates an FSM implementation directing **AI controlled** @{GROUP} and/or @{UNIT}. These AI\_ classes derive the @{#FSM_CONTROLLABLE} class.
--   * an acronym **TASK\_**, which indicates an FSM implementation executing a @{TASK} executed by Groups of players. These TASK\_ classes derive the @{#FSM_TASK} class.
--   * an acronym **ACT\_**, which indicates an Sub-FSM implementation, directing **Humans actions** that need to be done in a @{TASK}, seated in a @{CLIENT} (slot) or a @{UNIT} (CA join). These ACT\_ classes derive the @{#FSM_PROCESS} class.
-- 
-- Detailed explanations and API specifics are further below clarified and FSM derived class specifics are described in those class documentation sections.
-- 
-- ##__Dislaimer:__
-- The FSM class development is based on a finite state machine implementation made by Conroy Kyle.
-- The state machine can be found on [github](https://github.com/kyleconroy/lua-state-machine)
-- I've reworked this development (taken the concept), and created a **hierarchical state machine** out of it, embedded within the DCS simulator.
-- Additionally, I've added extendability and created an API that allows seamless FSM implementation.
-- 
-- The following derived classes are available in the MOOSE framework, that implement a specialised form of a FSM:
-- 
--   * @{#FSM_TASK}: Models Finite State Machines for @{Task}s.
--   * @{#FSM_PROCESS}: Models Finite State Machines for @{Task} actions, which control @{Client}s.
--   * @{#FSM_CONTROLLABLE}: Models Finite State Machines for @{Controllable}s, which are @{Group}s, @{Unit}s, @{Client}s.
--   * @{#FSM_SET}: Models Finite State Machines for @{Set}s. Note that these FSMs control multiple objects!!! So State concerns here
--     for multiple objects or the position of the state machine in the process.
-- 
-- ====
-- 
-- 
-- ### Author: **Sven Van de Velde (FlightControl)**
-- ### Contributions: 
-- 
-- ====
--
-- @module Fsm

do -- FSM

  --- @type FSM
  -- @extends Core.Base#BASE
  
  
  --- # FSM class, extends @{Base#BASE}
  --
  -- A Finite State Machine (FSM) models a process flow that transitions between various **States** through triggered **Events**.
  -- 
  -- A FSM can only be in one of a finite number of states. 
  -- The machine is in only one state at a time; the state it is in at any given time is called the **current state**. 
  -- It can change from one state to another when initiated by an **__internal__ or __external__ triggering event**, which is called a **transition**. 
  -- An **FSM implementation** is defined by **a list of its states**, **its initial state**, and **the triggering events** for **each possible transition**.
  -- An FSM implementation is composed out of **two parts**, a set of **state transition rules**, and an implementation set of **state transition handlers**, implementing those transitions.
  -- 
  -- The FSM class supports a **hierarchical implementation of a Finite State Machine**, 
  -- that is, it allows to **embed existing FSM implementations in a master FSM**.
  -- FSM hierarchies allow for efficient FSM re-use, **not having to re-invent the wheel every time again** when designing complex processes.
  -- 
  -- ![Workflow Example](..\Presentations\FSM\Dia2.JPG)
  -- 
  -- The above diagram shows a graphical representation of a FSM implementation for a **Task**, which guides a Human towards a Zone,
  -- orders him to destroy x targets and account the results.
  -- Other examples of ready made FSM could be: 
  -- 
  --   * route a plane to a zone flown by a human
  --   * detect targets by an AI and report to humans
  --   * account for destroyed targets by human players
  --   * handle AI infantry to deploy from or embark to a helicopter or airplane or vehicle 
  --   * let an AI patrol a zone
  -- 
  -- The **MOOSE framework** uses extensively the FSM class and derived FSM\_ classes, 
  -- because **the goal of MOOSE is to simplify mission design complexity for mission building**.
  -- By efficiently utilizing the FSM class and derived classes, MOOSE allows mission designers to quickly build processes.
  -- **Ready made FSM-based implementations classes** exist within the MOOSE framework that **can easily be re-used, 
  -- and tailored** by mission designers through **the implementation of Transition Handlers**.
  -- Each of these FSM implementation classes start either with:
  -- 
  --   * an acronym **AI\_**, which indicates an FSM implementation directing **AI controlled** @{GROUP} and/or @{UNIT}. These AI\_ classes derive the @{#FSM_CONTROLLABLE} class.
  --   * an acronym **TASK\_**, which indicates an FSM implementation executing a @{TASK} executed by Groups of players. These TASK\_ classes derive the @{#FSM_TASK} class.
  --   * an acronym **ACT\_**, which indicates an Sub-FSM implementation, directing **Humans actions** that need to be done in a @{TASK}, seated in a @{CLIENT} (slot) or a @{UNIT} (CA join). These ACT\_ classes derive the @{#FSM_PROCESS} class.
  -- 
  -- ![Transition Rules and Transition Handlers and Event Triggers](..\Presentations\FSM\Dia3.JPG)
  -- 
  -- The FSM class is the base class of all FSM\_ derived classes. It implements the main functionality to define and execute Finite State Machines.
  -- The derived FSM\_ classes extend the Finite State Machine functionality to run a workflow process for a specific purpose or component.
  -- 
  -- Finite State Machines have **Transition Rules**, **Transition Handlers** and **Event Triggers**.
  -- 
  -- The **Transition Rules** define the "Process Flow Boundaries", that is, 
  -- the path that can be followed hopping from state to state upon triggered events.
  -- If an event is triggered, and there is no valid path found for that event, 
  -- an error will be raised and the FSM will stop functioning.
  -- 
  -- The **Transition Handlers** are special methods that can be defined by the mission designer, following a defined syntax.
  -- If the FSM object finds a method of such a handler, then the method will be called by the FSM, passing specific parameters.
  -- The method can then define its own custom logic to implement the FSM workflow, and to conduct other actions.
  -- 
  -- The **Event Triggers** are methods that are defined by the FSM, which the mission designer can use to implement the workflow.
  -- Most of the time, these Event Triggers are used within the Transition Handler methods, so that a workflow is created running through the state machine.
  -- 
  -- As explained above, a FSM supports **Linear State Transitions** and **Hierarchical State Transitions**, and both can be mixed to make a comprehensive FSM implementation.
  -- The below documentation has a seperate chapter explaining both transition modes, taking into account the **Transition Rules**, **Transition Handlers** and **Event Triggers**.
  -- 
  -- ## FSM Linear Transitions
  -- 
  -- Linear Transitions are Transition Rules allowing an FSM to transition from one or multiple possible **From** state(s) towards a **To** state upon a Triggered **Event**.
  -- The Lineair transition rule evaluation will always be done from the **current state** of the FSM.
  -- If no valid Transition Rule can be found in the FSM, the FSM will log an error and stop.
  -- 
  -- ### FSM Transition Rules
  -- 
  -- The FSM has transition rules that it follows and validates, as it walks the process. 
  -- These rules define when an FSM can transition from a specific state towards an other specific state upon a triggered event.
  -- 
  -- The method @{#FSM.AddTransition}() specifies a new possible Transition Rule for the FSM. 
  -- 
  -- The initial state can be defined using the method @{#FSM.SetStartState}(). The default start state of an FSM is "None".
  -- 
  -- Find below an example of a Linear Transition Rule definition for an FSM.
  -- 
  --      local Fsm3Switch = FSM:New() -- #FsmDemo
  --      FsmSwitch:SetStartState( "Off" )
  --      FsmSwitch:AddTransition( "Off", "SwitchOn", "On" )
  --      FsmSwitch:AddTransition( "Off", "SwitchMiddle", "Middle" )
  --      FsmSwitch:AddTransition( "On", "SwitchOff", "Off" )
  --      FsmSwitch:AddTransition( "Middle", "SwitchOff", "Off" )
  -- 
  -- The above code snippet models a 3-way switch Linear Transition:
  -- 
  --    * It can be switched **On** by triggering event **SwitchOn**.
  --    * It can be switched to the **Middle** position, by triggering event **SwitchMiddle**.
  --    * It can be switched **Off** by triggering event **SwitchOff**.
  --    * Note that once the Switch is **On** or **Middle**, it can only be switched **Off**.
  -- 
  -- #### Some additional comments:
  -- 
  -- Note that Linear Transition Rules **can be declared in a few variations**:
  -- 
  --    * The From states can be **a table of strings**, indicating that the transition rule will be valid **if the current state** of the FSM will be **one of the given From states**.
  --    * The From state can be a **"*"**, indicating that **the transition rule will always be valid**, regardless of the current state of the FSM.
  --   
  -- The below code snippet shows how the two last lines can be rewritten and consensed.
  -- 
  --      FsmSwitch:AddTransition( { "On",  "Middle" }, "SwitchOff", "Off" )
  -- 
  -- ### Transition Handling
  -- 
  -- ![Transition Handlers](..\Presentations\FSM\Dia4.JPG)
  -- 
  -- An FSM transitions in **4 moments** when an Event is being triggered and processed.  
  -- The mission designer can define for each moment specific logic within methods implementations following a defined API syntax.  
  -- These methods define the flow of the FSM process; because in those methods the FSM Internal Events will be triggered.
  --
  --    * To handle **State** transition moments, create methods starting with OnLeave or OnEnter concatenated with the State name.
  --    * To handle **Event** transition moments, create methods starting with OnBefore or OnAfter concatenated with the Event name.
  -- 
  -- **The OnLeave and OnBefore transition methods may return false, which will cancel the transition!**
  -- 
  -- Transition Handler methods need to follow the above specified naming convention, but are also passed parameters from the FSM.
  -- These parameters are on the correct order: From, Event, To:
  -- 
  --    * From = A string containing the From state.
  --    * Event = A string containing the Event name that was triggered.
  --    * To = A string containing the To state.
  -- 
  -- On top, each of these methods can have a variable amount of parameters passed. See the example in section [1.1.3](#1.1.3\)-event-triggers).
  -- 
  -- ### Event Triggers
  -- 
  -- ![Event Triggers](..\Presentations\FSM\Dia5.JPG)
  -- 
  -- The FSM creates for each Event two **Event Trigger methods**.  
  -- There are two modes how Events can be triggered, which is **synchronous** and **asynchronous**:
  -- 
  --    * The method **FSM:Event()** triggers an Event that will be processed **synchronously** or **immediately**.
  --    * The method **FSM:__Event( __seconds__ )** triggers an Event that will be processed **asynchronously** over time, waiting __x seconds__.
  -- 
  -- The destinction between these 2 Event Trigger methods are important to understand. An asynchronous call will "log" the Event Trigger to be executed at a later time.
  -- Processing will just continue. Synchronous Event Trigger methods are useful to change states of the FSM immediately, but may have a larger processing impact.
  -- 
  -- The following example provides a little demonstration on the difference between synchronous and asynchronous Event Triggering.
  -- 
  --       function FSM:OnAfterEvent( From, Event, To, Amount )
  --         self:T( { Amount = Amount } ) 
  --       end
  --       
  --       local Amount = 1
  --       FSM:__Event( 5, Amount ) 
  --       
  --       Amount = Amount + 1
  --       FSM:Event( Text, Amount )
  --       
  -- In this example, the **:OnAfterEvent**() Transition Handler implementation will get called when **Event** is being triggered.
  -- Before we go into more detail, let's look at the last 4 lines of the example. 
  -- The last line triggers synchronously the **Event**, and passes Amount as a parameter.
  -- The 3rd last line of the example triggers asynchronously **Event**. 
  -- Event will be processed after 5 seconds, and Amount is given as a parameter.
  -- 
  -- The output of this little code fragment will be:
  -- 
  --    * Amount = 2
  --    * Amount = 2
  -- 
  -- Because ... When Event was asynchronously processed after 5 seconds, Amount was set to 2. So be careful when processing and passing values and objects in asynchronous processing!
  -- 
  -- ### Linear Transition Example
  -- 
  -- This example is fully implemented in the MOOSE test mission on GITHUB: [FSM-100 - Transition Explanation](https://github.com/FlightControl-Master/MOOSE/blob/master/Moose%20Test%20Missions/FSM%20-%20Finite%20State%20Machine/FSM-100%20-%20Transition%20Explanation/FSM-100%20-%20Transition%20Explanation.lua)
  -- 
  -- It models a unit standing still near Batumi, and flaring every 5 seconds while switching between a Green flare and a Red flare.
  -- The purpose of this example is not to show how exciting flaring is, but it demonstrates how a Linear Transition FSM can be build.
  -- Have a look at the source code. The source code is also further explained below in this section.
  -- 
  -- The example creates a new FsmDemo object from class FSM.
  -- It will set the start state of FsmDemo to state **Green**.
  -- Two Linear Transition Rules are created, where upon the event **Switch**,
  -- the FsmDemo will transition from state **Green** to **Red** and from **Red** back to **Green**.
  -- 
  -- ![Transition Example](..\Presentations\FSM\Dia6.JPG)
  -- 
  --      local FsmDemo = FSM:New() -- #FsmDemo
  --      FsmDemo:SetStartState( "Green" )
  --      FsmDemo:AddTransition( "Green", "Switch", "Red" )
  --      FsmDemo:AddTransition( "Red", "Switch", "Green" )
  -- 
  -- In the above example, the FsmDemo could flare every 5 seconds a Green or a Red flare into the air.
  -- The next code implements this through the event handling method **OnAfterSwitch**.
  -- 
  -- ![Transition Flow](..\Presentations\FSM\Dia7.JPG)
  -- 
  --      function FsmDemo:OnAfterSwitch( From, Event, To, FsmUnit )
  --        self:T( { From, Event, To, FsmUnit } )
  --        
  --        if From == "Green" then
  --          FsmUnit:Flare(FLARECOLOR.Green)
  --        else
  --          if From == "Red" then
  --            FsmUnit:Flare(FLARECOLOR.Red)
  --          end
  --        end
  --        self:__Switch( 5, FsmUnit ) -- Trigger the next Switch event to happen in 5 seconds.
  --      end
  --      
  --      FsmDemo:__Switch( 5, FsmUnit ) -- Trigger the first Switch event to happen in 5 seconds.
  -- 
  -- The OnAfterSwitch implements a loop. The last line of the code fragment triggers the Switch Event within 5 seconds.
  -- Upon the event execution (after 5 seconds), the OnAfterSwitch method is called of FsmDemo (cfr. the double point notation!!! ":").
  -- The OnAfterSwitch method receives from the FSM the 3 transition parameter details ( From, Event, To ), 
  -- and one additional parameter that was given when the event was triggered, which is in this case the Unit that is used within OnSwitchAfter.
  -- 
  --      function FsmDemo:OnAfterSwitch( From, Event, To, FsmUnit )
  -- 
  -- For debugging reasons the received parameters are traced within the DCS.log.
  -- 
  --         self:T( { From, Event, To, FsmUnit } )
  -- 
  -- The method will check if the From state received is either "Green" or "Red" and will flare the respective color from the FsmUnit.
  -- 
  --        if From == "Green" then
  --          FsmUnit:Flare(FLARECOLOR.Green)
  --        else
  --          if From == "Red" then
  --            FsmUnit:Flare(FLARECOLOR.Red)
  --          end
  --        end
  -- 
  -- It is important that the Switch event is again triggered, otherwise, the FsmDemo would stop working after having the first Event being handled.
  -- 
  --        FsmDemo:__Switch( 5, FsmUnit ) -- Trigger the next Switch event to happen in 5 seconds.
  -- 
  -- The below code fragment extends the FsmDemo, demonstrating multiple **From states declared as a table**, adding a **Linear Transition Rule**.
  -- The new event **Stop** will cancel the Switching process.
  -- The transition for event Stop can be executed if the current state of the FSM is either "Red" or "Green".
  -- 
  --      local FsmDemo = FSM:New() -- #FsmDemo
  --      FsmDemo:SetStartState( "Green" )
  --      FsmDemo:AddTransition( "Green", "Switch", "Red" )
  --      FsmDemo:AddTransition( "Red", "Switch", "Green" )
  --      FsmDemo:AddTransition( { "Red", "Green" }, "Stop", "Stopped" )
  -- 
  -- The transition for event Stop can also be simplified, as any current state of the FSM is valid.
  -- 
  --      FsmDemo:AddTransition( "*", "Stop", "Stopped" )
  --      
  -- So... When FsmDemo:Stop() is being triggered, the state of FsmDemo will transition from Red or Green to Stopped.
  -- And there is no transition handling method defined for that transition, thus, no new event is being triggered causing the FsmDemo process flow to halt.
  -- 
  -- ## FSM Hierarchical Transitions
  -- 
  -- Hierarchical Transitions allow to re-use readily available and implemented FSMs.
  -- This becomes in very useful for mission building, where mission designers build complex processes and workflows, 
  -- combining smaller FSMs to one single FSM.
  -- 
  -- The FSM can embed **Sub-FSMs** that will execute and return **multiple possible Return (End) States**.  
  -- Depending upon **which state is returned**, the main FSM can continue the flow **triggering specific events**.
  -- 
  -- The method @{#FSM.AddProcess}() adds a new Sub-FSM to the FSM.  
  --
  -- ===
  -- 
  -- @field #FSM FSM
  -- 
  FSM = {
    ClassName = "FSM",
  }
  
  --- Creates a new FSM object.
  -- @param #FSM self
  -- @return #FSM
  function FSM:New( FsmT )
  
    -- Inherits from BASE
    self = BASE:Inherit( self, BASE:New() )
  
    self.options = options or {}
    self.options.subs = self.options.subs or {}
    self.current = self.options.initial or 'none'
    self.Events = {}
    self.subs = {}
    self.endstates = {}
    
    self.Scores = {}
    
    self._StartState = "none"
    self._Transitions = {}
    self._Processes = {}
    self._EndStates = {}
    self._Scores = {}
    self._EventSchedules = {}
    
    self.CallScheduler = SCHEDULER:New( self )
    
  
    return self
  end
  
  
  --- Sets the start state of the FSM.
  -- @param #FSM self
  -- @param #string State A string defining the start state.
  function FSM:SetStartState( State )
  
    self._StartState = State
    self.current = State
  end
  
  
  --- Returns the start state of the FSM.
  -- @param #FSM self
  -- @return #string A string containing the start state.
  function FSM:GetStartState()
  
    return self._StartState or {}
  end
  
  --- Add a new transition rule to the FSM.
  -- A transition rule defines when and if the FSM can transition from a state towards another state upon a triggered event.
  -- @param #FSM self
  -- @param #table From Can contain a string indicating the From state or a table of strings containing multiple From states.
  -- @param #string Event The Event name.
  -- @param #string To The To state.
  function FSM:AddTransition( From, Event, To )
  
    local Transition = {}
    Transition.From = From
    Transition.Event = Event
    Transition.To = To
  
    self:T2( Transition )
    
    self._Transitions[Transition] = Transition
    self:_eventmap( self.Events, Transition )
  end

  
  --- Returns a table of the transition rules defined within the FSM.
  -- @return #table
  function FSM:GetTransitions()
  
    return self._Transitions or {}
  end
  
  --- Set the default @{Process} template with key ProcessName providing the ProcessClass and the process object when it is assigned to a @{Controllable} by the task.
  -- @param #FSM self
  -- @param #table From Can contain a string indicating the From state or a table of strings containing multiple From states.
  -- @param #string Event The Event name.
  -- @param Core.Fsm#FSM_PROCESS Process An sub-process FSM.
  -- @param #table ReturnEvents A table indicating for which returned events of the SubFSM which Event must be triggered in the FSM.
  -- @return Core.Fsm#FSM_PROCESS The SubFSM.
  function FSM:AddProcess( From, Event, Process, ReturnEvents )
    self:T( { From, Event } )
  
    local Sub = {}
    Sub.From = From
    Sub.Event = Event
    Sub.fsm = Process
    Sub.StartEvent = "Start"
    Sub.ReturnEvents = ReturnEvents
    
    self._Processes[Sub] = Sub
    
    self:_submap( self.subs, Sub, nil )
    
    self:AddTransition( From, Event, From )
  
    return Process
  end
  
  
  --- Returns a table of the SubFSM rules defined within the FSM.
  -- @return #table
  function FSM:GetProcesses()
  
    return self._Processes or {}
  end
  
  function FSM:GetProcess( From, Event )
  
    for ProcessID, Process in pairs( self:GetProcesses() ) do
      if Process.From == From and Process.Event == Event then
        return Process.fsm
      end
    end
    
    error( "Sub-Process from state " .. From .. " with event " .. Event .. " not found!" )
  end
  
  --- Adds an End state.
  function FSM:AddEndState( State )
  
    self._EndStates[State] = State
    self.endstates[State] = State
  end
  
  --- Returns the End states.
  function FSM:GetEndStates()
  
    return self._EndStates or {}
  end
  
  
  --- Adds a score for the FSM to be achieved.
  -- @param #FSM self
  -- @param #string State is the state of the process when the score needs to be given. (See the relevant state descriptions of the process).
  -- @param #string ScoreText is a text describing the score that is given according the status.
  -- @param #number Score is a number providing the score of the status.
  -- @return #FSM self
  function FSM:AddScore( State, ScoreText, Score )
    self:F( { State, ScoreText, Score } )
  
    self._Scores[State] = self._Scores[State] or {}
    self._Scores[State].ScoreText = ScoreText
    self._Scores[State].Score = Score
  
    return self
  end
  
  --- Adds a score for the FSM_PROCESS to be achieved.
  -- @param #FSM self
  -- @param #string From is the From State of the main process.
  -- @param #string Event is the Event of the main process.
  -- @param #string State is the state of the process when the score needs to be given. (See the relevant state descriptions of the process).
  -- @param #string ScoreText is a text describing the score that is given according the status.
  -- @param #number Score is a number providing the score of the status.
  -- @return #FSM self
  function FSM:AddScoreProcess( From, Event, State, ScoreText, Score )
    self:F( { From, Event, State, ScoreText, Score } )
  
    local Process = self:GetProcess( From, Event )
    
    Process._Scores[State] = Process._Scores[State] or {}
    Process._Scores[State].ScoreText = ScoreText
    Process._Scores[State].Score = Score
    
    self:T( Process._Scores )
  
    return Process
  end
  
  --- Returns a table with the scores defined.
  function FSM:GetScores()
  
    return self._Scores or {}
  end
  
  --- Returns a table with the Subs defined.
  function FSM:GetSubs()
  
    return self.options.subs
  end
  
  
  function FSM:LoadCallBacks( CallBackTable )
  
    for name, callback in pairs( CallBackTable or {} ) do
      self[name] = callback
    end
  
  end
  
  function FSM:_eventmap( Events, EventStructure )
  
      local Event = EventStructure.Event
      local __Event = "__" .. EventStructure.Event
      self[Event] = self[Event] or self:_create_transition(Event)
      self[__Event] = self[__Event] or self:_delayed_transition(Event)
      self:T2( "Added methods: " .. Event .. ", " .. __Event )
      Events[Event] = self.Events[Event] or { map = {} }
      self:_add_to_map( Events[Event].map, EventStructure )
  
  end
  
  function FSM:_submap( subs, sub, name )
    --self:F( { sub = sub, name = name } )
    subs[sub.From] = subs[sub.From] or {}
    subs[sub.From][sub.Event] = subs[sub.From][sub.Event] or {}
    
    -- Make the reference table weak.
    -- setmetatable( subs[sub.From][sub.Event], { __mode = "k" } )
    
    subs[sub.From][sub.Event][sub] = {}
    subs[sub.From][sub.Event][sub].fsm = sub.fsm
    subs[sub.From][sub.Event][sub].StartEvent = sub.StartEvent
    subs[sub.From][sub.Event][sub].ReturnEvents = sub.ReturnEvents or {} -- these events need to be given to find the correct continue event ... if none given, the processing will stop.
    subs[sub.From][sub.Event][sub].name = name
    subs[sub.From][sub.Event][sub].fsmparent = self
  end
  
  
  function FSM:_call_handler( handler, params, EventName )

    local ErrorHandler = function( errmsg )
  
      env.info( "Error in SCHEDULER function:" .. errmsg )
      if debug ~= nil then
        env.info( debug.traceback() )
      end
      
      return errmsg
    end
    if self[handler] then
      self:T2( "Calling " .. handler )
      self._EventSchedules[EventName] = nil
      local Result, Value = xpcall( function() return self[handler]( self, unpack( params ) ) end, ErrorHandler )
      return Value
    end
  end
  
  function FSM._handler( self, EventName, ... )
  
    local Can, to = self:can( EventName )
  
    if to == "*" then
      to = self.current
    end
  
    if Can then
      local from = self.current
      local params = { from, EventName, to, ...  }

      if self.Controllable then
        self:T( "FSM Transition for " .. self.Controllable.ControllableName .. " :" .. self.current .. " --> " .. EventName .. " --> " .. to )
      else
        self:T( "FSM Transition:" .. self.current .. " --> " .. EventName .. " --> " .. to )
      end        
  
      if ( self:_call_handler("onbefore" .. EventName, params, EventName ) == false )
      or ( self:_call_handler("OnBefore" .. EventName, params, EventName ) == false )
      or ( self:_call_handler("onleave" .. from, params, EventName ) == false )
      or ( self:_call_handler("OnLeave" .. from, params, EventName ) == false ) then
        self:T( "Cancel Transition" )
        return false
      end
  
      self.current = to
  
      local execute = true
  
      local subtable = self:_gosub( from, EventName )
      for _, sub in pairs( subtable ) do
        --if sub.nextevent then
        --  self:F2( "nextevent = " .. sub.nextevent )
        --  self[sub.nextevent]( self )
        --end
        self:T( "calling sub start event: " .. sub.StartEvent )
        sub.fsm.fsmparent = self
        sub.fsm.ReturnEvents = sub.ReturnEvents
        sub.fsm[sub.StartEvent]( sub.fsm )
        execute = false
      end
  
      local fsmparent, Event = self:_isendstate( to )
      if fsmparent and Event then
        self:F2( { "end state: ", fsmparent, Event } )
        self:_call_handler("onenter" .. to, params, EventName )
        self:_call_handler("OnEnter" .. to, params, EventName )
        self:_call_handler("onafter" .. EventName, params, EventName )
        self:_call_handler("OnAfter" .. EventName, params, EventName )
        self:_call_handler("onstatechange", params, EventName )
        fsmparent[Event]( fsmparent )
        execute = false
      end
  
      if execute then
        -- only execute the call if the From state is not equal to the To state! Otherwise this function should never execute!
        --if from ~= to then
          self:_call_handler("onenter" .. to, params, EventName )
          self:_call_handler("OnEnter" .. to, params, EventName )
        --end
  
        self:_call_handler("onafter" .. EventName, params, EventName )
        self:_call_handler("OnAfter" .. EventName, params, EventName )
  
        self:_call_handler("onstatechange", params, EventName )
      end
    else
      self:T( "Cannot execute transition." )
      self:T( { From = self.current, Event = EventName, To = to, Can = Can } )
    end
  
    return nil
  end
  
  function FSM:_delayed_transition( EventName )
    return function( self, DelaySeconds, ... )
      self:T2( "Delayed Event: " .. EventName )
      local CallID = 0
      if DelaySeconds ~= nil then
        if DelaySeconds < 0 then -- Only call the event ONCE!
          DelaySeconds = math.abs( DelaySeconds )
          if not self._EventSchedules[EventName] then
            CallID = self.CallScheduler:Schedule( self, self._handler, { EventName, ... }, DelaySeconds or 1 )
            self._EventSchedules[EventName] = CallID
          else
            -- reschedule
          end
        else
          CallID = self.CallScheduler:Schedule( self, self._handler, { EventName, ... }, DelaySeconds or 1 )
        end
      else
        error( "FSM: An asynchronous event trigger requires a DelaySeconds parameter!!! This can be positive or negative! Sorry, but will not process this." )
      end
      self:T2( { CallID = CallID } )
    end
  end
  
  function FSM:_create_transition( EventName )
    return function( self, ... ) return self._handler( self,  EventName , ... ) end
  end
  
  function FSM:_gosub( ParentFrom, ParentEvent )
    local fsmtable = {}
    if self.subs[ParentFrom] and self.subs[ParentFrom][ParentEvent] then
      self:T( { ParentFrom, ParentEvent, self.subs[ParentFrom], self.subs[ParentFrom][ParentEvent] } )
      return self.subs[ParentFrom][ParentEvent]
    else
      return {}
    end
  end
  
  function FSM:_isendstate( Current )
    local FSMParent = self.fsmparent
    if FSMParent and self.endstates[Current] then
      self:T( { state = Current, endstates = self.endstates, endstate = self.endstates[Current] } )
      FSMParent.current = Current
      local ParentFrom = FSMParent.current
      self:T( ParentFrom )
      self:T( self.ReturnEvents )
      local Event = self.ReturnEvents[Current]
      self:T( { ParentFrom, Event, self.ReturnEvents } )
      if Event then
        return FSMParent, Event
      else
        self:T( { "Could not find parent event name for state ", ParentFrom } )
      end
    end
  
    return nil
  end
  
  function FSM:_add_to_map( Map, Event )
    self:F3( {  Map, Event } )
    if type(Event.From) == 'string' then
       Map[Event.From] = Event.To
    else
      for _, From in ipairs(Event.From) do
         Map[From] = Event.To
      end
    end
    self:T3( {  Map, Event } )
  end
  
  function FSM:GetState()
    return self.current
  end
  
  
  function FSM:Is( State )
    return self.current == State
  end
  
  function FSM:is(state)
    return self.current == state
  end
  
  function FSM:can(e)
    local Event = self.Events[e]
    self:F3( { self.current, Event } )
    local To = Event and Event.map[self.current] or Event.map['*']
    return To ~= nil, To
  end
  
  function FSM:cannot(e)
    return not self:can(e)
  end

end

do -- FSM_CONTROLLABLE

  --- @type FSM_CONTROLLABLE
  -- @field Wrapper.Controllable#CONTROLLABLE Controllable
  -- @extends Core.Fsm#FSM
  
  --- # FSM_CONTROLLABLE, extends @{#FSM}
  --
  -- FSM_CONTROLLABLE class models Finite State Machines for @{Controllable}s, which are @{Group}s, @{Unit}s, @{Client}s.
  -- 
  -- ===
  -- 
  -- @field #FSM_CONTROLLABLE FSM_CONTROLLABLE
  -- 
  FSM_CONTROLLABLE = {
    ClassName = "FSM_CONTROLLABLE",
  }
  
  --- Creates a new FSM_CONTROLLABLE object.
  -- @param #FSM_CONTROLLABLE self
  -- @param #table FSMT Finite State Machine Table
  -- @param Wrapper.Controllable#CONTROLLABLE Controllable (optional) The CONTROLLABLE object that the FSM_CONTROLLABLE governs.
  -- @return #FSM_CONTROLLABLE
  function FSM_CONTROLLABLE:New( FSMT, Controllable )
  
    -- Inherits from BASE
    local self = BASE:Inherit( self, FSM:New( FSMT ) ) -- Core.Fsm#FSM_CONTROLLABLE
  
    if Controllable then
      self:SetControllable( Controllable )
    end
  
    self:AddTransition( "*", "Stop", "Stopped" )
  
    --- OnBefore Transition Handler for Event Stop.
    -- @function [parent=#FSM_CONTROLLABLE] OnBeforeStop
    -- @param #FSM_CONTROLLABLE self
    -- @param Wrapper.Controllable#CONTROLLABLE Controllable The Controllable Object managed by the FSM.
    -- @param #string From The From State string.
    -- @param #string Event The Event string.
    -- @param #string To The To State string.
    -- @return #boolean Return false to cancel Transition.
    
    --- OnAfter Transition Handler for Event Stop.
    -- @function [parent=#FSM_CONTROLLABLE] OnAfterStop
    -- @param #FSM_CONTROLLABLE self
    -- @param Wrapper.Controllable#CONTROLLABLE Controllable The Controllable Object managed by the FSM.
    -- @param #string From The From State string.
    -- @param #string Event The Event string.
    -- @param #string To The To State string.
    	
    --- Synchronous Event Trigger for Event Stop.
    -- @function [parent=#FSM_CONTROLLABLE] Stop
    -- @param #FSM_CONTROLLABLE self
    
    --- Asynchronous Event Trigger for Event Stop.
    -- @function [parent=#FSM_CONTROLLABLE] __Stop
    -- @param #FSM_CONTROLLABLE self
    -- @param #number Delay The delay in seconds.  
      
    --- OnLeave Transition Handler for State Stopped.
    -- @function [parent=#FSM_CONTROLLABLE] OnLeaveStopped
    -- @param #FSM_CONTROLLABLE self
    -- @param Wrapper.Controllable#CONTROLLABLE Controllable The Controllable Object managed by the FSM.
    -- @param #string From The From State string.
    -- @param #string Event The Event string.
    -- @param #string To The To State string.
    -- @return #boolean Return false to cancel Transition.
    
    --- OnEnter Transition Handler for State Stopped.
    -- @function [parent=#FSM_CONTROLLABLE] OnEnterStopped
    -- @param #FSM_CONTROLLABLE self
    -- @param Wrapper.Controllable#CONTROLLABLE Controllable The Controllable Object managed by the FSM.
    -- @param #string From The From State string.
    -- @param #string Event The Event string.
    -- @param #string To The To State string.

    return self
  end

  --- OnAfter Transition Handler for Event Stop.
  -- @function [parent=#FSM_CONTROLLABLE] OnAfterStop
  -- @param #FSM_CONTROLLABLE self
  -- @param Wrapper.Controllable#CONTROLLABLE Controllable The Controllable Object managed by the FSM.
  -- @param #string From The From State string.
  -- @param #string Event The Event string.
  -- @param #string To The To State string.
  function FSM_CONTROLLABLE:OnAfterStop(Controllable,From,Event,To)  
    
    -- Clear all pending schedules
    self.CallScheduler:Clear()
  end
  
  --- Sets the CONTROLLABLE object that the FSM_CONTROLLABLE governs.
  -- @param #FSM_CONTROLLABLE self
  -- @param Wrapper.Controllable#CONTROLLABLE FSMControllable
  -- @return #FSM_CONTROLLABLE
  function FSM_CONTROLLABLE:SetControllable( FSMControllable )
    --self:F( FSMControllable:GetName() )
    self.Controllable = FSMControllable
  end
  
  --- Gets the CONTROLLABLE object that the FSM_CONTROLLABLE governs.
  -- @param #FSM_CONTROLLABLE self
  -- @return Wrapper.Controllable#CONTROLLABLE
  function FSM_CONTROLLABLE:GetControllable()
    return self.Controllable
  end
  
  function FSM_CONTROLLABLE:_call_handler( handler, params, EventName )
  
    local ErrorHandler = function( errmsg )
  
      env.info( "Error in SCHEDULER function:" .. errmsg )
      if debug ~= nil then
        env.info( debug.traceback() )
      end
      
      return errmsg
    end
  
    if self[handler] then
      self:F3( "Calling " .. handler )
      self._EventSchedules[EventName] = nil
      local Result, Value = xpcall( function() return self[handler]( self, self.Controllable, unpack( params ) ) end, ErrorHandler )
      return Value
      --return self[handler]( self, self.Controllable, unpack( params ) )
    end
  end
  
end

do -- FSM_PROCESS

  --- @type FSM_PROCESS
  -- @field Tasking.Task#TASK Task
  -- @extends Core.Fsm#FSM_CONTROLLABLE
  
  
  --- # FSM_PROCESS, extends @{#FSM}
  --
  -- FSM_PROCESS class models Finite State Machines for @{Task} actions, which control @{Client}s.
  -- 
  -- ===
  -- 
  -- @field #FSM_PROCESS FSM_PROCESS
  -- 
  FSM_PROCESS = {
    ClassName = "FSM_PROCESS",
  }
  
  --- Creates a new FSM_PROCESS object.
  -- @param #FSM_PROCESS self
  -- @return #FSM_PROCESS
  function FSM_PROCESS:New( Controllable, Task )
  
    local self = BASE:Inherit( self, FSM_CONTROLLABLE:New() ) -- Core.Fsm#FSM_PROCESS

    --self:F( Controllable )
  
    self:Assign( Controllable, Task )
  
    return self
  end
  
  function FSM_PROCESS:Init( FsmProcess )
    self:T( "No Initialisation" )
  end  

  function FSM_PROCESS:_call_handler( handler, params, EventName )
  
    local ErrorHandler = function( errmsg )
  
      env.info( "Error in FSM_PROCESS call handler:" .. errmsg )
      if debug ~= nil then
        env.info( debug.traceback() )
      end
      
      return errmsg
    end
  
    if self[handler] then
      self:F3( "Calling " .. handler )
      self._EventSchedules[EventName] = nil
      local Result, Value = xpcall( function() return self[handler]( self, self.Controllable, self.Task, unpack( params ) ) end, ErrorHandler )
      return Value
      --return self[handler]( self, self.Controllable, unpack( params ) )
    end
  end
  
  --- Creates a new FSM_PROCESS object based on this FSM_PROCESS.
  -- @param #FSM_PROCESS self
  -- @return #FSM_PROCESS
  function FSM_PROCESS:Copy( Controllable, Task )
    self:T( { self:GetClassNameAndID() } )

  
    local NewFsm = self:New( Controllable, Task ) -- Core.Fsm#FSM_PROCESS
  
    NewFsm:Assign( Controllable, Task )
  
    -- Polymorphic call to initialize the new FSM_PROCESS based on self FSM_PROCESS
    NewFsm:Init( self )
    
    -- Set Start State
    NewFsm:SetStartState( self:GetStartState() )
  
    -- Copy Transitions
    for TransitionID, Transition in pairs( self:GetTransitions() ) do
      NewFsm:AddTransition( Transition.From, Transition.Event, Transition.To )
    end
  
    -- Copy Processes
    for ProcessID, Process in pairs( self:GetProcesses() ) do
      --self:E( { Process:GetName() } )
      local FsmProcess = NewFsm:AddProcess( Process.From, Process.Event, Process.fsm:Copy( Controllable, Task ), Process.ReturnEvents )
    end
  
    -- Copy End States
    for EndStateID, EndState in pairs( self:GetEndStates() ) do
      self:T( EndState )
      NewFsm:AddEndState( EndState )
    end
    
    -- Copy the score tables
    for ScoreID, Score in pairs( self:GetScores() ) do
      self:T( Score )
      NewFsm:AddScore( ScoreID, Score.ScoreText, Score.Score )
    end
  
    return NewFsm
  end

  --- Removes an FSM_PROCESS object.
  -- @param #FSM_PROCESS self
  -- @return #FSM_PROCESS
  function FSM_PROCESS:Remove()
    self:F( { self:GetClassNameAndID() } )

    self:F( "Clearing Schedules" )
    self.CallScheduler:Clear()
    
    -- Copy Processes
    for ProcessID, Process in pairs( self:GetProcesses() ) do
      if Process.fsm then
        Process.fsm:Remove()
        Process.fsm = nil
      end
    end
    
    return self
  end
  
  --- Sets the task of the process.
  -- @param #FSM_PROCESS self
  -- @param Tasking.Task#TASK Task
  -- @return #FSM_PROCESS
  function FSM_PROCESS:SetTask( Task )
  
    self.Task = Task
  
    return self
  end
  
  --- Gets the task of the process.
  -- @param #FSM_PROCESS self
  -- @return Tasking.Task#TASK
  function FSM_PROCESS:GetTask()
  
    return self.Task
  end
  
  --- Gets the mission of the process.
  -- @param #FSM_PROCESS self
  -- @return Tasking.Mission#MISSION
  function FSM_PROCESS:GetMission()
  
    return self.Task.Mission
  end
  
  --- Gets the mission of the process.
  -- @param #FSM_PROCESS self
  -- @return Tasking.CommandCenter#COMMANDCENTER
  function FSM_PROCESS:GetCommandCenter()
  
    return self:GetTask():GetMission():GetCommandCenter()
  end
  
-- TODO: Need to check and fix that an FSM_PROCESS is only for a UNIT. Not for a GROUP.  
  
  --- Send a message of the @{Task} to the Group of the Unit.
-- @param #FSM_PROCESS self
function FSM_PROCESS:Message( Message )
  self:F( { Message = Message } )

  local CC = self:GetCommandCenter()
  local TaskGroup = self.Controllable:GetGroup()
  
  local PlayerName = self.Controllable:GetPlayerName() -- Only for a unit
  PlayerName = PlayerName and " (" .. PlayerName .. ")" or "" -- If PlayerName is nil, then keep it nil, otherwise add brackets.
  local Callsign = self.Controllable:GetCallsign()
  local Prefix = Callsign and " @ " .. Callsign .. PlayerName or ""
  
  Message = Prefix .. ": " .. Message
  CC:MessageToGroup( Message, TaskGroup )
end

  
  
  
  --- Assign the process to a @{Unit} and activate the process.
  -- @param #FSM_PROCESS self
  -- @param Task.Tasking#TASK Task
  -- @param Wrapper.Unit#UNIT ProcessUnit
  -- @return #FSM_PROCESS self
  function FSM_PROCESS:Assign( ProcessUnit, Task )
    --self:T( { Task:GetName(), ProcessUnit:GetName() } )
  
    self:SetControllable( ProcessUnit )
    self:SetTask( Task )
    
    --self.ProcessGroup = ProcessUnit:GetGroup()
  
    return self
  end
    
  function FSM_PROCESS:onenterAssigned( ProcessUnit )
    self:T( "Assign" )
  
    self.Task:Assign()
  end
  
  function FSM_PROCESS:onenterFailed( ProcessUnit )
    self:T( "Failed" )
  
    self.Task:Fail()
  end

  
  --- StateMachine callback function for a FSM_PROCESS
  -- @param #FSM_PROCESS self
  -- @param Wrapper.Controllable#CONTROLLABLE ProcessUnit
  -- @param #string Event
  -- @param #string From
  -- @param #string To
  function FSM_PROCESS:onstatechange( ProcessUnit, Task, From, Event, To, Dummy )
    self:T( { ProcessUnit:GetName(), From, Event, To, Dummy, self:IsTrace() } )
  
    if self:IsTrace() then
      --MESSAGE:New( "@ Process " .. self:GetClassNameAndID() .. " : " .. Event .. " changed to state " .. To, 2 ):ToAll()
    end
  
    self:T( { Scores = self._Scores, To = To } )
    -- TODO: This needs to be reworked with a callback functions allocated within Task, and set within the mission script from the Task Objects...
    if self._Scores[To] then
    
      local Task = self.Task  
      local Scoring = Task:GetScoring()
      if Scoring then
        Scoring:_AddMissionTaskScore( Task.Mission, ProcessUnit, self._Scores[To].ScoreText, self._Scores[To].Score )
      end
    end
  end

end

do -- FSM_TASK

  --- FSM_TASK class
  -- @type FSM_TASK
  -- @field Tasking.Task#TASK Task
  -- @extends #FSM
   
  --- # FSM_TASK, extends @{#FSM}
  --
  -- FSM_TASK class models Finite State Machines for @{Task}s.
  -- 
  -- ===
  -- 
  -- @field #FSM_TASK FSM_TASK
  --   
  FSM_TASK = {
    ClassName = "FSM_TASK",
  }
  
  --- Creates a new FSM_TASK object.
  -- @param #FSM_TASK self
  -- @param #table FSMT
  -- @param Tasking.Task#TASK Task
  -- @param Wrapper.Unit#UNIT TaskUnit
  -- @return #FSM_TASK
  function FSM_TASK:New( FSMT )
  
    local self = BASE:Inherit( self, FSM_CONTROLLABLE:New( FSMT ) ) -- Core.Fsm#FSM_TASK
  
    self["onstatechange"] = self.OnStateChange
  
    return self
  end
  
  function FSM_TASK:_call_handler( handler, params, EventName )
    if self[handler] then
      self:T( "Calling " .. handler )
      self._EventSchedules[EventName] = nil
      return self[handler]( self, unpack( params ) )
    end
  end

end -- FSM_TASK

do -- FSM_SET

  --- FSM_SET class
  -- @type FSM_SET
  -- @field Core.Set#SET_BASE Set
  -- @extends Core.Fsm#FSM


  --- # FSM_SET, extends @{#FSM}
  --
  -- FSM_SET class models Finite State Machines for @{Set}s. Note that these FSMs control multiple objects!!! So State concerns here
  -- for multiple objects or the position of the state machine in the process.
  -- 
  -- ===
  -- 
  -- @field #FSM_SET FSM_SET
  -- 
  FSM_SET = {
    ClassName = "FSM_SET",
  }
  
  --- Creates a new FSM_SET object.
  -- @param #FSM_SET self
  -- @param #table FSMT Finite State Machine Table
  -- @param Set_SET_BASE FSMSet (optional) The Set object that the FSM_SET governs.
  -- @return #FSM_SET
  function FSM_SET:New( FSMSet )
  
    -- Inherits from BASE
    self = BASE:Inherit( self, FSM:New() ) -- Core.Fsm#FSM_SET
  
    if FSMSet then
      self:Set( FSMSet )
    end
  
    return self
  end
  
  --- Sets the SET_BASE object that the FSM_SET governs.
  -- @param #FSM_SET self
  -- @param Core.Set#SET_BASE FSMSet
  -- @return #FSM_SET
  function FSM_SET:Set( FSMSet )
    self:F( FSMSet )
    self.Set = FSMSet
  end
  
  --- Gets the SET_BASE object that the FSM_SET governs.
  -- @param #FSM_SET self
  -- @return Core.Set#SET_BASE
  function FSM_SET:Get()
    return self.Controllable
  end
  
  function FSM_SET:_call_handler( handler, params, EventName  )
    if self[handler] then
      self:T( "Calling " .. handler )
      self._EventSchedules[EventName] = nil
      return self[handler]( self, self.Set, unpack( params ) )
    end
  end

end -- FSM_SET

--- **Core** -- The RADIO Module is responsible for everything that is related to radio transmission and you can hear in DCS, be it TACAN beacons, Radio transmissions...
-- 
-- ![Banner Image](..\Presentations\RADIO\Dia1.JPG)
-- 
-- ===
--
-- The Radio contains 2 classes : RADIO and BEACON
--  
-- What are radio communications in DCS ?
-- 
--   * Radio transmissions consist of **sound files** that are broadcasted on a specific **frequency** (e.g. 115MHz) and **modulation** (e.g. AM),
--   * They can be **subtitled** for a specific **duration**, the **power** in Watts of the transmiter's antenna can be set, and the transmission can be **looped**.
-- 
-- How to supply DCS my own Sound Files ?
--   
--   * Your sound files need to be encoded in **.ogg** or .wav,
--   * Your sound files should be **as tiny as possible**. It is suggested you encode in .ogg with low bitrate and sampling settings,
--   * They need to be added in .\l10n\DEFAULT\ in you .miz file (wich can be decompressed like a .zip file),
--   * For simplicty sake, you can **let DCS' Mission Editor add the file** itself, by creating a new Trigger with the action "Sound to Country", and choosing your sound file and a country you don't use in your mission.
--   
-- Due to weird DCS quirks, **radio communications behave differently** if sent by a @{Unit#UNIT} or a @{Group#GROUP} or by any other @{Positionable#POSITIONABLE}
-- 
--   * If the transmitter is a @{Unit#UNIT} or a @{Group#GROUP}, DCS will set the power of the transmission  automatically,
--   * If the transmitter is any other @{Positionable#POSITIONABLE}, the transmisison can't be subtitled or looped.
--   
-- Note that obviously, the **frequency** and the **modulation** of the transmission are important only if the players are piloting an **Advanced System Modelling** enabled aircraft,
-- like the A10C or the Mirage 2000C. They will **hear the transmission** if they are tuned on the **right frequency and modulation** (and if they are close enough - more on that below).
-- If a FC3 airacraft is used, it will **hear every communication, whatever the frequency and the modulation** is set to. The same is true for TACAN beacons. If your aircaft isn't compatible,
-- you won't hear/be able to use the TACAN beacon informations.
--
-- ===
--
-- ### Author: Hugues "Grey_Echo" Bousquet
--
-- @module Radio


--- # RADIO class, extends @{Base#BASE}
-- 
-- ## RADIO usage
-- 
-- There are 3 steps to a successful radio transmission.
-- 
--   * First, you need to **"add a @{#RADIO} object** to your @{Positionable#POSITIONABLE}. This is done using the @{Positionable#POSITIONABLE.GetRadio}() function,
--   * Then, you will **set the relevant parameters** to the transmission (see below),
--   * When done, you can actually **broadcast the transmission** (i.e. play the sound) with the @{RADIO.Broadcast}() function.
--   
-- Methods to set relevant parameters for both a @{Unit#UNIT} or a @{Group#GROUP} or any other @{Positionable#POSITIONABLE}
-- 
--   * @{#RADIO.SetFileName}() : Sets the file name of your sound file (e.g. "Noise.ogg"),
--   * @{#RADIO.SetFrequency}() : Sets the frequency of your transmission.
--   * @{#RADIO.SetModulation}() : Sets the modulation of your transmission.
--   * @{#RADIO.SetLoop}() : Choose if you want the transmission to be looped. If you need your transmission to be looped, you might need a @{#BEACON} instead...
-- 
-- Additional Methods to set relevant parameters if the transmiter is a @{Unit#UNIT} or a @{Group#GROUP}
-- 
--   * @{#RADIO.SetSubtitle}() : Set both the subtitle and its duration,
--   * @{#RADIO.NewUnitTransmission}() : Shortcut to set all the relevant parameters in one method call
-- 
-- Additional Methods to set relevant parameters if the transmiter is any other @{Positionable#POSITIONABLE}
-- 
--   * @{#RADIO.SetPower}() : Sets the power of the antenna in Watts
--   * @{#RADIO.NewGenericTransmission}() : Shortcut to set all the relevant parameters in one method call
-- 
-- What is this power thing ?
-- 
--   * If your transmission is sent by a @{Positionable#POSITIONABLE} other than a @{Unit#UNIT} or a @{Group#GROUP}, you can set the power of the antenna,
--   * Otherwise, DCS sets it automatically, depending on what's available on your Unit,
--   * If the player gets **too far** from the transmiter, or if the antenna is **too weak**, the transmission will **fade** and **become noisyer**,
--   * This an automated DCS calculation you have no say on,
--   * For reference, a standard VOR station has a 100W antenna, a standard AA TACAN has a 120W antenna, and civilian ATC's antenna usually range between 300 and 500W,
--   * Note that if the transmission has a subtitle, it will be readable, regardless of the quality of the transmission. 
--   
-- @type RADIO
-- @field Positionable#POSITIONABLE Positionable The transmiter
-- @field #string FileName Name of the sound file
-- @field #number Frequency Frequency of the transmission in Hz
-- @field #number Modulation Modulation of the transmission (either radio.modulation.AM or radio.modulation.FM)
-- @field #string Subtitle Subtitle of the transmission
-- @field #number SubtitleDuration Duration of the Subtitle in seconds
-- @field #number Power Power of the antenna is Watts
-- @field #boolean Loop (default true)
-- @extends Core.Base#BASE
RADIO = {
  ClassName = "RADIO",
  FileName = "",
  Frequency = 0,
  Modulation = radio.modulation.AM,
  Subtitle = "",
  SubtitleDuration = 0,
  Power = 100,
  Loop = true,
}

--- Create a new RADIO Object. This doesn't broadcast a transmission, though, use @{#RADIO.Broadcast} to actually broadcast
-- If you want to create a RADIO, you probably should use @{Positionable#POSITIONABLE.GetRadio}() instead
-- @param #RADIO self
-- @param Wrapper.Positionable#POSITIONABLE Positionable The @{Positionable} that will receive radio capabilities.
-- @return #RADIO Radio
-- @return #nil If Positionable is invalid
function RADIO:New(Positionable)
  local self = BASE:Inherit( self, BASE:New() ) -- Core.Radio#RADIO
  
  self.Loop = true        -- default Loop to true (not sure the above RADIO definition actually is working)
  self:F(Positionable)
  
  if Positionable:GetPointVec2() then -- It's stupid, but the only way I found to make sure positionable is valid
    self.Positionable = Positionable
    return self
  end
  
  self:E({"The passed positionable is invalid, no RADIO created", Positionable})
  return nil
end

--- Check validity of the filename passed and sets RADIO.FileName
-- @param #RADIO self
-- @param #string FileName File name of the sound file (i.e. "Noise.ogg")
-- @return #RADIO self
function RADIO:SetFileName(FileName)
  self:F2(FileName)
  
  if type(FileName) == "string" then
    if FileName:find(".ogg") or FileName:find(".wav") then
      if not FileName:find("l10n/DEFAULT/") then
        FileName = "l10n/DEFAULT/" .. FileName
      end
      self.FileName = FileName
      return self
    end
  end
  
  self:E({"File name invalid. Maybe something wrong with the extension ?", self.FileName})
  return self
end

--- Check validity of the frequency passed and sets RADIO.Frequency
-- @param #RADIO self
-- @param #number Frequency in MHz (Ranges allowed for radio transmissions in DCS : 30-88 / 108-152 / 225-400MHz)
-- @return #RADIO self
function RADIO:SetFrequency(Frequency)
  self:F2(Frequency)
  if type(Frequency) == "number" then
    -- If frequency is in range
    if (Frequency >= 30 and Frequency < 88) or (Frequency >= 108 and Frequency < 152) or (Frequency >= 225 and Frequency < 400) then
      self.Frequency = Frequency * 1000000 -- Conversion in Hz
      -- If the RADIO is attached to a UNIT or a GROUP, we need to send the DCS Command "SetFrequency" to change the UNIT or GROUP frequency
      if self.Positionable.ClassName == "UNIT" or self.Positionable.ClassName == "GROUP" then
        self.Positionable:SetCommand({
          id = "SetFrequency",
          params = {
            frequency = self.Frequency,
            modulation = self.Modulation,
          }
        })
      end
      return self
    end
  end
  self:E({"Frequency is outside of DCS Frequency ranges (30-80, 108-152, 225-400). Frequency unchanged.", self.Frequency})
  return self
end

--- Check validity of the frequency passed and sets RADIO.Modulation
-- @param #RADIO self
-- @param #number Modulation either radio.modulation.AM or radio.modulation.FM
-- @return #RADIO self
function RADIO:SetModulation(Modulation)
  self:F2(Modulation)
  if type(Modulation) == "number" then
    if Modulation == radio.modulation.AM or Modulation == radio.modulation.FM then --TODO Maybe make this future proof if ED decides to add an other modulation ?
      self.Modulation = Modulation
      return self
    end
  end
  self:E({"Modulation is invalid. Use DCS's enum radio.modulation. Modulation unchanged.", self.Modulation})
  return self
end

--- Check validity of the power passed and sets RADIO.Power
-- @param #RADIO self
-- @param #number Power in W
-- @return #RADIO self
function RADIO:SetPower(Power)
  self:F2(Power)
  if type(Power) == "number" then
    self.Power = math.floor(math.abs(Power)) --TODO Find what is the maximum power allowed by DCS and limit power to that
    return self
  end
  self:E({"Power is invalid. Power unchanged.", self.Power})
  return self
end

--- Check validity of the loop passed and sets RADIO.Loop
-- @param #RADIO self
-- @param #boolean Loop
-- @return #RADIO self
-- @usage
function RADIO:SetLoop(Loop)
  self:F2(Loop)
  if type(Loop) == "boolean" then
    self.Loop = Loop
    return self
  end
  self:E({"Loop is invalid. Loop unchanged.", self.Loop})
  return self
end

--- Check validity of the subtitle and the subtitleDuration  passed and sets RADIO.subtitle and RADIO.subtitleDuration
-- Both parameters are mandatory, since it wouldn't make much sense to change the Subtitle and not its duration
-- @param #RADIO self
-- @param #string Subtitle
-- @param #number SubtitleDuration in s
-- @return #RADIO self
-- @usage
-- -- create the broadcaster and attaches it a RADIO
-- local MyUnit = UNIT:FindByName("MyUnit")
-- local MyUnitRadio = MyUnit:GetRadio()
-- 
-- -- add a subtitle for the next transmission, which will be up for 10s
-- MyUnitRadio:SetSubtitle("My Subtitle, 10)
function RADIO:SetSubtitle(Subtitle, SubtitleDuration)
  self:F2({Subtitle, SubtitleDuration})
  if type(Subtitle) == "string" then
    self.Subtitle = Subtitle
  else
    self.Subtitle = ""
    self:E({"Subtitle is invalid. Subtitle reset.", self.Subtitle})
  end
  if type(SubtitleDuration) == "number" then
    if math.floor(math.abs(SubtitleDuration)) == SubtitleDuration then
      self.SubtitleDuration = SubtitleDuration
      return self
    end
  end
  self.SubtitleDuration = 0
  self:E({"SubtitleDuration is invalid. SubtitleDuration reset.", self.SubtitleDuration})
end

--- Create a new transmission, that is to say, populate the RADIO with relevant data
-- In this function the data is especially relevant if the broadcaster is anything but a UNIT or a GROUP,
-- but it will work with a UNIT or a GROUP anyway. 
-- Only the #RADIO and the Filename are mandatory
-- @param #RADIO self
-- @param #string FileName
-- @param #number Frequency in MHz
-- @param #number Modulation either radio.modulation.AM or radio.modulation.FM
-- @param #number Power in W
-- @return #RADIO self
function RADIO:NewGenericTransmission(FileName, Frequency, Modulation, Power, Loop)
  self:F({FileName, Frequency, Modulation, Power})
  
  self:SetFileName(FileName)
  if Frequency then self:SetFrequency(Frequency) end
  if Modulation then self:SetModulation(Modulation) end
  if Power then self:SetPower(Power) end
  if Loop then self:SetLoop(Loop) end
  
  return self
end


--- Create a new transmission, that is to say, populate the RADIO with relevant data
-- In this function the data is especially relevant if the broadcaster is a UNIT or a GROUP,
-- but it will work for any @{Positionable#POSITIONABLE}. 
-- Only the RADIO and the Filename are mandatory.
-- @param #RADIO self
-- @param #string FileName
-- @param #string Subtitle
-- @param #number SubtitleDuration in s
-- @param #number Frequency in MHz
-- @param #number Modulation either radio.modulation.AM or radio.modulation.FM
-- @param #boolean Loop
-- @return #RADIO self
function RADIO:NewUnitTransmission(FileName, Subtitle, SubtitleDuration, Frequency, Modulation, Loop)
  self:F({FileName, Subtitle, SubtitleDuration, Frequency, Modulation, Loop})

  self:SetFileName(FileName)
  if Subtitle then self:SetSubtitle(Subtitle) end
  if SubtitleDuration then self:SetSubtitleDuration(SubtitleDuration) end
  if Frequency then self:SetFrequency(Frequency) end
  if Modulation then self:SetModulation(Modulation) end
  if Loop then self:SetLoop(Loop) end
  
  return self
end

--- Actually Broadcast the transmission
-- * The Radio has to be populated with the new transmission before broadcasting.
-- * Please use RADIO setters or either @{Radio#RADIO.NewGenericTransmission} or @{Radio#RADIO.NewUnitTransmission}
-- * This class is in fact pretty smart, it determines the right DCS function to use depending on the type of POSITIONABLE
-- * If the POSITIONABLE is not a UNIT or a GROUP, we use the generic (but limited) trigger.action.radioTransmission()
-- * If the POSITIONABLE is a UNIT or a GROUP, we use the "TransmitMessage" Command
-- * If your POSITIONABLE is a UNIT or a GROUP, the Power is ignored.
-- * If your POSITIONABLE is not a UNIT or a GROUP, the Subtitle, SubtitleDuration are ignored
-- @param #RADIO self
-- @return #RADIO self
function RADIO:Broadcast()
  self:F()
  
  -- If the POSITIONABLE is actually a UNIT or a GROUP, use the more complicated DCS command system
  if self.Positionable.ClassName == "UNIT" or self.Positionable.ClassName == "GROUP" then
    self:T2("Broadcasting from a UNIT or a GROUP")
    self.Positionable:SetCommand({
      id = "TransmitMessage",
      params = {
        file = self.FileName,
        duration = self.SubtitleDuration,
        subtitle = self.Subtitle,
        loop = self.Loop,
      }
    })
  else
    -- If the POSITIONABLE is anything else, we revert to the general singleton function
    -- I need to give it a unique name, so that the transmission can be stopped later. I use the class ID
    self:T2("Broadcasting from a POSITIONABLE")
    trigger.action.radioTransmission(self.FileName, self.Positionable:GetPositionVec3(), self.Modulation, self.Loop, self.Frequency, self.Power, tostring(self.ID))
  end
  return self
end

--- Stops a transmission
-- This function is especially usefull to stop the broadcast of looped transmissions
-- @param #RADIO self
-- @return #RADIO self
function RADIO:StopBroadcast()
  self:F()
  -- If the POSITIONABLE is a UNIT or a GROUP, stop the transmission with the DCS "StopTransmission" command 
  if self.Positionable.ClassName == "UNIT" or self.Positionable.ClassName == "GROUP" then
    self.Positionable:SetCommand({
      id = "StopTransmission",
      params = {}
    })
  else
    -- Else, we use the appropriate singleton funciton
    trigger.action.stopRadioTransmission(tostring(self.ID))
  end
  return self
end


--- # BEACON class, extends @{Base#BASE}
-- 
-- After attaching a @{#BEACON} to your @{Positionable#POSITIONABLE}, you need to select the right function to activate the kind of beacon you want. 
-- There are two types of BEACONs available : the AA TACAN Beacon and the general purpose Radio Beacon.
-- Note that in both case, you can set an optional parameter : the `BeaconDuration`. This can be very usefull to simulate the battery time if your BEACON is
-- attach to a cargo crate, for exemple. 
-- 
-- ## AA TACAN Beacon usage
-- 
-- This beacon only works with airborne @{Unit#UNIT} or a @{Group#GROUP}. Use @{#BEACON:AATACAN}() to set the beacon parameters and start the beacon.
-- Use @#BEACON:StopAATACAN}() to stop it.
-- 
-- ## General Purpose Radio Beacon usage
-- 
-- This beacon will work with any @{Positionable#POSITIONABLE}, but **it won't follow the @{Positionable#POSITIONABLE}** ! This means that you should only use it with
-- @{Positionable#POSITIONABLE} that don't move, or move very slowly. Use @{#BEACON:RadioBeacon}() to set the beacon parameters and start the beacon.
-- Use @{#BEACON:StopRadioBeacon}() to stop it.
-- 
-- @type BEACON
-- @extends Core.Base#BASE
BEACON = {
  ClassName = "BEACON",
}

--- Create a new BEACON Object. This doesn't activate the beacon, though, use @{#BEACON.AATACAN} or @{#BEACON.Generic}
-- If you want to create a BEACON, you probably should use @{Positionable#POSITIONABLE.GetBeacon}() instead.
-- @param #BEACON self
-- @param Wrapper.Positionable#POSITIONABLE Positionable The @{Positionable} that will receive radio capabilities.
-- @return #BEACON Beacon
-- @return #nil If Positionable is invalid
function BEACON:New(Positionable)
  local self = BASE:Inherit(self, BASE:New())
  
  self:F(Positionable)
  
  if Positionable:GetPointVec2() then -- It's stupid, but the only way I found to make sure positionable is valid
    self.Positionable = Positionable
    return self
  end
  
  self:E({"The passed positionable is invalid, no BEACON created", Positionable})
  return nil
end


--- Converts a TACAN Channel/Mode couple into a frequency in Hz
-- @param #BEACON self
-- @param #number TACANChannel
-- @param #string TACANMode
-- @return #number Frequecy
-- @return #nil if parameters are invalid
function BEACON:_TACANToFrequency(TACANChannel, TACANMode)
  self:F3({TACANChannel, TACANMode})

  if type(TACANChannel) ~= "number" then
      if TACANMode ~= "X" and TACANMode ~= "Y" then
        return nil -- error in arguments
      end
  end
  
-- This code is largely based on ED's code, in DCS World\Scripts\World\Radio\BeaconTypes.lua, line 137.
-- I have no idea what it does but it seems to work
  local A = 1151 -- 'X', channel >= 64
  local B = 64   -- channel >= 64
  
  if TACANChannel < 64 then
    B = 1
  end
  
  if TACANMode == 'Y' then
    A = 1025
    if TACANChannel < 64 then
      A = 1088
    end
  else -- 'X'
    if TACANChannel < 64 then
      A = 962
    end
  end
  
  return (A + TACANChannel - B) * 1000000
end


--- Activates a TACAN BEACON on an Aircraft.
-- @param #BEACON self
-- @param #number TACANChannel (the "10" part in "10Y"). Note that AA TACAN are only available on Y Channels
-- @param #string Message The Message that is going to be coded in Morse and broadcasted by the beacon
-- @param #boolean Bearing Can the BEACON be homed on ?
-- @param #number BeaconDuration How long will the beacon last in seconds. Omit for forever.
-- @return #BEACON self
-- @usage
-- -- Let's create a TACAN Beacon for a tanker
-- local myUnit = UNIT:FindByName("MyUnit") 
-- local myBeacon = myUnit:GetBeacon() -- Creates the beacon
-- 
-- myBeacon:AATACAN(20, "TEXACO", true) -- Activate the beacon
function BEACON:AATACAN(TACANChannel, Message, Bearing, BeaconDuration)
  self:F({TACANChannel, Message, Bearing, BeaconDuration})
  
  local IsValid = true
  
  if not self.Positionable:IsAir() then
    self:E({"The POSITIONABLE you want to attach the AA Tacan Beacon is not an aircraft ! The BEACON is not emitting", self.Positionable})
    IsValid = false
  end
    
  local Frequency = self:_TACANToFrequency(TACANChannel, "Y")
  if not Frequency then 
    self:E({"The passed TACAN channel is invalid, the BEACON is not emitting"})
    IsValid = false
  end
  
  -- I'm using the beacon type 4 (BEACON_TYPE_TACAN). For System, I'm using 5 (TACAN_TANKER_MODE_Y) if the bearing shows its bearing
  -- or 14 (TACAN_AA_MODE_Y) if it does not
  local System
  if Bearing then
    System = 5
  else
    System = 14
  end
  
  if IsValid then -- Starts the BEACON
    self:T2({"AA TACAN BEACON started !"})
    self.Positionable:SetCommand({
      id = "ActivateBeacon",
      params = {
        type = 4,
        system = System,
        callsign = Message,
        frequency = Frequency,
        }
      })
      
    if BeaconDuration then -- Schedule the stop of the BEACON if asked by the MD
      SCHEDULER:New( nil, 
      function()
        self:StopAATACAN()
      end, {}, BeaconDuration)
    end
  end
  
  return self
end

--- Stops the AA TACAN BEACON
-- @param #BEACON self
-- @return #BEACON self
function BEACON:StopAATACAN()
  self:F()
  if not self.Positionable then
    self:E({"Start the beacon first before stoping it !"})
  else
    self.Positionable:SetCommand({
      id = 'DeactivateBeacon', 
        params = { 
      } 
    })
  end
end


--- Activates a general pupose Radio Beacon
-- This uses the very generic singleton function "trigger.action.radioTransmission()" provided by DCS to broadcast a sound file on a specific frequency.
-- Although any frequency could be used, only 2 DCS Modules can home on radio beacons at the time of writing : the Huey and the Mi-8. 
-- They can home in on these specific frequencies : 
-- * **Mi8**
-- * R-828 -> 20-60MHz
-- * ARKUD -> 100-150MHz (canal 1 : 114166, canal 2 : 114333, canal 3 : 114583, canal 4 : 121500, canal 5 : 123100, canal 6 : 124100) AM
-- * ARK9 -> 150-1300KHz
-- * **Huey**
-- * AN/ARC-131 -> 30-76 Mhz FM
-- @param #BEACON self
-- @param #string FileName The name of the audio file
-- @param #number Frequency in MHz
-- @param #number Modulation either radio.modulation.AM or radio.modulation.FM
-- @param #number Power in W
-- @param #number BeaconDuration How long will the beacon last in seconds. Omit for forever.
-- @return #BEACON self
-- @usage
-- -- Let's create a beacon for a unit in distress.
-- -- Frequency will be 40MHz FM (home-able by a Huey's AN/ARC-131)
-- -- The beacon they use is battery-powered, and only lasts for 5 min
-- local UnitInDistress = UNIT:FindByName("Unit1")
-- local UnitBeacon = UnitInDistress:GetBeacon()
-- 
-- -- Set the beacon and start it
-- UnitBeacon:RadioBeacon("MySoundFileSOS.ogg", 40, radio.modulation.FM, 20, 5*60)
function BEACON:RadioBeacon(FileName, Frequency, Modulation, Power, BeaconDuration)
  self:F({FileName, Frequency, Modulation, Power, BeaconDuration})
  local IsValid = false
  
  -- Check the filename
  if type(FileName) == "string" then
    if FileName:find(".ogg") or FileName:find(".wav") then
      if not FileName:find("l10n/DEFAULT/") then
        FileName = "l10n/DEFAULT/" .. FileName
      end
      IsValid = true
    end
  end
  if not IsValid then
    self:E({"File name invalid. Maybe something wrong with the extension ? ", FileName})
  end
  
  -- Check the Frequency
  if type(Frequency) ~= "number" and IsValid then
    self:E({"Frequency invalid. ", Frequency})
    IsValid = false
  end
  Frequency = Frequency * 1000000 -- Conversion to Hz
  
  -- Check the modulation
  if Modulation ~= radio.modulation.AM and Modulation ~= radio.modulation.FM and IsValid then --TODO Maybe make this future proof if ED decides to add an other modulation ?
    self:E({"Modulation is invalid. Use DCS's enum radio.modulation.", Modulation})
    IsValid = false
  end
  
  -- Check the Power
  if type(Power) ~= "number" and IsValid then
    self:E({"Power is invalid. ", Power})
    IsValid = false
  end
  Power = math.floor(math.abs(Power)) --TODO Find what is the maximum power allowed by DCS and limit power to that
  
  if IsValid then
    self:T2({"Activating Beacon on ", Frequency, Modulation})
    -- Note that this is looped. I have to give this transmission a unique name, I use the class ID
    trigger.action.radioTransmission(FileName, self.Positionable:GetPositionVec3(), Modulation, true, Frequency, Power, tostring(self.ID))
    
     if BeaconDuration then -- Schedule the stop of the BEACON if asked by the MD
       SCHEDULER:New( nil, 
         function()
           self:StopRadioBeacon()
         end, {}, BeaconDuration)
     end
  end 
end

--- Stops the AA TACAN BEACON
-- @param #BEACON self
-- @return #BEACON self
function BEACON:StopRadioBeacon()
  self:F()
  -- The unique name of the transmission is the class ID
  trigger.action.stopRadioTransmission(tostring(self.ID))
end