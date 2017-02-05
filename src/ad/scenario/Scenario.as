package ad.scenario 
{
	import ad.ai.AI;
	import ad.ai.Goal;
	import ad.ai.GoalType;
	import ad.scenario.card.card.CardState;
	import ad.scenario.card.card.Card;
	import ad.scenario.card.effect.Ability;
	import ad.scenario.card.effect.StatusEffect;
	import com.adobe.tvsdk.mediacore.events.TimeChangeEvent;
	
	import ad.scenario.field.Field;
	import ad.scenario.event.Event;
	import ad.scenario.event.EventType;
	import ad.scenario.event.EventDispatcher;
	
	import utils.expression.ParseNode;
	import ad.file.FileProcessor;
	import utils.map.Map;
	import flash.system.fscommand;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class Scenario
	{
		public function Scenario(source:ParseNode, directoryValue:String) 
		{
			if ((m_directory = directoryValue) == null)
				m_directory = "";
			init(source);
		}
		
		
		public function toString():String
		{
			return "<" + m_id + ">";
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
		
		
		public function endTurn(source:Object = null):void
		{
			if (m_field.swapCurrent() == m_field.first)
				m_turn++;
			EventDispatcher.pollEvent(new Event(EventType.TurnEvent, new Map()
				.push("player", m_field.current)
				.push("count", m_turn)));
			
			if (m_field.current == m_field.second)
				m_aiTimer.start();
			else m_aiTimer.stop();
		}
		
		public function load(onLoad:Function = null):void
		{
			if (m_definition == null || m_cardsDirectory == null || m_statusEffectsDirectory == null || m_abilitiesDirectory == null)
				return;
			
			m_turn = 0;
			m_field = new Field(this);
			m_ai = new AI(m_field.second);
			m_aiTimer.addEventListener(TimerEvent.TIMER, function (event:TimerEvent) : void
				{
					m_ai.nextMove();
				});
			
			StatusEffect.loadResources(m_statusEffectsDirectory, function ():void
				{
					Ability.loadResources(m_abilitiesDirectory, function ():void
					{
						Card.loadResources(m_cardsDirectory, function ():void
							{
								current = m_field.parent;
								
								for each (var card:String in m_definition["player_field"])
									m_field.first.addCardToBattlefield(Card.getCard(card));
								for each (var card:String in m_definition["player_hand"])
									m_field.first.hand.addCard(Card.getCard(card));
								for each (var card:String in m_definition["player_deck"])
									m_field.first.deck.addCard(Card.getCard(card));
								
								for each (var card:String in m_definition["ai_field"])
									m_field.second.addCardToBattlefield(Card.getCard(card));
								for each (var card:String in m_definition["ai_hand"])
									m_field.second.hand.addCard(Card.getCard(card));
								for each (var card:String in m_definition["ai_deck"])
									m_field.second.deck.addCard(Card.getCard(card));
								
								for each (var goal:Goal in m_definition["ai_goals"])
									m_ai.goals.push(goal);
								
								m_field.first.deck.shuffle();
								m_field.second.deck.shuffle();
								
								m_field.first.hand.setPlayableCardLimit(Card.CHARACTER, 1);
								m_field.first.hand.setPlayableCardLimit(Card.SUPPORT, 1);
								m_field.first.hand.setPlayableCardLimit(Card.HABITAT, 1);
								
								m_field.second.hand.setPlayableCardLimit(Card.CHARACTER, 1);
								m_field.second.hand.setPlayableCardLimit(Card.SUPPORT, 1);
								m_field.second.hand.setPlayableCardLimit(Card.HABITAT, 1);
								
								EventDispatcher.addListener(input);
								
								EventDispatcher.pollEvent(new Event(EventType.GameEvent, new Map()
									.push("loaded", true)));
								
								if (onLoad != null)
									onLoad();
							} );
					} );
				} );
		}
		
		
		private function input(event:Event):void
		{
			if (m_victoryCondition == null || m_field == null)
				return;
			
			m_field.input(event);
			
			const outcome:int = m_victoryCondition.call(this, event);
			if (outcome == -1)
				EventDispatcher.pollEvent(new Event(EventType.GameEvent, new Map()
					.push("defeat", true)));
			else if (outcome == 1)
				EventDispatcher.pollEvent(new Event(EventType.GameEvent, new Map()
					.push("victory", true)));
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
		private var m_ai:AI, m_aiTimer:Timer = new Timer(1000);
		
		
		
		public static function loadResources(path:String, onLoad:Function):void
		{
			loadScope();
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
		
		
		private static function loadScope():void
		{
			scope["Card"] = Card;
			scope["Ability"] = Ability;
			scope["StatusEffect"] = StatusEffect;
			scope["EventType"] = EventType;
			
			scope["trace"] = trace;
			scope["destroy"] = function (id:String) : Goal
				{
					return new Goal(GoalType.DestroyCard, new Map().push("id", id));
				};
		}
		
		
		private static const scope:Object = new Object();
		private static const scenarios:Map = new Map();
		public static var current:Scenario;
	}
}