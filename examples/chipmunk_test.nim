import chipmunk, sfml, sfml_colors, sfml_vector
import math
const
  Width = 800
  Height= 600
type 
  PGameObj = ref object
    sprite: sfml.PCircleShape
    body: PBody
    shape: chipmunk.PShape
var 
  window = newRenderWindow(newVideoMode(Width, Height, 32), "Chipmunk Test", sfDefaultStyle)
  space = newSpace()
  gameobjects: seq[PGameObj] = @[]

window.setFramerateLimit(60)
space.setGravity(newVector(8.9, 82.3))

randomize()

var borders = @[
  newVector(0.0, 0.0), 
  newVector(Width.float, 0.0), 
  newVector(Width.float, Height.float),
  newVector(0.0, Height.float)]
borders = @[
  newVector(0.0, 0.0),
  newVector(100.0,0),
  newVector(100.0,100.0),
  newVector(0.0, 100.0)]
for i in 0..3:
  var shape = space.addShape(newSegmentShape(space.getStaticBody(), borders[i], borders[(i+1) mod 4], 1.0))
  shape.setLayers(1.TLayers)
  echo($ shape.getLayers())

proc vectorToVec2f(a: TVector): TVector2f =
  result.x = a.x
  result.y = a.y
proc floor(a: TVector): TVector2f =
  result.x = a.x.floor
  result.y = a.y.floor

proc newBall(mass = 10.0, radius = 10.0): PGameObj =
  let pos = newVector(random(Width).float, random(Height).float)
  new(result)
  result.sprite = newCircleShape()
  result.sprite.setRadius(radius)
  result.body = space.addBody(newBody(mass, momentForCircle(mass, 0.0, radius, vectorZero)))
  result.body.setPos pos
  result.shape = space.addShape(newCircleShape(result.body, radius, VectorZero))
  result.shape.setLayers(1.TLayers)
  echo($pos, $result.body.getPos(), $result.body.getMass()) #not being set for some reason .. >:\

for i in 0..0: #50:
  gameobjects.add(newBall((50.random + 1).float, (30.random + 5).float))
var ball = newBall(10.2, 15.0)
ball.sprite.setFillColor Blue
gameobjects.add(ball)

var 
  font = getDefaultFont()
  text = newText()
  event: TEvent
  clock = newClock()
  oldPos: TVector
text.setCharacterSize 18
text.setFont font
text.setString "" 
var text2 = text.copy()
text2.setPosition(text2.getPosition + vec2f(0.0, 18.0))
while window.isOpen():
  while window.pollEvent(addr event):
    if event.kind == EvtClosed:
      window.close()
      break
    elif event.kind == EvtKeyPressed:
      if event.key.code == KeyR:
        #ball.body.setPos(newVector(100.0, 100.0))
        ball.body.resetForces()
        text.setString($ball.body.getPos())
        oldPos = ball.body.getPos()
        echo("oldPos = ", repr(ball.body.getPos()))
      elif event.key.code == KeyO:
        ball.body.setPos(oldPos)
      
  space.step(1.0/60.0)
  window.clear(Black)
  for o in gameobjects: 
    #o.body.resetForces()
    o.sprite.setPosition o.body.getPos.vectorToVec2f
    window.draw o.sprite
  window.draw text
  window.display()

for o in gameobjects:
  o.body.destroy()
  o.sprite.destroy()

space.destroy()