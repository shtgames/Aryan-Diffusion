package ad.expression
{
	import ad.expression.Lexer;
	import ad.expression.ParseTreeNode;
	import ad.expression.TokenType;
	import ad.expression.Token;	
	
	public class Parser
	{
		public function Parser(lexer:Lexer)
		{
			if (lexer != null && (lexer.done() || lexer.process()))
				m_tokens = lexer.tokens;
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
			
			if (node == null) m_current = saved;
			
			return node;
		}
		
		private function nextExpression(next:Function, tokens:Vector.<TokenType>):ParseTreeNode
		{
			if (m_tokens == null) return null;
			
			const saved:int = m_current;
			
			var node:ParseTreeNode = next();
			if (node == null)
			{
				m_current = saved;
				return null;
			}
			
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
				{
					m_current = saved;
					return null;
				}
				
				var node3:ParseTreeNode = next();
				if (node3 == null)
				{
					m_current = saved;
					return null;
				}
				
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
			{
				m_current = saved;
				return null;
			}
			
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
			
			/*if ((node = parseCurrent(TokenType.FunctionCall)) != null)
			{
				if (parseCurrent(TokenType.ArgumentBeginOperator) == null)
				{
					m_current = saved;
					return null;
				}
				
				const parameters:Vector.<ParseTreeNode> = paramList();
				if (parameters == null)
				{
					m_current = saved;
					return null;
				}
				
				for each (var parameter:ParseTreeNode in parameters)
					node.getChildren().add(parameter);
				
				if (parseCurrent(TokenType.ArgumentEndOperator) == null)
				{
					m_current = saved;
					return null;
				}
				
				return node;
			}*/
			
			const currentToken:TokenType = getCurrentTokenType();
			if (currentToken == null)
			{
				m_current = saved;
				return null;
			}
			
			if (currentToken.equals(TokenType.SubtractionOperator) || currentToken.equals(TokenType.AdditionOperator))
			{
				if ((node = parseCurrent(currentToken)) == null)
				{
					m_current = saved;
					return null;
				}
				
				const node2:ParseTreeNode = unaryExpression();
				if (node2 == null)
				{
					m_current = saved;
					return null;
				}
				
				node.getChildren().push(node2);
				
				return node;
			}
			
			if (currentToken.equals(TokenType.OperatorBeginArguments))
			{
				if (parseCurrent(TokenType.OperatorBeginArguments) == null)
				{
					m_current = saved;
					return null;
				}
				
				if ((node = expression()) == null)
				{
					m_current = saved;
					return null;
				}
				
				if (parseCurrent(TokenType.OperatorEndArguments) == null)
				{
					m_current = saved;
					return null;
				}
				
				node.setEnclosed(true);
				
				return node;
			}
			
			m_current = saved;
			
			return null;
		}
		
		private function paramList():Vector.<ParseTreeNode>
		{
			if (getCurrentTokenType().equals(TokenType.OperatorEndArguments))
				return new Vector.<ParseTreeNode>();
			
			return expressionList(new <TokenType> [ TokenType.OperatorEndArguments ], new <TokenType> [ TokenType.Delimiter, TokenType.Terminator ], true);
		}
		
		
		private static function indexOf(array:Vector.<TokenType>, element:TokenType):int
		{
			if (array == null) return -1;
			
			const index:int = 0;
			for (var end:int = array.length; index != end; ++index)
				if (array[index].equals(element)) break;
			return index == array.length ? -1 : index;
		}
		
		private function expressionList(terminals:Vector.<TokenType>, separators:Vector.<TokenType>, allowNulls:Boolean):Vector.<ParseTreeNode>
		{
			const saved:int = m_current;
			
			var expressions:Vector.<ParseTreeNode> = new Vector.<ParseTreeNode>();
			
			if (indexOf(terminals, getCurrentTokenType()) != -1) return expressions;
			
			var node:ParseTreeNode = expression();
			if (!allowNulls && node == null)
			{
				m_current = saved;
				return null;
			}
			
			expressions.push(node);
			
			while (indexOf(separators, getCurrentTokenType()) != -1)
			{
				m_current++;
				
				if ((node = expression()) == null)
				{					
					if ((indexOf(terminals, getCurrentTokenType()) != -1 ||
						indexOf(separators, getCurrentTokenType()) != -1) && allowNulls)
					{
						expressions.push(null);
						continue;
					}
					
					m_current = saved;
					return null;
				}
				
				expressions.push(node);
			}
			
			return expressions;
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
		
		private function getCurrentToken():Token
		{
			return m_tokens == null ? null : m_tokens[m_current];
		}
		
		private function getCurrentTokenType():TokenType
		{
			const current:Token = getCurrentToken();
			if (current == null) return null;
			return current.type;
		}
		
		
		private var m_current:int;
		private var m_tokens:Vector.<Token>;
	}
}