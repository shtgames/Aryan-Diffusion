package ad.expression
{
	import ad.expression.TokenType;
	import ad.expression.Token;

	public class Lexer
	{
		public function Lexer(input:String = null)
		{
			setInput(input);
		}
		
		
		public function setInput(input:String):Lexer
		{
			if (input == null) return this;
			
			m_input = input;
			m_current = 0;
			m_tokens = null;
			return this;
		}
		
		public function process():Vector.<Token>
		{
			if (m_input == null) return null;
			
			m_tokens = new <Token> [ new Token("^", TokenType.StartOfInput) ];			
			while (!done())
				if (!next()) return m_tokens = null;
			
			m_tokens.push(new Token("$", TokenType.EndOfInput));
			
			return m_tokens;
		}
		
		
		public function get tokens():Vector.<Token>
		{
			return m_tokens;
		}
		
		public function done():Boolean
		{
			return m_input != null && m_current >= m_input.length;
		}
		
		
		private function next():Boolean
		{
			if (done()) return false;
			
			const source:String = m_input.substring(m_current);
			var result:Object = null;
			var i:uint = 0;
			
			for (var end:uint = TokenType.size(); i != end && result == null; ++i)
				result = TokenType.at(i).matches(source);
			
			if (result == null)
			{
				trace("Error: Unrecognized token '" + source.charAt(0) + "' at position " + m_current +
					" in \"" + m_input + "\".");
				return false;
			}
			
			i--;
			const token:Token = new Token(result[0], TokenType.at(i));
			m_current += (token.length == 0 ? 1 : token.length);
			
			if (token.type != TokenType.Whitespace)	m_tokens.push(token);
			
			return true;
		}
		
		
		private var m_current:uint;
		private var m_input:String;
		private var m_tokens:Vector.<Token>;
	}
}