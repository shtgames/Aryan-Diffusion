package ad.gui.card 
{
	import ad.scenario.card.effect.AbilityInstance;
	import flash.ui.Mouse;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class TargetingReticule extends MovieClip
	{
		public function TargetingReticule(ability:AbilityInstance, stage:Stage) 
		{
			m_ability = ability;
			
			{
				const visual:Sprite = new Sprite();
				visual.graphics.beginFill(0xaa4435, .95);
				visual.graphics.drawRect(10, 0, 5, 25);
				visual.graphics.drawRect(0, 10, 25, 5);
				visual.graphics.endFill();
				
				addChild(visual);
			}
			
			(m_stage = stage).addChild(this);
			m_stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			m_stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			
			x = m_stage.mouseX - 12;
			y = m_stage.mouseY - 12;
			Mouse.hide();
			
			reticule = this;
		}
		
		
		public function get ability():AbilityInstance
		{
			return m_ability;
		}
		
		
		private function mouseUp(event:MouseEvent):void
		{
			Mouse.show();
			
			m_stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			m_stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			m_stage.removeChild(this);
			reticule = null;
		}
		
		private function mouseMove(event:MouseEvent):void
		{
			x = event.stageX - 12;
			y = event.stageY - 12;
		}
		
		
		private var m_ability:AbilityInstance;
		private var m_added:Boolean = false;
		private var m_stage:Stage;
		
		public static var reticule:TargetingReticule = null;
	}
}