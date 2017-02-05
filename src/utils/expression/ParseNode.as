package utils.expression
{
	import utils.expression.Token;
	
	public class ParseNode
	{
		public function ParseNode(token:Token)
		{
			m_token = token;
		}
		
		
		public function toString():String
		{
			return m_token == null ? "<Undefined>" : m_token.toString() + ": " + m_children.length;
		}
		
		public function evaluate(scope:Object = null, context:Object = null):Object
		{
			return m_token == null || m_token.type == null ?
				null : m_token.type.evaluate(this, scope, context);
		}
		
		
		public function get token():Token
		{
			return m_token;
		}
		
		public function getChildCount():uint
		{
			return m_children.length;
		}
		
		public function getChild(index:uint):ParseNode
		{
			return index >= m_children.length ? null : m_children[index];
		}
		
		public function addChild(child:ParseNode):ParseNode
		{
			if (child == null) return this;
			
			m_children.push(child);
			return this;
		}
		
		public function addChildren(children:Vector.<ParseNode>):ParseNode
		{
			if (children == null) return this;
			
			for each (var child:ParseNode in children)
				addChild(child);
			return this;
		}
		
		public function removeChild(index:uint):ParseNode
		{
			if (index < m_children.length)
				m_children.removeAt(index);
			return this;
		}
		
		public function clearChildren():ParseNode
		{
			m_children.length = 0;
			return this;
		}
		
		
		private var m_token:Token;
		private var m_children:Vector.<ParseNode> = new Vector.<ParseNode>();
	}
}