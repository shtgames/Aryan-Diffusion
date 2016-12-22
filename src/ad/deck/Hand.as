package ad.deck 
{
	import ad.event.Event;
	import ad.event.EventType;
	import ad.event.EventDispatcher;
	import ad.deck.card.Card;
	import ad.player.Player;
	import ad.map.Map;
	
	public class Hand
	{
		public function Hand()
		{
			m_playableCardsCount.push(Card.CHARACTER, 0)
				.push(Card.SUPPORT, 0)
				.push(Card.HABITAT, 0);
			m_cards.push(Card.CHARACTER, new Vector.<String>())
				.push(Card.SUPPORT, new Vector.<String>())
				.push(Card.HABITAT, new Vector.<String>());
		}
		
		
		public function setParent(parent:Player):Hand
		{
			m_parent = parent;
			return this;
		}
		
		public function addCard(card:String):String
		{
			if (Card.exists(card)) m_cards.at(Card.getCard(card).type).push(card);
			return card;
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
			EventDispatcher.pollEvent(new Event(EventType.HandEvent, new Map()
				.push("card", Card.getCard(returnValue[returnValue.length - 1]))
				.push("player", m_parent)
				.push("drawn", true)));
			
			return returnValue;
		}
		
		
		public function get parent():Player
		{
			return m_parent;
		}
		
		public function cardCount(type:uint):uint
		{
			return new uint(m_cards.at(type));
		}
		
		public function playableCardCount(type:uint):uint
		{
			return new uint(m_playableCardsCount.at(type));
		}
		
		
		private var m_cards:Map = new Map(), m_playableCardsCount:Map = new Map();
		private var m_parent:Player = null;
	}
}