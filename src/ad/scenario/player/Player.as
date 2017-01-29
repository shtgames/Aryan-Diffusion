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
	import ad.map.Map;
	
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
		
		
		public function get deck():Deck
		{
			return m_deck;
		}
		
		public function get hand():Hand
		{
			return m_hand;
		}
		
		public function getPlayedCards(type:uint):Vector.<CardState>
		{
			return m_playedCards.at(type);
		}
		
		public function get parent():Field
		{
			return m_parent;
		}
		
		
		public function input(event:Event):void
		{
			for each (var cards:Vector.<CardState> in m_playedCards)
				for each (var card:CardState in cards)
					card.input(event);
		}
		
		public function addCardToBattlefield(cardKey:String):Player
		{
			const card:CardState = new CardState(Card.getCard(cardKey), this);
			if (card == null || card.card == null)
				return this;
			
			if (card.card.hasFlag(Card.UNIQUE))
				for each (var it:CardState in m_playedCards.at(card.card.type))
					if (it.card == card.card)
						return this;
			
			m_playedCards.at(card.card.type).push(card);
			EventDispatcher.pollEvent(new Event(EventType.FieldEvent, new Map()
				.push("card", card)
				.push("added", true)));
			return this;
		}
		
		
		private var m_playedCards:Map;
		private var m_hand:Hand;
		private var m_deck:Deck;
		private var m_parent:Field;
	}
}