package ad.deck.card 
{
	import ad.file.Statement;
	import ad.deck.card.CardState;
	
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
		
		public function isFulfilled(card:CardState):Boolean
		{
			return true;
		}
	}
}