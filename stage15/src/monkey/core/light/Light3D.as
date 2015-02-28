package monkey.core.light {

	import flash.events.Event;
	
	import monkey.core.base.Object3D;

	public class Light3D extends Object3D {
		
		private var _color 	: uint;
		private var _ambient: uint;
		
		public function Light3D() {
			super();
			this.color 	= 0xffffff;
			this.ambient= 0x333333;
		}
		
		public function get ambient() : uint {
			return _ambient;
		}
		
		/**
		 * 环境光 
		 * @param value
		 * 
		 */		
		public function set ambient(value : uint) : void {
			this._ambient = value;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * 灯光颜色
		 * @return
		 *
		 */
		public function get color() : uint {
			return _color;
		}
		
		/**
		 * 灯光颜色
		 * @param value
		 *
		 */
		public function set color(value : uint) : void {
			this._color = value;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
	}
}
