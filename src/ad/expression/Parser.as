package ad.expression
{
	import ad.expression.Lexer;
	import ad.expression.ParseTreeNode;
	import ad.expression.TokenType;
	import ad.expression.Token;	
	import ad.map.HashMap;
	
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
		
		
		public function setTokens(tokens:Vector.<Token>):Parser
		{
			m_tokens = tokens;
			return this;
		}
		
		
		public function getTokens():Vector.<Token>
		{
			return m_tokens;
		}
		
		public function parse():Vector.<ParseTreeNode>
		{
			if (m_tokens == null || m_tokens.length == 0) return null;
			
			m_current = 0;
			m_max = m_tokens.length;
			m_bracketEvaluator.reset();
			
			return parameterList(TokenType.StartOfInput, TokenType.EndOfInput, TokenType.Terminator, TokenType.OperatorEndData, false);
		}
		
		public function parseExpression(start:uint = 0, end:uint = 0):ParseTreeNode
		{
			if (m_tokens == null || m_tokens.length == 0 || start >= m_tokens.length) return null;
			
			m_current = start;
			m_max = (end <= start ? m_tokens.length : end);
			m_bracketEvaluator.reset();
			
			return expression();
		}
		
		public function done():Boolean
		{
			return getCurrentToken() == null;
		}
		
		
		private function expression():ParseTreeNode
		{
			const saved:uint = m_current;
			var node:ParseTreeNode = relationalExpression();
			
			if (node == null) return reset(saved);			
			return node;
		}
		
		private function nextExpression(next:Function, tokens:Vector.<TokenType>):ParseTreeNode
		{
			if (m_tokens == null) return null;
			
			const saved:uint = m_current;
			
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
		
		private function relationalExpression():ParseTreeNode
		{
			return nextExpression(additiveExpression, new <TokenType> [ TokenType.EqualityOperator, TokenType.InequalityOperator,
				TokenType.StrictLessOperator, TokenType.NonStrictLessOperator, TokenType.StrictGreaterOperator, TokenType.NonStrictGreaterOperator ]);
		}
		
		private function additiveExpression():ParseTreeNode
		{
			return nextExpression(multiplicativeExpression, new <TokenType> [ TokenType.AdditionOperator, TokenType.SubtractionOperator ]);
		}
		
		private function multiplicativeExpression():ParseTreeNode
		{
			return nextExpression(exponentExpression, new <TokenType> [ TokenType.MultiplicationOperator, TokenType.DivisionOperator, TokenType.ModuloOperator ]);
		}
		
		private function exponentExpression():ParseTreeNode
		{
			return nextExpression(unaryExpression, new <TokenType> [ TokenType.ExponentOperator ]);
		}
		
		private function unaryExpression():ParseTreeNode
		{
			const saved:uint = m_current;			
			var node:ParseTreeNode = null;
			
			if ((node = parseCurrent(TokenType.IntegralNumber)) != null || (node = parseCurrent(TokenType.FloatingPointNumber)) != null ||
				(node = parseCurrent(TokenType.StringLiteral)) != null || (node = parseCurrent(TokenType.Identifier)) != null)
				return node;
			
			if ((node = parseCurrent(TokenType.FunctionCall)) != null)
				return parseComplexIdentifier(node, TokenType.OperatorBeginArguments,
					TokenType.OperatorEndArguments, saved);		
			
			if ((node = parseCurrent(TokenType.ArrayAccess)) != null)
				return parseComplexIdentifier(node, TokenType.OperatorBeginArrayAccess,
					TokenType.OperatorEndArrayAccess, saved);			
			
			if ((node = parseCurrent(TokenType.ArrayInitialization)) != null)
				return parseComplexIdentifier(node, TokenType.OperatorBeginData,
					TokenType.OperatorEndData, saved);
			
			
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
			
			if (currentToken.equals(TokenType.OperatorBeginData))
			{	
				node = new ParseTreeNode(getCurrentToken());
				
				if (node.setChildren( parameterList(TokenType.OperatorBeginData, TokenType.OperatorEndData, null, TokenType.OperatorEndData, false) )
					.getChildren() == null) return reset(saved);
				
				return node.setEnclosed(true);
			}
			
			return reset(saved);
		}
		
		private function parseComplexIdentifier(node:ParseTreeNode, openingToken:TokenType,
			closingToken:TokenType, saved:uint):ParseTreeNode
		{
			if (node == null) return null;
			
			const parameters:Vector.<ParseTreeNode> =
				parameterList(openingToken, closingToken, TokenType.Delimiter);
			if (parameters == null)
				return reset(saved);
			
			return node.setChildren(parameters);
		}
		
		private function parameterList(openingToken:TokenType, closingToken:TokenType, delimiter:TokenType = null,
			secondaryDelimiter:TokenType = null,
			functionSyntax:Boolean = true):Vector.<ParseTreeNode>
		{
			if (openingToken == null || closingToken == null) return null;
			m_bracketEvaluator.addPair(openingToken, closingToken);
			
			var returnValue:Vector.<ParseTreeNode> = new Vector.<ParseTreeNode>();
			
			const parameterParser:Parser = new Parser(m_tokens);
			var buffer:ParseTreeNode;
			var start:uint;
			
			do
			{
				const current:Token = getCurrentToken();
				if (current == null || current.type == null || parseCurrent(current.type) == null) break;
				
				if (current.type.equals(closingToken) && m_bracketEvaluator.getUnclosedCount(openingToken) == 0)
				{
					if (functionSyntax)
					{
						if (m_current - 1 > start)
						{
							buffer = parameterParser.parseExpression(start, m_current - 1);
							if (buffer == null) return null;
							
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
						return error("Error: Syntax error on token " + current.type.name + ": expected token " + delimiter.name + ".");
				}
				
				if (current.type.equals(delimiter))
				{
					if (m_current - 1 > start)
					{
						buffer = parameterParser.parseExpression(start, m_current - 1);
						if (buffer == null) return null;
						
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
					start = m_current;
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
		
		private function parseCurrent(type:TokenType):ParseTreeNode
		{
			if (getCurrentTokenType() == type)
			{
				const node:ParseTreeNode = new ParseTreeNode(getCurrentToken());
				m_current++;
				
				if (!m_bracketEvaluator.next(node.getToken().type))
					return error("Error: Syntax error on token " + node.getToken().type.name + ".");
				
				return node;
			}
			
			return null;
		}
		
		
		private var m_current:uint, m_max:uint;
		private var m_tokens:Vector.<Token>;
		private var m_bracketEvaluator:BracketSyntaxEvaluator = new BracketSyntaxEvaluator();
	}
}