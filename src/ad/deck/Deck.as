package ad.deck 
{
	import ad.event.Event;
	import ad.event.EventType;
	import ad.event.EventDispatcher;
	import ad.player.Player;
	import ad.deck.card.Card;
	import ad.map.Map;
	
	public class Deck
	{		
		public function setParent(parent:Player):Deck
		{
			m_parent = parent;
			return this;
		}
		
		public function addCard(card:String):Deck
		{
			if (card != null)
				m_cards.push(card);
			return this;
		}
		
		
		public function get nextCard():String
		{
			if (m_cards.length != 0)
				return m_cards[m_cards.length - 1];
			return null;
		}
		
		public function drawNextCard():String
		{
			var returnValue:String = null;
			
			if (m_cards.length != 0)
			{
				returnValue = m_cards[m_cards.length - 1];
				m_cards.pop();
				EventDispatcher.pollEvent(new Event(EventType.DeckEvent, new Map()
					.push("card", Card.getCard(returnValue))
					.push("player", m_parent)
					.push("drawn", true)));
			}
			
			return returnValue;
		}
		
		public function peekNextCards(count:uint):Vector.<String>
		{
			var returnValue:Vector.<String> = new Vector.<String>();
			
			if (m_cards.length != 0)
				for (var i:uint = m_cards.length - 1; i >= 0 && i >= m_cards.length - count; --i)
					returnValue.push(m_cards[i]);
			
			return returnValue;
		}
		
		public function drawNextCards(count:uint):Vector.<String>
		{
			var returnValue:Vector.<String> = new Vector.<String>();
			
			while (count != 0 && m_cards.length != 0)
			{
				returnValue.push(drawNextCard());
				count--;
				EventDispatcher.pollEvent(new Event(EventType.DeckEvent, new Map()
					.push("card", Card.getCard(returnValue[returnValue.length - 1]))
					.push("player", m_parent)
					.push("drawn", true)));
			}
			
			return returnValue;
		}
		
		
		public function get parent():Player
		{
			return m_parent;
		}
		
		public function get cardCount():uint
		{
			return m_cards.length;
		}
		
		
		public function shuffle():Deck
		{
			var shuffledDeck:Vector.<String> = new Vector.<String>();
			
			var randomPos:Number = 0;
			for (var i:uint = 0; i < shuffledDeck.length; i++)
			{
				randomPos = int(Math.random() * m_cards.length);
				shuffledDeck[i] = m_cards.splice(randomPos, 1)[0];
			}
			
			m_cards = shuffledDeck;
			
			return this;
		}
		
		public function clear():Deck
		{
			m_cards.length = 0;
			return this;
		}
		
		
		private var m_cards:Vector.<String> = new Vector.<String>();
		private var m_parent:Player = null;
	}	
}