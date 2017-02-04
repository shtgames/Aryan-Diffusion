package ad.scenario.card.effect 
{
	import ad.scenario.Scenario;
	import ad.scenario.card.card.CardState;
	import ad.scenario.event.EventDispatcher;
	import ad.scenario.event.EventType;
	import ad.scenario.event.Event;
	import ad.map.Map;
	
	public class AbilityInstance 
	{
		public function AbilityInstance(ability:Ability, parent:CardState)
		{
			m_parent = parent;
			if ((m_ability = ability) != null)
				m_charges = m_ability.charges - 1;
		}
		
		
		public function toString():String
		{
			return m_ability == null ? "<Undefined>" : m_ability.toString();
		}
		
		public function get cooldown():uint
		{
			return m_cooldown;
		}
		
		public function get charges():uint
		{
			return m_charges;
		}
		
		public function get ability():Ability
		{
			return m_ability;
		}
		
		public function get persistent():Map
		{
			return m_persistent;
		}
		
		public function get parent():CardState
		{
			return m_parent;
		}
		
		
		public function setCooldown(value:uint, source:Object = null):AbilityInstance
		{
			if (m_cooldown == value)
				return this;
			
			const previous:uint = m_cooldown;
			m_cooldown = value;
			EventDispatcher.pollEvent(new Event(EventType.AbilityEvent, new Map()
				.push("cooldown", true)
				.push("source", source)
				.push("previous", previous)
				.push("ability", this)));
			
			if (m_cooldown == 0 && m_charges < m_ability.charges)
				setCharges(m_charges + 1);
			return this;
		}
		
		public function setCharges(value:uint, source:Object = null):AbilityInstance
		{
			if (m_charges == value)
				return this;
			
			const previous:uint = m_charges;
			m_charges = value;
			EventDispatcher.pollEvent(new Event(EventType.AbilityEvent, new Map()
				.push("charges", true)
				.push("source", source)
				.push("previous", previous)
				.push("ability", this)));
			
			if (m_charges < m_ability.charges)
				setCooldown(m_ability.cooldown);
			return this;
		}
		
		public function input(event:Event):void
		{
			if (m_parent == null || m_ability == null) 
				return;
			
			if (m_cooldown > 0 && event.type.equals(EventType.TurnEvent) && event.data.at("player") == m_parent.parent)
				setCooldown(m_cooldown - 1);
		}
		
		public function useOn(target:CardState = null):void
		{
			if (m_charges == 0 || m_parent == null || m_ability == null || m_ability.effect == null || (target == null && m_ability.targets != 0) || Scenario.current.field.current != m_parent.parent) 
				return;
			
			setCharges(m_charges - 1);
			m_ability.effect.call(this, target);
		}
		
		
		private var m_cooldown:uint = 1, m_charges:uint = 1;
		private var m_ability:Ability = null;
		private var m_persistent:Map = new Map();
		private var m_parent:CardState = null;
	}
}