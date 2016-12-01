package ad.expression;

import java.util.ArrayList;


/**
 * Represents a node in a parse tree.
 */
public class ParseTreeNode
{
	/**
	 * Initializes a new instance of the {@link ParseTreeNode} class.
	 */
	public ParseTreeNode()
	{
		this(null);
	}

	/**
	 * Initializes a new instance of the {@link ParseTreeNode} class.
	 */
	public ParseTreeNode(Token token)
	{
		this.token = token;
		this.children = new ArrayList<ParseTreeNode>();
	}

	public void accept(ITreeVisitor<ParseTreeNode> visitor)
	{
		if (visitor.enterVisit(this))
		{
			for (ParseTreeNode child: children)
				if (child == null)
				{
					visitor.enterVisit(null);
					visitor.leaveVisit(null);
				}
				else child.accept(visitor);
		}
		visitor.leaveVisit(this);
	}


	/**
	 * Gets the list with all children of this node.
	 */
	public ArrayList<ParseTreeNode> getChildren()
	{
		return children;
	}

	/**
	 * Gets the underlying token.
	 */
	public Token getToken()
	{
		return token;
	}

	/**
	 * Gets a value indicating whether this node was originally enclosed in braces.
	 */
	public boolean getEnclosed()
	{
		return enclosed;
	}
	
	/**
	 * Sets a value indicating whether this node was originally enclosed in braces.
	 */
	public void setEnclosed(boolean value)
	{
		enclosed = value;
	}


	/**
	 * The underlying token (if any) or null.
	 */
	private Token token;

	/**
	 * The child nodes.
	 */
	private ArrayList<ParseTreeNode> children;
	
	private boolean enclosed;
}