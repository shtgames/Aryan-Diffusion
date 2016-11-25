package ad.deck.card 
{
	import ad.file.Statement;
	import ad.deck.card.CardState;
	
	public class Effect 
	{
		public function Effect(source:Statement = null)
		{
			loadFromFile(source);
		}
		
		public function loadFromFile(source:Statement):void
		{
			if (source == null) return;
		}
		
		public function applyTo(target:CardState, source:CardState):CardState
		{
			return target;
		}
	}
}