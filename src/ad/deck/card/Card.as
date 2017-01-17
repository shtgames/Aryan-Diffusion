package ad.deck.card 
{
	import ad.deck.card.Ability;
	import ad.deck.effect.StatusEffect;
	
	import ad.expression.ParseNode;
	import ad.file.FileProcessor;
	import ad.map.Map;
	
	public class Card
	{
		public function Card(source:ParseNode = null)
		{
			load(source);
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
		
		public function get health():uint
		{
			return m_baseHealth;
		}
		
		public function get attack():uint
		{
			return m_baseAttack;
		}
		
		public function get abilities():Vector.<String>
		{
			return m_abilities;
		}
		
		public function get passives():Vector.<String>
		{
			return m_passives;
		}
		
		public function hasAbility(id:String):Boolean
		{
			if (!Ability.exists(id) || m_abilities.indexOf(id) == -1) return false;
			return true;
		}
		
		public function hasPassive(id:String):Boolean
		{
			if (!StatusEffect.exists(id) || m_passives.indexOf(id) == -1) return false;
			return true;
		}
		
		
		private function load(source:ParseNode):void
		{
			var object:Object;
			if (source == null || (object = source.evaluate(/**/)) == null)
				return;
			
			m_id = source.getChild(0).token.text;
			
			m_name = object["name"];
			m_description = object["description"];
			m_race = object["race"];
			m_type = parseType(object["type"]);
			m_baseHealth = object["health"];
			m_baseAttack = object["attack"];
			for each (var ability:String in object["abilities"])
				m_abilities.push(ability);
			for each (var passive:String in object["passives"])
				m_passives.push(passive);
		}
		
		
		private var m_id:String = null
		private var m_name:String = null, m_description:String = null;
		
		private var m_type:uint = CHARACTER;
		private var m_race:String = null;
		private var m_baseHealth:uint = 0, m_baseAttack:uint = 0;
		
		private var m_abilities:Vector.<String> = new Vector.<String>(), m_passives:Vector.<String> = new Vector.<String>();
		
		
		public static function loadResources(path:String):void
		{
			const directoryFile:FileProcessor = new FileProcessor(path, function():void
				{
					for each (var definition:ParseNode in file.getStatements())
						var file:FileProcessor = new FileProcessor(definition.evaluate(),
							function(statements:Vector.<ParseNode>):void
							{
								for each (var statement:ParseNode in statements)
									cards.push(statement.getChild(0).token.text, new Card(statement));
							} );
				} );
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
			if (type == null) return CHARACTER;
			
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