package ad.scenario.card.effect 
{
	import ad.scenario.card.card.CardState;
	import ad.scenario.event.Event;
	
	public class AbilityInstance 
	{
		public function AbilityInstance(ability:Ability, parent:CardState)
		{
			m_parent = parent;
			m_ability = ability;
		}
		
		
		public function toString():String
		{
			return m_ability == null ? "<Undefined>" : m_ability.toString();
		}
		
		public function useOn(target:CardState):void
		{
			if (m_parent == null || m_ability == null || m_ability.effect == null || target == null || !m_parent.parent.parent.isCurrent(m_parent.parent)) 
				return;
			
			m_ability.effect.call(this, target);
		}
		
		public function get ability():Ability
		{
			return m_ability;
		}
		
		public function get parent():CardState
		{
			return m_parent;
		}
		
		
		private var m_ability:Ability = null;
		private var m_parent:CardState = null;
	}
}