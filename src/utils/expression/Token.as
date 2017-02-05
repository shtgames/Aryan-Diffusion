package utils.expression
{
	import utils.expression.TokenType;
	
	public class Token
	{
		public function Token(text:String, tokenType:TokenType)
		{
			m_text = text;
			m_type = tokenType;
		}		
		
		
		public function toString():String
		{
			return (m_type == null ? "<Undefined>" : m_type) + (m_text == null ? "" : ": \"" + m_text + "\"");
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
			return m_text.length + (m_type != null && m_type.equals(TokenType.StringLiteral) ? 2 : 0);
		}
		
		
		private var m_text:String;
		private var m_type:TokenType;
	}
}