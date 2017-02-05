package ad.scenario.card.effect 
{
	import ad.ai.AI;
	import ad.ai.GoalType;
	import ad.ai.TargetScore;
	import ad.scenario.card.card.Card;
	import ad.scenario.card.card.CardState;
	
	import utils.expression.ParseNode;
	import ad.file.FileProcessor;
	import utils.map.Map;
	
	public final class Ability
	{
		public function Ability(source:Object) 
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
		
		public function get targets():uint
		{
			return m_targets;
		}
		
		public function get harmful():Boolean
		{
			return m_harmful;
		}
		
		public function get cooldown():uint
		{
			return m_cooldown;
		}
		
		public function get charges():uint
		{
			return m_charges;
		}
		
		public function get effect():Function
		{
			return m_effect;
		}
		
		public function AIEvaluation(ability:AbilityInstance, ai:AI, target:CardState):TargetScore
		{
			const returnValue:TargetScore = m_evaluation == null ? null : new TargetScore(m_evaluation.call(ability, ai, target), target);
			return returnValue == null ? new TargetScore() : returnValue;
		}
		
		
		private function load(source:Object):void
		{
			if (source == null)
				return;
			
			m_id = source["id"];
			
			m_name = source["name"];
			m_description = source["description"];
			m_targets = source["targets"];
			m_harmful = source["harmful"];
			
			source.hasOwnProperty("cooldown") ? m_cooldown = source["cooldown"] : m_cooldown = 1;
			m_charges = source["charges"];
			if (m_charges == 0)
				m_charges = 1;
			
			m_effect = source["effect"];
			m_evaluation = source["ai_evaluation"];
		}
		
		
		private var m_id:String;
		private var m_name:String, m_description:String;
		private var m_cooldown:uint, m_charges:uint, m_targets:uint;
		private var m_harmful:Boolean;
		private var m_effect:Function;
		private var m_evaluation:Function;
		
		
		public static function loadResources(path:String, onLoad:Function):void
		{
			loadScope();
			abilities.clear();
			
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
									abilities.push(source["id"] = statement.getChild(0).token.text, new Ability(source));
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
		
		public static function getAbility(id:String):Ability
		{
			return abilities.at(id);
		}
		
		public static function exists(id:String):Boolean
		{
			return abilities.contains(id);
		}
		
		private static function loadScope():void
		{
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
		private static const abilities:Map = new Map();
	}
}