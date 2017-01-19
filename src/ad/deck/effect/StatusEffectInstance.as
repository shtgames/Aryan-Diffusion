package ad.deck.effect 
{
	import ad.deck.card.CardState;
	import ad.event.Event;
	import ad.event.EventType;
	import ad.event.EventListener;
	
	public class StatusEffectInstance extends EventListener
	{
		override public function input(event:Event):void
		{
			if (m_parent == null || event == null || !event.isValid() || !StatusEffect.exists(m_effect)) 
				return;
			StatusEffect.getEffect(m_effect).input(this, event);
			if (EventType.TurnEvent.equals(event.type))
				m_duration--;
		}
		
		
		public function get effect():String
		{
			return m_effect;
		}
		
		public function get duration():uint
		{
			return m_duration;
		}
		
		public function get parent():CardState
		{
			return m_parent;
		}
		
		
		public function setEffect(effectKey:String):StatusEffectInstance
		{
			m_effect = effectKey;
			return this;
		}
		
		public function setDuration(turnDuration:uint):StatusEffectInstance
		{
			m_duration = turnDuration;
			return this;
		}
		
		public function setParent(parentCard:CardState):StatusEffectInstance
		{
			m_parent = parentCard;
			return this;
		}
		
		
		private var m_effect:String = null;
		private var m_duration:uint = 0;
		private var m_parent:CardState = null;
	}
}