module main;

import std.stdio;
import std.conv;
import std.string;


import derelict.sfml2.graphics;
import derelict.sfml2.system;
import derelict.sfml2.window;
import derelict.sfml2.audio;
import game;


void main()
{
    DerelictSFML2Graphics.load(); // l'unload est automatique
	DerelictSFML2System.load();
	DerelictSFML2Window.load();
	
	char[] filename = "parties\\".dup;

	menu(filename);
	
	if(filename != "")
	{
		auto sokoban = new Game("Math Sokoban", 704, 608, 32, "mapsfilename.txt", filename.idup, "textures_filename.txt", "music.ogg", ["player" : "prof_animations.json", "bloc_mobile_math" : "blocmath_anims.json"]);
		scope(exit) destroy(sokoban);


		sokoban.run();
	}


}

void menu(ref char[] filename)
{
	writeln("Welcome to Math Sokoban.");
	writeln("1 - New game ?");
	writeln("2 - Continue ?");
	writeln("3 - Print scenario.");
	writeln("4 - Leave.");
	writeln("Choose : ");

	uint buffer;
	readf("%d\n", &buffer);

	uint choice = buffer;

	switch(choice)
	{
		case 1:
			newgame(filename);
			break;
		case 2:
			continue_(filename);
			break;
		case 3:
			print_scenario();
			break;
		case 4:
			break;
		default:
			break;
	}
}

void newgame(ref char[] filename)
{
	writeln("Type your name please : ");
	string name;
	readf(" %s\n", &name);

	writefln("Thanks, the name of your new game is %s.", name);
	writeln("Don't forgot it.");
	filename ~= name ~ ".txt";
	File(filename.idup, "w").close();
}

void continue_(ref char[] filename)
{
	writeln("Type the name of your game please : ");
	string name;
	readf("%s\n", &name);
	writeln("Thanks.");
	filename ~= name ~ ".txt";
}

void print_scenario()
{

}
