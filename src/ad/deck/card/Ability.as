package ad.deck.card 
{
	import ad.expression.ParseNode;
	import ad.file.FileProcessor;
	import ad.map.Map;
	
	public final class Ability
	{
		public function Ability(source:ParseNode = null) 
		{
			load(source);
		}
		
		public function toString():String
		{
			return m_name;
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
		
		
		public function applyTo(source:CardState, target:CardState):Object
		{
			if (m_effect == null)
				return null;
			return m_effect.call(null, new Array(source, target));
		}
		
		
		private function load(source:ParseNode):void
		{
			var object:Object;
			if (source == null || (object = source.evaluate(/**/)) == null)
				return;
			
			m_id = source.getChild(0).token.text;
			
			m_name = object["name"];
			m_description = object["description"];
			m_effect = object["effect"];
		}
		
		
		private var m_id:String = null;
		private var m_name:String = "", m_description:String = "";
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
									abilities.push(statement.getChild(0).token.text, new Ability(statement));
							} );
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
		
		
		private static var abilities:Map = new Map();
	}
}