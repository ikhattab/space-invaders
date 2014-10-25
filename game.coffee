class Game
  constructor: (canvasId, soundId) ->
    canvas = document.getElementById canvasId
    @shootSound = document.getElementById soundId
    screen = canvas.getContext '2d'
    gameSize =
      x: canvas.width
      y: canvas.height

    @bodies = createInvaders(this).concat(new Player this, gameSize)

    tick = =>
      @update()
      @draw screen, gameSize
      requestAnimationFrame tick

    tick()

  createInvaders = (game) ->
    new Invader game, {x: 30 + (i % 8) * 30, y: 30 + (i % 3) * 30} for i in [0...24]

  update: () ->
    notCollidingWithAnything = (b1) =>
      (@bodies.filter (b2) -> isColliding b1, b2).length is 0

    @bodies = @bodies.filter notCollidingWithAnything
    body.update() for body in @bodies

  addBody: (body) ->
    @bodies.push body

  invadersBelow: (invader) ->
    @bodies.filter (b) ->
      b instanceof Invader and
      b.center.y > invader.center.y and
      b.center.x - invader.center.x < invader.size.x
    .length > 0

  drawRect = (screen, body) ->
    screen.fillRect body.center.x - body.size.x / 2,
                    body.center.y - body.size.y / 2,
                    body.size.x,
                    body.size.y

  draw: (screen,  gameSize) ->
    screen.clearRect 0, 0, gameSize.x, gameSize.y
    drawRect screen, body for body in @bodies

class Player
  constructor: (@game, @gameSize) ->
    @size = x: 15, y: 15
    @center = x: @gameSize.x / 2, y: @gameSize.y - @size.y
    @keyBoarder = new KeyBoarder

  update: () ->
    @center.x -= 2 if @keyBoarder.isDown @keyBoarder.KEYS.LEFT
    @center.x += 2 if @keyBoarder.isDown @keyBoarder.KEYS.RIGHT
    @center.x = @size.x if @center.x < @size.x
    @center.x = @gameSize.x - @size.x if @center.x > @gameSize.x - @size.x

    if @keyBoarder.isDown @keyBoarder.KEYS.SPACE
      bullet = new Bullet
        x: @center.x
        y: @center.y - @size.y
      , {x: 0, y: -6}

      @game.addBody bullet
      @game.shootSound.load()
      @game.shootSound.play()

class Invader
  constructor: (@game, @center) ->
    @size = x: 15, y: 15
    @patrolX = 0
    @speedX = 0.3

  update: () ->
    @speedX = -@speedX if @patrolX < 0 || @patrolX > 40
    @center.x += @speedX
    @patrolX += @speedX
    if Math.random() > 0.995 and not @game.invadersBelow this
      bullet = new Bullet
          x: @center.x
          y: @center.y + @size.y
        , {x: Math.random() - 0.5, y: 2}

      @game.addBody bullet

class Bullet
  constructor: (@center, @velocity) ->
    @size = x: 3, y: 3

  update: () ->
    @center.x += @velocity.x
    @center.y += @velocity.y

class KeyBoarder
  constructor: () ->
    keyState = {}

    window.onkeydown = (e) ->
      keyState[e.keyCode] = true

    window.onkeyup = (e) ->
      keyState[e.keyCode] = false

    @isDown = (keyCode) ->
      keyState[keyCode] is true

    @KEYS =
      LEFT: 37
      RIGHT: 39
      SPACE: 32

isColliding = (b1, b2) ->
  not (
        b1 is b2 or
        b1.center.x + b1.size.x / 2 <= b2.center.x - b2.size.x / 2 or
        b1.center.y + b1.size.y / 2 <= b2.center.y - b2.size.y / 2 or
        b1.center.x - b1.size.x / 2 >= b2.center.x + b2.size.x / 2 or
        b1.center.y - b1.size.y / 2 >= b2.center.y + b2.size.y / 2
      )

window.onload = ->
  new Game 'screen', 'shoot-sound'
