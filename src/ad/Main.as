package ad
{
	import flash.display.MovieClip;
	
	import ad.scenario.Scenario;
	import ad.scenario.card.card.Card;
	
	public class Main extends MovieClip
	{
		public function Main() 
		{
			Scenario.loadResources("../resources/scenarios/scenarios.ad", function ():void 
				{
					Scenario.getScenario("Demo").load(function ():void
						{
							var counter:uint = 0;
							while (true)
								if (counter == 2 || Scenario.getScenario("Demo").field.first.deck.nextCard == null)
									break;
								else if (Card.getCard(Scenario.getScenario("Demo").field.first.deck.drawNextCard()).type == Card.CHARACTER)
									counter++;
							
							Scenario.getScenario("Demo").field.first.hand.setPlayableCardLimit(Card.CHARACTER, 2);
							Scenario.getScenario("Demo").field.first.hand.drawCard(Card.CHARACTER, 0);
							Scenario.getScenario("Demo").field.first.hand.drawCard(Card.CHARACTER, 0);
							
							while (true)
								if (Scenario.getScenario("Demo").field.second.deck.drawNextCard() == "GiantCaptain")
									break;
							
							Scenario.getScenario("Demo").field.second.hand.setPlayableCardLimit(Card.CHARACTER, 2);
							for (var index:uint = 0; index != Scenario.getScenario("Demo").field.second.hand.cardCount(Card.CHARACTER); ++index)
								if (Scenario.getScenario("Demo").field.second.hand.peekCard(Card.CHARACTER, index) == "GiantCaptain")
								{
									Scenario.getScenario("Demo").field.second.hand.drawCard(Card.CHARACTER, index);
									break;
								}
							
							Scenario.getScenario("Demo").field.first.addCardToBattlefield("Riverbank");
							
							Scenario.getScenario("Demo").field.second.getPlayedCards(Card.CHARACTER)[1].useAbility("ArrowVolley", Scenario.getScenario("Demo").field.first.getPlayedCards(Card.CHARACTER)[0]);
						} );
				});
		}
	}
}