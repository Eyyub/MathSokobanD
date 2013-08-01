module game;

import std.string;

import derelict.sfml2.graphics;
import derelict.sfml2.system;
import derelict.sfml2.window;
import derelict.sfml2.audio;

import manager.level;

class Game
{
	private
	{
		sfRenderWindow* _window;
		LevelManager _lvlManager;
	}
	private
	{
		void update(sfEvent event)
		{			
			if(_lvlManager.currentLevel.isCleared)
			{
				_lvlManager.nextLevel();
			}
			else
				while(sfRenderWindow_pollEvent(_window, &event))
				{
					switch(event.type)
					{
						case sfEvtClosed:
							sfRenderWindow_close(_window);
							break;
						case sfEvtKeyPressed, sfEvtKeyReleased:
							_lvlManager.update(event);
							break;
						default:
							break;
					}
				}
		}
		void show()
		{
			sfRenderWindow_clear(_window, sfColor(0x7F, 0x7F, 0x7F, 0));
			_lvlManager.show(_window);
			sfRenderWindow_display(_window);
		}
	}
	public
	{
		this(string name, immutable uint width, immutable uint height, immutable uint bitsPerPixel, string maps_filename, string save_filename, string textures_filename, string musicname, string[string] animations_json_filenames)
		{
			_window = sfRenderWindow_create(sfVideoMode(width, height, bitsPerPixel), name.toStringz(), sfClose, null);
			_lvlManager = new LevelManager(maps_filename, save_filename, textures_filename, animations_json_filenames);
		}
		void run()
		{
			sfEvent event;
			while(sfRenderWindow_isOpen(_window))
			{
				update(event);
				show();			
			}
		}
		~this()
		{
			destroy(_lvlManager);
			sfRenderWindow_destroy(_window);
		}

	}
}