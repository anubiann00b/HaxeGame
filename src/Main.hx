import mgl.*;
using mgl.Fiber;
using mgl.Util;

class Main extends Game {

    static public function main() {
        new Main();
    }

    function new() {
        super(this);
    }

    var bgmDrumSound:Sound;
    var endGameSound:Sound;

    public override function initialize() {
        Ball.main = this;
        Sound.setDefaultQuant(4);
        bgmDrumSound = new Sound().setDrumMachine();
        endGameSound = new Sound().major().setMelody().addTone(.3, 10, .7).addTone(.6, 10, .4).end();
        setTitle("SNEAKY RUN");
    }

    public var ballLeft:Int;
    var nextBallCount:Int;
    var time:Int;

    public override function begin() {
        Ball.player = new Player();
        nextBallCount = 0;
        ballLeft = 28;
        time = 0;
        bgmDrumSound.play();
    }

    public override function update() {
        var sc = Std.int(time / 1000);
        var ms = '00${time % 1000}';
        ms = ms.substr(ms.length - 3);
        new Text().setXy(.99, .01).alignRight().setText('TIME: $sc.$ms').draw();
        if (!Game.isInGame) return;
        time += 16;
        new Text().setXy(.01, .01).setText('LEFT: $ballLeft').draw();
        if (ballLeft <= 0) {
            endGameSound.play();
            Game.endGame();
        } else if (Actor.getActors("Ball").length <= 0) {
            nextBallCount++;
            for (i in 0...nextBallCount) new Ball();
        }
        if (Game.ticks == 0) {
            new Text().setXy(.1, .1).setText("[urdl]: MOVE").setTicks(180).addOnce();
        }
        if (Game.ticks == 60) {
            new Text().setXy(.1, .15).setText("[Z]: BREAK").setTicks(180).addOnce();
        }
    }
}
class Player extends Actor {

    static var tickSound:Sound;

    public override function initialize() {
        dotPixelArt = new DotPixelArt().setColor(Color.green).generateShape(.04, .05);
        tickSound = new Sound().minor().addTone(.5, 3, .3).end();
        setHitRect(.04, .05);
    }

    public override function begin() {
        position.setNumber(.5);
        new Fiber(this).wait(30).doIt( { tickSound.play(); } );
    }

    public override function update() {
        way = position.wayTo(Mouse.position);
        if (position.distanceTo(Mouse.position) > 0.01) {
            makeMove(new Vector().addWay(way, 0.005));
            new Particle().setPosition(position).setColor(Color.green.goDark())
                    .setWay(way + 180, 45).setSpeed(0.005).add();
        }
        isHit("Ball", function(ball:Ball) {
            ball.erase();
        });
    }

    function makeMove(vec:Vector) {
        Actor.scrollActors(["Ball"], -vec.x, -vec.y);
    }
}

class Ball extends Actor {

    static public var main:Main;
    static public var player:Player;
    static var removeSound:Sound;

    public override function initialize() {
        dotPixelArt = new DotPixelArt().setColor(Color.yellow).generateCircle(.04);
        setHitRect(.04);
        removeSound = new Sound().minor().addTone(.7).addRest().addTone(.7).end();
    }

    public override function begin() {
        for (i in 0...10) {
            position.setXy((0.1).randomFromTo(.9), (0.1).randomFromTo(.9));
            if (position.distanceTo(player.position) > .3) break;
        }
    }

    public function erase() {
        new Particle().setPosition(position).setColor(Color.yellow.goRed())
        .setCount(20).setSize(.03).add();
        main.ballLeft--;
        removeSound.play();
        remove();
    }
}