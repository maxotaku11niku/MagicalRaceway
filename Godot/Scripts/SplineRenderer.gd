class_name SplineRenderer
extends Node
## Controls the rendering of all the splines

@export var staticSpriteScene: PackedScene
@export var dynamicSpriteScene: PackedScene
@export var possibleDynamicSprites: Array[SpriteFrames]
@export var possibleDynamicSpriteSizes: PackedVector2Array
@export var road: Pseudo3DSpline
@export var sky: Sky2D
@export var bgLayer1Part1: Sprite2D
@export var bgLayer1Part2: Sprite2D
@export var bgLayer2Part1: Sprite2D
@export var bgLayer2Part2: Sprite2D
@export var screenSize: Vector2i
@export var frontSplinePoints: int
@export var backSplinePoints: int
@export var cameraRelativePosition: Vector2
@export var nearClipPosition: float
@export var farClipPosition: float
@export var bg1TravelFactor: float
@export var bg2TravelFactor: float

var turnStrList: Array[FloatWithDistance]
var pitchStrList: Array[FloatWithDistance]
var splitAmtList: Array[FloatWithDistance]
var colourList: Array[ColourListWithDistance]
var bgList: Array[BGSpriteDefWithDistance]
var spriteList: Array[StaticSpriteDefWithDistance]
var stripList: Array[TexturedStripWithDistance]

var paused: bool
var roadMat: ShaderMaterial
var posTex: ImageTexture
var posImg := Image.create(4, 256, false, Image.FORMAT_RF)
var posDat := PackedByteArray()
var palTex: ImageTexture
var palImg := Image.create(256, 1, false, Image.FORMAT_RGBA8)
var palDat := PackedByteArray()
var splinePoints: int
var zeroPoint: int
var crestPoint: int
var zeroScale: float
var pointDists := PackedFloat64Array()
var pointScales := PackedFloat64Array()
var pointYs := PackedFloat64Array()
var pointXs := PackedFloat64Array()
var pointSplits := PackedFloat64Array()
var pointScrLines := PackedFloat64Array()

var dist: float
var xpos: float
var pposvec: Vector2
var turnStrStartInd: int
var pitchStrStartInd: int
var splitAmtStartInd: int
var colourStartInd: int
var bgStartInd: int
var spriteStartInd: int
var stripStartInd: int
var curXcurve: float
var curYcurve: float
var curSplit: float
var curBGDef: BGSpriteDef
var bg1Offset: float
var bg2Offset: float
var staticSprmngPool: Array[StaticSprite]
var spriteSpawnerPool: Array[SpriteSpawner]
var firstStaticSprite: int
var numStaticSpritesRendered: int
var firstSpriteSpawner: int
var numActiveSpriteSpawners: int
var nextSpriteSpawner: int
var dynamicSprmngPool: Array[DynamicSprite]
var firstDynamicSprite: int
var numDynamicSpritesRendered: int
var curDynamicSpriteSeparation: float
var nextDynamicSpriteSpawnDistance: float
var stepsSinceLastDynamicSpriteSpawnedInLane := PackedInt64Array()
var stepsSinceLastDynamicSpriteSpawnedThisType := PackedInt64Array()
var stripPool: Array[TexturedStrip]
var stripSpawnerPool: Array[TexturedStripSpawner]
var firstStrip: int
var numStripsRendered: int
var firstStripSpawner: int
var numActiveStripSpawners: int
var nextStripSpawner: int 

class StaticSprite:
	var splRend: SplineRenderer
	var sprite: RoadSprite
	var position: Vector3
	var scale: float
	
	func PositionSprite(charpos: Vector2, searchPoint: int) -> int:
		if searchPoint < 0: return -1
		return splRend.SetTruePositionsOfSprite(self, charpos, searchPoint)

class DynamicSprite:
	var splRend: SplineRenderer
	var sprite: AnimatedRoadSprite
	var position: Vector3
	var velocity: Vector3
	var size: Vector2
	var scale: float
	var side: int
	var behindPlayer: bool
	var alreadyGrazed: bool
	
	func PositionSprite(charpos: Vector2, searchPoint: int) -> int:
		if searchPoint < 0: return -1
		return splRend.SetTruePositionsOfDynamicSprite(self, charpos, searchPoint)

class SpriteSpawner:
	var splRend: SplineRenderer
	var spriteInfo: StaticSpriteDefWithDistance
	var nextSpawnDistance: float
	var spritesSpawned: int
	
	func TrySpawnSprite(dist: float) -> bool:
		if dist >= nextSpawnDistance:
			var curSprMng := splRend.staticSprmngPool[(splRend.firstStaticSprite + splRend.numStaticSpritesRendered) % len(splRend.staticSprmngPool)]
			var curSprite := curSprMng.sprite
			var spwnSide := spriteInfo.spawnSide
			var sc := spriteInfo.baseScale
			var flip := spriteInfo.flip
			if spwnSide == StaticSpriteDefWithDistance.SPAWNSIDE_BOTH:
				spwnSide = StaticSpriteDefWithDistance.SPAWNSIDE_LEFT
				curSprMng.position = splRend.GetLogicalPositionOfSprite(nextSpawnDistance, spriteInfo.offset, spwnSide)
				curSprMng.scale = sc
				curSprMng.splRend = splRend
				curSprite.visSprite.texture = spriteInfo.spriteDef.texture
				curSprite.visSprite.region_rect = spriteInfo.spriteDef.region
				curSprite.visSprite.flip_h = flip
				curSprite.layer = -4080
				if spriteInfo.canCollide:
					(curSprite.colBox.shape as RectangleShape2D).size.x = spriteInfo.spriteDef.colBounds.x/sc
					(curSprite.colBox.shape as RectangleShape2D).size.y = spriteInfo.spriteDef.colBounds.z/sc
					curSprite.monitorable = true
				else:
					curSprite.monitorable = false
				curSprite.visible = true
				curSprite.process_mode = Node.PROCESS_MODE_INHERIT
				splRend.numStaticSpritesRendered += 1
				curSprMng = splRend.staticSprmngPool[(splRend.firstStaticSprite + splRend.numStaticSpritesRendered) % len(splRend.staticSprmngPool)]
				curSprite = curSprMng.sprite
				spwnSide = StaticSpriteDefWithDistance.SPAWNSIDE_RIGHT
				flip = not flip if spriteInfo.flipOnOtherSide else flip
			curSprMng.position = splRend.GetLogicalPositionOfSprite(nextSpawnDistance, spriteInfo.offset, spwnSide)
			curSprMng.scale = sc
			curSprMng.splRend = splRend
			curSprite.visSprite.texture = spriteInfo.spriteDef.texture
			curSprite.visSprite.region_rect = spriteInfo.spriteDef.region
			curSprite.visSprite.flip_h = flip
			curSprite.layer = -4080
			if spriteInfo.canCollide:
				(curSprite.colBox.shape as RectangleShape2D).size.x = spriteInfo.spriteDef.colBounds.x/sc
				(curSprite.colBox.shape as RectangleShape2D).size.y = spriteInfo.spriteDef.colBounds.z/sc
				curSprite.monitorable = true
			else:
				curSprite.monitorable = false
			curSprite.visible = true
			curSprite.process_mode = Node.PROCESS_MODE_INHERIT
			nextSpawnDistance += spriteInfo.separation
			spritesSpawned += 1
			splRend.numStaticSpritesRendered += 1
			return true
		return false
		
	func IsAllSpritesSpawned() -> bool:
		if spritesSpawned >= spriteInfo.numSprite: return true
		else: return false

