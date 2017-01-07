package ad.expression
{
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
		
		public function evaluate(parent:ParseNode, scope:Object, context:Object):Object
		{
			return m_evaluation == null ? null : m_evaluation.call(parent, scope, context);
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
			
			case 9: return LogicalNegationOperator;
			
			case 10: return AdditionOperator;
			case 11: return SubtractionOperator;
			
			case 12: return MultiplicationOperator;
			case 13: return DivisionOperator;
			case 14: return ModuloOperator;
			case 15: return ExponentOperator;
			
			case 16: return StrictLessOperator;
			case 17: return StrictGreaterOperator;
			case 18: return NonStrictLessOperator;
			case 19: return NonStrictGreaterOperator;
			
			case 20: return EqualityOperator;
			case 21: return InequalityOperator;
			
			case 22: return LogicalAndOperator;
			case 23: return LogicalOrOperator;
			
			case 24: return AssignmentOperator;
			case 25: return AdditiveAssignmentOperator;
			case 26: return SubtractiveAssignmentOperator;
			case 27: return MultiplicativeAssignmentOperator;
			case 28: return DivisiveAssignmentOperator;
			case 29: return ModuloAssignmentOperator;
			case 30: return ExponentialAssignmentOperator;
			
			case 31: return MemberAccessOperator;
			
			case 32: return IntegralNumber;
			case 33: return FloatingPointNumber;
			case 34: return StringLiteral;
			
			case 35: return Identifier;
			case 36: return FunctionCall;
			case 37: return ArrayAccess;
			case 38: return DataBlock;
			
			case 39: return StartOfInput;
			case 40: return EndOfInput;
			}
			return null;
		}
		
		public static function size():uint
		{
			return 41;
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
		
		public static const LogicalNegationOperator:TokenType = new TokenType(/^\!(?!=)/, 9, "<Logical Negation Operator>", 
			function(scope:Object, context:Object) : Boolean 
			{
				return this.getChildCount() == 1 ? !Boolean(this.getChild(0).evaluate(scope, context)) : false;
			} );
		
		public static const AdditionOperator:TokenType = new TokenType(/^\+(?!=)/, 10, "<Addition Operator>", 
			function(scope:Object, context:Object) : Object 
			{
				return this.getChildCount() == 2 ? this.getChild(0).evaluate(scope, context) + this.getChild(1).evaluate(scope, context) :
					(this.getChildCount() == 1 ? this.getChild(0).evaluate(scope, context) : null);
			} );
		public static const SubtractionOperator:TokenType = new TokenType(/^-(?!=)/, 11, "<Subtraction Operator>", 
			function(scope:Object, context:Object) : Number 
			{
				return this.getChildCount() == 2 ? Number(this.getChild(0).evaluate(scope, context)) - Number(this.getChild(1).evaluate(scope, context)) :
					(this.getChildCount() == 1 ? (-1) * Number(this.getChild(0).evaluate(scope, context)) : 0);
			} );
		
		public static const MultiplicationOperator:TokenType = new TokenType(/^\*(?!=)/, 12, "<Multiplication Operator>", 
			function(scope:Object, context:Object) : Number 
			{
				return this.getChildCount() != 2 ? 0 : Number(this.getChild(0).evaluate(scope, context)) * Number(this.getChild(1).evaluate(scope, context));
			} );
		public static const DivisionOperator:TokenType = new TokenType(/^\/(?!=)/, 13, "<Division Operator>", 
			function(scope:Object, context:Object) : Number 
			{
				return this.getChildCount() != 2 ? 0 : Number(this.getChild(0).evaluate(scope, context)) / Number(this.getChild(1).evaluate(scope, context));
			} );
		public static const ModuloOperator:TokenType = new TokenType(/^%(?!=)/, 14, "<Modulo Operator>", 
			function(scope:Object, context:Object) : Number 
			{
				return this.getChildCount() != 2 ? 0 : Number(this.getChild(0).evaluate(scope, context)) % Number(this.getChild(1).evaluate(scope, context));
			} );
		
		public static const ExponentOperator:TokenType = new TokenType(/^\^(?!=)/, 15, "<Exponent Operator>", 
			function(scope:Object, context:Object) : Number 
			{
				return this.getChildCount() != 2 ? 0 : Math.pow(Number(this.getChild(0).evaluate(scope, context)), Number(this.getChild(1).evaluate(scope, context)));
			} );
		
		public static const StrictLessOperator:TokenType = new TokenType(/^<(?!=)/, 16, "<Less-Than Operator>", 
			function(scope:Object, context:Object) : Boolean 
			{
				return this.getChildCount() != 2 ? false : Number(this.getChild(0).evaluate(scope, context)) < Number(this.getChild(1).evaluate(scope, context));
			} );
		public static const StrictGreaterOperator:TokenType = new TokenType(/^>(?!=)/, 17, "<Greater-Than Operator>", 
			function(scope:Object, context:Object) : Boolean 
			{
				return this.getChildCount() != 2 ? false : Number(this.getChild(0).evaluate(scope, context)) > Number(this.getChild(1).evaluate(scope, context));
			} );
		public static const NonStrictLessOperator:TokenType = new TokenType(/^<=/, 18, "<Less-Than-Or-Equal Operator>", 
			function(scope:Object, context:Object) : Boolean 
			{
				return this.getChildCount() != 2 ? false : Number(this.getChild(0).evaluate(scope, context)) <= Number(this.getChild(1).evaluate(scope, context));
			} );
		public static const NonStrictGreaterOperator:TokenType = new TokenType(/^>=/, 19, "<Greater-Than-Or-Equal Operator>", 
			function(scope:Object, context:Object) : Boolean 
			{
				return this.getChildCount() != 2 ? false : Number(this.getChild(0).evaluate(scope, context)) >= Number(this.getChild(1).evaluate(scope, context));
			} );
		
		public static const EqualityOperator:TokenType = new TokenType(/^==/, 20, "<Equality Operator>", 
			function(scope:Object, context:Object) : Boolean 
			{
				return this.getChildCount() != 2 ? false : this.getChild(0).evaluate(scope, context) == this.getChild(1).evaluate(scope, context);
			} );
		public static const InequalityOperator:TokenType = new TokenType(/^\!=/, 21, "<Inequality Operator>", 
			function(scope:Object, context:Object) : Boolean 
			{
				return this.getChildCount() != 2 ? false : this.getChild(0).evaluate(scope, context) != this.getChild(1).evaluate(scope, context);
			} );
		
		public static const LogicalAndOperator:TokenType = new TokenType(/^&&/, 22, "<Logical-And Operator>", 
			function(scope:Object, context:Object) : Boolean 
			{
				return this.getChildCount() != 2 ? false : Boolean(this.getChild(0).evaluate(scope, context)) && Boolean(this.getChild(1).evaluate(scope, context));
			} );
		public static const LogicalOrOperator:TokenType = new TokenType(/^\|\|/, 23, "<Logical-Or Operator>", 
			function(scope:Object, context:Object) : Boolean 
			{
				return this.getChildCount() != 2 ? false : Boolean(this.getChild(0).evaluate(scope, context)) || Boolean(this.getChild(1).evaluate(scope, context));
			} );
		
		public static const AssignmentOperator:TokenType = new TokenType(/^=(?!=)/, 24, "<Assignment Operator>", 
			function(scope:Object, context:Object) : Object 
			{
				return context == null || this.getChildCount() != 2 || this.getChild(0).token == null || this.getChild(0).token.type == null || !this.getChild(0).token.type.equals(Identifier) ?
					null : context[this.getChild(0).token.text] = this.getChild(1).evaluate(scope, context);
			} );
		public static const AdditiveAssignmentOperator:TokenType = new TokenType(/^\+=/, 25, "<Additive-Assignment Operator>", 
			function(scope:Object, context:Object) : Object 
			{
				return context == null || this.getChildCount() != 2 || this.getChild(0).token == null || this.getChild(0).token.type == null || !this.getChild(0).token.type.equals(Identifier) ?
					null : context[this.getChild(0).token.text] += this.getChild(1).evaluate(scope, context);
			} );
		public static const SubtractiveAssignmentOperator:TokenType = new TokenType(/^-=/, 26, "<Subtractive-Assignment Operator>", 
			function(scope:Object, context:Object) : Number 
			{
				return context == null || this.getChildCount() != 2 || this.getChild(0).token == null || this.getChild(0).token.type == null || !this.getChild(0).token.type.equals(Identifier) ?
					0 : context[this.getChild(0).token.text] -= Number(this.getChild(1).evaluate(scope, context));
			} );
		public static const MultiplicativeAssignmentOperator:TokenType = new TokenType(/^\*=/, 27, "<Multiplicative-Assignment Operator>", 
			function(scope:Object, context:Object) : Number 
			{
				return context == null || this.getChildCount() != 2 || this.getChild(0).token == null || this.getChild(0).token.type == null || !this.getChild(0).token.type.equals(Identifier) ?
					0 : context[this.getChild(0).token.text] *= Number(this.getChild(1).evaluate(scope, context));
			} );
		public static const DivisiveAssignmentOperator:TokenType = new TokenType(/^\/=/, 28, "<Divisive-Assignment Operator>", 
			function(scope:Object, context:Object) : Number 
			{
				return context == null || this.getChildCount() != 2 || this.getChild(0).token == null || this.getChild(0).token.type == null || !this.getChild(0).token.type.equals(Identifier) ?
					0 : context[this.getChild(0).token.text] /= Number(this.getChild(1).evaluate(scope, context));
			} );
		public static const ModuloAssignmentOperator:TokenType = new TokenType(/^%=/, 29, "<Modulo-Assignment Operator>", 
			function(scope:Object, context:Object) : Number 
			{
				return context == null || this.getChildCount() != 2 || this.getChild(0).token == null || this.getChild(0).token.type == null || !this.getChild(0).token.type.equals(Identifier) ?
					0 : context[this.getChild(0).token.text] %= Number(this.getChild(1).evaluate(scope, context));
			} );
		public static const ExponentialAssignmentOperator:TokenType = new TokenType(/^\^=/, 30, "<Exponential-Assignment Operator>", 
			function(scope:Object, context:Object) : Number 
			{
				return context == null || this.getChildCount() != 2 || this.getChild(0).token == null || this.getChild(0).token.type == null || !this.getChild(0).token.type.equals(Identifier) ?
					0 : context[this.getChild(0).token.text] = Math.pow(Number(context[this.getChild(0).token.text]), Number(this.getChild(1).evaluate(scope, context)));
			} );
		
		public static const MemberAccessOperator:TokenType = new TokenType(/^\.(?![0-9])/, 31, "<Member-Access Operator>", 
			function(scope:Object, context:Object) : Object 
			{
				return this.getChildCount() != 2 ? null : this.getChild(1).evaluate(scope, this.getChild(0).evaluate(scope, context));
			} );
		
		private static const forbiddenNumberPostfix:String = "(?![_a-zA-Z0-9\.])";
		
		public static const IntegralNumber:TokenType = new TokenType(new RegExp("^[0-9]+" + forbiddenNumberPostfix), 32, "<Integral Number>", 
			function(scope:Object, context:Object) : int 
			{
				return this.token == null ? 0 : parseInt(this.token.text);
			} );
		public static const FloatingPointNumber:TokenType = new TokenType(new RegExp("^(?:(?:[0-9]*[\.][0-9]+)|(?:[0-9]+[\.][0-9]*))" + forbiddenNumberPostfix), 33, "<Floating-Point Number>", 
			function(scope:Object, context:Object) : Number 
			{
				return this.token == null ? 0 : parseFloat(this.token.text);
			} );
		public static const StringLiteral:TokenType = new TokenType(/(?<=^")[^"\\]*(?:\\.[^"\\]*)*(?=")/, 34, "<String Literal>", 
			function(scope:Object, context:Object) : String 
			{
				return this.token == null ? null : this.token.text;
			} );
		
		public static const Identifier:TokenType = new TokenType(/^[_a-zA-Z][a-zA-Z0-9_]*/, 35, "<Identifier>", 
			function(scope:Object, context:Object) : Object 
			{
				var returnValue:Object;
				return context == null || (returnValue = context[this.token.text]) == null ? (scope == null ? null : scope[this.token.text]) : returnValue;
			} );
		
		public static const FunctionCall:TokenType = new TokenType(null, 36, "<Function Call>", 
			function(scope:Object, context:Object) : Object 
			{
				if (scope == null || this.getChildCount() == 0) return null;
				
				const method:Function = this.getChild(0).evaluate(scope, context);
				if (method == null) return null;
				
				const methodArguments:Array = new Array();
				
				for (var it:uint = 1, end:uint = this.getChildCount(); it != end; ++it)
					methodArguments.push(this.getChild(it).evaluate(scope, context));
				
				return method.apply(null, methodArguments);
			} );
		public static const ArrayAccess:TokenType = new TokenType(null, 37, "<Array Access>", 
			function(scope:Object, context:Object) : Object 
			{
				if (scope == null || this.getChildCount() == 0) return null;
				
				const array:Object = this.getChild(0).evaluate(scope, context);
				if (array == null) return null;
				
				const arrayAccessArguments:Array = new Array();
				
				for (var it:uint = 1, end:uint = this.getChildCount(); it != end; ++it)
					arrayAccessArguments.push(this.getChild(it).evaluate(scope, context));
				
				return array[arrayAccessArguments];
			} );
		public static const DataBlock:TokenType = new TokenType(null, 38, "<Data Block>", 
			function(scope:Object, context:Object) : Object 
			{
				const object:Object = new Object();
				for (var index:uint = 0, end:uint = this.getChildCount(); index != end; ++index)
					object[index] = this.getChild(index).evaluate(scope, object);
				
				return object;
			} );
		
		
		public static const StartOfInput:TokenType = new TokenType(null, 39, "<Start of Input>");
		public static const EndOfInput:TokenType = new TokenType(null, 40, "<End of Input>");
	}
}