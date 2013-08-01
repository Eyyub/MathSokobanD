module manager.sprite;

import std.container;

import derelict.sfml2.graphics;
import derelict.sfml2.system;
import derelict.sfml2.window;

import sprite;
import bloc;
import player;

alias SpriteArray = Array!Sprite;

final class SpriteManager
{
	private
	{
		SpriteArray _sprites;
	}
	public
	{
		this()
		{
			_sprites = SpriteArray();
		}
		void update(sfEvent event)
		{
			foreach(sprite; _sprites)
				sprite.update(event);
		}
		void show(sfRenderWindow* window)
		{
			foreach(sprite; _sprites)
				if(typeid(sprite) == typeid(BlocImmobile) || typeid(sprite) == typeid(BlocCheckpoint) || typeid(sprite) == typeid(BlocFonction))
					sprite.show(window);

			foreach(sprite; _sprites)
				if(typeid(sprite) == typeid(BlocMobileMath))
					sprite.show(window);

			foreach(sprite; _sprites)
				if(typeid(sprite) == typeid(Player))
					sprite.show(window);
		}
		void insert(Sprite sprite)
		{
			_sprites.insert(sprite);
		}
		~this()
		{
			_sprites.clear();
		}
	}
}