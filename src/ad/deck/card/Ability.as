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
		
		public function getName():String
		{
			return m_name;
		}
		
		
		private var m_parent:Card = null;
		private var m_name:String = new String(), m_description:String = new String();
		
		public static const ACTIVE:uint = 0, PASSIVE:uint = 1, ON_SUMMON:uint = 2;
	}
}