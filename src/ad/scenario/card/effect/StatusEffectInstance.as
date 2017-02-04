package ad.scenario.card.effect 
{
	import ad.scenario.card.card.CardState;
	import ad.scenario.event.Event;
	import ad.scenario.event.EventType;
	import ad.scenario.event.EventDispatcher;
	import ad.map.Map;
	
	public class StatusEffectInstance
	{
		public function StatusEffectInstance(effect:StatusEffect, parent:CardState)
		{
			m_parent = parent;
			if ((m_effect = effect) != null)
				m_duration = m_effect.duration;
		}
		
		
		public function toString():String
		{
			return (m_effect == null ? "<Undefined>" : m_effect.toString()) + " (" + m_duration + "/" + m_stacks + ")";
		}
		
		public function apply():Boolean
		{
			if (m_effect == null)
				return false;
			if (m_stacks < m_effect.stackCap)
				return setStacks(m_stacks + 1), true;
			if (m_effect.refreshable)
				return setDuration(m_effect.duration), true;
			return false;
		}
		
		public function input(event:Event):void
		{
			if (m_parent == null || m_effect == null || m_effect.effect == null) 
				return;
			
			if (EventType.TurnEvent.equals(event.type) && event.data.at("player") == m_parent.parent && m_duration > 0)
				setDuration(m_duration - 1);
			m_effect.effect.call(this, event);
		}
		
		
		public function get effect():StatusEffect
		{
			return m_effect;
		}
		
		public function get duration():uint
		{
			return m_duration;
		}
		
		public function get stacks():uint
		{
			return m_stacks;
		}
		
		public function get persistent():Map
		{
			return m_persistent;
		}
		
		public function get parent():CardState
		{
			return m_parent;
		}
		
		
		public function setDuration(value:uint, source:Object = null):StatusEffectInstance
		{
			if (m_duration == value)
				return this;
			
			const previous:uint = m_duration;
			m_duration = value;
			EventDispatcher.pollEvent(new Event(EventType.StatusEffectEvent, new Map()
				.push("duration", true)
				.push("source", source)
				.push("previous", previous)
				.push("effect", this)));
			return this;
		}
		
		public function setStacks(value:uint, source:Object = null):StatusEffectInstance
		{
			if (m_stacks == value)
				return this;
			
			const previous:uint = m_stacks;
			m_stacks = value;
			EventDispatcher.pollEvent(new Event(EventType.StatusEffectEvent, new Map()
				.push("stacks", true)
				.push("source", source)
				.push("previous", previous)
				.push("effect", this)));
			return this;
		}
		
		
		private var m_effect:StatusEffect = null;
		private var m_duration:uint = 0, m_stacks:uint = 1;
		private var m_persistent:Map = new Map();
		private var m_parent:CardState = null;
	}
}