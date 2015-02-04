package f3d.core.camera.lens {
	
	
	

	public class PerspectiveLens extends Lens3D {
		
		private var _fieldOfView : Number;
		private var _zoom 		 : Number;
		private var _aspect		 : Number;
		
		public function PerspectiveLens(fieldOfView : Number = 75) {
			super();
			
			this._aspect = 1.0;
			this.fieldOfView = fieldOfView;
		}
		
		public function get aspect():Number {
			return _aspect;
		}

		public function get zoom():Number {
			return _zoom;
		}

		public function set zoom(value:Number):void {
			if (_zoom == value) {
				return;
			}
			_zoom = value;
			_fieldOfView = Math.atan(value) * 360 / Math.PI;
			invalidateProjection();
		}
		
		public function get fieldOfView():Number {
			return _fieldOfView;
		}

		public function set fieldOfView(value:Number):void {
			if (value == _fieldOfView) {
				return;
			}
			_fieldOfView = value;
			_zoom = Math.tan(value * Math.PI / 360);
			invalidateProjection();
		}
		
		override public function updateProjectionMatrix():void {
			super.updateProjectionMatrix();
			
			var w : Number = viewPort.width;
			var h : Number = viewPort.height;
			var n : Number = near;
			var f : Number = far;
			var a : Number = w / h;
			var y : Number = 1 / zoom * a;
			var x : Number = y / a;
			
			_aspect = a;
			
			var rawData : Vector.<Number> = _projection.rawData;
			
			rawData[0] = x;
			rawData[5] = y;
			rawData[10] = f / (n - f);
			rawData[11] = -1;
			rawData[14] = (f * n) / (n - f);
			rawData[15] = 0;
			
			_projection.copyRawDataFrom(rawData);
			_projection.prependScale(1, 1, -1);
			
			this.dispatchEvent(projectionEvent);
		}
	}
}
