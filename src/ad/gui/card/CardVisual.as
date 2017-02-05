package ad.gui.card 
{
	import ad.scenario.Scenario;
	import ad.scenario.card.Hand;
	import ad.scenario.card.card.Card;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	
	public class CardVisual extends MovieClip
	{
		public function CardVisual(card:Card, visible:Boolean, hand:HandVisual) 
		{
			m_hand = hand;
			m_card = card;
			
			m_background = new Sprite();
			m_background.graphics.lineStyle(1, 0x111111);
			m_background.graphics.beginFill(visible ? 0xdddccd : 0xbbaba0, 1);
			m_background.graphics.drawRect(0, 0, cardWidth, cardHeight);
			m_background.graphics.endFill();
			
			addChild(m_background);
			
			addEventListener(MouseEvent.MOUSE_OUT, mouseOut, true);
			addEventListener(MouseEvent.MOUSE_OVER, mouseOver, true);
			
			if (!(m_visible = visible))
				return;
			
			{
				const typeText:TextField = new TextField();
				switch (card.type)
				{
				case Card.CHARACTER:
					typeText.text = "Character";
					break;
				case Card.HABITAT:
					typeText.text = "Habitat";
					break;
				case Card.SUPPORT:
					typeText.text = "Support";
					break;
				}
				
				typeText.textColor = 0x777777;
				typeText.width = typeText.textWidth + 5;
				typeText.height = typeText.textHeight + 5;
				
				typeText.x = cardWidth - typeText.width - 5;
				addChild(typeText);
			}
			
			{
				const name:TextField = new TextField()
				name.text = card.name + " " + card.health + "/" + card.attack;
				name.wordWrap = true;
				name.width = cardWidth;
				name.height = name.textHeight + 5;
				name.textColor = 0x774444;
				
				name.x = (cardWidth - name.textWidth) / 2;
				name.y = cardHeight / 2 + 5 - name.height;
				
				addChild(name);
			}
			
			{
				const description:TextField = new TextField();
				description.width = cardWidth;
				description.wordWrap = true;
				description.text = card.description;
				
				description.height = cardHeight / 2 - 5;
				description.textColor = 0x444444;
				
				description.x = (cardWidth - description.textWidth) / 2;
				description.y = cardHeight - description.height;
				
				addChild(description);
			}
			
			addEventListener(MouseEvent.MOUSE_DOWN, startDragging, true);
			addEventListener(MouseEvent.MOUSE_UP, stopDragging, true);
		}
		
		public function get card():Card
		{
			return m_card;
		}
		
		private function startDragging(e:MouseEvent):void
		{
			m_dragX = x;
			m_dragY = y;
			
			startDrag();
		}
		
		private function stopDragging(e:MouseEvent):void
		{
			stopDrag();
			
			if (y + cardHeight + 10 < m_dragY && m_visible && Scenario.current != null)
				Scenario.current.field.first.hand.playCard(m_card);
			
			m_hand.reposition();
		}
		
		private function mouseOver(e:MouseEvent):void
		{
			m_background.graphics.beginFill(m_visible ? 0xfffddf : 0xccbcb1, 1);
			m_background.graphics.drawRect(0, 0, cardWidth, cardHeight);
			m_background.graphics.endFill();
		}
		
		private function mouseOut(e:MouseEvent):void
		{
			m_background.graphics.beginFill(m_visible ? 0xdddccd : 0xbbaba0, 1);
			m_background.graphics.drawRect(0, 0, cardWidth, cardHeight);
			m_background.graphics.endFill();
		}
		
		private var m_card:Card;
		private var m_hand:HandVisual;
		private var m_visible:Boolean;
		private var m_background:Sprite;
		private var m_dragX:uint, m_dragY:uint;
		
		public static const cardWidth:uint = 80, cardHeight:uint = 125;
	}
}