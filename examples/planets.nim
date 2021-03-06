
import 
  chipmunk, 
  csfml, 
  math, 
  random,
  basic2d,
  debugdraw

const
  gravityStrength = 50.CpFloat
  CTplanet = 1.CollisionType
  CTgravity= 2.CollisionType
  ScreenW = 640
  ScreenH = 480

var 
  space = newSpace()
  window = newRenderWindow(
    videoMode(ScreenW, ScreenH, 32), "Planets demo", WindowStyle.Default
  )
  screenArea = IntRect(left: 20, top: 20, width: ScreenW-20, height: ScreenH-20)

randomize()

proc gravityApplicator(arb: ArbiterPtr; space: 
                       SpacePtr; data: pointer): bool {.cdecl.} =
  var 
    dist = arb.body_a.getPos() - arb.body_b.getPos()
  dist.normalize()
  arb.body_b.applyImpulse(
    dist * (1.0 / basic2d.len(dist) * gravityStrength), VectorZero
  )

proc randomPoint(rect: var IntRect): Vector =
  result.x = (random(rect.width) + rect.left).CpFloat
  result.y = (random(rect.height) + rect.top).CpFloat

proc addPlanet() =
  let
    mass = random(10_000)/10_000*10.0
    radius = mass * 2.0
    gravityRadius = radius * 8.8
    body = space.addBody(newBody(mass, MomentForCircle(mass, 0.0, radius, VectorZero)))
    shape = debugdraw.addShape(space, body.newCircleShape(radius, VectorZero))
    gravity = debugdraw.addShape(space, body.newCircleShape(gravityRadius, VectorZero))
    gravityCircle = TOSPRITE(gravity, csfml.CircleShape)
  body.setPos randomPoint(screenArea)
  shape.setCollisionType CTplanet
  gravity.setSensor true
  gravity.setCollisionType CTgravity
  gravityCircle.fillColor = Transparent
  gravityCircle.outlineColor = Blue
  gravityCircle.outlineThickness = 2.0


# Startup initialization
window.frameRateLimit = 60
space.setIterations(20)
space.addCollisionHandler(CTgravity, CTplanet, preSolve = gravityApplicator)

# Add the planets and the borders
block:
  let borders = [vector(0, 0), vector(0, ScreenH),
                 vector(ScreenW, ScreenH), vector(ScreenW, 0)]
  for i in 0..3:
    var shape = space.addStaticShape(space.getStaticBody.newSegmentShape(
      borders[i], borders[(i + 1) mod 4], 16.0)
    )
  for i in 1..30:
    addPlanet()

# Initialize the debugdraw module
debugDrawInit(space)

var
  running = true
  event: Event
  clock = newClock()
while running:
  while window.pollEvent(event):
    if event.kind == EventType.Closed:
      running = false
      break
    elif event.kind == EventType.KeyPressed:
      if event.key.code == KeyCode.Escape:
        running = false
        break
        
  let dt = clock.restart.asSeconds / 100
  
  space.step dt
  window.clear Black
  window.draw space
  window.display()

space.destroy()

