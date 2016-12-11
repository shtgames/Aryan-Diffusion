package ad.expression
{
	import ad.expression.TokenType;
	
	public class Token
	{
		public function Token(text:String, tokenType:TokenType)
		{
			m_text = text;
			m_type = tokenType;
		}		
		
		
		public function assign(other:Token):Token
		{
			if (other == null) return this;
			
			m_text = other.m_text;
			m_type = other.m_type;
			
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
		
		public function get length():uint
		{
			return m_text.length;
		}
		
		
		private var m_text:String;
		private var m_type:TokenType;
	}
}