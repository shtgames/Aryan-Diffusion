package ad.expression
{
	import ad.expression.TokenType;
	import ad.expression.Token;

	public class Lexer
	{
		public function Lexer(input:String)
		{
			this.m_input = input;
		}
		
		
		public function process():Boolean
		{
			if (m_input == null) return false;
			
			while (!done())
				if (!next()) return false;			
			return true;
		}
		
		
		public function get tokens():Vector.<Token>
		{
			return m_tokens;
		}
		
		public function done():Boolean
		{
			return m_current >= m_input.length;
		}
		
		
		private function next():Boolean
		{
			const source:String = m_input.substring(m_current);
			if (source == null) return false;
			
			var result:Object = null;
			var i:uint = 0;
			for (end:uint = TokenType.size(); i != end && result == null; ++i)
				result = TokenType.at(i).matches(source);
			
			if (result == null)
			{
				trace("Failed to recognize character '" + source.charAt(0) + "' at position " + m_current +
					" within the input string \"" + m_input + "\".");
				return false;
			}
			
			const token:Token = new Token(result[0], TokenType.at(i), m_current);
			m_current += (token.length == 0 ? 1 : token.length);
			
			if (token.type != TokenType.Whitespace)	m_tokens.push(token);
			
			return true;
		}
		
		
		private var m_current:uint;
		private var m_input:String;
		private var m_tokens:Vector.<Token>;
	}
}