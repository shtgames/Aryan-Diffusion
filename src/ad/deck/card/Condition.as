package ad.deck.card 
{
	import ad.file.Statement;
	import ad.deck.card.Card;
	
	public class Condition 
	{
		public function Condition(source:Statement = null)
		{
			loadFromFile(source);
		}
		
		public function loadFromFile(source:Statement):void
		{
			if (source == null) return;
		}
		
		public function isFulfilled(card:Card):Boolean
		{
			return true;
		}
	}
}