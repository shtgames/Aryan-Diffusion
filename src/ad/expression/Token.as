package ad.expression;


/**
 * Represents a recognized token from a sequence of characters,
 * which conforms to the MindFusion Spreadsheet Expressions.
 */
public class Token
{
	/**
	 * Initializes a new instance of the {@link Token} class.
	 */
	public Token(String text, TokenType tokenType)
	{
		this.text = text;
		this.type = tokenType;
	}

	/**
	 * Initializes a new instance of the {@link Token} class.
	 */
	public Token(String text, TokenType tokenType, int index)
	{
		this.text = text;
		this.type = tokenType;
		this.index = index;
	}
	
	/**
	 * Initializes a new instance of the {@link Token} class.
	 */
	public Token(Token prototype)
	{
		this.text = prototype.text;
		this.type = prototype.type;
		this.index = prototype.index;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public String toString()
	{
		return String.format("\"%1$s\" [%2$s]", text, type.name());
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public int hashCode()
	{
		return text.hashCode() ^ type.ordinal();
	}


	/**
	 * Gets the token text.
	 */
	public String getText()
	{
		return text;
	}

	/**
	 * Sets the token text.
	 */
	public void setText(String value)
	{
		text = value;
	}

	/**
	 * Gets the token type.
	 */
	public TokenType getType()
	{
		return type;
	}

	/**
	 * Gets the index of this token in the input string.
	 */
	public int getIndex()
	{
		return index;
	}
	
	/**
	 * Sets the index of this token in the input string.
	 */
	public void setIndex(int value)
	{
		index = value;
	}

	/**
	 * Gets the length of this token.
	 */
	public int getLength()
	{
		int l = text.length();
		if (type == TokenType.String)
			l += 2; // quotes
		return l;
	}


	/**
	 * The text of the token.
	 */
	private String text;

	/**
	 * The type of the token.
	 */
	private TokenType type;

	/**
	 * The index of the token within the input string.
	 */
	private int index;
}