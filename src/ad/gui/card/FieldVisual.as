package ad.gui.card 
{
	import ad.gui.UI;
	import ad.scenario.Scenario;
	import ad.scenario.card.card.Card;
	import ad.scenario.card.card.CardState;
	import ad.scenario.event.EventType;
	import ad.scenario.event.Event;
	import flash.geom.Rectangle;
	import utils.map.Map;
	import ad.scenario.player.Player;
	import flash.display.MovieClip;
	import flash.display.Stage;
	
	public class FieldVisual extends MovieClip
	{
		public function FieldVisual(first:Boolean, ui:UI) 
		{
			m_first = first;
			m_parent = ui;
			
			m_cards.push(Card.CHARACTER, new Vector.<CardStateVisual>())
				.push(Card.SUPPORT, new Vector.<CardStateVisual>())
				.push(Card.HABITAT, new Vector.<CardStateVisual>());
		}
		
		public function get player():Player
		{
			return Scenario.current == null ? null : (m_first ? Scenario.current.field.first : Scenario.current.field.second)
		}
		
		public function getStage():Stage
		{
			return m_parent.getStage();
		}
		
		public function getCharacterIntersection(rect:Rectangle):CardState
		{
			if (rect == null)
				return null;
			
			var width:uint = 0, widthBuffer:uint = 0;
			var buffer:CardState = null;
			for each (var card:CardStateVisual in m_cards.at(Card.CHARACTER))
				if (width < (widthBuffer = card.getBounds(m_parent.getStage()).intersection(rect).width))
				{
					width = widthBuffer;
					buffer = card.card;
				}
			
			return buffer;
		}
		
		public function input(event:Event):void
		{
			if (player == null || 
				(event.type != EventType.FieldEvent && event.type != EventType.CardEvent && event.type != EventType.AbilityEvent && event.type != EventType.StatusEffectEvent))
				return;
			
			if (event.data.at("added") && event.data.at("card") != null && event.data.at("card").parent == player)
			{
				const visual:CardStateVisual = new CardStateVisual(event.data.at("card"), m_first, this);
				m_cards.at(event.data.at("card").card.type).push(visual);
				addChild(visual);
				reposition();
			}
			else if ((event.data.at("destroyed") || event.data.at("removed")) && event.data.at("card") != null && event.data.at("card").parent == player)
			{
				CardStateVisual(removeChild(m_cards.at(event.data.at("card").card.type).removeAt(event.data.at("index")))).dispose();
				reposition();
			}
			
			for each (var cards:Vector.<CardStateVisual> in m_cards)
				for each (var card:CardStateVisual in cards)
					card.input(event);
		}
		
		public function reposition():void
		{
			var vector:Vector.<CardStateVisual> = m_cards.at(Card.CHARACTER);
			var prev:uint = 0;
			
			for (var i:uint = 0, end:uint = vector.length; i != end; ++i)
				vector[i].x = (prev += vector[i].getWidth() + 5) - vector[i].getWidth();
			
			vector = m_cards.at(Card.SUPPORT);
			for (var i:uint = 0, end:uint = vector.length; i != end; ++i)
				vector[i].x = (prev += vector[i].getWidth() + 5) - vector[i].getWidth();
			
			vector = m_cards.at(Card.HABITAT);
			for (var i:uint = 0, end:uint = vector.length; i != end; ++i)
				vector[i].x = (prev += vector[i].getWidth() + 5) - vector[i].getWidth();
			
			x = (m_parent.getStage().stageWidth - width) / 2;
			y = m_first ? m_parent.getStage().stageHeight / 2 + 5 : m_parent.getStage().stageHeight / 2 - height - 5;
		}
		
		
		private var m_first:Boolean;
		private var m_parent:UI;
		private const m_cards:Map = new Map();
	}
}