package ad
{
	import flash.display.MovieClip;
	
	import ad.deck.card.Card;
	import ad.deck.card.Ability;
	import ad.deck.effect.StatusEffect;
	
	public class Main extends MovieClip
	{
		public function Main()
		{
			StatusEffect.loadResources("../resources/status_effects/definitions.dir");
			Ability.loadResources("../resources/abilities/definitions.dir");
			Card.loadResources("../resources/cards/definitions.dir");
		}
	}
}