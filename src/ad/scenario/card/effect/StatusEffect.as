package ad.scenario.card.effect 
{
	import ad.scenario.event.Event;
	import ad.scenario.event.EventType;
	import ad.scenario.card.card.Card;
	
	import ad.file.FileProcessor;
	import ad.expression.ParseNode;
	import ad.map.Map;
	
	public class StatusEffect
	{
		public function StatusEffect(source:ParseNode) 
		{
			load(source);
		}
		
		
		public function toString():String
		{
			return m_id;
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
		
		public function get effect():Function
		{
			return m_effect;
		}
		
		
		private function load(source:ParseNode):void
		{
			var object:Object;
			if (source == null || (object = source.evaluate(scope)) == null)
				return;
			
			m_id = source.getChild(0).token.text;
			
			m_name = object["name"];
			m_description = object["description"];
			m_duration = object["duration"];
			
			m_instanceCap = object["instance_cap"];
			if (m_instanceCap == 0)
				m_instanceCap = 1;
			
			m_stackCap = object["stack_cap"];
			m_refreshable = object["refreshable"];
			
			m_effect = object["effect"];
		}
		
		
		private var m_id:String = null;
		private var m_name:String = "", m_description:String = "";
		private var m_duration:uint = 1, m_instanceCap:uint = 1, m_stackCap:uint = 1;
		private var m_refreshable:Boolean = true;
		private var m_effect:Function = null;
		
		
		public static function loadResources(path:String, onLoad:Function):void
		{
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
									statusEffects.push(statement.getChild(0).token.text, new StatusEffect(statement));
								
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
		
		
		private static const scope:Object = new Object();
		{
			scope["Card"] = Card;
			scope["Ability"] = Ability;
			scope["StatusEffect"] = StatusEffect;
			scope["EventType"] = EventType;
			
			scope["random"] = Math.random;
			scope["clamp"] = function (value:Number) : int
			{
				return value as int;
			}
			scope["outcome"] = function (percent:uint) : Boolean
				{
					if (Math.random() * 100 < percent)
						return true;
					return false;
				};
			scope["isAbility"] = function (object:Object) : Boolean
				{
					return object == null ? false : object instanceof AbilityInstance;
				};
			scope["isEffect"] = function (object:Object) : Boolean
				{
					return object == null ? false : object instanceof StatusEffectInstance;
				};
		}
		private static const statusEffects:Map = new Map();
	}
}