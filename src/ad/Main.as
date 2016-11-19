package ad
{
	import flash.concurrent.Mutex;
	import flash.display.MovieClip;
	import ad.deck.card.Card;
	import ad.map.HashMap;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class Main extends MovieClip
	{		
		public function Main()
		{
			Card.loadResources("../resources/cards/definitions.dir");
			
			var timer:Timer = new Timer(500);
			timer.addEventListener(TimerEvent.TIMER, function():void 
				{
					for each(var card:Card in Card.cards)
						trace(card.getName());
				});
			timer.start();			
		}
	}	
}