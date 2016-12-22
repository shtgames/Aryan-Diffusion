package ad.deck.card 
{
	import ad.deck.card.Card;
	import ad.deck.card.Condition;
	import ad.deck.card.DynamicEffect;	
	import ad.expression.ParseTreeNode;
	import ad.expression.TokenType;	
	import ad.file.StatementProcessor;
	import ad.map.Map;
	
	public final class Ability
	{
		public function Ability(source:ParseTreeNode = null) 
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
		
		
		public function canApply(target:CardState, source:CardState):Boolean
		{
			if (target == null || source == null)
					return false;
			
			var returnValue:Boolean = false;
			for each (var condition:Condition in m_sourceConditions)
				if (condition.isFulfilled(target))
				{
					returnValue = true;
					break;
				}
			if (!returnValue) return false;
			
			for each (var condition:Condition in m_targetConditions)
				if (condition.isFulfilled(target)) return true;
			
			return false;
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
					case "type":
						m_type = parseType(statement.getChildren()[1].getToken().text);
						break;
					case "source":
						for each (var currentCase:ParseTreeNode in statement.getChildren()[1].getChildren())
						{
							var condition:Condition = null;
							var effect:DynamicEffect = null;
							for each (var currentStatement:ParseTreeNode in currentCase.getChildren()[1].getChildren())
								switch (currentStatement.getChildren()[0].getToken().text.toLowerCase())
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
						for each (var currentCase:ParseTreeNode in statement.getChildren()[1].getChildren())
						{
							var condition:Condition = null;
							var effect:DynamicEffect = null;
							for each (var currentStatement:ParseTreeNode in currentCase.getChildren()[1].getChildren())
								switch (currentStatement.getChildren()[0].getToken().text.toLowerCase())
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
					if (file.getStatements()[0].getChildren()[0].getToken().text != "directories") return;
					
					for each (var dir:ParseTreeNode in file.getStatements()[0].getChildren()[1].getChildren())
						var definitions:StatementProcessor = new StatementProcessor(dir.getToken().text,
							function(statements:Vector.<ParseTreeNode>):void
							{
								for each (var statement:ParseTreeNode in statements)
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
			case "passive":
				return PASSIVE;
			case "on_summon":
				return ON_SUMMON;
			}
			return ACTIVE;
		}
		
		
		public static const ACTIVE:uint = 0, PASSIVE:uint = 1, ON_SUMMON:uint = 2;
		private static var abilities:Map = new Map();
	}
}