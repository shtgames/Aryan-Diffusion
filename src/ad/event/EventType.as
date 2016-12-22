package ad.event 
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
		
		
		public static const TurnEvent:EventType = new EventType(0, "<Turn Event>");
		public static const DeckEvent:EventType = new EventType(1, "<Deck Event>");
		public static const HandEvent:EventType = new EventType(2, "<Hand Event>");
		public static const BattlefieldEvent:EventType = new EventType(3, "<Battlefield Event>");
		public static const CardEvent:EventType = new EventType(4, "<Card Event>");
	}
}