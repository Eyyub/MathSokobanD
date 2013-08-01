module bloc;

import std.stdio;
import std.string;
import std.exception;
import std.container;

import derelict.sfml2.graphics;
import derelict.sfml2.system;
import derelict.sfml2.window;

import sprite;
import hastext;
import utils;
import visitor;
import player;


class BlocImmobile : Sprite, Collidable, IVisitor
{
	protected
	{
		bool _hasMoved = false;
	}
	public
	{
		
		this(const sfTexture* texture, sfVector2f pos, sfBool resetRect = sfTrue)
		{
			super(texture, pos, resetRect);
		}
		void onCollide(Collidable entity)
		{
			entity.accept(this);
		}
		void visit(Player entity)
		{
			entity.setPosition(adjust_pos(entity.bounds, bounds, entity.lastMove));
			debug writeln("Collide with Player -- BlocImmobile.");
		}
		void visit(BlocImmobile entity)
		{

		}
		void visit(BlocMobileMath entity)
		{
			debug writeln("Collision with BlocMobileMath -- BlocImmobile.");
			entity.setPosition(adjust_pos(entity.bounds, bounds, entity.lastMove));
			
		}
		void visit(BlocFonction entity)
		{

		}
		void visit(BlocCheckpoint entity)
		{

		}		
		void accept(IVisitor v)
		{
			v.visit(this);
		}
		@property bool isAlive()
		{
			return true;
		}
		@property bool hasMoved()
		{
			return false;
		}
		@property void hasMoved(bool b)
		{
			_hasMoved = false;
		}
		mixin makeBounds;
	}
}

class BlocMobileMath : MoveableAnimatedSprite, Collidable, IVisitor, HasText
{
	private
	{
		mixin ImplHasText;

		int _value;
		bool _isDie = false;
		bool _isOnCheckpoint = false;
		sfColor _isOnCheckpointColor;	

		void moveText(sfVector2f mouvement)
		{
			sfText_move(_text, mouvement);
		}
	}
	public
	{
		this(const int value, sfTexture* texture, string animations_json_filename, sfVector2f pos, sfBool resetRect = sfTrue, sfColor isOnCheckpointColor = sfGreen)
		{
			_value = value;
			_isOnCheckpointColor = isOnCheckpointColor;
			super(texture, animations_json_filename, ["ALIVE", "DYING"], pos, resetRect);
			initText("%d".format(_value));
			sfSprite_setTextureRect(_sprite, sfIntRect(0, 0, 32, 32));
			setTextPosition(pos);
			_am.update("ALIVE");
		}
		override void move(sfVector2f mouvement)
		{
			moveText(mouvement);
			super.move(mouvement);
		}
		override void show(sfRenderWindow* window)
		{
			if(!_isDie)
			{
				if(_isOnCheckpoint)
				{
					setTextColor(_isOnCheckpointColor);
				}
				else
				{
					setTextColor(sfWhite);
				}
				_am.update("ALIVE");
				
				super.show(window);
				drawText(window);
			}
			else
			{
				if(_am.currentAnim.width != 0 && _am.currentAnim.height != 0)
					_am.update("DYING", sfSeconds(0.10f));
				
				super.show(window);
			}

		}
		override void setPosition(sfVector2f newpos)
		{
			setTextPosition(newpos);
			super.setPosition(newpos);
		}
		void onCollide(Collidable entity)
		{
			entity.accept(this);
		}
		mixin makeBounds;
		void visit(Player entity)
		{
			entity.setPosition(adjust_pos(entity.bounds, bounds, entity.lastMove));

			debug writeln("Collide with Player.");
		}
		void visit(BlocImmobile entity)
		{
			debug writeln("Collision with BlocImmobile -- BlocMobileMath.");
			setPosition(adjust_pos(bounds, entity.bounds, lastMove));
			hasMoved = true; // cause we moved one once
		}
		void visit(BlocMobileMath entity)
		{
			setPosition(adjust_pos(bounds, entity.bounds, lastMove));
			hasMoved = true; // cause we moved one once
			debug writeln("Me : x %0.f, y %0.f val %d | Him : x %0.f, y %0.f val %d".format(bounds.left, bounds.top, _value, entity.bounds.left, entity.bounds.top, entity.value));
		}
		void visit(BlocFonction entity)
		{

		}
		void visit(BlocCheckpoint entity)
		{
			sfFloatRect coeur;
			debug writeln("Collide with BlocCheckpoint.");
			coeur.left = entity.bounds.left + (entity.bounds.width/3);
			coeur.width = entity.bounds.width/3;
			coeur.top = entity.bounds.top + entity.bounds.height/3;
			coeur.height = entity.bounds.height/3;

			_isOnCheckpoint = false;

			if(collision(bounds, coeur) && entity.value == _value)
			{
				_isOnCheckpoint = true;
				entity.isChecked = true;	
			}			
		}
		void accept(IVisitor v)
		{
			v.visit(this);
		}
		void die()
		{
			_isDie = true;
		}
		@property bool isAlive()
		{
			return _isDie ? false : true;
		}
		@property bool hasMoved()
		{
			return _hasMoved;
		}
		@property void hasMoved(bool b)
		{
			_hasMoved = b;
		}
		@property void isOnCheckpoint(bool b)
		{
			_isOnCheckpoint = b;
		}
		@property bool isOnCheckpoint()
		{
			return _isOnCheckpoint;
		}
		@property int value()
		{
			return _value;
		}
		@property void value(int newval)
		{
			_value = newval;
			setString("%d".format(_value));
		}
		~this()
		{
			destroyText();
		}
	}
}

