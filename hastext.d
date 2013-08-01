module hastext;

import std.exception;

import derelict.sfml2.graphics;
import derelict.sfml2.system;
import derelict.sfml2.window;

interface HasText
{
	private
	{
		void initText(string toShow, string font_name = "arial.ttf", sfColor color = sfWhite, uint char_size = 25);
		void setTextPosition(sfVector2f pos);
		void setTextColor(sfColor color);
		void drawText(sfRenderWindow* window);
		void destroyText();
	}
}

mixin template ImplHasText()
{
	protected
	{
		import std.string : toStringz;

		sfText* _text;

		void initText(string toShow, string font_name = "arial.ttf", sfColor color = sfWhite, uint char_size = 25)
		{
			_text = sfText_create();
			enforce(_text !is null, "Was not able to init sfText* _text.");
			sfText_setString(_text, toShow.toStringz());
			sfText_setFont(_text, sfFont_createFromFile(font_name.toStringz()));
			sfText_setColor(_text, color);
			sfText_setCharacterSize(_text, char_size);			
		}
		void setTextPosition(sfVector2f pos)
		{
			auto bounds = getGlobalBounds();
			auto text_bounds = sfText_getGlobalBounds(_text);
			sfVector2f text_pos;
			text_pos.x = pos.x + (bounds.width - text_bounds.width)/2;
			text_pos.y = pos.y + (bounds.height - text_bounds.height)/2 - bounds.height/5;
			sfText_setPosition(_text, text_pos);			
		}
		void setString(string str)
		{
			sfText_setString(_text, str.toStringz());
		}
		void drawText(sfRenderWindow* window)
		{
			sfRenderWindow_drawText(window, _text, null);
		}
		void destroyText()
		{
			sfText_destroy(_text);
			destroy(_text);
		}
	}
	public
	{
		void setTextColor(sfColor color)
		{
			sfText_setColor(_text, color);
		}
	}
}