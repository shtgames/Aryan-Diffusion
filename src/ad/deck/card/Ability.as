package ad.deck.card 
{
	import ad.deck.card.Card;
	import ad.deck.effect.DynamicEffect;	
	import ad.expression.ParseNode;
	import ad.expression.TokenType;	
	import ad.file.StatementProcessor;
	import ad.map.Map;
	
	public final class Ability
	{
		public function Ability(source:ParseNode = null) 
		{
			loadFromFile(source);
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
		
		public function get type():uint
		{
			return m_type;
		}
		
		
		public function applyTo(target:CardState, source:CardState):Boolean
		{
			if (target == null || source == null)
				return false;
			
			var returnValue:Boolean = false;			
			for (var i:uint = 0; i != m_sourceConditions.length; ++i)
				if (m_sourceConditions[i].isFulfilled(target))
				{
					m_sourceEffects[i].applyTo( new Map().push("target", target).push("source", source) );
					returnValue = true;
				}
			if (!returnValue) return false;
			
			for (var i:uint = 0; i != m_targetConditions.length; ++i)
				if (m_targetConditions[i].isFulfilled(target))
				{
					m_targetEffects[i].applyTo( new Map().push("target", target).push("source", source) );
					returnValue = true;
				}
			
			return returnValue;
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
					case "type":
						m_type = parseType(statement.getChildren()[1].token.token.text);
						break;
					case "source":
						for each (var currentCase:ParseNode in statement.getChildren()[1].getChildren())
						{
							var condition:Condition = null;
							var effect:DynamicEffect = null;
							for each (var currentStatement:ParseNode in currentCase.getChildren()[1].getChildren())
								switch (currentStatement.getChildren()[0].token.token.text.toLowerCase())
								{
								case "condition":
									condition = new Condition(currentStatement);
									break;
								case "effect":
									effect = new DynamicEffect(currentStatement);
									break;
								}
							
							if (condition != null)
							{
								m_sourceConditions.push(condition);
								m_sourceEffects.push(effect == null ? new DynamicEffect() : effect);
							}
						}
						break;
					case "target":
						for each (var currentCase:ParseNode in statement.getChildren()[1].getChildren())
						{
							var condition:Condition = null;
							var effect:DynamicEffect = null;
							for each (var currentStatement:ParseNode in currentCase.getChildren()[1].getChildren())
								switch (currentStatement.getChildren()[0].token.token.text.toLowerCase())
								{
								case "condition":
									condition = new Condition(currentStatement);
									break;
								case "effect":
									effect = new DynamicEffect(currentStatement);
									break;
								}
							
							if (condition != null)
							{
								m_targetConditions.push(condition);
								m_targetEffects.push(effect == null ? new DynamicEffect() : effect);
							}
						}					
						break;
					}
		}
		
		
		private var m_id:String = null;
		private var m_name:String = "", m_description:String = "";
		private var m_type:uint = ACTIVE;
		private var m_sourceConditions:Vector.<Condition> = new Vector.<Condition>(), m_sourceEffects:Vector.<DynamicEffect> = new Vector.<DynamicEffect>();
		private var m_targetConditions:Vector.<Condition> = new Vector.<Condition>(), m_targetEffects:Vector.<DynamicEffect> = new Vector.<DynamicEffect>();
		
		
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
									const ability:Ability = new Ability(statement);
									abilities.push(ability.m_id, ability);
								}
							});
				});
		}
		
		public static function getAbility(id:String):Ability
		{
			return abilities.at(id);
		}
		
		public static function exists(id:String):Boolean
		{
			return abilities.contains(id);
		}
		
		
		private static function parseType(source:String):uint
		{
			if (source == null) return ACTIVE;
			
			switch (source.toLowerCase())
			{
			case "active":
				return ACTIVE;
			case "on_summon":
				return ON_SUMMON;
			}
			return ACTIVE;
		}
		
		
		public static const ACTIVE:uint = 0, ON_SUMMON:uint = 1;
		private static var abilities:Map = new Map();
	}
}