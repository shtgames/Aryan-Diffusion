package ad.expression
{
	import ad.expression.TokenType;
	
	public class Token
	{
		public function Token(text:String, tokenType:TokenType, index:uint = 0)
		{
			m_text = text;
			m_type = tokenType;
			m_index = index;
		}		
		
		
		public function assign(other:Token):Token
		{
			if (other == null) return this;
			
			m_text = other.m_text;
			m_type = other.m_type;
			m_index = other.m_index;
			
			return this;
		}
		
		
		public function get text():String
		{
			return m_text;
		}
		
		public function get type():TokenType
		{
			return m_type;
		}
		
		public function get index():uint
		{
			return m_index;
		}
		
		public function get length():uint
		{
			return m_text.length;
		}
		
		
		private var m_text:String;
		private var m_type:TokenType;
		private var m_index:int;
	}
}