package ad.gui.card 
{
	import ad.scenario.card.effect.StatusEffectInstance;
	import ad.scenario.event.Event;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class EffectVisual extends MovieClip
	{
		public function EffectVisual(effect:StatusEffectInstance, stage:Stage) 
		{
			m_effect = effect;
			
			{
				const background:Sprite = new Sprite();
				background.graphics.lineStyle(1, 0x111111);
				background.graphics.beginFill(0x779900, 1);
				background.graphics.drawRect(0, 0, 30, 30);
				background.graphics.endFill();
				
				addChild(background);
			}
			
			{
				m_duration = new TextField();
				m_duration.text = "" + (effect.duration == 0 ? "" : effect.duration);
				m_duration.textColor = 0xdddddd;
				
				m_duration.width = m_duration.textWidth + 5;
				m_duration.height = m_duration.textHeight + 5;
				m_duration.x = (background.width - m_duration.width) / 2;
				m_duration.y = (background.height - m_duration.height) / 2;
				
				addChild(m_duration);
			}
			
			{
				m_stacks = new TextField();
				m_stacks.text = "" + effect.stacks;
				m_stacks.textColor = 0xcccccc;
				
				m_stacks.width = m_stacks.textWidth + 5;
				m_stacks.height = m_stacks.textHeight + 5;
				m_stacks.x = background.width - m_stacks.width;
				m_stacks.y = background.height - m_stacks.height + 2;
				
				addChild(m_stacks);
			}
			
			{
				m_tooltip = new Sprite();
				
				const name:TextField = new TextField();
				name.text = effect.effect.name;
				name.textColor = 0xbbbbbb;
				
				name.width = name.textWidth + 10;
				name.height = name.textHeight + 5;
				
				m_tooltip.addChild(name);
				
				const cooldown:TextField = new TextField();
				cooldown.text = "Duration: " + effect.effect.duration + "\nStacks: " + effect.effect.stackCap;
				cooldown.textColor = 0x999999;
				
				cooldown.x = name.width + 10;
				cooldown.width = cooldown.textWidth + 10;
				cooldown.height = cooldown.textHeight + 5;
				
				m_tooltip.addChild(cooldown);
				
				const description:TextField = new TextField();
				description.text = effect.effect.description;
				description.textColor = 0xcccccc;
				description.wordWrap = true;
				
				description.y = cooldown.height > name.height ? cooldown.height : name.height;
				description.width = name.width + 10 + cooldown.width;
				description.height = description.textHeight + 5;
				
				m_tooltip.addChild(description);
				
				const tooltipBG:Sprite = new Sprite();
				tooltipBG.graphics.beginFill(0x151515, .75);
				tooltipBG.graphics.drawRect(0, 0, description.width, name.height + cooldown.height + description.height);
				tooltipBG.graphics.endFill();
				
				m_tooltip.addChildAt(tooltipBG, 0);
				
				m_tooltip.visible = false;
				
				stage.addChild(m_tooltip);
			}
			
			addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
		}
		
		
		public function get effect():StatusEffectInstance
		{
			return m_effect;
		}
		
		public function input(event:Event):void
		{
			if (event.data.at("effect") != m_effect)
				return;
			
			if (event.data.at("duration"))
				m_duration.text = "" + (m_effect.duration == 0 ? "" : m_effect.duration);
			else if (event.data.at("stacks"))
				m_stacks.text = "" + m_effect.stacks;
		}
		
		public function dispose():void
		{
			m_tooltip.parent.removeChild(m_tooltip);
		}
		
		
		private function mouseMove(event:MouseEvent):void
		{
			if (!m_tooltip.visible)
				return;
			
			m_tooltip.x = event.stageX + 16;
			m_tooltip.y = event.stageY + 16;
		}
		
		private function mouseOut(event:MouseEvent):void
		{
			m_tooltip.visible = false;
		}
		
		private function mouseOver(event:MouseEvent):void
		{
			m_tooltip.visible = true;
			m_tooltip.x = event.stageX + 16;
			m_tooltip.y = event.stageY + 16;
		}
		
		
		private var m_tooltip:Sprite, m_duration:TextField, m_stacks:TextField;
		private var m_effect:StatusEffectInstance;
	}
}