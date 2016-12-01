package ad.expression;

import com.mindfusion.common.ExtendedArrayList;

/***
 * Provides parsing capabilities for token lists previously generated
 * by processing character sequences through a {@link Lexer}.
 */
public class Parser
{
	/**
	* Initializes a new instance of the Parser class.
	*/
	public Parser(Lexer lexer)
	{
		this.tokens = lexer.getTokens();
	}

	/**
	* Returns a ParseTreeNode corresponding to the parsed tree starting
	* at the 'expression' nonterminal.
	*/
	public ParseTreeNode parse()
	{
		current = 0;
		return expression();
	}

	/**
	* Parses an 'expression' nonterminal.
	*/
	private ParseTreeNode expression()
	{
		int saved = current;

		ParseTreeNode node = null;
		if ((node = equalityExpression()) == null)
		{
			current = saved;
			return null;
		}

		return node;
	}

	/**
	* Parses an 'equalityExpression' nonterminal.
	*/
	private ParseTreeNode equalityExpression()
	{
		int saved = current;

		ParseTreeNode node = null;
		if ((node = relationalExpression()) == null)
		{
			current = saved;
			return null;
		}

		for (TokenType it = getCurrentTokenType(); it != null && (it.equals(TokenType.OpEqual) || it.equals(TokenType.OpNotEqual));
				it = getCurrentTokenType())
		{
			ParseTreeNode node2 = new ParseTreeNode(getCurrentToken());

			if (opEqual() == null)
			{
				if (opNotEqual() == null)
				{
					current = saved;
					return null;
				}
			}

			ParseTreeNode node3 = null;
			if ((node3 = relationalExpression()) == null)
			{
				current = saved;
				return null;
			}

			node2.getChildren().add(node);
			node2.getChildren().add(node3);

			node = node2;
		}

		return node;
	}

	/**
	* Parses a 'relationalExpression' nonterminal.
	*/
	private ParseTreeNode relationalExpression()
	{
		int saved = current;

		ParseTreeNode node = null;
		if ((node = concatExpression()) == null)
		{
			current = saved;
			return null;
		}

		for (TokenType it = getCurrentTokenType(); it != null && (it.equals(TokenType.OpLess) ||
				it.equals(TokenType.OpLessOrEqual) || it.equals(TokenType.OpGreater) || 
				it.equals(TokenType.OpGreaterOrEqual)); it = getCurrentTokenType())
		{
			ParseTreeNode node2 = new ParseTreeNode(getCurrentToken());

			if (opLess() == null)
			{
				if (opLessOrEqual() == null)
				{
					if (opGreater() == null)
					{
						if (opGreaterOrEqual() == null)
						{
							current = saved;
							return null;
						}
					}
				}
			}

			ParseTreeNode node3 = null;
			if ((node3 = concatExpression()) == null)
			{
				current = saved;
				return null;
			}

			node2.getChildren().add(node);
			node2.getChildren().add(node3);

			node = node2;
		}

		return node;
	}

	/**
	* Parses a 'concatExpression' nonterminal.
	*/
	private ParseTreeNode concatExpression()
	{
		int saved = current;

		ParseTreeNode node = null;
		if ((node = additiveExpression()) == null)
		{
			current = saved;
			return null;
		}

		for (TokenType it = getCurrentTokenType(); it != null && it.equals(TokenType.OpConcat); it = getCurrentTokenType())
		{
			ParseTreeNode node2 = new ParseTreeNode(getCurrentToken());

			if (opConcat() == null)
			{
				current = saved;
				return null;
			}

			ParseTreeNode node3 = null;
			if ((node3 = additiveExpression()) == null)
			{
				current = saved;
				return null;
			}

			node2.getChildren().add(node);
			node2.getChildren().add(node3);

			node = node2;
		}

		return node;
	}

