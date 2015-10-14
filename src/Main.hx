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
        Sound.setDefaultQuant(4);
        bgmDrumSound = new Sound().setDrumMachine();
        endGameSound = new Sound().major().setMelody().addTone(.3, 10, .7).addTone(.6, 10, .4).end();
        setTitle("SNEAKY RUN");
    }

    var time:Int;
    var grid:Grid;

    public override function begin() {
        new Player();
        grid = new Grid();
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
        if (Game.ticks == 0) {
            new Text().setXy(.1, .1).setText("[urdl]: MOVE").setTicks(180).addOnce();
        }
//        if (Game.ticks == 60) {
//            new Text().setXy(.1, .15).setText("[Z]: BREAK").setTicks(180).addOnce();
//        }
    }
}

class Wall extends Actor {

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
        if (!Game.isInGame) return;

        if (position.distanceTo(Mouse.position) > 0.01) {
            makeMove(new Vector().addWay(way, 0.005));
            new Particle().setPosition(position).setColor(Color.green.goDark())
            .setWay(way + 180, 45).setSpeed(0.005).add();
        }
//        isHit("Ball", function(ball:Ball) {
//            ball.erase();
//        });
    }

    function makeMove(vec:Vector) {
        Actor.scrollActors(["Ball", "Grid"], -vec.x, -vec.y);
    }
}

class Grid extends Actor {

    static var SIZE = 8;

    static var outline:DotPixelArt;

    public override function initialize() {
        outline = new DotPixelArt().setColor(Color.blue).lineRect(1.0 / SIZE);
        setDisplayPriority(-1);
    }

    public override function update() {
        for (xi in -1...SIZE+1) {
            var x = (xi + .5) / SIZE;
            for (yi in -1...SIZE+1) {
                var y = (yi + .5) / SIZE;
                outline.xy(x + position.x % (1/SIZE), y + position.y % (1/SIZE)).d;
            }
        }
    }
}