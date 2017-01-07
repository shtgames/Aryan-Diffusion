package ad
{
	import ad.expression.Lexer;
	import ad.expression.Parser;
	import flash.display.MovieClip;
	
	import ad.deck.card.Card;
	import ad.deck.card.Ability;
	import ad.deck.effect.StatusEffect;
	
	public class Main extends MovieClip
	{
		public function Main()
		{
			const scope:Object = new Object(), tikva:Object = new Object();
			tikva["prop1"] = "heya";
			tikva["mez"] = new Object();
			tikva["mez"]["yh"] = Math.sin;
			tikva["mez"]["index"] = 3;
			tikva["mez"]["arg"] = 100;
			tikva["tan"] = function(arg:Number):Number 
				{
					return Math.sin(arg) / Math.cos(arg);
				};
			tikva["arr"] = new Array(10, 15, 20);
			
			scope["tikva"] = tikva;
			scope["true"] = true;
			scope["sin"] = Math.sin;
			scope["result"] = 10;
			
			const parser:Parser = new Parser(new Lexer("result = tikva.arr[1].toPrecision(5) + tikva.mez.yh(tikva.mez.arg).toString().charAt(-1 + tikva.mez.index) + 10 + \"dif\";\
					Athena = { property1 = \"tikva\"; prop2 = { 20, 30, result = result + \"tikva\" } }; predicate = true + !0;").process());
			parser.parse()[0].evaluate(scope, scope);
			parser.parse()[1].evaluate(scope, scope);
			trace(parser.parse()[2].evaluate(scope, scope));
			
			/*StatusEffect.loadResources("../resources/status_effects/definitions.dir");
			Ability.loadResources("../resources/abilities/definitions.dir");
			Card.loadResources("../resources/cards/definitions.dir");*/
		}
	}
}