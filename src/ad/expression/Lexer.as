package ad.expression;

import java.text.DecimalFormatSymbols;
import java.util.Iterator;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.mindfusion.common.ByRef;
import com.mindfusion.common.Constants;
import com.mindfusion.common.ExtendedArrayList;
import com.mindfusion.common.ExtendedHashMap;
import com.mindfusion.spreadsheet.CellIndex;


public class Lexer
{
	private Lexer(int tokensCapacity, int allTokensCapacity, Locale locale)
	{
		this.input = "";
		this.locale = locale;
		String decimalSeparator = Character.toString(DecimalFormatSymbols.getInstance(locale).getDecimalSeparator());
		this.floatNumberRegex =	getFloatNumberRegex(decimalSeparator);

		tokens = new ExtendedArrayList<Token>(tokensCapacity);
		allTokens = new ExtendedArrayList<Token>(allTokensCapacity);
	}

	/**
	* Initializes a new instance of the Lexer class.
	*/
	public Lexer(String input, Locale locale)
	{
		this.current = 0;
		this.input = input;
		this.locale = locale;
		String decimalSeparator = Character.toString(DecimalFormatSymbols.getInstance(locale).getDecimalSeparator());
		this.floatNumberRegex =	getFloatNumberRegex(decimalSeparator);

		tokens = new ExtendedArrayList<Token>();
		allTokens = new ExtendedArrayList<Token>();
	}
	
	/**
	* Attempts to parse the next token from the input string.
	*/
	public boolean next()
	{
		if (getDone())
			return false;

		// Consume equal sign(s) at the start of the expression
		if (!startedContent)
		{
			ByRef<Integer> lengthRef = new ByRef<>(0);
			if (match(prefixRegex, lengthRef))
			{
				int length = lengthRef.get();
				add(new Token(input.substring(current, current + length), TokenType.Special, current));
				current += length;
				return true;
			}

			startedContent = true;
		}

		if (ws()) return true;

		if (ob()) return true;

		if (cb()) return true;

		if (ocb()) return true;

		if (ccb()) return true;

		if (vline()) return true;

		if (floatNumber()) return true;

		if (intNumber()) return true;

		if (string()) return true;

		if (opConcat()) return true;

		if (opExponent()) return true;

		if (opPlus()) return true;

		if (opMinus()) return true;

		if (opMultiply()) return true;

		if (opDivide()) return true;

		if (opPercent()) return true;

		if (opLessOrEqual()) return true;

		if (opGreaterOrEqual()) return true;

		if (opNotEqual()) return true;

		if (opLess()) return true;

		if (opGreater()) return true;

		if (opEqual()) return true;

		if (opSheetRef()) return true;

		if (opCellRange()) return true;

		if (comma()) return true;

		if (semicolon()) return true;

		if (cellRef()) return true;

		if (functionCall()) return true;

		if (sheetRef()) return true;

		if (identifier()) return true;

		if (error()) return true;
		
		throw new IllegalStateException(String.format("Failed to recognize character '%1$s' at position " +
			"%2$d within the input string '%3$s'.", input.charAt(current), current, input));
	}

	public Lexer transform(Function<Token, Token> t) throws Exception
	{
		// Force enumeration of the current tokens
		if (!getDone())
		{
			TokenList list = getTokens();
			for (@SuppressWarnings("unused") Token token: list);
		}
		
		Lexer lexer = new Lexer(tokens.size(), allTokens.size(), locale);
		for (Token token: allTokens)
		{
			Token ttoken = t.apply(token);
			if (ttoken == token)
				throw new Exception("The transformation cannot be identical.");
			lexer.allTokens.add(ttoken);
			if (tokens.contains(token))
				lexer.tokens.add(ttoken);
		}

		int i = 0;
		for (Token token: lexer.allTokens)
		{
			token.setIndex(i);
			i += token.getText().length();
		}

		return lexer;
	}

