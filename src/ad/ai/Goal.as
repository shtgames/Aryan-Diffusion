package ad.ai 
{
	import utils.map.Map;
	
	public class Goal 
	{
		public function Goal(type:GoalType, data:Map)
		{
			m_type = type;
			m_data = data;
		}
		
		
		public function toString():String
		{
			return (m_type != null ? m_type.toString() : "N/A") + ": " + (m_data != null ? m_data.toString() : "N/A");
		}
		
		public function get type():GoalType
		{
			return m_type;
		}
		
		public function get data():Map
		{
			return m_data;
		}
		
		public function isValid():Boolean
		{
			return m_type != null && m_data != null;
		}
		
		
		private var m_type:GoalType;
		private var m_data:Map;
	}
}