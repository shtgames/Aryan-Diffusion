package ad.gui.card 
{
	import ad.scenario.Scenario;
	import ad.scenario.card.effect.AbilityInstance;
	import ad.scenario.event.Event;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class AbilityVisual extends MovieClip
	{
		public function AbilityVisual(ability:AbilityInstance, stage:Stage) 
		{
			m_ability = ability;
			m_stage = stage;
			
			{
				m_background = new Sprite();
				m_background.graphics.lineStyle(1, 0x111111);
				m_background.graphics.beginFill(0xaa8811, 1);
				m_background.graphics.drawRect(0, 0, 30, 30);
				m_background.graphics.endFill();
				
				addChild(m_background);
			}
			
			{
				m_cooldown = new TextField();
				m_cooldown.text = "" + (ability.cooldown == 0 ? "" : ability.cooldown);
				m_cooldown.textColor = 0xdddddd;
				
				m_cooldown.width = m_cooldown.textWidth + 5;
				m_cooldown.height = m_cooldown.textHeight + 5;
				m_cooldown.x = (m_background.width - m_cooldown.width) / 2;
				m_cooldown.y = (m_background.height - m_cooldown.height) / 2;
				
				addChild(m_cooldown);
			}
			
			{
				m_charges = new TextField();
				m_charges.text = "" + ability.charges;
				m_charges.textColor = 0xcccccc;
				
				m_charges.width = m_charges.textWidth + 5;
				m_charges.height = m_charges.textHeight + 5;
				m_charges.x = m_background.width - m_charges.width;
				m_charges.y = m_background.height - m_charges.height + 2;
				
				addChild(m_charges);
			}
			
			{
				m_tooltip = new Sprite();
				
				const name:TextField = new TextField();
				name.text = ability.ability.name;
				name.textColor = 0xbbbbbb;
				
				name.width = name.textWidth + 10;
				name.height = name.textHeight + 5;
				
				m_tooltip.addChild(name);
				
				const cooldown:TextField = new TextField();
				cooldown.text = "Cooldown: " + ability.ability.cooldown + "\nCharges: " + ability.ability.charges;
				cooldown.textColor = 0x999999;
				
				cooldown.x = name.width + 10;
				cooldown.width = cooldown.textWidth + 10;
				cooldown.height = cooldown.textHeight + 5;
				
				m_tooltip.addChild(cooldown);
				
				const description:TextField = new TextField();
				description.text = ability.ability.description;
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
			
			addEventListener(MouseEvent.CLICK, mouseClick);
			addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
		}
		
		
		public function get ability():AbilityInstance
		{
			return m_ability;
		}
		
		public function input(event:Event):void
		{
			if (event.data.at("ability") != ability)
				return;
			
			if (event.data.at("cooldown"))
				m_cooldown.text = "" + (m_ability.cooldown == 0 ? "" : m_ability.cooldown);
			else if (event.data.at("charges"))
				m_charges.text = "" + m_ability.charges;
		}
		
		public function dispose():void
		{
			m_tooltip.parent.removeChild(m_tooltip);
		}
		
		
		private function mouseClick(event:MouseEvent):void
		{
			if (m_ability.parent.parent != Scenario.current.field.first)
				return;
			
			if (m_ability.ability.targets == 0)
				m_ability.useOn(null);
			else new TargetingReticule(m_ability, m_stage);
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
			m_background.graphics.clear();
			m_background.graphics.lineStyle(1, 0x111111);
			m_background.graphics.beginFill(0xaa8811, 1);
			m_background.graphics.drawRect(0, 0, 30, 30);
			m_background.graphics.endFill();
			m_tooltip.visible = false;
		}
		
		private function mouseOver(event:MouseEvent):void
		{
			m_background.graphics.clear();
			m_background.graphics.lineStyle(1, 0x111111);
			m_background.graphics.beginFill(0xbb9922, 1);
			m_background.graphics.drawRect(0, 0, 30, 30);
			m_background.graphics.endFill();
			
			m_tooltip.visible = true;
			m_tooltip.x = event.stageX + 16;
			m_tooltip.y = event.stageY + 16;
		}
		
		
		private var m_background:Sprite, m_tooltip:Sprite, m_cooldown:TextField, m_charges:TextField;
		private var m_ability:AbilityInstance;
		private var m_stage:Stage;
	}
}