	/**
	* Object.toString override.
	*/
	@Override
	public String toString()
	{
		if (!getDone())
			return "<Unprocessed>";

		StringBuilder builder = new StringBuilder();
		for (Token token: allTokens)
		{
			if (token.getType() == TokenType.String)
				builder.append('"');
			builder.append(token.getText());
			if (token.getType() == TokenType.String)
				builder.append('"');
		}
		return builder.toString();
	}

	/**
	* Adds the specified recognized token to the underlying lists.
	*/
	private void add(Token token)
	{
		if (token.getType() != TokenType.Ws && token.getType() != TokenType.Special)
			tokens.add(token);
		allTokens.add(token);
	}

	/**
	* Matches the specified character against the character
	* at the current position within the underlying string.
	*/
	private boolean match(char c)
	{
		if (current >= input.length())
			return false;

		return input.charAt(current) == c;
	}

	/**
	* Matches the specified string against the substring at the
	* current position within the underlying string.
	*/
	private boolean match(String s)
	{
		if (current + s.length() > input.length())
			return false;

		for (int i = 0; i < s.length(); i++)
			if (input.charAt(current + i) != s.charAt(i)) return false;

		return true;
	}

	/**
	* Matches the specified regex against the string starting
	* from the current position within the underlying string.
	*/
	private Matcher match(Pattern regex)
	{
		Matcher match = regex.matcher(input.substring(current));
		
		if (match == null || !match.find() || match.start() != 0 || match.end() == 0)
			return null;
		
		return match;
	}

	/**
	* Matches the specified regex against the string starting
	* from the current position within the underlying string.
	*/
	private boolean match(Pattern regex, ByRef<Integer> length)
	{
		length.set(0);
		
		Matcher match = match(regex);
		if (match == null) return false;
		
		length.set(match.end() - match.start()); // !Unsure if this is the equivalent of: getTextLength()
		
		return true;
	}
	
	/**
	* Recognizes a whitespace token.
	*/
	private boolean ws()
	{
		ByRef<Integer> lengthRef = new ByRef<>(0);
		if (match(wsRegex, lengthRef))
		{
			int length = lengthRef.get();
			add(new Token(input.substring(current, current + length), TokenType.Ws, current));
			current += length;
			return true;
		}

		return false;
	}

	/**
	* Recognizes an opening bracket.
	*/
	private boolean ob()
	{
		if (match('('))
		{
			add(new Token(input.substring(current, current + 1), TokenType.Ob, current));
			current++;
			return true;
		}

		return false;
	}

	/**
	* Recognizes a closing bracket.
	*/
	private boolean cb()
	{
		if (match(')'))
		{
			add(new Token(input.substring(current, current + 1), TokenType.Cb, current));
			current++;
			return true;
		}

		return false;
	}

	/**
	* Recognizes an opening curly bracket.
	*/
	private boolean ocb()
	{
		if (match('{'))
		{
			add(new Token(input.substring(current, current + 1), TokenType.Ocb, current));
			current++;
			return true;
		}

		return false;
	}

	/**
	* Recognizes a closing curly bracket.
	*/
	private boolean ccb()
	{
		if (match('}'))
		{
			add(new Token(input.substring(current, current + 1), TokenType.Ccb, current));
			current++;
			return true;
		}

		return false;
	}

	/**
	* Recognizes a vertical line.
	*/
	private boolean vline()
	{
		if (match('|'))
		{
			add(new Token(input.substring(current, current + 1), TokenType.Vline, current));
			current++;
			return true;
		}

		return false;
	}

	/**
	* Recognizes an ampersand '&amp;'.
	*/
	private boolean opConcat()
	{
		if (match('&'))
		{
			add(new Token(input.substring(current, current + 1), TokenType.OpConcat, current));
			current++;
			return true;
		}

		return false;
	}
	
