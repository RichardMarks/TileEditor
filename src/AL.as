package  
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * Allegro functions
	 * @author Richard Marks
	 */
	public class AL 
	{
		static public function GetPaletteIndex(color:uint):Number
		{
			return PALETTE256.indexOf(color);
		}
		
		static public const PALETTE256:Array = 
		[
			0xFF000000,0xFF0000A8,0xFF00A800,0xFF00A8A8,0xFFA80000,0xFFA800A8,0xFFA85400,0xFFA8A8A8,
			0xFF545454,0xFF5454FC,0xFF54FC54,0xFF54FCFC,0xFFFC5454,0xFFFC54FC,0xFFFCFC54,0xFFFCFCFC,
			0xFF000000,0xFF141414,0xFF202020,0xFF2C2C2C,0xFF383838,0xFF444444,0xFF505050,0xFF606060,
			0xFF707070,0xFF808080,0xFF909090,0xFFA0A0A0,0xFFB4B4B4,0xFFC8C8C8,0xFFE0E0E0,0xFFFCFCFC,
			0xFF0000FC,0xFF4000FC,0xFF7C00FC,0xFFBC00FC,0xFFFC00FC,0xFFFC00BC,0xFFFC007C,0xFFFC0040,
			0xFFFC0000,0xFFFC4000,0xFFFC7C00,0xFFFCBC00,0xFFFCFC00,0xFFBCFC00,0xFF7CFC00,0xFF40FC00,
			0xFF00FC00,0xFF00FC40,0xFF00FC7C,0xFF00FCBC,0xFF00FCFC,0xFF00BCFC,0xFF007CFC,0xFF0040FC,
			0xFF7C7CFC,0xFF9C7CFC,0xFFBC7CFC,0xFFDC7CFC,0xFFFC7CFC,0xFFFC7CDC,0xFFFC7CBC,0xFFFC7C9C,
			0xFFFC7C7C,0xFFFC9C7C,0xFFFCBC7C,0xFFFCDC7C,0xFFFCFC7C,0xFFDCFC7C,0xFFBCFC7C,0xFF9CFC7C,
			0xFF7CFC7C,0xFF7CFC9C,0xFF7CFCBC,0xFF7CFCDC,0xFF7CFCFC,0xFF7CDCFC,0xFF7CBCFC,0xFF7C9CFC,
			0xFFB4B4FC,0xFFC4B4FC,0xFFD8B4FC,0xFFE8B4FC,0xFFFCB4FC,0xFFFCB4E8,0xFFFCB4D8,0xFFFCB4C4,
			0xFFFCB4B4,0xFFFCC4B4,0xFFFCD8B4,0xFFFCE8B4,0xFFFCFCB4,0xFFE8FCB4,0xFFD8FCB4,0xFFC4FCB4,
			0xFFB4FCB4,0xFFB4FCC4,0xFFB4FCD8,0xFFB4FCE8,0xFFB4FCFC,0xFFB4E8FC,0xFFB4D8FC,0xFFB4C4FC,
			0xFF000070,0xFF1C0070,0xFF380070,0xFF540070,0xFF700070,0xFF700054,0xFF700038,0xFF70001C,
			0xFF700000,0xFF701C00,0xFF703800,0xFF705400,0xFF707000,0xFF547000,0xFF387000,0xFF1C7000,
			0xFF007000,0xFF00701C,0xFF007038,0xFF007054,0xFF007070,0xFF005470,0xFF003870,0xFF001C70,
			0xFF383870,0xFF443870,0xFF543870,0xFF603870,0xFF703870,0xFF703860,0xFF703854,0xFF703844,
			0xFF703838,0xFF704438,0xFF705438,0xFF706038,0xFF707038,0xFF607038,0xFF547038,0xFF447038,
			0xFF387038,0xFF387044,0xFF387054,0xFF387060,0xFF387070,0xFF386070,0xFF385470,0xFF384470,
			0xFF505070,0xFF585070,0xFF605070,0xFF685070,0xFF705070,0xFF705068,0xFF705060,0xFF705058,
			0xFF705050,0xFF705850,0xFF706050,0xFF706850,0xFF707050,0xFF687050,0xFF607050,0xFF587050,
			0xFF507050,0xFF507058,0xFF507060,0xFF507068,0xFF507070,0xFF506870,0xFF506070,0xFF505870,
			0xFF000040,0xFF100040,0xFF200040,0xFF300040,0xFF400040,0xFF400030,0xFF400020,0xFF400010,
			0xFF400000,0xFF401000,0xFF402000,0xFF403000,0xFF404000,0xFF304000,0xFF204000,0xFF104000,
			0xFF004000,0xFF004010,0xFF004020,0xFF004030,0xFF004040,0xFF003040,0xFF002040,0xFF001040,
			0xFF202040,0xFF282040,0xFF302040,0xFF382040,0xFF402040,0xFF402038,0xFF402030,0xFF402028,
			0xFF402020,0xFF402820,0xFF403020,0xFF403820,0xFF404020,0xFF384020,0xFF304020,0xFF284020,
			0xFF204020,0xFF204028,0xFF204030,0xFF204038,0xFF204040,0xFF203840,0xFF203040,0xFF202840,
			0xFF2C2C40,0xFF302C40,0xFF342C40,0xFF3C2C40,0xFF402C40,0xFF402C3C,0xFF402C34,0xFF402C30,
			0xFF402C2C,0xFF40302C,0xFF40342C,0xFF403C2C,0xFF40402C,0xFF3C402C,0xFF34402C,0xFF30402C,
			0xFF2C402C,0xFF2C4030,0xFF2C4034,0xFF2C403C,0xFF2C4040,0xFF2C3C40,0xFF2C3440,0xFF2C3040,
			0xFF000000,0xFF000000,0xFF000000,0xFF000000,0xFF000000,0xFF000000,0xFF000000,0xFF000000,
		];
		
		/**
		 * creates a color value
		 * @param	r - red intensity
		 * @param	g - green intensity
		 * @param	b - blue intensity
		 * @param	a - alpha value
		 * @return 32-bit color unsigned integer value
		 */
		static public function makecol(r:uint, g:uint, b:uint, a:uint = 0xFF):uint
		{
			return (a << 24) | (r << 16) | (g << 8) | b;
		}
		
		/**
		 * fills a bitmap with black
		 * @param	b - bitmap to fill
		 */
		static public function clear_bitmap(b:BitmapData):void
		{
			b.fillRect(b.rect, 0xFF000000);
		}
		
		static public function line(b:BitmapData, x1:Number, y1:Number, x2:Number, y2:Number, color:uint):void
		{
			var partial:Number;
			var delta:Point = new Point(x2 - x1, y2 - y1);
			var step:Point = new Point;
			
			if (delta.x < 0) { delta.x = -delta.x; step.x = -1; } else { step.x = 1; }
			if (delta.y < 0) { delta.y = -delta.y; step.y = -1; } else { step.y = 1; }
			
			delta.x <<= 1;
			delta.y <<= 1;
			
			b.setPixel32(x1, y1, color);
			
			if (delta.x > delta.y)
			{
				partial = delta.y - (delta.x >> 1);
				while (x1 != x2)
				{
					if (partial >= 0)
					{
						y1 += step.y;
						partial -= delta.x;
					}
					x1 += step.x;
					partial += delta.y;
					b.setPixel32(x1, y1, color);
				}
			}
			else
			{
				partial = delta.x - (delta.y >> 1);
				while (y1 != y2)
				{
					if (partial >= 0)
					{
						x1 += step.x;
						partial -= delta.y;
					}
					y1 += step.y;
					partial += delta.x;
					b.setPixel32(x1, y1, color);
				}
			}
		}
		
		static private function DrawHLine(b:BitmapData, x1:Number, x2:Number, y:Number, color:uint):void
		{
			var l:Number = Math.abs(x2 - x1);
			for (var i:Number = 0; i <= l; i++)
			{
				b.setPixel32(x1 + i, y, color);
			}
		}
		
		static private function DrawVLine(b:BitmapData, y1:Number, y2:Number, x:Number, color:uint):void
		{
			var l:Number = Math.abs(y2 - y1);
			for (var i:Number = 0; i <= l; i++)
			{
				b.setPixel32(x, y1 + i, color);
			}
		}
		
		static public function rect(b:BitmapData, x1:Number, y1:Number, x2:Number, y2:Number, color:uint):void
		{
			DrawHLine(b, x1, x2, y1, color);
			DrawHLine(b, x1, x2, y2, color);
			DrawVLine(b, y1, y2, x1, color);
			DrawVLine(b, y1, y2, x2, color);
		}
		
		static public function stretch_blit(source:BitmapData, dest:BitmapData, sourceRect:Rectangle, destRect:Rectangle):void
		{
			var scale:Point = new Point(destRect.width / sourceRect.width, destRect.height / sourceRect.height);
			
			var matrix:Matrix = new Matrix;
			matrix.identity();
			matrix.scale(scale.x, scale.y);
			matrix.translate(destRect.x, destRect.y);
			
			//trace("stretch_blit matrix=",matrix);
			
			dest.draw(source, matrix, null, null, null, false);
		}
	}
}