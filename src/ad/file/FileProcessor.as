package ad.file 
{
	import ad.expression.Lexer;
	import ad.expression.Parser;
	import ad.expression.ParseNode;
	
	import flash.concurrent.Mutex;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	public class FileProcessor 
	{		
		public function FileProcessor(path:String = null, onLoad:Function = null)
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
			
			
			if (channels >= maxChannels)
				enqueue(function ():void 
					{
						load(onLoad);
					} );
			else load(onLoad);
			
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
		
		
		private function load(onLoad:Function):void
		{
			const loader:URLLoader = new URLLoader();
			
			channels++;
			loader.load(new URLRequest(m_path));
			
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
				{
					m_statements = null;
					m_loading = false;
					if (onLoad != null)	onLoad(null);
					trace("Failed to load file \"" + m_path + "\".");
					
					processNextInQueue();
					channels--;
				});
			
			loader.addEventListener(Event.COMPLETE, function(e:Event):void 
				{
					m_statements = new Parser(new Lexer(loader.data).process()).parse();					
					m_loading = false;
					if (onLoad != null)	onLoad(getStatements());
					
					processNextInQueue();
					channels--;
				} );
		}
		
		
		private var m_statements:Vector.<ParseNode> = null;
		private var m_path:String = "";
		private var m_loading:Boolean = false;
		
		
		private static function enqueue(value:Function):void
		{
			if (value == null)
				return;
			
			mutex.lock();
			queue.push(value);
			mutex.unlock();
		}
		
		private static function processNextInQueue():void
		{
			mutex.lock();
			if (queue.length == 0)
				return mutex.unlock();
			
			if (queue[0] != null)
				queue[0].call(null);
			
			return queue.removeAt(0), mutex.unlock();
		}
		
		
		private static const mutex:Mutex = new Mutex();
		private static const queue:Vector.<Function> = new Vector.<Function>();
		private static var channels:uint = 0;
		
		private static const maxChannels:uint = 5;
	}
}