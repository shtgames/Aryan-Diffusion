package ad.scenario.card.card 
{
	import ad.scenario.card.effect.Ability;
	import ad.scenario.card.effect.StatusEffect;
	import ad.scenario.event.Event;
	
	import ad.expression.ParseNode;
	import ad.file.FileProcessor;
	import ad.map.Map;
	
	public class Card
	{
		public function Card(source:ParseNode)
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
		
		public function get abilities():Vector.<Ability>
		{
			return m_abilities;
		}
		
		public function get passives():Vector.<StatusEffect>
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
		
		public function hasFlag(flag:uint):Boolean
		{
			return Boolean(m_flags & flag);
		}
		
		
		private function load(source:ParseNode):void
		{
			var definition:Object;
			if (source == null || (definition = source.evaluate(scope)) == null)
				return;
			
			m_id = source.getChild(0).token.text;
			
			m_name = definition["name"];
			m_description = definition["description"];
			m_race = definition["race"];
			if ((m_type = definition["type"]) == HABITAT)
				m_passives.push(new StatusEffect(source));
			
			m_baseHealth = definition["health"];
			m_baseAttack = definition["attack"];
			
			for each (var flag:uint in definition["flags"])
				m_flags |= flag;
			
			for each (var ability:String in definition["abilities"])
				if (Ability.exists(ability))
					m_abilities.push(Ability.getAbility(ability));
			for each (var passive:String in definition["passives"])
				if (StatusEffect.exists(passive))
					m_passives.push(StatusEffect.getEffect(passive));
		}
		
		
		private var m_id:String;
		private var m_name:String, m_description:String;
		private var m_race:String;
		private var m_type:uint = CHARACTER;
		private var m_baseHealth:uint = 0, m_baseAttack:uint = 0;
		private var m_flags:uint = 0;
		
		private var m_abilities:Vector.<Ability> = new Vector.<Ability>(), m_passives:Vector.<StatusEffect> = new Vector.<StatusEffect>();
		
		
		public static function loadResources(path:String, onLoad:Function):void
		{
			cards.clear();
			
			const directoryFile:FileProcessor = new FileProcessor(path, function():void
				{
					const directory:String = path.substring(0, path.lastIndexOf('/') + 1);
					var channels:uint = 0, running:Boolean = true;
					
					for each (var definition:ParseNode in directoryFile.getStatements())
					{
						channels++;
						const file:FileProcessor = new FileProcessor(directory + definition.evaluate(),
							function(statements:Vector.<ParseNode>):void
							{
								for each (var statement:ParseNode in statements)
									cards.push(statement.getChild(0).token.text, new Card(statement));
								
								if (--channels == 0 && !running && onLoad != null)
									--channels, onLoad();
							} );
					}
					running = false;
					
					if (channels == 0 && onLoad != null)
						onLoad();
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
			return type == CHARACTER || type == SUPPORT || type == HABITAT;
		}
		
		
		public static const CHARACTER:uint = 0, SUPPORT:uint = 1, HABITAT:uint = 2;
		public static const UNIQUE:uint = 1, INDESTRUCTIBLE:uint = 1 << 1;
		
		private static const scope:Object = new Object();
		{
			scope["Character"] = CHARACTER;
			scope["Support"] = SUPPORT;
			scope["Habitat"] = HABITAT;
			scope["Unique"] = UNIQUE;
			scope["Indestructible"] = INDESTRUCTIBLE;
		}
		private static const cards:Map = new Map();
	}
}