package ad.deck.effect 
{
	import ad.deck.card.CardState;
	import ad.event.Event;
	import ad.event.EventListener;
	
	public class StatusEffectState extends EventListener
	{
		public function StatusEffectState() {}
		
		override public function input(event:Event):void
		{
			if (m_parent == null || m_effectKey == null || event == null || !event.isValid() || StatusEffect.getEffect(m_effectKey).getEventEffect(event.type) == null) 
				return;
		}
		
		
		private var m_effectKey:String = null;
		private var m_duration:uint = 0;
		private var m_parent:CardState = null;
	}
}