	/**
	* Parses an 'additiveExpression' nonterminal.
	*/
	private ParseTreeNode additiveExpression()
	{
		int saved = current;

		ParseTreeNode node = null;
		if ((node = multiplicativeExpression()) == null)
		{
			current = saved;
			return null;
		}

		for (TokenType it = getCurrentTokenType(); it != null && (it.equals(TokenType.OpPlus) ||
				it.equals(TokenType.OpMinus)); it = getCurrentTokenType())
		{
			ParseTreeNode node2 = new ParseTreeNode(getCurrentToken());

			if (opPlus() == null)
			{
				if (opMinus() == null)
				{
					current = saved;
					return null;
				}
			}

			ParseTreeNode node3 = null;
			if ((node3 = multiplicativeExpression()) == null)
			{
				current = saved;
				return null;
			}

			node2.getChildren().add(node);
			node2.getChildren().add(node3);

			node = node2;
		}

		return node;
	}

	/**
	* Parses a 'multiplicativeExpression' nonterminal.
	*/
	private ParseTreeNode multiplicativeExpression()
	{
		int saved = current;

		ParseTreeNode node = null;
		if ((node = exponentExpression()) == null)
		{
			current = saved;
			return null;
		}

		for (TokenType it = getCurrentTokenType(); it != null && (it.equals(TokenType.OpMultiply) || 
				it.equals(TokenType.OpDivide)); it = getCurrentTokenType())
		{
			ParseTreeNode node2 = new ParseTreeNode(getCurrentToken());

			if (opMultiply() == null)
			{
				if (opDivide() == null)
				{
					current = saved;
					return null;
				}
			}

			ParseTreeNode node3 = null;
			if ((node3 = exponentExpression()) == null)
			{
				current = saved;
				return null;
			}

			node2.getChildren().add(node);
			node2.getChildren().add(node3);

			node = node2;
		}

		return node;
	}

	/**
	* Parses a 'exponentExpression' nonterminal.
	*/
	private ParseTreeNode exponentExpression()
	{
		int saved = current;

		ParseTreeNode node = null;
		if ((node = percentExpression()) == null)
		{
			current = saved;
			return null;
		}
		
		for (TokenType it = getCurrentTokenType(); it != null && it.equals(TokenType.OpExponent); it = getCurrentTokenType())
		{
			ParseTreeNode node2 = new ParseTreeNode(getCurrentToken());

			if (opExponent() == null)
			{
				current = saved;
				return null;
			}

			ParseTreeNode node3 = null;
			if ((node3 = percentExpression()) == null)
			{
				current = saved;
				return null;
			}

			node2.getChildren().add(node);
			node2.getChildren().add(node3);

			node = node2;
		}

		return node;
	}

	/**
	* Parses a 'percentExpression' nonterminal.
	*/
	private ParseTreeNode percentExpression()
	{
		int saved = current;

		ParseTreeNode node = null;
		if ((node = unaryExpression()) == null)
		{
			current = saved;
			return null;
		}

		ParseTreeNode node2 = null;
		if ((node2 = opPercent()) != null)
		{
			node2.getChildren().add(node);
			return node2;
		}

		return node;
	}

