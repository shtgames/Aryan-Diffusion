package ad.scenario.card 
{
	import ad.scenario.event.Event;
	import ad.scenario.event.EventType;
	import ad.scenario.event.EventDispatcher;
	import ad.scenario.player.Player;
	import ad.scenario.card.card.Card;
	import ad.map.Map;
	
	public class Deck
	{		
		public function Deck(parentValue:Player)
		{
			m_parent = parentValue;
		}
		
		
		public function toString():String
		{
			return "<Deck> (" + m_cards.length + ")";
		}
		
		public function get parent():Player
		{
			return m_parent;
		}
		
		public function get cardCount():uint
		{
			return m_cards.length;
		}
		
		public function getNextCard():String
		{
			if (m_cards.length != 0)
				return m_cards[m_cards.length - 1];
			return null;
		}
		
		public function getNextCards(count:uint):Vector.<String>
		{
			var returnValue:Vector.<String> = new Vector.<String>();
			
			if (m_cards.length != 0)
				for (var i:int = m_cards.length - 1; i >= 0 && i >= m_cards.length - count; --i)
					returnValue.push(m_cards[i]);
			
			return returnValue;
		}
		
		public function peekCard(source:Object = null):String
		{
			if (m_cards.length != 0)
			{
				EventDispatcher.pollEvent(new Event(EventType.DeckEvent, new Map()
					.push("peeked", true)
					.push("source", source)
					.push("card", m_cards[m_cards.length - 1])
					.push("deck", this)));
				return m_cards[m_cards.length - 1];
			}
			return null;
		}
		
		public function peekCards(count:uint, source:Object = null):Vector.<String>
		{
			var returnValue:Vector.<String> = new Vector.<String>();
			
			if (m_cards.length != 0)
				for (var i:int = m_cards.length - 1; i >= 0 && i >= m_cards.length - count; --i)
					returnValue.push(m_cards[i]);
			
			EventDispatcher.pollEvent(new Event(EventType.DeckEvent, new Map()
				.push("peeked", true)
				.push("multiple", true)
				.push("source", source)
				.push("cards", returnValue)
				.push("deck", this)));
			return returnValue;
		}
		
		
		public function addCard(card:String, source:Object = null):Deck
		{
			if (Card.exists(card))
			{
				m_cards.push(card);
				EventDispatcher.pollEvent(new Event(EventType.DeckEvent, new Map()
					.push("added", true)
					.push("source", source)
					.push("card", card)
					.push("deck", this)));
			}
			return this;
		}
		
		public function removeCard(card:String, source:Object = null):Deck
		{
			if (Card.exists(card))
				for (var index:uint = 0, end:uint = m_cards.length; index != end; ++index)
					if (m_cards[index] == card)
					{
						EventDispatcher.pollEvent(new Event(EventType.DeckEvent, new Map()
							.push("removed", true)
							.push("source", source)
							.push("card", m_cards.removeAt(index))
							.push("deck", this)));
						break;
					}
			
			return this;
		}
		
		public function swapCards(first:uint, second:uint, source:Object = null):Deck
		{
			if (first == second || first >= m_cards.length || second >= m_cards.length)
				return this;
			
			const card:String = m_cards[first];
			m_cards[first] = m_cards[second];
			m_cards[second] = card;
			EventDispatcher.pollEvent(new Event(EventType.DeckEvent, new Map()
				.push("swapped", true)
				.push("source", source)
				.push("first", first)
				.push("second", second)
				.push("deck", this)));
			
			return this;
		}
		
		public function drawNextCard(source:Object = null):String
		{
			var returnValue:String = null;
			
			if (m_cards.length != 0)
			{
				returnValue = m_cards[m_cards.length - 1];
				m_cards.pop();
				
				if (m_parent != null && m_parent.hand != null)
					m_parent.hand.addCard(returnValue);
				
				EventDispatcher.pollEvent(new Event(EventType.DeckEvent, new Map()
					.push("drawn", true)
					.push("source", source)
					.push("card", returnValue)
					.push("deck", this)));
			}
			
			return returnValue;
		}
		
		public function drawNextCards(count:uint, source:Object = null):Vector.<String>
		{
			var returnValue:Vector.<String> = new Vector.<String>();
			
			while (count != 0 && m_cards.length != 0)
			{
				returnValue.push(drawNextCard(source));
				count--;
			}
			
			return returnValue;
		}
		
		
		public function shuffle(source:Object = null):Deck
		{
			const shuffledDeck:Vector.<String> = new Vector.<String>(m_cards.length);
			
			var randomPos:Number = 0;
			for (var i:uint = 0; i < shuffledDeck.length; ++i)
			{
				randomPos = int(Math.random() * m_cards.length);
				shuffledDeck[i] = m_cards.splice(randomPos, 1)[0];
			}
			m_cards = shuffledDeck;
			
			EventDispatcher.pollEvent(new Event(EventType.DeckEvent, new Map()
				.push("shuffled", true)
				.push("source", source)
				.push("deck", this)));
			
			return this;
		}
		
		public function clear():Deck
		{
			m_cards.length = 0;
			return this;
		}
		
		
		private var m_cards:Vector.<String> = new Vector.<String>();
		private var m_parent:Player;
	}	
}