package  
{
	/**
	 * Allegro functions
	 * @author Richard Marks
	 */
	public class AL 
	{
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
	}

}