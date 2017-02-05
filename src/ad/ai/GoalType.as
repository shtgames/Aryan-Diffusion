package ad.ai 
{
	public class GoalType 
	{
		public function GoalType(name:String) 
		{
			m_name = name;
		}
		
		
		public function toString():String
		{
			return m_name == null ? "<Undefined>" : m_name;
		}
		
		public function get name():String
		{
			return m_name;
		}
		
		
		private var m_name:String;
		
		
		public static const DestroyCard:GoalType = new GoalType("<Destroy Card>");
	}
}