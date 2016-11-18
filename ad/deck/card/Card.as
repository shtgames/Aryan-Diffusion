package ad.deck.card 
{
	import flash.display.MovieClip;
	import ad.deck.card.Ability;
	import ad.file.StatementProcessor;
	import ad.file.Statement;
	
	public class Card extends MovieClip
	{		
		public static const ACTIVE:uint = 0, PASSIVE:uint = 1, ON_SUMMON:uint = 2;
		private static var cards:Object = new Object();
		
		
		public function Card() {}
		
		public function loadFromFile(path:String):void
		{
			var file:StatementProcessor = new StatementProcessor(path, function():void 
				{
					m_name = file.getStatements()[0].left;
					
					for each (var statement:Statement in file.getStatements()[0].statements)
						switch (statement.left)
						{
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
		
		
		public function addAbility(ability:Ability, type:uint):Card
		{
			switch (type)
			{
			case ACTIVE:
				m_active[ability.getName()] = ability;
			case PASSIVE:
				m_passive.push(ability);
			case ON_SUMMON:
				m_onSummon.push(ability);
			}
			
			return this;
		}
		
		
		private var m_background:MovieClip = null, m_portrait:MovieClip = null;
		
		private var m_name:String = null, m_description:String = null, m_race:String = null, m_type:String = null;
		private var m_health:int = 0, m_baseHealth:uint = 0, m_attack:uint = 0, m_baseAttack:uint = 0;
		
		private var m_onSummon:Vector.<Ability> = new Vector.<Ability>(),
			m_passive:Vector.<Ability> = new Vector.<Ability>(), m_active:Object = new Object();
	}
}