	/**
	* Recognizes an exponent '^'.
	*/
	private boolean opExponent()
	{
		if (match('^'))
		{
			add(new Token(input.substring(current, current + 1), TokenType.OpExponent, current));
			current++;
			return true;
		}

		return false;
	}

	/**
	* Recognizes a plus sign '+'.
	*/
	private boolean opPlus()
	{
		if (match('+'))
		{
			add(new Token(input.substring(current, current + 1), TokenType.OpPlus, current));
			current++;
			return true;
		}

		return false;
	}

	/**
	* Recognizes a minus sign '-'.
	*/
	private boolean opMinus()
	{
		if (match('-'))
		{
			add(new Token(input.substring(current, current + 1), TokenType.OpMinus, current));
			current++;
			return true;
		}

		return false;
	}

	/**
	* Recognizes a multiplication operator '*'.
	*/
	private boolean opMultiply()
	{
		if (match('*'))
		{
			add(new Token(input.substring(current, current + 1), TokenType.OpMultiply, current));
			current++;
			return true;
		}

		return false;
	}

	/**
	* Recognizes a division operator '/'.
	*/
	private boolean opDivide()
	{
		if (match('/'))
		{
			add(new Token(input.substring(current, current + 1), TokenType.OpDivide, current));
			current++;
			return true;
		}

		return false;
	}

	/**
	* Recognizes a percent operator '%'.
	*/
	private boolean opPercent()
	{
		if (match('%'))
		{
			add(new Token(input.substring(current, current + 1), TokenType.OpPercent, current));
			current++;
			return true;
		}

		return false;
	}

	/**
	* Recognizes a less than comparison operator '&lt;'.
	*/
	private boolean opLess()
	{
		if (match('<'))
		{
			add(new Token(input.substring(current, current + 1), TokenType.OpLess, current));
			current++;
			return true;
		}

		return false;
	}

	/**
	* Recognizes a greater than comparison operator '&gt;'.
	*/
	private boolean opGreater()
	{
		if (match('>'))
		{
			add(new Token(input.substring(current, current + 1), TokenType.OpGreater, current));
			current++;
			return true;
		}

		return false;
	}

	/**
	* Recognizes an equal comparison operator '='.
	*/
	private boolean opEqual()
	{
		if (match('='))
		{
			add(new Token(input.substring(current, current + 1), TokenType.OpEqual, current));
			current++;
			return true;
		}

		return false;
	}

	/**
	* Recognizes a not equal comparison operator '&lt;&gt;'.
	*/
	private boolean opNotEqual()
	{
		if (match("<>"))
		{
			add(new Token(input.substring(current, current + 2), TokenType.OpNotEqual, current));
			current += 2;
			return true;
		}

		return false;
	}

	/**
	* Recognizes a less than or equal comparison operator '&lt;='.
	*/
	private boolean opLessOrEqual()
	{
		if (match("<="))
		{
			add(new Token(input.substring(current, current + 2), TokenType.OpLessOrEqual, current));
			current += 2;
			return true;
		}

		return false;
	}

	/**
	* Recognizes a greater than or equal comparison operator '&gt;='.
	*/
	private boolean opGreaterOrEqual()
	{
		if (match(">="))
		{
			add(new Token(input.substring(current, current + 2), TokenType.OpGreaterOrEqual, current));
			current += 2;
			return true;
		}

		return false;
	}

	/**
	* Recognizes a member access operator '.'.
	*/
	@SuppressWarnings("unused")
	private boolean opDot()
	{
		if (match('.'))
		{
			add(new Token(input.substring(current, current + 1), TokenType.OpDot, current));
			current++;
			return true;
		}

		return false;
	}

	/**
	* Recognizes a cell reference on another sheet '!'.
	*/
	private boolean opSheetRef()
	{
		if (match('!') || match('.'))
		{
			add(new Token(input.substring(current, current + 1), TokenType.OpSheetRef, current));
			current++;
			return true;
		}

		return false;
	}