class TexturedStrip:
	var splRend: SplineRenderer
	var strip: Pseudo3DSpline
	var startPos: Vector2
	var endPos: Vector2
	
	func PositionStrip(charpos: Vector2, searchPoint: int) -> int:
		if searchPoint < 0: return -1
		return splRend.SetTruePositionsOfStrip(self, charpos, searchPoint)

class TexturedStripSpawner:
	var splRend: SplineRenderer
	var stripInfo: TexturedStripWithDistance
	var nextSpawnDistance: float
	var stripsSpawned: int
	
	func TrySpawnStrip(dist: float) -> bool:
		if dist >= nextSpawnDistance:
			var curStrip := splRend.stripPool[(splRend.firstStrip + splRend.numStripsRendered) % len(splRend.stripPool)]
			curStrip.splRend = splRend
			curStrip.startPos = Vector2(stripInfo.xOffsetList[stripsSpawned].val, nextSpawnDistance)
			var stripSpl := curStrip.strip
			stripSpl.sideFlags = stripInfo.side
			stripSpl.isXClamped = stripInfo.xClamp
			stripSpl.texture = stripInfo.texture
			stripSpl.z_index = -512
			stripSpl.visible = true
			stripSpl.process_mode = Node.PROCESS_MODE_INHERIT
			stripSpl.SetPositioningTexture(splRend.posTex)
			stripSpl.SetXBounds(0.0, stripInfo.size.x/stripSpl.texture.get_width())
			stripSpl.SetPositioningParameters(splRend.pposvec, 64.0/stripSpl.texture.get_width(), 0.0)
			stripsSpawned += 1
			if IsAllStripsSpawned():
				curStrip.endPos = Vector2(curStrip.startPos.x, stripInfo.size.y + stripInfo.distance)
			else:
				nextSpawnDistance = stripInfo.xOffsetList[stripsSpawned].dist + stripInfo.distance
				curStrip.endPos = Vector2(stripInfo.xOffsetList[stripsSpawned].val, nextSpawnDistance)
			splRend.numStripsRendered += 1
			return true
		return false
	
	func IsAllStripsSpawned() -> bool:
		if stripsSpawned >= len(stripInfo.xOffsetList): return true
		else: return false

