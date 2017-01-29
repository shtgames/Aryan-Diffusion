package ad.scenario.event 
{
	import ad.scenario.event.EventType;
	import ad.map.Map;
	
	public class Event
	{
		public function Event(eventType:EventType, eventData:Map)
		{
			type = eventType;
			data = eventData;
		}
		
		
		public function toString():String
		{
			return (type != null ? type.toString() : "N/A") + ": " + (data != null ? data.toString() : "N/A");
		}
		
		public function isValid():Boolean
		{
			return type != null && data != null;
		}		
		
		public var type:EventType = null;
		public var data:Map = null;
	}
}