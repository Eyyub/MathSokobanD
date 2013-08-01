module utils;

import derelict.sfml2.graphics;
import derelict.sfml2.system;
import derelict.sfml2.window;

alias PtrMathFunction = const(int) function(const int val1, const int val2);

class SymbolException : Exception
{
	this(string msg)
	{
		super(msg);
	}
}

auto makePtrMathFunction(string repr)
{
	PtrMathFunction fct;

	string makeSwitchCase(string symbol)
	{
		return "case " ~ `"` ~symbol ~ `"` ~ ": fct = (val1, val2) => val1 " ~ symbol ~ "val2; break;";
	}

	switch(repr)
	{
		mixin(makeSwitchCase("+")); // (val1, val2) => val1 + val2;
		mixin(makeSwitchCase("-")); // (val1, val2) => val1 - val2;
		mixin(makeSwitchCase("*")); // (val1, val2) => val1 * val2;
		mixin(makeSwitchCase("/")); // (val1, val2) => val1 / val2;

		default:
			throw new SymbolException("Unknown symbol : " ~ repr); 
			break;
	}
	return fct;
}

struct brain(T) if(is(T : long))
{
	PtrMathFunction compute;
	T value;
	bool containsNumber = false;
}

enum DirectionMove : string
{
	LEFT = "LEFT",
	RIGHT = "RIGHT",
	UP = "UP",
	DOWN = "DOWN"
}

DirectionMove dirmove(sfVector2f mvt)
{
	if(mvt.x < 0 && mvt.y == 0)
		return DirectionMove.LEFT;
	else if(mvt.x > 0 && mvt.y == 0)
		return DirectionMove.RIGHT;
	else if(mvt.x == 0 && mvt.y < 0)
		return DirectionMove.UP;
	else if(mvt.x == 0 && mvt.y > 0)
		return DirectionMove.DOWN;
	else return DirectionMove.DOWN; //throw new Exception("Unknown direction.");
}

sfVector2f adjust_pos(sfFloatRect box_mvt, sfFloatRect box_col, sfVector2f mvt)
{
	
	switch(cast(string)dirmove(mvt))
	{
		case DirectionMove.LEFT:
			return sfVector2f((box_col.left + box_col.width), box_mvt.top);
			break;
		case DirectionMove.RIGHT:
			return sfVector2f((box_col.left - box_mvt.width), box_mvt.top);
			break;
		case DirectionMove.UP:
			return sfVector2f(box_mvt.left, (box_col.top + box_col.height));
			break;
		case DirectionMove.DOWN:
			return sfVector2f(box_mvt.left,  (box_col.top - box_mvt.height));
			break;
		default:
			break;
	}
	return sfVector2f(0, 0);
}


alias HitBox = sfFloatRect;

bool collision(HitBox a, HitBox b)
{
	if((a.left >= b.left  && a.left + 1 <= b.left + b.width - 1 ||
	   a.left + a.width - 1 >= b.left + 1 && a.left <= b.left) &&
	   (a.top >= b.top && a.top + 1 <= b.top + b.height - 1||
	   a.top <= b.top && a.top + a.height - 1 >= b.top + 1))
		return true;
	else
		return false;
}