func SetSplinePositioningParameters() -> void:
	# Calculate spline parameters
	var xAngle: float
	var yAngle: float
	var xCurve: float
	var yCurve: float
	var xDev: float
	var yDev: float
	var xc0: float
	var xc1: float
	var yc0: float
	var yc1: float
	var sa0: float
	var sa1: float
	var tsInd := turnStrStartInd
	var psInd := pitchStrStartInd
	var saInd := splitAmtStartInd
	xAngle = 0.0
	yAngle = 0.0
	xDev = 0.0
	yDev = 0.0
	xc0 = 0.0
	xc1 = 0.0
	yc0 = 0.0
	yc1 = 0.0
	sa0 = 0.0
	sa1 = 0.0
	var dlerpx: float = 0.0
	var dlerpy: float = 0.0
	var dlerps: float = 0.0
	# Backwards trace to near clipping plane
	for i in range(zeroPoint, -1, -1):
		xCurve = lerpf(xc0, xc1, dlerpx)
		yCurve = lerpf(yc0, yc1, dlerpy)
		pointSplits[i] = lerpf(sa0, sa1, dlerps)
		pointXs[i] = 0.0
		pointYs[i] = 0.0
	tsInd = turnStrStartInd
	psInd = pitchStrStartInd
	saInd = splitAmtStartInd
	xAngle = 0.0
	yAngle = 0.0
	xDev = 0.0
	yDev = 0.0
	if tsInd >= len(turnStrList) - 1: tsInd = len(turnStrList) - 2
	if psInd >= len(pitchStrList) - 1: psInd = len(pitchStrList) - 2
	if saInd >= len(splitAmtList) - 1: saInd = len(splitAmtList) - 2
	xc0 = turnStrList[tsInd].val
	xc1 = turnStrList[tsInd + 1].val
	yc0 = pitchStrList[psInd].val
	yc1 = pitchStrList[psInd + 1].val
	sa0 = splitAmtList[saInd].val
	sa1 = splitAmtList[saInd + 1].val
	pointXs[zeroPoint] = 0.0
	pointYs[zeroPoint] = 0.0
	pointSplits[zeroPoint] = remap(dist, splitAmtList[saInd].dist, splitAmtList[saInd + 1].dist, sa0, sa1)
	# Forwards trace to far clipping plane
	for i in range(zeroPoint + 1, splinePoints):
		var realDist: float = dist + pointDists[i]
		if realDist >= turnStrList[tsInd + 1].dist:
			if tsInd < len(turnStrList) - 2:
				tsInd += 1
				xc0 = turnStrList[tsInd].val
				xc1 = turnStrList[tsInd + 1].val
		if realDist >= pitchStrList[psInd + 1].dist:
			if psInd < len(pitchStrList) - 2:
				psInd += 1
				yc0 = pitchStrList[psInd].val
				yc1 = pitchStrList[psInd + 1].val
		if realDist >= splitAmtList[saInd + 1].dist:
			if saInd < len(splitAmtList) - 2:
				saInd += 1
				sa0 = splitAmtList[saInd].val
				sa1 = splitAmtList[saInd + 1].val
		xCurve = clampf(remap(realDist, turnStrList[tsInd].dist, turnStrList[tsInd + 1].dist, xc0, xc1), minf(xc0, xc1), maxf(xc0, xc1))
		yCurve = clampf(remap(realDist, pitchStrList[psInd].dist, pitchStrList[psInd + 1].dist, yc0, yc1), minf(yc0, yc1), maxf(yc0, yc1))
		pointSplits[i] = clampf(remap(realDist, splitAmtList[saInd].dist, splitAmtList[saInd + 1].dist, sa0, sa1), minf(sa0, sa1), maxf(sa0, sa1))
		var dy: float = pointDists[i] - pointDists[i-1]
		if xAngle <= (-PI * 0.5): # Extreme angle -> escape value
			xDev = -100000.0
		elif xAngle >= (PI * 0.5):
			xDev = 100000.0
		elif xCurve != 0.0: # Normal
			var xc: float = cos(xAngle)
			var xdyp: float = dy/xc
			var xdxp: float = (sqrt(1.0 - xCurve * xCurve * xdyp * xdyp) - 1.0)/xCurve
			xDev += dy * tan(xAngle) + xdxp * xc
			xAngle += sqrt(-2.0 * xCurve * xdxp) * signf(xCurve)
		else: # Zero curvature -> do not modify angle
			xDev += dy * tan(xAngle)
		if yAngle <= (-PI * 0.5): # Extreme angle -> escape value
			yDev = 100000.0
		elif yAngle >= (PI * 0.5):
			yDev = -100000.0
		elif yCurve != 0.0: # Normal
			var yc: float = cos(yAngle)
			var ydyp: float = dy/yc
			var ydxp: float = (sqrt(1.0 - yCurve * yCurve * ydyp * ydyp) - 1.0)/yCurve
			yDev -= dy * tan(yAngle) + ydxp * yc
			yAngle += sqrt(-2.0 * yCurve * ydxp) * signf(yCurve)
		else: # Zero curvature -> do not modify angle
			yDev -= dy * tan(yAngle)
		pointXs[i] = xDev
		pointYs[i] = yDev
	# Raytrace and forward parameters to the splines
	var lineNum: int
	lineNum = screenSize.y - 1
	posDat.encode_float((lineNum * 4 + 0) * 4, 1/pointScales[zeroPoint])
	posDat.encode_float((lineNum * 4 + 1) * 4, pointDists[zeroPoint])
	posDat.encode_float((lineNum * 4 + 2) * 4, pointXs[zeroPoint])
	posDat.encode_float((lineNum * 4 + 3) * 4, pointSplits[zeroPoint])
	lineNum -= 1
	var rayVec := Vector2(-cameraRelativePosition.x, lerpf(cameraRelativePosition.y, -cameraRelativePosition.y, float(lineNum)/float(screenSize.y - 1)))
	var rayGrad = rayVec.y/rayVec.x
	var compY: float
	var lerpFac: float
	var crestCand: int = splinePoints
	crestPoint = splinePoints
	var pointsSinceSuccess: int = 0
	for i in range(zeroPoint, splinePoints - 1):
		compY = cameraRelativePosition.y + (pointDists[i+1] - cameraRelativePosition.x) * rayGrad
		pointsSinceSuccess += 1
		while compY < pointYs[i+1]:
			crestCand = i
			pointsSinceSuccess = 0
			var ppdist: float = pointDists[i+1] - pointDists[i]
			var ppgrad: float = (pointYs[i+1] - pointYs[i])/ppdist
			var initpointx: float = pointDists[i]
			lerpFac = (((rayVec.y + cameraRelativePosition.y + initpointx * ppgrad - pointYs[i])/(ppgrad - rayGrad)) - initpointx)/ppdist
			posDat.encode_float((lineNum * 4 + 0) * 4, 1/(lerpf(pointScales[i], pointScales[i+1], lerpFac)))
			posDat.encode_float((lineNum * 4 + 1) * 4, lerpf(pointDists[i], pointDists[i+1], lerpFac))
			posDat.encode_float((lineNum * 4 + 2) * 4, lerpf(pointXs[i], pointXs[i+1], lerpFac)/screenSize.x)
			posDat.encode_float((lineNum * 4 + 3) * 4, lerpf(pointSplits[i], pointSplits[i+1], lerpFac))
			lineNum -= 1
			if lineNum < 0: break
			rayVec = Vector2(-cameraRelativePosition.x, lerpf(cameraRelativePosition.y, -cameraRelativePosition.y, float(lineNum)/float(screenSize.y - 1)))
			rayGrad = rayVec.y/rayVec.x
			compY = cameraRelativePosition.y + (pointDists[i+1] - cameraRelativePosition.x) * rayGrad
		if lineNum < 0: break
		if crestCand > 0 and pointsSinceSuccess >= 8:
			crestPoint = crestCand
			crestCand = -1
	for i in range(0, splinePoints):
		var linepy := pointYs[i]
		var linesc := pointScales[i]
		linepy -= cameraRelativePosition.y
		linepy = -linepy * linesc
		pointScrLines[i] = linepy + screenSize.y * 0.5
	var skyBottom: float = float(screenSize.y - 1) * (0.5 + (cameraRelativePosition.x/(2.0 * cameraRelativePosition.y)) * ((pointYs[splinePoints-1] - cameraRelativePosition.y)/(pointDists[splinePoints-1] - cameraRelativePosition.x)))
	skyBottom = maxf(skyBottom, lineNum + 1) #This prevents an ugly seam from forming
	sky.bottomY = skyBottom
	bgLayer1Part1.position.y = skyBottom - curBGDef.bg1ZeroY
	bgLayer1Part2.position.y = skyBottom - curBGDef.bg1ZeroY
	bgLayer2Part1.position.y = skyBottom - curBGDef.bg2ZeroY
	bgLayer2Part2.position.y = skyBottom - curBGDef.bg2ZeroY
	road.bound.position.y = lineNum + 1
	road.bound.size.y = screenSize.y - (lineNum + 1)
	posImg.set_data(4, 256, false, Image.FORMAT_RF, posDat)
	posTex = ImageTexture.create_from_image(posImg)
	road.SetPositioningTexture(posTex)
	pposvec = Vector2(xpos, fmod(dist, road.texture.get_height()))
	road.SetPositioningParameters(pposvec, 0.0, 0.0)

func TryChangeBGSprites() -> void:
	var newBGDef := bgList[bgStartInd].def
	if newBGDef != curBGDef:
		curBGDef = newBGDef
		bgLayer1Part1.texture = newBGDef.bgTexture
		bgLayer1Part1.region_rect = newBGDef.bg1Region
		bgLayer1Part2.texture = newBGDef.bgTexture
		bgLayer1Part2.region_rect = newBGDef.bg1Region
		bgLayer2Part1.texture = newBGDef.bgTexture
		bgLayer2Part1.region_rect = newBGDef.bg2Region
		bgLayer2Part2.texture = newBGDef.bgTexture
		bgLayer2Part2.region_rect = newBGDef.bg2Region

