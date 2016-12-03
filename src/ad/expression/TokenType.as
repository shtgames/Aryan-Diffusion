package ad.expression
{
	public class TokenType
	{		
		public function TokenType(pattern:RegExp, value:int) 
		{
			m_pattern = pattern;
			m_value = value;
		}
		
		
		public function get pattern():String { return m_pattern.source; }
		
		public function get ordinal():int { return m_value; }
		
		
		public function equals(other:TokenType):Boolean
		{
			return other != null && m_value == other.m_value;
		}
		
		public function matches(input:String):Object
		{
			if (m_pattern == null) return null;
			return m_pattern.exec(input);
		}		
		
		
		private var m_pattern:RegExp;
		private var m_value:int;
		
		
		public static const Whitespace:TokenType = new TokenType(/[ \t\r\n]+/, 0);
		
		public static const Terminator:TokenType = new TokenType(/;/, 1);
		public static const Delimiter:TokenType = new TokenType(/,/, 2);
		
		public static const OperatorBeginArguments:TokenType = new TokenType(/\(/, 3);
		public static const OperatorEndArguments:TokenType = new TokenType(/\)/, 4);
		public static const OperatorBeginData:TokenType = new TokenType(/{/, 5);
		public static const OperatorEndData:TokenType = new TokenType(/}/, 6);
		public static const OperatorBeginArrayAccess:TokenType = new TokenType(/\[/, 7);
		public static const OperatorEndArrayAccess:TokenType = new TokenType(/\]/, 8);
		
		public static const ExponentOperator:TokenType = new TokenType(/\^/, 9);
		public static const AdditionOperator:TokenType = new TokenType(/\+/, 10);
		public static const SubtractionOperator:TokenType = new TokenType(/\-/, 11);
		public static const MultiplicationOperator:TokenType = new TokenType(/\*/, 12);
		public static const DivisionOperator:TokenType = new TokenType(/\//, 13);
		public static const ModuloOperator:TokenType = new TokenType(/%/, 14);
		
		public static const StrictLessOperator:TokenType = new TokenType(/</, 15);
		public static const StrictGreaterOperator:TokenType = new TokenType(/>/, 16);
		public static const EqualityOperator:TokenType = new TokenType(/==/, 17);
		public static const InequalityOperator:TokenType = new TokenType(/!=/, 18);
		public static const LessOperator:TokenType = new TokenType(/<=/, 19);
		public static const GreaterOperator:TokenType = new TokenType(/>=/, 20);
		
		public static const IntegralNumber:TokenType = new TokenType(/([+-]?[0-9]+)/, 21);
		public static const FloatingPointNumber:TokenType = new TokenType(/[+-]?(?:[0-9]+)?[.][0-9]+/, 22);
		public static const StringLiteral:TokenType = new TokenType(/"[^"\\]*(?:\\.[^"\\]*)*"/, 23);
		
		public static const Identifier:TokenType = new TokenType(/[_a-zA-Z][a-zA-Z0-9_]*/, 24);
		
		private static const optionalWS:String = "[ \t\r\n]*";
		private static const paramList:String = "((?:" + Identifier.pattern + "|" + IntegralNumber.pattern + "|" +
			FloatingPointNumber.pattern + "|" + StringLiteral.pattern + ")(?:" + optionalWS + Delimiter.pattern +
			optionalWS + "(?:" + Identifier.pattern + "|" + IntegralNumber.pattern + "|" +	FloatingPointNumber.pattern + "|" +
			StringLiteral.pattern + "))*)";
			
		public static const FunctionCall:TokenType = new TokenType(new RegExp(Identifier.pattern + optionalWS + OperatorBeginArguments.pattern +
				optionalWS + paramList + "?" + optionalWS + OperatorEndArguments.pattern), 25);
		public static const ArrayAccess:TokenType = new TokenType(new RegExp(Identifier.pattern + optionalWS + OperatorBeginArrayAccess.pattern + 
				optionalWS + paramList + optionalWS + OperatorEndArrayAccess.pattern), 26);
		
	}
}