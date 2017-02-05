package ad.ai 
{
	import ad.scenario.card.card.CardState;
	
	public class TargetScore 
	{
		public function TargetScore(score:uint = 0, target:CardState = null)
		{
			this.score = score;
			this.target = target;
		}
		
		public var target:CardState = null, score:uint = 0;
	}
}