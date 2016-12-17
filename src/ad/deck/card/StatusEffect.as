package ad.deck.card 
{
	import ad.file.StatementProcessor;
	import ad.expression.ParseTreeNode;
	import ad.map.HashMap;
	
	public class StatusEffect 
	{
		public function StatusEffect() {}
		
		
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
		
		
		private var m_id:String = null;
		private var m_name:String = "", m_description:String = "";
		private var m_duration:uint = 0;
		private var m_effects:HashMap = new HashMap();
		
		
		public static function loadResources(path:String):void
		{			
			var file:StatementProcessor = new StatementProcessor(path, function():void
				{
					if (file.getStatements()[0].getChildren()[0].getToken().text != "directories") return;
					
					for each (var dir:ParseTreeNode in file.getStatements()[0].getChildren()[1].getChildren())
						var definitions:StatementProcessor = new StatementProcessor(dir.getToken().text,
							function(statements:Vector.<ParseTreeNode>):void
							{
								for each (var statement:ParseTreeNode in statements)
								{
									const statusEffect:StatusEffect = new StatusEffect(statement);
									statusEffects.insert(statusEffect.m_id, statusEffect);
								}
							});
				});
		}
		
		public static function getEffect(id:String):StatusEffect
		{
			return statusEffects.at(id);
		}
		
		public static function exists(id:String):Boolean
		{
			return statusEffects.contains(id);
		}
		
		
		private static var statusEffects:HashMap = new HashMap();
	}
}