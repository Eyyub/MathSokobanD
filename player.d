module player;

import std.stdio;

import derelict.sfml2.graphics;
import derelict.sfml2.system;
import derelict.sfml2.window;

import sprite;
import visitor;
import bloc;
import utils;

class Player : MoveableAnimatedSprite, Collidable, IVisitor
{
	private
	{
		brain!int novelli;
	}
	public
	{
		this(const sfTexture* texture, string animations_json_filename, sfVector2f pos, sfBool resetRect = sfTrue)
		{
			super(texture, animations_json_filename, ["UP", "DOWN", "LEFT", "RIGHT"], pos, resetRect);
			_am.update("DOWN");

		}
		override void update(sfEvent event)
		{
			switch(event.type)
			{
				case sfEvtKeyPressed:
					switch(event.key.code)
					{
						// il ne faut pas que le mouvement soit superieur a la taille d'une tile car pourrait provoquer un bug
						case sfKeyUp:
							move(0, -8);
							_am.update("UP", sfMilliseconds(100));
							break;
						case sfKeyDown:
							move(0, 8);
							_am.update("DOWN", sfMilliseconds(100));
							break;
						case sfKeyLeft:
							move(-8, 0);
							_am.update("LEFT", sfMilliseconds(100));
							break;
						case sfKeyRight:
							move(8, 0);
							_am.update("RIGHT", sfMilliseconds(100));
							break;
						default:
							break;
					}

					break;
				case sfEvtKeyReleased:
					_am.keyframe = 0;
					switch(event.key.code)
					{
						case sfKeyUp:
							_am.update("UP");
							break;
						case sfKeyDown:					
							_am.update("DOWN");
							break;
						case sfKeyLeft:
							_am.update("LEFT");
							break;
						case sfKeyRight:
							_am.update("RIGHT");
							break;
						default:
							break;						
					}
					break;
				default:
					break;
			}
		}
		override void show(sfRenderWindow* window)
		{
			super.show(window);
		}
		override void onCollide(Collidable entity)
		{

			entity.accept(this);
		}
		void visit(Player entity)
		{

		}
		void visit(BlocImmobile entity)
		{
			setPosition(adjust_pos(bounds, entity.bounds, lastMove));
			debug writeln("Collide with BlocImmobile");
		}
		void visit(BlocMobileMath entity)
		{
			entity.move(lastMove);
			if(novelli.containsNumber)
			{
				entity.value = novelli.compute(entity.value, novelli.value);
				novelli.containsNumber = false;
			}
			hasMoved = true;
			debug writeln("Collide with BlocMobileMath.");					
			
		}
		void visit(BlocFonction entity)
		{
			if(entity.novelli.containsNumber)
			{
				novelli = entity.novelli;
				entity.novelli.containsNumber = false;
				novelli.containsNumber = true;
				entity.novelli.containsNumber = false;
				entity.setTextColor(sfWhite);
			}
			hasMoved = true;
		}
		void visit(BlocCheckpoint entity)
		{
			hasMoved = true; // pour etre actif sur le blocmobilemath qui est eventuellement sur le bloc checkpoint
			debug writeln("Collide with BlocCheckpoint");
		}
		void accept(IVisitor v)
		{
			v.visit(this);
		}
		bool isAlive()
		{
			return true;
		}
		@property bool hasMoved()
		{
			return _hasMoved;
		}
		@property void hasMoved(bool b)
		{
			_hasMoved = b;
		}
		mixin makeBounds;
		~this()
		{

		}
	}
}