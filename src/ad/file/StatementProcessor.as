package ad.file 
{
	import ad.expression.Lexer;
	import ad.expression.Parser;
	import ad.expression.ParseNode;
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	public class StatementProcessor 
	{		
		public function StatementProcessor(path:String = null, onLoad:Function = null)
		{
			if (path != null) loadFromFile(path, onLoad);
		}
		
		
		public function loadFromFile(path:String, onLoad:Function = null):Boolean
		{
			if (path == null)
			{
				m_path = null;
				return false;				
			}
			m_loading = true;
			m_path = path;
			
			var loader:URLLoader = new URLLoader();
			loader.load(new URLRequest(m_path));
			
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
				{
					m_statements = null;
					m_loading = false;
					trace("Failed to load file \"" + m_path + "\".");
				});
			
			loader.addEventListener(Event.COMPLETE, function(e:Event):void 
				{
					m_statements = new Parser(new Lexer(loader.data).process()).parse();					
					m_loading = false;					
					if (onLoad != null)	onLoad(getStatements());
				} );
			
			return true;
		}
		
		public function getStatements():Vector.<ParseNode>
		{
			return m_statements;
		}
		
		public function isLoading():Boolean
		{
			return m_loading.valueOf();
		}
		
		
		private var m_statements:Vector.<ParseNode> = null;
		private var m_path:String = "";
		private var m_loading:Boolean = false;
	}
}