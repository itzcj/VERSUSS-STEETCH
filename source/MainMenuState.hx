package;

#if desktop
import Discord.DiscordClient;
#end
import stitchStates.FreeplayPicking;
import stitchStates.Stitch;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = 'STITCH PE'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var menuSparks:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var optionShit:Array<String> = ['story', 'freeplay', 'options'];
	var sparkleShit:Array<String> = ['story', 'frply', 'options'];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-950, -740).loadGraphic(Paths.image('MENUS/STORY/BG'));
		bg.frames = Paths.getSparrowAtlas('MENUS/STORY/BG');
		bg.animation.addByPrefix('idle', 'BG', 24);
		bg.animation.play('idle');
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);

		// magenta.scrollFactor.set();
		var bb = new FlxSprite(-970, -650).loadGraphic(Paths.image('MENUS/STORY/BLACKBARS'));
		bb.scale.x = 0.70;
		bb.scale.y = 0.70;
		add(bb);
		// add(sparkle1);
		// add(sparkle2);
		// add(sparkle3);
		menuSparks = new FlxTypedGroup<FlxSprite>();
		add(menuSparks);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/
		// sparkle1.frames = Paths.getSparrowAtlas('MENUS/STORY/' + "storysprkls");
		// sparkle1.animation.addByPrefix('SHINE', 'storysprkls', 24);
		// sparkle1.animation.play("SHINE");
		// sparkle1.scale.x = 0.70;
		// sparkle1.scale.y = 0.70;
		// ///////
		// sparkle2.frames = Paths.getSparrowAtlas('MENUS/STORY/' + "frplysprkls");
		// sparkle2.animation.addByPrefix('SHINE', 'storysprkls', 24);
		// sparkle2.animation.play("SHINE");
		// sparkle2.scale.x = 0.70;
		// sparkle2.scale.y = 0.70;
		// ///////
		// sparkle3.frames = Paths.getSparrowAtlas('MENUS/STORY/' + "optionssprkls");
		// sparkle3.animation.addByPrefix('SHINE', 'storysprkls', 24);
		// sparkle3.animation.play("SHINE");
		// sparkle3.scale.x = 0.70;
		// sparkle3.scale.y = 0.70;
		for (i in 0...1)
		{
			var menuSpark = new FlxSprite(-450, -460);
			menuSpark.frames = Paths.getSparrowAtlas('MENUS/STORY/' + "storysprkls");
			menuSpark.animation.addByPrefix('SHINE', 'storysprkls', 24);
			menuSpark.animation.play("SHINE");
			menuSpark.scale.x = 0.70;
			menuSpark.scale.y = 0.70;
			menuSparks.add(menuSpark);
			menuSpark.ID = i;
			var menuItem:FlxSprite = new FlxSprite(-400, -270);
			menuItem.scale.x = 0.70;
			menuItem.scale.y = 0.70;
			menuItem.frames = Paths.getSparrowAtlas('MENUS/STORY/' + optionShit[i]);
			menuItem.animation.addByPrefix('selected', optionShit[i] + 'SLCTD', 24);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " friend", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			// menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		for (i in 1...2)
		{
			var menuSpark = new FlxSprite(376, -340);
			menuSpark.frames = Paths.getSparrowAtlas('MENUS/STORY/' + "frplysprkls");
			menuSpark.animation.addByPrefix('SHINE', 'freeplayspkls', 24);
			menuSpark.animation.play("SHINE");
			menuSpark.scale.x = 0.70;
			menuSpark.scale.y = 0.70;
			menuSparks.add(menuSpark);
			menuSpark.ID = i;
			var menuItem:FlxSprite = new FlxSprite(80, -275);
			menuItem.scale.x = 0.70;
			menuItem.scale.y = 0.70;
			menuItem.frames = Paths.getSparrowAtlas('MENUS/STORY/' + optionShit[i]);
			menuItem.animation.addByPrefix('selected', optionShit[i] + 'SLCTD', 24);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " friend", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			// menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}
		for (i in 2...3)
		{
			var menuSpark = new FlxSprite(380, 280);
			menuSpark.frames = Paths.getSparrowAtlas('MENUS/STORY/' + "optionssprkls");
			menuSpark.animation.addByPrefix('SHINE', 'optionsprkls', 24);
			menuSpark.animation.play("SHINE");
			menuSpark.scale.x = 0.70;
			menuSpark.scale.y = 0.70;
			menuSparks.add(menuSpark);
			menuSpark.ID = i;
			var menuItem:FlxSprite = new FlxSprite(80, -35);
			menuItem.scale.x = 0.70;
			menuItem.scale.y = 0.70;
			menuItem.frames = Paths.getSparrowAtlas('MENUS/STORY/' + optionShit[i]);
			menuItem.animation.addByPrefix('selected', optionShit[i] + 'SLCTD', 24);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " friend", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			// menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}
		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();
		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
		{
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if (!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2]))
			{ // It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement()
	{
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if (ClientPrefs.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story':
										MusicBeatState.switchState(new Stitch());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		// menuItems.forEach(function(spr:FlxSprite)
		// {
		// 	spr.screenCenter(X);
		// });
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;
			menuSparks.forEach(function(spark:FlxSprite) {
				spark.alpha = 0;
				if (spark.ID == curSelected) {
					spark.alpha = 1;
				}
			});
		

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if (menuItems.length > 4)
				{
					add = menuItems.length * 8;
				}
			}
		});
	}
}
