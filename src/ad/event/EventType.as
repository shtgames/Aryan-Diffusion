package ad.event 
{
	public class EventType 
	{		
		public function EventType(id:uint, name:String) 
		{
			m_id = id;
			m_name = name;
		}
		
		
		public function equals(other:EventType)
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
		
		
		public static const TurnBegan:EventType = new EventType(0, "<Turn Began>");
		public static const TurnEnded:EventType = new EventType(1, "<Turn Ended>");
		public static const CardDrawn:EventType = new EventType(2, "<Card Drawn>");
		public static const CardPlayed:EventType = new EventType(3, "<Card Played>");
		public static const CardAttacked:EventType = new EventType(4, "<Card Attacked>");
		public static const AbilityUsed:EventType = new EventType(5, "<Ability Used>");
	}
}