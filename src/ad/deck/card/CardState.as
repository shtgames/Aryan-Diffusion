package ad.deck.card 
{
	import ad.deck.effect.StatusEffect;
	import ad.deck.effect.StatusEffectState;
	import ad.event.Event;
	import ad.event.EventListener;
	import ad.map.Map;
	import ad.player.Player;
	import ad.deck.card.Card;
	
	public class CardState extends EventListener
	{
		public function CardState(card:String) 
		{
			if (!Card.exists(card)) return;
			
			const buffer:Card = Card.getCard(card);
			m_health = buffer.health;
			m_attack = buffer.attack;
		}
		
		
		public function get cardKey():String
		{
			return m_key;
		}
		
		public function setCardKey(key:String):CardState
		{
			if (Card.exists(key)) m_key = key;
			return this;
		}
		
		
		public function get health():uint
		{
			return m_health;
		}
		
		public function get attack():uint
		{
			return m_attack;
		}
		
		public function setHealth(health:uint):CardState
		{
			m_health = health;
			return this;
		}
		
		public function setAttack(attack:uint):CardState
		{
			m_attack = attack;
			return this;
		}
		
		
		public function get parent():Player
		{
			return m_parent;
		}
		
		public function setParent(newParent:Player):CardState
		{
			m_parent = newParent;
			return this;
		}
		
		
		override public function input(event:Event):void
		{
			for (var effect:String in m_statusEffects)
				StatusEffect.getEffect(effect).input(event, this);
		}
		
		public function applyStatusEffect(id:String):void
		{
			if (!StatusEffect.exists(id)) return;
			
			m_statusEffects.push(id, StatusEffect.getEffect(id).duration);
		}
		
		public function useAbility(id:String, target:CardState):Boolean
		{
			if (!Card.exists(m_key) || !Card.getCard(m_key).hasAbility(id))	return false;
			
			return Ability.getAbility(id).applyTo(target, this);
		}
		
		
		private var m_key:String = null;
		private var m_parent:Player = null;
		private var m_health:int = 0, m_attack:uint = 0;
		private var m_statusEffects:Vector.<StatusEffectState> = new Vector.<StatusEffectState>();
	}
}