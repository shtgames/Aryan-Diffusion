package ad.event 
{
	import ad.event.EventType;
	import ad.map.Map;
	
	public class Event 
	{
		public function Event(eventType:EventType, eventData:Map)
		{
			type = eventType;
			data = eventData;
		}
		
		public function isValid():Boolean
		{
			return type != null && data != null;
		}
		
		public var type:EventType = null;
		public var data:Map = null;
	}
}