func TryMakeNewSpriteSpawner() -> void:
	var curSprDef := spriteList[spriteStartInd]
	var lastSprDist := curSprDef.dist + (curSprDef.numSprite - 1) * curSprDef.separation
	if curSprDef.numSprite > 0 and curSprDef.spawnSide != 0 and (dist + nearClipPosition - 100.0) < lastSprDist:
		var newSpawner := spriteSpawnerPool[(firstSpriteSpawner + numActiveSpriteSpawners) % len(spriteSpawnerPool)]
		newSpawner.spriteInfo = curSprDef
		newSpawner.nextSpawnDistance = curSprDef.dist
		newSpawner.spritesSpawned = 0
		newSpawner.splRend = self
		numActiveSpriteSpawners += 1

func TrySpawnDynamicSprite(dist: float) -> bool:
	if dist >= nextDynamicSpriteSpawnDistance:
		var curSprMng := dynamicSprmngPool[(firstDynamicSprite + numDynamicSpritesRendered) % len(dynamicSprmngPool)]
		var curSprite := curSprMng.sprite
		for i in range(len(stepsSinceLastDynamicSpriteSpawnedInLane)):
			stepsSinceLastDynamicSpriteSpawnedInLane[i] += 1
		for i in range(len(stepsSinceLastDynamicSpriteSpawnedThisType)):
			stepsSinceLastDynamicSpriteSpawnedThisType[i] += 1
		var lane: int = -1
		while lane < 0:
			var tempLane: int = randi_range(0, 5)
			if (stepsSinceLastDynamicSpriteSpawnedInLane[tempLane] >= 3):
				lane = tempLane
				stepsSinceLastDynamicSpriteSpawnedInLane[tempLane] = 0
		var sprType: int = -1
		while sprType < 0:
			var tempSprType: int = randi_range(0, len(possibleDynamicSprites)-1)
			if (stepsSinceLastDynamicSpriteSpawnedThisType[tempSprType] > 2):
				sprType = tempSprType
				stepsSinceLastDynamicSpriteSpawnedThisType[tempSprType] = 0
		var spwnSide: int = StaticSpriteDefWithDistance.SPAWNSIDE_LEFT if lane < 3 else StaticSpriteDefWithDistance.SPAWNSIDE_RIGHT
		var sc := 4.0
		curSprMng.position = GetLogicalPositionOfSprite(nextDynamicSpriteSpawnDistance, Vector2(-32.0 + 32.0 * (lane % 3), 8.0), 0)
		curSprMng.velocity = Vector3(0.0, 0.0, 600.0)
		curSprMng.scale = sc
		curSprMng.splRend = self
		curSprMng.size = possibleDynamicSpriteSizes[sprType]
		curSprMng.side = spwnSide
		curSprMng.behindPlayer = false
		curSprMng.alreadyGrazed = false
		curSprite.visSprite.sprite_frames = possibleDynamicSprites[sprType]
		curSprite.visSprite.play(&"front")
		curSprite.animationType = 0
		curSprite.animationDir = 0.0
		curSprite.animationSpeed = 0.0
		curSprite.layer = -4080
		(curSprite.colBox.shape as RectangleShape2D).size.x = 32.0/sc
		(curSprite.colBox.shape as RectangleShape2D).size.y = 32.0/sc
		curSprite.monitorable = true
		curSprite.visible = true
		curSprite.process_mode = Node.PROCESS_MODE_INHERIT
		nextDynamicSpriteSpawnDistance += curDynamicSpriteSeparation
		numDynamicSpritesRendered += 1
		return true
	return false

func TryMakeNewStripSpawner() -> void:
	var curStripDef := stripList[stripStartInd]
	var lastStripDist := float(curStripDef.distance + curStripDef.size.y)
	if len(curStripDef.xOffsetList) > 0 and curStripDef.side != 0 and (dist + nearClipPosition - 100.0) < lastStripDist:
		var newSpawner := stripSpawnerPool[(firstStripSpawner + numActiveStripSpawners) % len(stripSpawnerPool)]
		newSpawner.stripInfo = curStripDef
		newSpawner.nextSpawnDistance = curStripDef.distance
		newSpawner.stripsSpawned = 0
		newSpawner.splRend = self
		numActiveStripSpawners += 1

func Reset() -> void:
	turnStrStartInd = 0
	pitchStrStartInd = 0
	splitAmtStartInd = 0
	colourStartInd = 0
	bgStartInd = 0
	spriteStartInd = 0
	stripStartInd = 0
	firstStaticSprite = 0
	firstSpriteSpawner = 0
	numStaticSpritesRendered = 0
	numActiveSpriteSpawners = 0
	nextSpriteSpawner = -1
	firstDynamicSprite = 0
	numDynamicSpritesRendered = 0
	nextDynamicSpriteSpawnDistance = 2000.0
	firstStrip = 0
	firstStripSpawner = 0
	numStripsRendered = 0
	numActiveStripSpawners = 0
	nextStripSpawner = -1
	for i in range(len(staticSprmngPool)):
		var curspr := staticSprmngPool[i].sprite
		curspr.logicalPosition = Vector3(-6969.0, 420.0, 393939.0)
		curspr.screenPosition = Vector2(-6969.0, 393939.0)
		curspr.scale = Vector2(1.0, 1.0)
		curspr.visible = false
		curspr.monitoring = false
		curspr.monitorable = false
		curspr.process_mode = Node.PROCESS_MODE_DISABLED
	for i in range(len(dynamicSprmngPool)):
		var curspr := dynamicSprmngPool[i].sprite
		curspr.logicalPosition = Vector3(-6969.0, 420.0, 393939.0)
		curspr.screenPosition = Vector2(-6969.0, 393939.0)
		curspr.scale = Vector2(1.0, 1.0)
		curspr.visible = false
		curspr.monitoring = false
		curspr.monitorable = false
		curspr.process_mode = Node.PROCESS_MODE_DISABLED
	for i in range(len(stripPool)):
		var curstrip := stripPool[i].strip
		curstrip.isMainRoad = false
		curstrip.bound = Rect2(-6969.0, -3939.0, 0.0, 0.0)
		curstrip.positTexHeight = 256.0
		curstrip.sideFlags = 0
		curstrip.visible = false
		curstrip.z_index = -4080
	for i in range(len(stepsSinceLastDynamicSpriteSpawnedInLane)):
		stepsSinceLastDynamicSpriteSpawnedInLane[i] = 100
	for i in range(len(stepsSinceLastDynamicSpriteSpawnedThisType)):
		stepsSinceLastDynamicSpriteSpawnedThisType[i] = 100
	TryChangeBGSprites()

