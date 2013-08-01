module manager.save;

import std.stdio;
import std.exception;
import std.format;
import std.string;

class SaveManager
{
	private
	{
		string _filename;
		uint _currentLevel;
		uint _totalMove;
	}
	public
	{
		this(string filename)
		{
			_filename = filename;

			auto file = File(_filename, "r");
			scope(exit) file.close();

			enforce(file.isOpen, "Wrong save-filename : %d .".format(_filename));

			foreach(line; file.byLine)
			{
				string buf;
				formattedRead(line, "currentLevel=%d;totalMove=%d", &_currentLevel, &_totalMove);
			}
		}
		void save(uint index)
		{
			auto file = File(_filename, "w");
			scope(exit) file.close();

			_currentLevel = index;
			file.writef("currentLevel=%d;totalMove=%d", _currentLevel, _totalMove);
		}
		@property uint currentLevel()
		{
			return _currentLevel;
		}
		~this()
		{

		}
	}
}