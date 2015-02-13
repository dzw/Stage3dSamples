package f3d.core.camera.lens {


	import f3d.core.scene.Scene3D;
	import f3d.core.utils.Device3D;

	public class PerspectiveLens extends Lens3D {

		private static const rawData : Vector.<Number> = new Vector.<Number>(16, true);

		private var _fieldOfView : Number;
		private var _zoom : Number;
		private var _aspect : Number;
		
		public function PerspectiveLens(fieldOfView : Number = 75) {
			super();

			this._aspect = 1.0;
			this.fieldOfView = fieldOfView;
		}
		
		/**
		 * 横纵比
		 * @return 
		 * 
		 */		
		public function get aspect() : Number {
			return _aspect;
		}
		
		/**
		 * 焦距 
		 * @return 
		 * 
		 */		
		public function get zoom() : Number {
			return _zoom;
		}
		
		public function set zoom(value : Number) : void {
			if (_zoom == value) {
				return;
			}
			_zoom = value;
			_fieldOfView = Math.atan(value) * 360 / Math.PI;
			invalidateProjection();
		}
		
		public function get fieldOfView() : Number {
			return _fieldOfView;
		}
				
		public function set fieldOfView(value : Number) : void {
			if (value == _fieldOfView) {
				return;
			}
			_fieldOfView = value;
			_zoom = Math.tan(value * Math.PI / 360);
			invalidateProjection();
		}
		
		override public function updateProjectionMatrix() : void {
			super.updateProjectionMatrix();

			var w : Number = 0;
			var h : Number = 0;
			var n : Number = this._near;
			var f : Number = this._far;

			var scene : Scene3D = Device3D.scene;

			if (this.viewPort) {
				w = this.viewPort.width;
				h = this.viewPort.height;
			} else if (scene && scene.viewPort) {
				w = scene.viewPort.width;
				h = scene.viewPort.height;
			}

			var a : Number = w / h;
			var y : Number = 1 / this._zoom * a;
			var x : Number = y / a;

			this._aspect = a;

			rawData[0] = x;
			rawData[5] = y;
			rawData[10] = f / (n - f);
			rawData[11] = -1;
			rawData[14] = (f * n) / (n - f);

			if (this._viewPort) {
				if (scene && scene.viewPort) {
					w = scene.viewPort.width;
					h = scene.viewPort.height;
				}
				rawData[0] = (x / (w / this._viewPort.width));
				rawData[5] = (y / (h / this._viewPort.height));
				rawData[8] = (1 - (this._viewPort.width / w)) - ((this._viewPort.x / w) * 2);
				rawData[9] = (-1 + (this._viewPort.height / h)) + ((this._viewPort.y / h) * 2);
			}
			
			this._projection.copyRawDataFrom(rawData);
			this._projection.prependScale(1, 1, -1);

			this.dispatchEvent(projectionEvent);
		}
	}
}
