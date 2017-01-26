package ad
{
	import flash.display.MovieClip;
	
	import ad.scenario.Scenario;
	
	public class Main extends MovieClip
	{
		public function Main() 
		{
			Scenario.loadResources("../resources/scenarios/scenarios.ad", function ():void 
				{
					Scenario.getScenario("Demo").load(function ():void
						{
							trace ("Demo loaded.", Scenario.getScenario("Demo").field.first.deck.nextCard);
						} );
				});
		}
	}
}