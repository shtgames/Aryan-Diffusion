package ad.ai 
{
	import ad.scenario.Scenario;
	import ad.scenario.card.Hand;
	import ad.scenario.card.card.Card;
	import ad.scenario.card.effect.AbilityInstance;
	import ad.scenario.player.Player;
	
	public class AI 
	{
		public function AI(player:Player) 
		{
			m_player = player;
		}
		
		
		public function get player():Player
		{
			return m_player;
		}
		
		public function get goals():Vector.<Goal>
		{
			return m_goals;
		}
		
		public function hasGoal(method:Function):Boolean
		{
			for each (var goal:Goal in m_goals)
				if (method.call(null, goal))
					return true;
			return false;
		}
		
		public function nextMove():void
		{
			if (Scenario.current == null || m_player == null || Scenario.current.field.current != m_player)
				return;
			
			var score:uint = 0, buffer:uint;
			var card:Card = null, secondaryBuffer:Card, hand:Hand = m_player.hand;
			
			for (var type:uint = Card.CHARACTER, last:uint = Card.HABITAT; type <= last; ++type)
				for (var i:uint = 0, end:uint = hand.cardCount(type); i != end; ++i)
					if ((buffer = (secondaryBuffer = hand.getCard(type, i)).AIEvaluation(this)) > score)
					{
						score = buffer;
						card = secondaryBuffer;
					}
			
			var target:TargetScore = new TargetScore(score), targetBuffer:TargetScore;
			for (var i:uint = 0, end:uint = hand.cardCount(Card.SUPPORT); i != end; ++i)
				if ((targetBuffer = (secondaryBuffer = hand.getCard(Card.SUPPORT, i)).AIEvaluation(this)).score > target.score)
				{
					target = targetBuffer;
					card = secondaryBuffer;
				}
			
			if (card != null && (card.type != Card.SUPPORT || target.target != null))
			{
				m_player.hand.playCard(card, target.target);
				return;
			}
			
			var ability:AbilityInstance = null;
			target = new TargetScore();
			
			for (var type:uint = Card.CHARACTER, last:uint = Card.SUPPORT; type <= last; ++type)
				for (var i:uint = 0, end:uint = m_player.getPlayedCardCount(type); i != end; ++i)
					for each (var it:AbilityInstance in m_player.getPlayedCard(type, i).abilities)
						if ((targetBuffer = it.AIEvaluation(this)).score > target.score)
						{
							target = targetBuffer;
							ability = it;
						}
			
			if (ability != null)
				ability.useOn(target.target);
			else m_player.parent.parent.endTurn();
		}
		
		
		private const m_goals:Vector.<Goal> = new Vector.<Goal>();
		private var m_player:Player;
	}
}