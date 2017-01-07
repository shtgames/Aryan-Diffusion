package ad.map
{
	import flash.concurrent.Mutex;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import ad.map.Map;
	
	use namespace flash_proxy;
	
	public class ConcurrentMap extends Map
	{
		public function ConcurrentMap(other:Map = null)
		{
			assign(other);
		}
		
		public function assign(copy:Map):ConcurrentMap
		{
			return super.assign(copy) as ConcurrentMap;
		}
		
		
		override public function size():uint
		{
			m_mutex.lock();
			const returnValue:uint = m_array.length;
			m_mutex.unlock();
			
			return returnValue;
		}
		
		override public function push(key:*, value:*):ConcurrentMap
		{
			if (key == null) return this;
			
			m_mutex.lock();
			if (!m_keyMap.hasOwnProperty(key))
			{
				m_array.push(value);
				m_keyMap[key] = m_array.length - 1;
			}
			else m_array[m_keyMap[key]] = value;
			m_mutex.unlock();
			
			return this;
		}
		
		override public function at(key:*):*
		{
			if (key == null) return null;
			
			m_mutex.lock();
			if (!m_keyMap.hasOwnProperty(key))
			{
				m_mutex.unlock();
				return null;
			}
			
			const returnValue:* = m_array[m_keyMap[key]];
			m_mutex.unlock();
			
			return returnValue;
		}
		
		override public function contains(key:*):Boolean
		{
			if (key == null) return false;
			
			m_mutex.lock();
			const returnValue:Boolean = m_keyMap.hasOwnProperty(key);
			m_mutex.unlock();
			
			return returnValue;
		}
		
		override public function keyOf(value:*):*
		{			
			m_mutex.lock();
			for (var key:String in m_keyMap)
				if (at(key) == value)
				{
					m_mutex.unlock();
					return key;
				}
			m_mutex.unlock();
			return null;
		}
		
		
		override public function erase(key:String):Boolean
		{
			if (!contains(key)) return false;
			
			m_mutex.lock();
			const affectedIndex:int = m_keyMap[key];
			
			m_array.removeAt(affectedIndex);
			for (var it:String in m_keyMap)
				if (m_keyMap[it] > affectedIndex)
					m_keyMap[it]--;
			
			delete m_keyMap[key];
			m_mutex.unlock();
			
			return true;
		}
		
		override public function clear():ConcurrentMap
		{
			m_mutex.lock();
			m_keyMap = [];
			m_array.length = 0;
			m_mutex.unlock();
			
			return this;
		}
		
		
		override flash_proxy function nextName(index:int):String
		{
			m_mutex.lock();
			for (var key:String in m_keyMap)
				if (m_keyMap[key] == index - 1)
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
		
		
		private var m_mutex:Mutex = new Mutex();
	}
}