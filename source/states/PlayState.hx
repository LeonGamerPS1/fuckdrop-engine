package states;

import objects.gameplay.*;

class PlayState extends FlxState {
    public var playfield:Playfield;

    public override function create() {
        super.create();
        playfield = cast(add(new Playfield()));
    }

}