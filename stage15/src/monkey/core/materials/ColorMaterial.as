package monkey.core.materials {

	import monkey.core.interfaces.IComponent;
	import monkey.core.materials.shader.ColorShader;
	import monkey.core.scene.Scene3D;

	public class ColorMaterial extends Material3D {

		private var _color 	: uint;
		private var _red 	: Number;
		private var _green 	: Number;
		private var _blue 	: Number;

		public function ColorMaterial(color : uint = 0xFFFFFF) {
			super();
			this.color  = color;
			this.shader = ColorShader.instance; 
		}
		
		public function get color() : uint {
			return _color;
		}

		public function set color(value : uint) : void {
			_color 	= value;
			_blue 	= (value & 0xFF) / 0xFF;
			_green 	= ((value >> 8) & 0xFF) / 0xFF;
			_red 	= ((value >> 16) & 0xFF) / 0xFF;
		}

		override public function clone() : IComponent {
			var c : ColorMaterial = new ColorMaterial(color);
			return c;
		}
		
		override protected function updateMaterial(scene : Scene3D) : void {
			ColorShader(shader).setColor(_red, _green, _blue);
		}
		
	}
}
