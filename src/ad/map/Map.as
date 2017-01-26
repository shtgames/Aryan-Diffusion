package ad.map
{
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	use namespace flash_proxy;
	
	public class Map extends Proxy
	{
		public function Map(other:Map = null)
		{
			assign(other);
		}
		
		public function assign(copy:Map):Map
		{
			if (copy == null) return this;
			
			clear();
			for (var key:String in copy)
				push(key, copy.at(key));
			
			return this;
		}
		
		
		public function size():uint
		{
			return m_array.length;
		}
		
		public function empty():Boolean
		{
			return size() == 0;
		}
		
		
		public function push(key:*, value:*):Map
		{
			if (key == null) return this;
			
			if (!m_keyMap.hasOwnProperty(key))
			{
				m_array.push(value);
				m_keyMap[key] = m_array.length - 1;
			}
			else m_array[m_keyMap[key]] = value;
			
			return this;
		}
		
		public function at(key:*):*
		{
			if (key == null || !m_keyMap.hasOwnProperty(key))
				return null;
			
			return m_array[m_keyMap[key]];
		}
		
		public function contains(key:*):Boolean
		{
			if (key == null) return false;
			return m_keyMap.hasOwnProperty(key);
		}
		
		public function keyOf(value:*):*
		{
			for (var key:String in m_keyMap)
				if (at(key) == value)
					return key;
			return null;
		}
		
		
		public function erase(key:String):Boolean
		{
			if (!contains(key)) return false;
			
			const affectedIndex:int = m_keyMap[key];
			
			m_array.removeAt(affectedIndex);
			for (var it:String in m_keyMap)
				if (m_keyMap[it] > affectedIndex)
					m_keyMap[it]--;
			
			delete m_keyMap[key];
			
			return true;
		}
		
		public function clear():Map
		{
			m_keyMap = [];
			m_array.length = 0;
			
			return this;
		}		
		
		public function swap(other:Map):Map
		{
			if (other == null) return this;
			
			const buffer:Map = new Map(this);
			assign(other);
			other.assign(buffer);
			
			return this;
		}
		
		
		override flash_proxy function nextNameIndex(index:int):int
		{
			if (index < size())
				return index + 1;
			return 0;
		}
		
		override flash_proxy function nextName(index:int):String
		{
			for (var key:String in m_keyMap)
				if (m_keyMap[key] == index - 1)
					return key;
			
			return null;
		}
		
		override flash_proxy function nextValue(index:int):*
		{
			return m_array[index - 1];
		}
		
		override flash_proxy function getProperty(key:*):*
		{
			return at(key);
		}
		
		
		protected var m_keyMap:Object = new Object();
		protected var m_array:Vector.<*> = new Vector.<*>();
	}
}