module manager.collision;

import std.stdio;
import std.exception;
import std.string;
import std.container;

import derelict.sfml2.graphics;
import derelict.sfml2.system;
import derelict.sfml2.window;

import sprite;
import bloc;
import player;
import utils;

alias CollidableArray = Array!Collidable;

final class CollisionManager
{
	private
	{
		CollidableArray _entities;
		bool _isCleared;
	}
	public
	{
		this()
		{
			_entities = CollidableArray();
		}
		void insert(Collidable entity)
		{
			_entities.insert(entity);
		}		
		void update()
		{
			
			BlocCheckpoint[] checkpoints;
			foreach(entity; _entities)
			{
				if(typeid(cast(Object)entity) == typeid(BlocCheckpoint))
					checkpoints ~= (cast(BlocCheckpoint)entity); 
			}

			_isCleared = true;
			foreach(checkpoint; checkpoints)
				if(!checkpoint.isChecked)
					_isCleared = false;

			checkpoints = null;
			enforce(checkpoints is null, "checkpoints array is not null.");

			if(!isCleared)
			{	
				for(uint i = 0; i < 4; ++i)
				{
					foreach(entity1; _entities)
					{
						foreach(entity2; _entities)
						{
							if(entity1 is entity2 || !entity1.isAlive || !entity2.isAlive)
								continue;
							if(collision(entity1.bounds, entity2.bounds))
							{

								auto actif = entity1.hasMoved ? entity1 : entity2;
								auto passif = actif is entity1 ? entity2 : entity1;

								actif.hasMoved = false;
								actif.onCollide(passif);
								
								if(typeid(cast(Object)actif) != typeid(BlocImmobile))
									debug writefln("\nType actif : %s | Type passif : %s.\n", typeid(cast(Object)actif), typeid(cast(Object)passif));

							}
						}
					}

				}
			}


		}
		@property bool isCleared()
		{
			return _isCleared;
		}		
		~this()
		{
			_entities.clear();
		}
	}
}