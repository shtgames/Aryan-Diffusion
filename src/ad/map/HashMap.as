package ad.map
{
	import flash.concurrent.Mutex;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	use namespace flash_proxy;
	
	public class HashMap extends Proxy
	{
		public function HashMap(other:HashMap = null)
		{
			assign(other);
		}
		
		public function assign(copy:HashMap):HashMap
		{
			if (copy == null) return this;
			
			clear();
			copy.m_mutex.lock();
			for (var key:String in copy.m_keyToIndex)
				insert(key, copy.at(key));
			copy.m_mutex.unlock();
			
			return this;
		}
		
		
		public function size():uint
		{
			m_mutex.lock();
			const returnValue:uint = m_array.length;
			m_mutex.unlock();
			
			return returnValue;
		}
		
		public function empty():Boolean
		{
			return size() == 0;
		}
		
		
		public function insert(key:*, value:*):HashMap
		{
			if (key == null) return this;
			
			m_mutex.lock();
			if (!m_keyToIndex.hasOwnProperty(key))
			{
				m_array.push(value);
				m_keyToIndex[key] = m_array.length - 1;
			}
			else m_array[m_keyToIndex[key]] = value;
			m_mutex.unlock();
			
			return this;
		}
		
		public function at(key:*):*
		{
			if (key == null) return null;
			
			m_mutex.lock();
			if (!m_keyToIndex.hasOwnProperty(key))
			{
				m_mutex.unlock();
				return null;
			}
			
			const returnValue:* = m_array[m_keyToIndex[key]];
			m_mutex.unlock();
			
			return returnValue;
		}
		
		public function contains(key:*):Boolean
		{
			if (key == null) return false;
			
			m_mutex.lock();
			const returnValue:Boolean = m_keyToIndex.hasOwnProperty(key);
			m_mutex.unlock();
			
			return returnValue;
		}
		
		public function keyOf(value:*):*
		{			
			m_mutex.lock();
			for (var key:String in m_keyToIndex)
				if (at(key) == value)
				{
					m_mutex.unlock();
					return key;
				}
			m_mutex.unlock();
			return null;
		}
		
		
		public function erase(key:String):Boolean
		{
			if (!contains(key)) return false;
			
			m_mutex.lock();
			const affectedIndex:int = m_keyToIndex[key];
			
			m_array.removeAt(affectedIndex);
			for (var it:String in m_keyToIndex)
				if (m_keyToIndex[it] > affectedIndex)
					m_keyToIndex[it]--;
			
			delete m_keyToIndex[key];
			m_mutex.unlock();
			
			return true;
		}
		
		public function clear():HashMap
		{
			m_mutex.lock();
			m_keyToIndex = [];
			m_array.length = 0;
			m_mutex.unlock();
			
			return this;
		}		
		
		public function swap(other:HashMap):HashMap
		{
			if (other == null) return this;
			
			const buffer:HashMap = new HashMap(this);			
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
			m_mutex.lock();
			for (var key:String in m_keyToIndex)
				if (m_keyToIndex[key] == index - 1)
				{
					m_mutex.unlock();
					return key;				
				}			
			m_mutex.unlock();
			
			return null;
		}
		
		override flash_proxy function nextValue(index:int):*
		{
			m_mutex.lock();
			const returnValue:* = m_array[index - 1];
			m_mutex.unlock();
			
			return returnValue;
		}
		
		override flash_proxy function getProperty(key:*):*
		{
			return at(key);
		}
		
		
		private var m_keyToIndex:Object = new Object();
		private var m_array:Vector.<*> = new Vector.<*>();
		private var m_mutex:Mutex = new Mutex();
	}
}