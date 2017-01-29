package ad.scenario.field 
{	
	import ad.scenario.Scenario;
	import ad.scenario.event.Event;
	import ad.scenario.player.Player;
	
	public class Field
	{
		public function Field(parentValue:Scenario)
		{
			m_parent = parentValue;
			m_first = new Player(this);
			m_second = new Player(this);
		}
		
		
		public function input(event:Event):void
		{
			if (m_first != null)
				m_first.input(event);
			if (m_second != null)
				m_second.input(event);
		}
		
		
		public function get parent():Scenario
		{
			return m_parent;
		}
		
		public function get first():Player
		{
			return m_first;
		}
		
		public function get second():Player
		{
			return m_second;
		}
		
		public function getOther(player:Player):Player
		{
			if (player != m_first)
			{
				if (player != m_second) return null;
				return m_first;
			}
			if (player != m_second) return m_second;
			return null;
		}
		
		
		private var m_first:Player, m_second:Player;
		private var m_parent:Scenario;
	}
}