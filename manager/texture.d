module manager.texture;

import std.stdio;
import std.exception;
import std.format;
import std.string;

import derelict.sfml2.graphics;
import derelict.sfml2.system;
import derelict.sfml2.window;

alias TextureName = string;
alias TextureFilename = string;

class TextureManagerException : Exception
{
	public
	{
		this(string msg)
		{
			super(msg);
		}
	}
}

final class TextureManager
{
	private
	{
		sfTexture*[TextureName] _textures;
		TextureName[] _keys;
	}
	public
	{
		this(string textures_filename)
		{
			auto file = File(textures_filename, "r");
			scope(exit) file.close();
			enforce(file.isOpen, textures_filename ~ "can't be open.");

			foreach(line; file.byLine)
			{
				TextureName name;
				TextureFilename filename;
				enforce(line.formattedRead("%s=%s", &name, &filename) == 2, "Wrong description format.");
				
				_keys ~= name;
				_textures[name] = sfTexture_createFromFile(filename.toStringz(), null);
				enforce(_textures[name] !is null, "Texture creation %s has failed.".format(name)); 
			}

		}
		auto opIndex(TextureName key)
		{
			if(key in _textures)
				return _textures[key];
			else
				throw new TextureManagerException("Key %s was not found in _textures".format(key)); 
		}
		~this()
		{
			
			foreach(key; _keys)
			{
				sfTexture_destroy(_textures[key]);
			}
			destroy(_textures);
		}
	}
}