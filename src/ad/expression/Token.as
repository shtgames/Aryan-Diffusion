package ad.expression
{
	import ad.expression.TokenType;
	
	public class Token
	{
		public function Token(text:String, tokenType:TokenType, index:int = 0)
		{
			m_text = text;
			m_type = tokenType;
			m_index = index;
		}		
		
		public function getText():String
		{
			return m_text;
		}
		
		public function getType():TokenType
		{
			return m_type;
		}
		
		public function getIndex():int
		{
			return m_index;
		}
		
		public function getLength():int
		{
			return m_text.length() + (m_type == TokenType.String ? 2 : 0);
		}
		
		
		public function setText(value:String):Token
		{
			m_text = value;
			return this;
		}		
		
		public function setIndex(value:int):Token
		{
			m_index = value;
			return this;
		}
		
		
		public function assign(other:Token):Token
		{
			if (other == null) return this;
			
			m_text = other.m_text;
			m_type = other.m_type;
			m_index = other.m_index;
			
			return this;
		}
		
		public function toString():String
		{
			return "\"" + m_text + "\" - [" + m_type.ordinal + "]";
		}
		
		
		private var m_text:String;
		private var m_type:TokenType;
		private var m_index:int;
	}
}