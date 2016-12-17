package ad.event 
{
	public class Event 
	{
		public function Event() {}		
		
		public var type:EventType = null;
		public var turnBegan:TurnBeganEvent = null;
		public var turnEnded:TurnEndedEvent = null;
		public var cardDrawn:CardDrawnEvent = null;
		public var cardPlayed:CardPlayedEvent = null;
		public var cardAttacked:CardAttackedEvent = null;
		public var abilityUsed:AbilityUsedEvent = null;
	}
}