package ad.deck.effect 
{
	import ad.event.Event;
	
	import ad.file.FileProcessor;
	import ad.expression.ParseNode;
	import ad.map.Map;
	
	public class StatusEffect
	{
		public function StatusEffect(source:ParseNode = null) 
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
		
		
		public function input(parent:Object, event:Event):Object
		{
			if (m_effect == null || parent == null || event == null || !event.isValid())
				return null;
			return m_effect.call(null, new Array(parent, event));
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
			m_effect = object["effect"];
		}
		
		
		private var m_id:String = null;
		private var m_name:String = "", m_description:String = "";
		private var m_duration:uint = 0;
		private var m_effect:Function = null;
		
		
		public static function loadResources(path:String):void
		{
			const directoryFile:FileProcessor = new FileProcessor(path, function():void
				{
					for each (var definition:ParseNode in file.getStatements())
						var file:FileProcessor = new FileProcessor(definition.evaluate(),
							function(statements:Vector.<ParseNode>):void
							{
								for each (var statement:ParseNode in statements)
									statusEffects.push(statement.getChild(0).token.text, new StatusEffect(statement));
							} );
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
			
		}
		private static var statusEffects:Map = new Map();
	}
}