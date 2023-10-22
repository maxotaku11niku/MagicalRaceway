class_name SplineRenderer
extends Node
## Controls the rendering of all the splines

@export var staticSpriteScene: PackedScene
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

var dist: float
var xpos: float
var turnStrStartInd: int
var pitchStrStartInd: int
var splitAmtStartInd: int
var colourStartInd: int
var bgStartInd: int
var spriteStartInd: int
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
var firstSpawner: int
var numActiveSpawners: int
var nextSpawner: int 

class StaticSprite:
	var splRend: SplineRenderer
	var position: Vector3
	var scale: float
	var sprite: RoadSprite
	
	func PositionSprite(charpos: Vector2, searchPoint: int) -> int:
		if searchPoint < 0: return -1
		return splRend.SetTruePositionsOfSprite(self, charpos, searchPoint)

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

func SetSplinePositioningParameters() -> void:
	# Calculate spline parameters
	var xAngle: float
	var yAngle: float
	var xCurve: float
	var yCurve: float
	var xDev: float
	var yDev: float
	var dlerpx: float
	var dlerpy: float
	var dlerps: float
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
	dlerpx = 0.0
	dlerpy = 0.0
	dlerps = 0.0
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
	dlerps = (dist - splitAmtList[saInd].dist) / (splitAmtList[saInd + 1].dist - splitAmtList[saInd].dist)
	pointSplits[zeroPoint] = lerpf(sa0, sa1, dlerps)
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
		dlerpx = (realDist - turnStrList[tsInd].dist) / (turnStrList[tsInd + 1].dist - turnStrList[tsInd].dist)
		dlerpy = (realDist - pitchStrList[psInd].dist) / (pitchStrList[psInd + 1].dist - pitchStrList[psInd].dist)
		dlerps = (realDist - splitAmtList[saInd].dist) / (splitAmtList[saInd + 1].dist - splitAmtList[saInd].dist)
		if dlerpx >= 1.0: dlerpx = 1.0
		if dlerpy >= 1.0: dlerpy = 1.0
		if dlerps >= 1.0: dlerps = 1.0
		xCurve = lerpf(xc0, xc1, dlerpx)
		yCurve = lerpf(yc0, yc1, dlerpy)
		pointSplits[i] = lerpf(sa0, sa1, dlerps)
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
	roadMat.set_shader_parameter("positioning", posTex)
	roadMat.set_shader_parameter("pPos", Vector2(xpos, fmod(dist, road.texture.get_height())))

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

func TryMakeNewSpawner() -> void:
	var curSprDef := spriteList[spriteStartInd]
	if curSprDef.numSprite > 0 and curSprDef.spawnSide != 0:
		var newSpawner := spriteSpawnerPool[firstSpawner + numActiveSpawners]
		newSpawner.spriteInfo = curSprDef
		newSpawner.nextSpawnDistance = curSprDef.dist
		newSpawner.spritesSpawned = 0
		newSpawner.splRend = self
		numActiveSpawners += 1

func Reset() -> void:
	turnStrStartInd = 0
	pitchStrStartInd = 0
	splitAmtStartInd = 0
	colourStartInd = 0
	bgStartInd = 0
	spriteStartInd = 0
	firstStaticSprite = 0
	firstSpawner = 0
	numStaticSpritesRendered = 0
	numActiveSpawners = 0
	nextSpawner = -1
	for i in range(len(staticSprmngPool)):
		var curspr := staticSprmngPool[i].sprite
		curspr.logicalPosition = Vector3(-6969.0, 420.0, 393939.0)
		curspr.screenPosition = Vector2(-6969.0, 393939.0)
		curspr.scale = Vector2(1.0, 1.0)
		curspr.visible = false
		curspr.monitoring = false
		curspr.monitorable = false
		curspr.process_mode = Node.PROCESS_MODE_DISABLED
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
	staticSprmngPool.resize(1024)
	for i in range(len(staticSprmngPool)):
		staticSprmngPool[i] = StaticSprite.new()
		var curspr := staticSpriteScene.instantiate()
		add_child(curspr)
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
	roadMat.set_shader_parameter("positioning", posTex)
	roadMat.set_shader_parameter("positLines", 256)
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
		while (dist + farClipPosition + 100.0) >= spriteList[spriteStartInd].dist:
			TryMakeNewSpawner()
			spriteStartInd += 1
			if spriteStartInd >= (len(spriteList) - 1):
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
	if nextSpawner < 0:
		nextSpawner = -1
		for i in range(firstSpawner, firstSpawner + numActiveSpawners):
			var realInd := i % len(spriteSpawnerPool)
			var curspwn := spriteSpawnerPool[realInd]
			if curspwn.IsAllSpritesSpawned():
				if i == firstSpawner:
					numActiveSpawners -= 1
					firstSpawner += 1
					firstSpawner %= len(spriteSpawnerPool)
			elif curspwn.nextSpawnDistance < curClosestSpriteDist:
				nextSpawner = i
				curClosestSpriteDist = curspwn.nextSpawnDistance
	if nextSpawner >= 0:
		while spriteSpawnerPool[nextSpawner].TrySpawnSprite(dist + farClipPosition + 100.0):
			nextSpawner = -1
			curClosestSpriteDist = 9999999999999.0
			for i in range(firstSpawner, firstSpawner + numActiveSpawners):
				var realInd := i % len(spriteSpawnerPool)
				var curspwn := spriteSpawnerPool[realInd]
				if curspwn.IsAllSpritesSpawned():
					if i == firstSpawner:
						numActiveSpawners -= 1
						firstSpawner += 1
						firstSpawner %= len(spriteSpawnerPool)
				elif curspwn.nextSpawnDistance < curClosestSpriteDist:
					nextSpawner = i
					curClosestSpriteDist = curspwn.nextSpawnDistance
			if nextSpawner < 0: break
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
	bgLayer1Part1.position.x = fmod(bg1Offset, curBGDef.bg1Region.size.x)
	bgLayer2Part1.position.x = fmod(bg2Offset, curBGDef.bg2Region.size.x)
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
