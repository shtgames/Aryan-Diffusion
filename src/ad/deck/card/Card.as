package ad.deck.card 
{
	import ad.deck.card.Ability;
	import ad.file.StatementProcessor;
	import ad.file.Statement;
	import ad.map.HashMap;
	
	public class Card
	{
		public function Card(source:Statement = null)
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
		
		public function get race():String
		{
			return m_race;
		}
		
		public function getAbilities(type:uint):Vector.<String>
		{
			switch (type)
			{
			case Ability.ACTIVE:
				return m_active;
			case Ability.PASSIVE:
				return m_passive;
			case Ability.ON_SUMMON:
				return m_onSummon;
			}
			return null;
		}
		
		public function hasAbility(id:String):Boolean
		{
			if (!Ability.exists(id)) return false;
			
			switch (type)
			{
			case Ability.ACTIVE:
				return m_active.indexOf(id) != -1;
			case Ability.PASSIVE:
				return m_passive.indexOf(id) != -1;
			case Ability.ON_SUMMON:
				return m_onSummon.indexOf(id) != -1;
			}
			
			return false;
		}
		
		public function get health():uint
		{
			return m_baseHealth;
		}
		
		public function get attack():uint
		{
			return m_baseAttack;
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
				case "race":
					m_race = statement.strings[0];
					break;
				case "type":
					m_type = parseType(statement.strings[0]);
					break;
				case "base":
					m_baseHealth = parseInt(statement.strings[0], 10);
					m_baseAttack = parseInt(statement.strings[1], 10);
					break;
				case "abilities":
					for (var ability:String in statement.strings)
						addAbility(ability);
					break;
				}
		}		
		
		private function addAbility(id:String):Card
		{
			if (!Ability.exists(id)) return this;
			
			switch (Ability.getAbility(id).type)
			{
			case Ability.ACTIVE:
				m_active.push(id);
			case Ability.PASSIVE:
				m_passive.push(id);
			case Ability.ON_SUMMON:
				m_onSummon.push(id);
			}
			
			return this;
		}
		
		
		private var m_id:String = null
		private var m_name:String = null, m_description:String = null;
		
		private var m_type:uint = CHARACTER;
		private var m_race:String = null;
		private var m_baseHealth:uint = 0, m_baseAttack:uint = 0;
		
		private var m_onSummon:Vector.<String> = new Vector.<String>(), m_passive:Vector.<String> = new Vector.<String>(), m_active:Vector.<String> = new Vector.<String>();
		
		
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
									const card:Card = new Card(statement);
									cards.insert(card.m_id.toString(), card);
								}
							});
				});
		}
		
		public static function getCard(id:String):Card
		{
			return cards.at(id);
		}
		
		public static function exists(id:String):Boolean
		{
			return cards.contains(id);
		}
		
		public static function isValidType(type:uint):Boolean
		{
			if (type == CHARACTER || type == SUPPORT || type == HABITAT) return true;
			return false;
		}
		
		
		private static function parseType(type:String):uint
		{
			switch (type.toLowerCase())
			{
			case "character":
				return CHARACTER;
			case "support":
				return SUPPORT;
			case "habitat":
				return HABITAT;
			}
			return CHARACTER;
		}		
		
		
		public static const CHARACTER:uint = 0, SUPPORT:uint = 1, HABITAT:uint = 2;
		private static var cards:HashMap = new HashMap();
	}
}