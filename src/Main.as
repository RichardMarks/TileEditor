package 
{
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * TileEditor version 0.0.9a
	 * Designed and Developed by Richard Marks
	 * (C) Copyright 2009, CCPS Solutions
	 * http://www.ccpssolutions.com
	 *
	 * Ported to ActionScript 3.0 by Richard Marks
	 * (C) Copyright 2011, Richard Marks
	 *
	 * Disclaimer:
	 *
	 * This program is distributed in the hope that it will be useful,
	 * but WITHOUT ANY WARRANTY; without even the implied warranty of
	 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	 *
	 * @author Richard Marks
	 */
	[Frame(factoryClass="Preloader")]
	public class Main extends Sprite 
	{
		// constants
		static public const DEFAULT_SCREEN_WIDTH:Number = 1024;
		static public const DEFAULT_SCREEN_HEIGHT:Number = 768;
		
		static public const DEFAULT_TILE_WIDTH:Number = 32;
		static public const DEFAULT_TILE_HEIGHT:Number = 32;
		
		static public const DEFAULT_GRID_RESOLUTION_X:Number = 16;
		static public const DEFAULT_GRID_RESOLUTION_Y:Number = 16;
		
		static public const DEFAULT_ZOOM_LEVEL:Number = 4;
		
		static public const TILESZ:Number = 8;
		static public const GRIDRES:Number = 64;
		static public const ZOOM:Number = 6;
		
		static public const HUD_OPAQUE_MODE:Number = 4;
		static public const HUD_TRANSPARENT_MODE:Number = 2;
		static public const EDITACT_DRAW_PIXEL:Number = 0;
		static public const EDITACT_ERASE_PIXEL:Number = 1;
		static public const EDITACT_CLEAR_IMAGE:Number = 2;
		static public const EDITACT_FILL_IMAGE:Number = 3;
		static public const EDITACT_LOAD_IMAGE:Number = 4;
		static public const EDITACT_SAVE_IMAGE:Number = 5;
		static public const EDITACT_TOGGLE_GRID:Number = 6;
		static public const EDITACT_TOGGLE_OPAQUE_MODE:Number = 7;
		static public const EDITACT_SHIFT_PIXELS_UP:Number = 8;
		static public const EDITACT_SHIFT_PIXELS_DOWN:Number = 9;
		static public const EDITACT_SHIFT_PIXELS_LEFT:Number = 10;
		static public const EDITACT_SHIFT_PIXELS_RIGHT:Number = 11;
		static public const EDITACT_COPY_IMAGE:Number = 12;
		static public const EDITACT_PASTE_IMAGE:Number = 13;
		static public const EDITACT_PREVIEW_MODE:Number = 14;
		static public const EDITACT_RANDOM_FILL_IMAGE:Number = 15;
		static public const EDITACT_FLIP_IMAGE:Number = 16;
		static public const EDITACT_MIRROR_IMAGE:Number = 17;
		static public const EDITACT_ROTATE_IMAGE:Number = 18;
		static public const EDITACT_BLUR_IMAGE:Number = 19;
		static public const EDITACT_SCATTER_IMAGE:Number = 20;

		
		
		
		
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
		}

	}

}