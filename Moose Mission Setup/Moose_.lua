env.info('*** MOOSE STATIC INCLUDE START *** ')
env.info('Moose Generation Timestamp: 20171010_2135')
env.setErrorMessageBoxEnabled(false)
routines={}
routines.majorVersion=3
routines.minorVersion=3
routines.build=22
routines.utils={}
routines.utils.deepCopy=function(object)
local lookup_table={}
local function _copy(object)
if type(object)~="table"then
return object
elseif lookup_table[object]then
return lookup_table[object]
end
local new_table={}
lookup_table[object]=new_table
for index,value in pairs(object)do
new_table[_copy(index)]=_copy(value)
end
return setmetatable(new_table,getmetatable(object))
end
local objectreturn=_copy(object)
return objectreturn
end
routines.utils.oneLineSerialize=function(tbl)
lookup_table={}
local function _Serialize(tbl)
if type(tbl)=='table'then
if lookup_table[tbl]then
return lookup_table[object]
end
local tbl_str={}
lookup_table[tbl]=tbl_str
tbl_str[#tbl_str+1]='{'
for ind,val in pairs(tbl)do
local ind_str={}
if type(ind)=="number"then
ind_str[#ind_str+1]='['
ind_str[#ind_str+1]=tostring(ind)
ind_str[#ind_str+1]=']='
else
ind_str[#ind_str+1]='['
ind_str[#ind_str+1]=routines.utils.basicSerialize(ind)
ind_str[#ind_str+1]=']='
end
local val_str={}
if((type(val)=='number')or(type(val)=='boolean'))then
val_str[#val_str+1]=tostring(val)
val_str[#val_str+1]=','
tbl_str[#tbl_str+1]=table.concat(ind_str)
tbl_str[#tbl_str+1]=table.concat(val_str)
elseif type(val)=='string'then
val_str[#val_str+1]=routines.utils.basicSerialize(val)
val_str[#val_str+1]=','
tbl_str[#tbl_str+1]=table.concat(ind_str)
tbl_str[#tbl_str+1]=table.concat(val_str)
elseif type(val)=='nil'then
val_str[#val_str+1]='nil,'
tbl_str[#tbl_str+1]=table.concat(ind_str)
tbl_str[#tbl_str+1]=table.concat(val_str)
elseif type(val)=='table'then
if ind=="__index"then
else
val_str[#val_str+1]=_Serialize(val)
val_str[#val_str+1]=','
tbl_str[#tbl_str+1]=table.concat(ind_str)
tbl_str[#tbl_str+1]=table.concat(val_str)
end
elseif type(val)=='function'then
else
end
end
tbl_str[#tbl_str+1]='}'
return table.concat(tbl_str)
else
return tostring(tbl)
end
end
local objectreturn=_Serialize(tbl)
return objectreturn
end
routines.utils.basicSerialize=function(s)
if s==nil then
return"\"\""
else
if((type(s)=='number')or(type(s)=='boolean')or(type(s)=='function')or(type(s)=='table')or(type(s)=='userdata'))then
return tostring(s)
elseif type(s)=='string'then
s=string.format('%q',s)
return s
end
end
end
routines.utils.toDegree=function(angle)
return angle*180/math.pi
end
routines.utils.toRadian=function(angle)
return angle*math.pi/180
end
routines.utils.metersToNM=function(meters)
return meters/1852
end
routines.utils.metersToFeet=function(meters)
return meters/0.3048
end
routines.utils.NMToMeters=function(NM)
return NM*1852
end
routines.utils.feetToMeters=function(feet)
return feet*0.3048
end
routines.utils.mpsToKnots=function(mps)
return mps*3600/1852
end
routines.utils.mpsToKmph=function(mps)
return mps*3.6
end
routines.utils.knotsToMps=function(knots)
return knots*1852/3600
end
routines.utils.kmphToMps=function(kmph)
return kmph/3.6
end
function routines.utils.makeVec2(Vec3)
if Vec3.z then
return{x=Vec3.x,y=Vec3.z}
else
return{x=Vec3.x,y=Vec3.y}
end
end
function routines.utils.makeVec3(Vec2,y)
if not Vec2.z then
if not y then
y=0
end
return{x=Vec2.x,y=y,z=Vec2.y}
else
return{x=Vec2.x,y=Vec2.y,z=Vec2.z}
end
end
function routines.utils.makeVec3GL(Vec2,offset)
local adj=offset or 0
if not Vec2.z then
return{x=Vec2.x,y=(land.getHeight(Vec2)+adj),z=Vec2.y}
else
return{x=Vec2.x,y=(land.getHeight({x=Vec2.x,y=Vec2.z})+adj),z=Vec2.z}
end
end
routines.utils.zoneToVec3=function(zone)
local new={}
if type(zone)=='table'and zone.point then
new.x=zone.point.x
new.y=zone.point.y
new.z=zone.point.z
return new
elseif type(zone)=='string'then
zone=trigger.misc.getZone(zone)
if zone then
new.x=zone.point.x
new.y=zone.point.y
new.z=zone.point.z
return new
end
end
end
function routines.utils.getDir(vec,point)
local dir=math.atan2(vec.z,vec.x)
dir=dir+routines.getNorthCorrection(point)
if dir<0 then
dir=dir+2*math.pi
end
return dir
end
function routines.utils.get2DDist(point1,point2)
point1=routines.utils.makeVec3(point1)
point2=routines.utils.makeVec3(point2)
return routines.vec.mag({x=point1.x-point2.x,y=0,z=point1.z-point2.z})
end
function routines.utils.get3DDist(point1,point2)
return routines.vec.mag({x=point1.x-point2.x,y=point1.y-point2.y,z=point1.z-point2.z})
end
routines.vec={}
routines.vec.add=function(vec1,vec2)
return{x=vec1.x+vec2.x,y=vec1.y+vec2.y,z=vec1.z+vec2.z}
end
routines.vec.sub=function(vec1,vec2)
return{x=vec1.x-vec2.x,y=vec1.y-vec2.y,z=vec1.z-vec2.z}
end
routines.vec.scalarMult=function(vec,mult)
return{x=vec.x*mult,y=vec.y*mult,z=vec.z*mult}
end
routines.vec.scalar_mult=routines.vec.scalarMult
routines.vec.dp=function(vec1,vec2)
return vec1.x*vec2.x+vec1.y*vec2.y+vec1.z*vec2.z
end
routines.vec.cp=function(vec1,vec2)
return{x=vec1.y*vec2.z-vec1.z*vec2.y,y=vec1.z*vec2.x-vec1.x*vec2.z,z=vec1.x*vec2.y-vec1.y*vec2.x}
end
routines.vec.mag=function(vec)
return(vec.x^2+vec.y^2+vec.z^2)^0.5
end
routines.vec.getUnitVec=function(vec)
local mag=routines.vec.mag(vec)
return{x=vec.x/mag,y=vec.y/mag,z=vec.z/mag}
end
routines.vec.rotateVec2=function(vec2,theta)
return{x=vec2.x*math.cos(theta)-vec2.y*math.sin(theta),y=vec2.x*math.sin(theta)+vec2.y*math.cos(theta)}
end
routines.tostringMGRS=function(MGRS,acc)
if acc==0 then
return MGRS.UTMZone..' '..MGRS.MGRSDigraph
else
return MGRS.UTMZone..' '..MGRS.MGRSDigraph..' '..string.format('%0'..acc..'d',routines.utils.round(MGRS.Easting/(10^(5-acc)),0))
..' '..string.format('%0'..acc..'d',routines.utils.round(MGRS.Northing/(10^(5-acc)),0))
end
end
routines.tostringLL=function(lat,lon,acc,DMS)
local latHemi,lonHemi
if lat>0 then
latHemi='N'
else
latHemi='S'
end
if lon>0 then
lonHemi='E'
else
lonHemi='W'
end
lat=math.abs(lat)
lon=math.abs(lon)
local latDeg=math.floor(lat)
local latMin=(lat-latDeg)*60
local lonDeg=math.floor(lon)
local lonMin=(lon-lonDeg)*60
if DMS then
local oldLatMin=latMin
latMin=math.floor(latMin)
local latSec=routines.utils.round((oldLatMin-latMin)*60,acc)
local oldLonMin=lonMin
lonMin=math.floor(lonMin)
local lonSec=routines.utils.round((oldLonMin-lonMin)*60,acc)
if latSec==60 then
latSec=0
latMin=latMin+1
end
if lonSec==60 then
lonSec=0
lonMin=lonMin+1
end
local secFrmtStr
if acc<=0 then
secFrmtStr='%02d'
else
local width=3+acc
secFrmtStr='%0'..width..'.'..acc..'f'
end
return string.format('%02d',latDeg)..' '..string.format('%02d',latMin)..'\' '..string.format(secFrmtStr,latSec)..'"'..latHemi..'   '
..string.format('%02d',lonDeg)..' '..string.format('%02d',lonMin)..'\' '..string.format(secFrmtStr,lonSec)..'"'..lonHemi
else
latMin=routines.utils.round(latMin,acc)
lonMin=routines.utils.round(lonMin,acc)
if latMin==60 then
latMin=0
latDeg=latDeg+1
end
if lonMin==60 then
lonMin=0
lonDeg=lonDeg+1
end
local minFrmtStr
if acc<=0 then
minFrmtStr='%02d'
else
local width=3+acc
minFrmtStr='%0'..width..'.'..acc..'f'
end
return string.format('%02d',latDeg)..' '..string.format(minFrmtStr,latMin)..'\''..latHemi..'   '
..string.format('%02d',lonDeg)..' '..string.format(minFrmtStr,lonMin)..'\''..lonHemi
end
end
routines.tostringBR=function(az,dist,alt,metric)
az=routines.utils.round(routines.utils.toDegree(az),0)
if metric then
dist=routines.utils.round(dist/1000,2)
else
dist=routines.utils.round(routines.utils.metersToNM(dist),2)
end
local s=string.format('%03d',az)..' for '..dist
if alt then
if metric then
s=s..' at '..routines.utils.round(alt,0)
else
s=s..' at '..routines.utils.round(routines.utils.metersToFeet(alt),0)
end
end
return s
end
routines.getNorthCorrection=function(point)
if not point.z then
point.z=point.y
point.y=0
end
local lat,lon=coord.LOtoLL(point)
local north_posit=coord.LLtoLO(lat+1,lon)
return math.atan2(north_posit.z-point.z,north_posit.x-point.x)
end
do
local idNum=0
routines.addEventHandler=function(f)
local handler={}
idNum=idNum+1
handler.id=idNum
handler.f=f
handler.onEvent=function(self,event)
self.f(event)
end
world.addEventHandler(handler)
end
routines.removeEventHandler=function(id)
for key,handler in pairs(world.eventHandlers)do
if handler.id and handler.id==id then
world.eventHandlers[key]=nil
return true
end
end
return false
end
end
function routines.getRandPointInCircle(point,radius,innerRadius)
local theta=2*math.pi*math.random()
local rad=math.random()+math.random()
if rad>1 then
rad=2-rad
end
local radMult
if innerRadius and innerRadius<=radius then
radMult=(radius-innerRadius)*rad+innerRadius
else
radMult=radius*rad
end
if not point.z then
point.z=point.y
end
local rndCoord
if radius>0 then
rndCoord={x=math.cos(theta)*radMult+point.x,y=math.sin(theta)*radMult+point.z}
else
rndCoord={x=point.x,y=point.z}
end
return rndCoord
end
routines.goRoute=function(group,path)
local misTask={
id='Mission',
params={
route={
points=routines.utils.deepCopy(path),
},
},
}
if type(group)=='string'then
group=Group.getByName(group)
end
local groupCon=group:getController()
if groupCon then
groupCon:setTask(misTask)
return true
end
Controller.setTask(groupCon,misTask)
return false
end
routines.ground={}
routines.fixedWing={}
routines.heli={}
routines.ground.buildWP=function(point,overRideForm,overRideSpeed)
local wp={}
wp.x=point.x
if point.z then
wp.y=point.z
else
wp.y=point.y
end
local form,speed
if point.speed and not overRideSpeed then
wp.speed=point.speed
elseif type(overRideSpeed)=='number'then
wp.speed=overRideSpeed
else
wp.speed=routines.utils.kmphToMps(20)
end
if point.form and not overRideForm then
form=point.form
else
form=overRideForm
end
if not form then
wp.action='Cone'
else
form=string.lower(form)
if form=='off_road'or form=='off road'then
wp.action='Off Road'
elseif form=='on_road'or form=='on road'then
wp.action='On Road'
elseif form=='rank'or form=='line_abrest'or form=='line abrest'or form=='lineabrest'then
wp.action='Rank'
elseif form=='cone'then
wp.action='Cone'
elseif form=='diamond'then
wp.action='Diamond'
elseif form=='vee'then
wp.action='Vee'
elseif form=='echelon_left'or form=='echelon left'or form=='echelonl'then
wp.action='EchelonL'
elseif form=='echelon_right'or form=='echelon right'or form=='echelonr'then
wp.action='EchelonR'
else
wp.action='Cone'
end
end
wp.type='Turning Point'
return wp
end
routines.fixedWing.buildWP=function(point,WPtype,speed,alt,altType)
local wp={}
wp.x=point.x
if point.z then
wp.y=point.z
else
wp.y=point.y
end
if alt and type(alt)=='number'then
wp.alt=alt
else
wp.alt=2000
end
if altType then
altType=string.lower(altType)
if altType=='radio'or'agl'then
wp.alt_type='RADIO'
elseif altType=='baro'or'asl'then
wp.alt_type='BARO'
end
else
wp.alt_type='RADIO'
end
if point.speed then
speed=point.speed
end
if point.type then
WPtype=point.type
end
if not speed then
wp.speed=routines.utils.kmphToMps(500)
else
wp.speed=speed
end
if not WPtype then
wp.action='Turning Point'
else
WPtype=string.lower(WPtype)
if WPtype=='flyover'or WPtype=='fly over'or WPtype=='fly_over'then
wp.action='Fly Over Point'
elseif WPtype=='turningpoint'or WPtype=='turning point'or WPtype=='turning_point'then
wp.action='Turning Point'
else
wp.action='Turning Point'
end
end
wp.type='Turning Point'
return wp
end
routines.heli.buildWP=function(point,WPtype,speed,alt,altType)
local wp={}
wp.x=point.x
if point.z then
wp.y=point.z
else
wp.y=point.y
end
if alt and type(alt)=='number'then
wp.alt=alt
else
wp.alt=500
end
if altType then
altType=string.lower(altType)
if altType=='radio'or'agl'then
wp.alt_type='RADIO'
elseif altType=='baro'or'asl'then
wp.alt_type='BARO'
end
else
wp.alt_type='RADIO'
end
if point.speed then
speed=point.speed
end
if point.type then
WPtype=point.type
end
if not speed then
wp.speed=routines.utils.kmphToMps(200)
else
wp.speed=speed
end
if not WPtype then
wp.action='Turning Point'
else
WPtype=string.lower(WPtype)
if WPtype=='flyover'or WPtype=='fly over'or WPtype=='fly_over'then
wp.action='Fly Over Point'
elseif WPtype=='turningpoint'or WPtype=='turning point'or WPtype=='turning_point'then
wp.action='Turning Point'
else
wp.action='Turning Point'
end
end
wp.type='Turning Point'
return wp
end
routines.groupToRandomPoint=function(vars)
local group=vars.group
local point=vars.point
local radius=vars.radius or 0
local innerRadius=vars.innerRadius
local form=vars.form or'Cone'
local heading=vars.heading or math.random()*2*math.pi
local headingDegrees=vars.headingDegrees
local speed=vars.speed or routines.utils.kmphToMps(20)
local useRoads
if not vars.disableRoads then
useRoads=true
else
useRoads=false
end
local path={}
if headingDegrees then
heading=headingDegrees*math.pi/180
end
if heading>=2*math.pi then
heading=heading-2*math.pi
end
local rndCoord=routines.getRandPointInCircle(point,radius,innerRadius)
local offset={}
local posStart=routines.getLeadPos(group)
offset.x=routines.utils.round(math.sin(heading-(math.pi/2))*50+rndCoord.x,3)
offset.z=routines.utils.round(math.cos(heading+(math.pi/2))*50+rndCoord.y,3)
path[#path+1]=routines.ground.buildWP(posStart,form,speed)
if useRoads==true and((point.x-posStart.x)^2+(point.z-posStart.z)^2)^0.5>radius*1.3 then
path[#path+1]=routines.ground.buildWP({['x']=posStart.x+11,['z']=posStart.z+11},'off_road',speed)
path[#path+1]=routines.ground.buildWP(posStart,'on_road',speed)
path[#path+1]=routines.ground.buildWP(offset,'on_road',speed)
else
path[#path+1]=routines.ground.buildWP({['x']=posStart.x+25,['z']=posStart.z+25},form,speed)
end
path[#path+1]=routines.ground.buildWP(offset,form,speed)
path[#path+1]=routines.ground.buildWP(rndCoord,form,speed)
routines.goRoute(group,path)
return
end
routines.groupRandomDistSelf=function(gpData,dist,form,heading,speed)
local pos=routines.getLeadPos(gpData)
local fakeZone={}
fakeZone.radius=dist or math.random(300,1000)
fakeZone.point={x=pos.x,y,pos.y,z=pos.z}
routines.groupToRandomZone(gpData,fakeZone,form,heading,speed)
return
end
routines.groupToRandomZone=function(gpData,zone,form,heading,speed)
if type(gpData)=='string'then
gpData=Group.getByName(gpData)
end
if type(zone)=='string'then
zone=trigger.misc.getZone(zone)
elseif type(zone)=='table'and not zone.radius then
zone=trigger.misc.getZone(zone[math.random(1,#zone)])
end
if speed then
speed=routines.utils.kmphToMps(speed)
end
local vars={}
vars.group=gpData
vars.radius=zone.radius
vars.form=form
vars.headingDegrees=heading
vars.speed=speed
vars.point=routines.utils.zoneToVec3(zone)
routines.groupToRandomPoint(vars)
return
end
routines.isTerrainValid=function(coord,terrainTypes)
if coord.z then
coord.y=coord.z
end
local typeConverted={}
if type(terrainTypes)=='string'then
for constId,constData in pairs(land.SurfaceType)do
if string.lower(constId)==string.lower(terrainTypes)or string.lower(constData)==string.lower(terrainTypes)then
table.insert(typeConverted,constId)
end
end
elseif type(terrainTypes)=='table'then
for typeId,typeData in pairs(terrainTypes)do
for constId,constData in pairs(land.SurfaceType)do
if string.lower(constId)==string.lower(typeData)or string.lower(constData)==string.lower(typeId)then
table.insert(typeConverted,constId)
end
end
end
end
for validIndex,validData in pairs(typeConverted)do
if land.getSurfaceType(coord)==land.SurfaceType[validData]then
return true
end
end
return false
end
routines.groupToPoint=function(gpData,point,form,heading,speed,useRoads)
if type(point)=='string'then
point=trigger.misc.getZone(point)
end
if speed then
speed=routines.utils.kmphToMps(speed)
end
local vars={}
vars.group=gpData
vars.form=form
vars.headingDegrees=heading
vars.speed=speed
vars.disableRoads=useRoads
vars.point=routines.utils.zoneToVec3(point)
routines.groupToRandomPoint(vars)
return
end
routines.getLeadPos=function(group)
if type(group)=='string'then
group=Group.getByName(group)
end
local units=group:getUnits()
local leader=units[1]
if not leader then
local lowestInd=math.huge
for ind,unit in pairs(units)do
if ind<lowestInd then
lowestInd=ind
leader=unit
end
end
end
if leader and Unit.isExist(leader)then
return leader:getPosition().p
end
end
routines.getMGRSString=function(vars)
local units=vars.units
local acc=vars.acc or 5
local avgPos=routines.getAvgPos(units)
if avgPos then
return routines.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(avgPos)),acc)
end
end
routines.getLLString=function(vars)
local units=vars.units
local acc=vars.acc or 3
local DMS=vars.DMS
local avgPos=routines.getAvgPos(units)
if avgPos then
local lat,lon=coord.LOtoLL(avgPos)
return routines.tostringLL(lat,lon,acc,DMS)
end
end
routines.getBRStringZone=function(vars)
local zone=trigger.misc.getZone(vars.zone)
local ref=routines.utils.makeVec3(vars.ref,0)
local alt=vars.alt
local metric=vars.metric
if zone then
local vec={x=zone.point.x-ref.x,y=zone.point.y-ref.y,z=zone.point.z-ref.z}
local dir=routines.utils.getDir(vec,ref)
local dist=routines.utils.get2DDist(zone.point,ref)
if alt then
alt=zone.y
end
return routines.tostringBR(dir,dist,alt,metric)
else
env.info('routines.getBRStringZone: error: zone is nil')
end
end
routines.getBRString=function(vars)
local units=vars.units
local ref=routines.utils.makeVec3(vars.ref,0)
local alt=vars.alt
local metric=vars.metric
local avgPos=routines.getAvgPos(units)
if avgPos then
local vec={x=avgPos.x-ref.x,y=avgPos.y-ref.y,z=avgPos.z-ref.z}
local dir=routines.utils.getDir(vec,ref)
local dist=routines.utils.get2DDist(avgPos,ref)
if alt then
alt=avgPos.y
end
return routines.tostringBR(dir,dist,alt,metric)
end
end
routines.getLeadingPos=function(vars)
local units=vars.units
local heading=vars.heading
local radius=vars.radius
if vars.headingDegrees then
heading=routines.utils.toRadian(vars.headingDegrees)
end
local unitPosTbl={}
for i=1,#units do
local unit=Unit.getByName(units[i])
if unit and unit:isExist()then
unitPosTbl[#unitPosTbl+1]=unit:getPosition().p
end
end
if#unitPosTbl>0 then
local maxPos=-math.huge
local maxPosInd
for i=1,#unitPosTbl do
local rotatedVec2=routines.vec.rotateVec2(routines.utils.makeVec2(unitPosTbl[i]),heading)
if(not maxPos)or maxPos<rotatedVec2.x then
maxPos=rotatedVec2.x
maxPosInd=i
end
end
local avgPos
if radius then
local maxUnitPos=unitPosTbl[maxPosInd]
local avgx,avgy,avgz,totNum=0,0,0,0
for i=1,#unitPosTbl do
if routines.utils.get2DDist(maxUnitPos,unitPosTbl[i])<=radius then
avgx=avgx+unitPosTbl[i].x
avgy=avgy+unitPosTbl[i].y
avgz=avgz+unitPosTbl[i].z
totNum=totNum+1
end
end
avgPos={x=avgx/totNum,y=avgy/totNum,z=avgz/totNum}
else
avgPos=unitPosTbl[maxPosInd]
end
return avgPos
end
end
routines.getLeadingMGRSString=function(vars)
local pos=routines.getLeadingPos(vars)
if pos then
local acc=vars.acc or 5
return routines.tostringMGRS(coord.LLtoMGRS(coord.LOtoLL(pos)),acc)
end
end
routines.getLeadingLLString=function(vars)
local pos=routines.getLeadingPos(vars)
if pos then
local acc=vars.acc or 3
local DMS=vars.DMS
local lat,lon=coord.LOtoLL(pos)
return routines.tostringLL(lat,lon,acc,DMS)
end
end
routines.getLeadingBRString=function(vars)
local pos=routines.getLeadingPos(vars)
if pos then
local ref=vars.ref
local alt=vars.alt
local metric=vars.metric
local vec={x=pos.x-ref.x,y=pos.y-ref.y,z=pos.z-ref.z}
local dir=routines.utils.getDir(vec,ref)
local dist=routines.utils.get2DDist(pos,ref)
if alt then
alt=pos.y
end
return routines.tostringBR(dir,dist,alt,metric)
end
end
routines.msgMGRS=function(vars)
local units=vars.units
local acc=vars.acc
local text=vars.text
local displayTime=vars.displayTime
local msgFor=vars.msgFor
local s=routines.getMGRSString{units=units,acc=acc}
local newText
if string.find(text,'%%s')then
newText=string.format(text,s)
else
newText=text..s
end
routines.message.add{
text=newText,
displayTime=displayTime,
msgFor=msgFor
}
end
routines.msgLL=function(vars)
local units=vars.units
local acc=vars.acc
local DMS=vars.DMS
local text=vars.text
local displayTime=vars.displayTime
local msgFor=vars.msgFor
local s=routines.getLLString{units=units,acc=acc,DMS=DMS}
local newText
if string.find(text,'%%s')then
newText=string.format(text,s)
else
newText=text..s
end
routines.message.add{
text=newText,
displayTime=displayTime,
msgFor=msgFor
}
end
routines.msgBR=function(vars)
local units=vars.units
local ref=vars.ref
local alt=vars.alt
local metric=vars.metric
local text=vars.text
local displayTime=vars.displayTime
local msgFor=vars.msgFor
local s=routines.getBRString{units=units,ref=ref,alt=alt,metric=metric}
local newText
if string.find(text,'%%s')then
newText=string.format(text,s)
else
newText=text..s
end
routines.message.add{
text=newText,
displayTime=displayTime,
msgFor=msgFor
}
end
routines.msgBullseye=function(vars)
if string.lower(vars.ref)=='red'then
vars.ref=routines.DBs.missionData.bullseye.red
routines.msgBR(vars)
elseif string.lower(vars.ref)=='blue'then
vars.ref=routines.DBs.missionData.bullseye.blue
routines.msgBR(vars)
end
end
routines.msgBRA=function(vars)
if Unit.getByName(vars.ref)then
vars.ref=Unit.getByName(vars.ref):getPosition().p
if not vars.alt then
vars.alt=true
end
routines.msgBR(vars)
end
end
routines.msgLeadingMGRS=function(vars)
local units=vars.units
local heading=vars.heading
local radius=vars.radius
local headingDegrees=vars.headingDegrees
local acc=vars.acc
local text=vars.text
local displayTime=vars.displayTime
local msgFor=vars.msgFor
local s=routines.getLeadingMGRSString{units=units,heading=heading,radius=radius,headingDegrees=headingDegrees,acc=acc}
local newText
if string.find(text,'%%s')then
newText=string.format(text,s)
else
newText=text..s
end
routines.message.add{
text=newText,
displayTime=displayTime,
msgFor=msgFor
}
end
routines.msgLeadingLL=function(vars)
local units=vars.units
local heading=vars.heading
local radius=vars.radius
local headingDegrees=vars.headingDegrees
local acc=vars.acc
local DMS=vars.DMS
local text=vars.text
local displayTime=vars.displayTime
local msgFor=vars.msgFor
local s=routines.getLeadingLLString{units=units,heading=heading,radius=radius,headingDegrees=headingDegrees,acc=acc,DMS=DMS}
local newText
if string.find(text,'%%s')then
newText=string.format(text,s)
else
newText=text..s
end
routines.message.add{
text=newText,
displayTime=displayTime,
msgFor=msgFor
}
end
routines.msgLeadingBR=function(vars)
local units=vars.units
local heading=vars.heading
local radius=vars.radius
local headingDegrees=vars.headingDegrees
local metric=vars.metric
local alt=vars.alt
local ref=vars.ref
local text=vars.text
local displayTime=vars.displayTime
local msgFor=vars.msgFor
local s=routines.getLeadingBRString{units=units,heading=heading,radius=radius,headingDegrees=headingDegrees,metric=metric,alt=alt,ref=ref}
local newText
if string.find(text,'%%s')then
newText=string.format(text,s)
else
newText=text..s
end
routines.message.add{
text=newText,
displayTime=displayTime,
msgFor=msgFor
}
end
function spairs(t,order)
local keys={}
for k in pairs(t)do keys[#keys+1]=k end
if order then
table.sort(keys,function(a,b)return order(t,a,b)end)
else
table.sort(keys)
end
local i=0
return function()
i=i+1
if keys[i]then
return keys[i],t[keys[i]]
end
end
end
function routines.IsPartOfGroupInZones(CargoGroup,LandingZones)
local CurrentZoneID=nil
if CargoGroup then
local CargoUnits=CargoGroup:getUnits()
for CargoUnitID,CargoUnit in pairs(CargoUnits)do
if CargoUnit and CargoUnit:getLife()>=1.0 then
CurrentZoneID=routines.IsUnitInZones(CargoUnit,LandingZones)
if CurrentZoneID then
break
end
end
end
end
return CurrentZoneID
end
function routines.IsUnitInZones(TransportUnit,LandingZones)
local TransportZoneResult=nil
local TransportZonePos=nil
local TransportZone=nil
if TransportUnit then
local TransportUnitPos=TransportUnit:getPosition().p
if type(LandingZones)=="table"then
for LandingZoneID,LandingZoneName in pairs(LandingZones)do
TransportZone=trigger.misc.getZone(LandingZoneName)
if TransportZone then
TransportZonePos={radius=TransportZone.radius,x=TransportZone.point.x,y=TransportZone.point.y,z=TransportZone.point.z}
if(((TransportUnitPos.x-TransportZonePos.x)^2+(TransportUnitPos.z-TransportZonePos.z)^2)^0.5<=TransportZonePos.radius)then
TransportZoneResult=LandingZoneID
break
end
end
end
else
TransportZone=trigger.misc.getZone(LandingZones)
TransportZonePos={radius=TransportZone.radius,x=TransportZone.point.x,y=TransportZone.point.y,z=TransportZone.point.z}
if(((TransportUnitPos.x-TransportZonePos.x)^2+(TransportUnitPos.z-TransportZonePos.z)^2)^0.5<=TransportZonePos.radius)then
TransportZoneResult=1
end
end
if TransportZoneResult then
else
end
return TransportZoneResult
else
return nil
end
end
function routines.IsUnitNearZonesRadius(TransportUnit,LandingZones,ZoneRadius)
local TransportZoneResult=nil
local TransportZonePos=nil
local TransportZone=nil
if TransportUnit then
local TransportUnitPos=TransportUnit:getPosition().p
if type(LandingZones)=="table"then
for LandingZoneID,LandingZoneName in pairs(LandingZones)do
TransportZone=trigger.misc.getZone(LandingZoneName)
if TransportZone then
TransportZonePos={radius=TransportZone.radius,x=TransportZone.point.x,y=TransportZone.point.y,z=TransportZone.point.z}
if(((TransportUnitPos.x-TransportZonePos.x)^2+(TransportUnitPos.z-TransportZonePos.z)^2)^0.5<=ZoneRadius)then
TransportZoneResult=LandingZoneID
break
end
end
end
else
TransportZone=trigger.misc.getZone(LandingZones)
TransportZonePos={radius=TransportZone.radius,x=TransportZone.point.x,y=TransportZone.point.y,z=TransportZone.point.z}
if(((TransportUnitPos.x-TransportZonePos.x)^2+(TransportUnitPos.z-TransportZonePos.z)^2)^0.5<=ZoneRadius)then
TransportZoneResult=1
end
end
if TransportZoneResult then
else
end
return TransportZoneResult
else
return nil
end
end
function routines.IsStaticInZones(TransportStatic,LandingZones)
local TransportZoneResult=nil
local TransportZonePos=nil
local TransportZone=nil
local TransportStaticPos=TransportStatic:getPosition().p
if type(LandingZones)=="table"then
for LandingZoneID,LandingZoneName in pairs(LandingZones)do
TransportZone=trigger.misc.getZone(LandingZoneName)
if TransportZone then
TransportZonePos={radius=TransportZone.radius,x=TransportZone.point.x,y=TransportZone.point.y,z=TransportZone.point.z}
if(((TransportStaticPos.x-TransportZonePos.x)^2+(TransportStaticPos.z-TransportZonePos.z)^2)^0.5<=TransportZonePos.radius)then
TransportZoneResult=LandingZoneID
break
end
end
end
else
TransportZone=trigger.misc.getZone(LandingZones)
TransportZonePos={radius=TransportZone.radius,x=TransportZone.point.x,y=TransportZone.point.y,z=TransportZone.point.z}
if(((TransportStaticPos.x-TransportZonePos.x)^2+(TransportStaticPos.z-TransportZonePos.z)^2)^0.5<=TransportZonePos.radius)then
TransportZoneResult=1
end
end
return TransportZoneResult
end
function routines.IsUnitInRadius(CargoUnit,ReferencePosition,Radius)
local Valid=true
local CargoPos=CargoUnit:getPosition().p
local ReferenceP=ReferencePosition.p
if(((CargoPos.x-ReferenceP.x)^2+(CargoPos.z-ReferenceP.z)^2)^0.5<=Radius)then
else
Valid=false
end
return Valid
end
function routines.IsPartOfGroupInRadius(CargoGroup,ReferencePosition,Radius)
local Valid=true
Valid=routines.ValidateGroup(CargoGroup,"CargoGroup",Valid)
local CargoUnits=CargoGroup:getUnits()
for CargoUnitId,CargoUnit in pairs(CargoUnits)do
local CargoUnitPos=CargoUnit:getPosition().p
local ReferenceP=ReferencePosition.p
if(((CargoUnitPos.x-ReferenceP.x)^2+(CargoUnitPos.z-ReferenceP.z)^2)^0.5<=Radius)then
else
Valid=false
break
end
end
return Valid
end
function routines.ValidateString(Variable,VariableName,Valid)
if type(Variable)=="string"then
if Variable==""then
error("routines.ValidateString: error: "..VariableName.." must be filled out!")
Valid=false
end
else
error("routines.ValidateString: error: "..VariableName.." is not a string.")
Valid=false
end
return Valid
end
function routines.ValidateNumber(Variable,VariableName,Valid)
if type(Variable)=="number"then
else
error("routines.ValidateNumber: error: "..VariableName.." is not a number.")
Valid=false
end
return Valid
end
function routines.ValidateGroup(Variable,VariableName,Valid)
if Variable==nil then
error("routines.ValidateGroup: error: "..VariableName.." is a nil value!")
Valid=false
end
return Valid
end
function routines.ValidateZone(LandingZones,VariableName,Valid)
if LandingZones==nil then
error("routines.ValidateGroup: error: "..VariableName.." is a nil value!")
Valid=false
end
if type(LandingZones)=="table"then
for LandingZoneID,LandingZoneName in pairs(LandingZones)do
if trigger.misc.getZone(LandingZoneName)==nil then
error("routines.ValidateGroup: error: Zone "..LandingZoneName.." does not exist!")
Valid=false
break
end
end
else
if trigger.misc.getZone(LandingZones)==nil then
error("routines.ValidateGroup: error: Zone "..LandingZones.." does not exist!")
Valid=false
end
end
return Valid
end
function routines.ValidateEnumeration(Variable,VariableName,Enum,Valid)
local ValidVariable=false
for EnumId,EnumData in pairs(Enum)do
if Variable==EnumData then
ValidVariable=true
break
end
end
if ValidVariable then
else
error('TransportValidateEnum: " .. VariableName .. " is not a valid type.'..Variable)
Valid=false
end
return Valid
end
function routines.getGroupRoute(groupIdent,task)
local gpId=groupIdent
if type(groupIdent)=='string'and not tonumber(groupIdent)then
gpId=_DATABASE.Templates.Groups[groupIdent].groupId
end
for coa_name,coa_data in pairs(env.mission.coalition)do
if(coa_name=='red'or coa_name=='blue')and type(coa_data)=='table'then
if coa_data.country then
for cntry_id,cntry_data in pairs(coa_data.country)do
for obj_type_name,obj_type_data in pairs(cntry_data)do
if obj_type_name=="helicopter"or obj_type_name=="ship"or obj_type_name=="plane"or obj_type_name=="vehicle"then
if((type(obj_type_data)=='table')and obj_type_data.group and(type(obj_type_data.group)=='table')and(#obj_type_data.group>0))then
for group_num,group_data in pairs(obj_type_data.group)do
if group_data and group_data.groupId==gpId then
if group_data.route and group_data.route.points and#group_data.route.points>0 then
local points={}
for point_num,point in pairs(group_data.route.points)do
local routeData={}
if not point.point then
routeData.x=point.x
routeData.y=point.y
else
routeData.point=point.point
end
routeData.form=point.action
routeData.speed=point.speed
routeData.alt=point.alt
routeData.alt_type=point.alt_type
routeData.airdromeId=point.airdromeId
routeData.helipadId=point.helipadId
routeData.type=point.type
routeData.action=point.action
if task then
routeData.task=point.task
end
points[point_num]=routeData
end
return points
end
return
end
end
end
end
end
end
end
end
end
end
routines.ground.patrolRoute=function(vars)
local tempRoute={}
local useRoute={}
local gpData=vars.gpData
if type(gpData)=='string'then
gpData=Group.getByName(gpData)
end
local useGroupRoute
if not vars.useGroupRoute then
useGroupRoute=vars.gpData
else
useGroupRoute=vars.useGroupRoute
end
local routeProvided=false
if not vars.route then
if useGroupRoute then
tempRoute=routines.getGroupRoute(useGroupRoute)
end
else
useRoute=vars.route
local posStart=routines.getLeadPos(gpData)
useRoute[1]=routines.ground.buildWP(posStart,useRoute[1].action,useRoute[1].speed)
routeProvided=true
end
local overRideSpeed=vars.speed or'default'
local pType=vars.pType
local offRoadForm=vars.offRoadForm or'default'
local onRoadForm=vars.onRoadForm or'default'
if routeProvided==false and#tempRoute>0 then
local posStart=routines.getLeadPos(gpData)
useRoute[#useRoute+1]=routines.ground.buildWP(posStart,offRoadForm,overRideSpeed)
for i=1,#tempRoute do
local tempForm=tempRoute[i].action
local tempSpeed=tempRoute[i].speed
if offRoadForm=='default'then
tempForm=tempRoute[i].action
end
if onRoadForm=='default'then
onRoadForm='On Road'
end
if(string.lower(tempRoute[i].action)=='on road'or string.lower(tempRoute[i].action)=='onroad'or string.lower(tempRoute[i].action)=='on_road')then
tempForm=onRoadForm
else
tempForm=offRoadForm
end
if type(overRideSpeed)=='number'then
tempSpeed=overRideSpeed
end
useRoute[#useRoute+1]=routines.ground.buildWP(tempRoute[i],tempForm,tempSpeed)
end
if pType and string.lower(pType)=='doubleback'then
local curRoute=routines.utils.deepCopy(useRoute)
for i=#curRoute,2,-1 do
useRoute[#useRoute+1]=routines.ground.buildWP(curRoute[i],curRoute[i].action,curRoute[i].speed)
end
end
useRoute[1].action=useRoute[#useRoute].action
end
local cTask3={}
local newPatrol={}
newPatrol.route=useRoute
newPatrol.gpData=gpData:getName()
cTask3[#cTask3+1]='routines.ground.patrolRoute('
cTask3[#cTask3+1]=routines.utils.oneLineSerialize(newPatrol)
cTask3[#cTask3+1]=')'
cTask3=table.concat(cTask3)
local tempTask={
id='WrappedAction',
params={
action={
id='Script',
params={
command=cTask3,
},
},
},
}
useRoute[#useRoute].task=tempTask
routines.goRoute(gpData,useRoute)
return
end
routines.ground.patrol=function(gpData,pType,form,speed)
local vars={}
if type(gpData)=='table'and gpData:getName()then
gpData=gpData:getName()
end
vars.useGroupRoute=gpData
vars.gpData=gpData
vars.pType=pType
vars.offRoadForm=form
vars.speed=speed
routines.ground.patrolRoute(vars)
return
end
function routines.GetUnitHeight(CheckUnit)
local UnitPoint=CheckUnit:getPoint()
local UnitPosition={x=UnitPoint.x,y=UnitPoint.z}
local UnitHeight=UnitPoint.y
local LandHeight=land.getHeight(UnitPosition)
return UnitHeight-LandHeight
end
Su34Status={status={}}
boardMsgRed={statusMsg=""}
boardMsgAll={timeMsg=""}
SpawnSettings={}
Su34MenuPath={}
Su34Menus=0
function Su34AttackCarlVinson(groupName)
local groupSu34=Group.getByName(groupName)
local controllerSu34=groupSu34.getController(groupSu34)
local groupCarlVinson=Group.getByName("US Carl Vinson #001")
controllerSu34.setOption(controllerSu34,AI.Option.Air.id.ROE,AI.Option.Air.val.ROE.OPEN_FIRE)
controllerSu34.setOption(controllerSu34,AI.Option.Air.id.REACTION_ON_THREAT,AI.Option.Air.val.REACTION_ON_THREAT.EVADE_FIRE)
if groupCarlVinson~=nil then
controllerSu34.pushTask(controllerSu34,{id='AttackGroup',params={groupId=groupCarlVinson:getID(),expend=AI.Task.WeaponExpend.ALL,attackQtyLimit=true}})
end
Su34Status.status[groupName]=1
MessageToRed(string.format('%s: ',groupName)..'Attacking carrier Carl Vinson. ',10,'RedStatus'..groupName)
end
function Su34AttackWest(groupName)
local groupSu34=Group.getByName(groupName)
local controllerSu34=groupSu34.getController(groupSu34)
local groupShipWest1=Group.getByName("US Ship West #001")
local groupShipWest2=Group.getByName("US Ship West #002")
controllerSu34.setOption(controllerSu34,AI.Option.Air.id.ROE,AI.Option.Air.val.ROE.OPEN_FIRE)
controllerSu34.setOption(controllerSu34,AI.Option.Air.id.REACTION_ON_THREAT,AI.Option.Air.val.REACTION_ON_THREAT.EVADE_FIRE)
if groupShipWest1~=nil then
controllerSu34.pushTask(controllerSu34,{id='AttackGroup',params={groupId=groupShipWest1:getID(),expend=AI.Task.WeaponExpend.ALL,attackQtyLimit=true}})
end
if groupShipWest2~=nil then
controllerSu34.pushTask(controllerSu34,{id='AttackGroup',params={groupId=groupShipWest2:getID(),expend=AI.Task.WeaponExpend.ALL,attackQtyLimit=true}})
end
Su34Status.status[groupName]=2
MessageToRed(string.format('%s: ',groupName)..'Attacking invading ships in the west. ',10,'RedStatus'..groupName)
end
function Su34AttackNorth(groupName)
local groupSu34=Group.getByName(groupName)
local controllerSu34=groupSu34.getController(groupSu34)
local groupShipNorth1=Group.getByName("US Ship North #001")
local groupShipNorth2=Group.getByName("US Ship North #002")
local groupShipNorth3=Group.getByName("US Ship North #003")
controllerSu34.setOption(controllerSu34,AI.Option.Air.id.ROE,AI.Option.Air.val.ROE.OPEN_FIRE)
controllerSu34.setOption(controllerSu34,AI.Option.Air.id.REACTION_ON_THREAT,AI.Option.Air.val.REACTION_ON_THREAT.EVADE_FIRE)
if groupShipNorth1~=nil then
controllerSu34.pushTask(controllerSu34,{id='AttackGroup',params={groupId=groupShipNorth1:getID(),expend=AI.Task.WeaponExpend.ALL,attackQtyLimit=false}})
end
if groupShipNorth2~=nil then
controllerSu34.pushTask(controllerSu34,{id='AttackGroup',params={groupId=groupShipNorth2:getID(),expend=AI.Task.WeaponExpend.ALL,attackQtyLimit=false}})
end
if groupShipNorth3~=nil then
controllerSu34.pushTask(controllerSu34,{id='AttackGroup',params={groupId=groupShipNorth3:getID(),expend=AI.Task.WeaponExpend.ALL,attackQtyLimit=false}})
end
Su34Status.status[groupName]=3
MessageToRed(string.format('%s: ',groupName)..'Attacking invading ships in the north. ',10,'RedStatus'..groupName)
end
function Su34Orbit(groupName)
local groupSu34=Group.getByName(groupName)
local controllerSu34=groupSu34:getController()
controllerSu34.setOption(controllerSu34,AI.Option.Air.id.ROE,AI.Option.Air.val.ROE.WEAPON_HOLD)
controllerSu34.setOption(controllerSu34,AI.Option.Air.id.REACTION_ON_THREAT,AI.Option.Air.val.REACTION_ON_THREAT.EVADE_FIRE)
controllerSu34:pushTask({id='ControlledTask',params={task={id='Orbit',params={pattern=AI.Task.OrbitPattern.RACE_TRACK}},stopCondition={duration=600}}})
Su34Status.status[groupName]=4
MessageToRed(string.format('%s: ',groupName)..'In orbit and awaiting further instructions. ',10,'RedStatus'..groupName)
end
function Su34TakeOff(groupName)
local groupSu34=Group.getByName(groupName)
local controllerSu34=groupSu34:getController()
controllerSu34.setOption(controllerSu34,AI.Option.Air.id.ROE,AI.Option.Air.val.ROE.WEAPON_HOLD)
controllerSu34.setOption(controllerSu34,AI.Option.Air.id.REACTION_ON_THREAT,AI.Option.Air.val.REACTION_ON_THREAT.BYPASS_AND_ESCAPE)
Su34Status.status[groupName]=8
MessageToRed(string.format('%s: ',groupName)..'Take-Off. ',10,'RedStatus'..groupName)
end
function Su34Hold(groupName)
local groupSu34=Group.getByName(groupName)
local controllerSu34=groupSu34:getController()
controllerSu34.setOption(controllerSu34,AI.Option.Air.id.ROE,AI.Option.Air.val.ROE.WEAPON_HOLD)
controllerSu34.setOption(controllerSu34,AI.Option.Air.id.REACTION_ON_THREAT,AI.Option.Air.val.REACTION_ON_THREAT.BYPASS_AND_ESCAPE)
Su34Status.status[groupName]=5
MessageToRed(string.format('%s: ',groupName)..'Holding Weapons. ',10,'RedStatus'..groupName)
end
function Su34RTB(groupName)
Su34Status.status[groupName]=6
MessageToRed(string.format('%s: ',groupName)..'Return to Krasnodar. ',10,'RedStatus'..groupName)
end
function Su34Destroyed(groupName)
Su34Status.status[groupName]=7
MessageToRed(string.format('%s: ',groupName)..'Destroyed. ',30,'RedStatus'..groupName)
end
function GroupAlive(groupName)
local groupTest=Group.getByName(groupName)
local groupExists=false
if groupTest then
groupExists=groupTest:isExist()
end
return groupExists
end
function Su34IsDead()
end
function Su34OverviewStatus()
local msg=""
local currentStatus=0
local Exists=false
for groupName,currentStatus in pairs(Su34Status.status)do
env.info(('Su34 Overview Status: GroupName = '..groupName))
Alive=GroupAlive(groupName)
if Alive then
if currentStatus==1 then
msg=msg..string.format("%s: ",groupName)
msg=msg.."Attacking carrier Carl Vinson. "
elseif currentStatus==2 then
msg=msg..string.format("%s: ",groupName)
msg=msg.."Attacking supporting ships in the west. "
elseif currentStatus==3 then
msg=msg..string.format("%s: ",groupName)
msg=msg.."Attacking invading ships in the north. "
elseif currentStatus==4 then
msg=msg..string.format("%s: ",groupName)
msg=msg.."In orbit and awaiting further instructions. "
elseif currentStatus==5 then
msg=msg..string.format("%s: ",groupName)
msg=msg.."Holding Weapons. "
elseif currentStatus==6 then
msg=msg..string.format("%s: ",groupName)
msg=msg.."Return to Krasnodar. "
elseif currentStatus==7 then
msg=msg..string.format("%s: ",groupName)
msg=msg.."Destroyed. "
elseif currentStatus==8 then
msg=msg..string.format("%s: ",groupName)
msg=msg.."Take-Off. "
end
else
if currentStatus==7 then
msg=msg..string.format("%s: ",groupName)
msg=msg.."Destroyed. "
else
Su34Destroyed(groupName)
end
end
end
boardMsgRed.statusMsg=msg
end
function UpdateBoardMsg()
Su34OverviewStatus()
MessageToRed(boardMsgRed.statusMsg,15,'RedStatus')
end
function MusicReset(flg)
trigger.action.setUserFlag(95,flg)
end
function PlaneActivate(groupNameFormat,flg)
local groupName=groupNameFormat..string.format("#%03d",trigger.misc.getUserFlag(flg))
trigger.action.activateGroup(Group.getByName(groupName))
end
function Su34Menu(groupName)
local groupSu34=Group.getByName(groupName)
if Su34Status.status[groupName]==1 or
Su34Status.status[groupName]==2 or
Su34Status.status[groupName]==3 or
Su34Status.status[groupName]==4 or
Su34Status.status[groupName]==5 then
if Su34MenuPath[groupName]==nil then
if planeMenuPath==nil then
planeMenuPath=missionCommands.addSubMenuForCoalition(
coalition.side.RED,
"SU-34 anti-ship flights",
nil
)
end
Su34MenuPath[groupName]=missionCommands.addSubMenuForCoalition(
coalition.side.RED,
"Flight "..groupName,
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
if Su34MenuPath[groupName]then
missionCommands.removeItemForCoalition(coalition.side.RED,Su34MenuPath[groupName])
end
end
end
function ChooseInfantry(TeleportPrefixTable,TeleportMax)
TeleportPrefixTableCount=#TeleportPrefixTable
TeleportPrefixTableIndex=math.random(1,TeleportPrefixTableCount)
local TeleportFound=false
local TeleportLoop=true
local Index=TeleportPrefixTableIndex
local TeleportPrefix=''
while TeleportLoop do
TeleportPrefix=TeleportPrefixTable[Index]
if SpawnSettings[TeleportPrefix]then
if SpawnSettings[TeleportPrefix]['SpawnCount']-1<TeleportMax then
SpawnSettings[TeleportPrefix]['SpawnCount']=SpawnSettings[TeleportPrefix]['SpawnCount']+1
TeleportFound=true
else
TeleportFound=false
end
else
SpawnSettings[TeleportPrefix]={}
SpawnSettings[TeleportPrefix]['SpawnCount']=0
TeleportFound=true
end
if TeleportFound then
TeleportLoop=false
else
if Index<TeleportPrefixTableCount then
Index=Index+1
else
TeleportLoop=false
end
end
end
if TeleportFound==false then
TeleportLoop=true
Index=1
while TeleportLoop do
TeleportPrefix=TeleportPrefixTable[Index]
if SpawnSettings[TeleportPrefix]then
if SpawnSettings[TeleportPrefix]['SpawnCount']-1<TeleportMax then
SpawnSettings[TeleportPrefix]['SpawnCount']=SpawnSettings[TeleportPrefix]['SpawnCount']+1
TeleportFound=true
else
TeleportFound=false
end
else
SpawnSettings[TeleportPrefix]={}
SpawnSettings[TeleportPrefix]['SpawnCount']=0
TeleportFound=true
end
if TeleportFound then
TeleportLoop=false
else
if Index<TeleportPrefixTableIndex then
Index=Index+1
else
TeleportLoop=false
end
end
end
end
local TeleportGroupName=''
if TeleportFound==true then
TeleportGroupName=TeleportPrefix..string.format("#%03d",SpawnSettings[TeleportPrefix]['SpawnCount'])
else
TeleportGroupName=''
end
return TeleportGroupName
end
SpawnedInfantry=0
function LandCarrier(CarrierGroup,LandingZonePrefix)
local controllerGroup=CarrierGroup:getController()
local LandingZone=trigger.misc.getZone(LandingZonePrefix)
local LandingZonePos={}
LandingZonePos.x=LandingZone.point.x+math.random(LandingZone.radius*-1,LandingZone.radius)
LandingZonePos.y=LandingZone.point.z+math.random(LandingZone.radius*-1,LandingZone.radius)
controllerGroup:pushTask({id='Land',params={point=LandingZonePos,durationFlag=true,duration=10}})
end
EscortCount=0
function EscortCarrier(CarrierGroup,EscortPrefix,EscortLastWayPoint,EscortEngagementDistanceMax,EscortTargetTypes)
local CarrierName=CarrierGroup:getName()
local EscortMission={}
local CarrierMission={}
local EscortMission=SpawnMissionGroup(EscortPrefix)
local CarrierMission=SpawnMissionGroup(CarrierGroup:getName())
if EscortMission~=nil and CarrierMission~=nil then
EscortCount=EscortCount+1
EscortMissionName=string.format(EscortPrefix..'#Escort %s',CarrierName)
EscortMission.name=EscortMissionName
EscortMission.groupId=nil
EscortMission.lateActivation=false
EscortMission.taskSelected=false
local EscortUnits=#EscortMission.units
for u=1,EscortUnits do
EscortMission.units[u].name=string.format(EscortPrefix..'#Escort %s %02d',CarrierName,u)
EscortMission.units[u].unitId=nil
end
EscortMission.route.points[1].task={id="ComboTask",
params=
{
tasks=
{
[1]=
{
enabled=true,
auto=false,
id="Escort",
number=1,
params=
{
lastWptIndexFlagChangedManually=false,
groupId=CarrierGroup:getID(),
lastWptIndex=nil,
lastWptIndexFlag=false,
engagementDistMax=EscortEngagementDistanceMax,
targetTypes=EscortTargetTypes,
pos=
{
y=20,
x=20,
z=0,
}
}
}
}
}
}
SpawnGroupAdd(EscortPrefix,EscortMission)
end
end
function SendMessageToCarrier(CarrierGroup,CarrierMessage)
if CarrierGroup~=nil then
MessageToGroup(CarrierGroup,CarrierMessage,30,'Carrier/'..CarrierGroup:getName())
end
end
function MessageToGroup(MsgGroup,MsgText,MsgTime,MsgName)
if type(MsgGroup)=='string'then
MsgGroup=Group.getByName(MsgGroup)
end
if MsgGroup~=nil then
local MsgTable={}
MsgTable.text=MsgText
MsgTable.displayTime=MsgTime
MsgTable.msgFor={units={MsgGroup:getUnits()[1]:getName()}}
MsgTable.name=MsgName
end
end
function MessageToUnit(UnitName,MsgText,MsgTime,MsgName)
if UnitName~=nil then
local MsgTable={}
MsgTable.text=MsgText
MsgTable.displayTime=MsgTime
MsgTable.msgFor={units={UnitName}}
MsgTable.name=MsgName
end
end
function MessageToAll(MsgText,MsgTime,MsgName)
MESSAGE:New(MsgText,MsgTime,"Message"):ToCoalition(coalition.side.RED):ToCoalition(coalition.side.BLUE)
end
function MessageToRed(MsgText,MsgTime,MsgName)
MESSAGE:New(MsgText,MsgTime,"To Red Coalition"):ToCoalition(coalition.side.RED)
end
function MessageToBlue(MsgText,MsgTime,MsgName)
MESSAGE:New(MsgText,MsgTime,"To Blue Coalition"):ToCoalition(coalition.side.RED)
end
function getCarrierHeight(CarrierGroup)
if CarrierGroup~=nil then
if table.getn(CarrierGroup:getUnits())==1 then
local CarrierUnit=CarrierGroup:getUnits()[1]
local CurrentPoint=CarrierUnit:getPoint()
local CurrentPosition={x=CurrentPoint.x,y=CurrentPoint.z}
local CarrierHeight=CurrentPoint.y
local LandHeight=land.getHeight(CurrentPosition)
return CarrierHeight-LandHeight
else
return 999999
end
else
return 999999
end
end
function GetUnitHeight(CheckUnit)
local UnitPoint=CheckUnit:getPoint()
local UnitPosition={x=CurrentPoint.x,y=CurrentPoint.z}
local UnitHeight=CurrentPoint.y
local LandHeight=land.getHeight(CurrentPosition)
return UnitHeight-LandHeight
end
_MusicTable={}
_MusicTable.Files={}
_MusicTable.Queue={}
_MusicTable.FileCnt=0
function MusicRegister(SndRef,SndFile,SndTime)
env.info(('MusicRegister: SndRef = '..SndRef))
env.info(('MusicRegister: SndFile = '..SndFile))
env.info(('MusicRegister: SndTime = '..SndTime))
_MusicTable.FileCnt=_MusicTable.FileCnt+1
_MusicTable.Files[_MusicTable.FileCnt]={}
_MusicTable.Files[_MusicTable.FileCnt].Ref=SndRef
_MusicTable.Files[_MusicTable.FileCnt].File=SndFile
_MusicTable.Files[_MusicTable.FileCnt].Time=SndTime
if not _MusicTable.Function then
_MusicTable.Function=routines.scheduleFunction(MusicScheduler,{},timer.getTime()+10,10)
end
end
function MusicToPlayer(SndRef,PlayerName,SndContinue)
local PlayerUnits=AlivePlayerUnits()
for PlayerUnitIdx,PlayerUnit in pairs(PlayerUnits)do
local PlayerUnitName=PlayerUnit:getPlayerName()
if PlayerName==PlayerUnitName then
PlayerGroup=PlayerUnit:getGroup()
if PlayerGroup then
MusicToGroup(SndRef,PlayerGroup,SndContinue)
end
break
end
end
end
function MusicToGroup(SndRef,SndGroup,SndContinue)
if SndGroup~=nil then
if _MusicTable and _MusicTable.FileCnt>0 then
if SndGroup:isExist()then
if MusicCanStart(SndGroup:getUnit(1):getPlayerName())then
local SndIdx=0
if SndRef==''then
SndIdx=math.random(1,_MusicTable.FileCnt)
else
for SndIdx=1,_MusicTable.FileCnt do
if _MusicTable.Files[SndIdx].Ref==SndRef then
break
end
end
end
trigger.action.outSoundForGroup(SndGroup:getID(),_MusicTable.Files[SndIdx].File)
MessageToGroup(SndGroup,'Playing '.._MusicTable.Files[SndIdx].File,15,'Music-'..SndGroup:getUnit(1):getPlayerName())
local SndQueueRef=SndGroup:getUnit(1):getPlayerName()
if _MusicTable.Queue[SndQueueRef]==nil then
_MusicTable.Queue[SndQueueRef]={}
end
_MusicTable.Queue[SndQueueRef].Start=timer.getTime()
_MusicTable.Queue[SndQueueRef].PlayerName=SndGroup:getUnit(1):getPlayerName()
_MusicTable.Queue[SndQueueRef].Group=SndGroup
_MusicTable.Queue[SndQueueRef].ID=SndGroup:getID()
_MusicTable.Queue[SndQueueRef].Ref=SndIdx
_MusicTable.Queue[SndQueueRef].Continue=SndContinue
_MusicTable.Queue[SndQueueRef].Type=Group
end
end
end
end
end
function MusicCanStart(PlayerName)
local MusicOut=false
if _MusicTable['Queue']~=nil and _MusicTable.FileCnt>0 then
local PlayerFound=false
local MusicStart=0
local MusicTime=0
for SndQueueIdx,SndQueue in pairs(_MusicTable.Queue)do
if SndQueue.PlayerName==PlayerName then
PlayerFound=true
MusicStart=SndQueue.Start
MusicTime=_MusicTable.Files[SndQueue.Ref].Time
break
end
end
if PlayerFound then
if MusicStart+MusicTime<=timer.getTime()then
MusicOut=true
end
else
MusicOut=true
end
end
if MusicOut then
else
end
return MusicOut
end
function MusicScheduler()
if _MusicTable['Queue']~=nil and _MusicTable.FileCnt>0 then
for SndQueueIdx,SndQueue in pairs(_MusicTable.Queue)do
if SndQueue.Continue then
if MusicCanStart(SndQueue.PlayerName)then
MusicToPlayer('',SndQueue.PlayerName,true)
end
end
end
end
end
env.info(('Init: Scripts Loaded v1.1'))
SMOKECOLOR=trigger.smokeColor
FLARECOLOR=trigger.flareColor
UTILS={
_MarkID=1
}
UTILS.IsInstanceOf=function(object,className)
if not type(className)=='string'then
if type(className)=='table'and className.IsInstanceOf~=nil then
className=className.ClassName
else
local err_str='className parameter should be a string; parameter received: '..type(className)
self:E(err_str)
return false
end
end
if type(object)=='table'and object.IsInstanceOf~=nil then
return object:IsInstanceOf(className)
else
local basicDataTypes={'string','number','function','boolean','nil','table'}
for _,basicDataType in ipairs(basicDataTypes)do
if className==basicDataType then
return type(object)==basicDataType
end
end
end
return false
end
UTILS.DeepCopy=function(object)
local lookup_table={}
local function _copy(object)
if type(object)~="table"then
return object
elseif lookup_table[object]then
return lookup_table[object]
end
local new_table={}
lookup_table[object]=new_table
for index,value in pairs(object)do
new_table[_copy(index)]=_copy(value)
end
return setmetatable(new_table,getmetatable(object))
end
local objectreturn=_copy(object)
return objectreturn
end
UTILS.OneLineSerialize=function(tbl)
lookup_table={}
local function _Serialize(tbl)
if type(tbl)=='table'then
if lookup_table[tbl]then
return lookup_table[object]
end
local tbl_str={}
lookup_table[tbl]=tbl_str
tbl_str[#tbl_str+1]='{'
for ind,val in pairs(tbl)do
local ind_str={}
if type(ind)=="number"then
ind_str[#ind_str+1]='['
ind_str[#ind_str+1]=tostring(ind)
ind_str[#ind_str+1]=']='
else
ind_str[#ind_str+1]='['
ind_str[#ind_str+1]=routines.utils.basicSerialize(ind)
ind_str[#ind_str+1]=']='
end
local val_str={}
if((type(val)=='number')or(type(val)=='boolean'))then
val_str[#val_str+1]=tostring(val)
val_str[#val_str+1]=','
tbl_str[#tbl_str+1]=table.concat(ind_str)
tbl_str[#tbl_str+1]=table.concat(val_str)
elseif type(val)=='string'then
val_str[#val_str+1]=routines.utils.basicSerialize(val)
val_str[#val_str+1]=','
tbl_str[#tbl_str+1]=table.concat(ind_str)
tbl_str[#tbl_str+1]=table.concat(val_str)
elseif type(val)=='nil'then
val_str[#val_str+1]='nil,'
tbl_str[#tbl_str+1]=table.concat(ind_str)
tbl_str[#tbl_str+1]=table.concat(val_str)
elseif type(val)=='table'then
if ind=="__index"then
else
val_str[#val_str+1]=_Serialize(val)
val_str[#val_str+1]=','
tbl_str[#tbl_str+1]=table.concat(ind_str)
tbl_str[#tbl_str+1]=table.concat(val_str)
end
elseif type(val)=='function'then
tbl_str[#tbl_str+1]="f() "..tostring(ind)
tbl_str[#tbl_str+1]=','
else
env.info('unable to serialize value type '..routines.utils.basicSerialize(type(val))..' at index '..tostring(ind))
env.info(debug.traceback())
end
end
tbl_str[#tbl_str+1]='}'
return table.concat(tbl_str)
else
return tostring(tbl)
end
end
local objectreturn=_Serialize(tbl)
return objectreturn
end
UTILS.BasicSerialize=function(s)
if s==nil then
return"\"\""
else
if((type(s)=='number')or(type(s)=='boolean')or(type(s)=='function')or(type(s)=='table')or(type(s)=='userdata'))then
return tostring(s)
elseif type(s)=='string'then
s=string.format('%q',s)
return s
end
end
end
UTILS.ToDegree=function(angle)
return angle*180/math.pi
end
UTILS.ToRadian=function(angle)
return angle*math.pi/180
end
UTILS.MetersToNM=function(meters)
return meters/1852
end
UTILS.MetersToFeet=function(meters)
return meters/0.3048
end
UTILS.NMToMeters=function(NM)
return NM*1852
end
UTILS.FeetToMeters=function(feet)
return feet*0.3048
end
UTILS.MpsToKnots=function(mps)
return mps*3600/1852
end
UTILS.MpsToKmph=function(mps)
return mps*3.6
end
UTILS.KnotsToMps=function(knots)
return knots*1852/3600
end
UTILS.KnotsToKmph=function(knots)
return knots*1.852
end
UTILS.KmphToMps=function(kmph)
return kmph/3.6
end
UTILS.tostringLL=function(lat,lon,acc,DMS)
local latHemi,lonHemi
if lat>0 then
latHemi='N'
else
latHemi='S'
end
if lon>0 then
lonHemi='E'
else
lonHemi='W'
end
lat=math.abs(lat)
lon=math.abs(lon)
local latDeg=math.floor(lat)
local latMin=(lat-latDeg)*60
local lonDeg=math.floor(lon)
local lonMin=(lon-lonDeg)*60
if DMS then
local oldLatMin=latMin
latMin=math.floor(latMin)
local latSec=UTILS.Round((oldLatMin-latMin)*60,acc)
local oldLonMin=lonMin
lonMin=math.floor(lonMin)
local lonSec=UTILS.Round((oldLonMin-lonMin)*60,acc)
if latSec==60 then
latSec=0
latMin=latMin+1
end
if lonSec==60 then
lonSec=0
lonMin=lonMin+1
end
local secFrmtStr
secFrmtStr='%02d'
return string.format('%02d',latDeg)..' '..string.format('%02d',latMin)..'\' '..string.format(secFrmtStr,latSec)..'"'..latHemi..'   '
..string.format('%02d',lonDeg)..' '..string.format('%02d',lonMin)..'\' '..string.format(secFrmtStr,lonSec)..'"'..lonHemi
else
latMin=UTILS.Round(latMin,acc)
lonMin=UTILS.Round(lonMin,acc)
if latMin==60 then
latMin=0
latDeg=latDeg+1
end
if lonMin==60 then
lonMin=0
lonDeg=lonDeg+1
end
local minFrmtStr
if acc<=0 then
minFrmtStr='%02d'
else
local width=3+acc
minFrmtStr='%0'..width..'.'..acc..'f'
end
return string.format('%02d',latDeg)..' '..string.format(minFrmtStr,latMin)..'\''..latHemi..'   '
..string.format('%02d',lonDeg)..' '..string.format(minFrmtStr,lonMin)..'\''..lonHemi
end
end
UTILS.tostringMGRS=function(MGRS,acc)
if acc==0 then
return MGRS.UTMZone..' '..MGRS.MGRSDigraph
else
return MGRS.UTMZone..' '..MGRS.MGRSDigraph..' '..string.format('%0'..acc..'d',UTILS.Round(MGRS.Easting/(10^(5-acc)),0))
..' '..string.format('%0'..acc..'d',UTILS.Round(MGRS.Northing/(10^(5-acc)),0))
end
end
function UTILS.Round(num,idp)
local mult=10^(idp or 0)
return math.floor(num*mult+0.5)/mult
end
function UTILS.DoString(s)
local f,err=loadstring(s)
if f then
return true,f()
else
return false,err
end
end
function UTILS.spairs(t,order)
local keys={}
for k in pairs(t)do keys[#keys+1]=k end
if order then
table.sort(keys,function(a,b)return order(t,a,b)end)
else
table.sort(keys)
end
local i=0
return function()
i=i+1
if keys[i]then
return keys[i],t[keys[i]]
end
end
end
function UTILS.GetMarkID()
UTILS._MarkID=UTILS._MarkID+1
return UTILS._MarkID
end
function UTILS.IsInRadius(InVec2,Vec2,Radius)
local InRadius=((InVec2.x-Vec2.x)^2+(InVec2.y-Vec2.y)^2)^0.5<=Radius
return InRadius
end
function UTILS.IsInSphere(InVec3,Vec3,Radius)
local InSphere=((InVec3.x-Vec3.x)^2+(InVec3.y-Vec3.y)^2+(InVec3.z-Vec3.z)^2)^0.5<=Radius
return InSphere
end
local _TraceOnOff=true
local _TraceLevel=1
local _TraceAll=false
local _TraceClass={}
local _TraceClassMethod={}
local _ClassID=0
BASE={
ClassName="BASE",
ClassID=0,
Events={},
States={},
}
BASE.__={}
BASE._={
Schedules={}
}
FORMATION={
Cone="Cone",
Vee="Vee"
}
function BASE:New()
local self=routines.utils.deepCopy(self)
_ClassID=_ClassID+1
self.ClassID=_ClassID
return self
end
function BASE:Inherit(Child,Parent)
local Child=routines.utils.deepCopy(Child)
if Child~=nil then
if rawget(Child,"__")then
setmetatable(Child,{__index=Child.__})
setmetatable(Child.__,{__index=Parent})
else
setmetatable(Child,{__index=Parent})
end
end
return Child
end
local function getParent(Child)
local Parent=nil
if Child.ClassName=='BASE'then
Parent=nil
else
if rawget(Child,"__")then
Parent=getmetatable(Child.__).__index
else
Parent=getmetatable(Child).__index
end
end
return Parent
end
function BASE:GetParent(Child,FromClass)
local Parent
if Child.ClassName=='BASE'then
Parent=nil
else
self:E({FromClass=FromClass})
self:E({Child=Child.ClassName})
if FromClass then
while(Child.ClassName~="BASE"and Child.ClassName~=FromClass.ClassName)do
Child=getParent(Child)
self:E({Child.ClassName})
end
end
if Child.ClassName=='BASE'then
Parent=nil
else
Parent=getParent(Child)
end
end
self:E({Parent.ClassName})
return Parent
end
function BASE:IsInstanceOf(ClassName)
if type(ClassName)~='string'then
if type(ClassName)=='table'and ClassName.ClassName~=nil then
ClassName=ClassName.ClassName
else
local err_str='className parameter should be a string; parameter received: '..type(ClassName)
self:E(err_str)
return false
end
end
ClassName=string.upper(ClassName)
if string.upper(self.ClassName)==ClassName then
return true
end
local Parent=getParent(self)
while Parent do
if string.upper(Parent.ClassName)==ClassName then
return true
end
Parent=getParent(Parent)
end
return false
end
function BASE:GetClassNameAndID()
return string.format('%s#%09d',self.ClassName,self.ClassID)
end
function BASE:GetClassName()
return self.ClassName
end
function BASE:GetClassID()
return self.ClassID
end
do
function BASE:EventDispatcher()
return _EVENTDISPATCHER
end
function BASE:GetEventPriority()
return self._.EventPriority or 5
end
function BASE:SetEventPriority(EventPriority)
self._.EventPriority=EventPriority
end
function BASE:EventRemoveAll()
self:EventDispatcher():RemoveAll(self)
return self
end
function BASE:HandleEvent(Event,EventFunction)
self:EventDispatcher():OnEventGeneric(EventFunction,self,Event)
return self
end
function BASE:UnHandleEvent(Event)
self:EventDispatcher():RemoveEvent(self,Event)
return self
end
end
function BASE:CreateEventBirth(EventTime,Initiator,IniUnitName,place,subplace)
self:F({EventTime,Initiator,IniUnitName,place,subplace})
local Event={
id=world.event.S_EVENT_BIRTH,
time=EventTime,
initiator=Initiator,
IniUnitName=IniUnitName,
place=place,
subplace=subplace
}
world.onEvent(Event)
end
function BASE:CreateEventCrash(EventTime,Initiator)
self:F({EventTime,Initiator})
local Event={
id=world.event.S_EVENT_CRASH,
time=EventTime,
initiator=Initiator,
}
world.onEvent(Event)
end
function BASE:CreateEventTakeoff(EventTime,Initiator)
self:F({EventTime,Initiator})
local Event={
id=world.event.S_EVENT_TAKEOFF,
time=EventTime,
initiator=Initiator,
}
world.onEvent(Event)
end
function BASE:onEvent(event)
if self then
for EventID,EventObject in pairs(self.Events)do
if EventObject.EventEnabled then
if event.id==EventObject.Event then
if self==EventObject.Self then
if event.initiator and event.initiator:isExist()then
event.IniUnitName=event.initiator:getName()
end
if event.target and event.target:isExist()then
event.TgtUnitName=event.target:getName()
end
end
end
end
end
end
end
do
function BASE:ScheduleOnce(Start,SchedulerFunction,...)
self:F2({Start})
self:T3({...})
local ObjectName="-"
ObjectName=self.ClassName..self.ClassID
self:F3({"ScheduleOnce: ",ObjectName,Start})
self.SchedulerObject=self
local ScheduleID=_SCHEDULEDISPATCHER:AddSchedule(
self,
SchedulerFunction,
{...},
Start,
nil,
nil,
nil
)
self._.Schedules[#self.Schedules+1]=ScheduleID
return self._.Schedules
end
function BASE:ScheduleRepeat(Start,Repeat,RandomizeFactor,Stop,SchedulerFunction,...)
self:F2({Start})
self:T3({...})
local ObjectName="-"
ObjectName=self.ClassName..self.ClassID
self:F3({"ScheduleRepeat: ",ObjectName,Start,Repeat,RandomizeFactor,Stop})
self.SchedulerObject=self
local ScheduleID=_SCHEDULEDISPATCHER:AddSchedule(
self,
SchedulerFunction,
{...},
Start,
Repeat,
RandomizeFactor,
Stop
)
self._.Schedules[SchedulerFunction]=ScheduleID
return self._.Schedules
end
function BASE:ScheduleStop(SchedulerFunction)
self:F3({"ScheduleStop:"})
_SCHEDULEDISPATCHER:Stop(self,self._.Schedules[SchedulerFunction])
end
end
function BASE:SetState(Object,Key,Value)
local ClassNameAndID=Object:GetClassNameAndID()
self.States[ClassNameAndID]=self.States[ClassNameAndID]or{}
self.States[ClassNameAndID][Key]=Value
return self.States[ClassNameAndID][Key]
end
function BASE:GetState(Object,Key)
local ClassNameAndID=Object:GetClassNameAndID()
if self.States[ClassNameAndID]then
local Value=self.States[ClassNameAndID][Key]or false
return Value
end
return nil
end
function BASE:ClearState(Object,StateName)
local ClassNameAndID=Object:GetClassNameAndID()
if self.States[ClassNameAndID]then
self.States[ClassNameAndID][StateName]=nil
end
end
function BASE:TraceOnOff(TraceOnOff)
_TraceOnOff=TraceOnOff
end
function BASE:IsTrace()
if debug and(_TraceAll==true)or(_TraceClass[self.ClassName]or _TraceClassMethod[self.ClassName])then
return true
else
return false
end
end
function BASE:TraceLevel(Level)
_TraceLevel=Level
self:E("Tracing level "..Level)
end
function BASE:TraceAll(TraceAll)
_TraceAll=TraceAll
if _TraceAll then
self:E("Tracing all methods in MOOSE ")
else
self:E("Switched off tracing all methods in MOOSE")
end
end
function BASE:TraceClass(Class)
_TraceClass[Class]=true
_TraceClassMethod[Class]={}
self:E("Tracing class "..Class)
end
function BASE:TraceClassMethod(Class,Method)
if not _TraceClassMethod[Class]then
_TraceClassMethod[Class]={}
_TraceClassMethod[Class].Method={}
end
_TraceClassMethod[Class].Method[Method]=true
self:E("Tracing method "..Method.." of class "..Class)
end
function BASE:_F(Arguments,DebugInfoCurrentParam,DebugInfoFromParam)
if debug and(_TraceAll==true)or(_TraceClass[self.ClassName]or _TraceClassMethod[self.ClassName])then
local DebugInfoCurrent=DebugInfoCurrentParam and DebugInfoCurrentParam or debug.getinfo(2,"nl")
local DebugInfoFrom=DebugInfoFromParam and DebugInfoFromParam or debug.getinfo(3,"l")
local Function="function"
if DebugInfoCurrent.name then
Function=DebugInfoCurrent.name
end
if _TraceAll==true or _TraceClass[self.ClassName]or _TraceClassMethod[self.ClassName].Method[Function]then
local LineCurrent=0
if DebugInfoCurrent.currentline then
LineCurrent=DebugInfoCurrent.currentline
end
local LineFrom=0
if DebugInfoFrom then
LineFrom=DebugInfoFrom.currentline
end
env.info(string.format("%6d(%6d)/%1s:%20s%05d.%s(%s)",LineCurrent,LineFrom,"F",self.ClassName,self.ClassID,Function,routines.utils.oneLineSerialize(Arguments)))
end
end
end
function BASE:F(Arguments)
if debug and _TraceOnOff then
local DebugInfoCurrent=debug.getinfo(2,"nl")
local DebugInfoFrom=debug.getinfo(3,"l")
if _TraceLevel>=1 then
self:_F(Arguments,DebugInfoCurrent,DebugInfoFrom)
end
end
end
function BASE:F2(Arguments)
if debug and _TraceOnOff then
local DebugInfoCurrent=debug.getinfo(2,"nl")
local DebugInfoFrom=debug.getinfo(3,"l")
if _TraceLevel>=2 then
self:_F(Arguments,DebugInfoCurrent,DebugInfoFrom)
end
end
end
function BASE:F3(Arguments)
if debug and _TraceOnOff then
local DebugInfoCurrent=debug.getinfo(2,"nl")
local DebugInfoFrom=debug.getinfo(3,"l")
if _TraceLevel>=3 then
self:_F(Arguments,DebugInfoCurrent,DebugInfoFrom)
end
end
end
function BASE:_T(Arguments,DebugInfoCurrentParam,DebugInfoFromParam)
if debug and(_TraceAll==true)or(_TraceClass[self.ClassName]or _TraceClassMethod[self.ClassName])then
local DebugInfoCurrent=DebugInfoCurrentParam and DebugInfoCurrentParam or debug.getinfo(2,"nl")
local DebugInfoFrom=DebugInfoFromParam and DebugInfoFromParam or debug.getinfo(3,"l")
local Function="function"
if DebugInfoCurrent.name then
Function=DebugInfoCurrent.name
end
if _TraceAll==true or _TraceClass[self.ClassName]or _TraceClassMethod[self.ClassName].Method[Function]then
local LineCurrent=0
if DebugInfoCurrent.currentline then
LineCurrent=DebugInfoCurrent.currentline
end
local LineFrom=0
if DebugInfoFrom then
LineFrom=DebugInfoFrom.currentline
end
env.info(string.format("%6d(%6d)/%1s:%20s%05d.%s",LineCurrent,LineFrom,"T",self.ClassName,self.ClassID,routines.utils.oneLineSerialize(Arguments)))
end
end
end
function BASE:T(Arguments)
if debug and _TraceOnOff then
local DebugInfoCurrent=debug.getinfo(2,"nl")
local DebugInfoFrom=debug.getinfo(3,"l")
if _TraceLevel>=1 then
self:_T(Arguments,DebugInfoCurrent,DebugInfoFrom)
end
end
end
function BASE:T2(Arguments)
if debug and _TraceOnOff then
local DebugInfoCurrent=debug.getinfo(2,"nl")
local DebugInfoFrom=debug.getinfo(3,"l")
if _TraceLevel>=2 then
self:_T(Arguments,DebugInfoCurrent,DebugInfoFrom)
end
end
end
function BASE:T3(Arguments)
if debug and _TraceOnOff then
local DebugInfoCurrent=debug.getinfo(2,"nl")
local DebugInfoFrom=debug.getinfo(3,"l")
if _TraceLevel>=3 then
self:_T(Arguments,DebugInfoCurrent,DebugInfoFrom)
end
end
end
function BASE:E(Arguments)
if debug then
local DebugInfoCurrent=debug.getinfo(2,"nl")
local DebugInfoFrom=debug.getinfo(3,"l")
local Function="function"
if DebugInfoCurrent.name then
Function=DebugInfoCurrent.name
end
local LineCurrent=DebugInfoCurrent.currentline
local LineFrom=-1
if DebugInfoFrom then
LineFrom=DebugInfoFrom.currentline
end
env.info(string.format("%6d(%6d)/%1s:%20s%05d.%s(%s)",LineCurrent,LineFrom,"E",self.ClassName,self.ClassID,Function,routines.utils.oneLineSerialize(Arguments)))
end
end
do
USERFLAG={
ClassName="USERFLAG",
}
function USERFLAG:New(UserFlagName)
local self=BASE:Inherit(self,BASE:New())
self.UserFlagName=UserFlagName
return self
end
function USERFLAG:Set(Number)
trigger.misc.setUserFlag(self.UserFlagName)
return self
end
function USERFLAG:Set(Number)
return trigger.misc.getUserFlag(self.UserFlagName)
end
function USERFLAG:Is(Number)
return trigger.misc.getUserFlag(self.UserFlagName)==Number
end
end
do
USERSOUND={
ClassName="USERSOUND",
}
function USERSOUND:New(UserSoundFileName)
local self=BASE:Inherit(self,BASE:New())
self.UserSoundFileName=UserSoundFileName
return self
end
function USERSOUND:SetFileName(UserSoundFileName)
self.UserSoundFileName=UserSoundFileName
return self
end
function USERSOUND:ToAll()
trigger.action.outSound(self.UserSoundFileName)
return self
end
function USERSOUND:ToCoalition(Coalition)
trigger.action.outSoundForCoalition(Coalition,self.UserSoundFileName)
return self
end
function USERSOUND:ToCountry(Country)
trigger.action.outSoundForCountry(Country,self.UserSoundFileName)
return self
end
function USERSOUND:ToGroup(Group)
trigger.action.outSoundForGroup(Group:GetID(),self.UserSoundFileName)
return self
end
end
REPORT={
ClassName="REPORT",
Title="",
}
function REPORT:New(Title)
local self=BASE:Inherit(self,BASE:New())
self.Report={}
self:SetTitle(Title or"")
self:SetIndent(3)
return self
end
function REPORT:HasText()
return#self.Report>0
end
function REPORT:SetIndent(Indent)
self.Indent=Indent
return self
end
function REPORT:Add(Text)
self.Report[#self.Report+1]=Text
return self
end
function REPORT:AddIndent(Text)
self.Report[#self.Report+1]=string.rep(" ",self.Indent)..Text:gsub("\n","\n"..string.rep(" ",self.Indent))
return self
end
function REPORT:Text(Delimiter)
Delimiter=Delimiter or"\n"
local ReportText=(self.Title~=""and self.Title..Delimiter or self.Title)..table.concat(self.Report,Delimiter)or""
return ReportText
end
function REPORT:SetTitle(Title)
self.Title=Title
return self
end
function REPORT:GetCount()
return#self.Report
end
SCHEDULER={
ClassName="SCHEDULER",
Schedules={},
}
function SCHEDULER:New(SchedulerObject,SchedulerFunction,SchedulerArguments,Start,Repeat,RandomizeFactor,Stop)
local self=BASE:Inherit(self,BASE:New())
self:F2({Start,Repeat,RandomizeFactor,Stop})
local ScheduleID=nil
self.MasterObject=SchedulerObject
if SchedulerFunction then
ScheduleID=self:Schedule(SchedulerObject,SchedulerFunction,SchedulerArguments,Start,Repeat,RandomizeFactor,Stop)
end
return self,ScheduleID
end
function SCHEDULER:Schedule(SchedulerObject,SchedulerFunction,SchedulerArguments,Start,Repeat,RandomizeFactor,Stop)
self:F2({Start,Repeat,RandomizeFactor,Stop})
self:T3({SchedulerArguments})
local ObjectName="-"
if SchedulerObject and SchedulerObject.ClassName and SchedulerObject.ClassID then
ObjectName=SchedulerObject.ClassName..SchedulerObject.ClassID
end
self:F3({"Schedule :",ObjectName,tostring(SchedulerObject),Start,Repeat,RandomizeFactor,Stop})
self.SchedulerObject=SchedulerObject
local ScheduleID=_SCHEDULEDISPATCHER:AddSchedule(
self,
SchedulerFunction,
SchedulerArguments,
Start,
Repeat,
RandomizeFactor,
Stop
)
self.Schedules[#self.Schedules+1]=ScheduleID
return ScheduleID
end
function SCHEDULER:Start(ScheduleID)
self:F3({ScheduleID})
_SCHEDULEDISPATCHER:Start(self,ScheduleID)
end
function SCHEDULER:Stop(ScheduleID)
self:F3({ScheduleID})
_SCHEDULEDISPATCHER:Stop(self,ScheduleID)
end
function SCHEDULER:Remove(ScheduleID)
self:F3({ScheduleID})
_SCHEDULEDISPATCHER:Remove(self,ScheduleID)
end
function SCHEDULER:Clear()
self:F3()
_SCHEDULEDISPATCHER:Clear(self)
end
SCHEDULEDISPATCHER={
ClassName="SCHEDULEDISPATCHER",
CallID=0,
}
function SCHEDULEDISPATCHER:New()
local self=BASE:Inherit(self,BASE:New())
self:F3()
return self
end
function SCHEDULEDISPATCHER:AddSchedule(Scheduler,ScheduleFunction,ScheduleArguments,Start,Repeat,Randomize,Stop)
self:F2({Scheduler,ScheduleFunction,ScheduleArguments,Start,Repeat,Randomize,Stop})
self.CallID=self.CallID+1
local CallID=self.CallID.."#"..(Scheduler.MasterObject and Scheduler.MasterObject.GetClassNameAndID and Scheduler.MasterObject:GetClassNameAndID()or"")or""
self.PersistentSchedulers=self.PersistentSchedulers or{}
self.ObjectSchedulers=self.ObjectSchedulers or setmetatable({},{__mode="v"})
if Scheduler.MasterObject then
self.ObjectSchedulers[CallID]=Scheduler
self:F3({CallID=CallID,ObjectScheduler=tostring(self.ObjectSchedulers[CallID]),MasterObject=tostring(Scheduler.MasterObject)})
else
self.PersistentSchedulers[CallID]=Scheduler
self:F3({CallID=CallID,PersistentScheduler=self.PersistentSchedulers[CallID]})
end
self.Schedule=self.Schedule or setmetatable({},{__mode="k"})
self.Schedule[Scheduler]=self.Schedule[Scheduler]or{}
self.Schedule[Scheduler][CallID]={}
self.Schedule[Scheduler][CallID].Function=ScheduleFunction
self.Schedule[Scheduler][CallID].Arguments=ScheduleArguments
self.Schedule[Scheduler][CallID].StartTime=timer.getTime()+(Start or 0)
self.Schedule[Scheduler][CallID].Start=Start+.1
self.Schedule[Scheduler][CallID].Repeat=Repeat or 0
self.Schedule[Scheduler][CallID].Randomize=Randomize or 0
self.Schedule[Scheduler][CallID].Stop=Stop
self:T3(self.Schedule[Scheduler][CallID])
self.Schedule[Scheduler][CallID].CallHandler=function(CallID)
self:F2(CallID)
local ErrorHandler=function(errmsg)
env.info("Error in timer function: "..errmsg)
if debug~=nil then
env.info(debug.traceback())
end
return errmsg
end
local Scheduler=self.ObjectSchedulers[CallID]
if not Scheduler then
Scheduler=self.PersistentSchedulers[CallID]
end
if Scheduler then
local MasterObject=tostring(Scheduler.MasterObject)
local Schedule=self.Schedule[Scheduler][CallID]
local ScheduleObject=Scheduler.SchedulerObject
local ScheduleFunction=Schedule.Function
local ScheduleArguments=Schedule.Arguments
local Start=Schedule.Start
local Repeat=Schedule.Repeat or 0
local Randomize=Schedule.Randomize or 0
local Stop=Schedule.Stop or 0
local ScheduleID=Schedule.ScheduleID
local Status,Result
if ScheduleObject then
local function Timer()
return ScheduleFunction(ScheduleObject,unpack(ScheduleArguments))
end
Status,Result=xpcall(Timer,ErrorHandler)
else
local function Timer()
return ScheduleFunction(unpack(ScheduleArguments))
end
Status,Result=xpcall(Timer,ErrorHandler)
end
local CurrentTime=timer.getTime()
local StartTime=Schedule.StartTime
self:F3({Master=MasterObject,CurrentTime=CurrentTime,StartTime=StartTime,Start=Start,Repeat=Repeat,Randomize=Randomize,Stop=Stop})
if Status and((Result==nil)or(Result and Result~=false))then
if Repeat~=0 and((Stop==0)or(Stop~=0 and CurrentTime<=StartTime+Stop))then
local ScheduleTime=
CurrentTime+
Repeat+
math.random(
-(Randomize*Repeat/2),
(Randomize*Repeat/2)
)+
0.01
return ScheduleTime
else
self:Stop(Scheduler,CallID)
end
else
self:Stop(Scheduler,CallID)
end
else
self:E("Scheduled obsolete call for CallID: "..CallID)
end
return nil
end
self:Start(Scheduler,CallID)
return CallID
end
function SCHEDULEDISPATCHER:RemoveSchedule(Scheduler,CallID)
self:F2({Remove=CallID,Scheduler=Scheduler})
if CallID then
self:Stop(Scheduler,CallID)
self.Schedule[Scheduler][CallID]=nil
end
end
function SCHEDULEDISPATCHER:Start(Scheduler,CallID)
self:F2({Start=CallID,Scheduler=Scheduler})
if CallID then
local Schedule=self.Schedule[Scheduler]
if not Schedule[CallID].ScheduleID then
Schedule[CallID].StartTime=timer.getTime()
Schedule[CallID].ScheduleID=timer.scheduleFunction(
Schedule[CallID].CallHandler,
CallID,
timer.getTime()+Schedule[CallID].Start
)
end
else
for CallID,Schedule in pairs(self.Schedule[Scheduler]or{})do
self:Start(Scheduler,CallID)
end
end
end
function SCHEDULEDISPATCHER:Stop(Scheduler,CallID)
self:F2({Stop=CallID,Scheduler=Scheduler})
if CallID then
local Schedule=self.Schedule[Scheduler]
if Schedule[CallID].ScheduleID then
timer.removeFunction(Schedule[CallID].ScheduleID)
Schedule[CallID].ScheduleID=nil
end
else
for CallID,Schedule in pairs(self.Schedule[Scheduler]or{})do
self:Stop(Scheduler,CallID)
end
end
end
function SCHEDULEDISPATCHER:Clear(Scheduler)
self:F2({Scheduler=Scheduler})
for CallID,Schedule in pairs(self.Schedule[Scheduler]or{})do
self:Stop(Scheduler,CallID)
end
end
EVENT={
ClassName="EVENT",
ClassID=0,
}
world.event.S_EVENT_NEW_CARGO=world.event.S_EVENT_MAX+1000
world.event.S_EVENT_DELETE_CARGO=world.event.S_EVENT_MAX+1001
EVENTS={
Shot=world.event.S_EVENT_SHOT,
Hit=world.event.S_EVENT_HIT,
Takeoff=world.event.S_EVENT_TAKEOFF,
Land=world.event.S_EVENT_LAND,
Crash=world.event.S_EVENT_CRASH,
Ejection=world.event.S_EVENT_EJECTION,
Refueling=world.event.S_EVENT_REFUELING,
Dead=world.event.S_EVENT_DEAD,
PilotDead=world.event.S_EVENT_PILOT_DEAD,
BaseCaptured=world.event.S_EVENT_BASE_CAPTURED,
MissionStart=world.event.S_EVENT_MISSION_START,
MissionEnd=world.event.S_EVENT_MISSION_END,
TookControl=world.event.S_EVENT_TOOK_CONTROL,
RefuelingStop=world.event.S_EVENT_REFUELING_STOP,
Birth=world.event.S_EVENT_BIRTH,
HumanFailure=world.event.S_EVENT_HUMAN_FAILURE,
EngineStartup=world.event.S_EVENT_ENGINE_STARTUP,
EngineShutdown=world.event.S_EVENT_ENGINE_SHUTDOWN,
PlayerEnterUnit=world.event.S_EVENT_PLAYER_ENTER_UNIT,
PlayerLeaveUnit=world.event.S_EVENT_PLAYER_LEAVE_UNIT,
PlayerComment=world.event.S_EVENT_PLAYER_COMMENT,
ShootingStart=world.event.S_EVENT_SHOOTING_START,
ShootingEnd=world.event.S_EVENT_SHOOTING_END,
NewCargo=world.event.S_EVENT_NEW_CARGO,
DeleteCargo=world.event.S_EVENT_DELETE_CARGO,
}
local _EVENTMETA={
[world.event.S_EVENT_SHOT]={
Order=1,
Side="I",
Event="OnEventShot",
Text="S_EVENT_SHOT"
},
[world.event.S_EVENT_HIT]={
Order=1,
Side="T",
Event="OnEventHit",
Text="S_EVENT_HIT"
},
[world.event.S_EVENT_TAKEOFF]={
Order=1,
Side="I",
Event="OnEventTakeoff",
Text="S_EVENT_TAKEOFF"
},
[world.event.S_EVENT_LAND]={
Order=1,
Side="I",
Event="OnEventLand",
Text="S_EVENT_LAND"
},
[world.event.S_EVENT_CRASH]={
Order=-1,
Side="I",
Event="OnEventCrash",
Text="S_EVENT_CRASH"
},
[world.event.S_EVENT_EJECTION]={
Order=1,
Side="I",
Event="OnEventEjection",
Text="S_EVENT_EJECTION"
},
[world.event.S_EVENT_REFUELING]={
Order=1,
Side="I",
Event="OnEventRefueling",
Text="S_EVENT_REFUELING"
},
[world.event.S_EVENT_DEAD]={
Order=-1,
Side="I",
Event="OnEventDead",
Text="S_EVENT_DEAD"
},
[world.event.S_EVENT_PILOT_DEAD]={
Order=1,
Side="I",
Event="OnEventPilotDead",
Text="S_EVENT_PILOT_DEAD"
},
[world.event.S_EVENT_BASE_CAPTURED]={
Order=1,
Side="I",
Event="OnEventBaseCaptured",
Text="S_EVENT_BASE_CAPTURED"
},
[world.event.S_EVENT_MISSION_START]={
Order=1,
Side="N",
Event="OnEventMissionStart",
Text="S_EVENT_MISSION_START"
},
[world.event.S_EVENT_MISSION_END]={
Order=1,
Side="N",
Event="OnEventMissionEnd",
Text="S_EVENT_MISSION_END"
},
[world.event.S_EVENT_TOOK_CONTROL]={
Order=1,
Side="N",
Event="OnEventTookControl",
Text="S_EVENT_TOOK_CONTROL"
},
[world.event.S_EVENT_REFUELING_STOP]={
Order=1,
Side="I",
Event="OnEventRefuelingStop",
Text="S_EVENT_REFUELING_STOP"
},
[world.event.S_EVENT_BIRTH]={
Order=1,
Side="I",
Event="OnEventBirth",
Text="S_EVENT_BIRTH"
},
[world.event.S_EVENT_HUMAN_FAILURE]={
Order=1,
Side="I",
Event="OnEventHumanFailure",
Text="S_EVENT_HUMAN_FAILURE"
},
[world.event.S_EVENT_ENGINE_STARTUP]={
Order=1,
Side="I",
Event="OnEventEngineStartup",
Text="S_EVENT_ENGINE_STARTUP"
},
[world.event.S_EVENT_ENGINE_SHUTDOWN]={
Order=1,
Side="I",
Event="OnEventEngineShutdown",
Text="S_EVENT_ENGINE_SHUTDOWN"
},
[world.event.S_EVENT_PLAYER_ENTER_UNIT]={
Order=1,
Side="I",
Event="OnEventPlayerEnterUnit",
Text="S_EVENT_PLAYER_ENTER_UNIT"
},
[world.event.S_EVENT_PLAYER_LEAVE_UNIT]={
Order=-1,
Side="I",
Event="OnEventPlayerLeaveUnit",
Text="S_EVENT_PLAYER_LEAVE_UNIT"
},
[world.event.S_EVENT_PLAYER_COMMENT]={
Order=1,
Side="I",
Event="OnEventPlayerComment",
Text="S_EVENT_PLAYER_COMMENT"
},
[world.event.S_EVENT_SHOOTING_START]={
Order=1,
Side="I",
Event="OnEventShootingStart",
Text="S_EVENT_SHOOTING_START"
},
[world.event.S_EVENT_SHOOTING_END]={
Order=1,
Side="I",
Event="OnEventShootingEnd",
Text="S_EVENT_SHOOTING_END"
},
[EVENTS.NewCargo]={
Order=1,
Event="OnEventNewCargo",
Text="S_EVENT_NEW_CARGO"
},
[EVENTS.DeleteCargo]={
Order=1,
Event="OnEventDeleteCargo",
Text="S_EVENT_DELETE_CARGO"
},
}
function EVENT:New()
local self=BASE:Inherit(self,BASE:New())
self:F2()
self.EventHandler=world.addEventHandler(self)
return self
end
function EVENT:Init(EventID,EventClass)
self:F3({_EVENTMETA[EventID].Text,EventClass})
if not self.Events[EventID]then
self.Events[EventID]={}
end
local EventPriority=EventClass:GetEventPriority()
if not self.Events[EventID][EventPriority]then
self.Events[EventID][EventPriority]=setmetatable({},{__mode="k"})
end
if not self.Events[EventID][EventPriority][EventClass]then
self.Events[EventID][EventPriority][EventClass]={}
end
return self.Events[EventID][EventPriority][EventClass]
end
function EVENT:RemoveEvent(EventClass,EventID)
self:F2({"Removing subscription for class: ",EventClass:GetClassNameAndID()})
local EventPriority=EventClass:GetEventPriority()
self.Events=self.Events or{}
self.Events[EventID]=self.Events[EventID]or{}
self.Events[EventID][EventPriority]=self.Events[EventID][EventPriority]or{}
self.Events[EventID][EventPriority][EventClass]=self.Events[EventID][EventPriority][EventClass]
self.Events[EventID][EventPriority][EventClass]=nil
end
function EVENT:Reset(EventObject)
self:E({"Resetting subscriptions for class: ",EventObject:GetClassNameAndID()})
local EventPriority=EventObject:GetEventPriority()
for EventID,EventData in pairs(self.Events)do
if self.EventsDead then
if self.EventsDead[EventID]then
if self.EventsDead[EventID][EventPriority]then
if self.EventsDead[EventID][EventPriority][EventObject]then
self.Events[EventID][EventPriority][EventObject]=self.EventsDead[EventID][EventPriority][EventObject]
end
end
end
end
end
end
function EVENT:RemoveAll(EventObject)
self:F3({EventObject:GetClassNameAndID()})
local EventClass=EventObject:GetClassNameAndID()
local EventPriority=EventClass:GetEventPriority()
for EventID,EventData in pairs(self.Events)do
self.Events[EventID][EventPriority][EventClass]=nil
end
end
function EVENT:OnEventForTemplate(EventTemplate,EventFunction,EventClass,EventID)
self:F2(EventTemplate.name)
for EventUnitID,EventUnit in pairs(EventTemplate.units)do
self:OnEventForUnit(EventUnit.name,EventFunction,EventClass,EventID)
end
return self
end
function EVENT:OnEventGeneric(EventFunction,EventClass,EventID)
self:F2({EventID})
local EventData=self:Init(EventID,EventClass)
EventData.EventFunction=EventFunction
return self
end
function EVENT:OnEventForUnit(UnitName,EventFunction,EventClass,EventID)
self:F2(UnitName)
local EventData=self:Init(EventID,EventClass)
EventData.EventUnit=true
EventData.EventFunction=EventFunction
return self
end
function EVENT:OnEventForGroup(GroupName,EventFunction,EventClass,EventID,...)
self:E(GroupName)
local Event=self:Init(EventID,EventClass)
Event.EventGroup=true
Event.EventFunction=EventFunction
Event.Params=arg
return self
end
do
function EVENT:OnBirthForTemplate(EventTemplate,EventFunction,EventClass)
self:F2(EventTemplate.name)
self:OnEventForTemplate(EventTemplate,EventFunction,EventClass,EVENTS.Birth)
return self
end
end
do
function EVENT:OnCrashForTemplate(EventTemplate,EventFunction,EventClass)
self:F2(EventTemplate.name)
self:OnEventForTemplate(EventTemplate,EventFunction,EventClass,EVENTS.Crash)
return self
end
end
do
function EVENT:OnDeadForTemplate(EventTemplate,EventFunction,EventClass)
self:F2(EventTemplate.name)
self:OnEventForTemplate(EventTemplate,EventFunction,EventClass,EVENTS.Dead)
return self
end
end
do
function EVENT:OnLandForTemplate(EventTemplate,EventFunction,EventClass)
self:F2(EventTemplate.name)
self:OnEventForTemplate(EventTemplate,EventFunction,EventClass,EVENTS.Land)
return self
end
end
do
function EVENT:OnTakeOffForTemplate(EventTemplate,EventFunction,EventClass)
self:F2(EventTemplate.name)
self:OnEventForTemplate(EventTemplate,EventFunction,EventClass,EVENTS.Takeoff)
return self
end
end
do
function EVENT:OnEngineShutDownForTemplate(EventTemplate,EventFunction,EventClass)
self:F2(EventTemplate.name)
self:OnEventForTemplate(EventTemplate,EventFunction,EventClass,EVENTS.EngineShutdown)
return self
end
end
do
function EVENT:CreateEventNewCargo(Cargo)
self:F({Cargo})
local Event={
id=EVENTS.NewCargo,
time=timer.getTime(),
cargo=Cargo,
}
world.onEvent(Event)
end
function EVENT:CreateEventDeleteCargo(Cargo)
self:F({Cargo})
local Event={
id=EVENTS.DeleteCargo,
time=timer.getTime(),
cargo=Cargo,
}
world.onEvent(Event)
end
function EVENT:CreateEventPlayerEnterUnit(PlayerUnit)
self:F({PlayerUnit})
local Event={
id=EVENTS.PlayerEnterUnit,
time=timer.getTime(),
initiator=PlayerUnit:GetDCSObject()
}
world.onEvent(Event)
end
end
function EVENT:onEvent(Event)
local ErrorHandler=function(errmsg)
env.info("Error in SCHEDULER function:"..errmsg)
if debug~=nil then
env.info(debug.traceback())
end
return errmsg
end
local EventMeta=_EVENTMETA[Event.id]
if self and
self.Events and
self.Events[Event.id]and
(Event.initiator~=nil or(Event.initiator==nil and Event.id~=EVENTS.PlayerLeaveUnit))then
if Event.initiator then
Event.IniObjectCategory=Event.initiator:getCategory()
if Event.IniObjectCategory==Object.Category.UNIT then
Event.IniDCSUnit=Event.initiator
Event.IniDCSUnitName=Event.IniDCSUnit:getName()
Event.IniUnitName=Event.IniDCSUnitName
Event.IniDCSGroup=Event.IniDCSUnit:getGroup()
Event.IniUnit=UNIT:FindByName(Event.IniDCSUnitName)
if not Event.IniUnit then
Event.IniUnit=CLIENT:FindByName(Event.IniDCSUnitName,'',true)
end
Event.IniDCSGroupName=""
if Event.IniDCSGroup and Event.IniDCSGroup:isExist()then
Event.IniDCSGroupName=Event.IniDCSGroup:getName()
Event.IniGroup=GROUP:FindByName(Event.IniDCSGroupName)
if Event.IniGroup then
Event.IniGroupName=Event.IniDCSGroupName
end
end
Event.IniPlayerName=Event.IniDCSUnit:getPlayerName()
Event.IniCoalition=Event.IniDCSUnit:getCoalition()
Event.IniTypeName=Event.IniDCSUnit:getTypeName()
Event.IniCategory=Event.IniDCSUnit:getDesc().category
end
if Event.IniObjectCategory==Object.Category.STATIC then
Event.IniDCSUnit=Event.initiator
Event.IniDCSUnitName=Event.IniDCSUnit:getName()
Event.IniUnitName=Event.IniDCSUnitName
Event.IniUnit=STATIC:FindByName(Event.IniDCSUnitName,false)
Event.IniCoalition=Event.IniDCSUnit:getCoalition()
Event.IniCategory=Event.IniDCSUnit:getDesc().category
Event.IniTypeName=Event.IniDCSUnit:getTypeName()
end
if Event.IniObjectCategory==Object.Category.SCENERY then
Event.IniDCSUnit=Event.initiator
Event.IniDCSUnitName=Event.IniDCSUnit:getName()
Event.IniUnitName=Event.IniDCSUnitName
Event.IniUnit=SCENERY:Register(Event.IniDCSUnitName,Event.initiator)
Event.IniCategory=Event.IniDCSUnit:getDesc().category
Event.IniTypeName=Event.initiator:isExist()and Event.IniDCSUnit:getTypeName()or"SCENERY"
end
end
if Event.target then
Event.TgtObjectCategory=Event.target:getCategory()
if Event.TgtObjectCategory==Object.Category.UNIT then
Event.TgtDCSUnit=Event.target
Event.TgtDCSGroup=Event.TgtDCSUnit:getGroup()
Event.TgtDCSUnitName=Event.TgtDCSUnit:getName()
Event.TgtUnitName=Event.TgtDCSUnitName
Event.TgtUnit=UNIT:FindByName(Event.TgtDCSUnitName)
Event.TgtDCSGroupName=""
if Event.TgtDCSGroup and Event.TgtDCSGroup:isExist()then
Event.TgtDCSGroupName=Event.TgtDCSGroup:getName()
Event.TgtGroup=GROUP:FindByName(Event.TgtDCSGroupName)
if Event.TgtGroup then
Event.TgtGroupName=Event.TgtDCSGroupName
end
end
Event.TgtPlayerName=Event.TgtDCSUnit:getPlayerName()
Event.TgtCoalition=Event.TgtDCSUnit:getCoalition()
Event.TgtCategory=Event.TgtDCSUnit:getDesc().category
Event.TgtTypeName=Event.TgtDCSUnit:getTypeName()
end
if Event.TgtObjectCategory==Object.Category.STATIC then
Event.TgtDCSUnit=Event.target
Event.TgtDCSUnitName=Event.TgtDCSUnit:getName()
Event.TgtUnitName=Event.TgtDCSUnitName
Event.TgtUnit=STATIC:FindByName(Event.TgtDCSUnitName)
Event.TgtCoalition=Event.TgtDCSUnit:getCoalition()
Event.TgtCategory=Event.TgtDCSUnit:getDesc().category
Event.TgtTypeName=Event.TgtDCSUnit:getTypeName()
end
if Event.TgtObjectCategory==Object.Category.SCENERY then
Event.TgtDCSUnit=Event.target
Event.TgtDCSUnitName=Event.TgtDCSUnit:getName()
Event.TgtUnitName=Event.TgtDCSUnitName
Event.TgtUnit=SCENERY:Register(Event.TgtDCSUnitName,Event.target)
Event.TgtCategory=Event.TgtDCSUnit:getDesc().category
Event.TgtTypeName=Event.TgtDCSUnit:getTypeName()
end
end
if Event.weapon then
Event.Weapon=Event.weapon
Event.WeaponName=Event.Weapon:getTypeName()
Event.WeaponUNIT=CLIENT:Find(Event.Weapon,'',true)
Event.WeaponPlayerName=Event.WeaponUNIT and Event.Weapon:getPlayerName()
Event.WeaponCoalition=Event.WeaponUNIT and Event.Weapon:getCoalition()
Event.WeaponCategory=Event.WeaponUNIT and Event.Weapon:getDesc().category
Event.WeaponTypeName=Event.WeaponUNIT and Event.Weapon:getTypeName()
end
if Event.cargo then
Event.Cargo=Event.cargo
Event.CargoName=Event.cargo.Name
end
local PriorityOrder=EventMeta.Order
local PriorityBegin=PriorityOrder==-1 and 5 or 1
local PriorityEnd=PriorityOrder==-1 and 1 or 5
if Event.IniObjectCategory~=Object.Category.STATIC then
self:E({EventMeta.Text,Event,Event.IniDCSUnitName,Event.TgtDCSUnitName,PriorityOrder})
end
for EventPriority=PriorityBegin,PriorityEnd,PriorityOrder do
if self.Events[Event.id][EventPriority]then
for EventClass,EventData in pairs(self.Events[Event.id][EventPriority])do
Event.IniGroup=GROUP:FindByName(Event.IniDCSGroupName)
Event.TgtGroup=GROUP:FindByName(Event.TgtDCSGroupName)
if EventData.EventUnit then
if EventClass:IsAlive()or
Event.id==EVENTS.Crash or
Event.id==EVENTS.Dead then
local UnitName=EventClass:GetName()
if(EventMeta.Side=="I"and UnitName==Event.IniDCSUnitName)or
(EventMeta.Side=="T"and UnitName==Event.TgtDCSUnitName)then
if EventData.EventFunction then
if Event.IniObjectCategory~=3 then
self:E({"Calling EventFunction for UNIT ",EventClass:GetClassNameAndID(),", Unit ",Event.IniUnitName,EventPriority})
end
local Result,Value=xpcall(
function()
return EventData.EventFunction(EventClass,Event)
end,ErrorHandler)
else
local EventFunction=EventClass[EventMeta.Event]
if EventFunction and type(EventFunction)=="function"then
if Event.IniObjectCategory~=3 then
self:E({"Calling "..EventMeta.Event.." for Class ",EventClass:GetClassNameAndID(),EventPriority})
end
local Result,Value=xpcall(
function()
return EventFunction(EventClass,Event)
end,ErrorHandler)
end
end
end
else
self:RemoveEvent(EventClass,Event.id)
end
else
if EventData.EventGroup then
if EventClass:IsAlive()or
Event.id==EVENTS.Crash or
Event.id==EVENTS.Dead then
local GroupName=EventClass:GetName()
if(EventMeta.Side=="I"and GroupName==Event.IniDCSGroupName)or
(EventMeta.Side=="T"and GroupName==Event.TgtDCSGroupName)then
if EventData.EventFunction then
if Event.IniObjectCategory~=3 then
self:E({"Calling EventFunction for GROUP ",EventClass:GetClassNameAndID(),", Unit ",Event.IniUnitName,EventPriority})
end
local Result,Value=xpcall(
function()
return EventData.EventFunction(EventClass,Event,unpack(EventData.Params))
end,ErrorHandler)
else
local EventFunction=EventClass[EventMeta.Event]
if EventFunction and type(EventFunction)=="function"then
if Event.IniObjectCategory~=3 then
self:E({"Calling "..EventMeta.Event.." for GROUP ",EventClass:GetClassNameAndID(),EventPriority})
end
local Result,Value=xpcall(
function()
return EventFunction(EventClass,Event,unpack(EventData.Params))
end,ErrorHandler)
end
end
end
else
end
else
if not EventData.EventUnit then
if EventData.EventFunction then
if Event.IniObjectCategory~=3 then
self:F2({"Calling EventFunction for Class ",EventClass:GetClassNameAndID(),EventPriority})
end
local Result,Value=xpcall(
function()
return EventData.EventFunction(EventClass,Event)
end,ErrorHandler)
else
local EventFunction=EventClass[EventMeta.Event]
if EventFunction and type(EventFunction)=="function"then
if Event.IniObjectCategory~=3 then
self:F2({"Calling "..EventMeta.Event.." for Class ",EventClass:GetClassNameAndID(),EventPriority})
end
local Result,Value=xpcall(
function()
local Result,Value=EventFunction(EventClass,Event)
return Result,Value
end,ErrorHandler)
end
end
end
end
end
end
end
end
else
self:E({EventMeta.Text,Event})
end
Event=nil
end
EVENTHANDLER={
ClassName="EVENTHANDLER",
ClassID=0,
}
function EVENTHANDLER:New()
self=BASE:Inherit(self,BASE:New())
return self
end
SETTINGS={
ClassName="SETTINGS",
}
do
function SETTINGS:Set(PlayerName)
if PlayerName==nil then
local self=BASE:Inherit(self,BASE:New())
self:SetMetric()
self:SetA2G_BR()
self:SetA2A_BRAA()
self:SetLL_Accuracy(3)
self:SetMGRS_Accuracy(5)
self:SetMessageTime(MESSAGE.Type.Briefing,180)
self:SetMessageTime(MESSAGE.Type.Detailed,60)
self:SetMessageTime(MESSAGE.Type.Information,30)
self:SetMessageTime(MESSAGE.Type.Overview,60)
self:SetMessageTime(MESSAGE.Type.Update,15)
return self
else
local Settings=_DATABASE:GetPlayerSettings(PlayerName)
if not Settings then
Settings=BASE:Inherit(self,BASE:New())
_DATABASE:SetPlayerSettings(PlayerName,Settings)
end
return Settings
end
end
function SETTINGS:SetMetric()
self.Metric=true
end
function SETTINGS:IsMetric()
return(self.Metric~=nil and self.Metric==true)or(self.Metric==nil and _SETTINGS:IsMetric())
end
function SETTINGS:SetImperial()
self.Metric=false
end
function SETTINGS:IsImperial()
return(self.Metric~=nil and self.Metric==false)or(self.Metric==nil and _SETTINGS:IsMetric())
end
function SETTINGS:SetLL_Accuracy(LL_Accuracy)
self.LL_Accuracy=LL_Accuracy
end
function SETTINGS:GetLL_DDM_Accuracy()
return self.LL_DDM_Accuracy or _SETTINGS:GetLL_DDM_Accuracy()
end
function SETTINGS:SetMGRS_Accuracy(MGRS_Accuracy)
self.MGRS_Accuracy=MGRS_Accuracy
end
function SETTINGS:GetMGRS_Accuracy()
return self.MGRS_Accuracy or _SETTINGS:GetMGRS_Accuracy()
end
function SETTINGS:SetMessageTime(MessageType,MessageTime)
self.MessageTypeTimings=self.MessageTypeTimings or{}
self.MessageTypeTimings[MessageType]=MessageTime
end
function SETTINGS:GetMessageTime(MessageType)
return(self.MessageTypeTimings and self.MessageTypeTimings[MessageType])or _SETTINGS:GetMessageTime(MessageType)
end
function SETTINGS:SetA2G_LL_DMS()
self.A2GSystem="LL DMS"
end
function SETTINGS:SetA2G_LL_DDM()
self.A2GSystem="LL DDM"
end
function SETTINGS:IsA2G_LL_DMS()
return(self.A2GSystem and self.A2GSystem=="LL DMS")or(not self.A2GSystem and _SETTINGS:IsA2G_LL_DMS())
end
function SETTINGS:IsA2G_LL_DDM()
return(self.A2GSystem and self.A2GSystem=="LL DDM")or(not self.A2GSystem and _SETTINGS:IsA2G_LL_DDM())
end
function SETTINGS:SetA2G_MGRS()
self.A2GSystem="MGRS"
end
function SETTINGS:IsA2G_MGRS()
return(self.A2GSystem and self.A2GSystem=="MGRS")or(not self.A2GSystem and _SETTINGS:IsA2G_MGRS())
end
function SETTINGS:SetA2G_BR()
self.A2GSystem="BR"
end
function SETTINGS:IsA2G_BR()
return(self.A2GSystem and self.A2GSystem=="BR")or(not self.A2GSystem and _SETTINGS:IsA2G_BR())
end
function SETTINGS:SetA2A_BRAA()
self.A2ASystem="BRAA"
end
function SETTINGS:IsA2A_BRAA()
self:E({BRA=(self.A2ASystem and self.A2ASystem=="BRAA")or(not self.A2ASystem and _SETTINGS:IsA2A_BRAA())})
return(self.A2ASystem and self.A2ASystem=="BRAA")or(not self.A2ASystem and _SETTINGS:IsA2A_BRAA())
end
function SETTINGS:SetA2A_BULLS()
self.A2ASystem="BULLS"
end
function SETTINGS:IsA2A_BULLS()
return(self.A2ASystem and self.A2ASystem=="BULLS")or(not self.A2ASystem and _SETTINGS:IsA2A_BULLS())
end
function SETTINGS:SetA2A_LL_DMS()
self.A2ASystem="LL DMS"
end
function SETTINGS:SetA2A_LL_DDM()
self.A2ASystem="LL DDM"
end
function SETTINGS:IsA2A_LL_DMS()
return(self.A2ASystem and self.A2ASystem=="LL DMS")or(not self.A2ASystem and _SETTINGS:IsA2A_LL_DMS())
end
function SETTINGS:IsA2A_LL_DDM()
return(self.A2ASystem and self.A2ASystem=="LL DDM")or(not self.A2ASystem and _SETTINGS:IsA2A_LL_DDM())
end
function SETTINGS:SetA2A_MGRS()
self.A2ASystem="MGRS"
end
function SETTINGS:IsA2A_MGRS()
return(self.A2ASystem and self.A2ASystem=="MGRS")or(not self.A2ASystem and _SETTINGS:IsA2A_MGRS())
end
function SETTINGS:SetSystemMenu(MenuGroup,RootMenu)
local MenuText="System Settings"
local MenuTime=timer.getTime()
local SettingsMenu=MENU_GROUP:New(MenuGroup,MenuText,RootMenu):SetTime(MenuTime)
local A2GCoordinateMenu=MENU_GROUP:New(MenuGroup,"A2G Coordinate System",SettingsMenu):SetTime(MenuTime)
if not self:IsA2G_LL_DMS()then
MENU_GROUP_COMMAND:New(MenuGroup,"Lat/Lon Degree Min Sec (LL DMS)",A2GCoordinateMenu,self.A2GMenuSystem,self,MenuGroup,RootMenu,"LL DMS"):SetTime(MenuTime)
end
if not self:IsA2G_LL_DDM()then
MENU_GROUP_COMMAND:New(MenuGroup,"Lat/Lon Degree Dec Min (LL DDM)",A2GCoordinateMenu,self.A2GMenuSystem,self,MenuGroup,RootMenu,"LL DDM"):SetTime(MenuTime)
end
if self:IsA2G_LL_DDM()then
MENU_GROUP_COMMAND:New(MenuGroup,"LL DDM Accuracy 1",A2GCoordinateMenu,self.MenuLL_DDM_Accuracy,self,MenuGroup,RootMenu,1):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"LL DDM Accuracy 2",A2GCoordinateMenu,self.MenuLL_DDM_Accuracy,self,MenuGroup,RootMenu,2):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"LL DDM Accuracy 3",A2GCoordinateMenu,self.MenuLL_DDM_Accuracy,self,MenuGroup,RootMenu,3):SetTime(MenuTime)
end
if not self:IsA2G_BR()then
MENU_GROUP_COMMAND:New(MenuGroup,"Bearing, Range (BR)",A2GCoordinateMenu,self.A2GMenuSystem,self,MenuGroup,RootMenu,"BR"):SetTime(MenuTime)
end
if not self:IsA2G_MGRS()then
MENU_GROUP_COMMAND:New(MenuGroup,"Military Grid (MGRS)",A2GCoordinateMenu,self.A2GMenuSystem,self,MenuGroup,RootMenu,"MGRS"):SetTime(MenuTime)
end
if self:IsA2G_MGRS()then
MENU_GROUP_COMMAND:New(MenuGroup,"MGRS Accuracy 1",A2GCoordinateMenu,self.MenuMGRS_Accuracy,self,MenuGroup,RootMenu,1):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"MGRS Accuracy 2",A2GCoordinateMenu,self.MenuMGRS_Accuracy,self,MenuGroup,RootMenu,2):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"MGRS Accuracy 3",A2GCoordinateMenu,self.MenuMGRS_Accuracy,self,MenuGroup,RootMenu,3):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"MGRS Accuracy 4",A2GCoordinateMenu,self.MenuMGRS_Accuracy,self,MenuGroup,RootMenu,4):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"MGRS Accuracy 5",A2GCoordinateMenu,self.MenuMGRS_Accuracy,self,MenuGroup,RootMenu,5):SetTime(MenuTime)
end
local A2ACoordinateMenu=MENU_GROUP:New(MenuGroup,"A2A Coordinate System",SettingsMenu):SetTime(MenuTime)
if not self:IsA2A_LL_DMS()then
MENU_GROUP_COMMAND:New(MenuGroup,"Lat/Lon Degree Min Sec (LL DMS)",A2ACoordinateMenu,self.A2AMenuSystem,self,MenuGroup,RootMenu,"LL DMS"):SetTime(MenuTime)
end
if not self:IsA2A_LL_DDM()then
MENU_GROUP_COMMAND:New(MenuGroup,"Lat/Lon Degree Dec Min (LL DDM)",A2ACoordinateMenu,self.A2AMenuSystem,self,MenuGroup,RootMenu,"LL DDM"):SetTime(MenuTime)
end
if self:IsA2A_LL_DDM()then
MENU_GROUP_COMMAND:New(MenuGroup,"LL DDM Accuracy 1",A2ACoordinateMenu,self.MenuLL_DDM_Accuracy,self,MenuGroup,RootMenu,1):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"LL DDM Accuracy 2",A2ACoordinateMenu,self.MenuLL_DDM_Accuracy,self,MenuGroup,RootMenu,2):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"LL DDM Accuracy 3",A2ACoordinateMenu,self.MenuLL_DDM_Accuracy,self,MenuGroup,RootMenu,3):SetTime(MenuTime)
end
if not self:IsA2A_BULLS()then
MENU_GROUP_COMMAND:New(MenuGroup,"Bullseye (BULLS)",A2ACoordinateMenu,self.A2AMenuSystem,self,MenuGroup,RootMenu,"BULLS"):SetTime(MenuTime)
end
if not self:IsA2A_BRAA()then
MENU_GROUP_COMMAND:New(MenuGroup,"Bearing Range Altitude Aspect (BRAA)",A2ACoordinateMenu,self.A2AMenuSystem,self,MenuGroup,RootMenu,"BRAA"):SetTime(MenuTime)
end
if not self:IsA2A_MGRS()then
MENU_GROUP_COMMAND:New(MenuGroup,"Military Grid (MGRS)",A2ACoordinateMenu,self.A2AMenuSystem,self,MenuGroup,RootMenu,"MGRS"):SetTime(MenuTime)
end
if self:IsA2A_MGRS()then
MENU_GROUP_COMMAND:New(MenuGroup,"MGRS Accuracy 1",A2ACoordinateMenu,self.MenuMGRS_Accuracy,self,MenuGroup,RootMenu,1):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"MGRS Accuracy 2",A2ACoordinateMenu,self.MenuMGRS_Accuracy,self,MenuGroup,RootMenu,2):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"MGRS Accuracy 3",A2ACoordinateMenu,self.MenuMGRS_Accuracy,self,MenuGroup,RootMenu,3):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"MGRS Accuracy 4",A2ACoordinateMenu,self.MenuMGRS_Accuracy,self,MenuGroup,RootMenu,4):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"MGRS Accuracy 5",A2ACoordinateMenu,self.MenuMGRS_Accuracy,self,MenuGroup,RootMenu,5):SetTime(MenuTime)
end
local MetricsMenu=MENU_GROUP:New(MenuGroup,"Measures and Weights System",SettingsMenu):SetTime(MenuTime)
if self:IsMetric()then
MENU_GROUP_COMMAND:New(MenuGroup,"Imperial (Miles,Feet)",MetricsMenu,self.MenuMWSystem,self,MenuGroup,RootMenu,false):SetTime(MenuTime)
end
if self:IsImperial()then
MENU_GROUP_COMMAND:New(MenuGroup,"Metric (Kilometers,Meters)",MetricsMenu,self.MenuMWSystem,self,MenuGroup,RootMenu,true):SetTime(MenuTime)
end
local MessagesMenu=MENU_GROUP:New(MenuGroup,"Messages and Reports",SettingsMenu):SetTime(MenuTime)
local UpdateMessagesMenu=MENU_GROUP:New(MenuGroup,"Update Messages",MessagesMenu):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"Off",UpdateMessagesMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Update,0):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"5 seconds",UpdateMessagesMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Update,5):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"10 seconds",UpdateMessagesMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Update,10):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"15 seconds",UpdateMessagesMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Update,15):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"30 seconds",UpdateMessagesMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Update,30):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"1 minute",UpdateMessagesMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Update,60):SetTime(MenuTime)
local InformationMessagesMenu=MENU_GROUP:New(MenuGroup,"Information Messages",MessagesMenu):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"5 seconds",InformationMessagesMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Information,5):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"10 seconds",InformationMessagesMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Information,10):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"15 seconds",InformationMessagesMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Information,15):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"30 seconds",InformationMessagesMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Information,30):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"1 minute",InformationMessagesMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Information,60):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"2 minutes",InformationMessagesMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Information,120):SetTime(MenuTime)
local BriefingReportsMenu=MENU_GROUP:New(MenuGroup,"Briefing Reports",MessagesMenu):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"15 seconds",BriefingReportsMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Briefing,15):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"30 seconds",BriefingReportsMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Briefing,30):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"1 minute",BriefingReportsMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Briefing,60):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"2 minutes",BriefingReportsMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Briefing,120):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"3 minutes",BriefingReportsMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Briefing,180):SetTime(MenuTime)
local OverviewReportsMenu=MENU_GROUP:New(MenuGroup,"Overview Reports",MessagesMenu):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"15 seconds",OverviewReportsMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Overview,15):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"30 seconds",OverviewReportsMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Overview,30):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"1 minute",OverviewReportsMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Overview,60):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"2 minutes",OverviewReportsMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Overview,120):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"3 minutes",OverviewReportsMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.Overview,180):SetTime(MenuTime)
local DetailedReportsMenu=MENU_GROUP:New(MenuGroup,"Detailed Reports",MessagesMenu):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"15 seconds",DetailedReportsMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.DetailedReportsMenu,15):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"30 seconds",DetailedReportsMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.DetailedReportsMenu,30):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"1 minute",DetailedReportsMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.DetailedReportsMenu,60):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"2 minutes",DetailedReportsMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.DetailedReportsMenu,120):SetTime(MenuTime)
MENU_GROUP_COMMAND:New(MenuGroup,"3 minutes",DetailedReportsMenu,self.MenuMessageTimingsSystem,self,MenuGroup,RootMenu,MESSAGE.Type.DetailedReportsMenu,180):SetTime(MenuTime)
SettingsMenu:Remove(MenuTime)
return self
end
function SETTINGS:SetPlayerMenu(PlayerUnit)
local PlayerGroup=PlayerUnit:GetGroup()
local PlayerName=PlayerUnit:GetPlayerName()
local PlayerNames=PlayerGroup:GetPlayerNames()
local PlayerMenu=MENU_GROUP:New(PlayerGroup,'Settings "'..PlayerName..'"')
self.PlayerMenu=PlayerMenu
local A2GCoordinateMenu=MENU_GROUP:New(PlayerGroup,"A2G Coordinate System",PlayerMenu)
if not self:IsA2G_LL_DMS()then
MENU_GROUP_COMMAND:New(PlayerGroup,"Lat/Lon Degree Min Sec (LL DMS)",A2GCoordinateMenu,self.MenuGroupA2GSystem,self,PlayerUnit,PlayerGroup,PlayerName,"LL DMS")
end
if not self:IsA2G_LL_DDM()then
MENU_GROUP_COMMAND:New(PlayerGroup,"Lat/Lon Degree Dec Min (LL DDM)",A2GCoordinateMenu,self.MenuGroupA2GSystem,self,PlayerUnit,PlayerGroup,PlayerName,"LL DDM")
end
if self:IsA2G_LL_DDM()then
MENU_GROUP_COMMAND:New(PlayerGroup,"LL DDM Accuracy 1",A2GCoordinateMenu,self.MenuGroupLL_DDM_AccuracySystem,self,PlayerUnit,PlayerGroup,PlayerName,1)
MENU_GROUP_COMMAND:New(PlayerGroup,"LL DDM Accuracy 2",A2GCoordinateMenu,self.MenuGroupLL_DDM_AccuracySystem,self,PlayerUnit,PlayerGroup,PlayerName,2)
MENU_GROUP_COMMAND:New(PlayerGroup,"LL DDM Accuracy 3",A2GCoordinateMenu,self.MenuGroupLL_DDM_AccuracySystem,self,PlayerUnit,PlayerGroup,PlayerName,3)
end
if not self:IsA2G_BR()then
MENU_GROUP_COMMAND:New(PlayerGroup,"Bearing, Range (BR)",A2GCoordinateMenu,self.MenuGroupA2GSystem,self,PlayerUnit,PlayerGroup,PlayerName,"BR")
end
if not self:IsA2G_MGRS()then
MENU_GROUP_COMMAND:New(PlayerGroup,"Military Grid (MGRS)",A2GCoordinateMenu,self.MenuGroupA2GSystem,self,PlayerUnit,PlayerGroup,PlayerName,"MGRS")
end
if self:IsA2G_MGRS()then
MENU_GROUP_COMMAND:New(PlayerGroup,"MGRS Accuracy 1",A2GCoordinateMenu,self.MenuGroupMGRS_AccuracySystem,self,PlayerUnit,PlayerGroup,PlayerName,1)
MENU_GROUP_COMMAND:New(PlayerGroup,"MGRS Accuracy 2",A2GCoordinateMenu,self.MenuGroupMGRS_AccuracySystem,self,PlayerUnit,PlayerGroup,PlayerName,2)
MENU_GROUP_COMMAND:New(PlayerGroup,"MGRS Accuracy 3",A2GCoordinateMenu,self.MenuGroupMGRS_AccuracySystem,self,PlayerUnit,PlayerGroup,PlayerName,3)
MENU_GROUP_COMMAND:New(PlayerGroup,"MGRS Accuracy 4",A2GCoordinateMenu,self.MenuGroupMGRS_AccuracySystem,self,PlayerUnit,PlayerGroup,PlayerName,4)
MENU_GROUP_COMMAND:New(PlayerGroup,"MGRS Accuracy 5",A2GCoordinateMenu,self.MenuGroupMGRS_AccuracySystem,self,PlayerUnit,PlayerGroup,PlayerName,5)
end
local A2ACoordinateMenu=MENU_GROUP:New(PlayerGroup,"A2A Coordinate System",PlayerMenu)
if not self:IsA2A_LL_DMS()then
MENU_GROUP_COMMAND:New(PlayerGroup,"Lat/Lon Degree Min Sec (LL DMS)",A2GCoordinateMenu,self.MenuGroupA2GSystem,self,PlayerUnit,PlayerGroup,PlayerName,"LL DMS")
end
if not self:IsA2A_LL_DDM()then
MENU_GROUP_COMMAND:New(PlayerGroup,"Lat/Lon Degree Dec Min (LL DDM)",A2GCoordinateMenu,self.MenuGroupA2GSystem,self,PlayerUnit,PlayerGroup,PlayerName,"LL DDM")
end
if self:IsA2A_LL_DDM()then
MENU_GROUP_COMMAND:New(PlayerGroup,"LL DDM Accuracy 1",A2GCoordinateMenu,self.MenuGroupLL_DDM_AccuracySystem,self,PlayerUnit,PlayerGroup,PlayerName,1)
MENU_GROUP_COMMAND:New(PlayerGroup,"LL DDM Accuracy 2",A2GCoordinateMenu,self.MenuGroupLL_DDM_AccuracySystem,self,PlayerUnit,PlayerGroup,PlayerName,2)
MENU_GROUP_COMMAND:New(PlayerGroup,"LL DDM Accuracy 3",A2GCoordinateMenu,self.MenuGroupLL_DDM_AccuracySystem,self,PlayerUnit,PlayerGroup,PlayerName,3)
end
if not self:IsA2A_BULLS()then
MENU_GROUP_COMMAND:New(PlayerGroup,"Bullseye (BULLS)",A2ACoordinateMenu,self.MenuGroupA2ASystem,self,PlayerUnit,PlayerGroup,PlayerName,"BULLS")
end
if not self:IsA2A_BRAA()then
MENU_GROUP_COMMAND:New(PlayerGroup,"Bearing Range Altitude Aspect (BRAA)",A2ACoordinateMenu,self.MenuGroupA2ASystem,self,PlayerUnit,PlayerGroup,PlayerName,"BRAA")
end
if not self:IsA2A_MGRS()then
MENU_GROUP_COMMAND:New(PlayerGroup,"Military Grid (MGRS)",A2ACoordinateMenu,self.MenuGroupA2ASystem,self,PlayerUnit,PlayerGroup,PlayerName,"MGRS")
end
if self:IsA2A_MGRS()then
MENU_GROUP_COMMAND:New(PlayerGroup,"Military Grid (MGRS) Accuracy 1",A2ACoordinateMenu,self.MenuGroupMGRS_AccuracySystem,self,PlayerUnit,PlayerGroup,PlayerName,1)
MENU_GROUP_COMMAND:New(PlayerGroup,"Military Grid (MGRS) Accuracy 2",A2ACoordinateMenu,self.MenuGroupMGRS_AccuracySystem,self,PlayerUnit,PlayerGroup,PlayerName,2)
MENU_GROUP_COMMAND:New(PlayerGroup,"Military Grid (MGRS) Accuracy 3",A2ACoordinateMenu,self.MenuGroupMGRS_AccuracySystem,self,PlayerUnit,PlayerGroup,PlayerName,3)
MENU_GROUP_COMMAND:New(PlayerGroup,"Military Grid (MGRS) Accuracy 4",A2ACoordinateMenu,self.MenuGroupMGRS_AccuracySystem,self,PlayerUnit,PlayerGroup,PlayerName,4)
MENU_GROUP_COMMAND:New(PlayerGroup,"Military Grid (MGRS) Accuracy 5",A2ACoordinateMenu,self.MenuGroupMGRS_AccuracySystem,self,PlayerUnit,PlayerGroup,PlayerName,5)
end
local MetricsMenu=MENU_GROUP:New(PlayerGroup,"Measures and Weights System",PlayerMenu)
if self:IsMetric()then
MENU_GROUP_COMMAND:New(PlayerGroup,"Imperial (Miles,Feet)",MetricsMenu,self.MenuGroupMWSystem,self,PlayerUnit,PlayerGroup,PlayerName,false)
end
if self:IsImperial()then
MENU_GROUP_COMMAND:New(PlayerGroup,"Metric (Kilometers,Meters)",MetricsMenu,self.MenuGroupMWSystem,self,PlayerUnit,PlayerGroup,PlayerName,true)
end
local MessagesMenu=MENU_GROUP:New(PlayerGroup,"Messages and Reports",PlayerMenu)
local UpdateMessagesMenu=MENU_GROUP:New(PlayerGroup,"Update Messages",MessagesMenu)
MENU_GROUP_COMMAND:New(PlayerGroup,"Off",UpdateMessagesMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Update,0)
MENU_GROUP_COMMAND:New(PlayerGroup,"5 seconds",UpdateMessagesMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Update,5)
MENU_GROUP_COMMAND:New(PlayerGroup,"10 seconds",UpdateMessagesMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Update,10)
MENU_GROUP_COMMAND:New(PlayerGroup,"15 seconds",UpdateMessagesMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Update,15)
MENU_GROUP_COMMAND:New(PlayerGroup,"30 seconds",UpdateMessagesMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Update,30)
MENU_GROUP_COMMAND:New(PlayerGroup,"1 minute",UpdateMessagesMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Update,60)
local InformationMessagesMenu=MENU_GROUP:New(PlayerGroup,"Information Messages",MessagesMenu)
MENU_GROUP_COMMAND:New(PlayerGroup,"5 seconds",InformationMessagesMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Information,5)
MENU_GROUP_COMMAND:New(PlayerGroup,"10 seconds",InformationMessagesMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Information,10)
MENU_GROUP_COMMAND:New(PlayerGroup,"15 seconds",InformationMessagesMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Information,15)
MENU_GROUP_COMMAND:New(PlayerGroup,"30 seconds",InformationMessagesMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Information,30)
MENU_GROUP_COMMAND:New(PlayerGroup,"1 minute",InformationMessagesMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Information,60)
MENU_GROUP_COMMAND:New(PlayerGroup,"2 minutes",InformationMessagesMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Information,120)
local BriefingReportsMenu=MENU_GROUP:New(PlayerGroup,"Briefing Reports",MessagesMenu)
MENU_GROUP_COMMAND:New(PlayerGroup,"15 seconds",BriefingReportsMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Briefing,15)
MENU_GROUP_COMMAND:New(PlayerGroup,"30 seconds",BriefingReportsMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Briefing,30)
MENU_GROUP_COMMAND:New(PlayerGroup,"1 minute",BriefingReportsMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Briefing,60)
MENU_GROUP_COMMAND:New(PlayerGroup,"2 minutes",BriefingReportsMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Briefing,120)
MENU_GROUP_COMMAND:New(PlayerGroup,"3 minutes",BriefingReportsMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Briefing,180)
local OverviewReportsMenu=MENU_GROUP:New(PlayerGroup,"Overview Reports",MessagesMenu)
MENU_GROUP_COMMAND:New(PlayerGroup,"15 seconds",OverviewReportsMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Overview,15)
MENU_GROUP_COMMAND:New(PlayerGroup,"30 seconds",OverviewReportsMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Overview,30)
MENU_GROUP_COMMAND:New(PlayerGroup,"1 minute",OverviewReportsMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Overview,60)
MENU_GROUP_COMMAND:New(PlayerGroup,"2 minutes",OverviewReportsMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Overview,120)
MENU_GROUP_COMMAND:New(PlayerGroup,"3 minutes",OverviewReportsMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.Overview,180)
local DetailedReportsMenu=MENU_GROUP:New(PlayerGroup,"Detailed Reports",MessagesMenu)
MENU_GROUP_COMMAND:New(PlayerGroup,"15 seconds",DetailedReportsMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.DetailedReportsMenu,15)
MENU_GROUP_COMMAND:New(PlayerGroup,"30 seconds",DetailedReportsMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.DetailedReportsMenu,30)
MENU_GROUP_COMMAND:New(PlayerGroup,"1 minute",DetailedReportsMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.DetailedReportsMenu,60)
MENU_GROUP_COMMAND:New(PlayerGroup,"2 minutes",DetailedReportsMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.DetailedReportsMenu,120)
MENU_GROUP_COMMAND:New(PlayerGroup,"3 minutes",DetailedReportsMenu,self.MenuGroupMessageTimingsSystem,self,PlayerUnit,PlayerGroup,PlayerName,MESSAGE.Type.DetailedReportsMenu,180)
return self
end
function SETTINGS:RemovePlayerMenu(PlayerUnit)
if self.PlayerMenu then
self.PlayerMenu:Remove()
end
return self
end
function SETTINGS:A2GMenuSystem(MenuGroup,RootMenu,A2GSystem)
self.A2GSystem=A2GSystem
MESSAGE:New(string.format("Settings: Default A2G coordinate system set to %s for all players!",A2GSystem),5):ToAll()
self:SetSystemMenu(MenuGroup,RootMenu)
end
function SETTINGS:A2AMenuSystem(MenuGroup,RootMenu,A2ASystem)
self.A2ASystem=A2ASystem
MESSAGE:New(string.format("Settings: Default A2A coordinate system set to %s for all players!",A2ASystem),5):ToAll()
self:SetSystemMenu(MenuGroup,RootMenu)
end
function SETTINGS:MenuLL_DDM_Accuracy(MenuGroup,RootMenu,LL_Accuracy)
self.LL_Accuracy=LL_Accuracy
MESSAGE:New(string.format("Settings: Default LL accuracy set to %s for all players!",LL_Accuracy),5):ToAll()
self:SetSystemMenu(MenuGroup,RootMenu)
end
function SETTINGS:MenuMGRS_Accuracy(MenuGroup,RootMenu,MGRS_Accuracy)
self.MGRS_Accuracy=MGRS_Accuracy
MESSAGE:New(string.format("Settings: Default MGRS accuracy set to %s for all players!",MGRS_Accuracy),5):ToAll()
self:SetSystemMenu(MenuGroup,RootMenu)
end
function SETTINGS:MenuMWSystem(MenuGroup,RootMenu,MW)
self.Metric=MW
MESSAGE:New(string.format("Settings: Default measurement format set to %s for all players!",MW and"Metric"or"Imperial"),5):ToAll()
self:SetSystemMenu(MenuGroup,RootMenu)
end
function SETTINGS:MenuMessageTimingsSystem(MenuGroup,RootMenu,MessageType,MessageTime)
self:SetMessageTime(MessageType,MessageTime)
MESSAGE:New(string.format("Settings: Default message time set for %s to %d.",MessageType,MessageTime),5):ToAll()
end
do
function SETTINGS:MenuGroupA2GSystem(PlayerUnit,PlayerGroup,PlayerName,A2GSystem)
BASE:E({self,PlayerUnit:GetName(),A2GSystem})
self.A2GSystem=A2GSystem
MESSAGE:New(string.format("Settings: A2G format set to %s for player %s.",A2GSystem,PlayerName),5):ToGroup(PlayerGroup)
self:RemovePlayerMenu(PlayerUnit)
self:SetPlayerMenu(PlayerUnit)
end
function SETTINGS:MenuGroupA2ASystem(PlayerUnit,PlayerGroup,PlayerName,A2ASystem)
self.A2ASystem=A2ASystem
MESSAGE:New(string.format("Settings: A2A format set to %s for player %s.",A2ASystem,PlayerName),5):ToGroup(PlayerGroup)
self:RemovePlayerMenu(PlayerUnit)
self:SetPlayerMenu(PlayerUnit)
end
function SETTINGS:MenuGroupLL_DDM_AccuracySystem(PlayerUnit,PlayerGroup,PlayerName,LL_Accuracy)
self.LL_Accuracy=LL_Accuracy
MESSAGE:New(string.format("Settings: A2G LL format accuracy set to %d for player %s.",LL_Accuracy,PlayerName),5):ToGroup(PlayerGroup)
self:RemovePlayerMenu(PlayerUnit)
self:SetPlayerMenu(PlayerUnit)
end
function SETTINGS:MenuGroupMGRS_AccuracySystem(PlayerUnit,PlayerGroup,PlayerName,MGRS_Accuracy)
self.MGRS_Accuracy=MGRS_Accuracy
MESSAGE:New(string.format("Settings: A2G MGRS format accuracy set to %d for player %s.",MGRS_Accuracy,PlayerName),5):ToGroup(PlayerGroup)
self:RemovePlayerMenu(PlayerUnit)
self:SetPlayerMenu(PlayerUnit)
end
function SETTINGS:MenuGroupMWSystem(PlayerUnit,PlayerGroup,PlayerName,MW)
self.Metric=MW
MESSAGE:New(string.format("Settings: Measurement format set to %s for player %s.",MW and"Metric"or"Imperial",PlayerName),5):ToGroup(PlayerGroup)
self:RemovePlayerMenu(PlayerUnit)
self:SetPlayerMenu(PlayerUnit)
end
function SETTINGS:MenuGroupMessageTimingsSystem(PlayerUnit,PlayerGroup,PlayerName,MessageType,MessageTime)
self:SetMessageTime(MessageType,MessageTime)
MESSAGE:New(string.format("Settings: Default message time set for %s to %d.",MessageType,MessageTime),5):ToGroup(PlayerGroup)
end
end
end
do
MENU_BASE={
ClassName="MENU_BASE",
MenuPath=nil,
MenuText="",
MenuParentPath=nil
}
function MENU_BASE:New(MenuText,ParentMenu)
local MenuParentPath={}
if ParentMenu~=nil then
MenuParentPath=ParentMenu.MenuPath
end
local self=BASE:Inherit(self,BASE:New())
self.MenuPath=nil
self.MenuText=MenuText
self.MenuParentPath=MenuParentPath
self.Menus={}
self.MenuCount=0
self.MenuRemoveParent=false
self.MenuTime=timer.getTime()
return self
end
function MENU_BASE:GetMenu(MenuText)
self:F2({Menu=self.Menus[MenuText]})
return self.Menus[MenuText]
end
function MENU_BASE:SetRemoveParent(RemoveParent)
self:F2({RemoveParent})
self.MenuRemoveParent=RemoveParent
return self
end
function MENU_BASE:SetTime(MenuTime)
self.MenuTime=MenuTime
return self
end
function MENU_BASE:SetTag(MenuTag)
self.MenuTag=MenuTag
return self
end
end
do
MENU_COMMAND_BASE={
ClassName="MENU_COMMAND_BASE",
CommandMenuFunction=nil,
CommandMenuArgument=nil,
MenuCallHandler=nil,
}
function MENU_COMMAND_BASE:New(MenuText,ParentMenu,CommandMenuFunction,CommandMenuArguments)
local self=BASE:Inherit(self,MENU_BASE:New(MenuText,ParentMenu))
local ErrorHandler=function(errmsg)
env.info("MOOSE error in MENU COMMAND function: "..errmsg)
if debug~=nil then
env.info(debug.traceback())
end
return errmsg
end
self:SetCommandMenuFunction(CommandMenuFunction)
self:SetCommandMenuArguments(CommandMenuArguments)
self.MenuCallHandler=function()
local function MenuFunction()
return self.CommandMenuFunction(unpack(self.CommandMenuArguments))
end
local Status,Result=xpcall(MenuFunction,ErrorHandler)
end
return self
end
function MENU_COMMAND_BASE:SetCommandMenuFunction(CommandMenuFunction)
self.CommandMenuFunction=CommandMenuFunction
return self
end
function MENU_COMMAND_BASE:SetCommandMenuArguments(CommandMenuArguments)
self.CommandMenuArguments=CommandMenuArguments
return self
end
end
do
MENU_MISSION={
ClassName="MENU_MISSION"
}
function MENU_MISSION:New(MenuText,ParentMenu)
local self=BASE:Inherit(self,MENU_BASE:New(MenuText,ParentMenu))
self:F({MenuText,ParentMenu})
self.MenuText=MenuText
self.ParentMenu=ParentMenu
self.Menus={}
self:T({MenuText})
self.MenuPath=missionCommands.addSubMenu(MenuText,self.MenuParentPath)
self:T({self.MenuPath})
if ParentMenu and ParentMenu.Menus then
ParentMenu.Menus[self.MenuPath]=self
end
return self
end
function MENU_MISSION:RemoveSubMenus()
self:F(self.MenuPath)
for MenuID,Menu in pairs(self.Menus)do
Menu:Remove()
end
end
function MENU_MISSION:Remove()
self:F(self.MenuPath)
self:RemoveSubMenus()
missionCommands.removeItem(self.MenuPath)
if self.ParentMenu then
self.ParentMenu.Menus[self.MenuPath]=nil
end
return nil
end
end
do
MENU_MISSION_COMMAND={
ClassName="MENU_MISSION_COMMAND"
}
function MENU_MISSION_COMMAND:New(MenuText,ParentMenu,CommandMenuFunction,...)
local self=BASE:Inherit(self,MENU_COMMAND_BASE:New(MenuText,ParentMenu,CommandMenuFunction,arg))
self.MenuText=MenuText
self.ParentMenu=ParentMenu
self:T({MenuText,CommandMenuFunction,arg})
self.MenuPath=missionCommands.addCommand(MenuText,self.MenuParentPath,self.MenuCallHandler)
ParentMenu.Menus[self.MenuPath]=self
return self
end
function MENU_MISSION_COMMAND:Remove()
self:F(self.MenuPath)
missionCommands.removeItem(self.MenuPath)
if self.ParentMenu then
self.ParentMenu.Menus[self.MenuPath]=nil
end
return nil
end
end
do
MENU_COALITION={
ClassName="MENU_COALITION"
}
function MENU_COALITION:New(Coalition,MenuText,ParentMenu)
local self=BASE:Inherit(self,MENU_BASE:New(MenuText,ParentMenu))
self:F({Coalition,MenuText,ParentMenu})
self.Coalition=Coalition
self.MenuText=MenuText
self.ParentMenu=ParentMenu
self.Menus={}
self:T({MenuText})
self.MenuPath=missionCommands.addSubMenuForCoalition(Coalition,MenuText,self.MenuParentPath)
self:T({self.MenuPath})
if ParentMenu and ParentMenu.Menus then
ParentMenu.Menus[self.MenuPath]=self
end
return self
end
function MENU_COALITION:RemoveSubMenus()
self:F(self.MenuPath)
for MenuID,Menu in pairs(self.Menus)do
Menu:Remove()
end
end
function MENU_COALITION:Remove()
self:F(self.MenuPath)
self:RemoveSubMenus()
missionCommands.removeItemForCoalition(self.Coalition,self.MenuPath)
if self.ParentMenu then
self.ParentMenu.Menus[self.MenuPath]=nil
end
return nil
end
end
do
MENU_COALITION_COMMAND={
ClassName="MENU_COALITION_COMMAND"
}
function MENU_COALITION_COMMAND:New(Coalition,MenuText,ParentMenu,CommandMenuFunction,...)
local self=BASE:Inherit(self,MENU_COMMAND_BASE:New(MenuText,ParentMenu,CommandMenuFunction,arg))
self.MenuCoalition=Coalition
self.MenuText=MenuText
self.ParentMenu=ParentMenu
self:T({MenuText,CommandMenuFunction,arg})
self.MenuPath=missionCommands.addCommandForCoalition(self.MenuCoalition,MenuText,self.MenuParentPath,self.MenuCallHandler)
ParentMenu.Menus[self.MenuPath]=self
return self
end
function MENU_COALITION_COMMAND:Remove()
self:F(self.MenuPath)
missionCommands.removeItemForCoalition(self.MenuCoalition,self.MenuPath)
if self.ParentMenu then
self.ParentMenu.Menus[self.MenuPath]=nil
end
return nil
end
end
do
local _MENUCLIENTS={}
MENU_CLIENT={
ClassName="MENU_CLIENT"
}
function MENU_CLIENT:New(Client,MenuText,ParentMenu)
local MenuParentPath={}
if ParentMenu~=nil then
MenuParentPath=ParentMenu.MenuPath
end
local self=BASE:Inherit(self,MENU_BASE:New(MenuText,MenuParentPath))
self:F({Client,MenuText,ParentMenu})
self.MenuClient=Client
self.MenuClientGroupID=Client:GetClientGroupID()
self.MenuParentPath=MenuParentPath
self.MenuText=MenuText
self.ParentMenu=ParentMenu
self.Menus={}
if not _MENUCLIENTS[self.MenuClientGroupID]then
_MENUCLIENTS[self.MenuClientGroupID]={}
end
local MenuPath=_MENUCLIENTS[self.MenuClientGroupID]
self:T({Client:GetClientGroupName(),MenuPath[table.concat(MenuParentPath)],MenuParentPath,MenuText})
local MenuPathID=table.concat(MenuParentPath).."/"..MenuText
if MenuPath[MenuPathID]then
missionCommands.removeItemForGroup(self.MenuClient:GetClientGroupID(),MenuPath[MenuPathID])
end
self.MenuPath=missionCommands.addSubMenuForGroup(self.MenuClient:GetClientGroupID(),MenuText,MenuParentPath)
MenuPath[MenuPathID]=self.MenuPath
self:T({Client:GetClientGroupName(),self.MenuPath})
if ParentMenu and ParentMenu.Menus then
ParentMenu.Menus[self.MenuPath]=self
end
return self
end
function MENU_CLIENT:RemoveSubMenus()
self:F(self.MenuPath)
for MenuID,Menu in pairs(self.Menus)do
Menu:Remove()
end
end
function MENU_CLIENT:Remove()
self:F(self.MenuPath)
self:RemoveSubMenus()
if not _MENUCLIENTS[self.MenuClientGroupID]then
_MENUCLIENTS[self.MenuClientGroupID]={}
end
local MenuPath=_MENUCLIENTS[self.MenuClientGroupID]
if MenuPath[table.concat(self.MenuParentPath).."/"..self.MenuText]then
MenuPath[table.concat(self.MenuParentPath).."/"..self.MenuText]=nil
end
missionCommands.removeItemForGroup(self.MenuClient:GetClientGroupID(),self.MenuPath)
self.ParentMenu.Menus[self.MenuPath]=nil
return nil
end
MENU_CLIENT_COMMAND={
ClassName="MENU_CLIENT_COMMAND"
}
function MENU_CLIENT_COMMAND:New(Client,MenuText,ParentMenu,CommandMenuFunction,...)
local MenuParentPath={}
if ParentMenu~=nil then
MenuParentPath=ParentMenu.MenuPath
end
local self=BASE:Inherit(self,MENU_COMMAND_BASE:New(MenuText,MenuParentPath,CommandMenuFunction,arg))
self.MenuClient=Client
self.MenuClientGroupID=Client:GetClientGroupID()
self.MenuParentPath=MenuParentPath
self.MenuText=MenuText
self.ParentMenu=ParentMenu
if not _MENUCLIENTS[self.MenuClientGroupID]then
_MENUCLIENTS[self.MenuClientGroupID]={}
end
local MenuPath=_MENUCLIENTS[self.MenuClientGroupID]
self:T({Client:GetClientGroupName(),MenuPath[table.concat(MenuParentPath)],MenuParentPath,MenuText,CommandMenuFunction,arg})
local MenuPathID=table.concat(MenuParentPath).."/"..MenuText
if MenuPath[MenuPathID]then
missionCommands.removeItemForGroup(self.MenuClient:GetClientGroupID(),MenuPath[MenuPathID])
end
self.MenuPath=missionCommands.addCommandForGroup(self.MenuClient:GetClientGroupID(),MenuText,MenuParentPath,self.MenuCallHandler)
MenuPath[MenuPathID]=self.MenuPath
if ParentMenu and ParentMenu.Menus then
ParentMenu.Menus[self.MenuPath]=self
end
return self
end
function MENU_CLIENT_COMMAND:Remove()
self:F(self.MenuPath)
if not _MENUCLIENTS[self.MenuClientGroupID]then
_MENUCLIENTS[self.MenuClientGroupID]={}
end
local MenuPath=_MENUCLIENTS[self.MenuClientGroupID]
if MenuPath[table.concat(self.MenuParentPath).."/"..self.MenuText]then
MenuPath[table.concat(self.MenuParentPath).."/"..self.MenuText]=nil
end
missionCommands.removeItemForGroup(self.MenuClient:GetClientGroupID(),self.MenuPath)
self.ParentMenu.Menus[self.MenuPath]=nil
return nil
end
end
do
local _MENUGROUPS={}
MENU_GROUP={
ClassName="MENU_GROUP"
}
function MENU_GROUP:New(MenuGroup,MenuText,ParentMenu)
MenuGroup._Menus=MenuGroup._Menus or{}
local Path=(ParentMenu and(table.concat(ParentMenu.MenuPath or{},"@").."@"..MenuText))or MenuText
if MenuGroup._Menus[Path]then
self=MenuGroup._Menus[Path]
else
self=BASE:Inherit(self,MENU_BASE:New(MenuText,ParentMenu))
MenuGroup._Menus[Path]=self
self.MenuGroup=MenuGroup
self.Path=Path
self.MenuGroupID=MenuGroup:GetID()
self.MenuText=MenuText
self.ParentMenu=ParentMenu
self:T({"Adding Menu ",MenuText,self.MenuParentPath})
self.MenuPath=missionCommands.addSubMenuForGroup(self.MenuGroupID,MenuText,self.MenuParentPath)
if self.ParentMenu and self.ParentMenu.Menus then
self.ParentMenu.Menus[MenuText]=self
self:F({self.ParentMenu.Menus,MenuText})
self.ParentMenu.MenuCount=self.ParentMenu.MenuCount+1
end
end
return self
end
function MENU_GROUP:RemoveSubMenus(MenuTime,MenuTag)
self:T({"Removing Group SubMenus:",MenuTime,MenuTag,self.MenuGroup:GetName(),self.MenuPath})
for MenuText,Menu in pairs(self.Menus)do
Menu:Remove(MenuTime,MenuTag)
end
end
function MENU_GROUP:Remove(MenuTime,MenuTag)
self:RemoveSubMenus(MenuTime,MenuTag)
if not MenuTime or self.MenuTime~=MenuTime then
if(not MenuTag)or(MenuTag and self.MenuTag and MenuTag==self.MenuTag)then
if self.MenuGroup._Menus[self.Path]then
self=self.MenuGroup._Menus[self.Path]
missionCommands.removeItemForGroup(self.MenuGroupID,self.MenuPath)
if self.ParentMenu then
self.ParentMenu.Menus[self.MenuText]=nil
self.ParentMenu.MenuCount=self.ParentMenu.MenuCount-1
if self.ParentMenu.MenuCount==0 then
if self.MenuRemoveParent==true then
self:T2("Removing Parent Menu ")
self.ParentMenu:Remove()
end
end
end
end
self:T({"Removing Group Menu:",MenuGroup=self.MenuGroup:GetName()})
self.MenuGroup._Menus[self.Path]=nil
self=nil
end
end
return nil
end
MENU_GROUP_COMMAND={
ClassName="MENU_GROUP_COMMAND"
}
function MENU_GROUP_COMMAND:New(MenuGroup,MenuText,ParentMenu,CommandMenuFunction,...)
MenuGroup._Menus=MenuGroup._Menus or{}
local Path=(ParentMenu and(table.concat(ParentMenu.MenuPath or{},"@").."@"..MenuText))or MenuText
if MenuGroup._Menus[Path]then
self=MenuGroup._Menus[Path]
self:SetCommandMenuFunction(CommandMenuFunction)
self:SetCommandMenuArguments(arg)
return self
end
self=BASE:Inherit(self,MENU_COMMAND_BASE:New(MenuText,ParentMenu,CommandMenuFunction,arg))
MenuGroup._Menus[Path]=self
self.Path=Path
self.MenuGroup=MenuGroup
self.MenuGroupID=MenuGroup:GetID()
self.MenuText=MenuText
self.ParentMenu=ParentMenu
self:F({"Adding Group Command Menu:",MenuGroup=MenuGroup:GetName(),MenuText=MenuText,MenuPath=self.MenuParentPath})
self.MenuPath=missionCommands.addCommandForGroup(self.MenuGroupID,MenuText,self.MenuParentPath,self.MenuCallHandler)
if self.ParentMenu and self.ParentMenu.Menus then
self.ParentMenu.Menus[MenuText]=self
self.ParentMenu.MenuCount=self.ParentMenu.MenuCount+1
self:F2({ParentMenu.Menus,MenuText})
end
return self
end
function MENU_GROUP_COMMAND:Remove(MenuTime,MenuTag)
if not MenuTime or self.MenuTime~=MenuTime then
if(not MenuTag)or(MenuTag and self.MenuTag and MenuTag==self.MenuTag)then
if self.MenuGroup._Menus[self.Path]then
self=self.MenuGroup._Menus[self.Path]
missionCommands.removeItemForGroup(self.MenuGroupID,self.MenuPath)
self.ParentMenu.Menus[self.MenuText]=nil
self.ParentMenu.MenuCount=self.ParentMenu.MenuCount-1
if self.ParentMenu.MenuCount==0 then
if self.MenuRemoveParent==true then
self:T2("Removing Parent Menu ")
self.ParentMenu:Remove()
end
end
self.MenuGroup._Menus[self.Path]=nil
self=nil
end
end
end
return nil
end
end
ZONE_BASE={
ClassName="ZONE_BASE",
ZoneName="",
ZoneProbability=1,
}
function ZONE_BASE:New(ZoneName)
local self=BASE:Inherit(self,BASE:New())
self:F(ZoneName)
self.ZoneName=ZoneName
return self
end
function ZONE_BASE:GetName()
self:F2()
return self.ZoneName
end
function ZONE_BASE:SetName(ZoneName)
self:F2()
self.ZoneName=ZoneName
end
function ZONE_BASE:IsVec2InZone(Vec2)
self:F2(Vec2)
return false
end
function ZONE_BASE:IsVec3InZone(Vec3)
self:F2(Vec3)
local InZone=self:IsVec2InZone({x=Vec3.x,y=Vec3.z})
return InZone
end
function ZONE_BASE:IsPointVec2InZone(PointVec2)
self:F2(PointVec2)
local InZone=self:IsVec2InZone(PointVec2:GetVec2())
return InZone
end
function ZONE_BASE:IsPointVec3InZone(PointVec3)
self:F2(PointVec3)
local InZone=self:IsPointVec2InZone(PointVec3)
return InZone
end
function ZONE_BASE:GetVec2()
self:F2(self.ZoneName)
return nil
end
function ZONE_BASE:GetPointVec2()
self:F2(self.ZoneName)
local Vec2=self:GetVec2()
local PointVec2=POINT_VEC2:NewFromVec2(Vec2)
self:T2({PointVec2})
return PointVec2
end
function ZONE_BASE:GetCoordinate()
self:F2(self.ZoneName)
local Vec2=self:GetVec2()
local Coordinate=COORDINATE:NewFromVec2(Vec2)
self:T2({Coordinate})
return Coordinate
end
function ZONE_BASE:GetVec3(Height)
self:F2(self.ZoneName)
Height=Height or 0
local Vec2=self:GetVec2()
local Vec3={x=Vec2.x,y=Height and Height or land.getHeight(self:GetVec2()),z=Vec2.y}
self:T2({Vec3})
return Vec3
end
function ZONE_BASE:GetPointVec3(Height)
self:F2(self.ZoneName)
local Vec3=self:GetVec3(Height)
local PointVec3=POINT_VEC3:NewFromVec3(Vec3)
self:T2({PointVec3})
return PointVec3
end
function ZONE_BASE:GetCoordinate(Height)
self:F2(self.ZoneName)
local Vec3=self:GetVec3(Height)
local PointVec3=COORDINATE:NewFromVec3(Vec3)
self:T2({PointVec3})
return PointVec3
end
function ZONE_BASE:GetRandomVec2()
return nil
end
function ZONE_BASE:GetRandomPointVec2()
return nil
end
function ZONE_BASE:GetRandomPointVec3()
return nil
end
function ZONE_BASE:GetBoundingSquare()
return nil
end
function ZONE_BASE:BoundZone()
self:F2()
end
function ZONE_BASE:SmokeZone(SmokeColor)
self:F2(SmokeColor)
end
function ZONE_BASE:SetZoneProbability(ZoneProbability)
self:F2(ZoneProbability)
self.ZoneProbability=ZoneProbability or 1
return self
end
function ZONE_BASE:GetZoneProbability()
self:F2()
return self.ZoneProbability
end
function ZONE_BASE:GetZoneMaybe()
self:F2()
local Randomization=math.random()
if Randomization<=self.ZoneProbability then
return self
else
return nil
end
end
ZONE_RADIUS={
ClassName="ZONE_RADIUS",
}
function ZONE_RADIUS:New(ZoneName,Vec2,Radius)
local self=BASE:Inherit(self,ZONE_BASE:New(ZoneName))
self:F({ZoneName,Vec2,Radius})
self.Radius=Radius
self.Vec2=Vec2
return self
end
function ZONE_RADIUS:BoundZone(Points,CountryID,UnBound)
local Point={}
local Vec2=self:GetVec2()
Points=Points and Points or 360
local Angle
local RadialBase=math.pi*2
for Angle=0,360,(360/Points)do
local Radial=Angle*RadialBase/360
Point.x=Vec2.x+math.cos(Radial)*self:GetRadius()
Point.y=Vec2.y+math.sin(Radial)*self:GetRadius()
local CountryName=_DATABASE.COUNTRY_NAME[CountryID]
local Tire={
["country"]=CountryName,
["category"]="Fortifications",
["canCargo"]=false,
["shape_name"]="H-tyre_B_WF",
["type"]="Black_Tyre_WF",
["y"]=Point.y,
["x"]=Point.x,
["name"]=string.format("%s-Tire #%0d",self:GetName(),Angle),
["heading"]=0,
}
local Group=coalition.addStaticObject(CountryID,Tire)
if UnBound and UnBound==true then
Group:destroy()
end
end
return self
end
function ZONE_RADIUS:SmokeZone(SmokeColor,Points)
self:F2(SmokeColor)
local Point={}
local Vec2=self:GetVec2()
Points=Points and Points or 360
local Angle
local RadialBase=math.pi*2
for Angle=0,360,360/Points do
local Radial=Angle*RadialBase/360
Point.x=Vec2.x+math.cos(Radial)*self:GetRadius()
Point.y=Vec2.y+math.sin(Radial)*self:GetRadius()
POINT_VEC2:New(Point.x,Point.y):Smoke(SmokeColor)
end
return self
end
function ZONE_RADIUS:FlareZone(FlareColor,Points,Azimuth)
self:F2({FlareColor,Azimuth})
local Point={}
local Vec2=self:GetVec2()
Points=Points and Points or 360
local Angle
local RadialBase=math.pi*2
for Angle=0,360,360/Points do
local Radial=Angle*RadialBase/360
Point.x=Vec2.x+math.cos(Radial)*self:GetRadius()
Point.y=Vec2.y+math.sin(Radial)*self:GetRadius()
POINT_VEC2:New(Point.x,Point.y):Flare(FlareColor,Azimuth)
end
return self
end
function ZONE_RADIUS:GetRadius()
self:F2(self.ZoneName)
self:T2({self.Radius})
return self.Radius
end
function ZONE_RADIUS:SetRadius(Radius)
self:F2(self.ZoneName)
self.Radius=Radius
self:T2({self.Radius})
return self.Radius
end
function ZONE_RADIUS:GetVec2()
self:F2(self.ZoneName)
self:T2({self.Vec2})
return self.Vec2
end
function ZONE_RADIUS:SetVec2(Vec2)
self:F2(self.ZoneName)
self.Vec2=Vec2
self:T2({self.Vec2})
return self.Vec2
end
function ZONE_RADIUS:GetVec3(Height)
self:F2({self.ZoneName,Height})
Height=Height or 0
local Vec2=self:GetVec2()
local Vec3={x=Vec2.x,y=land.getHeight(self:GetVec2())+Height,z=Vec2.y}
self:T2({Vec3})
return Vec3
end
function ZONE_RADIUS:Scan(ObjectCategories)
self.ScanData={}
self.ScanData.Coalitions={}
self.ScanData.Scenery={}
local ZoneCoord=self:GetCoordinate()
local ZoneRadius=self:GetRadius()
self:E({ZoneCoord=ZoneCoord,ZoneRadius=ZoneRadius,ZoneCoordLL=ZoneCoord:ToStringLLDMS()})
local SphereSearch={
id=world.VolumeType.SPHERE,
params={
point=ZoneCoord:GetVec3(),
radius=ZoneRadius,
}
}
local function EvaluateZone(ZoneObject)
if ZoneObject:isExist()then
local ObjectCategory=ZoneObject:getCategory()
if(ObjectCategory==Object.Category.UNIT and ZoneObject:isActive())or
ObjectCategory==Object.Category.STATIC then
local CoalitionDCSUnit=ZoneObject:getCoalition()
self.ScanData.Coalitions[CoalitionDCSUnit]=true
self:E({Name=ZoneObject:getName(),Coalition=CoalitionDCSUnit})
end
if ObjectCategory==Object.Category.SCENERY then
local SceneryType=ZoneObject:getTypeName()
local SceneryName=ZoneObject:getName()
self.ScanData.Scenery[SceneryType]=self.ScanData.Scenery[SceneryType]or{}
self.ScanData.Scenery[SceneryType][SceneryName]=SCENERY:Register(SceneryName,ZoneObject)
self:E({SCENERY=self.ScanData.Scenery[SceneryType][SceneryName]})
end
end
return true
end
world.searchObjects(ObjectCategories,SphereSearch,EvaluateZone)
end
function ZONE_RADIUS:CountScannedCoalitions()
local Count=0
for CoalitionID,Coalition in pairs(self.ScanData.Coalitions)do
Count=Count+1
end
return Count
end
function ZONE_RADIUS:GetScannedCoalition(Coalition)
if Coalition then
return self.ScanData.Coalitions[Coalition]
else
local Count=0
local ReturnCoalition=nil
for CoalitionID,Coalition in pairs(self.ScanData.Coalitions)do
Count=Count+1
ReturnCoalition=CoalitionID
end
if Count~=1 then
ReturnCoalition=nil
end
return ReturnCoalition
end
end
function ZONE_RADIUS:GetScannedSceneryType(SceneryType)
return self.ScanData.Scenery[SceneryType]
end
function ZONE_RADIUS:GetScannedScenery()
return self.ScanData.Scenery
end
function ZONE_RADIUS:IsAllInZoneOfCoalition(Coalition)
return self:CountScannedCoalitions()==1 and self:GetScannedCoalition(Coalition)==true
end
function ZONE_RADIUS:IsAllInZoneOfOtherCoalition(Coalition)
self:E({Coalitions=self.Coalitions,Count=self:CountScannedCoalitions()})
return self:CountScannedCoalitions()==1 and self:GetScannedCoalition(Coalition)==nil
end
function ZONE_RADIUS:IsSomeInZoneOfCoalition(Coalition)
return self:CountScannedCoalitions()>1 and self:GetScannedCoalition(Coalition)==true
end
function ZONE_RADIUS:IsNoneInZoneOfCoalition(Coalition)
return self:GetScannedCoalition(Coalition)==nil
end
function ZONE_RADIUS:IsNoneInZone()
return self:CountScannedCoalitions()==0
end
function ZONE_RADIUS:SearchZone(EvaluateFunction,ObjectCategories)
local SearchZoneResult=true
local ZoneCoord=self:GetCoordinate()
local ZoneRadius=self:GetRadius()
self:E({ZoneCoord=ZoneCoord,ZoneRadius=ZoneRadius,ZoneCoordLL=ZoneCoord:ToStringLLDMS()})
local SphereSearch={
id=world.VolumeType.SPHERE,
params={
point=ZoneCoord:GetVec3(),
radius=ZoneRadius/2,
}
}
local function EvaluateZone(ZoneDCSUnit)
env.info(ZoneDCSUnit:getName())
local ZoneUnit=UNIT:Find(ZoneDCSUnit)
return EvaluateFunction(ZoneUnit)
end
world.searchObjects(Object.Category.UNIT,SphereSearch,EvaluateZone)
end
function ZONE_RADIUS:IsVec2InZone(Vec2)
self:F2(Vec2)
local ZoneVec2=self:GetVec2()
if ZoneVec2 then
if((Vec2.x-ZoneVec2.x)^2+(Vec2.y-ZoneVec2.y)^2)^0.5<=self:GetRadius()then
return true
end
end
return false
end
function ZONE_RADIUS:IsVec3InZone(Vec3)
self:F2(Vec3)
local InZone=self:IsVec2InZone({x=Vec3.x,y=Vec3.z})
return InZone
end
function ZONE_RADIUS:GetRandomVec2(inner,outer)
self:F(self.ZoneName,inner,outer)
local Point={}
local Vec2=self:GetVec2()
local _inner=inner or 0
local _outer=outer or self:GetRadius()
local angle=math.random()*math.pi*2;
Point.x=Vec2.x+math.cos(angle)*math.random(_inner,_outer);
Point.y=Vec2.y+math.sin(angle)*math.random(_inner,_outer);
self:T({Point})
return Point
end
function ZONE_RADIUS:GetRandomPointVec2(inner,outer)
self:F(self.ZoneName,inner,outer)
local PointVec2=POINT_VEC2:NewFromVec2(self:GetRandomVec2())
self:T3({PointVec2})
return PointVec2
end
function ZONE_RADIUS:GetRandomPointVec3(inner,outer)
self:F(self.ZoneName,inner,outer)
local PointVec3=POINT_VEC3:NewFromVec2(self:GetRandomVec2())
self:T3({PointVec3})
return PointVec3
end
function ZONE_RADIUS:GetRandomCoordinate(inner,outer)
self:F(self.ZoneName,inner,outer)
local Coordinate=COORDINATE:NewFromVec2(self:GetRandomVec2())
self:T3({Coordinate=Coordinate})
return Coordinate
end
ZONE={
ClassName="ZONE",
}
function ZONE:New(ZoneName)
local Zone=trigger.misc.getZone(ZoneName)
if not Zone then
error("Zone "..ZoneName.." does not exist.")
return nil
end
local self=BASE:Inherit(self,ZONE_RADIUS:New(ZoneName,{x=Zone.point.x,y=Zone.point.z},Zone.radius))
self:F(ZoneName)
self.Zone=Zone
return self
end
ZONE_UNIT={
ClassName="ZONE_UNIT",
}
function ZONE_UNIT:New(ZoneName,ZoneUNIT,Radius)
local self=BASE:Inherit(self,ZONE_RADIUS:New(ZoneName,ZoneUNIT:GetVec2(),Radius))
self:F({ZoneName,ZoneUNIT:GetVec2(),Radius})
self.ZoneUNIT=ZoneUNIT
self.LastVec2=ZoneUNIT:GetVec2()
return self
end
function ZONE_UNIT:GetVec2()
self:F2(self.ZoneName)
local ZoneVec2=self.ZoneUNIT:GetVec2()
if ZoneVec2 then
self.LastVec2=ZoneVec2
return ZoneVec2
else
return self.LastVec2
end
self:T2({ZoneVec2})
return nil
end
function ZONE_UNIT:GetRandomVec2()
self:F(self.ZoneName)
local RandomVec2={}
local Vec2=self.ZoneUNIT:GetVec2()
if not Vec2 then
Vec2=self.LastVec2
end
local angle=math.random()*math.pi*2;
RandomVec2.x=Vec2.x+math.cos(angle)*math.random()*self:GetRadius();
RandomVec2.y=Vec2.y+math.sin(angle)*math.random()*self:GetRadius();
self:T({RandomVec2})
return RandomVec2
end
function ZONE_UNIT:GetVec3(Height)
self:F2(self.ZoneName)
Height=Height or 0
local Vec2=self:GetVec2()
local Vec3={x=Vec2.x,y=land.getHeight(self:GetVec2())+Height,z=Vec2.y}
self:T2({Vec3})
return Vec3
end
ZONE_GROUP={
ClassName="ZONE_GROUP",
}
function ZONE_GROUP:New(ZoneName,ZoneGROUP,Radius)
local self=BASE:Inherit(self,ZONE_RADIUS:New(ZoneName,ZoneGROUP:GetVec2(),Radius))
self:F({ZoneName,ZoneGROUP:GetVec2(),Radius})
self._.ZoneGROUP=ZoneGROUP
return self
end
function ZONE_GROUP:GetVec2()
self:F(self.ZoneName)
local ZoneVec2=self._.ZoneGROUP:GetVec2()
self:T({ZoneVec2})
return ZoneVec2
end
function ZONE_GROUP:GetRandomVec2()
self:F(self.ZoneName)
local Point={}
local Vec2=self._.ZoneGROUP:GetVec2()
local angle=math.random()*math.pi*2;
Point.x=Vec2.x+math.cos(angle)*math.random()*self:GetRadius();
Point.y=Vec2.y+math.sin(angle)*math.random()*self:GetRadius();
self:T({Point})
return Point
end
function ZONE_GROUP:GetRandomPointVec2(inner,outer)
self:F(self.ZoneName,inner,outer)
local PointVec2=POINT_VEC2:NewFromVec2(self:GetRandomVec2())
self:T3({PointVec2})
return PointVec2
end
ZONE_POLYGON_BASE={
ClassName="ZONE_POLYGON_BASE",
}
function ZONE_POLYGON_BASE:New(ZoneName,PointsArray)
local self=BASE:Inherit(self,ZONE_BASE:New(ZoneName))
self:F({ZoneName,PointsArray})
local i=0
self._.Polygon={}
for i=1,#PointsArray do
self._.Polygon[i]={}
self._.Polygon[i].x=PointsArray[i].x
self._.Polygon[i].y=PointsArray[i].y
end
return self
end
function ZONE_POLYGON_BASE:GetVec2()
self:F(self.ZoneName)
local Bounds=self:GetBoundingSquare()
return{x=(Bounds.x2+Bounds.x1)/2,y=(Bounds.y2+Bounds.y1)/2}
end
function ZONE_POLYGON_BASE:Flush()
self:F2()
self:E({Polygon=self.ZoneName,Coordinates=self._.Polygon})
return self
end
function ZONE_POLYGON_BASE:BoundZone(UnBound)
local i
local j
local Segments=10
i=1
j=#self._.Polygon
while i<=#self._.Polygon do
self:T({i,j,self._.Polygon[i],self._.Polygon[j]})
local DeltaX=self._.Polygon[j].x-self._.Polygon[i].x
local DeltaY=self._.Polygon[j].y-self._.Polygon[i].y
for Segment=0,Segments do
local PointX=self._.Polygon[i].x+(Segment*DeltaX/Segments)
local PointY=self._.Polygon[i].y+(Segment*DeltaY/Segments)
local Tire={
["country"]="USA",
["category"]="Fortifications",
["canCargo"]=false,
["shape_name"]="H-tyre_B_WF",
["type"]="Black_Tyre_WF",
["y"]=PointY,
["x"]=PointX,
["name"]=string.format("%s-Tire #%0d",self:GetName(),((i-1)*Segments)+Segment),
["heading"]=0,
}
local Group=coalition.addStaticObject(country.id.USA,Tire)
if UnBound and UnBound==true then
Group:destroy()
end
end
j=i
i=i+1
end
return self
end
function ZONE_POLYGON_BASE:SmokeZone(SmokeColor)
self:F2(SmokeColor)
local i
local j
local Segments=10
i=1
j=#self._.Polygon
while i<=#self._.Polygon do
self:T({i,j,self._.Polygon[i],self._.Polygon[j]})
local DeltaX=self._.Polygon[j].x-self._.Polygon[i].x
local DeltaY=self._.Polygon[j].y-self._.Polygon[i].y
for Segment=0,Segments do
local PointX=self._.Polygon[i].x+(Segment*DeltaX/Segments)
local PointY=self._.Polygon[i].y+(Segment*DeltaY/Segments)
POINT_VEC2:New(PointX,PointY):Smoke(SmokeColor)
end
j=i
i=i+1
end
return self
end
function ZONE_POLYGON_BASE:IsVec2InZone(Vec2)
self:F2(Vec2)
local Next
local Prev
local InPolygon=false
Next=1
Prev=#self._.Polygon
while Next<=#self._.Polygon do
self:T({Next,Prev,self._.Polygon[Next],self._.Polygon[Prev]})
if(((self._.Polygon[Next].y>Vec2.y)~=(self._.Polygon[Prev].y>Vec2.y))and
(Vec2.x<(self._.Polygon[Prev].x-self._.Polygon[Next].x)*(Vec2.y-self._.Polygon[Next].y)/(self._.Polygon[Prev].y-self._.Polygon[Next].y)+self._.Polygon[Next].x)
)then
InPolygon=not InPolygon
end
self:T2({InPolygon=InPolygon})
Prev=Next
Next=Next+1
end
self:T({InPolygon=InPolygon})
return InPolygon
end
function ZONE_POLYGON_BASE:GetRandomVec2()
self:F2()
local Vec2Found=false
local Vec2
local BS=self:GetBoundingSquare()
self:T2(BS)
while Vec2Found==false do
Vec2={x=math.random(BS.x1,BS.x2),y=math.random(BS.y1,BS.y2)}
self:T2(Vec2)
if self:IsVec2InZone(Vec2)then
Vec2Found=true
end
end
self:T2(Vec2)
return Vec2
end
function ZONE_POLYGON_BASE:GetRandomPointVec2()
self:F2()
local PointVec2=POINT_VEC2:NewFromVec2(self:GetRandomVec2())
self:T2(PointVec2)
return PointVec2
end
function ZONE_POLYGON_BASE:GetRandomPointVec3()
self:F2()
local PointVec3=POINT_VEC3:NewFromVec2(self:GetRandomVec2())
self:T2(PointVec3)
return PointVec3
end
function ZONE_POLYGON_BASE:GetRandomCoordinate()
self:F2()
local Coordinate=COORDINATE:NewFromVec2(self:GetRandomVec2())
self:T2(Coordinate)
return Coordinate
end
function ZONE_POLYGON_BASE:GetBoundingSquare()
local x1=self._.Polygon[1].x
local y1=self._.Polygon[1].y
local x2=self._.Polygon[1].x
local y2=self._.Polygon[1].y
for i=2,#self._.Polygon do
self:T2({self._.Polygon[i],x1,y1,x2,y2})
x1=(x1>self._.Polygon[i].x)and self._.Polygon[i].x or x1
x2=(x2<self._.Polygon[i].x)and self._.Polygon[i].x or x2
y1=(y1>self._.Polygon[i].y)and self._.Polygon[i].y or y1
y2=(y2<self._.Polygon[i].y)and self._.Polygon[i].y or y2
end
return{x1=x1,y1=y1,x2=x2,y2=y2}
end
ZONE_POLYGON={
ClassName="ZONE_POLYGON",
}
function ZONE_POLYGON:New(ZoneName,ZoneGroup)
local GroupPoints=ZoneGroup:GetTaskRoute()
local self=BASE:Inherit(self,ZONE_POLYGON_BASE:New(ZoneName,GroupPoints))
self:F({ZoneName,ZoneGroup,self._.Polygon})
return self
end
function ZONE_POLYGON:NewFromGroupName(ZoneName,GroupName)
local ZoneGroup=GROUP:FindByName(GroupName)
local GroupPoints=ZoneGroup:GetTaskRoute()
local self=BASE:Inherit(self,ZONE_POLYGON_BASE:New(ZoneName,GroupPoints))
self:F({ZoneName,ZoneGroup,self._.Polygon})
return self
end
DATABASE={
ClassName="DATABASE",
Templates={
Units={},
Groups={},
Statics={},
ClientsByName={},
ClientsByID={},
},
UNITS={},
UNITS_Index={},
STATICS={},
GROUPS={},
PLAYERS={},
PLAYERSJOINED={},
PLAYERUNITS={},
CLIENTS={},
CARGOS={},
AIRBASES={},
COUNTRY_ID={},
COUNTRY_NAME={},
NavPoints={},
PLAYERSETTINGS={},
ZONENAMES={},
HITS={},
DESTROYS={},
}
local _DATABASECoalition=
{
[1]="Red",
[2]="Blue",
}
local _DATABASECategory=
{
["plane"]=Unit.Category.AIRPLANE,
["helicopter"]=Unit.Category.HELICOPTER,
["vehicle"]=Unit.Category.GROUND_UNIT,
["ship"]=Unit.Category.SHIP,
["static"]=Unit.Category.STRUCTURE,
}
function DATABASE:New()
local self=BASE:Inherit(self,BASE:New())
self:SetEventPriority(1)
self:HandleEvent(EVENTS.Birth,self._EventOnBirth)
self:HandleEvent(EVENTS.Dead,self._EventOnDeadOrCrash)
self:HandleEvent(EVENTS.Crash,self._EventOnDeadOrCrash)
self:HandleEvent(EVENTS.Hit,self.AccountHits)
self:HandleEvent(EVENTS.NewCargo)
self:HandleEvent(EVENTS.DeleteCargo)
self:HandleEvent(EVENTS.PlayerEnterUnit,self._EventOnPlayerEnterUnit)
self:HandleEvent(EVENTS.PlayerLeaveUnit,self._EventOnPlayerLeaveUnit)
self:_RegisterTemplates()
self:_RegisterGroupsAndUnits()
self:_RegisterClients()
self:_RegisterStatics()
self:_RegisterAirbases()
self.UNITS_Position=0
local function CheckPlayers(self)
local CoalitionsData={AlivePlayersRed=coalition.getPlayers(coalition.side.RED),AlivePlayersBlue=coalition.getPlayers(coalition.side.BLUE)}
for CoalitionId,CoalitionData in pairs(CoalitionsData)do
for UnitId,UnitData in pairs(CoalitionData)do
if UnitData and UnitData:isExist()then
local UnitName=UnitData:getName()
local PlayerName=UnitData:getPlayerName()
local PlayerUnit=UNIT:Find(UnitData)
if PlayerName and PlayerName~=""then
if self.PLAYERS[PlayerName]==nil or self.PLAYERS[PlayerName]~=UnitName then
self:AddPlayer(UnitName,PlayerName)
local Settings=SETTINGS:Set(PlayerName)
Settings:SetPlayerMenu(PlayerUnit)
end
end
end
end
end
end
self:E("Scheduling")
PlayerCheckSchedule=SCHEDULER:New(nil,CheckPlayers,{self},1,1)
return self
end
function DATABASE:FindUnit(UnitName)
local UnitFound=self.UNITS[UnitName]
return UnitFound
end
function DATABASE:AddUnit(DCSUnitName)
if not self.UNITS[DCSUnitName]then
local UnitRegister=UNIT:Register(DCSUnitName)
self.UNITS[DCSUnitName]=UNIT:Register(DCSUnitName)
table.insert(self.UNITS_Index,DCSUnitName)
end
return self.UNITS[DCSUnitName]
end
function DATABASE:DeleteUnit(DCSUnitName)
self.UNITS[DCSUnitName]=nil
end
function DATABASE:AddStatic(DCSStaticName)
if not self.STATICS[DCSStaticName]then
self.STATICS[DCSStaticName]=STATIC:Register(DCSStaticName)
end
end
function DATABASE:DeleteStatic(DCSStaticName)
end
function DATABASE:FindStatic(StaticName)
local StaticFound=self.STATICS[StaticName]
return StaticFound
end
function DATABASE:FindAirbase(AirbaseName)
local AirbaseFound=self.AIRBASES[AirbaseName]
return AirbaseFound
end
function DATABASE:AddAirbase(AirbaseName)
if not self.AIRBASES[AirbaseName]then
self.AIRBASES[AirbaseName]=AIRBASE:Register(AirbaseName)
end
end
function DATABASE:DeleteAirbase(AirbaseName)
self.AIRBASES[AirbaseName]=nil
end
function DATABASE:FindAirbase(AirbaseName)
local AirbaseFound=self.AIRBASES[AirbaseName]
return AirbaseFound
end
function DATABASE:AddCargo(Cargo)
if not self.CARGOS[Cargo.Name]then
self.CARGOS[Cargo.Name]=Cargo
end
end
function DATABASE:DeleteCargo(CargoName)
self.CARGOS[CargoName]=nil
end
function DATABASE:FindCargo(CargoName)
local CargoFound=self.CARGOS[CargoName]
return CargoFound
end
function DATABASE:FindClient(ClientName)
local ClientFound=self.CLIENTS[ClientName]
return ClientFound
end
function DATABASE:AddClient(ClientName)
if not self.CLIENTS[ClientName]then
self.CLIENTS[ClientName]=CLIENT:Register(ClientName)
end
return self.CLIENTS[ClientName]
end
function DATABASE:FindGroup(GroupName)
local GroupFound=self.GROUPS[GroupName]
return GroupFound
end
function DATABASE:AddGroup(GroupName)
if not self.GROUPS[GroupName]then
self:E({"Add GROUP:",GroupName})
self.GROUPS[GroupName]=GROUP:Register(GroupName)
end
return self.GROUPS[GroupName]
end
function DATABASE:AddPlayer(UnitName,PlayerName)
if PlayerName then
self:E({"Add player for unit:",UnitName,PlayerName})
self.PLAYERS[PlayerName]=UnitName
self.PLAYERUNITS[UnitName]=PlayerName
self.PLAYERSJOINED[PlayerName]=PlayerName
end
end
function DATABASE:DeletePlayer(UnitName,PlayerName)
if PlayerName then
self:E({"Clean player:",PlayerName})
self.PLAYERS[PlayerName]=nil
self.PLAYERUNITS[UnitName]=PlayerName
end
end
function DATABASE:Spawn(SpawnTemplate)
self:F(SpawnTemplate.name)
self:T({SpawnTemplate.SpawnCountryID,SpawnTemplate.SpawnCategoryID})
local SpawnCoalitionID=SpawnTemplate.CoalitionID
local SpawnCountryID=SpawnTemplate.CountryID
local SpawnCategoryID=SpawnTemplate.CategoryID
SpawnTemplate.CoalitionID=nil
SpawnTemplate.CountryID=nil
SpawnTemplate.CategoryID=nil
self:_RegisterGroupTemplate(SpawnTemplate,SpawnCoalitionID,SpawnCategoryID,SpawnCountryID)
self:T3(SpawnTemplate)
coalition.addGroup(SpawnCountryID,SpawnCategoryID,SpawnTemplate)
SpawnTemplate.CoalitionID=SpawnCoalitionID
SpawnTemplate.CountryID=SpawnCountryID
SpawnTemplate.CategoryID=SpawnCategoryID
local SpawnGroup=self:AddGroup(SpawnTemplate.name)
for UnitID,UnitData in pairs(SpawnTemplate.units)do
self:AddUnit(UnitData.name)
end
return SpawnGroup
end
function DATABASE:SetStatusGroup(GroupName,Status)
self:F2(Status)
self.Templates.Groups[GroupName].Status=Status
end
function DATABASE:GetStatusGroup(GroupName)
self:F2(Status)
if self.Templates.Groups[GroupName]then
return self.Templates.Groups[GroupName].Status
else
return""
end
end
function DATABASE:_RegisterGroupTemplate(GroupTemplate,CoalitionID,CategoryID,CountryID)
local GroupTemplateName=env.getValueDictByKey(GroupTemplate.name)
local TraceTable={}
if not self.Templates.Groups[GroupTemplateName]then
self.Templates.Groups[GroupTemplateName]={}
self.Templates.Groups[GroupTemplateName].Status=nil
end
if GroupTemplate.route and GroupTemplate.route.spans then
GroupTemplate.route.spans=nil
end
GroupTemplate.CategoryID=CategoryID
GroupTemplate.CoalitionID=CoalitionID
GroupTemplate.CountryID=CountryID
self.Templates.Groups[GroupTemplateName].GroupName=GroupTemplateName
self.Templates.Groups[GroupTemplateName].Template=GroupTemplate
self.Templates.Groups[GroupTemplateName].groupId=GroupTemplate.groupId
self.Templates.Groups[GroupTemplateName].UnitCount=#GroupTemplate.units
self.Templates.Groups[GroupTemplateName].Units=GroupTemplate.units
self.Templates.Groups[GroupTemplateName].CategoryID=CategoryID
self.Templates.Groups[GroupTemplateName].CoalitionID=CoalitionID
self.Templates.Groups[GroupTemplateName].CountryID=CountryID
TraceTable[#TraceTable+1]="Group"
TraceTable[#TraceTable+1]=self.Templates.Groups[GroupTemplateName].GroupName
TraceTable[#TraceTable+1]="Coalition"
TraceTable[#TraceTable+1]=self.Templates.Groups[GroupTemplateName].CoalitionID
TraceTable[#TraceTable+1]="Category"
TraceTable[#TraceTable+1]=self.Templates.Groups[GroupTemplateName].CategoryID
TraceTable[#TraceTable+1]="Country"
TraceTable[#TraceTable+1]=self.Templates.Groups[GroupTemplateName].CountryID
TraceTable[#TraceTable+1]="Units"
for unit_num,UnitTemplate in pairs(GroupTemplate.units)do
UnitTemplate.name=env.getValueDictByKey(UnitTemplate.name)
self.Templates.Units[UnitTemplate.name]={}
self.Templates.Units[UnitTemplate.name].UnitName=UnitTemplate.name
self.Templates.Units[UnitTemplate.name].Template=UnitTemplate
self.Templates.Units[UnitTemplate.name].GroupName=GroupTemplateName
self.Templates.Units[UnitTemplate.name].GroupTemplate=GroupTemplate
self.Templates.Units[UnitTemplate.name].GroupId=GroupTemplate.groupId
self.Templates.Units[UnitTemplate.name].CategoryID=CategoryID
self.Templates.Units[UnitTemplate.name].CoalitionID=CoalitionID
self.Templates.Units[UnitTemplate.name].CountryID=CountryID
if UnitTemplate.skill and(UnitTemplate.skill=="Client"or UnitTemplate.skill=="Player")then
self.Templates.ClientsByName[UnitTemplate.name]=UnitTemplate
self.Templates.ClientsByName[UnitTemplate.name].CategoryID=CategoryID
self.Templates.ClientsByName[UnitTemplate.name].CoalitionID=CoalitionID
self.Templates.ClientsByName[UnitTemplate.name].CountryID=CountryID
self.Templates.ClientsByID[UnitTemplate.unitId]=UnitTemplate
end
TraceTable[#TraceTable+1]=self.Templates.Units[UnitTemplate.name].UnitName
end
self:E(TraceTable)
end
function DATABASE:GetGroupTemplate(GroupName)
local GroupTemplate=self.Templates.Groups[GroupName].Template
GroupTemplate.SpawnCoalitionID=self.Templates.Groups[GroupName].CoalitionID
GroupTemplate.SpawnCategoryID=self.Templates.Groups[GroupName].CategoryID
GroupTemplate.SpawnCountryID=self.Templates.Groups[GroupName].CountryID
return GroupTemplate
end
function DATABASE:_RegisterStaticTemplate(StaticTemplate,CoalitionID,CategoryID,CountryID)
local TraceTable={}
local StaticTemplateName=env.getValueDictByKey(StaticTemplate.name)
self.Templates.Statics[StaticTemplateName]=self.Templates.Statics[StaticTemplateName]or{}
StaticTemplate.CategoryID=CategoryID
StaticTemplate.CoalitionID=CoalitionID
StaticTemplate.CountryID=CountryID
self.Templates.Statics[StaticTemplateName].StaticName=StaticTemplateName
self.Templates.Statics[StaticTemplateName].GroupTemplate=StaticTemplate
self.Templates.Statics[StaticTemplateName].UnitTemplate=StaticTemplate.units[1]
self.Templates.Statics[StaticTemplateName].CategoryID=CategoryID
self.Templates.Statics[StaticTemplateName].CoalitionID=CoalitionID
self.Templates.Statics[StaticTemplateName].CountryID=CountryID
TraceTable[#TraceTable+1]="Static"
TraceTable[#TraceTable+1]=self.Templates.Statics[StaticTemplateName].GroupName
TraceTable[#TraceTable+1]="Coalition"
TraceTable[#TraceTable+1]=self.Templates.Statics[StaticTemplateName].CoalitionID
TraceTable[#TraceTable+1]="Category"
TraceTable[#TraceTable+1]=self.Templates.Statics[StaticTemplateName].CategoryID
TraceTable[#TraceTable+1]="Country"
TraceTable[#TraceTable+1]=self.Templates.Statics[StaticTemplateName].CountryID
self:E(TraceTable)
end
function DATABASE:GetStaticUnitTemplate(StaticName)
local StaticTemplate=self.Templates.Statics[StaticName].UnitTemplate
StaticTemplate.SpawnCoalitionID=self.Templates.Statics[StaticName].CoalitionID
StaticTemplate.SpawnCategoryID=self.Templates.Statics[StaticName].CategoryID
StaticTemplate.SpawnCountryID=self.Templates.Statics[StaticName].CountryID
return StaticTemplate
end
function DATABASE:GetGroupNameFromUnitName(UnitName)
return self.Templates.Units[UnitName].GroupName
end
function DATABASE:GetGroupTemplateFromUnitName(UnitName)
return self.Templates.Units[UnitName].GroupTemplate
end
function DATABASE:GetCoalitionFromClientTemplate(ClientName)
return self.Templates.ClientsByName[ClientName].CoalitionID
end
function DATABASE:GetCategoryFromClientTemplate(ClientName)
return self.Templates.ClientsByName[ClientName].CategoryID
end
function DATABASE:GetCountryFromClientTemplate(ClientName)
return self.Templates.ClientsByName[ClientName].CountryID
end
function DATABASE:GetCoalitionFromAirbase(AirbaseName)
return self.AIRBASES[AirbaseName]:GetCoalition()
end
function DATABASE:GetCategoryFromAirbase(AirbaseName)
return self.AIRBASES[AirbaseName]:GetCategory()
end
function DATABASE:_RegisterPlayers()
local CoalitionsData={AlivePlayersRed=coalition.getPlayers(coalition.side.RED),AlivePlayersBlue=coalition.getPlayers(coalition.side.BLUE)}
for CoalitionId,CoalitionData in pairs(CoalitionsData)do
for UnitId,UnitData in pairs(CoalitionData)do
self:T3({"UnitData:",UnitData})
if UnitData and UnitData:isExist()then
local UnitName=UnitData:getName()
local PlayerName=UnitData:getPlayerName()
if not self.PLAYERS[PlayerName]then
self:E({"Add player for unit:",UnitName,PlayerName})
self:AddPlayer(UnitName,PlayerName)
end
end
end
end
return self
end
function DATABASE:_RegisterGroupsAndUnits()
local CoalitionsData={GroupsRed=coalition.getGroups(coalition.side.RED),GroupsBlue=coalition.getGroups(coalition.side.BLUE)}
for CoalitionId,CoalitionData in pairs(CoalitionsData)do
for DCSGroupId,DCSGroup in pairs(CoalitionData)do
if DCSGroup:isExist()then
local DCSGroupName=DCSGroup:getName()
self:E({"Register Group:",DCSGroupName})
self:AddGroup(DCSGroupName)
for DCSUnitId,DCSUnit in pairs(DCSGroup:getUnits())do
local DCSUnitName=DCSUnit:getName()
self:E({"Register Unit:",DCSUnitName})
self:AddUnit(DCSUnitName)
end
else
self:E({"Group does not exist: ",DCSGroup})
end
end
end
return self
end
function DATABASE:_RegisterClients()
for ClientName,ClientTemplate in pairs(self.Templates.ClientsByName)do
self:E({"Register Client:",ClientName})
self:AddClient(ClientName)
end
return self
end
function DATABASE:_RegisterStatics()
local CoalitionsData={GroupsRed=coalition.getStaticObjects(coalition.side.RED),GroupsBlue=coalition.getStaticObjects(coalition.side.BLUE)}
for CoalitionId,CoalitionData in pairs(CoalitionsData)do
for DCSStaticId,DCSStatic in pairs(CoalitionData)do
if DCSStatic:isExist()then
local DCSStaticName=DCSStatic:getName()
self:E({"Register Static:",DCSStaticName})
self:AddStatic(DCSStaticName)
else
self:E({"Static does not exist: ",DCSStatic})
end
end
end
return self
end
function DATABASE:_RegisterAirbases()
local CoalitionsData={AirbasesRed=coalition.getAirbases(coalition.side.RED),AirbasesBlue=coalition.getAirbases(coalition.side.BLUE),AirbasesNeutral=coalition.getAirbases(coalition.side.NEUTRAL)}
for CoalitionId,CoalitionData in pairs(CoalitionsData)do
for DCSAirbaseId,DCSAirbase in pairs(CoalitionData)do
local DCSAirbaseName=DCSAirbase:getName()
self:E({"Register Airbase:",DCSAirbaseName})
self:AddAirbase(DCSAirbaseName)
end
end
return self
end
function DATABASE:_EventOnBirth(Event)
self:F2({Event})
if Event.IniDCSUnit then
if Event.IniObjectCategory==3 then
self:AddStatic(Event.IniDCSUnitName)
else
if Event.IniObjectCategory==1 then
self:AddUnit(Event.IniDCSUnitName)
self:AddGroup(Event.IniDCSGroupName)
end
end
end
end
function DATABASE:_EventOnDeadOrCrash(Event)
self:F2({Event})
if Event.IniDCSUnit then
if Event.IniObjectCategory==3 then
if self.STATICS[Event.IniDCSUnitName]then
self:DeleteStatic(Event.IniDCSUnitName)
end
else
if Event.IniObjectCategory==1 then
if self.UNITS[Event.IniDCSUnitName]then
self:DeleteUnit(Event.IniDCSUnitName)
end
end
end
end
self:AccountDestroys(Event)
end
function DATABASE:_EventOnPlayerEnterUnit(Event)
self:F2({Event})
if Event.IniUnit then
if Event.IniObjectCategory==1 then
self:AddUnit(Event.IniDCSUnitName)
self:AddGroup(Event.IniDCSGroupName)
local PlayerName=Event.IniUnit:GetPlayerName()
if not self.PLAYERS[PlayerName]then
self:AddPlayer(Event.IniUnitName,PlayerName)
end
local Settings=SETTINGS:Set(PlayerName)
Settings:SetPlayerMenu(Event.IniUnit)
end
end
end
function DATABASE:_EventOnPlayerLeaveUnit(Event)
self:F2({Event})
if Event.IniUnit then
if Event.IniObjectCategory==1 then
local PlayerName=Event.IniUnit:GetPlayerName()
if self.PLAYERS[PlayerName]then
local Settings=SETTINGS:Set(PlayerName)
Settings:RemovePlayerMenu(Event.IniUnit)
self:DeletePlayer(Event.IniUnit,PlayerName)
end
end
end
end
function DATABASE:ForEach(IteratorFunction,FinalizeFunction,arg,Set)
self:F2(arg)
local function CoRoutine()
local Count=0
for ObjectID,Object in pairs(Set)do
self:T2(Object)
IteratorFunction(Object,unpack(arg))
Count=Count+1
end
return true
end
local co=CoRoutine
local function Schedule()
local status,res=co()
self:T3({status,res})
if status==false then
error(res)
end
if res==false then
return true
end
if FinalizeFunction then
FinalizeFunction(unpack(arg))
end
return false
end
local Scheduler=SCHEDULER:New(self,Schedule,{},0.001,0.001,0)
return self
end
function DATABASE:ForEachStatic(IteratorFunction,FinalizeFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,FinalizeFunction,arg,self.STATICS)
return self
end
function DATABASE:ForEachUnit(IteratorFunction,FinalizeFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,FinalizeFunction,arg,self.UNITS)
return self
end
function DATABASE:ForEachGroup(IteratorFunction,FinalizeFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,FinalizeFunction,arg,self.GROUPS)
return self
end
function DATABASE:ForEachPlayer(IteratorFunction,FinalizeFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,FinalizeFunction,arg,self.PLAYERS)
return self
end
function DATABASE:ForEachPlayerJoined(IteratorFunction,FinalizeFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,FinalizeFunction,arg,self.PLAYERSJOINED)
return self
end
function DATABASE:ForEachPlayerUnit(IteratorFunction,FinalizeFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,FinalizeFunction,arg,self.PLAYERUNITS)
return self
end
function DATABASE:ForEachClient(IteratorFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,arg,self.CLIENTS)
return self
end
function DATABASE:ForEachCargo(IteratorFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,arg,self.CARGOS)
return self
end
function DATABASE:OnEventNewCargo(EventData)
self:F2({EventData})
if EventData.Cargo then
self:AddCargo(EventData.Cargo)
end
end
function DATABASE:OnEventDeleteCargo(EventData)
self:F2({EventData})
if EventData.Cargo then
self:DeleteCargo(EventData.Cargo.Name)
end
end
function DATABASE:GetPlayerSettings(PlayerName)
self:F2({PlayerName})
return self.PLAYERSETTINGS[PlayerName]
end
function DATABASE:SetPlayerSettings(PlayerName,Settings)
self:F2({PlayerName,Settings})
self.PLAYERSETTINGS[PlayerName]=Settings
end
function DATABASE:_RegisterTemplates()
self:F2()
self.Navpoints={}
self.UNITS={}
for CoalitionName,coa_data in pairs(env.mission.coalition)do
if(CoalitionName=='red'or CoalitionName=='blue')and type(coa_data)=='table'then
local CoalitionSide=coalition.side[string.upper(CoalitionName)]
self.Navpoints[CoalitionName]={}
if coa_data.nav_points then
for nav_ind,nav_data in pairs(coa_data.nav_points)do
if type(nav_data)=='table'then
self.Navpoints[CoalitionName][nav_ind]=routines.utils.deepCopy(nav_data)
self.Navpoints[CoalitionName][nav_ind]['name']=nav_data.callsignStr
self.Navpoints[CoalitionName][nav_ind]['point']={}
self.Navpoints[CoalitionName][nav_ind]['point']['x']=nav_data.x
self.Navpoints[CoalitionName][nav_ind]['point']['y']=0
self.Navpoints[CoalitionName][nav_ind]['point']['z']=nav_data.y
end
end
end
if coa_data.country then
for cntry_id,cntry_data in pairs(coa_data.country)do
local CountryName=string.upper(cntry_data.name)
local CountryID=cntry_data.id
self.COUNTRY_ID[CountryName]=CountryID
self.COUNTRY_NAME[CountryID]=CountryName
if type(cntry_data)=='table'then
for obj_type_name,obj_type_data in pairs(cntry_data)do
if obj_type_name=="helicopter"or obj_type_name=="ship"or obj_type_name=="plane"or obj_type_name=="vehicle"or obj_type_name=="static"then
local CategoryName=obj_type_name
if((type(obj_type_data)=='table')and obj_type_data.group and(type(obj_type_data.group)=='table')and(#obj_type_data.group>0))then
for group_num,Template in pairs(obj_type_data.group)do
if obj_type_name~="static"and Template and Template.units and type(Template.units)=='table'then
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
end
end
end
end
end
end
end
end
end
end
for ZoneID,ZoneData in pairs(env.mission.triggers.zones)do
local ZoneName=ZoneData.name
self.ZONENAMES[ZoneName]=ZoneName
end
return self
end
function DATABASE:AccountHits(Event)
self:F({Event})
if Event.IniPlayerName~=nil then
self:T("Hitting Something")
if Event.TgtCategory then
self.HITS[Event.TgtUnitName]=self.HITS[Event.TgtUnitName]or{}
local Hit=self.HITS[Event.TgtUnitName]
Hit.Players=Hit.Players or{}
Hit.Players[Event.IniPlayerName]=true
end
end
if Event.WeaponPlayerName~=nil then
self:T("Hitting Scenery")
if Event.TgtCategory then
if Event.IniCoalition then
self.HITS[Event.TgtUnitName]=self.HITS[Event.TgtUnitName]or{}
local Hit=self.HITS[Event.TgtUnitName]
Hit.Players=Hit.Players or{}
Hit.Players[Event.WeaponPlayerName]=true
else
end
end
end
end
function DATABASE:AccountDestroys(Event)
self:F({Event})
local TargetUnit=nil
local TargetGroup=nil
local TargetUnitName=""
local TargetGroupName=""
local TargetPlayerName=""
local TargetCoalition=nil
local TargetCategory=nil
local TargetType=nil
local TargetUnitCoalition=nil
local TargetUnitCategory=nil
local TargetUnitType=nil
if Event.IniDCSUnit then
TargetUnit=Event.IniUnit
TargetUnitName=Event.IniDCSUnitName
TargetGroup=Event.IniDCSGroup
TargetGroupName=Event.IniDCSGroupName
TargetPlayerName=Event.IniPlayerName
TargetCoalition=Event.IniCoalition
TargetCategory=Event.IniCategory
TargetType=Event.IniTypeName
TargetUnitType=TargetType
self:T({TargetUnitName,TargetGroupName,TargetPlayerName,TargetCoalition,TargetCategory,TargetType})
end
self:T("Something got destroyed")
local Destroyed=false
if self.HITS[Event.IniUnitName]then
self.DESTROYS[Event.IniUnitName]=self.DESTROYS[Event.IniUnitName]or{}
self.DESTROYS[Event.IniUnitName]=true
end
end
SET_BASE={
ClassName="SET_BASE",
Filter={},
Set={},
List={},
Index={},
}
function SET_BASE:New(Database)
local self=BASE:Inherit(self,BASE:New())
self.Database=Database
self.YieldInterval=10
self.TimeInterval=0.001
self.Set={}
self.Index={}
self.CallScheduler=SCHEDULER:New(self)
self:SetEventPriority(2)
return self
end
function SET_BASE:_Find(ObjectName)
local ObjectFound=self.Set[ObjectName]
return ObjectFound
end
function SET_BASE:GetSet()
self:F2()
return self.Set
end
function SET_BASE:GetSetNames()
self:F2()
local Names={}
for Name,Object in pairs(self.Set)do
table.insert(Names,Name)
end
return Names
end
function SET_BASE:GetSetObjects()
self:F2()
local Objects={}
for Name,Object in pairs(self.Set)do
table.insert(Objects,Object)
end
return Objects
end
function SET_BASE:Add(ObjectName,Object)
self:F(ObjectName)
self.Set[ObjectName]=Object
table.insert(self.Index,ObjectName)
end
function SET_BASE:AddObject(Object)
self:F2(Object.ObjectName)
self:T(Object.UnitName)
self:T(Object.ObjectName)
self:Add(Object.ObjectName,Object)
end
function SET_BASE:Remove(ObjectName)
local Object=self.Set[ObjectName]
self:F3({ObjectName,Object})
if Object then
for Index,Key in ipairs(self.Index)do
if Key==ObjectName then
table.remove(self.Index,Index)
self.Set[ObjectName]=nil
break
end
end
end
end
function SET_BASE:Get(ObjectName)
self:F(ObjectName)
local Object=self.Set[ObjectName]
self:T3({ObjectName,Object})
return Object
end
function SET_BASE:GetFirst()
local ObjectName=self.Index[1]
local FirstObject=self.Set[ObjectName]
self:T3({FirstObject})
return FirstObject
end
function SET_BASE:GetLast()
local ObjectName=self.Index[#self.Index]
local LastObject=self.Set[ObjectName]
self:T3({LastObject})
return LastObject
end
function SET_BASE:GetRandom()
local RandomItem=self.Set[self.Index[math.random(#self.Index)]]
self:T3({RandomItem})
return RandomItem
end
function SET_BASE:Count()
return self.Index and#self.Index or 0
end
function SET_BASE:SetDatabase(BaseSet)
local OtherFilter=routines.utils.deepCopy(BaseSet.Filter)
self.Filter=OtherFilter
self.Database=BaseSet:GetSet()
return self
end
function SET_BASE:SetIteratorIntervals(YieldInterval,TimeInterval)
self.YieldInterval=YieldInterval
self.TimeInterval=TimeInterval
return self
end
function SET_BASE:FilterOnce()
for ObjectName,Object in pairs(self.Database)do
if self:IsIncludeObject(Object)then
self:Add(ObjectName,Object)
end
end
return self
end
function SET_BASE:_FilterStart()
for ObjectName,Object in pairs(self.Database)do
if self:IsIncludeObject(Object)then
self:E({"Adding Object:",ObjectName})
self:Add(ObjectName,Object)
end
end
self:HandleEvent(EVENTS.Birth,self._EventOnBirth)
self:HandleEvent(EVENTS.Dead,self._EventOnDeadOrCrash)
self:HandleEvent(EVENTS.Crash,self._EventOnDeadOrCrash)
self:HandleEvent(EVENTS.PlayerEnterUnit,self._EventOnPlayerEnterUnit)
self:HandleEvent(EVENTS.PlayerLeaveUnit,self._EventOnPlayerLeaveUnit)
return self
end
function SET_BASE:FilterDeads()
self:HandleEvent(EVENTS.Dead,self._EventOnDeadOrCrash)
return self
end
function SET_BASE:FilterCrashes()
self:HandleEvent(EVENTS.Crash,self._EventOnDeadOrCrash)
return self
end
function SET_BASE:FilterStop()
self:UnHandleEvent(EVENTS.Birth)
self:UnHandleEvent(EVENTS.Dead)
self:UnHandleEvent(EVENTS.Crash)
return self
end
function SET_BASE:FindNearestObjectFromPointVec2(PointVec2)
self:F2(PointVec2)
local NearestObject=nil
local ClosestDistance=nil
for ObjectID,ObjectData in pairs(self.Set)do
if NearestObject==nil then
NearestObject=ObjectData
ClosestDistance=PointVec2:DistanceFromVec2(ObjectData:GetVec2())
else
local Distance=PointVec2:DistanceFromVec2(ObjectData:GetVec2())
if Distance<ClosestDistance then
NearestObject=ObjectData
ClosestDistance=Distance
end
end
end
return NearestObject
end
function SET_BASE:_EventOnBirth(Event)
self:F3({Event})
if Event.IniDCSUnit then
local ObjectName,Object=self:AddInDatabase(Event)
self:T3(ObjectName,Object)
if Object and self:IsIncludeObject(Object)then
self:Add(ObjectName,Object)
end
end
end
function SET_BASE:_EventOnDeadOrCrash(Event)
self:F3({Event})
if Event.IniDCSUnit then
local ObjectName,Object=self:FindInDatabase(Event)
if ObjectName then
self:Remove(ObjectName)
end
end
end
function SET_BASE:_EventOnPlayerEnterUnit(Event)
self:F3({Event})
if Event.IniDCSUnit then
local ObjectName,Object=self:AddInDatabase(Event)
self:T3(ObjectName,Object)
if self:IsIncludeObject(Object)then
self:Add(ObjectName,Object)
end
end
end
function SET_BASE:_EventOnPlayerLeaveUnit(Event)
self:F3({Event})
local ObjectName=Event.IniDCSUnit
if Event.IniDCSUnit then
if Event.IniDCSGroup then
local GroupUnits=Event.IniDCSGroup:getUnits()
local PlayerCount=0
for _,DCSUnit in pairs(GroupUnits)do
if DCSUnit~=Event.IniDCSUnit then
if DCSUnit:getPlayerName()~=nil then
PlayerCount=PlayerCount+1
end
end
end
self:E(PlayerCount)
if PlayerCount==0 then
self:Remove(Event.IniDCSGroupName)
end
end
end
end
function SET_BASE:ForEach(IteratorFunction,arg,Set,Function,FunctionArguments)
self:F3(arg)
Set=Set or self:GetSet()
arg=arg or{}
local function CoRoutine()
local Count=0
for ObjectID,ObjectData in pairs(Set)do
local Object=ObjectData
self:T3(Object)
if Function then
if Function(unpack(FunctionArguments),Object)==true then
IteratorFunction(Object,unpack(arg))
end
else
IteratorFunction(Object,unpack(arg))
end
Count=Count+1
end
return true
end
local co=CoRoutine
local function Schedule()
local status,res=co()
self:T3({status,res})
if status==false then
error(res)
end
if res==false then
return true
end
return false
end
Schedule()
return self
end
function SET_BASE:IsIncludeObject(Object)
self:F3(Object)
return true
end
function SET_BASE:GetObjectNames()
self:F3()
local ObjectNames=""
for ObjectName,Object in pairs(self.Set)do
ObjectNames=ObjectNames..ObjectName..", "
end
return ObjectNames
end
function SET_BASE:Flush()
self:F3()
local ObjectNames=""
for ObjectName,Object in pairs(self.Set)do
ObjectNames=ObjectNames..ObjectName..", "
end
self:E({"Objects in Set:",ObjectNames})
return ObjectNames
end
SET_GROUP={
ClassName="SET_GROUP",
Filter={
Coalitions=nil,
Categories=nil,
Countries=nil,
GroupPrefixes=nil,
},
FilterMeta={
Coalitions={
red=coalition.side.RED,
blue=coalition.side.BLUE,
neutral=coalition.side.NEUTRAL,
},
Categories={
plane=Group.Category.AIRPLANE,
helicopter=Group.Category.HELICOPTER,
ground=Group.Category.GROUND,
ship=Group.Category.SHIP,
structure=Group.Category.STRUCTURE,
},
},
}
function SET_GROUP:New()
local self=BASE:Inherit(self,SET_BASE:New(_DATABASE.GROUPS))
return self
end
function SET_GROUP:AddGroupsByName(AddGroupNames)
local AddGroupNamesArray=(type(AddGroupNames)=="table")and AddGroupNames or{AddGroupNames}
for AddGroupID,AddGroupName in pairs(AddGroupNamesArray)do
self:Add(AddGroupName,GROUP:FindByName(AddGroupName))
end
return self
end
function SET_GROUP:RemoveGroupsByName(RemoveGroupNames)
local RemoveGroupNamesArray=(type(RemoveGroupNames)=="table")and RemoveGroupNames or{RemoveGroupNames}
for RemoveGroupID,RemoveGroupName in pairs(RemoveGroupNamesArray)do
self:Remove(RemoveGroupName.GroupName)
end
return self
end
function SET_GROUP:FindGroup(GroupName)
local GroupFound=self.Set[GroupName]
return GroupFound
end
function SET_GROUP:FindNearestGroupFromPointVec2(PointVec2)
self:F2(PointVec2)
local NearestGroup=nil
local ClosestDistance=nil
for ObjectID,ObjectData in pairs(self.Set)do
if NearestGroup==nil then
NearestGroup=ObjectData
ClosestDistance=PointVec2:DistanceFromVec2(ObjectData:GetVec2())
else
local Distance=PointVec2:DistanceFromVec2(ObjectData:GetVec2())
if Distance<ClosestDistance then
NearestGroup=ObjectData
ClosestDistance=Distance
end
end
end
return NearestGroup
end
function SET_GROUP:FilterCoalitions(Coalitions)
if not self.Filter.Coalitions then
self.Filter.Coalitions={}
end
if type(Coalitions)~="table"then
Coalitions={Coalitions}
end
for CoalitionID,Coalition in pairs(Coalitions)do
self.Filter.Coalitions[Coalition]=Coalition
end
return self
end
function SET_GROUP:FilterCategories(Categories)
if not self.Filter.Categories then
self.Filter.Categories={}
end
if type(Categories)~="table"then
Categories={Categories}
end
for CategoryID,Category in pairs(Categories)do
self.Filter.Categories[Category]=Category
end
return self
end
function SET_GROUP:FilterCategoryGround()
self:FilterCategories("ground")
return self
end
function SET_GROUP:FilterCategoryAirplane()
self:FilterCategories("plane")
return self
end
function SET_GROUP:FilterCategoryHelicopter()
self:FilterCategories("helicopter")
return self
end
function SET_GROUP:FilterCategoryShip()
self:FilterCategories("ship")
return self
end
function SET_GROUP:FilterCategoryStructure()
self:FilterCategories("structure")
return self
end
function SET_GROUP:FilterCountries(Countries)
if not self.Filter.Countries then
self.Filter.Countries={}
end
if type(Countries)~="table"then
Countries={Countries}
end
for CountryID,Country in pairs(Countries)do
self.Filter.Countries[Country]=Country
end
return self
end
function SET_GROUP:FilterPrefixes(Prefixes)
if not self.Filter.GroupPrefixes then
self.Filter.GroupPrefixes={}
end
if type(Prefixes)~="table"then
Prefixes={Prefixes}
end
for PrefixID,Prefix in pairs(Prefixes)do
self.Filter.GroupPrefixes[Prefix]=Prefix
end
return self
end
function SET_GROUP:FilterStart()
if _DATABASE then
self:_FilterStart()
end
return self
end
function SET_GROUP:_EventOnDeadOrCrash(Event)
self:F3({Event})
if Event.IniDCSUnit then
local ObjectName,Object=self:FindInDatabase(Event)
if ObjectName then
if Event.IniDCSGroup:getSize()==1 then
self:Remove(ObjectName)
end
end
end
end
function SET_GROUP:AddInDatabase(Event)
self:F3({Event})
if Event.IniObjectCategory==1 then
if not self.Database[Event.IniDCSGroupName]then
self.Database[Event.IniDCSGroupName]=GROUP:Register(Event.IniDCSGroupName)
self:T3(self.Database[Event.IniDCSGroupName])
end
end
return Event.IniDCSGroupName,self.Database[Event.IniDCSGroupName]
end
function SET_GROUP:FindInDatabase(Event)
self:F3({Event})
return Event.IniDCSGroupName,self.Database[Event.IniDCSGroupName]
end
function SET_GROUP:ForEachGroup(IteratorFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,arg,self.Set)
return self
end
function SET_GROUP:ForEachGroupCompletelyInZone(ZoneObject,IteratorFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,arg,self.Set,
function(ZoneObject,GroupObject)
if GroupObject:IsCompletelyInZone(ZoneObject)then
return true
else
return false
end
end,{ZoneObject})
return self
end
function SET_GROUP:ForEachGroupPartlyInZone(ZoneObject,IteratorFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,arg,self.Set,
function(ZoneObject,GroupObject)
if GroupObject:IsPartlyInZone(ZoneObject)then
return true
else
return false
end
end,{ZoneObject})
return self
end
function SET_GROUP:ForEachGroupNotInZone(ZoneObject,IteratorFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,arg,self.Set,
function(ZoneObject,GroupObject)
if GroupObject:IsNotInZone(ZoneObject)then
return true
else
return false
end
end,{ZoneObject})
return self
end
function SET_GROUP:AllCompletelyInZone(Zone)
self:F2(Zone)
local Set=self:GetSet()
for GroupID,GroupData in pairs(Set)do
if not GroupData:IsCompletelyInZone(Zone)then
return false
end
end
return true
end
function SET_GROUP:AnyCompletelyInZone(Zone)
self:F2(Zone)
local Set=self:GetSet()
for GroupID,GroupData in pairs(Set)do
if GroupData:IsCompletelyInZone(Zone)then
return true
end
end
return false
end
function SET_GROUP:AnyInZone(Zone)
self:F2(Zone)
local Set=self:GetSet()
for GroupID,GroupData in pairs(Set)do
if GroupData:IsPartlyInZone(Zone)or GroupData:IsCompletelyInZone(Zone)then
return true
end
end
return false
end
function SET_GROUP:AnyPartlyInZone(Zone)
self:F2(Zone)
local IsPartlyInZone=false
local Set=self:GetSet()
for GroupID,GroupData in pairs(Set)do
if GroupData:IsCompletelyInZone(Zone)then
return false
elseif GroupData:IsPartlyInZone(Zone)then
IsPartlyInZone=true
end
end
if IsPartlyInZone then
return true
else
return false
end
end
function SET_GROUP:NoneInZone(Zone)
self:F2(Zone)
local Set=self:GetSet()
for GroupID,GroupData in pairs(Set)do
if not GroupData:IsNotInZone(Zone)then
return false
end
end
return true
end
function SET_GROUP:CountInZone(Zone)
self:F2(Zone)
local Count=0
local Set=self:GetSet()
for GroupID,GroupData in pairs(Set)do
if GroupData:IsCompletelyInZone(Zone)then
Count=Count+1
end
end
return Count
end
function SET_GROUP:CountUnitInZone(Zone)
self:F2(Zone)
local Count=0
local Set=self:GetSet()
for GroupID,GroupData in pairs(Set)do
Count=Count+GroupData:CountInZone(Zone)
end
return Count
end
function SET_GROUP:IsIncludeObject(MooseGroup)
self:F2(MooseGroup)
local MooseGroupInclude=true
if self.Filter.Coalitions then
local MooseGroupCoalition=false
for CoalitionID,CoalitionName in pairs(self.Filter.Coalitions)do
self:T3({"Coalition:",MooseGroup:GetCoalition(),self.FilterMeta.Coalitions[CoalitionName],CoalitionName})
if self.FilterMeta.Coalitions[CoalitionName]and self.FilterMeta.Coalitions[CoalitionName]==MooseGroup:GetCoalition()then
MooseGroupCoalition=true
end
end
MooseGroupInclude=MooseGroupInclude and MooseGroupCoalition
end
if self.Filter.Categories then
local MooseGroupCategory=false
for CategoryID,CategoryName in pairs(self.Filter.Categories)do
self:T3({"Category:",MooseGroup:GetCategory(),self.FilterMeta.Categories[CategoryName],CategoryName})
if self.FilterMeta.Categories[CategoryName]and self.FilterMeta.Categories[CategoryName]==MooseGroup:GetCategory()then
MooseGroupCategory=true
end
end
MooseGroupInclude=MooseGroupInclude and MooseGroupCategory
end
if self.Filter.Countries then
local MooseGroupCountry=false
for CountryID,CountryName in pairs(self.Filter.Countries)do
self:T3({"Country:",MooseGroup:GetCountry(),CountryName})
if country.id[CountryName]==MooseGroup:GetCountry()then
MooseGroupCountry=true
end
end
MooseGroupInclude=MooseGroupInclude and MooseGroupCountry
end
if self.Filter.GroupPrefixes then
local MooseGroupPrefix=false
for GroupPrefixId,GroupPrefix in pairs(self.Filter.GroupPrefixes)do
self:T3({"Prefix:",string.find(MooseGroup:GetName(),GroupPrefix,1),GroupPrefix})
if string.find(MooseGroup:GetName(),GroupPrefix:gsub("-","%%-"),1)then
MooseGroupPrefix=true
end
end
MooseGroupInclude=MooseGroupInclude and MooseGroupPrefix
end
self:T2(MooseGroupInclude)
return MooseGroupInclude
end
do
SET_UNIT={
ClassName="SET_UNIT",
Units={},
Filter={
Coalitions=nil,
Categories=nil,
Types=nil,
Countries=nil,
UnitPrefixes=nil,
},
FilterMeta={
Coalitions={
red=coalition.side.RED,
blue=coalition.side.BLUE,
neutral=coalition.side.NEUTRAL,
},
Categories={
plane=Unit.Category.AIRPLANE,
helicopter=Unit.Category.HELICOPTER,
ground=Unit.Category.GROUND_UNIT,
ship=Unit.Category.SHIP,
structure=Unit.Category.STRUCTURE,
},
},
}
function SET_UNIT:New()
local self=BASE:Inherit(self,SET_BASE:New(_DATABASE.UNITS))
return self
end
function SET_UNIT:AddUnit(AddUnit)
self:F2(AddUnit:GetName())
self:Add(AddUnit:GetName(),AddUnit)
return self
end
function SET_UNIT:AddUnitsByName(AddUnitNames)
local AddUnitNamesArray=(type(AddUnitNames)=="table")and AddUnitNames or{AddUnitNames}
self:T(AddUnitNamesArray)
for AddUnitID,AddUnitName in pairs(AddUnitNamesArray)do
self:Add(AddUnitName,UNIT:FindByName(AddUnitName))
end
return self
end
function SET_UNIT:RemoveUnitsByName(RemoveUnitNames)
local RemoveUnitNamesArray=(type(RemoveUnitNames)=="table")and RemoveUnitNames or{RemoveUnitNames}
for RemoveUnitID,RemoveUnitName in pairs(RemoveUnitNamesArray)do
self:Remove(RemoveUnitName)
end
return self
end
function SET_UNIT:FindUnit(UnitName)
local UnitFound=self.Set[UnitName]
return UnitFound
end
function SET_UNIT:FilterCoalitions(Coalitions)
self.Filter.Coalitions={}
if type(Coalitions)~="table"then
Coalitions={Coalitions}
end
for CoalitionID,Coalition in pairs(Coalitions)do
self.Filter.Coalitions[Coalition]=Coalition
end
return self
end
function SET_UNIT:FilterCategories(Categories)
if not self.Filter.Categories then
self.Filter.Categories={}
end
if type(Categories)~="table"then
Categories={Categories}
end
for CategoryID,Category in pairs(Categories)do
self.Filter.Categories[Category]=Category
end
return self
end
function SET_UNIT:FilterTypes(Types)
if not self.Filter.Types then
self.Filter.Types={}
end
if type(Types)~="table"then
Types={Types}
end
for TypeID,Type in pairs(Types)do
self.Filter.Types[Type]=Type
end
return self
end
function SET_UNIT:FilterCountries(Countries)
if not self.Filter.Countries then
self.Filter.Countries={}
end
if type(Countries)~="table"then
Countries={Countries}
end
for CountryID,Country in pairs(Countries)do
self.Filter.Countries[Country]=Country
end
return self
end
function SET_UNIT:FilterPrefixes(Prefixes)
if not self.Filter.UnitPrefixes then
self.Filter.UnitPrefixes={}
end
if type(Prefixes)~="table"then
Prefixes={Prefixes}
end
for PrefixID,Prefix in pairs(Prefixes)do
self.Filter.UnitPrefixes[Prefix]=Prefix
end
return self
end
function SET_UNIT:FilterHasRadar(RadarTypes)
self.Filter.RadarTypes=self.Filter.RadarTypes or{}
if type(RadarTypes)~="table"then
RadarTypes={RadarTypes}
end
for RadarTypeID,RadarType in pairs(RadarTypes)do
self.Filter.RadarTypes[RadarType]=RadarType
end
return self
end
function SET_UNIT:FilterHasSEAD()
self.Filter.SEAD=true
return self
end
function SET_UNIT:FilterStart()
if _DATABASE then
self:_FilterStart()
end
return self
end
function SET_UNIT:AddInDatabase(Event)
self:F3({Event})
if Event.IniObjectCategory==1 then
if not self.Database[Event.IniDCSUnitName]then
self.Database[Event.IniDCSUnitName]=UNIT:Register(Event.IniDCSUnitName)
self:T3(self.Database[Event.IniDCSUnitName])
end
end
return Event.IniDCSUnitName,self.Database[Event.IniDCSUnitName]
end
function SET_UNIT:FindInDatabase(Event)
self:F2({Event.IniDCSUnitName,self.Set[Event.IniDCSUnitName],Event})
return Event.IniDCSUnitName,self.Set[Event.IniDCSUnitName]
end
do
function SET_UNIT:IsPartiallyInZone(ZoneTest)
local IsPartiallyInZone=false
local function EvaluateZone(ZoneUnit)
local ZoneUnitName=ZoneUnit:GetName()
self:E({ZoneUnitName=ZoneUnitName})
if self:FindUnit(ZoneUnitName)then
IsPartiallyInZone=true
self:E({Found=true})
return false
end
return true
end
ZoneTest:SearchZone(EvaluateZone)
return IsPartiallyInZone
end
function SET_UNIT:IsNotInZone(Zone)
local IsNotInZone=true
local function EvaluateZone(ZoneUnit)
local ZoneUnitName=ZoneUnit:GetName()
if self:FindUnit(ZoneUnitName)then
IsNotInZone=false
return false
end
return true
end
Zone:SearchZone(EvaluateZone)
return IsNotInZone
end
function SET_UNIT:ForEachUnitInZone(IteratorFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,arg,self.Set)
return self
end
end
function SET_UNIT:ForEachUnit(IteratorFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,arg,self.Set)
return self
end
function SET_UNIT:ForEachUnitPerThreatLevel(FromThreatLevel,ToThreatLevel,IteratorFunction,...)
self:F2(arg)
local ThreatLevelSet={}
if self:Count()~=0 then
for UnitName,UnitObject in pairs(self.Set)do
local Unit=UnitObject
local ThreatLevel=Unit:GetThreatLevel()
ThreatLevelSet[ThreatLevel]=ThreatLevelSet[ThreatLevel]or{}
ThreatLevelSet[ThreatLevel].Set=ThreatLevelSet[ThreatLevel].Set or{}
ThreatLevelSet[ThreatLevel].Set[UnitName]=UnitObject
self:E({ThreatLevel=ThreatLevel,ThreatLevelSet=ThreatLevelSet[ThreatLevel].Set})
end
local ThreatLevelIncrement=FromThreatLevel<=ToThreatLevel and 1 or-1
for ThreatLevel=FromThreatLevel,ToThreatLevel,ThreatLevelIncrement do
self:E({ThreatLevel=ThreatLevel})
local ThreatLevelItem=ThreatLevelSet[ThreatLevel]
if ThreatLevelItem then
self:ForEach(IteratorFunction,arg,ThreatLevelItem.Set)
end
end
end
return self
end
function SET_UNIT:ForEachUnitCompletelyInZone(ZoneObject,IteratorFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,arg,self.Set,
function(ZoneObject,UnitObject)
if UnitObject:IsInZone(ZoneObject)then
return true
else
return false
end
end,{ZoneObject})
return self
end
function SET_UNIT:ForEachUnitNotInZone(ZoneObject,IteratorFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,arg,self.Set,
function(ZoneObject,UnitObject)
if UnitObject:IsNotInZone(ZoneObject)then
return true
else
return false
end
end,{ZoneObject})
return self
end
function SET_UNIT:GetUnitTypes()
self:F2()
local MT={}
local UnitTypes={}
for UnitID,UnitData in pairs(self:GetSet())do
local TextUnit=UnitData
if TextUnit:IsAlive()then
local UnitType=TextUnit:GetTypeName()
if not UnitTypes[UnitType]then
UnitTypes[UnitType]=1
else
UnitTypes[UnitType]=UnitTypes[UnitType]+1
end
end
end
for UnitTypeID,UnitType in pairs(UnitTypes)do
MT[#MT+1]=UnitType.." of "..UnitTypeID
end
return UnitTypes
end
function SET_UNIT:GetUnitTypesText()
self:F2()
local MT={}
local UnitTypes=self:GetUnitTypes()
for UnitTypeID,UnitType in pairs(UnitTypes)do
MT[#MT+1]=UnitType.." of "..UnitTypeID
end
return table.concat(MT,", ")
end
function SET_UNIT:GetUnitThreatLevels()
self:F2()
local UnitThreatLevels={}
for UnitID,UnitData in pairs(self:GetSet())do
local ThreatUnit=UnitData
if ThreatUnit:IsAlive()then
local UnitThreatLevel,UnitThreatLevelText=ThreatUnit:GetThreatLevel()
local ThreatUnitName=ThreatUnit:GetName()
UnitThreatLevels[UnitThreatLevel]=UnitThreatLevels[UnitThreatLevel]or{}
UnitThreatLevels[UnitThreatLevel].UnitThreatLevelText=UnitThreatLevelText
UnitThreatLevels[UnitThreatLevel].Units=UnitThreatLevels[UnitThreatLevel].Units or{}
UnitThreatLevels[UnitThreatLevel].Units[ThreatUnitName]=ThreatUnit
end
end
return UnitThreatLevels
end
function SET_UNIT:CalculateThreatLevelA2G()
local MaxThreatLevelA2G=0
local MaxThreatText=""
for UnitName,UnitData in pairs(self:GetSet())do
local ThreatUnit=UnitData
local ThreatLevelA2G,ThreatText=ThreatUnit:GetThreatLevel()
if ThreatLevelA2G>MaxThreatLevelA2G then
MaxThreatLevelA2G=ThreatLevelA2G
MaxThreatText=ThreatText
end
end
self:F({MaxThreatLevelA2G=MaxThreatLevelA2G,MaxThreatText=MaxThreatText})
return MaxThreatLevelA2G,MaxThreatText
end
function SET_UNIT:GetCoordinate()
local Coordinate=self:GetFirst():GetCoordinate()
local x1=Coordinate.x
local x2=Coordinate.x
local y1=Coordinate.y
local y2=Coordinate.y
local z1=Coordinate.z
local z2=Coordinate.z
local MaxVelocity=0
local AvgHeading=nil
local MovingCount=0
for UnitName,UnitData in pairs(self:GetSet())do
local Unit=UnitData
local Coordinate=Unit:GetCoordinate()
x1=(Coordinate.x<x1)and Coordinate.x or x1
x2=(Coordinate.x>x2)and Coordinate.x or x2
y1=(Coordinate.y<y1)and Coordinate.y or y1
y2=(Coordinate.y>y2)and Coordinate.y or y2
z1=(Coordinate.y<z1)and Coordinate.z or z1
z2=(Coordinate.y>z2)and Coordinate.z or z2
local Velocity=Coordinate:GetVelocity()
if Velocity~=0 then
MaxVelocity=(MaxVelocity<Velocity)and Velocity or MaxVelocity
local Heading=Coordinate:GetHeading()
AvgHeading=AvgHeading and(AvgHeading+Heading)or Heading
MovingCount=MovingCount+1
end
end
AvgHeading=AvgHeading and(AvgHeading/MovingCount)
Coordinate.x=(x2-x1)/2+x1
Coordinate.y=(y2-y1)/2+y1
Coordinate.z=(z2-z1)/2+z1
Coordinate:SetHeading(AvgHeading)
Coordinate:SetVelocity(MaxVelocity)
self:F({Coordinate=Coordinate})
return Coordinate
end
function SET_UNIT:GetVelocity()
local Coordinate=self:GetFirst():GetCoordinate()
local MaxVelocity=0
for UnitName,UnitData in pairs(self:GetSet())do
local Unit=UnitData
local Coordinate=Unit:GetCoordinate()
local Velocity=Coordinate:GetVelocity()
if Velocity~=0 then
MaxVelocity=(MaxVelocity<Velocity)and Velocity or MaxVelocity
end
end
self:F({MaxVelocity=MaxVelocity})
return MaxVelocity
end
function SET_UNIT:GetHeading()
local HeadingSet=nil
local MovingCount=0
for UnitName,UnitData in pairs(self:GetSet())do
local Unit=UnitData
local Coordinate=Unit:GetCoordinate()
local Velocity=Coordinate:GetVelocity()
if Velocity~=0 then
local Heading=Coordinate:GetHeading()
if HeadingSet==nil then
HeadingSet=Heading
else
local HeadingDiff=(HeadingSet-Heading+180+360)%360-180
HeadingDiff=math.abs(HeadingDiff)
if HeadingDiff>5 then
HeadingSet=nil
break
end
end
end
end
return HeadingSet
end
function SET_UNIT:HasRadar(RadarType)
self:F2(RadarType)
local RadarCount=0
for UnitID,UnitData in pairs(self:GetSet())do
local UnitSensorTest=UnitData
local HasSensors
if RadarType then
HasSensors=UnitSensorTest:HasSensors(Unit.SensorType.RADAR,RadarType)
else
HasSensors=UnitSensorTest:HasSensors(Unit.SensorType.RADAR)
end
self:T3(HasSensors)
if HasSensors then
RadarCount=RadarCount+1
end
end
return RadarCount
end
function SET_UNIT:HasSEAD()
self:F2()
local SEADCount=0
for UnitID,UnitData in pairs(self:GetSet())do
local UnitSEAD=UnitData
if UnitSEAD:IsAlive()then
local UnitSEADAttributes=UnitSEAD:GetDesc().attributes
local HasSEAD=UnitSEAD:HasSEAD()
self:T3(HasSEAD)
if HasSEAD then
SEADCount=SEADCount+1
end
end
end
return SEADCount
end
function SET_UNIT:HasGroundUnits()
self:F2()
local GroundUnitCount=0
for UnitID,UnitData in pairs(self:GetSet())do
local UnitTest=UnitData
if UnitTest:IsGround()then
GroundUnitCount=GroundUnitCount+1
end
end
return GroundUnitCount
end
function SET_UNIT:HasFriendlyUnits(FriendlyCoalition)
self:F2()
local FriendlyUnitCount=0
for UnitID,UnitData in pairs(self:GetSet())do
local UnitTest=UnitData
if UnitTest:IsFriendly(FriendlyCoalition)then
FriendlyUnitCount=FriendlyUnitCount+1
end
end
return FriendlyUnitCount
end
function SET_UNIT:IsIncludeObject(MUnit)
self:F2(MUnit)
local MUnitInclude=true
if self.Filter.Coalitions then
local MUnitCoalition=false
for CoalitionID,CoalitionName in pairs(self.Filter.Coalitions)do
self:E({"Coalition:",MUnit:GetCoalition(),self.FilterMeta.Coalitions[CoalitionName],CoalitionName})
if self.FilterMeta.Coalitions[CoalitionName]and self.FilterMeta.Coalitions[CoalitionName]==MUnit:GetCoalition()then
MUnitCoalition=true
end
end
MUnitInclude=MUnitInclude and MUnitCoalition
end
if self.Filter.Categories then
local MUnitCategory=false
for CategoryID,CategoryName in pairs(self.Filter.Categories)do
self:T3({"Category:",MUnit:GetDesc().category,self.FilterMeta.Categories[CategoryName],CategoryName})
if self.FilterMeta.Categories[CategoryName]and self.FilterMeta.Categories[CategoryName]==MUnit:GetDesc().category then
MUnitCategory=true
end
end
MUnitInclude=MUnitInclude and MUnitCategory
end
if self.Filter.Types then
local MUnitType=false
for TypeID,TypeName in pairs(self.Filter.Types)do
self:T3({"Type:",MUnit:GetTypeName(),TypeName})
if TypeName==MUnit:GetTypeName()then
MUnitType=true
end
end
MUnitInclude=MUnitInclude and MUnitType
end
if self.Filter.Countries then
local MUnitCountry=false
for CountryID,CountryName in pairs(self.Filter.Countries)do
self:T3({"Country:",MUnit:GetCountry(),CountryName})
if country.id[CountryName]==MUnit:GetCountry()then
MUnitCountry=true
end
end
MUnitInclude=MUnitInclude and MUnitCountry
end
if self.Filter.UnitPrefixes then
local MUnitPrefix=false
for UnitPrefixId,UnitPrefix in pairs(self.Filter.UnitPrefixes)do
self:T3({"Prefix:",string.find(MUnit:GetName(),UnitPrefix,1),UnitPrefix})
if string.find(MUnit:GetName(),UnitPrefix,1)then
MUnitPrefix=true
end
end
MUnitInclude=MUnitInclude and MUnitPrefix
end
if self.Filter.RadarTypes then
local MUnitRadar=false
for RadarTypeID,RadarType in pairs(self.Filter.RadarTypes)do
self:T3({"Radar:",RadarType})
if MUnit:HasSensors(Unit.SensorType.RADAR,RadarType)==true then
if MUnit:GetRadar()==true then
self:T3("RADAR Found")
end
MUnitRadar=true
end
end
MUnitInclude=MUnitInclude and MUnitRadar
end
if self.Filter.SEAD then
local MUnitSEAD=false
if MUnit:HasSEAD()==true then
self:T3("SEAD Found")
MUnitSEAD=true
end
MUnitInclude=MUnitInclude and MUnitSEAD
end
self:T2(MUnitInclude)
return MUnitInclude
end
function SET_UNIT:GetTypeNames(Delimiter)
Delimiter=Delimiter or", "
local TypeReport=REPORT:New()
local Types={}
for UnitName,UnitData in pairs(self:GetSet())do
local Unit=UnitData
local UnitTypeName=Unit:GetTypeName()
if not Types[UnitTypeName]then
Types[UnitTypeName]=UnitTypeName
TypeReport:Add(UnitTypeName)
end
end
return TypeReport:Text(Delimiter)
end
end
do
SET_STATIC={
ClassName="SET_STATIC",
Statics={},
Filter={
Coalitions=nil,
Categories=nil,
Types=nil,
Countries=nil,
StaticPrefixes=nil,
},
FilterMeta={
Coalitions={
red=coalition.side.RED,
blue=coalition.side.BLUE,
neutral=coalition.side.NEUTRAL,
},
Categories={
plane=Unit.Category.AIRPLANE,
helicopter=Unit.Category.HELICOPTER,
ground=Unit.Category.GROUND_STATIC,
ship=Unit.Category.SHIP,
structure=Unit.Category.STRUCTURE,
},
},
}
function SET_STATIC:New()
local self=BASE:Inherit(self,SET_BASE:New(_DATABASE.STATICS))
return self
end
function SET_STATIC:AddStatic(AddStatic)
self:F2(AddStatic:GetName())
self:Add(AddStatic:GetName(),AddStatic)
return self
end
function SET_STATIC:AddStaticsByName(AddStaticNames)
local AddStaticNamesArray=(type(AddStaticNames)=="table")and AddStaticNames or{AddStaticNames}
self:T(AddStaticNamesArray)
for AddStaticID,AddStaticName in pairs(AddStaticNamesArray)do
self:Add(AddStaticName,STATIC:FindByName(AddStaticName))
end
return self
end
function SET_STATIC:RemoveStaticsByName(RemoveStaticNames)
local RemoveStaticNamesArray=(type(RemoveStaticNames)=="table")and RemoveStaticNames or{RemoveStaticNames}
for RemoveStaticID,RemoveStaticName in pairs(RemoveStaticNamesArray)do
self:Remove(RemoveStaticName)
end
return self
end
function SET_STATIC:FindStatic(StaticName)
local StaticFound=self.Set[StaticName]
return StaticFound
end
function SET_STATIC:FilterCoalitions(Coalitions)
if not self.Filter.Coalitions then
self.Filter.Coalitions={}
end
if type(Coalitions)~="table"then
Coalitions={Coalitions}
end
for CoalitionID,Coalition in pairs(Coalitions)do
self.Filter.Coalitions[Coalition]=Coalition
end
return self
end
function SET_STATIC:FilterCategories(Categories)
if not self.Filter.Categories then
self.Filter.Categories={}
end
if type(Categories)~="table"then
Categories={Categories}
end
for CategoryID,Category in pairs(Categories)do
self.Filter.Categories[Category]=Category
end
return self
end
function SET_STATIC:FilterTypes(Types)
if not self.Filter.Types then
self.Filter.Types={}
end
if type(Types)~="table"then
Types={Types}
end
for TypeID,Type in pairs(Types)do
self.Filter.Types[Type]=Type
end
return self
end
function SET_STATIC:FilterCountries(Countries)
if not self.Filter.Countries then
self.Filter.Countries={}
end
if type(Countries)~="table"then
Countries={Countries}
end
for CountryID,Country in pairs(Countries)do
self.Filter.Countries[Country]=Country
end
return self
end
function SET_STATIC:FilterPrefixes(Prefixes)
if not self.Filter.StaticPrefixes then
self.Filter.StaticPrefixes={}
end
if type(Prefixes)~="table"then
Prefixes={Prefixes}
end
for PrefixID,Prefix in pairs(Prefixes)do
self.Filter.StaticPrefixes[Prefix]=Prefix
end
return self
end
function SET_STATIC:FilterStart()
if _DATABASE then
self:_FilterStart()
end
return self
end
function SET_STATIC:AddInDatabase(Event)
self:F3({Event})
if Event.IniObjectCategory==Object.Category.STATIC then
if not self.Database[Event.IniDCSStaticName]then
self.Database[Event.IniDCSStaticName]=STATIC:Register(Event.IniDCSStaticName)
self:T3(self.Database[Event.IniDCSStaticName])
end
end
return Event.IniDCSStaticName,self.Database[Event.IniDCSStaticName]
end
function SET_STATIC:FindInDatabase(Event)
self:F2({Event.IniDCSStaticName,self.Set[Event.IniDCSStaticName],Event})
return Event.IniDCSStaticName,self.Set[Event.IniDCSStaticName]
end
do
function SET_STATIC:IsPatriallyInZone(Zone)
local IsPartiallyInZone=false
local function EvaluateZone(ZoneStatic)
local ZoneStaticName=ZoneStatic:GetName()
if self:FindStatic(ZoneStaticName)then
IsPartiallyInZone=true
return false
end
return true
end
return IsPartiallyInZone
end
function SET_STATIC:IsNotInZone(Zone)
local IsNotInZone=true
local function EvaluateZone(ZoneStatic)
local ZoneStaticName=ZoneStatic:GetName()
if self:FindStatic(ZoneStaticName)then
IsNotInZone=false
return false
end
return true
end
Zone:Search(EvaluateZone)
return IsNotInZone
end
function SET_STATIC:ForEachStaticInZone(IteratorFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,arg,self.Set)
return self
end
end
function SET_STATIC:ForEachStatic(IteratorFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,arg,self.Set)
return self
end
function SET_STATIC:ForEachStaticCompletelyInZone(ZoneObject,IteratorFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,arg,self.Set,
function(ZoneObject,StaticObject)
if StaticObject:IsInZone(ZoneObject)then
return true
else
return false
end
end,{ZoneObject})
return self
end
function SET_STATIC:ForEachStaticNotInZone(ZoneObject,IteratorFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,arg,self.Set,
function(ZoneObject,StaticObject)
if StaticObject:IsNotInZone(ZoneObject)then
return true
else
return false
end
end,{ZoneObject})
return self
end
function SET_STATIC:GetStaticTypes()
self:F2()
local MT={}
local StaticTypes={}
for StaticID,StaticData in pairs(self:GetSet())do
local TextStatic=StaticData
if TextStatic:IsAlive()then
local StaticType=TextStatic:GetTypeName()
if not StaticTypes[StaticType]then
StaticTypes[StaticType]=1
else
StaticTypes[StaticType]=StaticTypes[StaticType]+1
end
end
end
for StaticTypeID,StaticType in pairs(StaticTypes)do
MT[#MT+1]=StaticType.." of "..StaticTypeID
end
return StaticTypes
end
function SET_STATIC:GetStaticTypesText()
self:F2()
local MT={}
local StaticTypes=self:GetStaticTypes()
for StaticTypeID,StaticType in pairs(StaticTypes)do
MT[#MT+1]=StaticType.." of "..StaticTypeID
end
return table.concat(MT,", ")
end
function SET_STATIC:GetCoordinate()
local Coordinate=self:GetFirst():GetCoordinate()
local x1=Coordinate.x
local x2=Coordinate.x
local y1=Coordinate.y
local y2=Coordinate.y
local z1=Coordinate.z
local z2=Coordinate.z
local MaxVelocity=0
local AvgHeading=nil
local MovingCount=0
for StaticName,StaticData in pairs(self:GetSet())do
local Static=StaticData
local Coordinate=Static:GetCoordinate()
x1=(Coordinate.x<x1)and Coordinate.x or x1
x2=(Coordinate.x>x2)and Coordinate.x or x2
y1=(Coordinate.y<y1)and Coordinate.y or y1
y2=(Coordinate.y>y2)and Coordinate.y or y2
z1=(Coordinate.y<z1)and Coordinate.z or z1
z2=(Coordinate.y>z2)and Coordinate.z or z2
local Velocity=Coordinate:GetVelocity()
if Velocity~=0 then
MaxVelocity=(MaxVelocity<Velocity)and Velocity or MaxVelocity
local Heading=Coordinate:GetHeading()
AvgHeading=AvgHeading and(AvgHeading+Heading)or Heading
MovingCount=MovingCount+1
end
end
AvgHeading=AvgHeading and(AvgHeading/MovingCount)
Coordinate.x=(x2-x1)/2+x1
Coordinate.y=(y2-y1)/2+y1
Coordinate.z=(z2-z1)/2+z1
Coordinate:SetHeading(AvgHeading)
Coordinate:SetVelocity(MaxVelocity)
self:F({Coordinate=Coordinate})
return Coordinate
end
function SET_STATIC:GetVelocity()
return 0
end
function SET_STATIC:GetHeading()
local HeadingSet=nil
local MovingCount=0
for StaticName,StaticData in pairs(self:GetSet())do
local Static=StaticData
local Coordinate=Static:GetCoordinate()
local Velocity=Coordinate:GetVelocity()
if Velocity~=0 then
local Heading=Coordinate:GetHeading()
if HeadingSet==nil then
HeadingSet=Heading
else
local HeadingDiff=(HeadingSet-Heading+180+360)%360-180
HeadingDiff=math.abs(HeadingDiff)
if HeadingDiff>5 then
HeadingSet=nil
break
end
end
end
end
return HeadingSet
end
function SET_STATIC:IsIncludeObject(MStatic)
self:F2(MStatic)
local MStaticInclude=true
if self.Filter.Coalitions then
local MStaticCoalition=false
for CoalitionID,CoalitionName in pairs(self.Filter.Coalitions)do
self:T3({"Coalition:",MStatic:GetCoalition(),self.FilterMeta.Coalitions[CoalitionName],CoalitionName})
if self.FilterMeta.Coalitions[CoalitionName]and self.FilterMeta.Coalitions[CoalitionName]==MStatic:GetCoalition()then
MStaticCoalition=true
end
end
MStaticInclude=MStaticInclude and MStaticCoalition
end
if self.Filter.Categories then
local MStaticCategory=false
for CategoryID,CategoryName in pairs(self.Filter.Categories)do
self:T3({"Category:",MStatic:GetDesc().category,self.FilterMeta.Categories[CategoryName],CategoryName})
if self.FilterMeta.Categories[CategoryName]and self.FilterMeta.Categories[CategoryName]==MStatic:GetDesc().category then
MStaticCategory=true
end
end
MStaticInclude=MStaticInclude and MStaticCategory
end
if self.Filter.Types then
local MStaticType=false
for TypeID,TypeName in pairs(self.Filter.Types)do
self:T3({"Type:",MStatic:GetTypeName(),TypeName})
if TypeName==MStatic:GetTypeName()then
MStaticType=true
end
end
MStaticInclude=MStaticInclude and MStaticType
end
if self.Filter.Countries then
local MStaticCountry=false
for CountryID,CountryName in pairs(self.Filter.Countries)do
self:T3({"Country:",MStatic:GetCountry(),CountryName})
if country.id[CountryName]==MStatic:GetCountry()then
MStaticCountry=true
end
end
MStaticInclude=MStaticInclude and MStaticCountry
end
if self.Filter.StaticPrefixes then
local MStaticPrefix=false
for StaticPrefixId,StaticPrefix in pairs(self.Filter.StaticPrefixes)do
self:T3({"Prefix:",string.find(MStatic:GetName(),StaticPrefix,1),StaticPrefix})
if string.find(MStatic:GetName(),StaticPrefix,1)then
MStaticPrefix=true
end
end
MStaticInclude=MStaticInclude and MStaticPrefix
end
self:T2(MStaticInclude)
return MStaticInclude
end
function SET_STATIC:GetTypeNames(Delimiter)
Delimiter=Delimiter or", "
local TypeReport=REPORT:New()
local Types={}
for StaticName,StaticData in pairs(self:GetSet())do
local Static=StaticData
local StaticTypeName=Static:GetTypeName()
if not Types[StaticTypeName]then
Types[StaticTypeName]=StaticTypeName
TypeReport:Add(StaticTypeName)
end
end
return TypeReport:Text(Delimiter)
end
end
SET_CLIENT={
ClassName="SET_CLIENT",
Clients={},
Filter={
Coalitions=nil,
Categories=nil,
Types=nil,
Countries=nil,
ClientPrefixes=nil,
},
FilterMeta={
Coalitions={
red=coalition.side.RED,
blue=coalition.side.BLUE,
neutral=coalition.side.NEUTRAL,
},
Categories={
plane=Unit.Category.AIRPLANE,
helicopter=Unit.Category.HELICOPTER,
ground=Unit.Category.GROUND_UNIT,
ship=Unit.Category.SHIP,
structure=Unit.Category.STRUCTURE,
},
},
}
function SET_CLIENT:New()
local self=BASE:Inherit(self,SET_BASE:New(_DATABASE.CLIENTS))
return self
end
function SET_CLIENT:AddClientsByName(AddClientNames)
local AddClientNamesArray=(type(AddClientNames)=="table")and AddClientNames or{AddClientNames}
for AddClientID,AddClientName in pairs(AddClientNamesArray)do
self:Add(AddClientName,CLIENT:FindByName(AddClientName))
end
return self
end
function SET_CLIENT:RemoveClientsByName(RemoveClientNames)
local RemoveClientNamesArray=(type(RemoveClientNames)=="table")and RemoveClientNames or{RemoveClientNames}
for RemoveClientID,RemoveClientName in pairs(RemoveClientNamesArray)do
self:Remove(RemoveClientName.ClientName)
end
return self
end
function SET_CLIENT:FindClient(ClientName)
local ClientFound=self.Set[ClientName]
return ClientFound
end
function SET_CLIENT:FilterCoalitions(Coalitions)
if not self.Filter.Coalitions then
self.Filter.Coalitions={}
end
if type(Coalitions)~="table"then
Coalitions={Coalitions}
end
for CoalitionID,Coalition in pairs(Coalitions)do
self.Filter.Coalitions[Coalition]=Coalition
end
return self
end
function SET_CLIENT:FilterCategories(Categories)
if not self.Filter.Categories then
self.Filter.Categories={}
end
if type(Categories)~="table"then
Categories={Categories}
end
for CategoryID,Category in pairs(Categories)do
self.Filter.Categories[Category]=Category
end
return self
end
function SET_CLIENT:FilterTypes(Types)
if not self.Filter.Types then
self.Filter.Types={}
end
if type(Types)~="table"then
Types={Types}
end
for TypeID,Type in pairs(Types)do
self.Filter.Types[Type]=Type
end
return self
end
function SET_CLIENT:FilterCountries(Countries)
if not self.Filter.Countries then
self.Filter.Countries={}
end
if type(Countries)~="table"then
Countries={Countries}
end
for CountryID,Country in pairs(Countries)do
self.Filter.Countries[Country]=Country
end
return self
end
function SET_CLIENT:FilterPrefixes(Prefixes)
if not self.Filter.ClientPrefixes then
self.Filter.ClientPrefixes={}
end
if type(Prefixes)~="table"then
Prefixes={Prefixes}
end
for PrefixID,Prefix in pairs(Prefixes)do
self.Filter.ClientPrefixes[Prefix]=Prefix
end
return self
end
function SET_CLIENT:FilterStart()
if _DATABASE then
self:_FilterStart()
end
return self
end
function SET_CLIENT:AddInDatabase(Event)
self:F3({Event})
return Event.IniDCSUnitName,self.Database[Event.IniDCSUnitName]
end
function SET_CLIENT:FindInDatabase(Event)
self:F3({Event})
return Event.IniDCSUnitName,self.Database[Event.IniDCSUnitName]
end
function SET_CLIENT:ForEachClient(IteratorFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,arg,self.Set)
return self
end
function SET_CLIENT:ForEachClientInZone(ZoneObject,IteratorFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,arg,self.Set,
function(ZoneObject,ClientObject)
if ClientObject:IsInZone(ZoneObject)then
return true
else
return false
end
end,{ZoneObject})
return self
end
function SET_CLIENT:ForEachClientNotInZone(ZoneObject,IteratorFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,arg,self.Set,
function(ZoneObject,ClientObject)
if ClientObject:IsNotInZone(ZoneObject)then
return true
else
return false
end
end,{ZoneObject})
return self
end
function SET_CLIENT:IsIncludeObject(MClient)
self:F2(MClient)
local MClientInclude=true
if MClient then
local MClientName=MClient.UnitName
if self.Filter.Coalitions then
local MClientCoalition=false
for CoalitionID,CoalitionName in pairs(self.Filter.Coalitions)do
local ClientCoalitionID=_DATABASE:GetCoalitionFromClientTemplate(MClientName)
self:T3({"Coalition:",ClientCoalitionID,self.FilterMeta.Coalitions[CoalitionName],CoalitionName})
if self.FilterMeta.Coalitions[CoalitionName]and self.FilterMeta.Coalitions[CoalitionName]==ClientCoalitionID then
MClientCoalition=true
end
end
self:T({"Evaluated Coalition",MClientCoalition})
MClientInclude=MClientInclude and MClientCoalition
end
if self.Filter.Categories then
local MClientCategory=false
for CategoryID,CategoryName in pairs(self.Filter.Categories)do
local ClientCategoryID=_DATABASE:GetCategoryFromClientTemplate(MClientName)
self:T3({"Category:",ClientCategoryID,self.FilterMeta.Categories[CategoryName],CategoryName})
if self.FilterMeta.Categories[CategoryName]and self.FilterMeta.Categories[CategoryName]==ClientCategoryID then
MClientCategory=true
end
end
self:T({"Evaluated Category",MClientCategory})
MClientInclude=MClientInclude and MClientCategory
end
if self.Filter.Types then
local MClientType=false
for TypeID,TypeName in pairs(self.Filter.Types)do
self:T3({"Type:",MClient:GetTypeName(),TypeName})
if TypeName==MClient:GetTypeName()then
MClientType=true
end
end
self:T({"Evaluated Type",MClientType})
MClientInclude=MClientInclude and MClientType
end
if self.Filter.Countries then
local MClientCountry=false
for CountryID,CountryName in pairs(self.Filter.Countries)do
local ClientCountryID=_DATABASE:GetCountryFromClientTemplate(MClientName)
self:T3({"Country:",ClientCountryID,country.id[CountryName],CountryName})
if country.id[CountryName]and country.id[CountryName]==ClientCountryID then
MClientCountry=true
end
end
self:T({"Evaluated Country",MClientCountry})
MClientInclude=MClientInclude and MClientCountry
end
if self.Filter.ClientPrefixes then
local MClientPrefix=false
for ClientPrefixId,ClientPrefix in pairs(self.Filter.ClientPrefixes)do
self:T3({"Prefix:",string.find(MClient.UnitName,ClientPrefix,1),ClientPrefix})
if string.find(MClient.UnitName,ClientPrefix,1)then
MClientPrefix=true
end
end
self:T({"Evaluated Prefix",MClientPrefix})
MClientInclude=MClientInclude and MClientPrefix
end
end
self:T2(MClientInclude)
return MClientInclude
end
SET_AIRBASE={
ClassName="SET_AIRBASE",
Airbases={},
Filter={
Coalitions=nil,
},
FilterMeta={
Coalitions={
red=coalition.side.RED,
blue=coalition.side.BLUE,
neutral=coalition.side.NEUTRAL,
},
Categories={
airdrome=Airbase.Category.AIRDROME,
helipad=Airbase.Category.HELIPAD,
ship=Airbase.Category.SHIP,
},
},
}
function SET_AIRBASE:New()
local self=BASE:Inherit(self,SET_BASE:New(_DATABASE.AIRBASES))
return self
end
function SET_AIRBASE:AddAirbasesByName(AddAirbaseNames)
local AddAirbaseNamesArray=(type(AddAirbaseNames)=="table")and AddAirbaseNames or{AddAirbaseNames}
for AddAirbaseID,AddAirbaseName in pairs(AddAirbaseNamesArray)do
self:Add(AddAirbaseName,AIRBASE:FindByName(AddAirbaseName))
end
return self
end
function SET_AIRBASE:RemoveAirbasesByName(RemoveAirbaseNames)
local RemoveAirbaseNamesArray=(type(RemoveAirbaseNames)=="table")and RemoveAirbaseNames or{RemoveAirbaseNames}
for RemoveAirbaseID,RemoveAirbaseName in pairs(RemoveAirbaseNamesArray)do
self:Remove(RemoveAirbaseName.AirbaseName)
end
return self
end
function SET_AIRBASE:FindAirbase(AirbaseName)
local AirbaseFound=self.Set[AirbaseName]
return AirbaseFound
end
function SET_AIRBASE:FilterCoalitions(Coalitions)
if not self.Filter.Coalitions then
self.Filter.Coalitions={}
end
if type(Coalitions)~="table"then
Coalitions={Coalitions}
end
for CoalitionID,Coalition in pairs(Coalitions)do
self.Filter.Coalitions[Coalition]=Coalition
end
return self
end
function SET_AIRBASE:FilterCategories(Categories)
if not self.Filter.Categories then
self.Filter.Categories={}
end
if type(Categories)~="table"then
Categories={Categories}
end
for CategoryID,Category in pairs(Categories)do
self.Filter.Categories[Category]=Category
end
return self
end
function SET_AIRBASE:FilterStart()
if _DATABASE then
self:_FilterStart()
end
return self
end
function SET_AIRBASE:AddInDatabase(Event)
self:F3({Event})
return Event.IniDCSUnitName,self.Database[Event.IniDCSUnitName]
end
function SET_AIRBASE:FindInDatabase(Event)
self:F3({Event})
return Event.IniDCSUnitName,self.Database[Event.IniDCSUnitName]
end
function SET_AIRBASE:ForEachAirbase(IteratorFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,arg,self.Set)
return self
end
function SET_AIRBASE:FindNearestAirbaseFromPointVec2(PointVec2)
self:F2(PointVec2)
local NearestAirbase=self:FindNearestObjectFromPointVec2(PointVec2)
return NearestAirbase
end
function SET_AIRBASE:IsIncludeObject(MAirbase)
self:F2(MAirbase)
local MAirbaseInclude=true
if MAirbase then
local MAirbaseName=MAirbase:GetName()
if self.Filter.Coalitions then
local MAirbaseCoalition=false
for CoalitionID,CoalitionName in pairs(self.Filter.Coalitions)do
local AirbaseCoalitionID=_DATABASE:GetCoalitionFromAirbase(MAirbaseName)
self:T3({"Coalition:",AirbaseCoalitionID,self.FilterMeta.Coalitions[CoalitionName],CoalitionName})
if self.FilterMeta.Coalitions[CoalitionName]and self.FilterMeta.Coalitions[CoalitionName]==AirbaseCoalitionID then
MAirbaseCoalition=true
end
end
self:T({"Evaluated Coalition",MAirbaseCoalition})
MAirbaseInclude=MAirbaseInclude and MAirbaseCoalition
end
if self.Filter.Categories then
local MAirbaseCategory=false
for CategoryID,CategoryName in pairs(self.Filter.Categories)do
local AirbaseCategoryID=_DATABASE:GetCategoryFromAirbase(MAirbaseName)
self:T3({"Category:",AirbaseCategoryID,self.FilterMeta.Categories[CategoryName],CategoryName})
if self.FilterMeta.Categories[CategoryName]and self.FilterMeta.Categories[CategoryName]==AirbaseCategoryID then
MAirbaseCategory=true
end
end
self:T({"Evaluated Category",MAirbaseCategory})
MAirbaseInclude=MAirbaseInclude and MAirbaseCategory
end
end
self:T2(MAirbaseInclude)
return MAirbaseInclude
end
SET_CARGO={
ClassName="SET_CARGO",
Cargos={},
Filter={
Coalitions=nil,
Types=nil,
Countries=nil,
ClientPrefixes=nil,
},
FilterMeta={
Coalitions={
red=coalition.side.RED,
blue=coalition.side.BLUE,
neutral=coalition.side.NEUTRAL,
},
},
}
function SET_CARGO:New()
local self=BASE:Inherit(self,SET_BASE:New(_DATABASE.CARGOS))
return self
end
function SET_CARGO:AddCargosByName(AddCargoNames)
local AddCargoNamesArray=(type(AddCargoNames)=="table")and AddCargoNames or{AddCargoNames}
for AddCargoID,AddCargoName in pairs(AddCargoNamesArray)do
self:Add(AddCargoName,CARGO:FindByName(AddCargoName))
end
return self
end
function SET_CARGO:RemoveCargosByName(RemoveCargoNames)
local RemoveCargoNamesArray=(type(RemoveCargoNames)=="table")and RemoveCargoNames or{RemoveCargoNames}
for RemoveCargoID,RemoveCargoName in pairs(RemoveCargoNamesArray)do
self:Remove(RemoveCargoName.CargoName)
end
return self
end
function SET_CARGO:FindCargo(CargoName)
local CargoFound=self.Set[CargoName]
return CargoFound
end
function SET_CARGO:FilterCoalitions(Coalitions)
if not self.Filter.Coalitions then
self.Filter.Coalitions={}
end
if type(Coalitions)~="table"then
Coalitions={Coalitions}
end
for CoalitionID,Coalition in pairs(Coalitions)do
self.Filter.Coalitions[Coalition]=Coalition
end
return self
end
function SET_CARGO:FilterTypes(Types)
if not self.Filter.Types then
self.Filter.Types={}
end
if type(Types)~="table"then
Types={Types}
end
for TypeID,Type in pairs(Types)do
self.Filter.Types[Type]=Type
end
return self
end
function SET_CARGO:FilterCountries(Countries)
if not self.Filter.Countries then
self.Filter.Countries={}
end
if type(Countries)~="table"then
Countries={Countries}
end
for CountryID,Country in pairs(Countries)do
self.Filter.Countries[Country]=Country
end
return self
end
function SET_CARGO:FilterPrefixes(Prefixes)
if not self.Filter.CargoPrefixes then
self.Filter.CargoPrefixes={}
end
if type(Prefixes)~="table"then
Prefixes={Prefixes}
end
for PrefixID,Prefix in pairs(Prefixes)do
self.Filter.CargoPrefixes[Prefix]=Prefix
end
return self
end
function SET_CARGO:FilterStart()
if _DATABASE then
self:_FilterStart()
end
self:HandleEvent(EVENTS.NewCargo)
self:HandleEvent(EVENTS.DeleteCargo)
return self
end
function SET_CARGO:AddInDatabase(Event)
self:F3({Event})
return Event.IniDCSUnitName,self.Database[Event.IniDCSUnitName]
end
function SET_CARGO:FindInDatabase(Event)
self:F3({Event})
return Event.IniDCSUnitName,self.Database[Event.IniDCSUnitName]
end
function SET_CARGO:ForEachCargo(IteratorFunction,...)
self:F2(arg)
self:ForEach(IteratorFunction,arg,self.Set)
return self
end
function SET_CARGO:FindNearestCargoFromPointVec2(PointVec2)
self:F2(PointVec2)
local NearestCargo=self:FindNearestObjectFromPointVec2(PointVec2)
return NearestCargo
end
function SET_CARGO:IsIncludeObject(MCargo)
self:F2(MCargo)
local MCargoInclude=true
if MCargo then
local MCargoName=MCargo:GetName()
if self.Filter.Coalitions then
local MCargoCoalition=false
for CoalitionID,CoalitionName in pairs(self.Filter.Coalitions)do
local CargoCoalitionID=MCargo:GetCoalition()
self:T3({"Coalition:",CargoCoalitionID,self.FilterMeta.Coalitions[CoalitionName],CoalitionName})
if self.FilterMeta.Coalitions[CoalitionName]and self.FilterMeta.Coalitions[CoalitionName]==CargoCoalitionID then
MCargoCoalition=true
end
end
self:T({"Evaluated Coalition",MCargoCoalition})
MCargoInclude=MCargoInclude and MCargoCoalition
end
if self.Filter.Types then
local MCargoType=false
for TypeID,TypeName in pairs(self.Filter.Types)do
self:T3({"Type:",MCargo:GetType(),TypeName})
if TypeName==MCargo:GetType()then
MCargoType=true
end
end
self:T({"Evaluated Type",MCargoType})
MCargoInclude=MCargoInclude and MCargoType
end
if self.Filter.CargoPrefixes then
local MCargoPrefix=false
for CargoPrefixId,CargoPrefix in pairs(self.Filter.CargoPrefixes)do
self:T3({"Prefix:",string.find(MCargo.Name,CargoPrefix,1),CargoPrefix})
if string.find(MCargo.Name,CargoPrefix,1)then
MCargoPrefix=true
end
end
self:T({"Evaluated Prefix",MCargoPrefix})
MCargoInclude=MCargoInclude and MCargoPrefix
end
end
self:T2(MCargoInclude)
return MCargoInclude
end
function SET_CARGO:OnEventNewCargo(EventData)
if EventData.Cargo then
if EventData.Cargo and self:IsIncludeObject(EventData.Cargo)then
self:Add(EventData.Cargo.Name,EventData.Cargo)
end
end
end
function SET_CARGO:OnEventDeleteCargo(EventData)
self:F3({EventData})
if EventData.Cargo then
local Cargo=_DATABASE:FindCargo(EventData.Cargo.Name)
if Cargo and Cargo.Name then
self:Remove(Cargo.Name)
end
end
end
do
COORDINATE={
ClassName="COORDINATE",
}
function COORDINATE:New(x,y,z)
local self=BASE:Inherit(self,BASE:New())
self.x=x
self.y=y
self.z=z
return self
end
function COORDINATE:NewFromVec2(Vec2,LandHeightAdd)
local LandHeight=land.getHeight(Vec2)
LandHeightAdd=LandHeightAdd or 0
LandHeight=LandHeight+LandHeightAdd
local self=self:New(Vec2.x,LandHeight,Vec2.y)
self:F2(self)
return self
end
function COORDINATE:NewFromVec3(Vec3)
local self=self:New(Vec3.x,Vec3.y,Vec3.z)
self:F2(self)
return self
end
function COORDINATE:GetVec3()
return{x=self.x,y=self.y,z=self.z}
end
function COORDINATE:GetVec2()
return{x=self.x,y=self.z}
end
function COORDINATE:DistanceFromVec2(Vec2Reference)
self:F2(Vec2Reference)
local Distance=((Vec2Reference.x-self.x)^2+(Vec2Reference.y-self.z)^2)^0.5
self:T2(Distance)
return Distance
end
function COORDINATE:Translate(Distance,Angle)
local SX=self.x
local SY=self.z
local Radians=Angle/180*math.pi
local TX=Distance*math.cos(Radians)+SX
local TY=Distance*math.sin(Radians)+SY
return COORDINATE:NewFromVec2({x=TX,y=TY})
end
function COORDINATE:GetRandomVec2InRadius(OuterRadius,InnerRadius)
self:F2({OuterRadius,InnerRadius})
local Theta=2*math.pi*math.random()
local Radials=math.random()+math.random()
if Radials>1 then
Radials=2-Radials
end
local RadialMultiplier
if InnerRadius and InnerRadius<=OuterRadius then
RadialMultiplier=(OuterRadius-InnerRadius)*Radials+InnerRadius
else
RadialMultiplier=OuterRadius*Radials
end
local RandomVec2
if OuterRadius>0 then
RandomVec2={x=math.cos(Theta)*RadialMultiplier+self.x,y=math.sin(Theta)*RadialMultiplier+self.z}
else
RandomVec2={x=self.x,y=self.z}
end
return RandomVec2
end
function COORDINATE:GetRandomVec3InRadius(OuterRadius,InnerRadius)
local RandomVec2=self:GetRandomVec2InRadius(OuterRadius,InnerRadius)
local y=self.y+math.random(InnerRadius,OuterRadius)
local RandomVec3={x=RandomVec2.x,y=y,z=RandomVec2.y}
return RandomVec3
end
function COORDINATE:GetLandHeight()
local Vec2={x=self.x,y=self.z}
return land.getHeight(Vec2)
end
function COORDINATE:SetHeading(Heading)
self.Heading=Heading
end
function COORDINATE:GetHeading()
return self.Heading
end
function COORDINATE:SetVelocity(Velocity)
self.Velocity=Velocity
end
function COORDINATE:GetVelocity()
local Velocity=self.Velocity
return Velocity or 0
end
function COORDINATE:GetMovingText(Settings)
return self:GetVelocityText(Settings)..", "..self:GetHeadingText(Settings)
end
function COORDINATE:GetDirectionVec3(TargetCoordinate)
return{x=TargetCoordinate.x-self.x,y=TargetCoordinate.y-self.y,z=TargetCoordinate.z-self.z}
end
function COORDINATE:GetNorthCorrectionRadians()
local TargetVec3=self:GetVec3()
local lat,lon=coord.LOtoLL(TargetVec3)
local north_posit=coord.LLtoLO(lat+1,lon)
return math.atan2(north_posit.z-TargetVec3.z,north_posit.x-TargetVec3.x)
end
function COORDINATE:GetAngleRadians(DirectionVec3)
local DirectionRadians=math.atan2(DirectionVec3.z,DirectionVec3.x)
if DirectionRadians<0 then
DirectionRadians=DirectionRadians+2*math.pi
end
return DirectionRadians
end
function COORDINATE:GetAngleDegrees(DirectionVec3)
local AngleRadians=self:GetAngleRadians(DirectionVec3)
local Angle=UTILS.ToDegree(AngleRadians)
return Angle
end
function COORDINATE:Get2DDistance(TargetCoordinate)
local TargetVec3=TargetCoordinate:GetVec3()
local SourceVec3=self:GetVec3()
return((TargetVec3.x-SourceVec3.x)^2+(TargetVec3.z-SourceVec3.z)^2)^0.5
end
function COORDINATE:Get3DDistance(TargetCoordinate)
local TargetVec3=TargetCoordinate:GetVec3()
local SourceVec3=self:GetVec3()
return((TargetVec3.x-SourceVec3.x)^2+(TargetVec3.y-SourceVec3.y)^2+(TargetVec3.z-SourceVec3.z)^2)^0.5
end
function COORDINATE:GetBearingText(AngleRadians,Precision,Settings)
local Settings=Settings or _SETTINGS
local AngleDegrees=UTILS.Round(UTILS.ToDegree(AngleRadians),Precision)
local s=string.format('%03d°',AngleDegrees)
return s
end
function COORDINATE:GetDistanceText(Distance,Settings)
local Settings=Settings or _SETTINGS
local DistanceText
if Settings:IsMetric()then
DistanceText=" for "..UTILS.Round(Distance/1000,2).." km"
else
DistanceText=" for "..UTILS.Round(UTILS.MetersToNM(Distance),2).." miles"
end
return DistanceText
end
function COORDINATE:GetAltitudeText(Settings)
local Altitude=self.y
local Settings=Settings or _SETTINGS
if Altitude~=0 then
if Settings:IsMetric()then
return" at "..UTILS.Round(self.y,-3).." meters"
else
return" at "..UTILS.Round(UTILS.MetersToFeet(self.y),-3).." feet"
end
else
return""
end
end
function COORDINATE:GetVelocityText(Settings)
local Velocity=self:GetVelocity()
local Settings=Settings or _SETTINGS
if Velocity then
if Settings:IsMetric()then
return string.format(" moving at %d km/h",UTILS.MpsToKmph(Velocity))
else
return string.format(" moving at %d mi/h",UTILS.MpsToKmph(Velocity)/1.852)
end
else
return" stationary"
end
end
function COORDINATE:GetHeadingText(Settings)
local Heading=self:GetHeading()
if Heading then
return string.format(" bearing %3d°",Heading)
else
return" bearing unknown"
end
end
function COORDINATE:GetBRText(AngleRadians,Distance,Settings)
local Settings=Settings or _SETTINGS
local BearingText=self:GetBearingText(AngleRadians,0,Settings)
local DistanceText=self:GetDistanceText(Distance,Settings)
local BRText=BearingText..DistanceText
return BRText
end
function COORDINATE:GetBRAText(AngleRadians,Distance,Settings)
local Settings=Settings or _SETTINGS
local BearingText=self:GetBearingText(AngleRadians,0,Settings)
local DistanceText=self:GetDistanceText(Distance,Settings)
local AltitudeText=self:GetAltitudeText(Settings)
local BRAText=BearingText..DistanceText..AltitudeText
return BRAText
end
function COORDINATE:Translate(Distance,Angle)
local SX=self.x
local SZ=self.z
local Radians=Angle/180*math.pi
local TX=Distance*math.cos(Radians)+SX
local TZ=Distance*math.sin(Radians)+SZ
return COORDINATE:New(TX,self.y,TZ)
end
function COORDINATE:WaypointAir(AltType,Type,Action,Speed,SpeedLocked)
self:F2({AltType,Type,Action,Speed,SpeedLocked})
local RoutePoint={}
RoutePoint.x=self.x
RoutePoint.y=self.z
RoutePoint.alt=self.y
RoutePoint.alt_type=AltType or"RADIO"
RoutePoint.type=Type or nil
RoutePoint.action=Action or nil
RoutePoint.speed=(Speed and Speed/3.6)or(500/3.6)
RoutePoint.speed_locked=true
RoutePoint.task={}
RoutePoint.task.id="ComboTask"
RoutePoint.task.params={}
RoutePoint.task.params.tasks={}
return RoutePoint
end
function COORDINATE:WaypointGround(Speed,Formation)
self:F2({Formation,Speed})
local RoutePoint={}
RoutePoint.x=self.x
RoutePoint.y=self.z
RoutePoint.action=Formation or""
RoutePoint.speed=(Speed or 999)/3.6
RoutePoint.speed_locked=true
RoutePoint.task={}
RoutePoint.task.id="ComboTask"
RoutePoint.task.params={}
RoutePoint.task.params.tasks={}
return RoutePoint
end
function COORDINATE:Explosion(ExplosionIntensity)
self:F2({ExplosionIntensity})
trigger.action.explosion(self:GetVec3(),ExplosionIntensity)
end
function COORDINATE:IlluminationBomb()
self:F2()
trigger.action.illuminationBomb(self:GetVec3())
end
function COORDINATE:Smoke(SmokeColor)
self:F2({SmokeColor})
trigger.action.smoke(self:GetVec3(),SmokeColor)
end
function COORDINATE:SmokeGreen()
self:F2()
self:Smoke(SMOKECOLOR.Green)
end
function COORDINATE:SmokeRed()
self:F2()
self:Smoke(SMOKECOLOR.Red)
end
function COORDINATE:SmokeWhite()
self:F2()
self:Smoke(SMOKECOLOR.White)
end
function COORDINATE:SmokeOrange()
self:F2()
self:Smoke(SMOKECOLOR.Orange)
end
function COORDINATE:SmokeBlue()
self:F2()
self:Smoke(SMOKECOLOR.Blue)
end
function COORDINATE:Flare(FlareColor,Azimuth)
self:F2({FlareColor})
trigger.action.signalFlare(self:GetVec3(),FlareColor,Azimuth and Azimuth or 0)
end
function COORDINATE:FlareWhite(Azimuth)
self:F2(Azimuth)
self:Flare(FLARECOLOR.White,Azimuth)
end
function COORDINATE:FlareYellow(Azimuth)
self:F2(Azimuth)
self:Flare(FLARECOLOR.Yellow,Azimuth)
end
function COORDINATE:FlareGreen(Azimuth)
self:F2(Azimuth)
self:Flare(FLARECOLOR.Green,Azimuth)
end
function COORDINATE:FlareRed(Azimuth)
self:F2(Azimuth)
self:Flare(FLARECOLOR.Red,Azimuth)
end
do
function COORDINATE:MarkToAll(MarkText)
local MarkID=UTILS.GetMarkID()
trigger.action.markToAll(MarkID,MarkText,self:GetVec3())
return MarkID
end
function COORDINATE:MarkToCoalition(MarkText,Coalition)
local MarkID=UTILS.GetMarkID()
trigger.action.markToCoalition(MarkID,MarkText,self:GetVec3(),Coalition)
return MarkID
end
function COORDINATE:MarkToCoalitionRed(MarkText)
return self:MarkToCoalition(MarkText,coalition.side.RED)
end
function COORDINATE:MarkToCoalitionBlue(MarkText)
return self:MarkToCoalition(MarkText,coalition.side.BLUE)
end
function COORDINATE:MarkToGroup(MarkText,MarkGroup)
local MarkID=UTILS.GetMarkID()
trigger.action.markToGroup(MarkID,MarkText,self:GetVec3(),MarkGroup:GetID())
return MarkID
end
function COORDINATE:RemoveMark(MarkID)
trigger.action.removeMark(MarkID)
end
end
function COORDINATE:IsLOS(ToCoordinate)
local FromVec3=self:GetVec3()
FromVec3.y=FromVec3.y+2
local ToVec3=ToCoordinate:GetVec3()
ToVec3.y=ToVec3.y+2
local IsLOS=land.isVisible(FromVec3,ToVec3)
return IsLOS
end
function COORDINATE:IsInRadius(Coordinate,Radius)
local InVec2=self:GetVec2()
local Vec2=Coordinate:GetVec2()
local InRadius=UTILS.IsInRadius(InVec2,Vec2,Radius)
return InRadius
end
function COORDINATE:IsInSphere(Coordinate,Radius)
local InVec3=self:GetVec3()
local Vec3=Coordinate:GetVec3()
local InSphere=UTILS.IsInSphere(InVec3,Vec3,Radius)
return InSphere
end
function COORDINATE:ToStringBR(FromCoordinate,Settings)
local DirectionVec3=FromCoordinate:GetDirectionVec3(self)
local AngleRadians=self:GetAngleRadians(DirectionVec3)
local Distance=self:Get2DDistance(FromCoordinate)
return"BR, "..self:GetBRText(AngleRadians,Distance,Settings)
end
function COORDINATE:ToStringBRA(FromCoordinate,Settings)
local DirectionVec3=FromCoordinate:GetDirectionVec3(self)
local AngleRadians=self:GetAngleRadians(DirectionVec3)
local Distance=FromCoordinate:Get2DDistance(self)
local Altitude=self:GetAltitudeText()
return"BRA, "..self:GetBRAText(AngleRadians,Distance,Settings)
end
function COORDINATE:ToStringBULLS(Coalition,Settings)
local TargetCoordinate=COORDINATE:NewFromVec3(coalition.getMainRefPoint(Coalition))
local DirectionVec3=self:GetDirectionVec3(TargetCoordinate)
local AngleRadians=self:GetAngleRadians(DirectionVec3)
local Distance=self:Get2DDistance(TargetCoordinate)
local Altitude=self:GetAltitudeText()
return"BULLS, "..self:GetBRText(AngleRadians,Distance,Settings)
end
function COORDINATE:ToStringAspect(TargetCoordinate)
local Heading=self.Heading
local DirectionVec3=self:GetDirectionVec3(TargetCoordinate)
local Angle=self:GetAngleDegrees(DirectionVec3)
if Heading then
local Aspect=Angle-Heading
if Aspect>-135 and Aspect<=-45 then
return"Flanking"
end
if Aspect>-45 and Aspect<=45 then
return"Hot"
end
if Aspect>45 and Aspect<=135 then
return"Flanking"
end
if Aspect>135 or Aspect<=-135 then
return"Cold"
end
end
return""
end
function COORDINATE:ToStringLLDMS(Settings)
local LL_Accuracy=Settings and Settings.LL_Accuracy or _SETTINGS.LL_Accuracy
local lat,lon=coord.LOtoLL(self:GetVec3())
return"LL DMS, "..UTILS.tostringLL(lat,lon,LL_Accuracy,true)
end
function COORDINATE:ToStringLLDDM(Settings)
local LL_Accuracy=Settings and Settings.LL_Accuracy or _SETTINGS.LL_Accuracy
local lat,lon=coord.LOtoLL(self:GetVec3())
return"LL DDM, "..UTILS.tostringLL(lat,lon,LL_Accuracy,false)
end
function COORDINATE:ToStringMGRS(Settings)
local MGRS_Accuracy=Settings and Settings.MGRS_Accuracy or _SETTINGS.MGRS_Accuracy
local lat,lon=coord.LOtoLL(self:GetVec3())
local MGRS=coord.LLtoMGRS(lat,lon)
return"MGRS, "..UTILS.tostringMGRS(MGRS,MGRS_Accuracy)
end
function COORDINATE:ToStringFromRP(ReferenceCoord,ReferenceName,Controllable,Settings)
self:E({ReferenceCoord=ReferenceCoord,ReferenceName=ReferenceName})
local Settings=Settings or(Controllable and _DATABASE:GetPlayerSettings(Controllable:GetPlayerName()))or _SETTINGS
local IsAir=Controllable and Controllable:IsAirPlane()or false
if IsAir then
local DirectionVec3=ReferenceCoord:GetDirectionVec3(self)
local AngleRadians=self:GetAngleRadians(DirectionVec3)
local Distance=self:Get2DDistance(ReferenceCoord)
return"Targets are the last seen "..self:GetBRText(AngleRadians,Distance,Settings).." from "..ReferenceName
else
local DirectionVec3=ReferenceCoord:GetDirectionVec3(self)
local AngleRadians=self:GetAngleRadians(DirectionVec3)
local Distance=self:Get2DDistance(ReferenceCoord)
return"Target are located "..self:GetBRText(AngleRadians,Distance,Settings).." from "..ReferenceName
end
return nil
end
function COORDINATE:ToStringA2G(Controllable,Settings)
self:F({Controllable=Controllable and Controllable:GetName()})
local Settings=Settings or(Controllable and _DATABASE:GetPlayerSettings(Controllable:GetPlayerName()))or _SETTINGS
if Settings:IsA2G_BR()then
if Controllable then
local Coordinate=Controllable:GetCoordinate()
return Controllable and self:ToStringBR(Coordinate,Settings)or self:ToStringMGRS(Settings)
else
return self:ToStringMGRS(Settings)
end
end
if Settings:IsA2G_LL_DMS()then
return self:ToStringLLDMS(Settings)
end
if Settings:IsA2G_LL_DDM()then
return self:ToStringLLDDM(Settings)
end
if Settings:IsA2G_MGRS()then
return self:ToStringMGRS(Settings)
end
return nil
end
function COORDINATE:ToStringA2A(Controllable,Settings)
self:F({Controllable=Controllable and Controllable:GetName()})
local Settings=Settings or(Controllable and _DATABASE:GetPlayerSettings(Controllable:GetPlayerName()))or _SETTINGS
if Settings:IsA2A_BRAA()then
if Controllable then
local Coordinate=Controllable:GetCoordinate()
return self:ToStringBRA(Coordinate,Settings)
else
return self:ToStringMGRS(Settings)
end
end
if Settings:IsA2A_BULLS()then
local Coalition=Controllable:GetCoalition()
return self:ToStringBULLS(Coalition,Settings)
end
if Settings:IsA2A_LL_DMS()then
return self:ToStringLLDMS(Settings)
end
if Settings:IsA2A_LL_DDM()then
return self:ToStringLLDDM(Settings)
end
if Settings:IsA2A_MGRS()then
return self:ToStringMGRS(Settings)
end
return nil
end
function COORDINATE:ToString(Controllable,Settings,Task)
self:F({Controllable=Controllable and Controllable:GetName()})
local Settings=Settings or(Controllable and _DATABASE:GetPlayerSettings(Controllable:GetPlayerName()))or _SETTINGS
local ModeA2A=false
if Task then
if Task:IsInstanceOf(TASK_A2A)then
ModeA2A=true
else
if Task:IsInstanceOf(TASK_A2G)then
ModeA2A=false
else
if Task:IsInstanceOf(TASK_CARGO)then
ModeA2A=false
else
ModeA2A=false
end
end
end
else
local IsAir=Controllable and Controllable:IsAirPlane()or false
if IsAir then
ModeA2A=true
else
ModeA2A=false
end
end
if ModeA2A==true then
return self:ToStringA2A(Controllable,Settings)
else
return self:ToStringA2G(Controllable,Settings)
end
return nil
end
end
do
POINT_VEC3={
ClassName="POINT_VEC3",
Metric=true,
RoutePointAltType={
BARO="BARO",
},
RoutePointType={
TakeOffParking="TakeOffParking",
TurningPoint="Turning Point",
},
RoutePointAction={
FromParkingArea="From Parking Area",
TurningPoint="Turning Point",
},
}
function POINT_VEC3:New(x,y,z)
local self=BASE:Inherit(self,COORDINATE:New(x,y,z))
self:F2(self)
return self
end
function POINT_VEC3:NewFromVec2(Vec2,LandHeightAdd)
local self=BASE:Inherit(self,COORDINATE:NewFromVec2(Vec2,LandHeightAdd))
self:F2(self)
return self
end
function POINT_VEC3:NewFromVec3(Vec3)
local self=BASE:Inherit(self,COORDINATE:NewFromVec3(Vec3))
self:F2(self)
return self
end
function POINT_VEC3:GetX()
return self.x
end
function POINT_VEC3:GetY()
return self.y
end
function POINT_VEC3:GetZ()
return self.z
end
function POINT_VEC3:SetX(x)
self.x=x
return self
end
function POINT_VEC3:SetY(y)
self.y=y
return self
end
function POINT_VEC3:SetZ(z)
self.z=z
return self
end
function POINT_VEC3:AddX(x)
self.x=self.x+x
return self
end
function POINT_VEC3:AddY(y)
self.y=self.y+y
return self
end
function POINT_VEC3:AddZ(z)
self.z=self.z+z
return self
end
function POINT_VEC3:GetRandomPointVec3InRadius(OuterRadius,InnerRadius)
return POINT_VEC3:NewFromVec3(self:GetRandomVec3InRadius(OuterRadius,InnerRadius))
end
end
do
POINT_VEC2={
ClassName="POINT_VEC2",
}
function POINT_VEC2:New(x,y,LandHeightAdd)
local LandHeight=land.getHeight({["x"]=x,["y"]=y})
LandHeightAdd=LandHeightAdd or 0
LandHeight=LandHeight+LandHeightAdd
local self=BASE:Inherit(self,COORDINATE:New(x,LandHeight,y))
self:F2(self)
return self
end
function POINT_VEC2:NewFromVec2(Vec2,LandHeightAdd)
local LandHeight=land.getHeight(Vec2)
LandHeightAdd=LandHeightAdd or 0
LandHeight=LandHeight+LandHeightAdd
local self=BASE:Inherit(self,COORDINATE:NewFromVec2(Vec2,LandHeightAdd))
self:F2(self)
return self
end
function POINT_VEC2:NewFromVec3(Vec3)
local self=BASE:Inherit(self,COORDINATE:NewFromVec3(Vec3))
self:F2(self)
return self
end
function POINT_VEC2:GetX()
return self.x
end
function POINT_VEC2:GetY()
return self.z
end
function POINT_VEC2:SetX(x)
self.x=x
return self
end
function POINT_VEC2:SetY(y)
self.z=y
return self
end
function POINT_VEC2:GetLat()
return self.x
end
function POINT_VEC2:SetLat(x)
self.x=x
return self
end
function POINT_VEC2:GetLon()
return self.z
end
function POINT_VEC2:SetLon(z)
self.z=z
return self
end
function POINT_VEC2:GetAlt()
return self.y~=0 or land.getHeight({x=self.x,y=self.z})
end
function POINT_VEC2:SetAlt(Altitude)
self.y=Altitude or land.getHeight({x=self.x,y=self.z})
return self
end
function POINT_VEC2:AddX(x)
self.x=self.x+x
return self
end
function POINT_VEC2:AddY(y)
self.z=self.z+y
return self
end
function POINT_VEC2:AddAlt(Altitude)
self.y=land.getHeight({x=self.x,y=self.z})+Altitude or 0
return self
end
function POINT_VEC2:GetRandomPointVec2InRadius(OuterRadius,InnerRadius)
self:F2({OuterRadius,InnerRadius})
return POINT_VEC2:NewFromVec2(self:GetRandomVec2InRadius(OuterRadius,InnerRadius))
end
function POINT_VEC2:DistanceFromPointVec2(PointVec2Reference)
self:F2(PointVec2Reference)
local Distance=((PointVec2Reference.x-self.x)^2+(PointVec2Reference.z-self.z)^2)^0.5
self:T2(Distance)
return Distance
end
end
MESSAGE={
ClassName="MESSAGE",
MessageCategory=0,
MessageID=0,
}
MESSAGE.Type={
Update="Update",
Information="Information",
Briefing="Briefing Report",
Overview="Overview Report",
Detailed="Detailed Report"
}
function MESSAGE:New(MessageText,MessageDuration,MessageCategory)
local self=BASE:Inherit(self,BASE:New())
self:F({MessageText,MessageDuration,MessageCategory})
self.MessageType=nil
if MessageCategory and MessageCategory~=""then
if MessageCategory:sub(-1)~="\n"then
self.MessageCategory=MessageCategory..": "
else
self.MessageCategory=MessageCategory:sub(1,-2)..":\n"
end
else
self.MessageCategory=""
end
self.MessageDuration=MessageDuration or 5
self.MessageTime=timer.getTime()
self.MessageText=MessageText:gsub("^\n","",1):gsub("\n$","",1)
self.MessageSent=false
self.MessageGroup=false
self.MessageCoalition=false
return self
end
function MESSAGE:NewType(MessageText,MessageType)
local self=BASE:Inherit(self,BASE:New())
self:F({MessageText})
self.MessageType=MessageType
self.MessageTime=timer.getTime()
self.MessageText=MessageText:gsub("^\n","",1):gsub("\n$","",1)
return self
end
function MESSAGE:ToClient(Client,Settings)
self:F(Client)
if Client and Client:GetClientGroupID()then
if self.MessageType then
local Settings=Settings or(Client and _DATABASE:GetPlayerSettings(Client:GetPlayerName()))or _SETTINGS
self.MessageDuration=Settings:GetMessageTime(self.MessageType)
self.MessageCategory=""
end
if self.MessageDuration~=0 then
local ClientGroupID=Client:GetClientGroupID()
self:T(self.MessageCategory..self.MessageText:gsub("\n$",""):gsub("\n$","").." / "..self.MessageDuration)
trigger.action.outTextForGroup(ClientGroupID,self.MessageCategory..self.MessageText:gsub("\n$",""):gsub("\n$",""),self.MessageDuration)
end
end
return self
end
function MESSAGE:ToGroup(Group,Settings)
self:F(Group.GroupName)
if Group then
if self.MessageType then
local Settings=Settings or(Group and _DATABASE:GetPlayerSettings(Group:GetPlayerName()))or _SETTINGS
self.MessageDuration=Settings:GetMessageTime(self.MessageType)
self.MessageCategory=""
end
if self.MessageDuration~=0 then
self:T(self.MessageCategory..self.MessageText:gsub("\n$",""):gsub("\n$","").." / "..self.MessageDuration)
trigger.action.outTextForGroup(Group:GetID(),self.MessageCategory..self.MessageText:gsub("\n$",""):gsub("\n$",""),self.MessageDuration)
end
end
return self
end
function MESSAGE:ToBlue()
self:F()
self:ToCoalition(coalition.side.BLUE)
return self
end
function MESSAGE:ToRed()
self:F()
self:ToCoalition(coalition.side.RED)
return self
end
function MESSAGE:ToCoalition(CoalitionSide,Settings)
self:F(CoalitionSide)
if self.MessageType then
local Settings=Settings or _SETTINGS
self.MessageDuration=Settings:GetMessageTime(self.MessageType)
self.MessageCategory=""
end
if CoalitionSide then
if self.MessageDuration~=0 then
self:T(self.MessageCategory..self.MessageText:gsub("\n$",""):gsub("\n$","").." / "..self.MessageDuration)
trigger.action.outTextForCoalition(CoalitionSide,self.MessageText:gsub("\n$",""):gsub("\n$",""),self.MessageDuration)
end
end
return self
end
function MESSAGE:ToCoalitionIf(CoalitionSide,Condition)
self:F(CoalitionSide)
if Condition and Condition==true then
self:ToCoalition(CoalitionSide)
end
return self
end
function MESSAGE:ToAll()
self:F()
if self.MessageType then
local Settings=Settings or _SETTINGS
self.MessageDuration=Settings:GetMessageTime(self.MessageType)
self.MessageCategory=""
end
if self.MessageDuration~=0 then
self:T(self.MessageCategory..self.MessageText:gsub("\n$",""):gsub("\n$","").." / "..self.MessageDuration)
trigger.action.outText(self.MessageCategory..self.MessageText:gsub("\n$",""):gsub("\n$",""),self.MessageDuration)
end
return self
end
function MESSAGE:ToAllIf(Condition)
if Condition and Condition==true then
self:ToAll()
end
return self
end
do
FSM={
ClassName="FSM",
}
function FSM:New(FsmT)
self=BASE:Inherit(self,BASE:New())
self.options=options or{}
self.options.subs=self.options.subs or{}
self.current=self.options.initial or'none'
self.Events={}
self.subs={}
self.endstates={}
self.Scores={}
self._StartState="none"
self._Transitions={}
self._Processes={}
self._EndStates={}
self._Scores={}
self._EventSchedules={}
self.CallScheduler=SCHEDULER:New(self)
return self
end
function FSM:SetStartState(State)
self._StartState=State
self.current=State
end
function FSM:GetStartState()
return self._StartState or{}
end
function FSM:AddTransition(From,Event,To)
local Transition={}
Transition.From=From
Transition.Event=Event
Transition.To=To
self:T2(Transition)
self._Transitions[Transition]=Transition
self:_eventmap(self.Events,Transition)
end
function FSM:GetTransitions()
return self._Transitions or{}
end
function FSM:AddProcess(From,Event,Process,ReturnEvents)
self:T({From,Event})
local Sub={}
Sub.From=From
Sub.Event=Event
Sub.fsm=Process
Sub.StartEvent="Start"
Sub.ReturnEvents=ReturnEvents
self._Processes[Sub]=Sub
self:_submap(self.subs,Sub,nil)
self:AddTransition(From,Event,From)
return Process
end
function FSM:GetProcesses()
return self._Processes or{}
end
function FSM:GetProcess(From,Event)
for ProcessID,Process in pairs(self:GetProcesses())do
if Process.From==From and Process.Event==Event then
return Process.fsm
end
end
error("Sub-Process from state "..From.." with event "..Event.." not found!")
end
function FSM:AddEndState(State)
self._EndStates[State]=State
self.endstates[State]=State
end
function FSM:GetEndStates()
return self._EndStates or{}
end
function FSM:AddScore(State,ScoreText,Score)
self:F({State,ScoreText,Score})
self._Scores[State]=self._Scores[State]or{}
self._Scores[State].ScoreText=ScoreText
self._Scores[State].Score=Score
return self
end
function FSM:AddScoreProcess(From,Event,State,ScoreText,Score)
self:F({From,Event,State,ScoreText,Score})
local Process=self:GetProcess(From,Event)
Process._Scores[State]=Process._Scores[State]or{}
Process._Scores[State].ScoreText=ScoreText
Process._Scores[State].Score=Score
self:T(Process._Scores)
return Process
end
function FSM:GetScores()
return self._Scores or{}
end
function FSM:GetSubs()
return self.options.subs
end
function FSM:LoadCallBacks(CallBackTable)
for name,callback in pairs(CallBackTable or{})do
self[name]=callback
end
end
function FSM:_eventmap(Events,EventStructure)
local Event=EventStructure.Event
local __Event="__"..EventStructure.Event
self[Event]=self[Event]or self:_create_transition(Event)
self[__Event]=self[__Event]or self:_delayed_transition(Event)
self:T2("Added methods: "..Event..", "..__Event)
Events[Event]=self.Events[Event]or{map={}}
self:_add_to_map(Events[Event].map,EventStructure)
end
function FSM:_submap(subs,sub,name)
subs[sub.From]=subs[sub.From]or{}
subs[sub.From][sub.Event]=subs[sub.From][sub.Event]or{}
subs[sub.From][sub.Event][sub]={}
subs[sub.From][sub.Event][sub].fsm=sub.fsm
subs[sub.From][sub.Event][sub].StartEvent=sub.StartEvent
subs[sub.From][sub.Event][sub].ReturnEvents=sub.ReturnEvents or{}
subs[sub.From][sub.Event][sub].name=name
subs[sub.From][sub.Event][sub].fsmparent=self
end
function FSM:_call_handler(handler,params,EventName)
local ErrorHandler=function(errmsg)
env.info("Error in SCHEDULER function:"..errmsg)
if debug~=nil then
env.info(debug.traceback())
end
return errmsg
end
if self[handler]then
self:T2("Calling "..handler)
self._EventSchedules[EventName]=nil
local Result,Value=xpcall(function()return self[handler](self,unpack(params))end,ErrorHandler)
return Value
end
end
function FSM._handler(self,EventName,...)
local Can,to=self:can(EventName)
if to=="*"then
to=self.current
end
if Can then
local from=self.current
local params={from,EventName,to,...}
if self.Controllable then
self:T("FSM Transition for "..self.Controllable.ControllableName.." :"..self.current.." --> "..EventName.." --> "..to)
else
self:T("FSM Transition:"..self.current.." --> "..EventName.." --> "..to)
end
if(self:_call_handler("onbefore"..EventName,params,EventName)==false)
or(self:_call_handler("OnBefore"..EventName,params,EventName)==false)
or(self:_call_handler("onleave"..from,params,EventName)==false)
or(self:_call_handler("OnLeave"..from,params,EventName)==false)then
self:T("Cancel Transition")
return false
end
self.current=to
local execute=true
local subtable=self:_gosub(from,EventName)
for _,sub in pairs(subtable)do
self:T("calling sub start event: "..sub.StartEvent)
sub.fsm.fsmparent=self
sub.fsm.ReturnEvents=sub.ReturnEvents
sub.fsm[sub.StartEvent](sub.fsm)
execute=false
end
local fsmparent,Event=self:_isendstate(to)
if fsmparent and Event then
self:F2({"end state: ",fsmparent,Event})
self:_call_handler("onenter"..to,params,EventName)
self:_call_handler("OnEnter"..to,params,EventName)
self:_call_handler("onafter"..EventName,params,EventName)
self:_call_handler("OnAfter"..EventName,params,EventName)
self:_call_handler("onstatechange",params,EventName)
fsmparent[Event](fsmparent)
execute=false
end
if execute then
self:_call_handler("onenter"..to,params,EventName)
self:_call_handler("OnEnter"..to,params,EventName)
self:_call_handler("onafter"..EventName,params,EventName)
self:_call_handler("OnAfter"..EventName,params,EventName)
self:_call_handler("onstatechange",params,EventName)
end
else
self:T("Cannot execute transition.")
self:T({From=self.current,Event=EventName,To=to,Can=Can})
end
return nil
end
function FSM:_delayed_transition(EventName)
return function(self,DelaySeconds,...)
self:T2("Delayed Event: "..EventName)
local CallID=0
if DelaySeconds~=nil then
if DelaySeconds<0 then
DelaySeconds=math.abs(DelaySeconds)
if not self._EventSchedules[EventName]then
CallID=self.CallScheduler:Schedule(self,self._handler,{EventName,...},DelaySeconds or 1)
self._EventSchedules[EventName]=CallID
else
end
else
CallID=self.CallScheduler:Schedule(self,self._handler,{EventName,...},DelaySeconds or 1)
end
else
error("FSM: An asynchronous event trigger requires a DelaySeconds parameter!!! This can be positive or negative! Sorry, but will not process this.")
end
self:T2({CallID=CallID})
end
end
function FSM:_create_transition(EventName)
return function(self,...)return self._handler(self,EventName,...)end
end
function FSM:_gosub(ParentFrom,ParentEvent)
local fsmtable={}
if self.subs[ParentFrom]and self.subs[ParentFrom][ParentEvent]then
self:T({ParentFrom,ParentEvent,self.subs[ParentFrom],self.subs[ParentFrom][ParentEvent]})
return self.subs[ParentFrom][ParentEvent]
else
return{}
end
end
function FSM:_isendstate(Current)
local FSMParent=self.fsmparent
if FSMParent and self.endstates[Current]then
self:T({state=Current,endstates=self.endstates,endstate=self.endstates[Current]})
FSMParent.current=Current
local ParentFrom=FSMParent.current
self:T(ParentFrom)
self:T(self.ReturnEvents)
local Event=self.ReturnEvents[Current]
self:T({ParentFrom,Event,self.ReturnEvents})
if Event then
return FSMParent,Event
else
self:T({"Could not find parent event name for state ",ParentFrom})
end
end
return nil
end
function FSM:_add_to_map(Map,Event)
self:F3({Map,Event})
if type(Event.From)=='string'then
Map[Event.From]=Event.To
else
for _,From in ipairs(Event.From)do
Map[From]=Event.To
end
end
self:T3({Map,Event})
end
function FSM:GetState()
return self.current
end
function FSM:Is(State)
return self.current==State
end
function FSM:is(state)
return self.current==state
end
function FSM:can(e)
local Event=self.Events[e]
self:F3({self.current,Event})
local To=Event and Event.map[self.current]or Event.map['*']
return To~=nil,To
end
function FSM:cannot(e)
return not self:can(e)
end
end
do
FSM_CONTROLLABLE={
ClassName="FSM_CONTROLLABLE",
}
function FSM_CONTROLLABLE:New(FSMT,Controllable)
local self=BASE:Inherit(self,FSM:New(FSMT))
if Controllable then
self:SetControllable(Controllable)
end
self:AddTransition("*","Stop","Stopped")
return self
end
function FSM_CONTROLLABLE:OnAfterStop(Controllable,From,Event,To)
self.CallScheduler:Clear()
end
function FSM_CONTROLLABLE:SetControllable(FSMControllable)
self.Controllable=FSMControllable
end
function FSM_CONTROLLABLE:GetControllable()
return self.Controllable
end
function FSM_CONTROLLABLE:_call_handler(handler,params,EventName)
local ErrorHandler=function(errmsg)
env.info("Error in SCHEDULER function:"..errmsg)
if debug~=nil then
env.info(debug.traceback())
end
return errmsg
end
if self[handler]then
self:F3("Calling "..handler)
self._EventSchedules[EventName]=nil
local Result,Value=xpcall(function()return self[handler](self,self.Controllable,unpack(params))end,ErrorHandler)
return Value
end
end
end
do
FSM_PROCESS={
ClassName="FSM_PROCESS",
}
function FSM_PROCESS:New(Controllable,Task)
local self=BASE:Inherit(self,FSM_CONTROLLABLE:New())
self:Assign(Controllable,Task)
return self
end
function FSM_PROCESS:Init(FsmProcess)
self:T("No Initialisation")
end
function FSM_PROCESS:_call_handler(handler,params,EventName)
local ErrorHandler=function(errmsg)
env.info("Error in FSM_PROCESS call handler:"..errmsg)
if debug~=nil then
env.info(debug.traceback())
end
return errmsg
end
if self[handler]then
self:F3("Calling "..handler)
self._EventSchedules[EventName]=nil
local Result,Value=xpcall(function()return self[handler](self,self.Controllable,self.Task,unpack(params))end,ErrorHandler)
return Value
end
end
function FSM_PROCESS:Copy(Controllable,Task)
self:T({self:GetClassNameAndID()})
local NewFsm=self:New(Controllable,Task)
NewFsm:Assign(Controllable,Task)
NewFsm:Init(self)
NewFsm:SetStartState(self:GetStartState())
for TransitionID,Transition in pairs(self:GetTransitions())do
NewFsm:AddTransition(Transition.From,Transition.Event,Transition.To)
end
for ProcessID,Process in pairs(self:GetProcesses())do
local FsmProcess=NewFsm:AddProcess(Process.From,Process.Event,Process.fsm:Copy(Controllable,Task),Process.ReturnEvents)
end
for EndStateID,EndState in pairs(self:GetEndStates())do
self:T(EndState)
NewFsm:AddEndState(EndState)
end
for ScoreID,Score in pairs(self:GetScores())do
self:T(Score)
NewFsm:AddScore(ScoreID,Score.ScoreText,Score.Score)
end
return NewFsm
end
function FSM_PROCESS:Remove()
self:F({self:GetClassNameAndID()})
self:F("Clearing Schedules")
self.CallScheduler:Clear()
for ProcessID,Process in pairs(self:GetProcesses())do
if Process.fsm then
Process.fsm:Remove()
Process.fsm=nil
end
end
return self
end
function FSM_PROCESS:SetTask(Task)
self.Task=Task
return self
end
function FSM_PROCESS:GetTask()
return self.Task
end
function FSM_PROCESS:GetMission()
return self.Task.Mission
end
function FSM_PROCESS:GetCommandCenter()
return self:GetTask():GetMission():GetCommandCenter()
end
function FSM_PROCESS:Message(Message)
self:F({Message=Message})
local CC=self:GetCommandCenter()
local TaskGroup=self.Controllable:GetGroup()
local PlayerName=self.Controllable:GetPlayerName()
PlayerName=PlayerName and" ("..PlayerName..")"or""
local Callsign=self.Controllable:GetCallsign()
local Prefix=Callsign and" @ "..Callsign..PlayerName or""
Message=Prefix..": "..Message
CC:MessageToGroup(Message,TaskGroup)
end
function FSM_PROCESS:Assign(ProcessUnit,Task)
self:SetControllable(ProcessUnit)
self:SetTask(Task)
return self
end
function FSM_PROCESS:onenterAssigned(ProcessUnit)
self:T("Assign")
self.Task:Assign()
end
function FSM_PROCESS:onenterFailed(ProcessUnit)
self:T("Failed")
self.Task:Fail()
end
function FSM_PROCESS:onstatechange(ProcessUnit,Task,From,Event,To,Dummy)
self:T({ProcessUnit:GetName(),From,Event,To,Dummy,self:IsTrace()})
if self:IsTrace()then
end
self:T({Scores=self._Scores,To=To})
if self._Scores[To]then
local Task=self.Task
local Scoring=Task:GetScoring()
if Scoring then
Scoring:_AddMissionTaskScore(Task.Mission,ProcessUnit,self._Scores[To].ScoreText,self._Scores[To].Score)
end
end
end
end
do
FSM_TASK={
ClassName="FSM_TASK",
}
function FSM_TASK:New(FSMT)
local self=BASE:Inherit(self,FSM_CONTROLLABLE:New(FSMT))
self["onstatechange"]=self.OnStateChange
return self
end
function FSM_TASK:_call_handler(handler,params,EventName)
if self[handler]then
self:T("Calling "..handler)
self._EventSchedules[EventName]=nil
return self[handler](self,unpack(params))
end
end
end
do
FSM_SET={
ClassName="FSM_SET",
}
function FSM_SET:New(FSMSet)
self=BASE:Inherit(self,FSM:New())
if FSMSet then
self:Set(FSMSet)
end
return self
end
function FSM_SET:Set(FSMSet)
self:F(FSMSet)
self.Set=FSMSet
end
function FSM_SET:Get()
return self.Controllable
end
function FSM_SET:_call_handler(handler,params,EventName)
if self[handler]then
self:T("Calling "..handler)
self._EventSchedules[EventName]=nil
return self[handler](self,self.Set,unpack(params))
end
end
end
RADIO={
ClassName="RADIO",
FileName="",
Frequency=0,
Modulation=radio.modulation.AM,
Subtitle="",
SubtitleDuration=0,
Power=100,
Loop=true,
}
function RADIO:New(Positionable)
local self=BASE:Inherit(self,BASE:New())
self.Loop=true
self:F(Positionable)
if Positionable:GetPointVec2()then
self.Positionable=Positionable
return self
end
self:E({"The passed positionable is invalid, no RADIO created",Positionable})
return nil
end
function RADIO:SetFileName(FileName)
self:F2(FileName)
if type(FileName)=="string"then
if FileName:find(".ogg")or FileName:find(".wav")then
if not FileName:find("l10n/DEFAULT/")then
FileName="l10n/DEFAULT/"..FileName
end
self.FileName=FileName
return self
end
end
self:E({"File name invalid. Maybe something wrong with the extension ?",self.FileName})
return self
end
function RADIO:SetFrequency(Frequency)
self:F2(Frequency)
if type(Frequency)=="number"then
if(Frequency>=30 and Frequency<88)or(Frequency>=108 and Frequency<152)or(Frequency>=225 and Frequency<400)then
self.Frequency=Frequency*1000000
if self.Positionable.ClassName=="UNIT"or self.Positionable.ClassName=="GROUP"then
self.Positionable:SetCommand({
id="SetFrequency",
params={
frequency=self.Frequency,
modulation=self.Modulation,
}
})
end
return self
end
end
self:E({"Frequency is outside of DCS Frequency ranges (30-80, 108-152, 225-400). Frequency unchanged.",self.Frequency})
return self
end
function RADIO:SetModulation(Modulation)
self:F2(Modulation)
if type(Modulation)=="number"then
if Modulation==radio.modulation.AM or Modulation==radio.modulation.FM then
self.Modulation=Modulation
return self
end
end
self:E({"Modulation is invalid. Use DCS's enum radio.modulation. Modulation unchanged.",self.Modulation})
return self
end
function RADIO:SetPower(Power)
self:F2(Power)
if type(Power)=="number"then
self.Power=math.floor(math.abs(Power))
return self
end
self:E({"Power is invalid. Power unchanged.",self.Power})
return self
end
function RADIO:SetLoop(Loop)
self:F2(Loop)
if type(Loop)=="boolean"then
self.Loop=Loop
return self
end
self:E({"Loop is invalid. Loop unchanged.",self.Loop})
return self
end
function RADIO:SetSubtitle(Subtitle,SubtitleDuration)
self:F2({Subtitle,SubtitleDuration})
if type(Subtitle)=="string"then
self.Subtitle=Subtitle
else
self.Subtitle=""
self:E({"Subtitle is invalid. Subtitle reset.",self.Subtitle})
end
if type(SubtitleDuration)=="number"then
if math.floor(math.abs(SubtitleDuration))==SubtitleDuration then
self.SubtitleDuration=SubtitleDuration
return self
end
end
self.SubtitleDuration=0
self:E({"SubtitleDuration is invalid. SubtitleDuration reset.",self.SubtitleDuration})
end
function RADIO:NewGenericTransmission(FileName,Frequency,Modulation,Power,Loop)
self:F({FileName,Frequency,Modulation,Power})
self:SetFileName(FileName)
if Frequency then self:SetFrequency(Frequency)end
if Modulation then self:SetModulation(Modulation)end
if Power then self:SetPower(Power)end
if Loop then self:SetLoop(Loop)end
return self
end
function RADIO:NewUnitTransmission(FileName,Subtitle,SubtitleDuration,Frequency,Modulation,Loop)
self:F({FileName,Subtitle,SubtitleDuration,Frequency,Modulation,Loop})
self:SetFileName(FileName)
if Subtitle then self:SetSubtitle(Subtitle)end
if SubtitleDuration then self:SetSubtitleDuration(SubtitleDuration)end
if Frequency then self:SetFrequency(Frequency)end
if Modulation then self:SetModulation(Modulation)end
if Loop then self:SetLoop(Loop)end
return self
end
function RADIO:Broadcast()
self:F()
if self.Positionable.ClassName=="UNIT"or self.Positionable.ClassName=="GROUP"then
self:T2("Broadcasting from a UNIT or a GROUP")
self.Positionable:SetCommand({
id="TransmitMessage",
params={
file=self.FileName,
duration=self.SubtitleDuration,
subtitle=self.Subtitle,
loop=self.Loop,
}
})
else
self:T2("Broadcasting from a POSITIONABLE")
trigger.action.radioTransmission(self.FileName,self.Positionable:GetPositionVec3(),self.Modulation,self.Loop,self.Frequency,self.Power,tostring(self.ID))
end
return self
end
function RADIO:StopBroadcast()
self:F()
if self.Positionable.ClassName=="UNIT"or self.Positionable.ClassName=="GROUP"then
self.Positionable:SetCommand({
id="StopTransmission",
params={}
})
else
trigger.action.stopRadioTransmission(tostring(self.ID))
end
return self
end
BEACON={
ClassName="BEACON",
}
function BEACON:New(Positionable)
local self=BASE:Inherit(self,BASE:New())
self:F(Positionable)
if Positionable:GetPointVec2()then
self.Positionable=Positionable
return self
end
self:E({"The passed positionable is invalid, no BEACON created",Positionable})
return nil
end
function BEACON:_TACANToFrequency(TACANChannel,TACANMode)
self:F3({TACANChannel,TACANMode})
if type(TACANChannel)~="number"then
if TACANMode~="X"and TACANMode~="Y"then
return nil
end
end
local A=1151
local B=64
if TACANChannel<64 then
B=1
end
if TACANMode=='Y'then
A=1025
if TACANChannel<64 then
A=1088
end
else
if TACANChannel<64 then
A=962
end
end
return(A+TACANChannel-B)*1000000
end
function BEACON:AATACAN(TACANChannel,Message,Bearing,BeaconDuration)
self:F({TACANChannel,Message,Bearing,BeaconDuration})
local IsValid=true
if not self.Positionable:IsAir()then
self:E({"The POSITIONABLE you want to attach the AA Tacan Beacon is not an aircraft ! The BEACON is not emitting",self.Positionable})
IsValid=false
end
local Frequency=self:_TACANToFrequency(TACANChannel,"Y")
if not Frequency then
self:E({"The passed TACAN channel is invalid, the BEACON is not emitting"})
IsValid=false
end
local System
if Bearing then
System=5
else
System=14
end
if IsValid then
self:T2({"AA TACAN BEACON started !"})
self.Positionable:SetCommand({
id="ActivateBeacon",
params={
type=4,
system=System,
callsign=Message,
frequency=Frequency,
}
})
if BeaconDuration then
SCHEDULER:New(nil,
function()
self:StopAATACAN()
end,{},BeaconDuration)
end
end
return self
end
function BEACON:StopAATACAN()
self:F()
if not self.Positionable then
self:E({"Start the beacon first before stoping it !"})
else
self.Positionable:SetCommand({
id='DeactivateBeacon',
params={
}
})
end
end
function BEACON:RadioBeacon(FileName,Frequency,Modulation,Power,BeaconDuration)
self:F({FileName,Frequency,Modulation,Power,BeaconDuration})
local IsValid=false
if type(FileName)=="string"then
if FileName:find(".ogg")or FileName:find(".wav")then
if not FileName:find("l10n/DEFAULT/")then
FileName="l10n/DEFAULT/"..FileName
end
IsValid=true
end
end
if not IsValid then
self:E({"File name invalid. Maybe something wrong with the extension ? ",FileName})
end
if type(Frequency)~="number"and IsValid then
self:E({"Frequency invalid. ",Frequency})
IsValid=false
end
Frequency=Frequency*1000000
if Modulation~=radio.modulation.AM and Modulation~=radio.modulation.FM and IsValid then
self:E({"Modulation is invalid. Use DCS's enum radio.modulation.",Modulation})
IsValid=false
end
if type(Power)~="number"and IsValid then
self:E({"Power is invalid. ",Power})
IsValid=false
end
Power=math.floor(math.abs(Power))
if IsValid then
self:T2({"Activating Beacon on ",Frequency,Modulation})
trigger.action.radioTransmission(FileName,self.Positionable:GetPositionVec3(),Modulation,true,Frequency,Power,tostring(self.ID))
if BeaconDuration then
SCHEDULER:New(nil,
function()
self:StopRadioBeacon()
end,{},BeaconDuration)
end
end
end
function BEACON:StopRadioBeacon()
self:F()
trigger.action.stopRadioTransmission(tostring(self.ID))
end