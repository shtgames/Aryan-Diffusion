package ad.scenario.card.card 
{
	import ad.scenario.card.effect.Ability;
	import ad.scenario.card.effect.StatusEffect;
	import ad.scenario.card.effect.StatusEffectInstance;
	import ad.scenario.player.Player;
	import ad.scenario.card.card.Card;
	import ad.scenario.event.Event;
	import ad.scenario.event.EventListener;
	
	public class CardState extends EventListener
	{
		public function CardState(cardValue:Card, parentValue:Player) 
		{
			if (cardValue == null) return;
			
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
		
		
		public function setCard(value:Card):CardState
		{
			m_card = value;
			return this;
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
		
		
		override public function input(event:Event):void
		{
			if (event == null || !event.isValid())
				return;
			
			if (m_card != null)
				for each (var passive:String in m_card.passives)
					StatusEffect.getEffect(passive).input(this, event);
			
			for each (var effect:StatusEffectInstance in m_statusEffects)
				effect.input(event);
		}
		
		public function applyStatusEffect(id:String):void
		{
			if (!StatusEffect.exists(id)) return;
			m_statusEffects.push(id, StatusEffect.getEffect(id).duration);
		}
		
		public function useAbility(id:String, target:CardState):Boolean
		{
			if (m_card == null || !m_card.hasAbility(id)) return false;
			return Ability.getAbility(id).applyTo(this, target);
		}
		
		
		private var m_card:Card = null;
		private var m_parent:Player = null;
		private var m_health:int = 0, m_attack:uint = 0;
		private var m_statusEffects:Vector.<StatusEffectInstance> = new Vector.<StatusEffectInstance>();
	}
}