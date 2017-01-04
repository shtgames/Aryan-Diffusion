package ad.expression
{
	import ad.map.Map;
	
	public class TokenType
	{		
		public function TokenType(pattern:RegExp, value:int, name:String, evaluation:Function = null) 
		{
			m_pattern = pattern;
			m_value = value;
			m_name = name;
			m_evaluation = evaluation;
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
		
		public function evaluate(parent:ParseNode, context:Object):Object
		{
			return m_evaluation == null ? null : m_evaluation.call(parent, context);
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
		private var m_evaluation:Function;
		
		
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
			case 17: return AssignmentOperator;
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
			case 28: return StartOfInput;
			case 29: return EndOfInput;
			}
			return null;
		}
		
		public static function size():uint
		{
			return 30;
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
		
		public static const ExponentOperator:TokenType = new TokenType(/^\^/, 9, "<Exponent Operator>", 
			function(context:Object) : Number 
			{
				return this.getChildCount() < 2 ? 0 : Math.pow(Number(this.getChild(0).evaluate(context)), Number(this.getChild(1).evaluate(context)));
			} );
		public static const AdditionOperator:TokenType = new TokenType(/^\+/, 10, "<Addition Operator>", 
			function(context:Object) : Object 
			{
				return this.getChildCount() == 2 ? this.getChild(0).evaluate(context) + this.getChild(1).evaluate(context) :
					(this.getChildCount() == 1 ? this.getChild(0).evaluate(context) : null);
			} );
		public static const SubtractionOperator:TokenType = new TokenType(/^-/, 11, "<Subtraction Operator>", 
			function(context:Object) : Number 
			{
				return this.getChildCount() == 2 ? Number(this.getChild(0).evaluate(context)) - Number(this.getChild(1).evaluate(context)) :
					(this.getChildCount() == 1 ? (-1) * Number(this.getChild(0).evaluate(context)) : 0);
			} );
		public static const MultiplicationOperator:TokenType = new TokenType(/^\*/, 12, "<Multiplication Operator>", 
			function(context:Object) : Number 
			{
				return this.getChildCount() < 2 ? 0 : Number(this.getChild(0).evaluate(context)) * Number(this.getChild(1).evaluate(context));
			} );
		public static const DivisionOperator:TokenType = new TokenType(/^\//, 13, "<Division Operator>", 
			function(context:Object) : Number 
			{
				return this.getChildCount() < 2 ? 0 : Number(this.getChild(0).evaluate(context)) / Number(this.getChild(1).evaluate(context));
			} );
		public static const ModuloOperator:TokenType = new TokenType(/^%/, 14, "<Modulo Operator>", 
			function(context:Object) : Number 
			{
				return this.getChildCount() < 2 ? 0 : Number(this.getChild(0).evaluate(context)) % Number(this.getChild(1).evaluate(context));
			} );
		
		public static const StrictLessOperator:TokenType = new TokenType(/^<(?!=)/, 15, "<Less-Than Operator>", 
			function(context:Object) : Boolean 
			{
				return this.getChildCount() < 2 ? false : Number(this.getChild(0).evaluate(context)) < Number(this.getChild(1).evaluate(context));
			} );
		public static const StrictGreaterOperator:TokenType = new TokenType(/^>(?!=)/, 16, "<Greater-Than Operator>", 
			function(context:Object) : Boolean 
			{
				return this.getChildCount() < 2 ? false : Number(this.getChild(0).evaluate(context)) > Number(this.getChild(1).evaluate(context));
			} );
		public static const AssignmentOperator:TokenType = new TokenType(/^=(?!=)/, 17, "<Assignment Operator>", 
			function(context:Object) : Object 
			{
				return this.getChildCount() < 2 || context == null || this.getChild(0).token == null || this.getChild(0).token.type == null || !this.getChild(0).token.type.equals(Identifier) ?
					null : context[this.getChild(0).token.text] = this.getChild(1).evaluate(context);
			} );
		public static const InequalityOperator:TokenType = new TokenType(/^!=/, 18, "<Inequality Operator>", 
			function(context:Object) : Boolean 
			{
				return this.getChildCount() < 2 ? false : this.getChild(0).evaluate(context) != this.getChild(1).evaluate(context);
			} );
		public static const NonStrictLessOperator:TokenType = new TokenType(/^<=/, 19, "<Less-Than-Or-Equal Operator>", 
			function(context:Object) : Boolean 
			{
				return this.getChildCount() < 2 ? false : Number(this.getChild(0).evaluate(context)) <= Number(this.getChild(1).evaluate(context));
			} );
		public static const NonStrictGreaterOperator:TokenType = new TokenType(/^>=/, 20, "<Greater-Than-Or-Equal Operator>", 
			function(context:Object) : Boolean 
			{
				return this.getChildCount() < 2 ? false : Number(this.getChild(0).evaluate(context)) >= Number(this.getChild(1).evaluate(context));
			} );
		public static const MemberAccessOperator:TokenType = new TokenType(/^\.(?![0-9])/, 21, "<Member-Access Operator>", 
			function(context:Object) : Object 
			{
				return this.getChildCount() < 2 ? null : this.getChild(1).evaluate(this.getChild(0).evaluate(context));
			} );
		
		private static const forbiddenNumberPostfix:String = "(?![_a-zA-Z0-9\.])";
		
		public static const IntegralNumber:TokenType = new TokenType(new RegExp("^[0-9]+" + forbiddenNumberPostfix), 22, "<Integral Number>", 
			function(context:Object) : int 
			{
				return this.token == null ? 0 : parseInt(this.token.text);
			} );
		public static const FloatingPointNumber:TokenType = new TokenType(new RegExp("^(?:(?:[0-9]*[\.][0-9]+)|(?:[0-9]+[\.][0-9]*))" + forbiddenNumberPostfix), 23, "<Floating-Point Number>", 
			function(context:Object) : Number 
			{
				return this.token == null ? 0 : parseFloat(this.token.text);
			} );
		public static const StringLiteral:TokenType = new TokenType(/(?<=^")[^"\\]*(?:\\.[^"\\]*)*(?=")/, 24, "<String Literal>", 
			function(context:Object) : String 
			{
				return this.token == null ? null : this.token.text;
			} );
		
		public static const Identifier:TokenType = new TokenType(new RegExp("^[_a-zA-Z][a-zA-Z0-9_]*"), 25, "<Identifier>", 
			function(context:Object) : Object 
			{
				return context == null || this.token == null ? null : context[this.token.text];
			} );
		
		public static const FunctionCall:TokenType = new TokenType(null, 26, "<Function Call>", 
			function(context:Object) : Object 
			{
				if (context == null || this.getChildCount() == 0) return null;
				
				const method:Function = this.getChild(0).evaluate(context);
				if (method == null) return null;
				
				const methodArguments:Array = new Array();
				
				for (var it:uint = 1, end:uint = this.getChildCount(); it != end; ++it)
					methodArguments.push(this.getChild(it).evaluate(context));
				
				return method.apply(null, methodArguments);
			} );
		public static const ArrayAccess:TokenType = new TokenType(null, 27, "<Array Access>", 
			function(context:Object) : Object 
			{
				if (context == null || this.getChildCount() == 0) return null;
				
				const array:Object = this.getChild(0).evaluate(context);
				if (array == null) return null;
				
				const arrayAccessArguments:Array = new Array();
				
				for (var it:uint = 1, end:uint = this.getChildCount(); it != end; ++it)
					arrayAccessArguments.push(this.getChild(it).evaluate(context));
				
				return array[arrayAccessArguments];
			} );
		
		public static const StartOfInput:TokenType = new TokenType(null, 28, "<Start of Input>");
		public static const EndOfInput:TokenType = new TokenType(null, 29, "<End of Input>");
	}
}