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
		
		
		public function get parent():Player
		{
			return m_parent;
		}
		
		public function get cardCount():uint
		{
			return m_cards.length;
		}
		
		public function get nextCard():String
		{
			if (m_cards.length != 0)
				return m_cards[m_cards.length - 1];
			return null;
		}
		
		public function nextCards(count:uint):Vector.<String>
		{
			var returnValue:Vector.<String> = new Vector.<String>();
			
			if (m_cards.length != 0)
				for (var i:int = m_cards.length - 1; i >= 0 && i >= m_cards.length - count; --i)
					returnValue.push(m_cards[i]);
			
			return returnValue;
		}
		
		
		public function addCard(card:String):Deck
		{
			if (card != null)
				m_cards.push(card);
			return this;
		}
		
		public function drawNextCard():String
		{
			var returnValue:String = null;
			
			if (m_cards.length != 0)
			{
				returnValue = m_cards[m_cards.length - 1];
				m_cards.pop();
				
				if (m_parent != null && m_parent.hand != null)
					m_parent.hand.addCard(returnValue);
				
				EventDispatcher.pollEvent(new Event(EventType.DeckEvent, new Map()
					.push("card", Card.getCard(returnValue))
					.push("player", m_parent)
					.push("drawn", true)));
			}
			
			return returnValue;
		}
		
		public function drawNextCards(count:uint):Vector.<String>
		{
			var returnValue:Vector.<String> = new Vector.<String>();
			
			while (count != 0 && m_cards.length != 0)
			{
				returnValue.push(drawNextCard());
				count--;
			}
			
			return returnValue;
		}
		
		public function shuffle():Deck
		{
			const shuffledDeck:Vector.<String> = new Vector.<String>(m_cards.length);
			
			var randomPos:Number = 0;
			for (var i:uint = 0; i < shuffledDeck.length; ++i)
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
		private var m_parent:Player;
	}	
}