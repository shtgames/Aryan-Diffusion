package ad.deck.card 
{
	import flash.display.MovieClip;
	
	import ad.deck.card.Card;
	import ad.deck.card.Condition;
	import ad.deck.card.Effect;
	import ad.file.StatementProcessor;
	import ad.file.Statement;
	import ad.map.HashMap;
	
	public class Ability extends MovieClip
	{
		public function Ability(source:Statement = null) 
		{
			loadFromFile(source);
		}
		
		
		public function getID():String
		{
			return m_id;
		}
		
		public function getName():String
		{
			return m_name;
		}
		
		public function getDescription():String
		{
			return m_description;
		}
		
		public function getType():uint
		{
			return m_type;
		}
		
		
		public function canApply(target:Card, source:Card):Boolean
		{			
			if (target == null || source == null || m_effect == null ||
				(m_sourceCondition != null && !m_sourceCondition.isFulfilled(source)) ||
				(m_targetCondition != null && !m_targetCondition.isFulfilled(target))) return false;
			return true;
		}
		
		public function applyTo(target:Card, source:Card):Boolean
		{
			if (!canApply(target, source)) return false;
			m_effect.applyTo(target, source);
			return true;
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
				case "target_condition":
					m_targetCondition = new Condition(statement);
					break;
				case "effect":
					m_effect = new Effect(statement);
					break;
				}
		}
		
		
		private var m_id:String = null;
		private var m_name:String = "", m_description:String = "";
		private var m_type:uint = ACTIVE;
		private var m_sourceCondition:Condition = null, m_targetCondition:Condition = null;
		private var m_effect:Effect = null;
		
		
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