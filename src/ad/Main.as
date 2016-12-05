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
			/*Card.loadResources("../resources/cards/definitions.dir");
			Ability.loadResources("../resources/abilities/definitions.dir");*/
			
			var parser:Parser = new Parser(new Lexer("this = 3 - constant + (sin (3.14 * cos(30), _secondArg) / (3 * (5 + that)) - 1) ^ 2;"));			
			const tree:ParseTreeNode = parser.parse();
			trace(tree.getChildren()[1].getChildren()[1].getChildren()[1].getToken().text);
		}
	}	
}