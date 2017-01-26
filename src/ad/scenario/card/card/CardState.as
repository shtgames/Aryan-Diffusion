package ad.scenario.card.card 
{
	import ad.map.ConcurrentMap;
	import ad.map.Map;
	import ad.scenario.card.effect.Ability;
	import ad.scenario.card.effect.StatusEffect;
	import ad.scenario.card.effect.StatusEffectInstance;
	import ad.scenario.player.Player;
	import ad.scenario.card.card.Card;
	import ad.scenario.event.Event;
	import ad.scenario.event.EventType;
	import ad.scenario.event.EventListener;
	import ad.scenario.event.EventDispatcher;
	
	public class CardState extends EventListener
	{
		public function CardState(cardValue:Card, parentValue:Player) 
		{
			if (cardValue == null) return;
			
			m_card = cardValue;
			m_health = cardValue.health;
			m_attack = cardValue.attack;
			
			m_parent = parentValue;
		}
		
		
		public function get card():Card
		{
			return m_card;
		}
		
		public function get health():uint
		{
			return m_health;
		}
		
		public function get attack():uint
		{
			return m_attack;
		}
		
		public function get parent():Player
		{
			return m_parent;
		}
		
		
		public function setHealth(health:uint):CardState
		{
			const previous_health:uint = m_health;
			m_health = health;
			EventDispatcher.pollEvent(new Event(EventType.CardEvent, new Map()
				.push("card", this)
				.push("health", true)
				.push("previous_health", previous_health)));
			return this;
		}
		
		public function setAttack(attack:uint):CardState
		{
			const previous_attack:uint = m_attack;
			m_attack = attack;
			EventDispatcher.pollEvent(new Event(EventType.CardEvent, new Map()
				.push("card", this)
				.push("attack", true)
				.push("previous_attack", previous_attack)));
			return this;
		}
		
		
		override public function input(event:Event):void
		{
			if (m_card == null || event == null || !event.isValid())
				return;
			
			for each (var passive:String in m_card.passives)
				StatusEffect.getEffect(passive).input(this, event);
			
			const toErase:Vector.<String> = new Vector.<String>();
			for (var key:String in m_statusEffects)
			{
				const effects:Vector.<StatusEffectInstance> = m_statusEffects.at(key);
				for (var index:uint = 0; index < effects.length; ++index)
				{
					const effect:StatusEffectInstance = effects[index];
					if (effect.duration != 0)
					{
						effect.input(event);
						if (effect.duration != 0)
							continue;
						
						effect.dispose = true;
						EventDispatcher.pollEvent(new Event(EventType.CardEvent, new Map()
							.push("effect_expired", true)
							.push("effect", effect)));
						effects.removeAt(index);
					}
					else effect.input(event);
				}
				
				if (effects.length == 0)
					toErase.push(key);
			}
			
			for each (var key:String in toErase)
				if (m_statusEffects.at(key).length == 0)
					m_statusEffects.erase(key);
		}
		
		public function applyStatusEffect(id:String):void
		{
			const effect:StatusEffect = StatusEffect.getEffect(id);
			if (effect == null) return;
			
			if (!m_statusEffects.contains(id))
				m_statusEffects.push(id, new Vector.<StatusEffectInstance>());
			
			if (m_statusEffects.at(id).length < effect.instanceCap)
			{
				const instance:StatusEffectInstance = new StatusEffectInstance(effect, this);
				m_statusEffects.at(id).push(instance);
				EventDispatcher.pollEvent(new Event(EventType.CardEvent, new Map()
					.push("effect_applied", true)
					.push("effect", instance)));
			}
			else for each (var it:StatusEffectInstance in m_statusEffects.at(id))
				if (it.apply())
					break;
		}
		
		public function removeStatusEffect(id:String):void
		{
			if (!m_statusEffects.contains(id))
				return;
			
			const effects:Vector.<StatusEffectInstance> = m_statusEffects.at(id);
			if (effects.length == 0)
				return;
			
			effects[effects.length - 1].dispose = true;
			
			EventDispatcher.pollEvent(new Event(EventType.CardEvent, new Map()
				.push("effect_removed", true)
				.push("effect", effects.pop())));
			
			if (effects.length == 0)
				m_statusEffects.erase(id);
		}
		
		public function useAbility(id:String, target:CardState):Boolean
		{
			if (m_card == null || !m_card.hasAbility(id)) return false;
			return Ability.getAbility(id).applyTo(this, target);
		}
		
		
		private var m_card:Card = null;
		private var m_parent:Player = null;
		private var m_health:int = 0, m_attack:uint = 0;
		private var m_statusEffects:ConcurrentMap = new ConcurrentMap();
	}
}