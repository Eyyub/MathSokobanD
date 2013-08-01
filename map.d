module map;

import std.stdio;
import std.exception;
import std.conv;
import std.string;

import derelict.sfml2.graphics;
import derelict.sfml2.system;
import derelict.sfml2.window;

import manager.sprite;
import manager.collision;
import manager.texture;

import sprite;
import bloc;
import player;
import utils;

enum TILE_WIDTH = 32;
enum TILE_HEIGHT = 32;

class MapException : Exception
{
	public
	{
		this(string msg)
		{
			super(msg);
		}
	}
}

class Map
{
	private
	{
		SpriteManager _sm;
		CollisionManager _cm;
		TextureManager _tm;
		bool _isCleared;

		void parseMapFile(string map_filename, string[string] animations_json_filenames)
		{
			auto file = File(map_filename, "r");
			scope(exit) file.close();
			uint y = 0;
			
			foreach(str; file.byLine())
			{
				auto line = str.split(",");
				foreach(uint x, item; line)
				{
					if(item == "*".dup)
						continue;
					if(item == "#".dup)
					{
						auto temp = new BlocImmobile(_tm["bloc_immobile"], sfVector2f(TILE_WIDTH*x, TILE_HEIGHT*y));
						_sm.insert(temp);
						_cm.insert(temp);
					}
					else if(item == "p" || item == "P")
					{
						auto temp = new Player(_tm["player"], animations_json_filenames["player"], sfVector2f((TILE_WIDTH ) * x, (TILE_HEIGHT ) * y));
						_sm.insert(temp);
						_cm.insert(temp);
					}
					else if(item.isNumeric())
					{
						auto temp = new BlocMobileMath(to!int(item), _tm["bloc_mobile_math"], animations_json_filenames["bloc_mobile_math"], sfVector2f((TILE_WIDTH ) * x, (TILE_HEIGHT ) * y));
						_sm.insert(temp);
						_cm.insert(temp);
					}
					else if(item.length > 4 && item[0..4] == "fct_".dup)
					{
						auto temp = new BlocFonction(makePtrMathFunction(to!string(item[4..$])), to!string(item[4..$]), _tm["bloc_fonction"], sfVector2f((TILE_WIDTH ) * x, (TILE_HEIGHT ) * y));
						_sm.insert(temp);
						_cm.insert(temp);
					}
					else if(item.length > 2 && item[0..2] == "c_".dup)
					{
						auto temp = new BlocCheckpoint(to!int(item[2..$]), _tm["bloc_checkpoint"], sfVector2f((TILE_WIDTH ) * x, (TILE_HEIGHT ) * y));
						_sm.insert(temp);
						_cm.insert(temp);
					}
					else
					{
						throw new MapException("Unknow symbol : %s at line %d position %d(without ',').".format(item, y, x));
					}
				}
				y += 1;
			}

		}
	}
	public
	{
		this(string map_filename, string textures_filename, string[string] animations_json_filenames)
		{
			_sm = new SpriteManager;
			_cm = new CollisionManager;
			_tm = new TextureManager(textures_filename);
			parseMapFile(map_filename, animations_json_filenames);
		}
		void update(sfEvent event)
		{
			if(_cm.isCleared)
				_isCleared = true;
			else
			{
				_sm.update(event);
				_cm.update();
			}

		}
		void show(sfRenderWindow* window)
		{
			if(!_isCleared)
				_sm.show(window);
		}
		@property bool isCleared()
		{
			return _isCleared;
		}
		~this()
		{
			destroy(_cm); // destroying an interface(in _cm dtor) does not do anything so that's why we should call _cm's dtor before _sm's dtor
			destroy(_sm);
			destroy(_tm);
		}
	}
}