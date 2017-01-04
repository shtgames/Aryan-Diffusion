package ad.deck.effect 
{
	import ad.expression.ParseNode;
	import ad.deck.card.CardState;
	
	public class Condition 
	{
		public function Condition(source:ParseNode = null)
		{
			loadFromFile(source);
		}
		
		public function loadFromFile(source:ParseNode):void
		{
			if (source == null) return;
		}
		
		public function isFulfilled(card:CardState):Boolean
		{
			return true;
		}
	}
}