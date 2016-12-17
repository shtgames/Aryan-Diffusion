package ad
{
	import flash.display.MovieClip;
	
	import ad.deck.card.Card;
	import ad.deck.card.Ability;
	
	public class Main extends MovieClip
	{
		public function Main()
		{
			Ability.loadResources("../resources/abilities/definitions.dir");
			Card.loadResources("../resources/cards/definitions.dir");
		}
	}
}