module manager.animations;

import std.stdio;
import std.exception;
import std.json;
import std.file;
import std.conv;

import derelict.sfml2.graphics;
import derelict.sfml2.system;
import derelict.sfml2.window;

final class AnimationsManager
{
	private
	{
		sfIntRect[int][string] _animations;
		sfIntRect _currentAnim;
		string _lastFrameName;
		sfClock* clock;
		uint _keyframe = 0;

		void makeAnimations(string json_filename, string[] frames_name)
		{
			auto anim_tree = readText(json_filename).parseJSON();

			foreach(frame_name; frames_name)
			{
				for(uint i = 0; i < anim_tree[frame_name].object.length; ++i)
				{
					auto anim_bounds = anim_tree[frame_name][to!string(i)];
					_animations[frame_name][i] = sfIntRect(to!int(anim_bounds["x"].integer), to!int(anim_bounds["y"].integer), to!int(anim_bounds["w"].integer), to!int(anim_bounds["h"].integer));
				}
			}
			clock = sfClock_create();
		}
	}
	public
	{
		this(const sfTexture* texture, string json_filename, string[] frames_name)
		{
			makeAnimations(json_filename, frames_name);

		}
		void update(string frame_name, sfTime timeInSecondsBetweenTwoFrames = sfSeconds(0))
		{

			if(timeInSecondsBetweenTwoFrames.sfTime_asSeconds() == 0 || sfClock_getElapsedTime(clock).sfTime_asSeconds() > timeInSecondsBetweenTwoFrames.sfTime_asSeconds() || frame_name != _lastFrameName)
			{
				
				if(frame_name != _lastFrameName || _keyframe >= _animations[frame_name].length)
					_keyframe = 0;

				
				_lastFrameName = frame_name;
				_currentAnim = _animations[frame_name][_keyframe];
				
				++_keyframe;
	
				sfClock_restart(clock);
			}
		}
		@property sfIntRect currentAnim()
		{
			return _currentAnim;
		}
		@property void keyframe(uint newkeyframe)
		{
			_keyframe = newkeyframe;
		}
		~this()
		{

		}
	}
}