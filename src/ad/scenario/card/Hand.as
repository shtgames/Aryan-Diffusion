package ad.scenario.card 
{
	import ad.scenario.card.card.CardState;
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
		
		
		public function toString():String
		{
			return "<Hand> (" + m_playableCardsLimit.at(Card.CHARACTER) + "/" + m_playableCardsLimit.at(Card.SUPPORT) + "/" + m_playableCardsLimit.at(Card.HABITAT) + ")";
		}
		
		public function peekCard(type:uint, index:uint, source:Object = null):String
		{			
			if (!Card.isValidType(type) || index > cardCount(type))
				return null;
			
			EventDispatcher.pollEvent(new Event(EventType.HandEvent, new Map()
				.push("peeked", true)
				.push("source", source)
				.push("card", m_cards.at(type)[index])
				.push("hand", this)));
			return m_cards.at(type)[index];
		}
		
		public function cardCount(type:uint):uint
		{
			return m_cards.at(type).length;
		}
		
		public function getPlayableCardLimit(type:uint):uint
		{
			return m_playableCardsLimit.at(type);
		}
		
		public function get parent():Player
		{
			return m_parent;
		}
		
		
		public function input(event:Event):void
		{
			if (event != null && event.type.equals(EventType.TurnEvent) && event.data.at("player") == m_parent)
				for (var type:String in m_playableCardsLimit)
					if (m_playableCardsLimit.at(type) < 1)
						setPlayableCardLimit(parseInt(type), 1);
		}
		
		public function setPlayableCardLimit(type:uint, value:uint, source:Object = null):Hand
		{
			if (Card.isValidType(type))
			{
				const previous:uint = m_playableCardsLimit.at(type);
				m_playableCardsLimit.push(type, value);
				EventDispatcher.pollEvent(new Event(EventType.HandEvent, new Map()
					.push("limit", true)
					.push("source", source)
					.push("type", type)
					.push("previous_limit", previous)
					.push("hand", this)));
			}
			return this;
		}
		
		public function addCard(card:String, source:Object = null):Hand
		{
			if (Card.exists(card))
			{
				m_cards.at(Card.getCard(card).type).push(card);
				EventDispatcher.pollEvent(new Event(EventType.HandEvent, new Map()
					.push("added", true)
					.push("source", source)
					.push("card", card)
					.push("hand", this)));
			}
			return this;
		}
		
		public function removeCard(card:String, source:Object = null):Hand
		{
			if (Card.exists(card))
				for (var i:uint = 0, cards:Vector.<String> = m_cards.at(Card.getCard(card).type), end:uint = cards.length; i != end; ++i)
					if (cards[i] == card)
					{
						EventDispatcher.pollEvent(new Event(EventType.HandEvent, new Map()
							.push("removed", true)
							.push("source", source)
							.push("card", cards.removeAt(i))
							.push("hand", this)));
						break;
					}
			return this;
		}
		
		public function playCard(type:uint, index:uint):String
		{
			if (!Card.isValidType(type) || index >= cardCount(type) ||
				getPlayableCardLimit(type) == 0) return null;
			
			const card:String = m_cards.at(type)[index];
			m_cards.at(type).removeAt(index);
			m_playableCardsLimit.push(type, m_playableCardsLimit.at(type) - 1);
			
			if (m_parent != null)
				m_parent.addCardToBattlefield(card, this);
			
			return card;
		}
		
		
		private var m_cards:Map = new Map(), m_playableCardsLimit:Map = new Map();
		private var m_parent:Player;
	}
}