	/**
	* Recognizes a cell range operator ':'.
	*/
	private boolean opCellRange()
	{
		if (match(':'))
		{
			add(new Token(input.substring(current, current + 1), TokenType.OpCellRange, current));
			current++;
			return true;
		}

		return false;
	}

	/**
	* Recognizes comma ','.
	*/
	private boolean comma()
	{
		if (match(','))
		{
			add(new Token(input.substring(current, current + 1), TokenType.Comma, current));
			current++;
			return true;
		}

		return false;
	}

	/**
	* Recognizes semicolon ';'.
	*/
	private boolean semicolon()
	{
		if (match(';'))
		{
			add(new Token(input.substring(current, current + 1), TokenType.Semicolon, current));
			current++;
			return true;
		}

		return false;
	}

	/**
	* Recognizes a sheet reference.
	*/
	private boolean sheetRef()
	{
		Matcher match = match(sheetRegex);
		if (match != null)
		{
			int length = 0;
			String name = null;
			String nameGroup = match.group("name");
			if (nameGroup != null && !nameGroup.isEmpty())
			{
				name = nameGroup;
				length = nameGroup.length();
			}
			else
			{
				nameGroup = match.group("qname");
				if (nameGroup != null && !nameGroup.isEmpty())
				{
					name = nameGroup.replace("''", "'");
					length = nameGroup.length() + 2;
				}
				// Apostrophes are outside of the group
			}

			if (name != null && name.length() != 0)
			{
				add(new Token(name, TokenType.SheetRef, current));
				current += length;
				return true;
			}
		}

		return false;
	}

	/**
	* Recognizes a function calls.
	*/
	private boolean functionCall()
	{
		Matcher match = match(functionRegex);
		if (match != null)
		{
			int length = 0;
			String name = null;
			String nameGroup = match.group("name");
			if (nameGroup != null && !nameGroup.isEmpty())
			{
				name = nameGroup;
				length = nameGroup.length();
			}
			else
			{
				nameGroup = match.group("qname");
				if (nameGroup != null && !nameGroup.isEmpty())
				{
					name = nameGroup.replace("''", "'");
					length = nameGroup.length() + 2;
				}
				// Apostrophes are outside of the group
			}
			
			if (input.charAt(match.start()) == '@')
				length += 1;
			
			if (name != null && name.length() != 0)
			{
				add(new Token(name, TokenType.FunctionCall, current));
				current += length;
				return true;
			}
		}

		return false;
	}

	/**
	* Recognizes a cell reference.
	* 
	* Valid cell references include:
	* Numbers only: 1,2,.. (currently NOT supported)
	* Letters only: A,B,.. (currently NOT supported)
	* Numbers and letters combinations: A1,AC3,BD11,..
	* All of the above prefixed by $ sign: $1,$A,$A1,A$1,$A$1,..
	* Also recognizes references in the R1C1-style format.
	*/
	private boolean cellRef()
	{
		Matcher match = match(referenceRegexOld);
		if (match != null)
		{
			add(new Token(match.group().trim(), TokenType.CellIndex, current)); // !Unsure if group() is equivalent to: getValue()
			current += match.end() - match.start();
			return true;
		}

		match = match(referenceRegex);
		if (match != null)
		{
			// Check if the reference is within the limit. For the column
			// use ordinal string comparison to avoid having to convert column letters
			int column = CellIndex.getColumnIndex(match.group("cC"));
			if (column >= Constants.MaxColumn)
				return false;

			int row = Integer.parseInt(match.group("rR"));
			if (row > Constants.MaxRow)
				return false;

			add(new Token(match.group().trim(), TokenType.CellIndex, current)); // !Unsure if group() is equivalent to: getValue()
			current += match.end() - match.start(); // !Unsure if this is equivalent to: getTextLength()
			return true;
		}

		return false;
	}

