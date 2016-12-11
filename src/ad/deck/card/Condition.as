package ad.deck.card 
{
	import ad.expression.ParseTreeNode;
	import ad.deck.card.CardState;
	
	public class Condition 
	{
		public function Condition(source:ParseTreeNode = null)
		{
			loadFromFile(source);
		}
		
		public function loadFromFile(source:ParseTreeNode):void
		{
			if (source == null) return;
		}
		
		public function isFulfilled(card:CardState):Boolean
		{
			return true;
		}
	}
}