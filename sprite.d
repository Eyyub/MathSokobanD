module sprite;

import std.exception;

import derelict.sfml2.graphics;
import derelict.sfml2.system;
import derelict.sfml2.window;

import visitor;
import manager.animations;

interface Entity
{
	@property bool isAlive();
}

interface Collidable : Entity, IVisitable
{
	public
	{
		void onCollide(Collidable entity);
		@property sfFloatRect bounds();
		@property void hasMoved(bool b);
		@property bool hasMoved();
		
	}
}

mixin template makeBounds()
{
	public
	{
		@property sfFloatRect bounds()
		{
			return getGlobalBounds();
		}
	}
}


abstract class Sprite
{
	protected
	{
		sfSprite* _sprite;

		auto  getGlobalBounds()
		{
			return sfSprite_getGlobalBounds(_sprite);
		}
	}
	public
	{
		this(const sfTexture* texture, sfVector2f pos, sfBool resetRect = sfTrue)
		{
			_sprite = sfSprite_create();
			enforce(_sprite !is null, "Can't init. sprite.");
			sfSprite_setTexture(_sprite, texture, resetRect);
			sfSprite_setPosition(_sprite, pos);
		}

		void update(sfEvent event)
		{

		}
		void show(sfRenderWindow* window)
		{
			sfRenderWindow_drawSprite(window, _sprite, null);
		}
		void setPosition(sfVector2f newpos)
		{
			sfSprite_setPosition(_sprite, newpos);
		}
		@property sfVector2f pos()
		{
			return sfSprite_getPosition(_sprite);
		}
		~this()
		{
			sfSprite_destroy(_sprite);
		}
	}
}

abstract class MoveableSprite : Sprite
{
	protected
	{
		sfVector2f _pos;
		sfVector2f _lastPos;
		sfVector2f _lastMove;
		sfVector2f _beforeLastPos;
		
	}
	public
	{
		bool _hasMoved = false;
		this(const sfTexture* texture, sfVector2f pos, sfBool resetRect = sfTrue)
		{
			super(texture, pos, resetRect);
		}
		void move(sfVector2f mouvement)
		{
			_lastMove = mouvement;
			_lastPos = sfSprite_getPosition(_sprite);
			sfSprite_move(_sprite, mouvement);
			_hasMoved = true;
		}
		void move(int x, int y)
		{
			move(sfVector2f(x, y));
		}
		override void setPosition(sfVector2f newpos)
		{
			_beforeLastPos = _lastPos;
			_lastPos = newpos;
			super.setPosition(newpos);
		}
		override void show(sfRenderWindow* window)
		{
			_hasMoved = false;
			super.show(window);
		}
		@property auto lastMove()
		{
			return _lastMove;
		}
		@property auto lastPos()
		{
			return _lastPos;
		}
		@property auto beforeLastPos()
		{
			return _beforeLastPos;
		}
		~this()
		{
			destroy(_pos);
		}
	}
}

abstract class MoveableAnimatedSprite : MoveableSprite
{
	protected
	{
		AnimationsManager _am;
	}
	public
	{
		this(const sfTexture* texture, string animations_json, string[] frames_name, sfVector2f pos, sfBool resetRect = sfTrue)
		{
			_am = new AnimationsManager(texture, animations_json, frames_name);
			super(texture, pos, resetRect);
		}
		override void show(sfRenderWindow* window)
		{			
			sfSprite_setTextureRect(_sprite, _am.currentAnim);
			super.show(window);
		}
		~this()
		{
			destroy(_am);
		}
	}
}