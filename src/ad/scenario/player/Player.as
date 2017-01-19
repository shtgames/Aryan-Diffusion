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
		
		
		public function addCardToBattlefield(card:String):Player
		{
			if (!Card.exists(card)) return this;
			
			const instance:CardState = new CardState(Card.getCard(card));
			m_playedCards.at(Card.getCard(card).type).push(instance);
			
			EventDispatcher.pollEvent(new Event(EventType.FieldEvent, new Map()
				.push("card", instance)
				.push("player", this)
				.push("added", true)));
			
			return this;
		}
		
		
		private var m_playedCards:Map;
		private var m_hand:Hand;
		private var m_deck:Deck;
		private var m_parent:Field;
	}
}