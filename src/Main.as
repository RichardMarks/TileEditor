package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.flashpunk.utils.Key;

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
		
		static public const TILESZ:Number = 32;//8;
		static public const GRIDRES:Number = 16;//64;
		static public const ZOOM:Number = 4;//6;
		
		static public const HUD_OPAQUE_MODE:Number = AL.PALETTE256[4];
		static public const HUD_TRANSPARENT_MODE:Number = AL.PALETTE256[2];
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
		static public var drawColor:Number = AL.PALETTE256[15];
		static public var gridColor:Number = AL.PALETTE256[15];
		static public var hudColor:Number = HUD_OPAQUE_MODE;
		
		// mode toggles
		static public var showGrid:Boolean = true;
		static public var opaqueDrawing:Number = 1;
		
		// cpu saver
		private var renderNeeded:Boolean = true;
		
		// fluid drawing
		private var penOn:Boolean = false;
		
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
			gridImage = new BitmapData(tileImage.width, tileImage.height, true, 0x00000000);
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
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, OnKeyUp);
			stage.addEventListener(MouseEvent.CLICK, OnMouseClick);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
			
			addChild(new Bitmap(backBuffer, PixelSnapping.NEVER));
		}
		
		private function OnMouseMove(e:MouseEvent):void
		{
			var mouseX:Number = e.stageX;
			var mouseY:Number = e.stageY;
			
			if (e.buttonDown)
			{
				// tile editor panel
				if (tileEditPanelRect.contains(mouseX, mouseY))
				{
					if (e.altKey) { DoEditorAction(EDITACT_ERASE_PIXEL); }
					else { DoEditorAction(EDITACT_DRAW_PIXEL); }
				}
			}
		}
		
		private function OnKeyDown(e:KeyboardEvent):void 
		{
			// handle keyboard input
			
			switch (e.keyCode)
			{
				case Key.F8: { DoEditorAction(EDITACT_PREVIEW_MODE); } break;
				
				case Key.LEFT: 
				{ 
					if (e.ctrlKey) { DoEditorAction(EDITACT_SHIFT_PIXELS_LEFT); } 
					else if (e.shiftKey) { DoEditorAction(EDITACT_MIRROR_IMAGE); }
				} break;
				
				case Key.RIGHT: 
				{ 
					if (e.ctrlKey) { DoEditorAction(EDITACT_SHIFT_PIXELS_RIGHT); } 
					else if (e.shiftKey) { DoEditorAction(EDITACT_MIRROR_IMAGE); }
				} break;
				
				case Key.UP: 
				{ 
					if (e.ctrlKey) { DoEditorAction(EDITACT_SHIFT_PIXELS_UP); } 
					else if (e.shiftKey) { DoEditorAction(EDITACT_FLIP_IMAGE); }
				} break;
				
				case Key.DOWN: 
				{ 
					if (e.ctrlKey) { DoEditorAction(EDITACT_SHIFT_PIXELS_DOWN); } 
					else if (e.shiftKey) { DoEditorAction(EDITACT_FLIP_IMAGE); }
				} break;
				
				
				
				case Key.T: { DoEditorAction(EDITACT_TOGGLE_OPAQUE_MODE); } break;
				case Key.F: { DoEditorAction(EDITACT_FILL_IMAGE); } break;
				case Key.G: { DoEditorAction(EDITACT_TOGGLE_GRID); } break;
				case Key.N: { DoEditorAction(EDITACT_CLEAR_IMAGE); } break;
				case Key.S: { DoEditorAction(EDITACT_SAVE_IMAGE); } break;
				case Key.L: { DoEditorAction(EDITACT_LOAD_IMAGE); } break;
				case Key.R: { DoEditorAction(EDITACT_RANDOM_FILL_IMAGE); } break;
				
				case Key.TILDE: { DoEditorAction(EDITACT_ROTATE_IMAGE); } break;
				case Key.DIGIT_1: { DoEditorAction(EDITACT_BLUR_IMAGE); } break;
				case Key.DIGIT_2: { DoEditorAction(EDITACT_SCATTER_IMAGE); } break;
				
				default:break;
			}
		}
		
		private function OnKeyUp(e:KeyboardEvent):void 
		{ 
			switch (e.keyCode)
			{
				case Key.C: { if (e.ctrlKey) { DoEditorAction(EDITACT_COPY_IMAGE); } } break;
				case Key.V: { if (e.ctrlKey) { DoEditorAction(EDITACT_PASTE_IMAGE); } } break;
				default:break;
			}
		}
		
		private function OnMouseClick(e:MouseEvent):void 
		{ 
			//trace("mouse click at", e.stageX, ",", e.stageY);
			
			// handle mouse input
			var mouseX:Number = e.stageX;
			var mouseY:Number = e.stageY;
			
			// tile editor panel
			if (tileEditPanelRect.contains(mouseX, mouseY))
			{
				if (e.altKey) { DoEditorAction(EDITACT_ERASE_PIXEL); }
				else { DoEditorAction(EDITACT_DRAW_PIXEL); }
			}
			// color palette panel
			else if (palettePanelRect.contains(mouseX, mouseY))
			{
				drawColor = paletteImage.getPixel32(mouseX - palettePanelRect.x, mouseY - palettePanelRect.y);
				RedrawThePalette(paletteImage);
				renderNeeded = true;
			}
			// close button
			else if (uiCloseButtonRect.contains(mouseX, mouseY))
			{
				// do nothing for now
			}
			// toggle transparent mode
			else if (uiTranspButtonRect.contains(mouseX, mouseY))
			{
				DoEditorAction(EDITACT_TOGGLE_OPAQUE_MODE);
			}
		}
		
		private function MainLoop(e:Event):void
		{
			if (!renderNeeded)
			{
				return;
			}
			renderNeeded = false;
			
			// render
			
			// draw clipboard buffer
			AL.stretch_blit(clipboardImage, backBuffer, clipboardImage.rect, clipboardTileRect);
			
			// draw zoomed tile
			AL.stretch_blit(realTileImage, backBuffer, realTileImage.rect, zoomTileRect);
			
			
			// draw edited tile
			backBuffer.copyPixels(tileImage, tileImage.rect, new Point(tileEditPanelRect.x, tileEditPanelRect.y));
			
			// draw palette
			backBuffer.copyPixels(paletteImage, paletteImage.rect, new Point(palettePanelRect.x, palettePanelRect.y));
			
			// draw grid
			if (showGrid)
			{
				backBuffer.draw(gridImage, 
					new Matrix(1, 0, 0, 1, tileEditPanelRect.left, tileEditPanelRect.top), 
					null, BlendMode.NORMAL, null, false);
			}
		
			// draw hud (the frames that go around every panel
			UIDrawFrame(tileEditPanelRect);
			UIDrawFrame(palettePanelRect);
			UIDrawFrame(zoomTileRect);
			UIDrawFrame(clipboardTileRect);
			UIDrawFrame(infoPanelRect);
			UIDrawFrame(uiCloseButtonRect);
			UIDrawFrame(uiFilenameRect);
			UIDrawFrame(uiTranspButtonRect);
			UIDrawFrame(uiStatusBarRect);
			
			
			// textprintf_ex(doublebuffer, font, ui_transp_button_rect[0] + 5, ui_transp_button_rect[1] + 5, hud_color, -1, (opaque_drawing==1)?"T":"O");
			
			
			// draw the status bar
			
			
			/*
		
		
		{
			int x = ui_status_bar_rect[0] + 4;
			int y = ui_status_bar_rect[1] + 4;
			
			if (ptinrect(mouse_x, mouse_y, tile_edit_panel_rect))
			{
				int mousex = mouse_x - tile_edit_panel_rect[0];
				int mousey = mouse_y - tile_edit_panel_rect[1];
				int mx = (int)mousex / GRIDRES;
				int my = (int)mousey / GRIDRES;
				
				int p_color = getpixel(realtileimage, mx, my);
				
				//textprintf_ex(doublebuffer, font, x, y, makecol(255,255,255), -1, " X %02d Y %02d   Drawing Color %03d   Pixel Color %03d", mx, my, draw_color, getpixel(realtileimage, mx, my));
				textprintf_ex(doublebuffer, font, x, y, makecol(255,255,255), -1, " X %02d Y %02d   Drawing Color %03d RGB(%03d, %03d, %03d)   Pixel Color %03d RGB(%03d, %03d, %03d)", mx, my, 
				draw_color, getr(draw_color), getg(draw_color), getb(draw_color), 
				p_color, getr(p_color), getg(p_color), getb(p_color));
			}
			else if (ptinrect(mouse_x, mouse_y, palette_panel_rect))
			{
				// mouse is over the color palette panel
				int p_color = getpixel(paletteimage, mouse_x-palette_panel_rect[0], mouse_y-palette_panel_rect[1]);
				textprintf_ex(doublebuffer, font, x, y, makecol(255,255,255), -1, " Click the Left Mouse Button to Select Palette Value %03d RGB(%03d, %03d, %03d)", p_color, getr(p_color), getg(p_color), getb(p_color));
			}
			else if (ptinrect(mouse_x, mouse_y, ui_transp_button_rect))
			{
				textprintf_ex(doublebuffer, font, x, y, makecol(255,255,255), -1, " Click the Left Mouse Button to Select %s Drawing Mode", (opaque_drawing==1)?"Transparent":"Opaque");
			}
			else if (ptinrect(mouse_x, mouse_y, ui_close_button_rect))
			{
				textprintf_ex(doublebuffer, font, x, y, makecol(255,255,255), -1, " Click the Left Mouse Button to Close the program. Unsaved changes will be lost!");
			}
			
		}
		
			*/
		
			AL.rect(backBuffer, 0, 0, DEFAULT_SCREEN_WIDTH - 1, DEFAULT_SCREEN_HEIGHT - 1, hudColor);
			AL.rect(backBuffer, 1, 1, DEFAULT_SCREEN_WIDTH - 2, DEFAULT_SCREEN_HEIGHT - 2, hudColor);
		}
		
		// functions
		
		private function SetTileData(x:uint, y:uint, value:uint):void
		{
			//trace("SetTileData(" + x + ", " + y + ", " + value + ");");
			
			tileData[x + (y * TILESZ)] = value;
		}
		
		private function GetTileData(x:uint, y:uint):uint
		{
			return tileData[x + (y * TILESZ)];
		}
		
		private function RedrawTheGrid(b:BitmapData):void
		{
			for (var i:Number = 0; i < TILESZ; i++)
			{
				AL.line(b, 0, i * GRIDRES, b.width, i * GRIDRES, gridColor);
				AL.line(b, i * GRIDRES, 0, i * GRIDRES, b.height, gridColor);
			}
		}
		
		private function RedrawTheTile(b:BitmapData):void
		{
			var rect:Rectangle = new Rectangle;
			rect.width = GRIDRES;
			rect.height = GRIDRES;
			for (var y:Number = 0; y < TILESZ; y++)
			{
				rect.y = y * GRIDRES;
				for (var x:Number = 0; x < TILESZ; x++)
				{
					rect.x = x * GRIDRES;
					var pixelColor:Number = GetTileData(x, y);
					b.fillRect(rect, pixelColor);
					if (!opaqueDrawing && pixelColor == AL.PALETTE256[0])
					{
						b.copyPixels(xorPixel, xorPixel.rect, new Point(rect.x, rect.y));
					}
				}
			}
		}
		
		private function RedrawThePalette(b:BitmapData):void
		{
			var rect:Rectangle = new Rectangle;
			var palY:Number = 0;
			var y:Number = 0;
			
			var selRect:Rectangle = null;
			
			for (var n:Number = 0; n < 8; n++)
			{
				for (var x:Number = 0; x < 32; x++)
				{
					var color:Number = AL.PALETTE256[x + (palY * 32)];
					
					rect.x = x * paletteBlockSize;
					rect.y = y;
					rect.width = paletteBlockSize;
					rect.height = paletteBlockSize;
					
					b.fillRect(rect, color);
					if (drawColor == color)
					{
						selRect = rect.clone();
						selRect.inflate(1, 1);
					}
				}
				y += paletteBlockSize;
				palY++;
			}
			
			if (selRect)
			{
				AL.rect(b, selRect.x, selRect.y, selRect.right, selRect.bottom, AL.PALETTE256[0]);
				selRect.inflate(-1, -1);
				AL.rect(b, selRect.x, selRect.y, selRect.right, selRect.bottom, AL.PALETTE256[0]);
			}
		}
		
		private function SynchronizeEditorWithTile():void
		{
			for (var y:Number = 0; y < realTileImage.height; y++)
			{
				for (var x:Number = 0; x < realTileImage.width; x++)
				{
					var pixelColor:uint = realTileImage.getPixel32(x, y);
					SetTileData(x, y, pixelColor);
				}
			}
			RedrawTheTile(tileImage);
		}
		
		private function ToolShiftPixelsLeft():void
		{
			/* 
			[0][1][2][3][4][5]    [1][2][3][4][5][0]
			[a][b][c][d][e][f] to [b][c][d][e][f][a] 
			*/
			for (var y:Number = 0; y < TILESZ; y++)
			{
				var t:uint = realTileImage.getPixel32(0, y);
				for (var x:Number = 0; x < TILESZ - 1; x++)
				{
					realTileImage.setPixel32(x, y, realTileImage.getPixel32(x + 1, y));
				}
				realTileImage.setPixel32(TILESZ - 1, y, t);
			}
			SynchronizeEditorWithTile();
		}
		
		private function ToolShiftPixelsRight():void
		{
			/*
			[0][1][2][3][4][5]    [5][0][1][2][3][4]
			[a][b][c][d][e][f] to [f][a][b][c][d][e]
			*/
			for (var y:Number = 0; y < TILESZ; y++)
			{
				var t:uint = realTileImage.getPixel32(TILESZ - 1, y);
				for (var x:Number = TILESZ - 1; x > 0; x--)
				{
					realTileImage.setPixel32(x, y, realTileImage.getPixel32(x - 1, y));
				}
				realTileImage.setPixel32(0, y, t);
			}
			SynchronizeEditorWithTile();
		}
		
		private function ToolShiftPixelsUp():void
		{
			/*
			[a][0]    [b][1]
			[b][1]    [c][2]
			[c][2] to [d][3]
			[d][3]    [e][4]
			[e][4]    [f][5]
			[f][5]    [a][0]
			*/
			for (var x:Number = 0; x < TILESZ; x++)
			{
				var t:uint = realTileImage.getPixel32(x, 0);
				for (var y:Number = 0; y < TILESZ - 1; y++)
				{
					realTileImage.setPixel32(x, y, realTileImage.getPixel32(x, y + 1));
				}
				realTileImage.setPixel32(x, TILESZ - 1, t);
			}
			SynchronizeEditorWithTile();
		}
		
		private function ToolShiftPixelsDown():void
		{
			/*
			[a][0]    [f][5]
			[b][1]    [a][0]
			[c][2] to [b][1]
			[d][3]    [c][2]
			[e][4]    [d][3]
			[f][5]    [e][4]
			*/
			for (var x:Number = 0; x < TILESZ; x++)
			{
				var t:uint = realTileImage.getPixel32(x, TILESZ - 1);
				for (var y:Number = TILESZ - 1; y > 0; y--)
				{
					realTileImage.setPixel32(x, y, realTileImage.getPixel32(x, y - 1));
				}
				realTileImage.setPixel32(x, 0, t);
			}
			SynchronizeEditorWithTile();
		}
		
		private function DoEditorAction(action:Number):void 
		{
			// no action specified, just exit now
			if (action < 0) { return; }
			
			switch(action)
			{
				case EDITACT_DRAW_PIXEL: { EditActDrawPixel(); } break;
				case EDITACT_ERASE_PIXEL: { EditActErasePixel(); } break;
				case EDITACT_CLEAR_IMAGE: { EditActClearImage(); } break;
				case EDITACT_FILL_IMAGE: { EditActFillImage(); } break;
				case EDITACT_LOAD_IMAGE: { EditActLoadImage(); } break;
				case EDITACT_SAVE_IMAGE: { EditActSaveImage(); } break;
				case EDITACT_TOGGLE_GRID: { EditActToggleGrid(); } break;
				case EDITACT_TOGGLE_OPAQUE_MODE: { EditActToggleOpaqueMode(); } break;
				case EDITACT_SHIFT_PIXELS_UP: { EditActShiftPixelsUp(); } break;
				case EDITACT_SHIFT_PIXELS_DOWN: { EditActShiftPixelsDown(); } break;
				case EDITACT_SHIFT_PIXELS_LEFT: { EditActShiftPixelsLeft(); } break;
				case EDITACT_SHIFT_PIXELS_RIGHT: { EditActShiftPixelsRight(); } break;
				case EDITACT_COPY_IMAGE: { EditActCopyImage(); } break;
				case EDITACT_PASTE_IMAGE: { EditActPasteImage(); } break;
				case EDITACT_PREVIEW_MODE: { EditActPreviewMode(); } break;
				case EDITACT_RANDOM_FILL_IMAGE: { EditActRandomFillImage(); } break;
				case EDITACT_FLIP_IMAGE: { EditActFlipImage(); } break;
				case EDITACT_MIRROR_IMAGE: { EditActMirrorImage(); } break;
				case EDITACT_ROTATE_IMAGE: { EditActRotateImage(); } break;
				case EDITACT_BLUR_IMAGE: { EditActBlurImage(); } break;
				case EDITACT_SCATTER_IMAGE: { EditActScatterImage(); } break;
				default:
				{
					throw new Error("Unknown action: " + action);
				} break;
			}
			
			renderNeeded = true;
		}
		
		private function EditActDrawPixel():void 
		{
			var mouseX:Number = stage.mouseX - tileEditPanelRect.left;
			var mouseY:Number = stage.mouseY - tileEditPanelRect.top;
			var mx:Number = int(mouseX / GRIDRES);
			var my:Number = int(mouseY / GRIDRES);
			
			//trace("EditActDrawPixel","mouseX=",mouseX,"mouseY=",mouseY,"mx=",mx,"my=",my,"drawColor=",drawColor);
			
			SetTileData(mx, my, drawColor);
			RedrawTheTile(tileImage);
			realTileImage.setPixel32(mx, my, drawColor);
			//SynchronizeEditorWithTile();
		}
		
		private function EditActErasePixel():void 
		{ 
			var mouseX:Number = stage.mouseX - tileEditPanelRect.left;
			var mouseY:Number = stage.mouseY - tileEditPanelRect.top;
			var mx:Number = int(mouseX / GRIDRES);
			var my:Number = int(mouseY / GRIDRES);
			SetTileData(mx, my, AL.PALETTE256[0]);
			RedrawTheTile(tileImage);
			realTileImage.setPixel32(mx, my, AL.PALETTE256[0]);
		}
		
		private function EditActClearImage():void 
		{ 
			realTileImage.fillRect(realTileImage.rect, AL.PALETTE256[0]);
			SynchronizeEditorWithTile();
		}
		
		private function EditActFillImage():void 
		{ 
			realTileImage.fillRect(realTileImage.rect, drawColor);
			SynchronizeEditorWithTile();
		}
		
		private function EditActLoadImage():void 
		{ 
			/*// load
	//char path[80 * 8];
	//sprintf(path, " ");
	sprintf(name_of_file_being_edited, " ");
	int ret = file_select_ex("Load A Tile...", name_of_file_being_edited, "BMP;bmp;", 80 * 8, 300, 400);
	if (ret)
	{
		// load!
		BITMAP * tmpbit = load_bmp(name_of_file_being_edited, NULL);
		blit(tmpbit, realtileimage, 0, 0, 0, 0, tmpbit->w, tmpbit->h);
		destroy_bitmap(tmpbit);
		
		// update the tile editor tiledata
		synchronize_editor_with_tile();
	}*/
		}
		
		private function EditActSaveImage():void 
		{ 
			/*// save
	// thanks to kazzmir in #allegro-support 10-11-07 6:22pm for helping me
	//char path[80 * 8];
	//sprintf(path, "untitled.bmp");
	
	int ret = file_select_ex("Save As...", name_of_file_being_edited, "BMP;bmp;", 80 * 8, 300, 400);
	if (ret)
	{
		// save!
		// fprintf(stdout, "you want to save to %s\n", path);
		save_bmp(name_of_file_being_edited, realtileimage, NULL);
	}
	else
	{
		// nope, don't save
		alert("Just to let you know...","","The current image has NOT been saved.", "Okay", NULL, KEY_ENTER, KEY_ESC);
	}*/
		}
		
		private function EditActToggleGrid():void 
		{ 
			showGrid = !showGrid;
			//trace("toggle grid:",showGrid);
		}
		
		private function EditActToggleOpaqueMode():void 
		{
			if (opaqueDrawing)
			{
				opaqueDrawing = 0;
				hudColor = HUD_TRANSPARENT_MODE;
			}
			else
			{
				opaqueDrawing = 1;
				hudColor = HUD_OPAQUE_MODE;
			}
			RedrawTheTile(tileImage);
		}
		
		private function EditActShiftPixelsUp():void 
		{
			ToolShiftPixelsUp();
		}
		
		private function EditActShiftPixelsDown():void 
		{
			ToolShiftPixelsDown();
		}
		
		private function EditActShiftPixelsLeft():void 
		{
			ToolShiftPixelsLeft();
		}
		
		private function EditActShiftPixelsRight():void 
		{
			ToolShiftPixelsRight();
		}
		
		private function EditActCopyImage():void 
		{
			//trace("copying image to cliboard");
			clipboardImage.copyPixels(realTileImage, realTileImage.rect, new Point);
		}
		
		private function EditActPasteImage():void 
		{ 
			//trace("pasting image from cliboard");
			if (opaqueDrawing)
			{
				realTileImage.copyPixels(clipboardImage, clipboardImage.rect, new Point);
			}
			else
			{
				for (var y:Number = 0; y < clipboardImage.height; y++)
				{
					for (var x:Number = 0; x < clipboardImage.width; x++)
					{
						var sourcePixel:uint = clipboardImage.getPixel32(x, y);
						if (sourcePixel != AL.PALETTE256[0])
						{
							realTileImage.setPixel32(x, y, sourcePixel);
						}
					}
				}
			}
			SynchronizeEditorWithTile();
		}
		
		private function EditActPreviewMode():void 
		{ 
			/*
		//a very simple tiled-preview of the current tile fills the screen
		//pressing space will exit the preview mode
	
	bool end_preview = false;
	while (!end_preview)
	{
		if (key[KEY_SPACE])
		{
			end_preview = true;
		}
		clear_bitmap(doublebuffer);
		{
			// real size preview
			{
				for (int y = 0; y < SCREEN_H / 2; y += TILESZ)
				{
					for (int x = 0; x < SCREEN_W; x += TILESZ)
					{
						blit(realtileimage, doublebuffer, 0, 0, x, y, TILESZ, TILESZ);
					}
				}
			}
			
			// zoom tiled preview
			{
				for (int y = SCREEN_H / 2; y < SCREEN_H; y += zoom_tile_rect[5])
				{
					for (int x = 0; x < SCREEN_W; x += zoom_tile_rect[4])
					{
						stretch_blit(realtileimage, doublebuffer, 0, 0, realtileimage->w, realtileimage->h, 
						x, y, zoom_tile_rect[4], zoom_tile_rect[5]);
					}
				}
			}
		}
		blit(doublebuffer, screen, 0, 0, 0, 0, doublebuffer->w, doublebuffer->h);
	}
	clear_bitmap(doublebuffer);*/
		}
		
		private function EditActRandomFillImage():void 
		{
			var iterations:Number = int((TILESZ * TILESZ) * 0.125);
			for (var i:Number = 0; i < iterations; i++)
			{
				var px:Number = Math.random() * TILESZ;
				var py:Number = Math.random() * TILESZ;
				realTileImage.setPixel32(px, py, drawColor);
			}
			
			SynchronizeEditorWithTile();
		}
		
		private function EditActFlipImage():void 
		{
			var t:BitmapData = new BitmapData(TILESZ, TILESZ, true, 0x00000000);
			t.copyPixels(realTileImage, realTileImage.rect, new Point);
			
			for (var x:Number = 0; x < TILESZ; x++)
			{
				for (var y:Number = 0; y < TILESZ; y++)
				{
					t.setPixel32(x, y, realTileImage.getPixel32(x, (TILESZ - 1) - y));
				}
			}
			
			realTileImage.copyPixels(t, t.rect, new Point);
			t.dispose();
			SynchronizeEditorWithTile();
		}
		
		private function EditActMirrorImage():void 
		{
			var t:BitmapData = new BitmapData(TILESZ, TILESZ, true, 0x00000000);
			t.copyPixels(realTileImage, realTileImage.rect, new Point);
			
			for (var x:Number = 0; x < TILESZ; x++)
			{
				for (var y:Number = 0; y < TILESZ; y++)
				{
					t.setPixel32(x, y, realTileImage.getPixel32((TILESZ - 1) - x, y));
				}
			}
			
			realTileImage.copyPixels(t, t.rect, new Point);
			t.dispose();
			SynchronizeEditorWithTile();
		}
		
		private function EditActRotateImage():void 
		{
			var t:BitmapData = new BitmapData(TILESZ, TILESZ, true, 0x00000000);
			t.copyPixels(realTileImage, realTileImage.rect, new Point);
			
			for (var x:Number = 0; x < TILESZ; x++)
			{
				for (var y:Number = 0; y < TILESZ; y++)
				{
					t.setPixel32(y, (TILESZ - 1) - x, realTileImage.getPixel32(x, y));
				}
			}
			
			realTileImage.copyPixels(t, t.rect, new Point);
			t.dispose();
			SynchronizeEditorWithTile();
		}
		
		private function EditActBlurImage():void 
		{
			var t:BitmapData = new BitmapData(TILESZ, TILESZ, true, 0x00000000);
			t.copyPixels(realTileImage, realTileImage.rect, new Point);
			
			// lets see which method works better
			
			// flash filter blur
			t.applyFilter(t, t.rect, new Point, new BlurFilter);
			
			// manual blur
			/*
			var sample:Vector.<uint> = new Vector.<uint>(8);
			var color:uint = 0;
			for (var x:Number = 0; x < TILESZ; x++)
			{
				for (var y:Number = 0; y < TILESZ; y++)
				{
					sample[0] = realTileImage.getPixel32(x - 1, y - 1);
					sample[1] = realTileImage.getPixel32(x, y - 1);
					sample[2] = realTileImage.getPixel32(x + 1, y - 1);
					sample[3] = realTileImage.getPixel32(x + 1, y);
					sample[4] = realTileImage.getPixel32(x + 1, y + 1);
					sample[5] = realTileImage.getPixel32(x, y + 1);
					sample[6] = realTileImage.getPixel32(x - 1, y + 1);
					sample[7] = realTileImage.getPixel32(x - 1, y);
					
					color = uint(sample[0]);
					for (var s:Number = 1; s < 8; s++)
					{
						color += sample[s];
					}
					color *= 0.25;
					t.setPixel32(x, y, color);
				}
			}
			*/
			
			realTileImage.copyPixels(t, t.rect, new Point);
			t.dispose();
			SynchronizeEditorWithTile();
		}
		
		private function EditActScatterImage():void 
		{
			var t:BitmapData = new BitmapData(TILESZ, TILESZ, true, 0x00000000);
			t.copyPixels(realTileImage, realTileImage.rect, new Point);
			const min:Number = -4;
			const max:Number = 4;
			
			for (var x:Number = 0; x < TILESZ - 1; x++)
			{
				for (var y:Number = 0; y < TILESZ - 1; y++)
				{
					var dx:Number = min + Math.random() % (max - min);
					var dy:Number = min + Math.random() % (max - min);
					if (x + dx < TILESZ && x + dx > 0 && y + dy < TILESZ && y + dy > 0)
					{
						var oldColor:Number = t.getPixel32(x, y);
						var newColor:Number = t.getPixel32(x + dx, y + dy);
						t.setPixel32(x, y, newColor);
						t.setPixel32(x + dx, y + dy, oldColor);
					}
				}
			}
			
			realTileImage.copyPixels(t, t.rect, new Point);
			t.dispose();
			SynchronizeEditorWithTile();
		}
		
		private function UIDrawFrame(rect:Rectangle):void
		{
			const colors:Vector.<uint> = Vector.<uint>([0xFFFFFFFF, 0xFFC0C0C0, 0xFF808080, 0xFF404040]);
			
			for (var i:Number = 0; i < 4; i++)
			{
				AL.rect(backBuffer, rect.left - i, rect.top - i, rect.right + i, rect.bottom + i, colors[i]);
			}
		}
	}
}