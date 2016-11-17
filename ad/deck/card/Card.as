package ad.deck.card 
{
	import flash.display.MovieClip;
	import ad.deck.card.Ability;
	
	public class Card extends MovieClip
	{		
		public static function loadFromFile(path:String):Card
		{
			
			return this;
		}
		
		public static const ACTIVE:uint = 0, PASSIVE:uint = 1, ON_SUMMON:uint = 2;
		
		
		public function Card() 
		{
			
		}
		
		
		public function addAbility(ability:Ability, type:uint):Card
		{
			switch (type)
			{
			case ACTIVE:
				m_active[ability.getName()] = ability;
			case PASSIVE:
				m_passive.push(ability);
			case ON_SUMMON:
				m_onSummon.push(ability);
			}
			
			return this;
		}
		
		
		private var m_background:MovieClip = null, m_portrait:MovieClip = null;
		
		private var m_name:String = null, m_description:String = null, m_race:String = null, m_type:String = null;
		private var m_health:int = 0, m_baseHealth:uint = 0, m_attack:uint = 0, m_baseAttack:uint = 0;
		
		private var m_onSummon:Vector.<Ability> = new Vector.<Ability>(),
			m_passive:Vector.<Ability> = new Vector.<Ability>(), m_active:Object = new Object();
	}
}