	/**
	* Recognizes an identifier.
	*/
	private boolean identifier()
	{
		ByRef<Integer> lengthRef = new ByRef<>(0);
		if (match(identifierRegex, lengthRef))
		{
			int length = lengthRef.get();
			add(new Token(input.substring(current, current + length), TokenType.Identifier, current));
			current += length;
			return true;
		}

		return false;
	}

	/**
	* Recognizes a string literal.
	*/
	private boolean string()
	{
		ByRef<Integer> lengthRef = new ByRef<>(0);
		if (match(stringRegex, lengthRef))
		{
			int length = lengthRef.get();
			// Replace leading and trailing quotes as well as repeating quotes inside the string
			String value = input.substring(current, current + length);
			value = value.substring(1, value.length() - 1);
			value = value.replace("\"\"", "\"");

			add(new Token(value, TokenType.String, current));
			current += length;
			return true;
		}

		return false;
	}

	/**
	* Recognizes an integer number.
	*/
	private boolean intNumber()
	{
		ByRef<Integer> lengthRef = new ByRef<>(0);
		if (match(intNumberRegex, lengthRef))
		{
			int length = lengthRef.get();
			add(new Token(input.substring(current, current + length), TokenType.IntNumber, current));
			current += length;
			return true;
		}

		return false;
	}

	/**
	* Recognizes an error literal.
	*/
	private boolean error()
	{
		ByRef<Integer> lengthRef = new ByRef<>(0);
		if (match(errorRegex, lengthRef))
		{
			int length = lengthRef.get();
			add(new Token(input.substring(current, current + length).toUpperCase(), TokenType.Error, current));
			current += length;
			return true;
		}

		return false;
	}

	/**
	* Recognizes a float number.
	*/
	private boolean floatNumber()
	{
		ByRef<Integer> lengthRef = new ByRef<>(0);
		if (match(floatNumberRegex, lengthRef))
		{
			int length = lengthRef.get();
			add(new Token(input.substring(current, current + length), TokenType.FloatNumber, current));
			current += length;
			return true;
		}

		return false;
	}

	private static Pattern getFloatNumberRegex(String decimalSeparator)
	{
		ByRef<Pattern> regexRef = new ByRef<>();
		if (floatNumberRegexes.tryGetValue(decimalSeparator, regexRef))
			return regexRef.get();

		Pattern regex = Pattern.compile("[0-9]*" + Pattern.quote(decimalSeparator) + "?[0-9]+([eE][-+]?[0-9]+)?",
			Pattern.UNICODE_CHARACTER_CLASS);
		floatNumberRegexes.put(decimalSeparator, regex);
		return regex;
	}

	/**
	* Gets the list of tokens produced by the lexer.
	*/
	public TokenList getTokens()
	{
		return new TokenList(this);
	}


	/**
	* Gets a value indicating whether the lexer has processed the entire input string.
	*/
	public boolean getDone()
	{
		return current >= input.length();
	}

	/**
	 * Regular expression for sheet references.
	 * <p> 
	 * Matches either anything enclosed by single quotes and followed
	 * by an exclamation mark, or a proper identifier followed by an
	 * exclamation mark. Captures the identifier in 'name'.
	 */
	private final static Pattern sheetRegex = Pattern.compile("('(?<qname>([^']|'')*)'|(?<name>[a-zA-Z][a-zA-Z0-9_]*))[!.]", Pattern.UNICODE_CHARACTER_CLASS);

	/**
	 * Regular expression for function identifiers.
	 * <p>
	 * Matches proper identifiers followed by an opening bracket. Captures
	 * the identifier in 'name'.
	 */
	private final static Pattern functionRegex = Pattern.compile("@?('(?<qname>[^\\(]*)'|(?<name>[a-zA-Z][a-zA-Z0-9_\\.]*))(\\s)*\\(", Pattern.UNICODE_CHARACTER_CLASS);

	/**
	 * Regular expression for identifiers.
	 */
	private final static Pattern identifierRegex = Pattern.compile("[a-zA-Z_][a-z_A-Z0-9]*", Pattern.UNICODE_CHARACTER_CLASS);

