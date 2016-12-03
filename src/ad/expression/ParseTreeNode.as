package ad.expression
{
	import ad.expression.Token;
	
	public class ParseTreeNode
	{
		public function ParseTreeNode(token:Token = null)
		{
			this.m_token = token;
			this.m_children = new Vector.<ParseTreeNode>();
		}
		
		
		public function getChildren():Vector.<ParseTreeNode>
		{
			return m_children;
		}
		
		public function getToken():Token
		{
			return m_token;
		}
		
		public function getEnclosed():Boolean
		{
			return m_enclosed;
		}
		
		
		public function setEnclosed(value:Boolean):void
		{
			m_enclosed = value;
		}
		
		
		private var m_token:Token;
		private var m_children:Vector.<ParseTreeNode>;
		private var m_enclosed:Boolean;
	}
}