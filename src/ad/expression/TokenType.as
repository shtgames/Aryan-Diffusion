package ad.expression;


/**
 * Specifies the type of a token.
 */
public enum TokenType
{
	/**
	 * Indicates the formula prefix token '='.
	 */
	Special,

	/**
	 * Indicates a whitespace token.
	 */
	Ws,

	/**
	 * Indicates an opening bracket '('.
	 */
	Ob,

	/**
	 * Indicates a closing bracket ')'.
	 */
	Cb,

	/**
	 * Indicates an opening curly bracket '{'.
	 */
	Ocb,

	/**
	 * Indicates a closing curly bracket '}'.
	 */
	Ccb,

	/**
	 * Indicates a vertical line '|'.
	 */
	Vline,

	/**
	 * Indicates a matrix node in a parse tree.
	 */
	Matrix,

	/**
	 * Indicates a matrix row node in a parse tree.
	 */
	MatrixRow,

	/**
	 * Indicates an identifier.
	 */
	Identifier,

	/**
	 * Indicates an error literal.
	 */
	Error,

	/**
	 * Indicates a cell reference.
	 */
	CellIndex,

	/**
	 * Indicates a sheet reference.
	 */
	SheetRef,

	/**
	 * Indicates a function identifier.
	 */
	FunctionCall,

	/**
	 * Indicates a floating point number.
	 */
	FloatNumber,

	/**
	 * Indicates an integer number.
	 */
	IntNumber,

	/**
	 * Indicates a string literal.
	 */
	String,

	/**
	 * Indicates a string concatenation sign '&amp;'.
	 */
	OpConcat,

	/**
	 * Indicates the exponent sign '^'.
	 */
	OpExponent,

	/**
	 * Indicates a plus sign '+'.
	 */
	OpPlus,

	/**
	 * Indicates a minus sign '-'.
	 */
	OpMinus,

	/**
	 * Indicates a multiplication operator '*'.
	 */
	OpMultiply,

	/**
	 * Indicates a division operator '/'.
	 */
	OpDivide,

	/**
	 * Indicates a percent operator '%'.
	 */
	OpPercent,

	/**
	 * Indicates a less than comparison operator '&lt;'.
	 */
	OpLess,

	/**
	 * Indicates a greater than comparison operator '&gt;'.
	 */
	OpGreater,

	/**
	 * Indicates an equal comparison operator '='.
	 */
	OpEqual,

	/**
	 * Indicates a not equal comparison operator '&lt;&gt;'.
	 */
	OpNotEqual,

	/**
	 * Indicates a less than or equal comparison operator '&lt;='.
	 */
	OpLessOrEqual,

	/**
	 * Indicates a greater than or equal comparison operator '&gt;='.
	 */
	OpGreaterOrEqual,

	/**
	 * Indicates a member access operator '.'.
	 */
	OpDot,

	/**
	 * Indicates a cell reference on another sheet operator '!'.
	 */
	OpSheetRef,

	/**
	 * Indicates a cell range operator ':'.
	 */
	OpCellRange,

	/**
	 * Indicates a semicolon ';'.
	 */
	Semicolon,

	/**
	 * Indicates a comma ','.
	 */
	Comma,
}