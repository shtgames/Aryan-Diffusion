package ad.scenario.card.card 
{
	import ad.ai.AI;
	import ad.ai.GoalType;
	import ad.scenario.card.effect.Ability;
	import ad.scenario.card.effect.StatusEffect;
	import ad.scenario.event.Event;
	
	import utils.expression.ParseNode;
	import ad.file.FileProcessor;
	import utils.map.Map;
	
	public class Card
	{
		public function Card(source:Object)
		{
			load(source);
		}
		
		
		public function toString():String
		{
			return "<" + m_id + ">";
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
		
		public function evaluationMethod():Function
		{
			return m_evaluation;
		}
		
		
		public function AIEvaluation(ai:AI):uint
		{
			return ai == null || ai.player.hand.getPlayableCardLimit(m_type) == 0 || m_evaluation == null ? 0 : m_evaluation.call(this, ai);
		}
		
		
		private function load(source:Object):void
		{
			if (source == null)
				return;
			
			m_id = source["id"];
			
			m_name = source["name"];
			m_description = source["description"];
			m_race = source["race"];
			m_type = source["type"];
			
			m_baseHealth = source["health"];
			if (m_baseHealth == 0)
				m_baseHealth = 1;
			
			m_baseAttack = source["attack"];
			
			for each (var flag:uint in source["flags"])
				m_flags |= flag;
			
			for each (var ability:String in source["abilities"])
				if (Ability.exists(ability))
					m_abilities.push(Ability.getAbility(ability));
			for each (var passive:String in source["passives"])
				if (StatusEffect.exists(passive))
					m_passives.push(StatusEffect.getEffect(passive));
			
			m_evaluation = source["ai_evaluation"];
		}
		
		
		private var m_id:String;
		private var m_name:String, m_description:String;
		private var m_race:String;
		private var m_type:uint = CHARACTER;
		private var m_baseHealth:uint, m_baseAttack:uint;
		private var m_flags:uint;
		private var m_evaluation:Function;
		
		private var m_abilities:Vector.<Ability> = new Vector.<Ability>(), m_passives:Vector.<StatusEffect> = new Vector.<StatusEffect>();
		
		
		public static function loadResources(path:String, onLoad:Function):void
		{
			loadScope();
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
								{
									const source:Object = statement.evaluate(scope);
									cards.push(source["id"] = statement.getChild(0).token.text, new Card(source));
								}
								
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
		
		
		private static function loadScope():void
		{
			scope["Character"] = CHARACTER;
			scope["Support"] = SUPPORT;
			scope["Habitat"] = HABITAT;
			scope["Unique"] = UNIQUE;
			scope["Indestructible"] = INDESTRUCTIBLE;
			
			scope["Card"] = Card;
			scope["Ability"] = Ability;
			scope["StatusEffect"] = StatusEffect;
			scope["GoalType"] = GoalType;
			
			scope["trace"] = trace;
			scope["clamp"] = function (value:Number) : int
				{
					return int(value);
				};
			scope["random"] = Math.random;
			scope["outcome"] = function (percent:uint) : Boolean
				{
					if (Math.random() * 100 < percent)
						return true;
					return false;
				};
			
			scope["vector"] = function () : Array
				{
					return new Array();
				};
		}
		
		
		private static const scope:Object = new Object();
		private static const cards:Map = new Map();
	}
}