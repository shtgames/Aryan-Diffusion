package ad.expression 
{
	import ad.map.Map;
	
	public class BracketSyntaxEvaluator 
	{
		public function toString():String
		{
			return hasUnclosed() ? "<Unclosed>" : "<Closed>";
		}
		
		public function next(token:TokenType):Boolean
		{
			if (token == null) return true;
			
			if (m_pairs.contains(token.ordinal))
			{
				m_brackets.push(token.ordinal);
				m_unclosedCount.push(token.ordinal, m_unclosedCount.at(token.ordinal) + 1);
			}
			else if (m_pairs.keyOf(token.ordinal) != null)
			{
				const key:uint = m_brackets[m_brackets.length - 1];
				if (m_brackets.length == 0 || token.ordinal != m_pairs.at(key))
					return false;
				
				m_unclosedCount.push(key, m_unclosedCount.at(key) - 1);
				m_brackets.pop();
			}
			
			return true;
		}
		
		public function addPair(opening:TokenType, closing:TokenType):BracketSyntaxEvaluator
		{
			if (opening != null && closing != null && opening != closing && !m_unclosedCount.contains(opening.ordinal))
			{
				m_pairs.push(opening.ordinal, closing.ordinal);
				m_unclosedCount.push(opening.ordinal, 0);
			}
			return this;
		}
		
		public function reset():BracketSyntaxEvaluator
		{
			m_brackets = new Vector.<uint>();
			for (var key:String in m_unclosedCount)
				m_unclosedCount.push(key, 0);
			return this;
		}
		
		public function hasUnclosed(token:TokenType = null):Boolean
		{
			if (token == null || m_unclosedCount.contains(token.ordinal))
				return m_brackets.length != 0;
			return m_unclosedCount.at(token.ordinal) != 0;
		}
		
		public function getUnclosedCount(token:TokenType):uint
		{
			if (!m_unclosedCount.contains(token.ordinal)) return 0;
			return m_unclosedCount.at(token.ordinal);
		}
		
		public function isTopLevel(token:TokenType, count:uint = 1):Boolean
		{
			return token != null && m_brackets.length != 0 &&
				m_brackets[m_brackets.length - 1] == token.ordinal && m_unclosedCount.at(token.ordinal) == count;
		}
		
		public function getCurrent():TokenType
		{
			return m_brackets.length == 0 ? null : TokenType.at(m_brackets[m_brackets.length - 1]);
		}
		
		
		private var m_brackets:Vector.<uint> = new Vector.<uint>();
		private const m_pairs:Map = new Map(), m_unclosedCount:Map = new Map();
	}
}