func GetEdgeGrazeMultiplier(cForce: float) -> float:
	if xpos <= -32.0 - curSplit:
		return 1.0 + (exp((-xpos - 56.0 - curSplit) * 0.125) * absf(cForce) * 0.05)
	elif xpos >= 32.0 + curSplit:
		return 1.0 + (exp((xpos - 56.0 - curSplit) * 0.125) * absf(cForce) * 0.05)
	elif curSplit >= 56.0:
		if xpos <= -32.0 + curSplit and xpos > 0.0:
			return 1.0 + (exp((-xpos - 56.0 + curSplit) * 0.125) * absf(cForce) * 0.05)
		elif xpos >= 32.0 - curSplit and xpos < 0.0:
			return 1.0 + (exp((xpos - 56.0 + curSplit) * 0.125) * absf(cForce) * 0.05)
		else: return 1.0
	else: return 1.0

func IsPlayerOnRoad() -> bool:
	if xpos >= -56.0 - curSplit and xpos <= 56.0 + curSplit:
		if xpos <= 56.0 - curSplit or xpos >= -56.0 + curSplit:
			return true
		else: return false
	else: return false
	
func GetLogicalPositionOfSprite(dist: float, offset: Vector2, side: int) -> Vector3:
	var truexpos: float = 0.0
	var splitComp := splitAmtList[len(splitAmtList)-1].val + 64.0
	for i in range(splitAmtStartInd, len(splitAmtList)-1):
		if dist >= splitAmtList[i].dist and dist < splitAmtList[i+1].dist:
			splitComp = lerpf(splitAmtList[i].val, splitAmtList[i+1].val, (dist-splitAmtList[i].dist)/(splitAmtList[i+1].dist-splitAmtList[i].dist)) + 64.0
	if side == StaticSpriteDefWithDistance.SPAWNSIDE_RIGHT:
		truexpos = offset.x + splitComp
	elif side == StaticSpriteDefWithDistance.SPAWNSIDE_LEFT:
		truexpos = -offset.x - splitComp
	else:
		truexpos = offset.x
	return Vector3(truexpos, offset.y, dist)

func SetTruePositionsOfSprite(spr: StaticSprite, charpos: Vector2, searchPoint: int) -> int:
	var rSprite := spr.sprite
	var logPos := spr.position - Vector3(0.0, 0.0, charpos.y)
	rSprite.logicalPosition = logPos
	logPos.x -= charpos.x
	var sDist := logPos.z
	if searchPoint >= splinePoints: return searchPoint
	if sDist < farClipPosition:
		if sDist >= nearClipPosition:
			while sDist >= pointDists[searchPoint]:
				searchPoint += 1
			rSprite.layer = zeroPoint - searchPoint
			if searchPoint >= crestPoint:
				rSprite.layer -= 600
			var lerpfac := (sDist - pointDists[searchPoint - 1])/(pointDists[searchPoint] - pointDists[searchPoint - 1])
			var px := lerpf(pointXs[searchPoint - 1], pointXs[searchPoint], lerpfac)
			var py := lerpf(pointYs[searchPoint - 1], pointYs[searchPoint], lerpfac)
			var sc := lerpf(pointScales[searchPoint - 1], pointScales[searchPoint], lerpfac)
			var cScale := 1 / spr.scale
			rSprite.visSprite.scale = Vector2(sc, sc) * cScale
			px += logPos.x
			py += logPos.y - cameraRelativePosition.y + rSprite.visSprite.region_rect.size.y * 0.5 * cScale
			var ps := Vector2(px, -py)
			ps *= sc
			rSprite.screenPosition = ps + screenSize * 0.5
			return searchPoint
		elif sDist >= nearClipPosition - 100.0:
			rSprite.layer = -4080
			return 0
		else: return -1
	else: return splinePoints

func SetTruePositionsOfDynamicSprite(spr: DynamicSprite, charpos: Vector2, searchPoint: int) -> int:
	var rSprite := spr.sprite
	var logPos := spr.position - Vector3(0.0, 0.0, charpos.y)
	var splitComp := splitAmtList[len(splitAmtList)-1].val
	for i in range(splitAmtStartInd, len(splitAmtList)-1):
		if spr.position.z >= splitAmtList[i].dist and spr.position.z < splitAmtList[i+1].dist:
			splitComp = lerpf(splitAmtList[i].val, splitAmtList[i+1].val, (spr.position.z-splitAmtList[i].dist)/(splitAmtList[i+1].dist-splitAmtList[i].dist))
	if spr.side == StaticSpriteDefWithDistance.SPAWNSIDE_RIGHT:
		logPos.x += splitComp
	elif spr.side == StaticSpriteDefWithDistance.SPAWNSIDE_LEFT:
		logPos.x -= splitComp
	rSprite.logicalPosition = logPos
	logPos.x -= charpos.x
	var sDist := logPos.z
	if searchPoint >= splinePoints: return searchPoint
	if sDist >= farClipPosition + 200.0: return -1
	if sDist < farClipPosition:
		if sDist >= nearClipPosition:
			while sDist >= pointDists[searchPoint]:
				searchPoint += 1
			rSprite.layer = zeroPoint - searchPoint
			if searchPoint >= crestPoint:
				rSprite.layer -= 600
			var lerpfac := (sDist - pointDists[searchPoint - 1])/(pointDists[searchPoint] - pointDists[searchPoint - 1])
			var px := lerpf(pointXs[searchPoint - 1], pointXs[searchPoint], lerpfac)
			var py := lerpf(pointYs[searchPoint - 1], pointYs[searchPoint], lerpfac)
			var sc := lerpf(pointScales[searchPoint - 1], pointScales[searchPoint], lerpfac)
			var cScale := 1 / spr.scale
			rSprite.visSprite.scale = Vector2(sc, sc) * cScale
			px += logPos.x
			py += logPos.y - cameraRelativePosition.y + spr.size.y * 0.5 * cScale
			var ps := Vector2(px, -py)
			ps *= sc
			rSprite.screenPosition = ps + screenSize * 0.5
			return searchPoint
		elif sDist >= nearClipPosition - 100.0:
			rSprite.layer = -4080
			return 0
		else: return -1
	else: return splinePoints

