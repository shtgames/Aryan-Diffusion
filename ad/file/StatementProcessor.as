package ad.file 
{
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import ad.file.Statement;
	
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
			if (path == null)
			{
				m_path = null;
				return false;				
			}
			m_path = path;
			
			var loader:URLLoader = new URLLoader();
			loader.load(new URLRequest(m_path));
			
			
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent) : void
				{
					m_statements = null;
					trace("Failed to load file \"" + m_path + "\".");
				});
			
			loader.addEventListener(Event.COMPLETE, function(e:Event) : void 
				{
					var file:String = new String(loader.data);
					var lines:Vector.<String> = splitStatements(file);
					if (lines == null) return;
					
					m_statements = new Vector.<Statement>();
					
					for each (var line:String in lines)
					{
						const statement:Statement = getNextStatement(line);
						if (statement != null)
							m_statements.push(statement);
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
		
		
		private function getNextStatement(source:String):Statement
		{
			if (source == null) return null;
			
			var left:Array = getLeftHandSide(source, '=');
			if (left[0].length == 0) return null;
			
			var returnValue:Statement = new Statement();
			returnValue.left = left[0];
			source = source.substr(left[1] + 1);
			
			const nextChar:String = getNextChar(source);
			if (nextChar == '{')
			{
				const data:String = getContentWithinBrackets(source);				
				if (data == null) return null;
				
				const statements:Vector.<String> = splitStatements(data);
				if (statements == null) return null;
				
				for each (var value:String in statements)
					if (value == null || value.length == 0)
						continue;
					else if (value.search('=') != -1)
					{
						const statement:Statement = getNextStatement(value);
						if (statement != null) returnValue.statements.push(statement);
					}
					else if (value.search('"') != -1)
						returnValue.strings.push(String(value.split('"')[1]).replace(/[\r\n,]+/gim, ''));
					else returnValue.strings.push(value.replace(/[ \s\r\n,]+/gim, ''));
			}
			else if (nextChar == '"')
				returnValue.strings.push( String(source.split('"')[1])
					.replace(/[\r\n]+/gim, ''));
			else returnValue.strings.push( source.replace(/[ \t\r\n,]+/gim, '') );
			
			return returnValue;
		}
		
		private function getNextChar(source:String):String
		{
			if (source == null) return '\0';
			
			for (var i:uint = 0; i < source.length; ++i)
			{
				const char:String = source.charAt(i);
				if (char != null && char != ' ' && char != '\t' && char != '\r' && char != '\n')
					return char;
			}
			return '\0';
		}
		
		private function getLeftHandSide(source:String, delimiter:String = '\n'):Array
		{
			var returnValue:String = new String();
			
			var end:uint = 0;
			for (var i:uint = 0, char:String = source.charAt(i); i < source.length && char != delimiter; char = source.charAt(++i), end = i)
				if (char != null && char != ' ' && char != '\t' && char != '\n' && char != '\r')
					returnValue = returnValue.concat(char);
			
			return [ returnValue, end ];
		}
		
		private function splitStatements(source:String):Vector.<String>
		{
			var statements:Vector.<String> = new Vector.<String>();
			var brackets:uint = 0;
			
			for (var i:uint = 0, start:uint = 0;  i < source.length; ++i)
			{
				const char:String = source.charAt(i);
				if (char == '{') brackets++;
				else if (char == '}') 
				{
					if (brackets == 0)
					{
						trace("Syntax error in file \"" + m_path + "\".\nError while reading block: \"" + source + "\".");
						return null;
					}
					brackets--;
					if (brackets == 0)					
					{
						statements.push( source.substring(start, i + 1).replace(/[\r\n]+/gim, '') );
						start = i + 1;
						
						if (statements[statements.length - 1].length == 0)
							statements.pop();
					}
				}
				else if (char == ';' && brackets == 0)
				{
					statements.push( source.substring(start, i + 1).replace(/[\r\n]+/gim, '') );
					start = i + 1;
					
					if (statements[statements.length - 1].length == 0)
						statements.pop();
				}
			}
			
			return statements;
		}
		
		private function getContentWithinBrackets(source:String):String
		{
			var brackets:uint = 0;
			
			for (var i:uint = 0, start:uint = 0;  i < source.length; ++i)
			{
				const char:String = source.charAt(i);
				if (char == '{')
				{
					if (brackets == 0)
						start = i + 1;
					brackets++;
				}
				else if (char == '}') 
				{
					if (brackets == 0)
					{
						trace("Syntax error in file \"" + m_path + "\"\nError while parsing block: \"" + source + "\".");
						return null;
					}
					brackets--;
					if (brackets == 0)					
						return source.substring(start, i).replace(/[\r\n]+/gim, '');
				}
			}
			
			return null;
		}
		
		
		private var m_statements:Vector.<Statement> = null;
		private var m_path:String = "";
	}
}