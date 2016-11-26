package ad.deck.card 
{
	import ad.deck.card.Card;
	import ad.deck.card.Condition;
	import ad.deck.card.Effect;
	import ad.file.StatementProcessor;
	import ad.file.Statement;
	import ad.map.HashMap;
	
	public class Ability
	{
		public function Ability(source:Statement = null) 
		{
			loadFromFile(source);
		}
		
		
		public function get ID():String
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
			if (target == null || source == null ||
				(m_sourceCondition != null && !m_sourceCondition.isFulfilled(source)))
					return false;
			
			for each (var condition:Condition in m_targetConditions)
				if (condition.isFulfilled(target)) return true;
			
			return false;
		}
		
		public function applyTo(target:CardState, source:CardState):Boolean
		{
			if (target == null || source == null ||
				(m_sourceCondition != null && !m_sourceCondition.isFulfilled(source)))
				return false;
			
			var returnValue:Boolean = false;
			for (var i:uint = 0; i != m_targetConditions.length; ++i)
				if (m_targetConditions[i].isFulfilled(target))
				{
					m_targetEffects[i].applyTo(target, source);
					returnValue = true;
				}
			
			return returnValue;
		}
		
		
		private function loadFromFile(source:Statement):void
		{
			if (source == null) return;
			
			m_id = source.left;
			
			for each (var statement:Statement in source.statements)
				switch (statement.left.toLowerCase())
				{
				case "name":
					m_name = statement.strings[0];
					break;
				case "description":
					m_description = statement.strings[0];
					break;
				case "type":
					m_type = parseType(statement.strings[0]);
					break;
				case "source_condition":
					m_sourceCondition = new Condition(statement);
					break;
				case "target":
					for each (var tarCase:Statement in statement.statements)
						for each (var tarStatement:Statement in tarCase.statements)
							switch (tarStatement.left.toLowerCase())
							{
							case "condition":
								m_targetConditions.push(new Condition(tarStatement));
								break;
							case "effect":
								m_targetEffects.push(new Effect(tarStatement));
								break;
							}
					
					if (m_targetConditions.length != m_targetEffects.length) 
					{
						trace("Logic error in definition of Ability(ID: " + m_id + ", Name: " + m_name + "):\n" +
							"Inequal amounts of target Conditions and corresponding Effects - will remove excess items.");
						
						while (m_targetConditions.length > m_targetEffects.length) m_targetConditions.pop();
						while (m_targetConditions.length < m_targetEffects.length) m_targetEffects.pop();
					}
					
					break;
				}
		}
		
		
		private var m_id:String = null;
		private var m_name:String = "", m_description:String = "";
		private var m_type:uint = ACTIVE;
		private var m_sourceCondition:Condition = null;
		private var m_targetConditions:Vector.<Condition> = new Vector.<Condition>(), m_targetEffects:Vector.<Effect> = new Vector.<Effect>();
		
		
		public static function loadResources(path:String):void
		{			
			var file:StatementProcessor = new StatementProcessor(path, function():void
				{
					if (file.getStatements()[0].left != "directories") return;
					
					for each (var dir:String in file.getStatements()[0].strings)
						var definitions:StatementProcessor = new StatementProcessor(dir, function(statements:Vector.<Statement>):void
							{
								for each (var statement:Statement in statements)
								{
									const ability:Ability = new Ability(statement);
									abilities.insert(ability.m_id, ability);
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
		private static var abilities:HashMap = new HashMap();
	}
}