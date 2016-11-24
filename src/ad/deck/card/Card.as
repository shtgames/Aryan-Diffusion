package ad.deck.card 
{
	import ad.player.Player;
	import flash.display.MovieClip;
	
	import ad.deck.card.Ability;
	import ad.file.StatementProcessor;
	import ad.file.Statement;
	import ad.map.HashMap;
	
	public class Card extends MovieClip
	{
		public function Card(source:Statement = null)
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
		
		public function getRace():String
		{
			return m_race;
		}
		
		
		public function parent():Player
		{
			return m_parent;
		}
		
		public function parent(newParent:Player):Card
		{
			m_parent = newParent;
			return this;
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
				}
		}		
		
		private function addAbility(id:String):Card
		{
			if (!Ability.exists(id)) return this;
			
			switch (Ability.getAbility(id).getType())
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
		private var m_parent:Player = null;
		
		private var m_type:uint = CHARACTER;
		private var m_race:String = null;
		private var m_health:int = 0, m_baseHealth:uint = 0, m_attack:uint = 0, m_baseAttack:uint = 0;
		
		private var m_onSummon:Vector.<uint> = new Vector.<uint>(),
			m_passive:Vector.<uint> = new Vector.<uint>(), m_active:Vector.<uint> = new Vector.<uint>();
		
		
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