package ad.deck.effect 
{
	import ad.expression.ParseNode;
	import ad.deck.card.CardState;
	import ad.map.Map;
	
	public class DynamicEffect 
	{
		public function DynamicEffect(source:ParseNode = null)
		{
			loadFromFile(source);
		}
		
		public function loadFromFile(source:ParseNode):void
		{
			if (source == null) return;
		}
		
		public function applyTo(data:Map):void
		{
			
		}
	}
}