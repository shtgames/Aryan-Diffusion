package ad.scenario 
{
	import ad.scenario.card.card.CardState;
	import ad.scenario.card.card.Card;
	import ad.scenario.card.effect.Ability;
	import ad.scenario.card.effect.StatusEffect;
	
	import ad.scenario.field.Field;
	import ad.scenario.event.Event;
	import ad.scenario.event.EventListener;
	
	import ad.expression.ParseNode;
	import ad.file.FileProcessor;
	import ad.map.Map;
	
	public class Scenario extends EventListener
	{
		public function Scenario(source:ParseNode, directoryValue:String) 
		{
			if ((m_directory = directoryValue) == null)
				m_directory = "";
			init(source);
		}
		
		
		public function get id():String
		{
			return m_id;
		}
		
		public function get directory():String
		{
			return m_directory;
		}
		
		public function get name():String
		{
			return m_name;
		}
		
		public function get description():String
		{
			return m_description;
		}
		
		public function get field():Field
		{
			return m_field;
		}
		
		
		override public function input(event:Event):void
		{
			if (m_victoryCondition == null || event == null || !event.isValid())
				return;
			
			const outcome:int = m_victoryCondition.call(null, new Array(event));
			if (outcome == -1) // Defeat
			{
				
			}
			else if (outcome == 1) // Victory
			{
				
			}
		}
		
		
		public function load(onLoad:Function):void
		{
			if (m_definition == null || m_cardsDirectory == null || m_statusEffectsDirectory == null || m_abilitiesDirectory == null)
				return;
			
			m_turn = 0;
			m_field = new Field(this);
			
			StatusEffect.loadResources(m_statusEffectsDirectory, function ():void
				{
					Ability.loadResources(m_abilitiesDirectory, function ():void
					{
						Card.loadResources(m_cardsDirectory, function ():void
							{
								for each (var card:String in m_definition["player_field"])
									if (Card.exists(card))
										m_field.first.addCardToBattlefield(new CardState(Card.getCard(card), m_field.first));
								for each (var card:String in m_definition["player_deck"])
									if (Card.exists(card))
										m_field.first.deck.addCard(card);
								
								for each (var card:String in m_definition["ai_field"])
									if (Card.exists(card))
										m_field.second.addCardToBattlefield(new CardState(Card.getCard(card), m_field.second));
								for each (var card:String in m_definition["ai_deck"])
									if (Card.exists(card))
										m_field.second.deck.addCard(card);
								
								m_field.first.deck.shuffle();
								m_field.second.deck.shuffle();
								
								if (onLoad != null)
									onLoad();
							} );
					} );
				} );
		}
		
		
		private function init(source:ParseNode):void
		{
			if (source == null || (m_definition = source.evaluate(scope)) == null)
				return;
			
			m_id = source.getChild(0).token.text;
			
			m_name = m_definition["name"];
			m_description = m_definition["description"];
			
			m_cardsDirectory = m_directory + m_definition["cards"];
			m_statusEffectsDirectory = m_directory + m_definition["status_effects"];
			m_abilitiesDirectory = m_directory + m_definition["abilities"];
			
			m_victoryCondition = m_definition["victory_condition"];
		}
		
		
		private var m_id:String;
		private var m_directory:String, m_cardsDirectory:String, m_abilitiesDirectory:String, m_statusEffectsDirectory:String;
		private var m_definition:Object;
		
		private var m_name:String, m_description:String;
		private var m_victoryCondition:Function;
		private var m_turn:uint;
		private var m_field:Field;
		
		
		
		public static function loadResources(path:String, onLoad:Function):void
		{
			scenarios.clear();
			
			const directoryFile:FileProcessor = new FileProcessor(path, function():void
				{
					const directory:String = path.substring(0, path.lastIndexOf('/') + 1);
					var subdirectory:String;
					var channels:uint = 0, running:Boolean = true;
					
					for each (var definition:ParseNode in directoryFile.getStatements())
					{
						channels++;
						var file:FileProcessor = new FileProcessor(subdirectory = directory + definition.evaluate(),
							function(statements:Vector.<ParseNode>):void
							{
								for each (var statement:ParseNode in statements)
									scenarios.push(statement.getChild(0).token.text, new Scenario(statement, subdirectory.substring(0, subdirectory.lastIndexOf('/') + 1)));
								
								if (--channels == 0 && !running && onLoad != null)
									--channels, onLoad();
							} );
					}
					running = false;
					
					if (channels == 0 && onLoad != null)
						onLoad();
				} );
		}
		
		public static function getScenario(id:String):Scenario
		{
			return scenarios.at(id);
		}
		
		public static function exists(id:String):Boolean
		{
			return scenarios.contains(id);
		}
		
		
		private static const scope:Object = new Object();
		private static const scenarios:Map = new Map();
	}
}