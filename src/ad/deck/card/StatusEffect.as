package ad.deck.card 
{
	import ad.event.Event;
	import ad.event.EventType;
	import ad.file.StatementProcessor;
	import ad.expression.ParseTreeNode;
	import ad.expression.TokenType;
	import ad.map.Map;
	
	public class StatusEffect
	{
		public function StatusEffect(source:ParseTreeNode = null) 
		{
			loadFromFile(source);
		}
		
		
		public function toString():String
		{
			return m_id;
		}
		
		
		public function get id():String
		{
			return m_id;
		}
		
		public function get name():String
		{
			return m_name;
		}
		
		public function get description():String
		{
			return m_description;
		}
		
		public function get duration():uint
		{
			return m_duration;
		}
		
		
		public function input(event:Event, parent:CardState):void
		{
			if (event == null || parent == null || !event.isValid() || !m_effects.contains(event.type)) return;
			
			m_effects.at(event.type).applyTo(event.data.push("this", parent));
		}
		
		
		private function loadFromFile(source:ParseTreeNode):void
		{
			if (source == null || !source.getToken().type.equals(TokenType.EqualityOperator) ||
				!source.getChildren()[0].getToken().type.equals(TokenType.Identifier)) 
				return;
			
			m_id = source.getChildren()[0].getToken().text;
			
			for each (var statement:ParseTreeNode in source.getChildren()[1].getChildren())
				if (statement.getToken().type == TokenType.EqualityOperator)
					switch (statement.getChildren()[0].getToken().text.toLowerCase())
					{
					case "name":
						m_name = statement.getChildren()[1].getToken().text;
						break;
					case "description":
						m_description = statement.getChildren()[1].getToken().text;
						break;
					}
		}
		
		
		private var m_id:String = null;
		private var m_name:String = "", m_description:String = "";
		private var m_duration:uint = 0;
		private var m_effects:Map = new Map();
		
		
		public static function loadResources(path:String):void
		{			
			var file:StatementProcessor = new StatementProcessor(path, function():void
				{
					if (file.getStatements()[0].getChildren()[0].getToken().text != "directories") return;
					
					for each (var dir:ParseTreeNode in file.getStatements()[0].getChildren()[1].getChildren())
						var definitions:StatementProcessor = new StatementProcessor(dir.getToken().text,
							function(statements:Vector.<ParseTreeNode>):void
							{
								for each (var statement:ParseTreeNode in statements)
								{
									const statusEffect:StatusEffect = new StatusEffect(statement);
									statusEffects.push(statusEffect.m_id, statusEffect);
								}
							});
				});
		}
		
		public static function getEffect(id:String):StatusEffect
		{
			return statusEffects.at(id);
		}
		
		public static function exists(id:String):Boolean
		{
			return statusEffects.contains(id);
		}
		
		
		private static var statusEffects:Map = new Map();
	}
}