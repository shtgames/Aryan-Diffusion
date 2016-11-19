package ad.deck.card 
{
	import flash.display.MovieClip;
	
	import ad.deck.card.Ability;
	import ad.file.StatementProcessor;
	import ad.file.Statement;
	import ad.map.HashMap;
	
	public class Card extends MovieClip
	{		
		public function Card(path:String = null)
		{
			if (path != null) loadFromFile(path);
		}
		
		
		public function getName():String
		{
			return m_name;
		}
		
		
		private function loadFromFile(path:String):void
		{
			if (path == null) return;
			
			var file:StatementProcessor = new StatementProcessor(path, function():void 
				{
					m_id = parseInt(file.getStatements()[0].left, 10);
					
					for each (var statement:Statement in file.getStatements()[0].statements)
						switch (statement.left)
						{
						case "name":
							m_name = statement.strings[0];
							break;
						case "description":
							m_description = statement.strings[0];
							break;
						case "race":
							m_race = statement.strings[0];
							break;
						case "type":
							m_type = statement.strings[0];
							break;
						case "base":
							m_baseHealth = statement.strings[0];
							m_baseAttack = statement.strings[1];
							break;
						}
				});
		}		
		
		private function addAbility(ability:Ability, type:uint):Card
		{
			switch (type)
			{
			case Ability.ACTIVE:
				m_active[ability.getName()] = ability;
			case Ability.PASSIVE:
				m_passive.push(ability);
			case Ability.ON_SUMMON:
				m_onSummon.push(ability);
			}
			
			return this;
		}
		
		
		private var m_background:MovieClip = null, m_portrait:MovieClip = null;
		
		private var m_name:String = null, m_description:String = null, m_race:String = null, m_type:String = null;
		private var m_health:int = 0, m_baseHealth:uint = 0, m_attack:uint = 0, m_baseAttack:uint = 0;
		private var m_id:uint = 0;
		
		private var m_onSummon:Vector.<Ability> = new Vector.<Ability>(),
			m_passive:Vector.<Ability> = new Vector.<Ability>(), m_active:Object = new Object();
		
		
		public static function loadResources(path:String):void
		{			
			var file:StatementProcessor = new StatementProcessor(path, function():void
				{
					if (file.getStatements()[0].left != "directories") return;
					
					for each (var dir:String in file.getStatements()[0].strings)
					{
						const card:Card = new Card(dir);
						cards.insert(card.m_id, card);
					}
				});
		}
		
		private static var cards:HashMap = new HashMap();
	}
}