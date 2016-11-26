package ad.deck 
{	
	import ad.map.HashMap;
	import ad.deck.card.Card;
	
	public class Hand
	{
		public function Hand()
		{
			m_playableCardsCount.insert(Card.CHARACTER, 0)
				.insert(Card.SUPPORT, 0)
				.insert(Card.HABITAT, 0);
			m_cards.insert(Card.CHARACTER, new Vector.<String>())
				.insert(Card.SUPPORT, new Vector.<String>())
				.insert(Card.HABITAT, new Vector.<String>());
		}
		
		
		public function addCard(card:String):Hand
		{
			if (Card.exists(card)) m_cards.at(Card.getCard(card).type).push(card);
			return this;
		}
		
		public function peekCard(type:uint, index:uint):String
		{			
			if (!Card.isValidType(type) || index > cardCount(type))
				return null;
			return m_cards.at(type)[index];
		}
		
		public function drawCard(type:uint, index:uint):String
		{
			if (!Card.isValidType(type) || index > cardCount(type) ||
				playableCardCount(type) == 0) return null;
			
			const returnValue:String = m_cards.at(type)[index];
			m_cards.at(type).removeAt(index);
			return returnValue;
		}
		
		
		public function cardCount(type:uint):uint
		{
			return new uint(m_cards.at(type));
		}
		
		public function playableCardCount(type:uint):uint
		{
			return new uint(m_playableCardsCount.at(type));
		}
		
		
		private var m_cards:HashMap = new HashMap(), m_playableCardsCount:HashMap = new HashMap();
	}
}