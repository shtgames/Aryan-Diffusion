package ad
{
	import ad.gui.UI;
	import flash.display.MovieClip;
	
	import ad.scenario.Scenario;
	import ad.scenario.card.card.Card;
	
	public class Main extends MovieClip
	{
		public function Main() 
		{
			addChild(new UI(stage));
			
			Scenario.loadResources("../resources/scenarios/scenarios.ad", function ():void 
				{
					Scenario.getScenario("Demo").load();
				});
		}
	}
}