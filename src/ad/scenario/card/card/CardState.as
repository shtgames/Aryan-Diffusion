package ad.scenario.card.card 
{
	import ad.gui.card.CardStateVisual;
	import ad.scenario.card.effect.Ability;
	import ad.scenario.card.effect.AbilityInstance;
	import ad.scenario.card.effect.StatusEffect;
	import ad.scenario.card.effect.StatusEffectInstance;
	import ad.scenario.player.Player;
	import ad.scenario.card.card.Card;
	import ad.scenario.event.Event;
	import ad.scenario.event.EventType;
	import ad.scenario.event.EventDispatcher;
	import utils.map.ConcurrentMap;
	import utils.map.Map;
	
	public class CardState
	{
		public function CardState(cardValue:Card, parentValue:Object) 
		{
			if (cardValue == null) return;
			
			m_card = cardValue;
			m_maxHealth = m_health = cardValue.health;
			m_attack = cardValue.attack;
			
			m_parent = parentValue;
			
			m_cacheEvents = true;
			for each (var effect:StatusEffect in m_card.passives)
				applyStatusEffect(effect);
			
			for each (var ability:Ability in m_card.abilities)
				addAbility(ability);
			m_cacheEvents = false;
			
			for each (var event:Event in m_eventCache)
				EventDispatcher.pollEvent(event);
			m_eventCache.length = 0;
		}
		
		
		public function toString():String
		{
			return (m_card == null ? "<Undefined>" : card.toString()) + " (" + m_health + "/" + m_attack + ")";
		}
		
		public function get card():Card
		{
			return m_card;
		}
		
		public function get health():int
		{
			return m_health;
		}
		
		public function get maxHealth():uint
		{
			return m_maxHealth;
		}
		
		public function get attack():uint
		{
			return m_attack;
		}
		
		public function get abilities():Vector.<AbilityInstance>
		{
			const returnValue:Vector.<AbilityInstance> = new Vector.<AbilityInstance>();
			
			for each (var ability:AbilityInstance in m_abilities)
				returnValue.push(ability);
			return returnValue;
		}
		
		public function get effects():Vector.<StatusEffectInstance>
		{
			const returnValue:Vector.<StatusEffectInstance> = new Vector.<StatusEffectInstance>();
			
			for each (var effects:Vector.<StatusEffectInstance> in m_statusEffects)
				for each (var effect:StatusEffectInstance in effects)
					returnValue.push(effect);
			return returnValue;
		}
		
		public function get parent():Object
		{
			return m_parent;
		}
		
		
		public function setHealth(health:int, source:Object = null):CardState
		{
			if (m_health == health || (health < m_health && m_card.hasFlag(Card.INDESTRUCTIBLE)) ||
				(m_health == m_maxHealth && health > m_maxHealth))
				return this;
			
			health = health > m_maxHealth ? m_maxHealth : health;
			const previous:int = m_health;
			m_health = health;
			(m_cacheEvents ? m_eventCache.push : EventDispatcher.pollEvent)
				.call(null, new Event(EventType.CardEvent, new Map()
					.push("card", this)
					.push("source", source)
					.push("health", true)
					.push("previous", previous)));
			return this;
		}
		
		public function setMaxHealth(health:uint, source:Object = null):CardState
		{
			if (health == 0 || health == m_maxHealth)
				return this;
			
			const previous:uint = m_maxHealth;
			m_maxHealth = health;
			(m_cacheEvents ? m_eventCache.push : EventDispatcher.pollEvent)
				.call(null, new Event(EventType.CardEvent, new Map()
					.push("card", this)
					.push("source", source)
					.push("health", true)
					.push("previous", previous)));
			
			if (m_health > m_maxHealth)
				setHealth(m_maxHealth, source);
			
			return this;
		}
		
		public function setAttack(attack:uint, source:Object = null):CardState
		{
			if (attack == m_attack)
				return this;
			
			const previous:uint = m_attack;
			m_attack = attack;
			(m_cacheEvents ? m_eventCache.push : EventDispatcher.pollEvent)
				.call(null, new Event(EventType.CardEvent, new Map()
					.push("card", this)
					.push("source", source)
					.push("attack", true)
					.push("previous", previous)));
			return this;
		}
		
		
		public function input(event:Event):void
		{
			if (m_card == null)
				return;
			
			for each (var ability:AbilityInstance in m_abilities)
				ability.input(event);
			
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
						
						(m_cacheEvents ? m_eventCache.push : EventDispatcher.pollEvent)
							.call(null, new Event(EventType.StatusEffectEvent, new Map()
								.push("expired", true)
								.push("effect", effects.removeAt(index))));
					}
					else effect.input(event);
				}
				
				if (effects.length == 0)
					toErase.push(key);
			}
			
			for each (var key:String in toErase)
				if (m_statusEffects.at(key).length == 0)
					m_statusEffects.erase(key);
			
			if (event.type == EventType.FieldEvent && (event.data.at("destroyed") || event.data.at("removed")))
				{
					const card:CardState = event.data.at("card");
					if (card == this)
					{
						EventDispatcher.removeListener(input);
						if (card.m_card.type == Card.CHARACTER)
							while (m_support.length != 0)
								destroySupportAt(m_support.length - 1, event.data.at("source"));
					}
					else if (card.m_parent == this)
						for (var i:uint = 0, end:uint = m_support.length; i != end; ++i)
							if (m_support[i] == card)
							{
								m_support.removeAt(m_removedSupport = i);
								break;
							}
				}
			
			if (m_card.type == Card.CHARACTER)
				for (var i:uint = 0; i < m_support.length; ++i)
					{	
						m_support[i].input(event);
						if (m_removedSupport != -1 && m_removedSupport <= i)
							i += (m_removedSupport = -1);
					}
		}
		
		
		public function useAbility(id:String, target:CardState):Boolean
		{
			if (!m_abilities.contains(id))
				return false;
			return m_abilities.at(id).useOn(target), true;
		}
		
		public function addAbility(ability:Ability, source:Object = null):void
		{
			if (ability == null)
				return;
			
			const instance:AbilityInstance = new AbilityInstance(ability, this);
			m_abilities.push(ability.id, instance);
			
			(m_cacheEvents ? m_eventCache.push : EventDispatcher.pollEvent)
				.call(null, new Event(EventType.AbilityEvent, new Map()
					.push("gained", true)
					.push("source", source)
					.push("ability", instance)));
		}
		
		public function removeAbility(id:String, source:Object = null):void
		{
			const instance:AbilityInstance = m_abilities.at(id);
			if (instance == null)
				return;
			
			m_abilities.erase(id);
			(m_cacheEvents ? m_eventCache.push : EventDispatcher.pollEvent)
				.call(null, new Event(EventType.AbilityEvent, new Map()
					.push("lost", true)
					.push("source", source)
					.push("ability", instance)));
		}
		
		
		public function applyStatusEffect(effect:StatusEffect, source:Object = null):void
		{
			if (effect == null) return;
			
			if (!m_statusEffects.contains(effect.id))
				m_statusEffects.push(effect.id, new Vector.<StatusEffectInstance>());
			
			if (m_statusEffects.at(effect.id).length < effect.instanceCap)
			{
				const instance:StatusEffectInstance = new StatusEffectInstance(effect, this);
				m_statusEffects.at(effect.id).push(instance);
				
				(m_cacheEvents ? m_eventCache.push : EventDispatcher.pollEvent)
					.call(null, new Event(EventType.StatusEffectEvent, new Map()
						.push("applied", true)
						.push("source", source)
						.push("effect", instance)));
			}
			else for each (var it:StatusEffectInstance in m_statusEffects.at(effect.id))
				if (it.apply())
					break;
		}
		
		public function removeStatusEffect(id:String, source:Object = null):void
		{
			if (!m_statusEffects.contains(id))
				return;
			
			const effects:Vector.<StatusEffectInstance> = m_statusEffects.at(id);
			if (effects.length == 0)
				return;
			
			(m_cacheEvents ? m_eventCache.push : EventDispatcher.pollEvent)
				.call(null, new Event(EventType.StatusEffectEvent, new Map()
					.push("removed", true)
					.push("source", source)
					.push("effect", effects.pop())));
			
			if (effects.length == 0)
				m_statusEffects.erase(id);
		}
		
		
		public function getSupportCount():uint
		{
			return m_support.length;
		}
		
		public function getSupportIndex(support:CardState):int
		{
			for (var i:uint = 0, end:uint = m_support.length; i != end; ++i)
				if (m_support[i] == support)
					return i;
			return -1;
		}
		
		public function getSupportAt(index:uint):CardState
		{
			return index >= m_support.length ? null : m_support[index];
		}
		
		public function addSupport(cardPrototype:Card, source:Object = null):void
		{
			const support:CardState = new CardState(cardPrototype, this);
			if (m_card == null || m_card.type != Card.CHARACTER || support == null || support.card == null || support.card.type != Card.SUPPORT)
				return;
			
			for each (var card:CardState in m_support)
				if (card == support)
					return;
			
			support.m_parent = this;
			m_support.push(support);
			EventDispatcher.pollEvent(new Event(EventType.FieldEvent, new Map()
				.push("card", support)
				.push("index", m_support.length - 1)
				.push("source", source)
				.push("added", true)));
			
			setMaxHealth(m_maxHealth + support.m_maxHealth);
			setHealth(m_health + support.m_health);
			setAttack(m_attack + support.m_attack);
		}
		
		public function removeSupport(support:CardState, source:Object = null):void
		{
			if (support == null || support.card == null || support.card.type != Card.SUPPORT)
				return;
			
			for (var i:uint = 0, end:uint = m_support.length; i != end; ++i)
				if (m_support[i] == support)
				{
					removeSupportAt(i);
					return;
				}
		}
		
		public function destroySupport(support:CardState, source:Object = null):void
		{
			if (support == null || support.card == null || support.card.type != Card.SUPPORT)
				return;
			
			for (var i:uint = 0, end:uint = m_support.length; i != end; ++i)
				if (m_support[i] == support)
				{
					destroySupportAt(i);
					return;
				}
		}
		
		public function removeSupportAt(index:uint, source:Object = null):void
		{
			if (index >= m_support.length)
				return;
			
			const card:CardState = CardState(m_support.removeAt(m_removedSupport = index));
			EventDispatcher.addListener(card.input);
			EventDispatcher.pollEvent(new Event(EventType.FieldEvent, new Map()
				.push("card", card)
				.push("index", index)
				.push("source", source)
				.push("removed", true)));
			
			setMaxHealth(m_maxHealth - card.m_maxHealth);
		}
		
		public function destroySupportAt(index:uint, source:Object = null):void
		{
			if (index >= m_support.length)
				return;
			
			const card:CardState = CardState(m_support.removeAt(m_removedSupport = index));
			EventDispatcher.addListener(card.input);
			EventDispatcher.pollEvent(new Event(EventType.FieldEvent, new Map()
				.push("card", card)
				.push("index", index)
				.push("source", source)
				.push("destroyed", true)));
			
			setMaxHealth(m_maxHealth - card.m_maxHealth);
		}
		
		
		private var m_card:Card = null;
		private var m_parent:Object = null;
		private var m_health:int = 0, m_maxHealth:uint = 0, m_attack:uint = 0;
		
		private var m_statusEffects:ConcurrentMap = new ConcurrentMap();
		private var m_abilities:ConcurrentMap = new ConcurrentMap();
		private var m_support:Vector.<CardState> = new Vector.<CardState>(), m_removedSupport:int = -1;
		
		private var m_cacheEvents:Boolean = false, m_eventCache:Vector.<Event> = new Vector.<Event>();
	}
}