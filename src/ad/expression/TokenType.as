package ad.expression
{
	public class TokenType
	{		
		public function TokenType(pattern:RegExp, value:int, name:String) 
		{
			m_pattern = pattern;
			m_value = value;
			m_name = name;
		}
		
		
		public function toString():String
		{
			return m_name == null ? "<Undefined>" : m_name;
		}
		
		public function equals(other:TokenType):Boolean
		{
			return other != null && m_value == other.m_value;
		}
		
		public function matches(input:String):Object
		{
			if (m_pattern == null) return null;
			return m_pattern.exec(input);
		}		
		
		
		public function get pattern():String 
		{ 
			return m_pattern.source;
		}
		
		public function get ordinal():int
		{
			return m_value;
		}
		
		public function get name():String
		{
			return m_name;
		}
		
		
		private function get _pattern():String 
		{
			return m_pattern == null || m_pattern.source == null || m_pattern.source.length <= 1 ?
				null : m_pattern.source.substring(1);
		}
		
		
		private var m_pattern:RegExp;
		private var m_value:int;
		private var m_name:String;
		
		
		public static function at(index:uint):TokenType
		{
			switch (index)
			{
			case 0: return Whitespace;
			case 1: return Terminator;
			case 2: return Delimiter;
			case 3: return OperatorBeginArguments;
			case 4: return OperatorEndArguments;
			case 5: return OperatorBeginData;
			case 6: return OperatorEndData;
			case 7: return OperatorBeginArrayAccess;
			case 8: return OperatorEndArrayAccess;
			case 9: return ExponentOperator;
			case 10: return AdditionOperator;
			case 11: return SubtractionOperator;
			case 12: return MultiplicationOperator;
			case 13: return DivisionOperator;
			case 14: return ModuloOperator;
			case 15: return StrictLessOperator;
			case 16: return StrictGreaterOperator;
			case 17: return EqualityOperator;
			case 18: return InequalityOperator;
			case 19: return NonStrictLessOperator;
			case 20: return NonStrictGreaterOperator;
			case 21: return MemberAccessOperator;
			case 22: return IntegralNumber;
			case 23: return FloatingPointNumber;
			case 24: return StringLiteral;
			case 25: return Identifier;
			case 26: return FunctionCall;
			case 27: return ArrayAccess;
			case 28: return ArrayInitialization;
			case 29: return StartOfInput;
			case 30: return EndOfInput;
			}
			return null;
		}
		
		public static function size():uint
		{
			return 31;
		}
		
		
		public static const Whitespace:TokenType = new TokenType(/^[ \t\r\n]+/, 0, "<Whitespace>");
		
		public static const Terminator:TokenType = new TokenType(/^;/, 1, "<Terminator>");
		public static const Delimiter:TokenType = new TokenType(/^,/, 2, "<Delimiter>");
		
		public static const OperatorBeginArguments:TokenType = new TokenType(/^\(/, 3, "<Operator Begin Arguments>");
		public static const OperatorEndArguments:TokenType = new TokenType(/^\)/, 4, "<Operator End Arguments>");
		public static const OperatorBeginData:TokenType = new TokenType(/^{/, 5, "<Operator Begin Data>");
		public static const OperatorEndData:TokenType = new TokenType(/^}/, 6, "<Operator End Data>");
		public static const OperatorBeginArrayAccess:TokenType = new TokenType(/^\[/, 7, "<Operator Begin Array Access>");
		public static const OperatorEndArrayAccess:TokenType = new TokenType(/^]/, 8, "<Operator End Array Access>");
		
		public static const ExponentOperator:TokenType = new TokenType(/^\^/, 9, "<Exponent Operator>");
		public static const AdditionOperator:TokenType = new TokenType(/^\+/, 10, "<Addition Operator>");
		public static const SubtractionOperator:TokenType = new TokenType(/^-/, 11, "<Subtraction Operator>");
		public static const MultiplicationOperator:TokenType = new TokenType(/^\*/, 12, "<Multiplication Operator>");
		public static const DivisionOperator:TokenType = new TokenType(/^\//, 13, "<Division Operator>");
		public static const ModuloOperator:TokenType = new TokenType(/^%/, 14, "<Modulo Operator>");
		
		public static const StrictLessOperator:TokenType = new TokenType(/^<(?!=)/, 15, "<Less-Than Operator>");
		public static const StrictGreaterOperator:TokenType = new TokenType(/^>(?!=)/, 16, "<Greater-Than Operator>");
		public static const EqualityOperator:TokenType = new TokenType(/^=/, 17, "<Equality Operator>");
		public static const InequalityOperator:TokenType = new TokenType(/^!=/, 18, "<Inequality Operator>");
		public static const NonStrictLessOperator:TokenType = new TokenType(/^<=/, 19, "<Less-Than-Or-Equal Operator>");
		public static const NonStrictGreaterOperator:TokenType = new TokenType(/^>=/, 20, "<Greater-Than-Or-Equal Operator>");
		public static const MemberAccessOperator:TokenType = new TokenType(/^\.[^0-9]/, 21, "<Member-Access Operator>");
		
		private static const forbiddenNumberPostfix:String = "(?![_a-zA-Z0-9\.])";
		
		public static const IntegralNumber:TokenType = new TokenType(new RegExp("^[+-]?[0-9]+" + forbiddenNumberPostfix), 22, "<Integral Number>");
		public static const FloatingPointNumber:TokenType = new TokenType(new RegExp("^[+-]?(?:(?:[0-9]*[\.][0-9]+)|(?:[0-9]+[\.][0-9]*))" + forbiddenNumberPostfix), 23, "<Floating-Point Number>");
		public static const StringLiteral:TokenType = new TokenType(/(?<=^")[^"\\]*(?:\\.[^"\\]*)*(?=")/, 24, "<String Literal>");
		
		private static const optionalWS:String = "[ \t\r\n]*";
		private static const identifierName:String = "[_a-zA-Z][a-zA-Z0-9_]*";
		
		public static const Identifier:TokenType = new TokenType(new RegExp("^" + identifierName + "(?=" + optionalWS + "[^" + OperatorBeginArguments._pattern + OperatorBeginArrayAccess._pattern +
			OperatorBeginData._pattern + "a-zA-Z0-9_])"), 25, "<Identifier>");
		
		public static const FunctionCall:TokenType = new TokenType(new RegExp("^" + identifierName + "(?=" + optionalWS + OperatorBeginArguments._pattern + ")"), 26, "<Function Call>");
		public static const ArrayAccess:TokenType = new TokenType(new RegExp("^" + identifierName  + "(?=" + optionalWS + OperatorBeginArrayAccess._pattern + ")"), 27, "<Array Access>");
		public static const ArrayInitialization:TokenType = new TokenType(new RegExp("^" + identifierName + "(?=" + optionalWS + OperatorBeginData._pattern + ")"), 28, "<Array Initialization>");
		
		public static const StartOfInput:TokenType = new TokenType(null, 29, "<Start of Input>");
		public static const EndOfInput:TokenType = new TokenType(null, 30, "<End of Input>");
	}
}