alias PtrMathFunction = const(int) function(const int val1, const int val2);

class BlocFonction : BlocImmobile, HasText
{
	private
	{
		mixin ImplHasText;

		PtrMathFunction _fct;
		brain!int _novelli;		
	}
	public
	{
		

		this(PtrMathFunction fct, string toShow, const sfTexture* texture, sfVector2f pos, sfBool resetRect = sfTrue)
		{
			_fct = fct;
			super(texture, pos, resetRect);
			initText(toShow);
			setTextPosition(pos);
		}
		override void show(sfRenderWindow* window)
		{
			super.show(window);
			drawText(window);
		}
		override void accept(IVisitor visitor)
		{
			visitor.visit(this);
		}
		override void visit(Player entity)
		{

		}
		override void visit(BlocImmobile entity)
		{
			
		}
		override void visit(BlocMobileMath entity)
		{
			novelli.compute = _fct;
			novelli.value = entity.value;
			novelli.containsNumber = true;
			setTextColor(sfBlack);
			entity.die();
		}
		override void visit(BlocFonction entity)
		{
			
		}
		override void visit(BlocCheckpoint entity)
		{
			
		}
		@property auto ref novelli()
		{
			return _novelli;
		}
		~this()
		{
			destroyText();
			destroy(_fct);
		}
	}
}

class BlocCheckpoint : BlocImmobile,  HasText
{
	private
	{
		mixin ImplHasText;
		const int _value;
		bool _isChecked = false;
	}
	public
	{
		this(const int value, sfTexture* texture, sfVector2f pos, sfBool resetRect = sfTrue)
		{
			_value = value;
			super(texture, pos, resetRect);
			initText("%d".format(_value));
			setTextPosition(pos);
		}
		override void show(sfRenderWindow* window)
		{
			super.show(window);
			drawText(window);
		}
		override void accept(IVisitor v)
		{
			v.visit(this);
		}
		override void visit(BlocImmobile entity)
		{

		}
		override void visit(Player entity)
		{
			debug writeln("Collide with Player -- Checkpoint.");
		}
		override void visit(BlocMobileMath entity)
		{

		}
		override void visit(BlocFonction entity)
		{

		}
		override void visit(BlocCheckpoint entity)
		{

		}			
		@property const int value()
		{
			return _value;
		}
		@property bool isChecked()
		{
			return _isChecked;
		}
		@property void isChecked(bool b)
		{
			_isChecked = b;
		}
		~this()
		{
			destroyText();
		}
	}
}


