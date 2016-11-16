package ad.deck.card 
{
	import flash.display.MovieClip;
	
	public class Card extends MovieClip
	{		
		public function Card() 
		{
			
		}
		
		private var m_background:MovieClip = null, m_portrait:MovieClip = null;
		private var m_name:String = null, m_description:String = null;
		
		private var m_health:uint = 0, m_attack:uint = 0;
	}
}