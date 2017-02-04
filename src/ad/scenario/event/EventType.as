package ad.scenario.event 
{
	public class EventType 
	{		
		public function EventType(id:uint, name:String) 
		{
			m_id = id;
			m_name = name;
		}
		
		
		public function equals(other:EventType):Boolean
		{
			return other != null && m_id == other.m_id;
		}
		
		public function toString():String
		{
			return m_name;
		}
		
		
		public function get id():uint
		{
			return m_id;
		}
		
		public function get name():String
		{
			return m_name;
		}
		
		
		private var m_id:uint;
		private var m_name:String;
		
		
		public static const GameEvent:EventType = new EventType(0, "<Game Event>");
		public static const TurnEvent:EventType = new EventType(1, "<Turn Event>");
		public static const DeckEvent:EventType = new EventType(2, "<Deck Event>");
		public static const HandEvent:EventType = new EventType(3, "<Hand Event>");
		public static const FieldEvent:EventType = new EventType(4, "<Field Event>");
		public static const CardEvent:EventType = new EventType(5, "<Card Event>");
		public static const AbilityEvent:EventType = new EventType(6, "<Ability Event>");
		public static const StatusEffectEvent:EventType = new EventType(7, "<Status-Effect Event>");
	}
}