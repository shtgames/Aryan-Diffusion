package ad.expression
{
	import ad.expression.ParseNode;
	import ad.expression.TokenType;
	import ad.expression.Token;
	
	public class Parser
	{
		public function Parser(tokens:Vector.<Token> = null)
		{
			setTokens(tokens);
			m_bracketEvaluator.addPair(TokenType.OperatorBeginArguments, TokenType.OperatorEndArguments)
				.addPair(TokenType.OperatorBeginArrayAccess, TokenType.OperatorEndArrayAccess)
				.addPair(TokenType.OperatorBeginData, TokenType.OperatorEndData)
				.addPair(TokenType.StartOfInput, TokenType.EndOfInput);
		}
		
		
		public function toString():String
		{
			return done() ? "<Done>" : "<Working>";
		}
		
		public function setTokens(tokens:Vector.<Token>):Parser
		{
			m_tokens = tokens;
			return this;
		}
		
		public function getTokens():Vector.<Token>
		{
			return m_tokens;
		}
		
		public function parse():Vector.<ParseNode>
		{
			if (m_tokens == null || m_tokens.length == 0) return null;
			
			m_current = 0;
			m_max = m_tokens.length;
			m_bracketEvaluator.reset();
			
			return parameterList(TokenType.StartOfInput, TokenType.EndOfInput, TokenType.Terminator, TokenType.OperatorEndData, false);
		}
		
		public function done():Boolean
		{
			return getCurrentToken() == null;
		}
		
		
		private function parseExpression(start:uint = 0, end:uint = 0):ParseNode
		{
			if (m_tokens == null || m_tokens.length == 0 || start >= m_tokens.length) return null;
			
			m_current = start;
			m_max = (end <= start ? m_tokens.length : end);
			m_bracketEvaluator.reset();
			
			return expression();
		}
		
		private function expression():ParseNode
		{
			const saved:uint = m_current;
			var node:ParseNode = assignmentExpression();
			
			if (node == null) return reset(saved);			
			return node;
		}
		
		private function binaryExpression(next:Function, tokens:Vector.<TokenType>):ParseNode
		{
			if (m_tokens == null) return null;
			
			const saved:uint = m_current;
			
			var node:ParseNode = next();
			if (node == null) 
				return reset(saved);
			
			for (var it:TokenType = getCurrentTokenType(); it != null; it = getCurrentTokenType())
			{
				var verdict:Boolean = false;
				for each (var it1:TokenType in tokens)
					if (it.equals(it1))
					{
						verdict = true;
						break;
					}
				
				if (!verdict) break;
				
				var node2:ParseNode = new ParseNode(getCurrentToken());
				
				verdict = false;
				for each (var it1:TokenType in tokens)
					if (parseCurrent(it1) != null)
					{
						verdict = true;
						break;
					}				
				
				if (!verdict)
					return reset(saved);
				
				const node3:ParseNode = next();
				if (node3 == null)
					return reset(saved);
				
				node2.addChild(node);
				node2.addChild(node3);
				
				node = node2;
			}
			
			return node;
		}
		
		public function assignmentExpression():ParseNode
		{
			return binaryExpression(logicalOrExpression, new <TokenType> [ TokenType.AssignmentOperator, TokenType.AdditiveAssignmentOperator,
				TokenType.SubtractiveAssignmentOperator, TokenType.MultiplicativeAssignmentOperator, TokenType.DivisiveAssignmentOperator,
				TokenType.ModuloAssignmentOperator, TokenType.ExponentialAssignmentOperator ]);
		}
		
		private function logicalOrExpression():ParseNode
		{
			return binaryExpression(logicalAndExpression, new <TokenType> [ TokenType.LogicalOrOperator ]);
		}
		
		private function logicalAndExpression():ParseNode
		{
			return binaryExpression(equalityExpression, new <TokenType> [ TokenType.LogicalAndOperator ]);
		}
		
		private function equalityExpression():ParseNode
		{
			return binaryExpression(relationalExpression, new <TokenType> [ TokenType.EqualityOperator, TokenType.InequalityOperator ]);
		}
		
		private function relationalExpression():ParseNode
		{
			return binaryExpression(additiveExpression, new <TokenType> [ TokenType.StrictLessOperator, TokenType.NonStrictLessOperator,
				TokenType.StrictGreaterOperator, TokenType.NonStrictGreaterOperator ]);
		}
		
		private function additiveExpression():ParseNode
		{
			return binaryExpression(multiplicativeExpression, new <TokenType> [ TokenType.AdditionOperator, TokenType.SubtractionOperator ]);
		}
		
		private function multiplicativeExpression():ParseNode
		{
			return binaryExpression(exponentExpression, new <TokenType> [ TokenType.MultiplicationOperator, TokenType.DivisionOperator, TokenType.ModuloOperator ]);
		}
		
		private function exponentExpression():ParseNode
		{
			return binaryExpression(objectExpression, new <TokenType> [ TokenType.ExponentOperator ]);
		}
		
		private function objectExpression():ParseNode
		{
			var node:ParseNode = unaryExpression();
			
			if (node == null)
				return null;
			
			const saved:uint = m_current;
			
			for (var it:TokenType = getCurrentTokenType(); it != null; it = getCurrentTokenType())
			{
				var node2:ParseNode;
				if ((node2 = parseCurrent(TokenType.MemberAccessOperator)) == null)
				{
					if (it.equals(TokenType.OperatorBeginArguments) || it.equals(TokenType.OperatorBeginArrayAccess))
					{
						var parameters:Vector.<ParseNode>;						
						
						if (it.equals(TokenType.OperatorBeginArguments) &&
								(parameters = parameterList(TokenType.OperatorBeginArguments, TokenType.OperatorEndArguments, TokenType.Delimiter)) != null)
							node = new ParseNode(new Token("()", TokenType.FunctionCall)) .addChild(node).addChildren(parameters);
						else if (it.equals(TokenType.OperatorBeginArrayAccess) &&
								(parameters = parameterList(TokenType.OperatorBeginArrayAccess, TokenType.OperatorEndArrayAccess, TokenType.Delimiter)) != null)
							node = new ParseNode(new Token("[]", TokenType.ArrayAccess)) .addChild(node).addChildren(parameters);
						
						continue;
					}
					else return node;
				}
				
				var node3:ParseNode = unaryExpression();
				if (node3 == null)
					return reset(saved);
				
				node2.addChild(node);
				node2.addChild(node3);
				
				node = node2;
			}
			
			return node;
		}
		
		private function unaryExpression():ParseNode
		{
			const saved:uint = m_current;
			
			const currentToken:TokenType = getCurrentTokenType();
			if (currentToken == null)
				return reset(saved);
			
			if (currentToken.equals(TokenType.IntegralNumber) || currentToken.equals(TokenType.FloatingPointNumber) ||
					currentToken.equals(TokenType.StringLiteral) || currentToken.equals(TokenType.Identifier))
				return parseCurrent(currentToken);
			
			var node:ParseNode = null;
			
			if (currentToken.equals(TokenType.LogicalNegationOperator) ||
				currentToken.equals(TokenType.AdditionOperator) || currentToken.equals(TokenType.SubtractionOperator))
			{
				if ((node = parseCurrent(currentToken)) == null)
					return reset(saved);
				
				const node2:ParseNode = objectExpression();
				if (node2 == null)
					return reset(saved);
				
				return node.addChild(node2);
			}
			
			if (currentToken.equals(TokenType.OperatorBeginArguments))
			{
				const value:Vector.<ParseNode> = parameterList(TokenType.OperatorBeginArguments, TokenType.OperatorEndArguments);
				if (value == null || value.length == 0 || (node = value[0]) == null)
					return reset(saved);
				
				return node;
			}
			
			if (currentToken.equals(TokenType.OperatorBeginData))
			{
				node = new ParseNode(new Token("{}", TokenType.DataBlock));
				
				const parameters:Vector.<ParseNode> = parameterList(TokenType.OperatorBeginData, TokenType.OperatorEndData, null, TokenType.OperatorEndData, false);
				if (parameters == null)
					return reset(saved);
				
				return node.addChildren(parameters);
			}
			
			return reset(saved);
		}
		
		private function parameterList(openingToken:TokenType, closingToken:TokenType, delimiter:TokenType = null,
			secondaryDelimiter:TokenType = null, functionSyntax:Boolean = true):Vector.<ParseNode>
		{
			if (openingToken == null || closingToken == null) return null;
			m_bracketEvaluator.addPair(openingToken, closingToken);
			
			var returnValue:Vector.<ParseNode> = new Vector.<ParseNode>();
			
			const parameterParser:Parser = new Parser(m_tokens);
			var buffer:ParseNode;
			var start:uint = m_current;
			
			do
			{
				const current:Token = getCurrentToken();
				if (current == null || current.type == null || parseCurrent(current.type) == null) break;
				
				if (current.type.equals(closingToken) && m_bracketEvaluator.getUnclosedCount(openingToken) == 0)
				{
					if (functionSyntax)
					{
						if (start < m_current - 1)
						{
							buffer = parameterParser.parseExpression(start, m_current - 1);
							if (buffer == null)	return null;
							
							returnValue.push(buffer);
							start = m_current;
						}
						else if (returnValue.length != 0)
							return error("Error: Syntax error on token " + current.type.name + ": expected an expression.");
					}
					else if (start < m_current - 1 && returnValue.length != 0)
						return error("Error: Syntax error on token " + current.type.name + ": expected " + delimiter.name + ".");
				}
				
				if (!m_bracketEvaluator.isTopLevel(openingToken)) continue;
				
				if (current.type.equals(openingToken))
				{
					start = m_current;
					continue;
				}
				
				if (current.type.equals(TokenType.Delimiter) || current.type.equals(TokenType.Terminator))
				{
					if (delimiter == null)
						functionSyntax = (delimiter = current.type).equals(TokenType.Delimiter);
					else if (!current.type.equals(delimiter))
						return error("Error: Syntax error on token " + current.type.name + ": expected " + delimiter.name + ".");
				}
				
				if (current.type.equals(delimiter))
				{
					if (start < m_current - 1)
					{
						buffer = parameterParser.parseExpression(start, m_current - 1);
						if (buffer == null)
							return null;
						
						returnValue.push(buffer);
						start = m_current;
					}
					else if (functionSyntax)
						return error("Error: Syntax error on token " + delimiter.name + ": expected an expression." + start + " " + m_current);
				}
				else if (!functionSyntax && current.type.equals(secondaryDelimiter) && m_current > start)
				{
					buffer = parameterParser.parseExpression(start, m_current);
					if (buffer == null) return null;
					
					returnValue.push(buffer);
					start = m_current + 1;
				}
			} while (!done() && m_bracketEvaluator.hasUnclosed());
			
			if (m_bracketEvaluator.hasUnclosed())
				return error("Error: The opening token " + m_bracketEvaluator.getCurrent().name + " was unmatched at end of expression.");
			
			return returnValue;
		}
		
		
		private function reset(saved:uint):*
		{
			m_current = saved;
			return null;
		}
		
		private function error(message:String):*
		{
			trace (message);
			return null;
		}
		
		private function getCurrentToken():Token
		{
			return m_tokens == null || m_current >= m_max ? null : m_tokens[m_current];
		}
		
		private function getCurrentTokenType():TokenType
		{
			const current:Token = getCurrentToken();
			if (current == null) return null;
			return current.type;
		}
		
		private function parseCurrent(type:TokenType):ParseNode
		{
			if (getCurrentTokenType() == type)
			{
				const node:ParseNode = new ParseNode(getCurrentToken());
				m_current++;
				
				if (!m_bracketEvaluator.next(node.token.type))
					return error("Error: Syntax error on token " + node.token.type.name + ".");
				
				return node;
			}
			
			return null;
		}
		
		
		private var m_current:uint, m_max:uint;
		private var m_tokens:Vector.<Token>;
		private var m_bracketEvaluator:BracketSyntaxEvaluator = new BracketSyntaxEvaluator();
	}
}