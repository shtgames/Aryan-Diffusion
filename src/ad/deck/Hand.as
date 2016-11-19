package ad.deck 
{
	import flash.display.MovieClip;
	import ad.deck.card.Card;
	
	public class Hand extends MovieClip
	{		
		public function Hand() 
		{
			
		}
		
		
		public function addCard(card:Card):Hand
		{
			if (card != null)
				m_cards.push(card);
			return this;
		}
		
		
		private var m_cards:Vector.<Card> = null;
	}

}