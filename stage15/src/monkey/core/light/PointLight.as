package monkey.core.light {
	import flash.events.Event;

	public class PointLight extends Light3D {
		
		private var _radius 	: Number;
		private var _multiplier : Number;
		
		public function PointLight() {
			super();
			this.radius 	= 100;
			this.multiplier = 1;
		}
		
		public function get multiplier():Number {
			return _multiplier;
		}
		
		/**
		 * 强度 
		 * @param value
		 * 
		 */		
		public function set multiplier(value:Number):void {
			this._multiplier = value;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get radius():Number {
			return _radius;
		}
		
		/**
		 * 半径 
		 * @param value
		 * 
		 */		
		public function set radius(value:Number):void {
			this._radius = value;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
	}
}
