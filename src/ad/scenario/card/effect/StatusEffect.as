package ad.scenario.card.effect 
{
	import ad.scenario.card.Deck;
	import ad.scenario.card.Hand;
	import ad.scenario.player.Player;
	import ad.scenario.event.Event;
	import ad.scenario.event.EventType;
	import ad.scenario.card.card.Card;
	
	import ad.file.FileProcessor;
	import utils.expression.ParseNode;
	import utils.map.Map;
	
	public class StatusEffect
	{
		public function StatusEffect(source:Object) 
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
		
		public function get duration():uint
		{
			return m_duration;
		}
		
		public function get instanceCap():uint
		{
			return m_instanceCap;
		}
		
		public function get stackCap():uint
		{
			return m_stackCap;
		}
		
		public function get refreshable():Boolean
		{
			return m_refreshable;
		}
		
		public function get harmful():Boolean
		{
			return m_harmful;
		}
		
		public function get effect():Function
		{
			return m_effect;
		}
		
		
		private function load(source:Object):void
		{
			if (source == null)
				return;
			
			m_id = source["id"];
			
			m_name = source["name"];
			m_description = source["description"];
			m_duration = source["duration"];
			
			m_instanceCap = source["instance_cap"];
			if (m_instanceCap == 0)
				m_instanceCap = 1;
			
			m_stackCap = source["stack_cap"];
			m_refreshable = source["refreshable"];
			
			m_harmful = source["harmful"];
			m_effect = source["effect"];
		}
		
		
		private var m_id:String;
		private var m_name:String, m_description:String;
		private var m_duration:uint = 1, m_instanceCap:uint = 1, m_stackCap:uint = 1;
		private var m_refreshable:Boolean = true, m_harmful:Boolean;
		private var m_effect:Function;
		
		
		public static function loadResources(path:String, onLoad:Function):void
		{
			loadScope();
			statusEffects.clear();
			
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
									statusEffects.push(source["id"] = statement.getChild(0).token.text, new StatusEffect(source));
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
		
		public static function getEffect(id:String):StatusEffect
		{
			return statusEffects.at(id);
		}
		
		public static function exists(id:String):Boolean
		{
			return statusEffects.contains(id);
		}
		
		private static function loadScope():void
		{
			scope["Card"] = Card;
			scope["Ability"] = Ability;
			scope["StatusEffect"] = StatusEffect;
			scope["EventType"] = EventType;
			
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
			
			scope["composeEffect"] = function (id:String, name:String, description:String, effect:Function, duration:uint = 1) : StatusEffect
				{
					const source:Object = new Object();
					source["id"] = id;
					source["name"] = name;
					source["description"] = description;
					source["effect"] = effect;
					source["duration"] = duration;
					
					return new StatusEffect(source);
				};
			scope["vector"] = function () : Array
				{
					return new Array();
				};
			
			scope["isAbility"] = function (object:Object) : Boolean
				{
					return object == null ? false : object is AbilityInstance;
				};
			scope["isEffect"] = function (object:Object) : Boolean
				{
					return object == null ? false : object is StatusEffectInstance;
				};
			scope["isDeck"] = function (object:Object) : Boolean
				{
					return object == null ? false : object is Deck;
				};
			scope["isHand"] = function (object:Object) : Boolean
				{
					return object == null ? false : object is Hand;
				};
			scope["isPlayer"] = function (object:Object) : Boolean
				{
					return object == null ? false : object is Player;
				};
		}
		
		
		private static const scope:Object = new Object();
		private static const statusEffects:Map = new Map();
	}
}