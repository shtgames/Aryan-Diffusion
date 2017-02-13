package ad.gui 
{
	import ad.gui.card.FieldVisual;
	import ad.gui.card.HandVisual;
	import ad.scenario.Scenario;
	import ad.scenario.card.card.Card;
	import ad.scenario.card.Hand;
	import ad.scenario.event.Event;
	import ad.scenario.event.EventType;
	import ad.scenario.event.EventDispatcher;
	import ad.scenario.player.Player;
	import utils.map.Map;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import flash.events.KeyboardEvent;
	
	public class UI extends MovieClip
	{
		public function UI(stage:Stage)
		{
			if ((m_stage = stage) == null)
				return;
			
			{
				const cardsInDeck:TextField = new TextField();
				addChild(cardsInDeck);
				elements.push("cardsInDeck", cardsInDeck);
				
				cardsInDeck.x = stage.stageWidth - 70;
				cardsInDeck.y = stage.stageHeight - 25;
				
				cardsInDeck.scaleX = 1.5;
				cardsInDeck.scaleY = 1.5;
				
				cardsInDeck.opaqueBackground = 0x88888855;
			}
			
			{
				const playableCardCount:TextField = new TextField();
				addChild(playableCardCount);
				elements.push("playableCardCount", playableCardCount);
				
				playableCardCount.width = stage.stageWidth / 20;
				playableCardCount.y = stage.stageHeight - 84;
				
				playableCardCount.scaleX = 2;
				playableCardCount.scaleY = 2;
				
				playableCardCount.opaqueBackground = 0x88888855;
			}
			
			{
				const endTurn:SimpleButton = new SimpleButton();
				addChild(endTurn);
				elements.push("endTurn", endTurn);
				
				var text:TextField = new TextField();
				text.text = "End Turn";
				text.textColor = 0xfffddc;
				text.width = text.textWidth + 10;
				text.height = text.textHeight * 1.2;
				text.x = (100 - text.width) / 2;
				text.y = (20 - text.height) / 2;
				
				{
					var text:TextField = new TextField();
					text.text = "End Turn";
					text.textColor = 0xffdddc;
					text.width = text.textWidth + 5;
					text.height = text.textHeight * 1.2;
					text.x = (100 - text.width) / 2;
					text.y = (20 - text.height) / 2;
					
					var bg:Sprite = new Sprite();
					bg.graphics.lineStyle(1, 0x111111);
					bg.graphics.beginFill(0x88888855, 1);
					bg.graphics.drawRect(0, 0, 100, 20);
					bg.graphics.endFill();
					bg.addChild(text);
					
					endTurn.upState = bg;
				}
				
				{
					var text:TextField = new TextField();
					text.text = "End Turn";
					text.textColor = 0xfffddc;
					text.width = text.textWidth + 5;
					text.height = text.textHeight * 1.2;
					text.x = (100 - text.textWidth) / 2;
					text.y = (20 - text.height) / 2;
					
					var bg:Sprite = new Sprite();
					bg.graphics.lineStyle(1, 0x111111);
					bg.graphics.beginFill(0x666633, 1);
					bg.graphics.drawRect(0, 0, 100, 20);
					bg.graphics.endFill();
					bg.addChild(text);
					
					endTurn.downState = bg;
				}
				
				{
					var text:TextField = new TextField();
					text.text = "End Turn";
					text.textColor = 0xfffddc;
					text.width = text.textWidth + 5;
					text.height = text.textHeight * 1.2;
					text.x = (100 - text.width) / 2;
					text.y = (20 - text.height) / 2;
					
					var bg:Sprite = new Sprite();
					bg.graphics.lineStyle(1, 0x111111);
					bg.graphics.beginFill(0xaaaa77, 1);
					bg.graphics.drawRect(0, 0, 100, 20);
					bg.graphics.endFill();
					bg.addChild(text);
					
					endTurn.hitTestState = endTurn.overState = bg;
				}
				
				endTurn.x = stage.stageWidth - endTurn.width;
				endTurn.y = (stage.stageHeight - endTurn.height) / 2;
			}
			
			{
				const field:FieldVisual = new FieldVisual(true, this);
				elements.push("field", field);
				addChild(field);
			}
			
			{
				const enemyField:FieldVisual = new FieldVisual(false, this);
				elements.push("enemyField", enemyField);
				addChild(enemyField);
			}
			
			{
				const enemyHand:HandVisual = new HandVisual(this, false);
				elements.push("enemyHand", enemyHand);
				addChild(enemyHand);
			}
			
			{
				const combatLog:TextField = new TextField();
				addChild(combatLog);
				elements.push("combatLog", combatLog);
				
				combatLog.textColor = 0xddddcc;
				combatLog.wordWrap = true;
				combatLog.width = stage.stageWidth / 2;
				combatLog.height = stage.stageHeight / 6;
				
				combatLog.background = true;
				combatLog.backgroundColor = 0x333333;
				combatLog.alpha = .8;
				
				combatLog.visible = false;
				
				stage.addEventListener(KeyboardEvent.KEY_DOWN, consoleCall, false, 1);
			}
			
			{
				const hand:HandVisual = new HandVisual(this, true);
				elements.push("hand", hand);
				addChild(hand);
			}
			
			{
				const turn:TextField = new TextField();
				turn.text = "Turn: 0";
				turn.textColor = 0x000000;
				turn.width = text.textWidth + 5;
				turn.height = text.textHeight * 1.2;
				turn.x = stage.stageWidth - turn.width - 20;
				
				elements.push("turn", turn);
				addChild(turn);
			}
			
			{
				const victory:TextField = new TextField();
				victory.visible = false;
				elements.push("victory", victory);
				addChild(victory);
			}
			
			EventDispatcher.addListener(input);
		}
		
		
		public function getField(player:Player):FieldVisual
		{
			if (player == elements.at("field").player)
				return elements.at("field");
			else if (player == elements.at("enemyField").player)
				return elements.at("enemyField");
			return null;
		}
		
		public function getStage():Stage
		{
			return m_stage;
		}
		
		public function input(event:Event):void
		{
			if (event.type == EventType.TurnEvent)
			{
				if (event.data.at("player") == Scenario.current.field.first)
				{
					elements.at("endTurn").mouseEnabled = true;
					
					var bg:Sprite = new Sprite();
					bg.graphics.lineStyle(1, 0x111111);
					bg.graphics.beginFill(0x88888855, 1);
					bg.graphics.drawRect(0, 0, 100, 20);
					bg.graphics.endFill();
					bg.addChild(elements.at("endTurn").upState.getChildAt(0));
					
					elements.at("endTurn").upState = bg;
				}
				else
				{
					elements.at("endTurn").mouseEnabled = false;
					
					var bg:Sprite = new Sprite();
					bg.graphics.lineStyle(1, 0x111111);
					bg.graphics.beginFill(0x555555, 1);
					bg.graphics.drawRect(0, 0, 100, 20);
					bg.graphics.endFill();
					bg.addChild(elements.at("endTurn").upState.getChildAt(0));
					
					elements.at("endTurn").upState = bg;
				}
				
				elements.at("turn").text = "Turn: " + event.data.at("count");
			}
			else if (event.type == EventType.DeckEvent)
			{
				if ((event.data.at("added") || event.data.at("removed")) && event.data.at("deck").parent == Scenario.current.field.first)
					elements.at("cardsInDeck").text = " Deck: " + event.data.at("deck").cardCount;
			}
			else if (event.type == EventType.HandEvent)
			{
				if (event.data.at("limit"))
				{
					if (event.data.at("hand").parent == Scenario.current.field.first)
					{
						const hand:Hand = event.data.at("hand");
						elements.at("playableCardCount").text = "C: " + hand.getPlayableCardLimit(Card.CHARACTER) + "\nS: " +
						hand.getPlayableCardLimit(Card.SUPPORT) + "\nH: " + hand.getPlayableCardLimit(Card.HABITAT);
					}
				}
				else
				{
					elements.at("hand").input(event);
					elements.at("enemyHand").input(event);
				}
			}
			else if (event.type == EventType.FieldEvent || event.type == EventType.CardEvent || event.type == EventType.AbilityEvent || event.type == EventType.StatusEffectEvent)
			{
				elements.at("field").input(event);
				elements.at("enemyField").input(event);
			}
			else if (event.type == EventType.GameEvent)
			{
				if (event.data.at("victory"))
				{
					elements.at("victory").text = "Victory!";
					elements.at("victory").scaleX = 3;
					elements.at("victory").scaleY = 3;
					elements.at("victory").width = elements.at("victory").textWidth + 5;
					elements.at("victory").height = elements.at("victory").textHeight + 5;
					elements.at("victory").x = (getStage().stageWidth - elements.at("victory").width) / 2;
					elements.at("victory").y = (getStage().stageHeight - elements.at("victory").height) / 2;
					elements.at("victory").textColor = 0x00cc00;
					elements.at("victory").visible = true;
				}
				else if (event.data.at("defeat"))
				{
					elements.at("victory").text = "Defeat!";
					elements.at("victory").scaleX = 3;
					elements.at("victory").scaleY = 3;
					elements.at("victory").width = elements.at("victory").textWidth + 5;
					elements.at("victory").height = elements.at("victory").textHeight + 5;
					elements.at("victory").x = (getStage().stageWidth - elements.at("victory").width) / 2;
					elements.at("victory").y = (getStage().stageHeight - elements.at("victory").height) / 2;
					elements.at("victory").textColor = 0xcc0000;
					elements.at("victory").visible = true;
				}
				else if (event.data.at("loaded"))
					elements.at("endTurn").addEventListener(MouseEvent.CLICK, Scenario.current.endTurn );
			}
			
			{
				const combatLog:TextField = elements.at("combatLog");
				combatLog.appendText((getTimer() / 1000).toPrecision(3) + " - " + event + "\n");
				combatLog.scrollV = combatLog.maxScrollV;
			}
		}
		
		public function cleanup():void
		{
			if (m_stage == null)
				return;
			m_stage.removeEventListener(KeyboardEvent.KEY_DOWN, consoleCall, false);
			m_stage.removeChild(this);
		}
		
		private function consoleCall(event:KeyboardEvent):void
		{
			if (event.keyCode == 192 && !event.shiftKey && !event.altKey && !event.ctrlKey)
				elements.at("combatLog").visible = !elements.at("combatLog").visible;
		}
		
		
		
		private const elements:Map = new Map();
		private var m_stage:Stage;
	}
}