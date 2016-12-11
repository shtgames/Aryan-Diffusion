package ad
{
	import ad.expression.Lexer;
	import ad.expression.ParseTreeNode;
	import ad.expression.Parser;
	import ad.expression.Token;
	import flash.concurrent.Mutex;
	import flash.display.MovieClip;
	
	import ad.deck.card.Card;
	import ad.deck.card.Ability;
	import ad.map.HashMap;
	
	import ad.expression.TokenType;
	
	public class Main extends MovieClip
	{
		public function Main()
		{
			Ability.loadResources("../resources/abilities/definitions.dir");
			Card.loadResources("../resources/cards/definitions.dir");
		}
	}	
}