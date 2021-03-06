package monkey.core.entities.primitives.particles.prop.color {
	
	import flash.geom.Vector3D;

	/**
	 * 常量颜色
	 * @author Neil
	 *
	 */
	public class PropConstColor extends PropColor {
		
		private var _color : uint;	// 颜色

		public function PropConstColor() {
			super();
			this.color = 0xFFFFFF;
		}
		
		public function get color() : uint {
			return _color;
		}

		public function set color(value : uint) : void {
			if (value == _color) {
				return;
			}
			this._color  = value;
			this._rgba.z = (color & 0xFF) / 0xFF;
			this._rgba.y = ((color >> 8) & 0xFF) / 0xFF;
			this._rgba.x = ((color >> 16) & 0xFF) / 0xFF;
		}
		
		override public function getRGBA(x : Number) : Vector3D {
			return _rgba;
		}
		
	}
}
