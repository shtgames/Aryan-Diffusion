package ad.expression
{
	import ad.expression.Lexer;
	import ad.expression.ParseTreeNode;
	import ad.expression.TokenType;
	import ad.expression.Token;	
	
	public class Parser
	{
		public function Parser(lexer:Lexer = null)
		{
			setLexer(lexer);
		}
		
		
		public function setLexer(lexer:Lexer):Parser
		{
			if (lexer != null && (lexer.done() || lexer.process()))
				m_tokens = lexer.tokens;
			return this;
		}
		
		
		public function getTokens():Vector.<Token>
		{
			return m_tokens;
		}
		
		public function parse():ParseTreeNode
		{
			if (m_tokens == null) return null;
			
			m_current = 0;
			return expression();
		}		
		
		public function done():Boolean
		{
			return getCurrentToken() == null;
		}
		
		
		private function expression():ParseTreeNode
		{
			const saved:int = m_current;
			var node:ParseTreeNode = equalityExpression();
			
			if (node == null) return reset(saved);			
			return node;
		}
		
		private function nextExpression(next:Function, tokens:Vector.<TokenType>):ParseTreeNode
		{
			if (m_tokens == null) return null;
			
			const saved:int = m_current;
			
			var node:ParseTreeNode = next();
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
				
				var node2:ParseTreeNode = new ParseTreeNode(getCurrentToken());
				
				verdict = false;
				for each (var it1:TokenType in tokens)
					if (parseCurrent(it1) != null)
					{
						verdict = true;
						break;
					}				
				
				if (!verdict)
					return reset(saved);
				
				var node3:ParseTreeNode = next();
				if (node3 == null)
					return reset(saved);
				
				node2.getChildren().push(node);
				node2.getChildren().push(node3);
				
				node = node2;
			}
			
			return node;
		}
		
		private function equalityExpression():ParseTreeNode
		{
			return nextExpression(relationalExpression, new <TokenType> [ TokenType.EqualityOperator, TokenType.InequalityOperator ]);
		}
		
		private function relationalExpression():ParseTreeNode
		{
			return nextExpression(additiveExpression, new <TokenType> [ TokenType.StrictLessOperator, TokenType.LessOperator, TokenType.StrictGreaterOperator, TokenType.GreaterOperator ]);
		}
		
		private function additiveExpression():ParseTreeNode
		{
			return nextExpression(multiplicativeExpression, new <TokenType> [ TokenType.AdditionOperator, TokenType.SubtractionOperator ]);
		}
		
		private function multiplicativeExpression():ParseTreeNode
		{
			return nextExpression(exponentExpression, new <TokenType> [ TokenType.MultiplicationOperator, TokenType.DivisionOperator ]);
		}
		
		private function exponentExpression():ParseTreeNode
		{
			return nextExpression(percentExpression, new <TokenType> [ TokenType.ExponentOperator ]);
		}
		
		private function percentExpression():ParseTreeNode
		{
			const saved:int = m_current;
			
			var node:ParseTreeNode = unaryExpression();
			if (node == null)
				return reset(saved);
			
			var node2:ParseTreeNode = parseCurrent(TokenType.ModuloOperator);
			if (node2 != null)
			{
				node2.getChildren().push(node);
				return node2;
			}
			
			return node;
		}
		
		private function unaryExpression():ParseTreeNode
		{
			const saved:int = m_current;			
			var node:ParseTreeNode = null;
			
			if ((node = parseCurrent(TokenType.IntegralNumber)) != null || (node = parseCurrent(TokenType.FloatingPointNumber)) != null ||
				(node = parseCurrent(TokenType.StringLiteral)) != null || (node = parseCurrent(TokenType.Identifier)) != null)
				return node;
			
			if ((node = parseCurrent(TokenType.FunctionCall)) != null)
				return parseComplexIdentifier(node, TokenType.OperatorBeginArguments,
					TokenType.OperatorEndArguments, TokenType.Delimiter, saved);		
			
			if ((node = parseCurrent(TokenType.ArrayAccess)) != null)
				return parseComplexIdentifier(node, TokenType.OperatorBeginArrayAccess,
					TokenType.OperatorEndArrayAccess, TokenType.Delimiter, saved);		
			
			if ((node = parseCurrent(TokenType.ArrayInitialization)) != null)
				return parseComplexIdentifier(node, TokenType.OperatorBeginData,
					TokenType.OperatorEndData, TokenType.Delimiter, saved);
			
			const currentToken:TokenType = getCurrentTokenType();
			if (currentToken == null)
				return reset(saved);
			
			if (currentToken.equals(TokenType.SubtractionOperator) || currentToken.equals(TokenType.AdditionOperator))
			{
				if ((node = parseCurrent(currentToken)) == null)
					return reset(saved);
				
				const node2:ParseTreeNode = unaryExpression();
				if (node2 == null)
					return reset(saved);
				
				node.getChildren().push(node2);
				
				return node;
			}
			
			if (currentToken.equals(TokenType.OperatorBeginArguments))
			{
				if (parseCurrent(TokenType.OperatorBeginArguments) == null || (node = expression()) == null || 
					parseCurrent(TokenType.OperatorEndArguments) == null)
					return reset(saved);
				
				node.setEnclosed(true);
				
				return node;
			}
			
			return reset(saved);
		}
		
		private function parseComplexIdentifier(node:ParseTreeNode, openingToken:TokenType,
			closingToken:TokenType, delimiter:TokenType, saved:int):ParseTreeNode
		{
			if (node == null) return null;
			
			var parameters:Vector.<ParseTreeNode> =
				parameterList(openingToken, closingToken, delimiter);			
			if (parameters == null)
				return reset(saved);
			
			for each (var parameter:ParseTreeNode in parameters)
				node.getChildren().push(parameter);
				
			return node;
		}
		
		private function parameterList(openingToken:TokenType, closingToken:TokenType, delimiter:TokenType):Vector.<ParseTreeNode>
		{
			if (openingToken == null || closingToken == null || delimiter == null) return null;
			
			var returnValue:Vector.<ParseTreeNode> = new Vector.<ParseTreeNode>();
			var parameter:Vector.<Token> = new Vector.<Token>();
			
			var bracketCount:uint = 0;
			do
			{
				const current:TokenType = getCurrentTokenType();
				if (current == null) return returnValue;
				
				if (current.equals(openingToken) && ++bracketCount == 1)
				{
					parseCurrent(current);
					continue;
				}
				else if (current.equals(closingToken) && --bracketCount == 0)
				{
					if (parameter.length != 0)
					{
						returnValue.push(new Parser().setTokens(parameter).parse());
						parameter = null;
					}
					parseCurrent(current);
					break;
				}
				
				if (current.equals(delimiter))
				{
					if (parameter.length != 0)
					{
						returnValue.push(new Parser().setTokens(parameter).parse());
						parameter = new Vector.<Token>();
					}
				}
				else parameter.push(getCurrentToken());
				parseCurrent(current);
			} while (bracketCount != 0);
			
			return returnValue;
		}
		
		
		private function setTokens(tokens:Vector.<Token>):Parser
		{
			m_tokens = tokens;
			m_current = 0;
			return this;
		}
		
		private function reset(saved:int):ParseTreeNode
		{
			m_current = saved;
			return null;
		}
		
		private function getCurrentToken():Token
		{
			return m_tokens == null || m_current >= m_tokens.length ? null : m_tokens[m_current];
		}
		
		private function getCurrentTokenType():TokenType
		{
			const current:Token = getCurrentToken();
			if (current == null) return null;
			return current.type;
		}
		
		private function parseCurrent(type:TokenType):ParseTreeNode
		{
			if (getCurrentTokenType() == type)
			{
				const node:ParseTreeNode = new ParseTreeNode(getCurrentToken());
				m_current++;
				return node;
			}
			
			return null;
		}		
		
		private static function indexOf(array:Vector.<TokenType>, element:TokenType):int
		{
			if (array == null) return -1;
			
			const index:int = 0;
			for (var end:int = array.length; index != end; ++index)
				if (array[index].equals(element)) break;
			return index == array.length ? -1 : index;
		}
		
		
		private var m_current:int;
		private var m_tokens:Vector.<Token>;
	}
}