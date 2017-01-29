package ad.scenario.card.effect 
{
	import ad.expression.ParseNode;
	import ad.file.FileProcessor;
	import ad.map.Map;
	import ad.scenario.card.card.Card;
	import ad.scenario.card.card.CardState;
	
	public final class Ability
	{
		public function Ability(source:ParseNode) 
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
			m_effect = object["effect"];
		}
		
		
		private var m_id:String = null;
		private var m_name:String = "", m_description:String = "";
		private var m_effect:Function = null;
		
		
		public static function loadResources(path:String, onLoad:Function):void
		{
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
									abilities.push(statement.getChild(0).token.text, new Ability(statement));
								
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
		
		
		private static const scope:Object = new Object();
		{
			scope["Card"] = Card;
			scope["Ability"] = Ability;
			scope["StatusEffect"] = StatusEffect;
			
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
		}
		private static const abilities:Map = new Map();
	}
}