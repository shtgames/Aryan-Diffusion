package ad.scenario.card 
{
	import ad.scenario.event.Event;
	import ad.scenario.event.EventType;
	import ad.scenario.event.EventDispatcher;
	import ad.scenario.card.card.Card;
	import ad.scenario.player.Player;
	import ad.map.Map;
	
	public class Hand
	{
		public function Hand(parentValue:Player)
		{
			m_parent = parentValue;
			
			m_playableCardsLimit.push(Card.CHARACTER, 0)
				.push(Card.SUPPORT, 0)
				.push(Card.HABITAT, 0);
			m_cards.push(Card.CHARACTER, new Vector.<String>())
				.push(Card.SUPPORT, new Vector.<String>())
				.push(Card.HABITAT, new Vector.<String>());
		}
		
		
		public function peekCard(type:uint, index:uint):String
		{			
			if (!Card.isValidType(type) || index > cardCount(type))
				return null;
			return m_cards.at(type)[index];
		}
		
		public function cardCount(type:uint):uint
		{
			return m_cards.at(type);
		}
		
		public function getPlayableCardLimit(type:uint):uint
		{
			return m_playableCardsLimit.at(type);
		}
		
		public function get parent():Player
		{
			return m_parent;
		}
		
		
		public function setPlayableCardLimit(type:uint, value:uint):Hand
		{
			if (Card.isValidType(type))
				m_playableCardsLimit.push(type, value);
			return this;
		}
		
		public function addCard(card:String):String
		{
			if (Card.exists(card))
				m_cards.at(Card.getCard(card).type).push(card);
			return card;
		}
		
		public function drawCard(type:uint, index:uint):String
		{
			if (!Card.isValidType(type) || index > cardCount(type) ||
				getPlayableCardLimit(type) == 0) return null;
			
			const returnValue:String = m_cards.at(type)[index];
			m_cards.at(type).removeAt(index);
			
			EventDispatcher.pollEvent(new Event(EventType.HandEvent, new Map()
				.push("card", Card.getCard(returnValue[returnValue.length - 1]))
				.push("player", m_parent)
				.push("drawn", true)));
			
			if (m_parent != null)
				m_parent.addCardToBattlefield(returnValue);
			
			return returnValue;
		}
		
		
		private var m_cards:Map = new Map(), m_playableCardsLimit:Map = new Map();
		private var m_parent:Player;
	}
}