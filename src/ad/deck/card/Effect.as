package ad.deck.card 
{
	import ad.expression.ParseTreeNode;
	import ad.deck.card.CardState;
	
	public class Effect 
	{
		public function Effect(source:ParseTreeNode = null)
		{
			loadFromFile(source);
		}
		
		public function loadFromFile(source:ParseTreeNode):void
		{
			if (source == null) return;
		}
		
		public function applyTo(target:CardState, source:CardState):CardState
		{
			return target;
		}
	}
}