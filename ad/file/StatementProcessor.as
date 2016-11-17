package ad.file 
{
	import flash.concurrent.Mutex;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	public class StatementProcessor 
	{
		public static function getDirectoryContents(path:String):Vector.<String>
		{
			// Need to use Adobe AIR for this to work.
			return new Vector.<String>();
		}
		
		
		public function StatementProcessor(path:String = null, onLoad:Function = null)
		{
			if (path != null) loadFromFile(path, onLoad);
		}
		
		
		public function loadFromFile(path:String, onLoad:Function = null ):Boolean
		{
			if (path == null) return false;
			
			var loader:URLLoader = new URLLoader();
			loader.load(new URLRequest(path));
			
			
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent) : void
				{
					m_statements = null;
					trace("Failed to load file \"" + path + "\".");
				});
			loader.addEventListener(Event.COMPLETE, function(e:Event) : void 
				{
					var file:String = new String(loader.data);
					var lines:Array = file.split(';');
					m_statements = new Vector.<Statement>();
					
					for each (var line:String in lines)
					{
						var left:Array = getLeftHandSide(line, '=');
						if (left[0].length == 0) continue;
						var right:String = getRightHandSide(line, left[1] + 1);
						if (right.length == 0) continue;
						
						m_statements.push(new Statement(left[0], right));
					}
					
					if (onLoad != null)
						onLoad();
				} );
			
			return true;
		}
		
		public function getStatements():Vector.<Statement>
		{
			return m_statements;
		}
		
		
		private function getLeftHandSide(source:String, delimiter:String = '\n'):Array
		{
			var returnValue:String = new String();
			
			var end:uint = 0;
			for (var i:uint = 0, char:String = source.charAt(i); i < source.length && char != delimiter; char = source.charAt(++i), end = i)
				if (char != ' ' && char != '\t' && char != '\n' && char != '\r')
					returnValue = returnValue.concat(char);
			
			return [ returnValue, end ];
		}
		
		private function getRightHandSide(source:String, start:uint = 0):String
		{
			if (source.search('"') != -1)
				return new String(source.substr(start).split('"')[1]).replace(/[\r\n,]+/gim, '');
			return source.substr(start).replace(/[ \s\r\n,]+/gim, '');
		}
		
		
		private var m_statements:Vector.<Statement> = null;
	}
}