	/**
	* Parses an 'unaryExpression' nonterminal.
	*/
	private ParseTreeNode unaryExpression()
	{
		int saved = current;

		ParseTreeNode node = null;

		if ((node = intNumber()) != null)
			return node;

		if ((node = floatNumber()) != null)
			return node;

		if ((node = string()) != null)
			return node;

		if ((node = sheetRefExpression()) != null)
			return node;

		if ((node = cellRangeExpression()) != null)
			return node;

		if ((node = cellIndex()) != null)
			return node;

		if ((node = identifier()) != null)
			return node;

		if ((node = error()) != null)
			return node;

		if ((node = function()) != null)
		{
			if (ob() == null)
			{
				current = saved;
				return null;
			}

			ExtendedArrayList<ParseTreeNode> parameters = new ExtendedArrayList<ParseTreeNode>();
			if ((parameters = paramList()) == null)
			{
				current = saved;
				return null;
			}

			for (ParseTreeNode parameter: parameters)
				node.getChildren().add(parameter);

			if (cb() == null)
			{
				current = saved;
				return null;
			}

			return node;
		}
		
		final TokenType currentToken = getCurrentTokenType();
		if (currentToken == null)
		{
			current = saved;
			return null;
		}

		if (currentToken.equals(TokenType.OpMinus))
		{
			if ((node = opMinus()) == null)
			{
				current = saved;
				return null;
			}

			ParseTreeNode node2 = null;
			if ((node2 = unaryExpression()) == null)
			{
				current = saved;
				return null;
			}

			node.getChildren().add(node2);

			return node;
		}

		if (currentToken.equals(TokenType.OpPlus))
		{
			if ((node = opPlus()) == null)
			{
				current = saved;
				return null;
			}

			ParseTreeNode node2 = null;
			if ((node2 = unaryExpression()) == null)
			{
				current = saved;
				return null;
			}

			node.getChildren().add(node2);

			return node;
		}

		if (currentToken.equals(TokenType.Ocb))
		{
			node = new ParseTreeNode(new Token("", TokenType.Matrix, getCurrentToken().getIndex()));

			if (ocb() == null)
			{
				current = saved;
				return null;
			}

			ExtendedArrayList<ExtendedArrayList<ParseTreeNode>> m = null;
			if ((m = matrix()) == null)
			{
				current = saved;
				return null;
			}

			// Check if matrix is rectangular
			if (m.size() > 0)
			{
				int width = m.get(0).size();
				for (int r = 1; r < m.size(); r++)
				{
					if (m.get(r).size() != width)
					{
						// TODO: throw directly, the expression is not valid
						current = saved;
						return null;
					}
				}
			}

			for (ExtendedArrayList<ParseTreeNode> r: m)
			{
				ParseTreeNode row = new ParseTreeNode(new Token("", TokenType.MatrixRow,
					r.size() > 0 ? r.get(0).getToken().getIndex() : 0));
				for (ParseTreeNode e: r)
					row.getChildren().add(e);
				node.getChildren().add(row);
			}

			// Closing bracket has been parsed by matrix(), no need to parse Ccb()

			return node;
		}

		if (currentToken.equals(TokenType.Ob))
		{
			if (ob() == null)
			{
				current = saved;
				return null;
			}

			if ((node = expression()) == null)
			{
				current = saved;
				return null;
			}

			if (cb() == null)
			{
				current = saved;
				return null;
			}

			node.setEnclosed(true);

			return node;
		}

		current = saved;

		return null;
	}

	/**
	* Parses a 'sheetRefExpression' nonterminal.
	*/
	private ParseTreeNode sheetRefExpression()
	{
		int saved = current;

		ParseTreeNode node = null;
		if ((node = sheetRef()) == null)
		{
			current = saved;
			return null;
		}

		ParseTreeNode node2 = null;
		if ((node2 = opSheetRef()) == null)
		{
			current = saved;
			return null;
		}

		ParseTreeNode node3 = null;
		if ((node3 = cellRangeExpression()) == null)
		{
			if ((node3 = cellIndex()) == null)
			{
				// Handles named range expressions, specified as references:
				// =Sheet1!NamedRange
				node3 = identifier();
			}
		}
		if (node3 == null)
		{
			current = saved;
			return null;
		}

		node2.getChildren().add(node);
		node2.getChildren().add(node3);

		return node2;
	}

	/**
	* Parses a 'cellRangeExpression' nonterminal.
	*/
	private ParseTreeNode cellRangeExpression()
	{
		int saved = current;

		ParseTreeNode node = null;
		if ((node = cellIndex()) == null)
		{
			current = saved;
			return null;
		}

		ParseTreeNode node2 = null;
		if ((node2 = opCellRange()) == null)
		{
			current = saved;
			return null;
		}

		ParseTreeNode node3 = null;
		if ((node3 = cellIndex()) == null)
		{
			current = saved;
			return null;
		}

		node2.getChildren().add(node);
		node2.getChildren().add(node3);

		return node2;
	}

	/**
	* Parses a 'paramList' nonterminal.
	*/
	private ExtendedArrayList<ParseTreeNode> paramList()
	{
		if (getCurrentTokenType().equals(TokenType.Cb))
			return new ExtendedArrayList<ParseTreeNode>();

		return expressionList(new TokenType[] { TokenType.Cb }, new TokenType[] {
			TokenType.Comma, TokenType.Semicolon }, true);
	}

	/**
	* Parses a 'matrix' nonterminal.
	*/
	private ExtendedArrayList<ExtendedArrayList<ParseTreeNode>> matrix()
	{
		if (ccb() != null)
			return new ExtendedArrayList<ExtendedArrayList<ParseTreeNode>>();

		return rowList();
	}