func SetTruePositionsOfStrip(strip: TexturedStrip, charpos: Vector2, searchPoint: int) -> int:
	var rStrip := strip.strip
	var sDist := strip.startPos.y - charpos.y
	var eDist := strip.endPos.y - charpos.y
	var bx := strip.startPos.x
	var tx := strip.endPos.x
	var grad := (tx - bx)/(eDist - sDist)
	bx -= grad * sDist
	var tSearchPoint := searchPoint
	if sDist < farClipPosition:
		if eDist < nearClipPosition - 100.0:
			return -1
		elif eDist < nearClipPosition:
			rStrip.bound = Rect2(-6969.0, -3939.0, 0.0, 0.0)
		elif sDist >= nearClipPosition:
			var highestY = pointScrLines[tSearchPoint]
			var highestPoint = tSearchPoint
			while sDist >= pointDists[tSearchPoint]:
				tSearchPoint += 1
				if (pointScrLines[tSearchPoint] < highestY):
					highestY = pointScrLines[tSearchPoint]
					highestPoint = tSearchPoint
			if (highestPoint == tSearchPoint):
				rStrip.bound = road.bound
				var lerpfac := (sDist - pointDists[tSearchPoint - 1])/(pointDists[tSearchPoint] - pointDists[tSearchPoint - 1])
				var py := lerpf(pointScrLines[tSearchPoint - 1], pointScrLines[tSearchPoint], lerpfac)
				rStrip.bound.size.y = py - road.bound.position.y
			else:
				rStrip.bound = Rect2(-6969.0, -3939.0, 0.0, 0.0)
		else:
			rStrip.bound = road.bound
		if eDist < farClipPosition:
			var highestY = pointScrLines[searchPoint]
			var highestPoint = searchPoint
			while eDist >= pointDists[searchPoint]:
				searchPoint += 1
				if (pointScrLines[searchPoint] < highestY):
					highestY = pointScrLines[searchPoint]
					highestPoint = searchPoint
			if (highestPoint == searchPoint):
				var lerpfac := (eDist - pointDists[searchPoint - 1])/(pointDists[searchPoint] - pointDists[searchPoint - 1])
				var py := lerpf(pointScrLines[searchPoint - 1], pointScrLines[searchPoint], lerpfac)
				rStrip.bound.position.y = py
				rStrip.bound.size.y += road.bound.position.y - py
		rStrip.SetPositioningParameters(Vector2(xpos, dist - strip.startPos.y), 64.0 + bx, grad)
		rStrip.SetPositioningTexture(posTex)
		return 0
	else: return 0

#Returns 0 if no sprite passed this frame, returns positive if grazeable, returns negative if not grazeable
func GetDynamicSpritePassDistance(curDist: float, curXPos: float) -> float:
	var passDist: float = 0.0
	for i in range(firstDynamicSprite, firstDynamicSprite + numDynamicSpritesRendered):
		var realInd := i % len(dynamicSprmngPool)
		var curspr := dynamicSprmngPool[realInd]
		if curspr.position.z <= curDist and not curspr.behindPlayer:
			curspr.behindPlayer = true
			passDist = absf(curspr.sprite.logicalPosition.x - curXPos)
			if curspr.alreadyGrazed: passDist = -passDist
			elif passDist <= 24.0: curspr.alreadyGrazed = true
			break
		elif curspr.position.z > curDist and curspr.behindPlayer:
			curspr.behindPlayer = false
			passDist = absf(curspr.sprite.logicalPosition.x - curXPos)
			if curspr.alreadyGrazed: passDist = -passDist
			elif passDist <= 24.0: curspr.alreadyGrazed = true
			break
	return passDist

func SetBGOffsets(accumOffset: float) -> void:
	bg1Offset = bg1TravelFactor * accumOffset
	bg2Offset = bg2TravelFactor * accumOffset

func _ready() -> void:
	splinePoints = frontSplinePoints + backSplinePoints
	pointDists.resize(splinePoints)
	pointScales.resize(splinePoints)
	pointYs.resize(splinePoints)
	pointXs.resize(splinePoints)
	pointSplits.resize(splinePoints)
	pointScrLines.resize(splinePoints)
	staticSprmngPool.resize(1024)
	for i in range(len(staticSprmngPool)):
		staticSprmngPool[i] = StaticSprite.new()
		var curspr := staticSpriteScene.instantiate()
		add_child(curspr)
		curspr.colBox.shape = RectangleShape2D.new()
		curspr.logicalPosition = Vector3(-6969.0, 420.0, 393939.0)
		curspr.screenPosition = Vector2(-6969.0, 393939.0)
		curspr.scale = Vector2(1.0, 1.0)
		curspr.visible = false
		curspr.monitoring = false
		curspr.monitorable = false
		curspr.process_mode = Node.PROCESS_MODE_DISABLED
		staticSprmngPool[i].sprite = curspr
	spriteSpawnerPool.resize(64)
	for i in range(len(spriteSpawnerPool)):
		spriteSpawnerPool[i] = SpriteSpawner.new()
	dynamicSprmngPool.resize(128)
	for i in range(len(dynamicSprmngPool)):
		dynamicSprmngPool[i] = DynamicSprite.new()
		var curspr := dynamicSpriteScene.instantiate()
		add_child(curspr)
		curspr.colBox.shape = RectangleShape2D.new()
		curspr.logicalPosition = Vector3(-6969.0, 420.0, 393939.0)
		curspr.screenPosition = Vector2(-6969.0, 393939.0)
		curspr.scale = Vector2(1.0, 1.0)
		curspr.visible = false
		curspr.monitoring = false
		curspr.monitorable = false
		curspr.process_mode = Node.PROCESS_MODE_DISABLED
		dynamicSprmngPool[i].sprite = curspr
	stepsSinceLastDynamicSpriteSpawnedInLane.resize(6)
	for i in range(len(stepsSinceLastDynamicSpriteSpawnedInLane)):
		stepsSinceLastDynamicSpriteSpawnedInLane[i] = 100
	stepsSinceLastDynamicSpriteSpawnedThisType.resize(len(possibleDynamicSprites))
	for i in range(len(stepsSinceLastDynamicSpriteSpawnedThisType)):
		stepsSinceLastDynamicSpriteSpawnedThisType[i] = 100
	stripPool.resize(64)
	for i in range(len(stripPool)):
		stripPool[i] = TexturedStrip.new()
		var curstrip := Pseudo3DSpline.new()
		curstrip.material = ShaderMaterial.new()
		curstrip.material.set_shader(load("res://Shaders/spline.gdshader"))
		add_child(curstrip)
		curstrip.isMainRoad = false
		curstrip.bound = Rect2(-6969.0, -3939.0, 0.0, 0.0)
		curstrip.positTexHeight = 256.0
		curstrip.sideFlags = 0
		curstrip.visible = false
		curstrip.z_index = -4080
		stripPool[i].strip = curstrip
	stripSpawnerPool.resize(16)
	for i in range(len(stripSpawnerPool)):
		stripSpawnerPool[i] = TexturedStripSpawner.new()
	var nearScale: float
	var farScale: float
	zeroScale = (0.5 * screenSize.y) / cameraRelativePosition.y
	nearScale = (cameraRelativePosition.x * zeroScale) / (cameraRelativePosition.x - nearClipPosition)
	farScale = (cameraRelativePosition.x * zeroScale) / (cameraRelativePosition.x - farClipPosition)
	zeroPoint = backSplinePoints
	crestPoint = splinePoints
	pointScales[zeroPoint] = zeroScale
	pointDists[zeroPoint] = 0
	for i in range(0, zeroPoint):
		pointDists[i] = lerpf(nearClipPosition, 0.0, float(i)/float(zeroPoint))
		pointScales[i] = (cameraRelativePosition.x * zeroScale) / (cameraRelativePosition.x - pointDists[i])
	for i in range(zeroPoint + 1, splinePoints):
		pointDists[i] = lerpf(0.0, farClipPosition, float(i - zeroPoint)/float(splinePoints - zeroPoint - 1))
		pointScales[i] = (cameraRelativePosition.x * zeroScale) / (cameraRelativePosition.x - pointDists[i])
	posDat.resize(4 * 256 * 4)
	posDat.fill(0)
	dist = 0.0
	xpos = 0.0
	for i in range(128, 240):
		var rscale := 1.0/(0.1 + 3.9 * ((i - 128.0)/111.0));
		posDat.encode_float((i * 4 + 0) * 4, rscale)
		posDat.encode_float((i * 4 + 1) * 4, (239.0 - i) * rscale)
		posDat.encode_float((i * 4 + 2) * 4, 0.0)
		posDat.encode_float((i * 4 + 3) * 4, 0.0)
	posImg.set_data(4, 256, false, Image.FORMAT_RF, posDat)
	posTex = ImageTexture.create_from_image(posImg)
	roadMat = road.material
	road.SetPositioningTexture(posTex)
	road.positTexHeight = 256
	road.isMainRoad = true
	palDat.resize(4 * 256)
	palDat.fill(0)
	palImg.set_data(256, 1, false, Image.FORMAT_RGBA8, palDat)
	palTex = ImageTexture.create_from_image(palImg)
	road.palTex = palTex
	sky.palTex = palTex

