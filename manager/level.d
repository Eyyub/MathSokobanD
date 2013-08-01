module manager.level;

import std.stdio;
import std.container;
import std.exception;
import std.format;

import derelict.sfml2.graphics;
import derelict.sfml2.system;
import derelict.sfml2.window;

import level;
import manager.save;

alias StringArray = Array!string;
alias LevelArray = Array!Level;

class LevelManager
{
	private
	{
		Level _currentLevel;
		StringArray _map_filenames;
		SaveManager _sm;
		string _textures_filename;
		string[string] _animations_json_filenames;
	}
	public
	{
		this(string maps_filename, string save_filename, string textures_filename, string[string] animations_json_filenames)
		{
			auto file = File(maps_filename, "r");
			scope(exit) file.close();
			_map_filenames = StringArray();
			_textures_filename = textures_filename;
			foreach(line; file.byLine)
			{
				string map_filename;
				enforce(line.formattedRead("map_filename=%s", &map_filename) == 1, maps_filename ~ "format is wrong.");
				_map_filenames.insertBack(map_filename);
			}

			debug writeln(_map_filenames[]);

			_sm = new SaveManager(save_filename);
			_currentLevel = new Level(_map_filenames[_sm.currentLevel], _textures_filename, animations_json_filenames);

			_animations_json_filenames = animations_json_filenames;


		}
		void update(sfEvent event)
		{
			 _currentLevel.update(event);
		}
		void show(sfRenderWindow* window)
		{
			_currentLevel.show(window);
		}
		void nextLevel()
		{
			uint i = (_sm.currentLevel + 1) != _map_filenames.length ? (_sm.currentLevel + 1) : 0;
			debug writeln(i, " ", _map_filenames[i]);
			_sm.save(i);
			destroy(_currentLevel);
			_currentLevel = null;
			_currentLevel = new Level(_map_filenames[i], _textures_filename, _animations_json_filenames);				
		}
		@property auto currentLevel()
		{
			return _currentLevel;
		}
		~this()
		{
			destroy(_currentLevel);
			_map_filenames.clear();
		}
	}
}