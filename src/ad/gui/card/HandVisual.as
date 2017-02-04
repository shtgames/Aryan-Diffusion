package ad.gui.card 
{
	import ad.scenario.Scenario;
	import ad.scenario.card.Hand;
	import ad.scenario.card.card.Card;
	import ad.scenario.event.Event;
	import ad.scenario.event.EventType;
	import ad.map.Map;
	import flash.display.Stage;
	
	import flash.display.MovieClip;
	
	public class HandVisual extends MovieClip
	{
		public function HandVisual(stage:Stage, visible:Boolean)
		{
			m_stage = stage;
			m_visible = visible;
			
			m_cards.push(Card.CHARACTER, new Vector.<CardVisual>())
				.push(Card.SUPPORT, new Vector.<CardVisual>())
				.push(Card.HABITAT, new Vector.<CardVisual>());
		}
		
		public function input(event:Event):void
		{
			if (!event.type.equals(EventType.HandEvent) || event.data.at("hand") != getHand())
				return;
			
			const card:Card = Card.getCard(event.data.at("card"));
			if (event.data.at("added"))
			{
				const visual:CardVisual = new CardVisual(card, m_visible, this);
				m_cards.at(card.type).push(visual);
				addChild(visual);
				reposition();
			}
			else if (event.data.at("removed"))
			{
				removeChild(m_cards.at(card.type).removeAt(event.data.at("index")));
				reposition();
			}
		}
		
		public function reposition():void
		{
			var vector:Vector.<CardVisual> = m_cards.at(Card.CHARACTER);
			const cardWidth:uint = CardVisual.cardWidth;
			
			for (var i:uint = 0, end:uint = vector.length; i != end; ++i)
			{
				vector[i].x = i * (cardWidth + 5);
				vector[i].y = 0;
			}
			
			var offset:uint = vector.length * (cardWidth + 5);
			vector = m_cards.at(Card.SUPPORT);
			for (var i:uint = 0, end:uint = vector.length; i != end; ++i)
			{
				vector[i].x = offset + i * (cardWidth + 5);
				vector[i].y = 0;
			}
			
			offset += vector.length * (cardWidth + 5);
			vector = m_cards.at(Card.HABITAT);
			for (var i:uint = 0, end:uint = vector.length; i != end; ++i)
			{
				vector[i].x = offset + i * (cardWidth + 5);
				vector[i].y = 0;
			}
			
			x = (m_stage.stageWidth - width) / 2;
			y = m_visible ? m_stage.stageHeight - height - 5 : 0;
		}
		
		
		private function getHand():Hand
		{
			if (Scenario.current == null)
				return null;
			
			return m_visible ? Scenario.current.field.first.hand : Scenario.current.field.second.hand;
		}
		
		private const m_cards:Map = new Map();
		private var m_stage:Stage;
		private var m_visible:Boolean = true;
	}
}