func _process(delta: float) -> void:
	if turnStrStartInd < (len(turnStrList) - 2):
		while dist >= turnStrList[turnStrStartInd + 1].dist:
			turnStrStartInd += 1
			if turnStrStartInd >= (len(turnStrList) - 2):
				break
	if pitchStrStartInd < (len(pitchStrList) - 2):
		while dist >= pitchStrList[pitchStrStartInd + 1].dist:
			pitchStrStartInd += 1
			if pitchStrStartInd >= (len(pitchStrList) - 2):
				break
	if splitAmtStartInd < (len(splitAmtList) - 2):
		while dist >= splitAmtList[splitAmtStartInd + 1].dist:
			splitAmtStartInd += 1
			if splitAmtStartInd >= (len(splitAmtList) - 2):
				break
	if colourStartInd < (len(colourList) - 2):
		while dist >= colourList[colourStartInd + 1].dist:
			colourStartInd += 1
			if colourStartInd >= (len(colourList) - 2):
				break
	if bgStartInd < (len(bgList) - 2):
		while dist >= bgList[bgStartInd + 1].dist:
			bgStartInd += 1
			TryChangeBGSprites()
			if bgStartInd >= (len(bgList) - 2):
				break
	if spriteStartInd <= (len(spriteList) - 1):
		while (dist + farClipPosition + 200.0) >= spriteList[spriteStartInd].dist:
			TryMakeNewSpriteSpawner()
			spriteStartInd += 1
			if spriteStartInd >= (len(spriteList) - 1):
				break
	if stripStartInd <= (len(stripList) - 1):
		while (dist + farClipPosition + 200.0) >= stripList[stripStartInd].distance:
			TryMakeNewStripSpawner()
			stripStartInd += 1
			if stripStartInd >= (len(stripList) - 1):
				break
	var dlerpx: float = (dist - turnStrList[turnStrStartInd].dist) / (turnStrList[turnStrStartInd + 1].dist - turnStrList[turnStrStartInd].dist)
	var dlerpy: float = (dist - pitchStrList[pitchStrStartInd].dist) / (pitchStrList[pitchStrStartInd + 1].dist - pitchStrList[pitchStrStartInd].dist)
	var dlerps: float = (dist - splitAmtList[splitAmtStartInd].dist) / (splitAmtList[splitAmtStartInd + 1].dist - splitAmtList[splitAmtStartInd].dist)
	if dlerpx >= 1.0: dlerpx = 1.0
	if dlerpy >= 1.0: dlerpy = 1.0
	if dlerps >= 1.0: dlerps = 1.0
	curXcurve = lerpf(turnStrList[turnStrStartInd].val, turnStrList[turnStrStartInd + 1].val, dlerpx)
	curYcurve = lerpf(pitchStrList[pitchStrStartInd].val, pitchStrList[pitchStrStartInd + 1].val, dlerpy)
	curSplit = lerpf(splitAmtList[splitAmtStartInd].val, splitAmtList[splitAmtStartInd + 1].val, dlerps)
	SetSplinePositioningParameters()
	
	var curClosestSpriteDist := 9999999999999.0
	if nextSpriteSpawner < 0:
		nextSpriteSpawner = -1
		for i in range(firstSpriteSpawner, firstSpriteSpawner + numActiveSpriteSpawners):
			var realInd := i % len(spriteSpawnerPool)
			var curspwn := spriteSpawnerPool[realInd]
			if curspwn.IsAllSpritesSpawned():
				if i == firstSpriteSpawner:
					numActiveSpriteSpawners -= 1
					firstSpriteSpawner += 1
					firstSpriteSpawner %= len(spriteSpawnerPool)
			elif curspwn.nextSpawnDistance < curClosestSpriteDist:
				nextSpriteSpawner = realInd
				curClosestSpriteDist = curspwn.nextSpawnDistance
	if nextSpriteSpawner >= 0:
		while spriteSpawnerPool[nextSpriteSpawner].TrySpawnSprite(dist + farClipPosition + 100.0):
			nextSpriteSpawner = -1
			curClosestSpriteDist = 9999999999999.0
			for i in range(firstSpriteSpawner, firstSpriteSpawner + numActiveSpriteSpawners):
				var realInd := i % len(spriteSpawnerPool)
				var curspwn := spriteSpawnerPool[realInd]
				if curspwn.IsAllSpritesSpawned():
					if i == firstSpriteSpawner:
						numActiveSpriteSpawners -= 1
						firstSpriteSpawner += 1
						firstSpriteSpawner %= len(spriteSpawnerPool)
				elif curspwn.nextSpawnDistance <= curClosestSpriteDist:
					nextSpriteSpawner = realInd
					curClosestSpriteDist = curspwn.nextSpawnDistance
			if nextSpriteSpawner < 0: break
	var startSearchPoint: int = 0
	for i in range(firstStaticSprite, firstStaticSprite + numStaticSpritesRendered):
		var realInd := i % len(staticSprmngPool)
		var curspr := staticSprmngPool[realInd]
		startSearchPoint = curspr.PositionSprite(Vector2(xpos, dist), startSearchPoint)
		if startSearchPoint < 0:
			curspr.sprite.visible = false
			curspr.sprite.monitoring = false
			curspr.sprite.monitorable = false
			curspr.sprite.process_mode = Node.PROCESS_MODE_DISABLED
			if i == firstStaticSprite:
				numStaticSpritesRendered -= 1
				firstStaticSprite += 1
				firstStaticSprite %= len(staticSprmngPool)
			startSearchPoint = 0
	
	TrySpawnDynamicSprite(dist + farClipPosition + 100.0)
	startSearchPoint = 0
	for i in range(firstDynamicSprite, firstDynamicSprite + numDynamicSpritesRendered):
		var realInd := i % len(dynamicSprmngPool)
		var curspr := dynamicSprmngPool[realInd]
		startSearchPoint = curspr.PositionSprite(Vector2(xpos, dist), startSearchPoint)
		if startSearchPoint < 0:
			curspr.sprite.visible = false
			curspr.sprite.monitoring = false
			curspr.sprite.monitorable = false
			curspr.sprite.process_mode = Node.PROCESS_MODE_DISABLED
			if i == firstDynamicSprite:
				numDynamicSpritesRendered -= 1
				firstDynamicSprite += 1
				firstDynamicSprite %= len(dynamicSprmngPool)
			startSearchPoint = 0
		elif not paused: curspr.position += curspr.velocity * delta
	
	var curClosestStripDist := 9999999999999.0
	if nextStripSpawner < 0:
		nextStripSpawner = -1
		for i in range(firstStripSpawner, firstStripSpawner + numActiveStripSpawners):
			var realInd := i % len(stripSpawnerPool)
			var curspwn := stripSpawnerPool[realInd]
			if curspwn.IsAllStripsSpawned():
				if i == firstStripSpawner:
					numActiveStripSpawners -= 1
					firstStripSpawner += 1
					firstStripSpawner %= len(stripSpawnerPool)
			elif curspwn.nextSpawnDistance < curClosestStripDist:
				nextStripSpawner = realInd
				curClosestStripDist = curspwn.nextSpawnDistance
	if nextStripSpawner >= 0:
		while stripSpawnerPool[nextStripSpawner].TrySpawnStrip(dist + farClipPosition + 100.0):
			nextStripSpawner = -1
			curClosestStripDist = 9999999999999.0
			for i in range(firstStripSpawner, firstStripSpawner + numActiveStripSpawners):
				var realInd := i % len(stripSpawnerPool)
				var curspwn := stripSpawnerPool[realInd]
				if curspwn.IsAllStripsSpawned():
					if i == firstStripSpawner:
						numActiveStripSpawners -= 1
						firstStripSpawner += 1
						firstStripSpawner %= len(stripSpawnerPool)
				elif curspwn.nextSpawnDistance <= curClosestStripDist:
					nextStripSpawner = realInd
					curClosestStripDist = curspwn.nextSpawnDistance
			if nextStripSpawner < 0: break
	startSearchPoint = 0
	for i in range(firstStrip, firstStrip + numStripsRendered):
		var realInd := i % len(stripPool)
		var curstrip := stripPool[realInd]
		startSearchPoint = curstrip.PositionStrip(Vector2(xpos, dist), startSearchPoint)
		if startSearchPoint < 0:
			curstrip.strip.visible = false
			curstrip.strip.process_mode = Node.PROCESS_MODE_DISABLED
			if i == firstStrip:
				numStripsRendered -= 1
				firstStrip += 1
				firstStrip %= len(stripPool)
			startSearchPoint = 0
	
	bgLayer1Part1.position.x = fposmod(bg1Offset, curBGDef.bg1Region.size.x)
	bgLayer2Part1.position.x = fposmod(bg2Offset, curBGDef.bg2Region.size.x)
	bgLayer1Part2.position.x = bgLayer1Part1.position.x - curBGDef.bg1Region.size.x
	bgLayer2Part2.position.x = bgLayer2Part1.position.x - curBGDef.bg2Region.size.x
	var curBGColour := bgList[bgStartInd].spriteColour
	var nextBGColour := bgList[bgStartInd + 1].spriteColour
	var dlerpb: float = (dist - bgList[bgStartInd].dist) / (bgList[bgStartInd + 1].dist - bgList[bgStartInd].dist)
	if dlerpb >= 1.0: dlerpb = 1.0
	var bgcol: Color = curBGColour.lerp(nextBGColour, dlerpb)
	(bgLayer1Part1.material as ShaderMaterial).set_shader_parameter("col", bgcol)
	(bgLayer1Part2.material as ShaderMaterial).set_shader_parameter("col", bgcol)
	(bgLayer2Part1.material as ShaderMaterial).set_shader_parameter("col", bgcol)
	(bgLayer2Part2.material as ShaderMaterial).set_shader_parameter("col", bgcol)
	var curColourList := colourList[colourStartInd].cols
	var nextColourList := colourList[colourStartInd + 1].cols
	var dlerpc: float = (dist - colourList[colourStartInd].dist) / (colourList[colourStartInd + 1].dist - colourList[colourStartInd].dist)
	if dlerpc >= 1.0: dlerpc = 1.0
	for i in range(len(curColourList)):
		var col: Color = curColourList[i].lerp(nextColourList[i], dlerpc)
		palDat.encode_u32(i * 4, col.to_abgr32())
	palImg.set_data(256, 1, false, Image.FORMAT_RGBA8, palDat)
	palTex = ImageTexture.create_from_image(palImg)
	road.palTex = palTex
	sky.palTex = palTex