	/**
	* Parses a rowList nonterminal.
	*/
	private ExtendedArrayList<ExtendedArrayList<ParseTreeNode>> rowList()
	{
		int saved = current;

		ExtendedArrayList<ExtendedArrayList<ParseTreeNode>> rows =
			new ExtendedArrayList<ExtendedArrayList<ParseTreeNode>>();

		ExtendedArrayList<ParseTreeNode> node = null;
		while ((node = expressionList(new TokenType[] { TokenType.Vline, TokenType.Ccb },
			new TokenType[] { TokenType.Semicolon }, false)) != null)
		{
			// Do not allow empty rows
			if (node.size() == 0)
			{
				current = saved;
				return null;
			}

			rows.add(node);

			if (ccb() != null)
				break;

			if (vline() == null)
			{
				current = saved;
				return null;
			}
		}

		return rows;
	}
	
	
	private static final int indexOf(TokenType[] array, TokenType element)
	{
		int index = 0;
		for (int end = array.length; index != end; ++index)
			if (array[index].equals(element)) break;
		return index == array.length ? -1 : index;
	}
	
	/**
	* Parses an 'expressionList' nonterminal.
	*/
	private ExtendedArrayList<ParseTreeNode> expressionList(TokenType[]
		terminals, TokenType[] separators, boolean allowNulls)
	{
		int saved = current;

		ExtendedArrayList<ParseTreeNode> expressions = new ExtendedArrayList<ParseTreeNode>();
		
		if (indexOf(terminals, getCurrentTokenType()) != -1)
			return expressions;

		ParseTreeNode node = expression();
		if (!allowNulls)
		{
			if (node == null)
			{
				current = saved;
				return null;
			}
		}

		expressions.add(node);

		while (indexOf(separators, getCurrentTokenType()) != -1)
		{
			current++;

			if ((node = expression()) == null)
			{
				// Two consecutive separators indicate an empty (null) expression
				if ((indexOf(terminals, getCurrentTokenType()) != -1 ||
					indexOf(separators, getCurrentTokenType()) != -1) && allowNulls)
				{
					expressions.add(null);
					continue;
				}

				current = saved;
				return null;
			}

			expressions.add(node);
		}

		return expressions;
	}


	/**
	* Parses a terminal of the specified type at the current
	* parsing position within the token list.
	*/
	private ParseTreeNode parseCurrent(TokenType type)
	{
		if (getCurrentTokenType() == type)
		{
			ParseTreeNode node = new ParseTreeNode(getCurrentToken());
			current++;
			return node;
		}

		return null;
	}

	/**
	* Parses an 'Ob' terminal.
	*/
	private ParseTreeNode ob()
	{
		return parseCurrent(TokenType.Ob);
	}

	/**
	* Parses a 'Cb' terminal.
	*/
	private ParseTreeNode cb()
	{
		return parseCurrent(TokenType.Cb);
	}

	/**
	* Parses an 'Ocb' terminal.
	*/
	private ParseTreeNode ocb()
	{
		return parseCurrent(TokenType.Ocb);
	}

	/**
	* Parses a 'Ccb' terminal.
	*/
	private ParseTreeNode ccb()
	{
		return parseCurrent(TokenType.Ccb);
	}

	/**
	* Parses a 'Vline' terminal.
	*/
	private ParseTreeNode vline()
	{
		return parseCurrent(TokenType.Vline);
	}

	/**
	* Parses an 'OpPlus' terminal.
	*/
	private ParseTreeNode opPlus()
	{
		return parseCurrent(TokenType.OpPlus);
	}

	/**
	* Parses an 'OpMinus' terminal.
	*/
	private ParseTreeNode opMinus()
	{
		return parseCurrent(TokenType.OpMinus);
	}

	/**
	* Parses an 'OpMultiply' terminal.
	*/
	private ParseTreeNode opMultiply()
	{
		return parseCurrent(TokenType.OpMultiply);
	}

	/**
	* Parses an 'OpDivide' terminal.
	*/
	private ParseTreeNode opDivide()
	{
		return parseCurrent(TokenType.OpDivide);
	}

