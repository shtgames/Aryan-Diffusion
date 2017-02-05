package ad.scenario.event 
{
	public class EventType 
	{		
		public function EventType(name:String) 
		{
			m_name = name;
		}
		
		public function toString():String
		{
			return m_name;
		}
		
		public function get name():String
		{
			return m_name;
		}
		
		private var m_name:String;
		
		
		public static const GameEvent:EventType = new EventType("<Game Event>");
		public static const TurnEvent:EventType = new EventType("<Turn Event>");
		public static const DeckEvent:EventType = new EventType("<Deck Event>");
		public static const HandEvent:EventType = new EventType("<Hand Event>");
		public static const FieldEvent:EventType = new EventType("<Field Event>");
		public static const CardEvent:EventType = new EventType("<Card Event>");
		public static const AbilityEvent:EventType = new EventType("<Ability Event>");
		public static const StatusEffectEvent:EventType = new EventType("<Status-Effect Event>");
	}
}