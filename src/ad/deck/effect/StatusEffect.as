package ad.deck.effect 
{
	import ad.deck.card.CardState;
	import ad.event.Event;
	import ad.event.EventType;
	import ad.file.StatementProcessor;
	import ad.expression.ParseNode;
	import ad.expression.TokenType;
	import ad.map.Map;
	
	public class StatusEffect
	{
		public function StatusEffect(source:ParseNode = null) 
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
		
		public function getEventEffect(event:EventType):DynamicEffect
		{
			
		}
		
		
		private function loadFromFile(source:ParseNode):void
		{
			if (source == null || !source.token.type.equals(TokenType.AssignmentOperator) ||
				!source.getChildren()[0].token.type.equals(TokenType.Identifier)) 
				return;
			
			m_id = source.getChildren()[0].token.token.text;
			
			for each (var statement:ParseNode in source.getChildren()[1].getChildren())
				if (statement.token.type == TokenType.AssignmentOperator)
					switch (statement.getChildren()[0].token.token.text.toLowerCase())
					{
					case "name":
						m_name = statement.getChildren()[1].token.token.text;
						break;
					case "description":
						m_description = statement.getChildren()[1].token.token.text;
						break;
					case "duration":
						m_duration = parseInt(statement.getChildren()[1].token.token.text);
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
					if (file.getStatements()[0].getChildren()[0].token.token.text != "directories") return;
					
					for each (var dir:ParseNode in file.getStatements()[0].getChildren()[1].getChildren())
						var definitions:StatementProcessor = new StatementProcessor(dir.token.token.text,
							function(statements:Vector.<ParseNode>):void
							{
								for each (var statement:ParseNode in statements)
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