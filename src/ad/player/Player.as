package ad.player 
{	
	import ad.deck.Deck;
	import ad.deck.Hand;
	import ad.deck.card.Card;
	import ad.deck.card.CardState;
	import ad.event.Event;
	import ad.event.EventType;
	import ad.event.EventDispatcher;
	import ad.field.Field;
	import ad.map.Map;
	
	public class Player
	{
		public function Player()
		{
			m_playedCards.push(Card.CHARACTER, new Vector.<CardState>())
				.push(Card.SUPPORT, new Vector.<CardState>())
				.push(Card.HABITAT, new Vector.<CardState>());
		}
		
		
		public function get deck():Deck
		{
			return m_deck;
		}
		
		public function get hand():Hand
		{
			return m_hand;
		}
		
		public function get parent():Field
		{
			return m_parent;
		}
		
		
		public function setParent(parent:Field):Player
		{
			m_parent = parent;
			return this;
		}
		
		public function drawCard():Player
		{
			m_hand.addCard(m_deck.drawNextCard());
			return this;
		}
		
		public function playCard(type:uint, index:uint):Player
		{
			return addCardToBattlefield(m_hand.drawCard(type, index));
		}
		
		public function addCardToBattlefield(card:String):Player
		{
			if (!Card.exists(card)) return this;
			
			const instance:CardState = new CardState(card);
			m_playedCards.at(Card.getCard(card).type).push(instance);
			
			EventDispatcher.pollEvent(new Event(EventType.FieldEvent, new Map()
				.push("card", instance)
				.push("player", this)
				.push("added", true)));
			
			return this;
		}
		
		
		public function getPlayedCards(type:uint):Vector.<CardState>
		{
			return m_playedCards.at(type);
		}
		
		
		private var m_playedCards:Map = new Map();
		private var m_hand:Hand = new Hand();
		private var m_deck:Deck = new Deck();
		private var m_parent:Field = null;
	}
}