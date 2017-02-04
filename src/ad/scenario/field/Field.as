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
			m_current = m_first;
		}
		
		
		public function toString():String
		{
			return "<Field>";
		}
		
		public function input(event:Event):void
		{
			m_first.input(event);
			m_second.input(event);
			
			m_first.cull();
			m_second.cull();
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
		
		public function get current():Player
		{
			return m_current;
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
		
		public function swapCurrent():Player
		{
			return m_current = getOther(m_current);
		}
		
		
		private var m_first:Player, m_second:Player, m_current:Player;
		private var m_parent:Scenario;
	}
}