	/**
	* Parses an 'OpPercent' terminal.
	*/
	private ParseTreeNode opPercent()
	{
		return parseCurrent(TokenType.OpPercent);
	}

	/**
	* Parses an 'OpConcat' terminal.
	*/
	private ParseTreeNode opConcat()
	{
		return parseCurrent(TokenType.OpConcat);
	}

	/**
	* Parses an 'OpExponent' terminal.
	*/
	private ParseTreeNode opExponent()
	{
		return parseCurrent(TokenType.OpExponent);
	}

	/**
	* Parses an 'OpLess' terminal.
	*/
	private ParseTreeNode opLess()
	{
		return parseCurrent(TokenType.OpLess);
	}

	/**
	* Parses an 'OpLessOrEqual' terminal.
	*/
	private ParseTreeNode opLessOrEqual()
	{
		return parseCurrent(TokenType.OpLessOrEqual);
	}

	/**
	* Parses an 'OpGreater' terminal.
	*/
	private ParseTreeNode opGreater()
	{
		return parseCurrent(TokenType.OpGreater);
	}

	/**
	* Parses an 'OpGreaterOrEqual' terminal.
	*/
	private ParseTreeNode opGreaterOrEqual()
	{
		return parseCurrent(TokenType.OpGreaterOrEqual);
	}

	/**
	* Parses an 'OpEqual' terminal.
	*/
	private ParseTreeNode opEqual()
	{
		return parseCurrent(TokenType.OpEqual);
	}

	/**
	* Parses an 'OpNotEqual' terminal.
	*/
	private ParseTreeNode opNotEqual()
	{
		return parseCurrent(TokenType.OpNotEqual);
	}

	/**
	* Parses an 'OpCellRange' terminal.
	*/
	private ParseTreeNode opCellRange()
	{
		return parseCurrent(TokenType.OpCellRange);
	}

	/**
	* Parses an 'OpSheetRef' terminal.
	*/
	private ParseTreeNode opSheetRef()
	{
		return parseCurrent(TokenType.OpSheetRef);
	}

	/**
	* Parses an 'CellIndex' terminal.
	*/
	private ParseTreeNode cellIndex()
	{
		return parseCurrent(TokenType.CellIndex);
	}

	/**
	* Parses an 'SheetRef' terminal.
	*/
	private ParseTreeNode sheetRef()
	{
		return parseCurrent(TokenType.SheetRef);
	}

	/**
	* Parses an 'Identifier' terminal.
	*/
	private ParseTreeNode identifier()
	{
		return parseCurrent(TokenType.Identifier);
	}

	/**
	* Parses an 'Error' terminal.
	*/
	private ParseTreeNode error()
	{
		return parseCurrent(TokenType.Error);
	}

	/**
	* Parses an 'Function' terminal.
	*/
	private ParseTreeNode function()
	{
		return parseCurrent(TokenType.FunctionCall);
	}

	/**
	* Parses an 'IntNumber' terminal.
	*/
	private ParseTreeNode intNumber()
	{
		return parseCurrent(TokenType.IntNumber);
	}

	/**
	* Parses a 'String' terminal.
	*/
	private ParseTreeNode string()
	{
		return parseCurrent(TokenType.String);
	}

	/**
	* Parses a 'FloatNumber' terminal.
	*/
	private ParseTreeNode floatNumber()
	{
		return parseCurrent(TokenType.FloatNumber);
	}



	/**
	* Gets a value indicating whether the parser consumed all tokens
	* in the source list.
	*/
	public boolean getDone()
	{
		return tokens.getDone() && getCurrentToken() == null;
	}

	/**
	* Gets the current token, or null, if done.
	*/
	private Token getCurrentToken()
	{
		return tokens.get(current);
	}

	/**
	* Gets the type of the current token, or null, if done.
	*/
	private TokenType getCurrentTokenType()
	{
		Token current = getCurrentToken();
		if (current == null)
			return null;
		return current.getType();
	}


	/***
	 * The list of tokens to parse.
	 */
	private Lexer.TokenList tokens;

	/***
	 * The current parsing position.
	 */
	private int current;
}