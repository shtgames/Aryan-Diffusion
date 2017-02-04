package ad.gui.card 
{
	import ad.scenario.Scenario;
	import ad.scenario.card.card.Card;
	import ad.scenario.card.card.CardState;
	import ad.scenario.event.EventType;
	import ad.scenario.event.Event;
	import ad.map.Map;
	import ad.scenario.player.Player;
	import flash.display.MovieClip;
	import flash.display.Stage;
	
	public class FieldVisual extends MovieClip
	{
		public function FieldVisual(first:Boolean, stage:Stage) 
		{
			m_first = first;
			m_stage = stage;
			
			m_cards.push(Card.CHARACTER, new Vector.<CardStateVisual>())
				.push(Card.SUPPORT, new Vector.<CardStateVisual>())
				.push(Card.HABITAT, new Vector.<CardStateVisual>());
		}
		
		public function get player():Player
		{
			return Scenario.current == null ? null : (m_first ? Scenario.current.field.first : Scenario.current.field.second)
		}
		
		public function input(event:Event):void
		{
			if (player == null || 
				(!event.type.equals(EventType.FieldEvent) && !event.type.equals(EventType.CardEvent) && !event.type.equals(EventType.AbilityEvent) && !event.type.equals(EventType.StatusEffectEvent)))
				return;
			
			if (event.data.at("added") && event.data.at("card") != null && event.data.at("card").parent == player)
			{
				const visual:CardStateVisual = new CardStateVisual(event.data.at("card"), m_first, m_stage);
				m_cards.at(event.data.at("card").card.type).push(visual);
				addChild(visual);
				reposition();
			}
			else if ((event.data.at("destroyed") || event.data.at("removed")) && event.data.at("card") != null && event.data.at("card").parent == player)
			{
				m_cards.at(event.data.at("card").card.type).removeAt(event.data.at("index"));
				removeChildAt((event.data.at("card").card.type == Card.CHARACTER ? 0 :
					(event.data.at("card").card.type == Card.SUPPORT ? m_cards.at(Card.CHARACTER).length : m_cards.at(Card.CHARACTER).length + m_cards.at(Card.SUPPORT).length)) + event.data.at("index"));
				reposition();
			}
			
			for each (var cards:Vector.<CardStateVisual> in m_cards)
				for each (var card:CardStateVisual in cards)
					card.input(event);
		}
		
		
		private function reposition():void
		{
			var vector:Vector.<CardStateVisual> = m_cards.at(Card.CHARACTER);
			const cardWidth:uint = CardStateVisual.cardWidth;
			
			for (var i:uint = 0, end:uint = vector.length; i != end; ++i)
				vector[i].x = i * (cardWidth + 5);
			
			var offset:uint = vector.length * (cardWidth + 5);
			vector = m_cards.at(Card.SUPPORT);
			for (var i:uint = 0, end:uint = vector.length; i != end; ++i)
				vector[i].x = offset + i * (cardWidth + 5);
			
			offset += vector.length * (cardWidth + 5);
			vector = m_cards.at(Card.HABITAT);
			for (var i:uint = 0, end:uint = vector.length; i != end; ++i)
				vector[i].x = offset + i * (cardWidth + 5);
			
			x = (m_stage.stageWidth - width) / 2;
			y = m_first ? m_stage.stageHeight / 2 + 5 : m_stage.stageHeight / 2 - height - 5;
		}
		
		
		private var m_first:Boolean;
		private var m_stage:Stage;
		private const m_cards:Map = new Map();
	}
}