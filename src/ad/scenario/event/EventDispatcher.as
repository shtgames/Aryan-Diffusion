package ad.scenario.event 
{
	import flash.concurrent.Mutex;
	
	public final class EventDispatcher 
	{
		public static function pollEvent(event:Event):void
		{
			if (event == null) return;
			
			mutex.lock();
			for each (var listener:EventListener in listeners)
				if (listener != null)
					listener.input(event);
			mutex.unlock();
		}
		
		public static function addListener(listener:EventListener):void
		{
			if (listener == null) return;
			mutex.lock();
			listeners.push(listener);
			mutex.unlock();
		}
		
		
		private static const listeners:Vector.<EventListener> = new Vector.<EventListener>();
		private static const mutex:Mutex = new Mutex();
	}
}