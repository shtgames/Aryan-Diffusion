package ad.player 
{
	import ad.deck.card.Card;
	import ad.deck.card.CardState;
	import ad.deck.Hand;
	import ad.deck.Deck;
	import ad.map.HashMap;
	import ad.field.Field;
	
	public class Player 
	{		
		public function Player()
		{
			m_playedCards.insert(Card.CHARACTER, new Vector.<CardState>())
				.insert(Card.SUPPORT, new Vector.<CardState>())
				.insert(Card.HABITAT, new Vector.<CardState>());
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
			m_playedCards.at(Card.getCard(card).type).push(new CardState(card));
			return this;
		}
		
		
		public function getPlayedCards(type:uint):Vector.<CardState>
		{
			return m_playedCards.at(type);
		}
		
		
		private var m_playedCards:HashMap = new HashMap();
		private var m_hand:Hand = new Hand();
		private var m_deck:Deck = new Deck();
		private var m_parent:Field = null;
	}
}