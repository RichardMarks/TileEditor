package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

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
		
		
		// globals
		
		// bitmaps
		static public var backBuffer:BitmapData;
		static public var tileImage:BitmapData;
		static public var paletteImage:BitmapData;
		static public var realTileImage:BitmapData;
		static public var gridImage:BitmapData;
		static public var clipboardImage:BitmapData;
		static public var xorPixel:BitmapData;
		
		// areas
		static public var uiCloseButtonRect:Rectangle = new Rectangle(DEFAULT_SCREEN_WIDTH - 24, 8, 16, 16);
		static public var uiFilenameRect:Rectangle = new Rectangle(8, 8, uiCloseButtonRect.x - uiCloseButtonRect.width, uiCloseButtonRect.height);
		static public var tileEditPanelRect:Rectangle = new Rectangle(8, 32, TILESZ * GRIDRES, TILESZ * GRIDRES);
		static public var paletteBlockSize:Number = Math.floor(tileEditPanelRect.width / 32);
		static public var palettePanelRect:Rectangle = new Rectangle(8, 8 + tileEditPanelRect.y + tileEditPanelRect.height, 32 * paletteBlockSize, 8 * paletteBlockSize);
		static public var zoomTileRect:Rectangle = new Rectangle(8 + tileEditPanelRect.x + tileEditPanelRect.width, tileEditPanelRect.y, TILESZ * ZOOM, TILESZ * ZOOM);
		static public var clipboardTileRect:Rectangle = new Rectangle(8 + zoomTileRect.x + zoomTileRect.width, tileEditPanelRect.y, TILESZ * ZOOM, TILESZ * ZOOM);
		static public var infoPanelRect:Rectangle = new Rectangle(zoomTileRect.x, 8 + zoomTileRect.y + zoomTileRect.height, DEFAULT_SCREEN_WIDTH - (zoomTileRect.x + 8), 128);
		static public var uiTranspButtonRect:Rectangle = new Rectangle(DEFAULT_SCREEN_WIDTH - 24, DEFAULT_SCREEN_HEIGHT - 24, 16, 16);
		static public var uiStatusBarRect:Rectangle = new Rectangle(8, DEFAULT_SCREEN_HEIGHT - 24, uiTranspButtonRect.x - uiTranspButtonRect.width, uiTranspButtonRect.height);
		
		// tile data array
		static public var tileData:Vector.<Number> = new Vector.<Number>((TILESZ + (TILESZ * TILESZ)));
		
		// misc colors
		static public var drawColor:Number = 15;
		static public var gridColor:Number = 15;
		static public var hudColor:Number = HUD_OPAQUE_MODE;
		
		// mode toggles
		static public var showGrid:Number = 1;
		static public var opaqueDrawing:Number = 1;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			// create bitmap buffers
			backBuffer = new BitmapData(DEFAULT_SCREEN_WIDTH, DEFAULT_SCREEN_HEIGHT, true, 0xFF000000);
			realTileImage = new BitmapData(TILESZ, TILESZ, true, 0xFF000000);
			tileImage = new BitmapData(tileEditPanelRect.width, tileEditPanelRect.height, true, 0xFF000000);
			paletteImage = new BitmapData(palettePanelRect.width, palettePanelRect.height, true, 0xFF000000);
			gridImage = new BitmapData(tileImage.width, tileImage.height, true, 0xFF000000);
			clipboardImage = new BitmapData(TILESZ, TILESZ, true, 0xFF000000);
			xorPixel = new BitmapData(GRIDRES, GRIDRES, true, 0xFF000000);
			
			// draw the xorpixel texture
			for (var x:Number = 0; x < xorPixel.width; x++)
			{
				for (var y:Number = 0; y < xorPixel.height; y++)
				{
					var c:uint = 8 * (x ^ y);
					xorPixel.setPixel(x, y, AL.makecol(c, c, c));
				}
			}
			
			// draw the panels
			RedrawTheTile(tileImage);
			RedrawThePalette(paletteImage);
			RedrawTheGrid(gridImage);
			
			addEventListener(Event.ENTER_FRAME, MainLoop);
			addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
			addEventListener(KeyboardEvent.KEY_UP, OnKeyUp);
			addEventListener(MouseEvent.CLICK, OnMouseClick);
			
			addChild(new Bitmap(backBuffer, PixelSnapping.NEVER));
		}
		
		private function MainLoop(e:Event):void
		{
			
		}
	}
}