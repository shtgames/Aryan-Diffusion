package ad.expression
{
	import ad.expression.Lexer;
	import ad.expression.ParseTreeNode;
	import ad.expression.TokenType;
	import ad.expression.Token;
	import ad.expression.TokenList;
	
	
	public class Parser
	{
		public function Parser(lexer:Lexer)
		{
			m_tokens = lexer.getTokens();
		}
		
		
		public function parse():ParseTreeNode
		{
			m_current = 0;
			return expression();
		}		
		
		public function getDone():Boolean
		{
			return m_tokens.getDone() && getCurrentToken() == null;
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
				
				node2.getChildren().add(node);
				node2.getChildren().add(node3);
				
				node = node2;
			}
			
			return node;
		}
		
		private function equalityExpression():ParseTreeNode
		{
			return nextExpression(relationalExpression, [ TokenType.EqualityOperator, TokenType.InequalityOperator ]);
		}
		
		private function relationalExpression():ParseTreeNode
		{
			return nextExpression(concatExpression, [ TokenType.StrictLessOperator, TokenType.LessOperator, TokenType.StrictGreaterOperator, TokenType.GreaterOperator ]);
		}
		
		private function concatExpression():ParseTreeNode
		{
			return nextExpression(additiveExpression, [ TokenType.OpConcat ]);
		}
		
		private function additiveExpression():ParseTreeNode
		{
			return nextExpression(multiplicativeExpression, [ TokenType.AdditionOperator, TokenType.SubtractionOperator ]);
		}
		
		private function multiplicativeExpression():ParseTreeNode
		{
			return nextExpression(exponentExpression, [ TokenType.MultiplicationOperator, TokenType.DivisionOperator ]);
		}
		
		private function exponentExpression():ParseTreeNode
		{
			return nextExpression(percentExpression, [ TokenType.ExponentOperator ]);
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
				node2.getChildren().add(node);
				return node2;
			}
			
			return node;
		}
		
		private function unaryExpression():ParseTreeNode
		{
			const saved:int = m_current;
			
			var node:ParseTreeNode = null;
			
			if ((node = parseCurrent(TokenType.IntegralNumber)) != null || (node = parseCurrent(TokenType.FloatingPointNumber)) != null ||
				(node = parseCurrent(TokenType.String)) != null || (node = parseCurrent(TokenType.SheetRef)) != null ||
				(node = parseCurrent(TokenType.OpCellRange)) != null || (node = parseCurrent(TokenType.CellIndex)) != null ||
				(node = parseCurrent(TokenType.Identifier)) != null (node = parseCurrent(TokenType.Error)) != null)
				return node;
			
			if ((node = parseCurrent(TokenType.FunctionCall)) != null)
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
			}
			
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
				
				node.getChildren().add(node2);
				
				return node;
			}
			
			if (currentToken.equals(TokenType.DataBeginOperator))
			{
				node = new ParseTreeNode(new Token("", TokenType.Matrix, getCurrentToken().getIndex()));
				
				if (parseCurrent(TokenType.DataBeginOperator) == null)
				{
					m_current = saved;
					return null;
				}
				
				var m:Vector.<Vector.<ParseTreeNode>> = matrix();
				if (m == null)
				{
					m_current = saved;
					return null;
				}
				
				if (m.size() > 0)
				{
					const width:int = m[0].size();
					for (var i:int = 1; i < m.size(); ++i)
						if (m[i].size() != width)
						{
							// TODO: throw directly, the expression is not valid
							m_current = saved;
							return null;
						}
				}
				
				for each (var item:Vector.<ParseTreeNode> in m)
				{
					var row:ParseTreeNode = new ParseTreeNode(new Token("", TokenType.MatrixRow,
						item.size() > 0 ? item[0].getToken().getIndex() : 0));
					
					for each (var e:ParseTreeNode in item)
						row.getChildren().add(e);
					
					node.getChildren().add(row);
				}
				
				return node;
			}
			
			if (currentToken.equals(TokenType.ArgumentBeginOperator))
			{
				if (parseCurrent(TokenType.ArgumentBeginOperator) == null)
				{
					m_current = saved;
					return null;
				}
				
				if ((node = expression()) == null)
				{
					m_current = saved;
					return null;
				}
				
				if (parseCurrent(TokenType.ArgumentEndOperator) == null)
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
		
		private function sheetRefExpression():ParseTreeNode
		{
			const saved:int = m_current;
			
			const node:ParseTreeNode = parseCurrent(TokenType.SheetRef);
			if (node == null)
			{
				m_current = saved;
				return null;
			}
			
			const node2:ParseTreeNode = parseCurrent(TokenType.OpSheetRef);
			if (node2 == null)
			{
				m_current = saved;
				return null;
			}
			
			var node3:ParseTreeNode = cellRangeExpression();
			if (node3 == null && (node3 = cellIndex()) == null)
				node3 = identifier();
			
			if (node3 == null)
			{
				m_current = saved;
				return null;
			}
			
			node2.getChildren().add(node);
			node2.getChildren().add(node3);
			
			return node2;
		}
		
		private function cellRangeExpression():ParseTreeNode
		{
			const saved:int = m_current;
			
			const node:ParseTreeNode = parseCurrent(TokenType.CellIndex);
			if (node == null)
			{
				m_current = saved;
				return null;
			}
			
			var node2:ParseTreeNode = parseCurrent(TokenType.OpCellRange);
			if (node2 == null)
			{
				m_current = saved;
				return null;
			}
			
			var node3:ParseTreeNode = parseCurrent(TokenType.CellIndex);
			if (node3 == null)
			{
				m_current = saved;
				return null;
			}
			
			node2.getChildren().add(node);
			node2.getChildren().add(node3);
			
			return node2;
		}
		
		private function paramList():Vector.<ParseTreeNode>
		{
			if (getCurrentTokenType().equals(TokenType.ArgumentEndOperator))
				return new Vector.<ParseTreeNode>();
			
			return expressionList(new Vector.<TokenType> [ TokenType.ArgumentEndOperator ], new Vector.<TokenType> [ TokenType.Delimmiter, TokenType.Terminator ],
				true);
		}
		
		private function matrix():Vector.<Vector.<ParseTreeNode>> 
		{
			if (parseCurrent(TokenType.DataEndOperator) != null)
				return new Vector.<Vector.<ParseTreeNode>>();
			
			return rowList();
		}
		
		private function rowList():Vector.<Vector.<ParseTreeNode>>
		{
			const saved:int = m_current;
			
			var rows:Vector.<Vector.<ParseTreeNode>> = new Vector.<Vector.<ParseTreeNode>>();
			
			var node:Vector.<ParseTreeNode> = null;
			while ((node = expressionList(new Vector.<TokenType> [ TokenType.Pipe, TokenType.DataEndOperator ],
				new Vector.<TokenType> [ TokenType.Terminator ], false)) != null)
			{
				if (node.size() == 0)
				{
					m_current = saved;
					return null;
				}
				
				rows.add(node);
				
				if (parseCurrent(TokenType.DataEndOperator) != null)
					break;
				
				if (parseCurrent(TokenType.Pipe) == null)
				{
					m_current = saved;
					return null;
				}
			}
			
			return rows;
		}
		
		
		private static function indexOf(array:Vector.<TokenType>, element:TokenType):int
		{
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
			
			expressions.add(node);
			
			while (indexOf(separators, getCurrentTokenType()) != -1)
			{
				m_current++;
				
				if ((node = expression()) == null)
				{					
					if ((indexOf(terminals, getCurrentTokenType()) != -1 ||
						indexOf(separators, getCurrentTokenType()) != -1) && allowNulls)
					{
						expressions.add(null);
						continue;
					}
					
					m_current = saved;
					return null;
				}
				
				expressions.add(node);
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
			return m_tokens.at(m_current);
		}
		
		private function getCurrentTokenType():TokenType
		{
			const current:Token = getCurrentToken();
			if (current == null) return null;
			return current.getType();
		}
		
		
		private var m_tokens:Lexer.TokenList;		
		private var m_current:int;
	}
}