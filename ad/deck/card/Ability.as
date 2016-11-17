package ad.deck.card 
{
	import flash.display.MovieClip;
	import ad.deck.card.Card;
	
	public class Ability extends MovieClip
	{
		public function Ability() 
		{
			
		}
		
		
		public function applyTo(target:Card):void
		{
			
		}
		
		public function setParent(parent:Card):Ability
		{
			m_parent = parent;
			return this;
		}
		
		public function getName():const String
		{
			return m_name;
		}
		
		
		private var m_parent:Card = null;
		private var m_name:String = new String(), m_description = new String();
	}
}