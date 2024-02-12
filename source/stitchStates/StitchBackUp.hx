package stitchStates;

//I WANTED TO MAKE MY OWN STATE BUT THIS AINT LOOKIN SO BRIGHT LOL ILL REVISIT

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;

class Stitch extends MusicBeatState
{
	var keyz = 'MENUS/SELECT/';
	var spin:FlxSprite;
    var arrow:FlxSprite;
    var stitch:FlxSprite;
    var sparkle:FlxSprite;
    //STORYSHIT
	var loadedWeeks:Array<WeekData> = [];
	var selectedWeek:Bool = false;
	var curDifficulty:Int = 1;
	private static var curWeek:Int = 0;
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();
	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		super.create();
		var s = 0.70;
		var bg = new FlxSprite(-300, -300).loadGraphic(Paths.image(keyz + 'BGselection'));
		bg.frames = Paths.getSparrowAtlas(keyz + 'BGselection');
		bg.animation.addByPrefix('a', 'BG', 24);
		bg.animation.play('a');
		bg.scale.x = s;
		bg.scale.y = s;
		add(bg);
		
        var spin = new FlxSprite(100, 100).loadGraphic(Paths.image(keyz + 'Stitch_spin'));
        spin.frames = Paths.getSparrowAtlas(keyz + 'Stitch_spin');
		spin.animation.addByPrefix('a', 'Stitch spin', 24);
		spin.animation.play('a');
		spin.scale.x = 1;
		spin.scale.y = 1;
		add(spin);
		var blackBar = new FlxSprite(-500, -360).loadGraphic(Paths.image(keyz + 'BLACKBARSselection'));
		blackBar.frames = Paths.getSparrowAtlas(keyz + 'BLACKBARSselection');
		blackBar.animation.addByPrefix('a', 'selectscreenBLKBARS', 24);
		blackBar.animation.play('a');
		blackBar.scale.x = s;
		blackBar.scale.y = s;
		add(blackBar);
        var arrow = new FlxSprite(680, 290).loadGraphic(Paths.image(keyz + 'pointer'));
		arrow.frames = Paths.getSparrowAtlas(keyz + 'pointer');
		arrow.animation.addByPrefix('a', 'arrow', 24);
		arrow.animation.play('a');
		arrow.scale.x = s;
		arrow.scale.y = s;
		add(arrow);
        var stitch = new FlxSprite(0, 250).loadGraphic(Paths.image(keyz + 'STITCH'));
		stitch.frames = Paths.getSparrowAtlas(keyz + 'STITCH');
		stitch.animation.addByPrefix('stay', 'STITCH_fuck', 24);
		stitch.animation.play('stay');
		stitch.scale.x = s;
		stitch.scale.y = s;
		add(stitch);
        var sparkle = new FlxSprite(-65, 210).loadGraphic(Paths.image(keyz + 'STITCHsprkles'));
		sparkle.frames = Paths.getSparrowAtlas(keyz + 'STITCHsprkles');
		sparkle.animation.addByPrefix('a', 'stitchsprkls', 24);
		sparkle.animation.play('a');
		sparkle.scale.x = s;
		sparkle.scale.y = s;
		add(sparkle);
/////

var num:Int = 0;
for (i in 0...WeekData.weeksList.length)
	{
		var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
		var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
		if(!isLocked || !weekFile.hiddenUntilUnlocked)
		{
			loadedWeeks.push(weekFile);
			WeekData.setDirectoryFromWeek(weekFile);
			num++;
		}
	}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			trace('leweek:' + leWeek);
		
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
			if(diffic == null) diffic = '';

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
		}
	}
	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}
}