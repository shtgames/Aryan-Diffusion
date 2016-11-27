package ad.field 
{	
	import ad.player.Player;
	
	public class Field
	{		
		public function Field() {}
		
		
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
		
		
		private var m_first:Player = null, m_second:Player = null;
	}
}