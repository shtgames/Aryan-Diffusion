package ad.gui.card 
{
	import ad.scenario.player.Player;
	import ad.scenario.card.card.CardState;
	import ad.scenario.card.card.Card;
	import ad.scenario.card.effect.AbilityInstance;
	import ad.scenario.card.effect.StatusEffectInstance;
	import ad.scenario.event.EventType;
	import ad.scenario.event.Event;
	import ad.scenario.field.Field;
	import utils.gui.components.ScrollPane;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	
	public class CardStateVisual extends MovieClip
	{
		public function CardStateVisual(card:CardState, first:Boolean, parent:FieldVisual) 
		{
			m_first = first;
			m_card = card;
			m_parent = parent;
			
			m_background = new Sprite();
			m_background.graphics.lineStyle(1, 0x111111);
			m_background.graphics.beginFill(0xdddccd, 1);
			m_background.graphics.drawRect(0, 0, cardWidth, cardHeight);
			m_background.graphics.endFill();
			
			addChild(m_background);
			width = cardWidth;
			height = cardHeight;
			
			{
				const typeText:TextField = new TextField();
				switch (card.card.type)
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
				name.text = card.card.name;
				name.wordWrap = true;
				name.width = cardWidth;
				name.height = name.textHeight + 5;
				name.textColor = 0x774444;
				
				name.x = (cardWidth - name.textWidth) / 2;
				name.y = typeText.y + name.height;
				
				addChild(name);
			}
			
			{
				m_stats = new TextField();
				m_stats.width = cardWidth;
				m_stats.wordWrap = true;
				m_stats.text =  card.health + "/" + card.attack;
				
				m_stats.height = m_stats.textHeight + 5;
				m_stats.textColor = 0x787521;
				
				m_stats.x = (cardWidth - m_stats.textWidth) / 2;
				m_stats.y = name.y + m_stats.height;
				
				addChild(m_stats);
			}
			
			{
				m_abilities = new ScrollPane();
				m_abilities.vertical = false;
				m_abilities.x = 5;
				m_abilities.y = m_stats.y + m_stats.height;
				m_abilities.resetScrollRect(cardWidth - 10, 31);
				
				for each (var ability:AbilityInstance in card.abilities)
					m_abilities.addChild(new AbilityVisual(ability, m_parent.getStage()));
				
				addChild(m_abilities);
			}
			
			{
				m_effects = new ScrollPane();
				m_effects.vertical = false;
				m_effects.x = 5;
				m_effects.y = m_abilities.y + m_abilities.scrollRect.height + 1;
				m_effects.resetScrollRect(cardWidth - 10, 31);
				
				for each (var effect:StatusEffectInstance in card.effects)
					m_effects.addChild(new EffectVisual(effect, m_parent.getStage()));
				
				addChild(m_effects);
			}
			
			if (card.card.type == Card.CHARACTER)
			{
				m_support = new ScrollPane();
				m_support.resetScrollRect(cardWidth, cardHeight);
				addChild(m_support);
			}
			
			addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		}
		
		public function getWidth():uint
		{
			return cardWidth + (m_support != null && m_support.numChildren != 1 ? cardWidth : 0);
		}
		
		public function get card():CardState
		{
			return m_card;
		}
		
		public function input(event:Event):void
		{
			if ((event.type != EventType.FieldEvent || (!event.data.at("added") && !event.data.at("removed") && !event.data.at("destroyed"))) &&
				(event.type != EventType.AbilityEvent || event.data.at("ability").parent != m_card) &&
				(event.type != EventType.StatusEffectEvent || event.data.at("effect").parent != m_card) &&
				(event.type != EventType.CardEvent || event.data.at("card") != m_card))
				return;
			
			if (event.data.at("health") || event.data.at("attack"))
				m_stats.text = m_card.health + "/" + m_card.attack;
			else if (event.data.at("charges") || event.data.at("cooldown"))
				for (var i:uint = 0, end:uint = m_abilities.numChildren, ability:AbilityVisual = AbilityVisual(m_abilities.getChildAt(i)); i != end; ability = AbilityVisual(m_abilities.getChildAt(++i)))
				{
					if (ability == null)
						break;
					else if (ability.ability == event.data.at("ability"))
					{
						ability.input(event);
						break;
					}
				}
			else if (event.data.at("gained"))
				m_abilities.addChild(new AbilityVisual(event.data.at("ability"), m_parent.getStage()));
			else if (event.data.at("lost"))
				for (var i:uint = 0, end:uint = m_abilities.numChildren, ability:AbilityVisual = AbilityVisual(m_abilities.getChildAt(i)); i != end; ability = AbilityVisual(m_abilities.getChildAt(++i)))
				{	
					if (ability == null)
						break;
					else if (ability.ability == event.data.at("ability"))
					{
						ability.dispose();
						m_abilities.removeChild(ability);
						break;
					}
				}
			else if (event.type == EventType.StatusEffectEvent)
			{
				if (event.data.at("duration") || event.data.at("stacks"))
					for (var i:uint = 0, end:uint = m_effects.numChildren, effect:EffectVisual = EffectVisual(m_effects.getChildAt(i)); i != end; effect = EffectVisual(m_effects.getChildAt(++i)))
					{
						if (effect == null)
							break;
						else if (effect.effect == event.data.at("effect"))
						{
							effect.input(event);
							break;
						}
					}
				else if (event.data.at("applied"))
					m_effects.addChild(new EffectVisual(event.data.at("effect"), m_parent.getStage()));
				else if (event.data.at("expired") || event.data.at("removed"))
					for (var i:uint = 0, end:uint = m_effects.numChildren, effect:EffectVisual = EffectVisual(m_effects.getChildAt(i)); i != end; effect = EffectVisual(m_effects.getChildAt(++i)))
					{
						if (effect == null)
							break;
						else if (effect.effect == event.data.at("effect"))
						{
							EffectVisual(m_effects.removeChild(effect)).dispose();
							break;
						}
					}
			}
			else if (event.type == EventType.FieldEvent && m_card.card.type == Card.CHARACTER && event.data.at("card") is CardState)
			{
				const card:CardState = event.data.at("card");
				if (card != null && card.card.type == Card.SUPPORT && card.parent == m_card)
				{
					if (event.data.at("added"))
					{
						m_support.x = cardWidth;
						m_support.y = cardHeight / 5;
						m_support.addChild(new CardStateVisual(card, m_first, m_parent));
						m_parent.reposition();
					}
					else if (event.data.at("removed") || event.data.at("destroyed"))
					{
						CardStateVisual(m_support.removeChildAt(event.data.at("index") + 1)).dispose();
						if (m_support.numChildren == 1)
						{
							m_support.x = 0;
							m_support.y = 0;
						}
						m_parent.reposition();
					}
				}
			}
		}
		
		public function dispose():void
		{
			while (m_abilities.numChildren > 1)
				AbilityVisual(m_abilities.removeChildAt(m_abilities.numChildren - 1)).dispose();
			while (m_effects.numChildren > 1)
				EffectVisual(m_effects.removeChildAt(m_effects.numChildren - 1)).dispose();
		}
		
		private function mouseUp(event:MouseEvent):void
		{
			if (TargetingReticule.reticule != null)
				TargetingReticule.reticule.ability.useOn(m_card);
		}
		
		
		private var m_first:Boolean;
		private var m_stats:TextField, m_abilities:ScrollPane, m_effects:ScrollPane;
		private var m_card:CardState;
		private var m_background:Sprite;
		private var m_parent:FieldVisual;
		private var m_support:ScrollPane = null;
		
		public static const cardWidth:uint = 90, cardHeight:uint = 125;
	}
}