	/**
	 * Regular expression for string literals.
	 */
	private final static Pattern stringRegex = Pattern.compile("\"([^\"]|\"\")*\"", Pattern.UNICODE_CHARACTER_CLASS);

	/**
	 * Regular expression for integer numbers.
	 */
	private final static Pattern intNumberRegex = Pattern.compile("[0-9]+", Pattern.UNICODE_CHARACTER_CLASS);

	/**
	 * Regular expression for error literals.
	 */
	private final static Pattern errorRegex = Pattern.compile("#[a-zA-Z0-9]+([!?]|/([a-zA-Z]|[0-9][!?]))", Pattern.UNICODE_CHARACTER_CLASS);

	/**
	 * Regular expression for cell references in the old format.
	 */
	private final static Pattern referenceRegexOld = Pattern.compile("[rR]([1-9][0-9]*|\\[[1-9][0-9]*\\])[cC]([1-9][0-9]*|\\[[1-9][0-9]*\\])(?!(\\s)*[!.(])", Pattern.UNICODE_CHARACTER_CLASS);

	/**
	 * Regular expression for cell references.
	 */
	private final static Pattern referenceRegex = Pattern.compile("(\\$?(?<cC>[A-Za-z]{1,3})\\$?(?<rR>[0-9][0-9]*))(?!(\\s)*[!.(])", Pattern.UNICODE_CHARACTER_CLASS);

	/**
	 * Regular expression for float numbers for different locales.
	 */
	private final static ExtendedHashMap<String, Pattern> floatNumberRegexes = new ExtendedHashMap<String, Pattern>();

	/**
	 * Regular expression for whitespaces.
	 */
	private final static Pattern wsRegex = Pattern.compile("[\\s]*", Pattern.UNICODE_CHARACTER_CLASS);

	/**
	 * Regular expression for the formula prefix sign '='.
	 */
	private final static Pattern prefixRegex = Pattern.compile("(=)*", Pattern.UNICODE_CHARACTER_CLASS);


	/**
	* The current locale.
	*/
	private Locale locale;

	/**
	* The float number regular expression for the specified locale.
	*/
	private Pattern floatNumberRegex;

	/**
	* The sequence of recognized tokens.
	*/
	ExtendedArrayList<Token> tokens;

	/**
	* The sequence of tokens, including whitespaces.
	*/
	private ExtendedArrayList<Token> allTokens;

	/**
	* The current processing position.
	*/
	private int current;

	/**
	* The input string.
	*/
	private String input;

	/**
	* Indicates that lexer has started processing the actual expression,
	* that is, the portion after the equal sign.
	*/
	private boolean startedContent;
		
	/**
	* Represents an enumerable list of tokens. The tokens in the list
	* are not parsed until after they are requested.
	*/
	public static class TokenList
		implements Iterable<Token>
	{
		private static class TokenEnumerator
			implements Iterator<Token>
		{
			public TokenEnumerator(TokenList list)
			{
				this.list = list;
				current = -1;
			}
			
			@Override
			public boolean hasNext()
			{
				return list.get(++current) != null;
			}
			
			@SuppressWarnings("unused")
			public void reset()
			{
				current = -1;
			}
			
			@SuppressWarnings("unused")
			public Token getCurrent()
			{
				return list.get(current);
			}
			
			@Override
			public Token next() 
			{
				return list.get(++current);
			}
	
			TokenList list;
			int current;
		}
		
		public TokenList(Lexer lexer)
		{
			this.lexer = lexer;
		}
		
		@Override
		public Iterator<Token> iterator()
		{
			return new TokenEnumerator(this);
		}
		
		public Token get(int index)
		{
			while (index >= lexer.tokens.size())
			{
				if (!lexer.next())
					return null;
			}
			
			return lexer.tokens.get(index);
		}

		public boolean getDone()
		{
			return lexer.getDone();
		}

		private Lexer lexer;
	}
}