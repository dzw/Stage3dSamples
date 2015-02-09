package f3d.core.camera {

	import flash.geom.Matrix3D;
	
	import f3d.core.base.Object3D;
	import f3d.core.camera.lens.Lens3D;

	/**
	 * 相机 
	 * @author Neil
	 * 
	 */	
	public class Camera3D extends Object3D {
		
		private var _lens : Lens3D;
		private var _viewProjection : Matrix3D;
				
		public function Camera3D(lens : Lens3D) {
			super();
			this.lens = lens;
			this._viewProjection = new Matrix3D();
		}
		
		public function get viewProjection() : Matrix3D {
			_viewProjection.copyFrom(transform.world);
			_viewProjection.invert();
			_viewProjection.append(lens.projection);
			return _viewProjection;
		}
				
		public function get lens():Lens3D {
			return _lens;
		}

		public function set lens(value:Lens3D):void {
			_lens = value;
		}
		
		public function get projection() : Matrix3D {
			return _lens.projection;
		}
		
		public function get view() : Matrix3D {
			return transform.invWorld;
		}

	}
}
