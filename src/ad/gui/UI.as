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
	import ad.map.Map;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	public class UI extends MovieClip
	{
		public function UI(stage:Stage)
		{
			m_stage = stage;
			
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
				const field:FieldVisual = new FieldVisual(true, stage);
				elements.push("field", field);
				addChild(field);
			}
			
			{
				const enemyField:FieldVisual = new FieldVisual(false, stage);
				elements.push("enemyField", enemyField);
				addChild(enemyField);
			}
			
			{
				const enemyHand:HandVisual = new HandVisual(stage, false);
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
			}
			
			{
				const hand:HandVisual = new HandVisual(stage, true);
				elements.push("hand", hand);
				addChild(hand);
			}
			
			EventDispatcher.addListener(input);
		}
		
		
		public function input(event:Event):void
		{
			if (event.type.equals(EventType.TurnEvent))
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
			}
			else if (event.type.equals(EventType.DeckEvent))
			{
				if ((event.data.at("added") || event.data.at("removed")) && event.data.at("deck").parent == Scenario.current.field.first)
					elements.at("cardsInDeck").text = " Deck: " + event.data.at("deck").cardCount;
			}
			else if (event.type.equals(EventType.HandEvent))
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
			else if (event.type.equals(EventType.FieldEvent) || event.type.equals(EventType.CardEvent) || event.type.equals(EventType.AbilityEvent) || event.type.equals(EventType.StatusEffectEvent))
			{
				elements.at("field").input(event);
				elements.at("enemyField").input(event);
			}
			else if (event.type.equals(EventType.GameEvent))
			{
				if (event.data.at("loaded"))
					elements.at("endTurn").addEventListener(MouseEvent.CLICK, Scenario.current.endTurn );
			}
			
			{
				const combatLog:TextField = elements.at("combatLog");
				combatLog.appendText((getTimer() / 1000).toPrecision(3) + " - " + event + "\n");
				combatLog.scrollV = combatLog.maxScrollV;
			}
		}
		
		
		private const elements:Map = new Map();
		private var m_stage:Stage;
	}
}