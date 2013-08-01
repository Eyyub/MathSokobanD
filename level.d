module level;

import std.stdio;
import std.exception;

import derelict.sfml2.graphics;
import derelict.sfml2.system;
import derelict.sfml2.window;

import map;

class Level
{
	private
	{
		Map _map;
		bool _isCleared;
	}
	public
	{
		this(string map_filename, string textures_filename, string[string] animations_json_filenames)
		{
			_map = new Map(map_filename, textures_filename, animations_json_filenames);
		}
		void update(sfEvent event)
		{
			if(_map.isCleared)
				_isCleared = true;
			else _map.update(event);
		}
		void show(sfRenderWindow* window)
		{
			_map.show(window);
		}
		@property bool isCleared()
		{
			return _isCleared;
		}
		~this()
		{
			destroy(_map);
		}
	}
}