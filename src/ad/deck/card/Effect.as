package ad.deck.card 
{
	import ad.file.Statement;
	import ad.deck.card.Card;
	
	public class Effect 
	{
		public function Effect(source:Statement = null)
		{
			loadFromFile(source);
		}
		
		public function loadFromFile(souce:Statement)
		{
			if (source == null) return;
		}
		
		public function applyTo(target:Card, source:Card)
		{
			
		}
	}
}