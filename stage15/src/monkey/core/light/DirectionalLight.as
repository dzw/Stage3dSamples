package monkey.core.light {
	
	import flash.events.Event;

	public class DirectionalLight extends Light3D {
		
		private var _specular : uint = 0x000000;
		private var _power 	  : Number = 50;
		
		public function DirectionalLight() {
			super();
			this.specular = 0x333333;
			this.power    = 50;
		}
		
		public function get power():Number {
			return _power;
		}
		
		public function set power(value:Number):void {
			this._power = value;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get specular():uint {
			return _specular;
		}
		
		public function set specular(value:uint):void {
			this._specular = value;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
	}
}
