package ad.scenario.event 
{
	import flash.concurrent.Mutex;
	
	public final class EventDispatcher 
	{
		public static function pollEvent(event:Event):void
		{
			processEvent(event);
			
			if (processing)
				return;
			
			eventQueueLock.lock();
			for (var index:uint = 0; index < eventQueue.length; ++index)
				processEvent(eventQueue[index]);
			eventQueue.length = 0;
			eventQueueLock.unlock();
			
			listenersLock.lock();
			for (var index:uint = 0; index < listeners.length; ++index)
				if (listeners[index].dispose)
					listeners.removeAt(index--);
			listenersLock.unlock();
		}
		
		public static function addListener(listener:EventListener):void
		{
			if (listener == null) return;
			
			listenersLock.lock();
			listeners.push(listener);
			listenersLock.unlock();
		}
		
		private static function processEvent(event:Event):void
		{
			if (event == null) return;
			
			if (processing)
			{
				eventQueueLock.lock();
				eventQueue.push(event);
				eventQueueLock.unlock();
				return;
			}
			
			processing = true;
			listenersLock.lock();
			for (var index:uint = 0; index < listeners.length; ++index)
				if (listeners[index] != null)
					listeners[index].input(event);
				else listeners.removeAt(index--);
			listenersLock.unlock();
			processing = false;
		}
		
		
		private static const listeners:Vector.<EventListener> = new Vector.<EventListener>(), eventQueue:Vector.<Event> = new Vector.<Event>();
		private static const listenersLock:Mutex = new Mutex(), eventQueueLock:Mutex = new Mutex();
		private static var processing:Boolean = false;
	}
}