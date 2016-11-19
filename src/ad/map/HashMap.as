package ad.map
{
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	use namespace flash_proxy;
	
	public class HashMap extends Proxy
	{
		public function HashMap(copy:HashMap = null)
		{
			assignmentOperator(copy);
		}
		
		public function assignmentOperator(copy:HashMap):HashMap
		{
			if (copy == null) return this;
			
			clear();
			for (var key:String in copy.m_keyToIndex)
				insert(key, copy.at(key));
			
			return this;
		}
		
		
		public function size():uint
		{
			return m_array.length;
		}
		
		public function empty():Boolean
		{
			return m_array.length == 0;
		}
		
		
		public function insert(key:String, value:*):*
		{
			if (key == null) return null;
			
			if (!contains(key))
			{
				m_array.push(value);
				m_keyToIndex[key] = m_array.length - 1;
			}
			else m_array[m_keyToIndex[key]] = value;
			
			return at(key);
		}
		
		public function at(key:String):*
		{
			if (key == null || !m_keyToIndex.hasOwnProperty(key)) return null;
			
			return m_array[m_keyToIndex[key]];
		}
		
		public function contains(key:String):Boolean
		{
			return m_keyToIndex.hasOwnProperty(key);
		}
		
		
		public function erase(key:String):Boolean
		{
			if (!contains(key)) return false;
			
			const affectedIndex:int = m_keyToIndex[key];
			
			m_array.removeAt(affectedIndex);
			for (var it:String in m_keyToIndex)
				if (m_keyToIndex[it] > affectedIndex)
					m_keyToIndex[it]--;
			
			delete m_keyToIndex[key];
			
			return true;
		}
		
		public function clear():HashMap
		{
			m_keyToIndex = new Object();
			m_array = new Vector.<Object>();
			
			return this;
		}
		
		public function swap(other:HashMap):HashMap
		{
			const buffer:HashMap = new HashMap(this);			
			assignmentOperator(other);
			other.assignmentOperator(buffer);
			
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
			for (var key:String in m_keyToIndex)
				if (m_keyToIndex[key] == index - 1)
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
		
		
		private var m_keyToIndex:Object = new Object();
		private var m_array:Vector.<*> = new Vector.<*>();
	}
}