package ad.scenario.player 
{	
	import ad.scenario.card.Deck;
	import ad.scenario.card.Hand;
	import ad.scenario.card.card.Card;
	import ad.scenario.card.card.CardState;
	import ad.scenario.field.Field;
	import ad.scenario.event.Event;
	import ad.scenario.event.EventType;
	import ad.scenario.event.EventDispatcher;
	import utils.map.Map;
	
	public class Player
	{
		public function Player(parentValue:Field)
		{
			m_parent = parentValue;
			m_playedCards = new Map().push(Card.CHARACTER, new Vector.<CardState>())
				.push(Card.SUPPORT, new Vector.<CardState>())
				.push(Card.HABITAT, new Vector.<CardState>());
			
			m_deck = new Deck(this);
			m_hand = new Hand(this);
		}
		
		
		public function toString():String
		{
			return "<Player> (" + m_deck.toString() + "/" + m_hand.toString() + ")";
		}
		
		public function get deck():Deck
		{
			return m_deck;
		}
		
		public function get hand():Hand
		{
			return m_hand;
		}
		
		public function getPlayedCard(type:uint, index:uint):CardState
		{
			return m_playedCards.at(type) == null || index >= m_playedCards.at(type).length ? null : m_playedCards.at(type)[index];
		}
		
		public function getPlayedCardCount(type:uint):uint
		{
			return m_playedCards.at(type) == null ? 0 : m_playedCards.at(type).length;
		}
		
		public function get parent():Field
		{
			return m_parent;
		}
		
		
		public function input(event:Event):void
		{
			m_deck.input(event);
			m_hand.input(event);
			
			for each (var cards:Vector.<CardState> in m_playedCards)
				for each (var card:CardState in cards)
					card.input(event);
		}
		
		public function cull():void
		{
			for each (var cards:Vector.<CardState> in m_playedCards)
				for (var index:uint = 0; index < cards.length; ++index)
					if (!cards[index].card.hasFlag(Card.INDESTRUCTIBLE) && cards[index].health <= 0)
						EventDispatcher.pollEvent(new Event(EventType.FieldEvent, new Map()
							.push("card", cards.removeAt(index))
							.push("index", index--)
							.push("destroyed", true)));
		}
		
		public function addCardToBattlefield(cardPrototype:Card, source:Object = null):Player
		{
			const card:CardState = new CardState(cardPrototype, this);
			if (card == null || card.card == null)
				return this;
			
			if (card.card.hasFlag(Card.UNIQUE))
				for each (var it:CardState in m_playedCards.at(card.card.type))
					if (it.card == card.card)
						return this;
			
			m_playedCards.at(card.card.type).push(card);
			EventDispatcher.pollEvent(new Event(EventType.FieldEvent, new Map()
				.push("card", card)
				.push("index", m_playedCards.at(card.card.type).length - 1)
				.push("source", source)
				.push("added", true)));
			return this;
		}
		
		public function destroyCard(card:CardState, source:Object = null):Player
		{
			if (card == null || card.card == null || card.card.hasFlag(Card.INDESTRUCTIBLE))
				return this;
			
			const cards:Vector.<CardState> = m_playedCards.at(card.card.type);
			for (var index:uint = 0, end:uint = cards.length; index != end; ++index)
				if (cards[index] == card)
				{
					cards.removeAt(index);
					EventDispatcher.pollEvent(new Event(EventType.FieldEvent, new Map()
						.push("card", card)
						.push("index", index)
						.push("source", source)
						.push("destroyed", true)));
					break;
				}
			
			return this;
		}
		
		public function removeCardFromBattlefield(card:CardState, source:Object = null):Player
		{
			if (card == null || card.card == null)
				return this;
			
			const cards:Vector.<CardState> = m_playedCards.at(card.card.type);
			for (var index:uint = 0, end:uint = cards.length; index != end; ++index)
				if (cards[index] == card)
				{
					cards.removeAt(index);
					EventDispatcher.pollEvent(new Event(EventType.FieldEvent, new Map()
						.push("card", card)
						.push("index", index)
						.push("source", source)
						.push("removed", true)));
					break;
				}
			return this;
		}
		
		
		private var m_playedCards:Map;
		private var m_hand:Hand;
		private var m_deck:Deck;
		private var m_parent:Field;
	}
}