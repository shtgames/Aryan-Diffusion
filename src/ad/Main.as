package ad
{
	import flash.concurrent.Mutex;
	import flash.display.MovieClip;
	
	import ad.deck.card.Card;
	import ad.deck.card.Ability;
	import ad.map.HashMap;
	
	public class Main extends MovieClip
	{		
		public function Main()
		{
			Card.loadResources("../resources/cards/definitions.dir");
			Ability.loadResources("../resources/abilities/definitions.dir");
		}
	}	
}