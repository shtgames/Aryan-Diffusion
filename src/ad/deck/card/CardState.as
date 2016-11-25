package ad.deck.card 
{
	import ad.player.Player;
	import ad.deck.card.Card;
	
	public class CardState 
	{		
		public function CardState(card:String) 
		{
			if (!Card.exists(card)) return;
			
			const buffer:Card = Card.getCard(card);
			m_health = buffer.getHealth();
			m_attack = buffer.getAttack();
		}
		
		
		public function getCardKey():String
		{
			return m_key;
		}
		
		public function getHealth():uint
		{
			return m_health;
		}
		
		public function getAttack():uint
		{
			return m_attack;
		}
		
		public function setHealth(health:uint):CardState
		{
			m_health = health;
			return this;
		}
		
		public function setAttack(attack:uint):CardState
		{
			m_attack = attack;
			return this;
		}
		
		
		public function getParent():Player
		{
			return m_parent;
		}
		
		public function setParent(newParent:Player):CardState
		{
			m_parent = newParent;
			return this;
		}
		
		
		private var m_key:String = null;
		private var m_parent:Player = null;
		private var m_health:int = 0, m_attack:uint = 0;
	}
}