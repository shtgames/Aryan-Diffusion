package ad.deck.card 
{
	import flash.display.MovieClip;
	
	import ad.deck.card.Card;
	import ad.file.StatementProcessor;
	import ad.file.Statement;
	import ad.map.HashMap;
	
	public class Ability extends MovieClip
	{
		public function Ability(source:Statement = null) 
		{
			loadFromFile(source);
		}
		
		
		public function applyTo(target:Card, source:Card):void
		{
			
		}
		
		public function getName():String
		{
			return m_name;
		}
		
		public function getType():uint
		{
			return m_type;
		}
		
		private function loadFromFile(source:Statement):void
		{
			if (source == null) return;
		}
		
		
		private var m_id:String = null, m_type:uint = ACTIVE;
		private var m_name:String = new String(), m_description:String = new String();
		
		
		public static function loadResources(path:String):void
		{			
			var file:StatementProcessor = new StatementProcessor(path, function():void
				{
					if (file.getStatements()[0].left != "directories") return;
					
					for each (var dir:String in file.getStatements()[0].strings)
						var definitions:StatementProcessor = new StatementProcessor(dir, function(statements:Vector.<Statement>):void
							{
								for each (var statement:Statement in statements)
								{
									const ability:Ability = new Ability(statement);
									abilities.insert(ability.m_id, ability);
								}
							});
				});
		}
		
		public static function getAbility(id:String):Ability
		{
			return abilities.at(id);
		}
		
		public static function exists(id:String):Boolean
		{
			return abilities.contains(id);
		}
		
		
		public static const ACTIVE:uint = 0, PASSIVE:uint = 1, ON_SUMMON:uint = 2;
		private static var abilities:HashMap = new HashMap();
	}
}