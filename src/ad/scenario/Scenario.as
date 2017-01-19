package ad.scenario 
{
	import ad.expression.ParseNode;
	import ad.file.FileProcessor;
	import ad.map.Map;
	
	public class Scenario 
	{
		public function Scenario(source:ParseNode) 
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
		
		
		private function load(source:ParseNode):void
		{
			var definition:Object;
			if (source == null || (definition = source.evaluate(scope)) == null)
				return;
			
			m_id = source.getChild(0).token.text;
			
			m_name = definition["name"];
			m_description = definition["description"];
		}
		
		
		private var m_id:String;
		private var m_name:String, m_description:String;
		
		
		public static function loadResources(path:String):void
		{
			const directoryFile:FileProcessor = new FileProcessor(path, function():void
				{
					for each (var definition:ParseNode in file.getStatements())
						var file:FileProcessor = new FileProcessor(definition.evaluate(),
							function(statements:Vector.<ParseNode>):void
							{
								for each (var statement:ParseNode in statements)
									scenarios.push(statement.getChild(0).token.text, new Scenario(statement));
							} );
				} );
		}
		
		public static function getScenario(id:String)
		{
			return scenarios.at(it);
		}
		
		public static function exists(id:String):Boolean
		{
			return scenarios.contains(id);
		}
		
		
		private static const scope:Object = new Object();
		{
			
		}
		private static const scenarios:Map = new Map();
	}
}