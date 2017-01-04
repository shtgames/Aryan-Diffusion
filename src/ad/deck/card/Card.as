package ad.deck.card 
{
	import ad.deck.card.Ability;
	
	import ad.expression.ParseNode;
	import ad.expression.TokenType;
	import ad.file.StatementProcessor;
	import ad.map.Map;
	
	public class Card
	{
		public function Card(source:ParseNode = null)
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
			case Ability.ON_DEATH:
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
			case Ability.ON_DEATH:
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
					case "race":
						m_race = statement.getChildren()[1].token.token.text;
						break;
					case "type":
						m_type = parseType(statement.getChildren()[1].token.token.text);
						break;
					case "health":
						m_baseAttack = parseInt(statement.getChildren()[1].token.token.text, 10);
						break;
					case "attack":
						m_baseHealth = parseInt(statement.getChildren()[1].token.token.text, 10);
						break;
					case "abilities":
						for each (var ability:ParseNode in statement.getChildren()[1].getChildren())
							addAbility(ability.token.token.text);
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
			case Ability.ON_DEATH:
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
					if (file.getStatements()[0].getChildren()[0].token.token.text != "directories") return;
					for each (var dir:ParseNode in file.getStatements()[0].getChildren()[1].getChildren())
						var definitions:StatementProcessor = new StatementProcessor(dir.token.token.text,
							function(statements:Vector.<ParseNode>):void
							{
								for each (var statement:ParseNode in statements)
								{
									const card:Card = new Card(statement);
									cards.push(card.m_id, card);
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
		private static var cards:Map = new Map();
	}
}