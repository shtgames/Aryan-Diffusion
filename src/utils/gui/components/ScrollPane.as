package utils.gui.components 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class ScrollPane extends MovieClip
	{
		public function ScrollPane()
		{
			addChild(m_background);
			resetScrollRect(0, 0);
			addEventListener(MouseEvent.MOUSE_MOVE, mouseMove, true);
			cacheAsBitmap = true;
		}
		
		
		public function resetScrollRect(width:uint, height:uint):void
		{
			scrollRect = new Rectangle(0, 0, width, height);
		}
		
		public function get vertical():Boolean
		{
			return m_vertical;
		}
		
		public function get spacing():uint
		{
			return m_spacing;
		}
		
		public function get scrollSpeed():uint
		{
			return m_scrollSpeed;
		}
		
		public function set vertical(value:Boolean):void
		{
			if (m_vertical == value)
				return;
			m_vertical = value;
			reposition();
		}
		
		public function set spacing(value:uint):void
		{
			if (m_spacing == value)
				return;
			m_spacing = value;
			reposition();
		}
		
		public function set scrollSpeed(value:uint):void
		{
			m_scrollSpeed = value;
		}
		
		
		public override function getChildAt(index:int):DisplayObject
		{
			if (index >= numChildren || index < 0)
				return null;
			return super.getChildAt(index == 0 ? 1 : index);
		}
		
		public override function addChild(child:DisplayObject):DisplayObject
		{
			super.addChild(child);
			reposition();
			return child;
		}
		
		public override function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			super.addChildAt(child, index == 0 ? 1 : index);
			reposition();
			return child;
		}
		
		public override function removeChildren(start:int = 0, end:int = 2147483647):void
		{
			super.removeChildren(start == 0 ? 1 : start, end);
			reposition();
		}
		
		public override function removeChildAt(index:int):DisplayObject
		{
			if (index == 0)
				return null;
			
			const returnValue:DisplayObject = super.removeChildAt(index);
			reposition();
			return returnValue;
		}
		
		public override function removeChild(child:DisplayObject):DisplayObject
		{
			if (child == m_background)
				return null;
			
			const returnValue:DisplayObject = super.removeChild(child);
			reposition();
			return returnValue;
		}
		
		public override function swapChildren(child1:DisplayObject, child2:DisplayObject):void
		{
			if (child1 == m_background || child2 == m_background)
				return;
			
			super.swapChildren(child1, child2);
			reposition();
		}
		
		public override function swapChildrenAt(child1:int, child2:int):void
		{
			if (child1 == 0 || child2 == 0)
				return;
			
			super.swapChildrenAt(child1, child2);
			reposition();
		}
		
		
		private function reposition():void
		{
			var prev:uint = 0;
			for (var i:uint = 1, end:uint = numChildren; i < end; ++i)
			{
				const child:DisplayObject = super.getChildAt(i);
				child.x = m_vertical ? 0 : (prev += child.width + m_spacing) - child.width - m_spacing;
				child.y = m_vertical ? (prev += child.height + m_spacing) - child.height - m_spacing: 0;
				
				if (child.x + child.width > m_maxX)
					m_maxX = child.x + child.width;
				if (child.y + child.height > m_maxY)
					m_maxY = child.y + child.height;
			}
			
			m_background.graphics.clear();
			m_background.graphics.beginFill(0xbbbbbb, 0.25);
			m_background.graphics.drawRect(0, 0, m_maxX, m_maxY);
			m_background.graphics.endFill();
		}
		
		private function mouseMove(event:MouseEvent):void
		{
			if (m_vertical)
			{
				if (m_maxY < scrollRect.height)
					return;
				
				const y_coord:int = localToGlobal(new Point(0, y)).y - y + scrollRect.y;
				var direction:int;
				
				if (event.stageY - y_coord < m_threshold)
					direction = 1;
				else if (event.stageY - y_coord > scrollRect.height - m_threshold)
					direction = -1;
				else return;
				
				scrollRect = new Rectangle(scrollRect.x, scrollRect.y - direction * m_scrollSpeed < 0 ?
						0 : (scrollRect.y - direction * m_scrollSpeed > m_maxY - scrollRect.height ? m_maxY - scrollRect.height + 1 : scrollRect.y - direction * m_scrollSpeed),
					scrollRect.width, scrollRect.height);
			}
			else
			{
				if (m_maxX < scrollRect.width)
					return;
				
				const x_coord:int = localToGlobal(new Point(x)).x - x + scrollRect.x;
				var direction:int;
				
				if (event.stageX - x_coord < m_threshold)
					direction = 1;
				else if (event.stageX - x_coord > scrollRect.width - m_threshold)
					direction = -1;
				else return;
				
				scrollRect = new Rectangle(scrollRect.x - direction * m_scrollSpeed < 0 ? 0 : (scrollRect.x - direction * m_scrollSpeed > m_maxX - scrollRect.width ?
						m_maxX - scrollRect.width + 1 : scrollRect.x - direction * m_scrollSpeed),
					scrollRect.y, scrollRect.width, scrollRect.height);
			}
		}
		
		
		private var m_background:Sprite = new Sprite();
		private var m_vertical:Boolean = true;
		private var m_spacing:uint = 3, m_scrollSpeed:uint = 2, m_threshold:uint = 20;
		private var m_maxX:uint = 0, m_maxY:uint = 0;
	}
}