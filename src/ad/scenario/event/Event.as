package ad.scenario.event 
{
	import ad.scenario.event.EventType;
	import utils.map.Map;
	
	public class Event
	{
		public function Event(type:EventType, data:Map)
		{
			m_type = type;
			m_data = data;
		}
		
		
		public function toString():String
		{
			return (m_type != null ? m_type.toString() : "N/A") + ": " + (m_data != null ? m_data.toString() : "N/A");
		}
		
		public function get type():EventType
		{
			return m_type;
		}
		
		public function get data():Map
		{
			return m_data;
		}
		
		public function isValid():Boolean
		{
			return type != null && data != null;
		}
		
		
		private var m_type:EventType;
		private var m_data:Map;
	}
}