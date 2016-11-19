package ad.deck 
{
	import flash.display.MovieClip;
	import ad.deck.card.Card;
	
	public class Deck extends MovieClip
	{
		public function Deck() 
		{
			
		}
		
		
		public function addCard(card:Card):Deck
		{
			if (card != null)
				m_cards.push(card);
			return this;
		}
		
		
		public function getNextCard():Card
		{
			if (m_cards.length != 0)
				return m_cards[m_cards.length - 1];
			return null;
		}
		
		public function popNextCard():Card
		{
			var returnValue:Card = null;
			
			if (m_cards.length != 0)
			{
				returnValue = m_cards[m_cards.length - 1];
				m_cards.pop();
			}
			
			return returnValue;
		}
		
		public function getNextCards(count:uint):Vector.<Card>
		{
			var returnValue:Vector.<Card> = new Vector.<Card>();
			
			if (m_cards.length != 0)
				for (var i:uint = m_cards.length - 1; i >= 0 && i >= m_cards.length - count; --i)
					returnValue.push(m_cards[i]);
			
			return returnValue;
		}
		
		public function popNextCards(count:uint):Vector.<Card>
		{
			var returnValue:Vector.<Card> = new Vector.<Card>();
			
			while (count != 0 && m_cards.length != 0)
			{
				returnValue.push(popNextCard());
				count--;
			}
			
			return returnValue;
		}
		
		
		public function getCardCount():uint
		{
			return m_cards.length;
		}
		
		
		public function shuffle():Deck
		{
			var shuffledDeck:Vector.<Card> = new Vector.<Card>();
			
			var randomPos:Number = 0;
			for (var i:uint = 0; i < shuffledDeck.length; i++)
			{
				randomPos = int(Math.random() * m_cards.length);
				shuffledDeck[i] = m_cards.splice(randomPos, 1)[0];
			}
			
			m_cards = shuffledDeck;
			
			return this;
		}
		
		
		private var m_cards:Vector.<Card> = new Vector.<Card>();
	}	
}