package ad.deck.card 
{
	import ad.expression.ParseTreeNode;
	import ad.deck.card.CardState;
	import ad.map.Map;
	
	public class DynamicEffect 
	{
		public function DynamicEffect(source:ParseTreeNode = null)
		{
			loadFromFile(source);
		}
		
		public function loadFromFile(source:ParseTreeNode):void
		{
			if (source == null) return;
		}
		
		public function applyTo(data:Map):void
		{
			
		}
	}
}