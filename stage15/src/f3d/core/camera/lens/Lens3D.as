package f3d.core.camera.lens {

	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	
	import f3d.core.event.LensEvent;

	[Event(name="PROJECTION_UPDATE", type="f3d.core.event.LensEvent")]
	
	
	public class Lens3D extends EventDispatcher {
	
		protected static const projectionEvent : LensEvent = new LensEvent(LensEvent.PROJECTION_UPDATE);
		
		protected var _projection 	: Matrix3D;			// 投影矩阵
		protected var _viewPort   	: Rectangle;		// 相机视口
		protected var _near		  	: Number;			// 近裁面
		protected var _far		  	: Number;			// 远裁面
		protected var _projDirty  	: Boolean;			// 
		protected var _invProjDirty	: Boolean;			
		protected var _invProjection: Matrix3D;			// 投影逆矩阵
		
		public function Lens3D() {
			super();
			this._viewPort		= new Rectangle();
			this._projection	= new Matrix3D();
			this._invProjection	= new Matrix3D();
			this._near			= 0.1;
			this._far			= 3000;
			this._projDirty		= true;
			this._invProjDirty  = true;
		}
		
		public function get viewPort():Rectangle {
			return _viewPort;
		}

		
		public function setViewPort(x : int, y : int, width : int, height : int):void {
			if (_viewPort.x == x && _viewPort.y == y && _viewPort.width == width && _viewPort.height == height) {
				return;
			}
			_viewPort.setTo(x, y, width, height);
			invalidateProjection();
		}
		
		public function get far():Number {
			return _far;
		}

		public function set far(value:Number):void {
			if (_far == value) {
				return;
			}
			_far = value;
			invalidateProjection();
		}
		
		public function get invProjection() : Matrix3D {
			if (_invProjDirty) {
				_invProjection.copyFrom(projection);
				_invProjection.invert();
				_invProjDirty = false;
			}
			return _invProjection;
		}
				
		/**
		 * 投影矩阵 
		 * @return 
		 * 
		 */		
		public function get projection() : Matrix3D {
			if (_projDirty) {
				updateProjectionMatrix();
			}
			return _projection;
		}
		
		public function get near() : Number {
			return _near;
		}
				
		public function set near(value : Number) : void {
			if (_near == value) {
				return;
			}
			_near = value;
			invalidateProjection();
		}
		
		protected function invalidateProjection() : void {
			this._projDirty = true;
			this._invProjDirty = true;
		}
		
		/**
		 * 更新投影矩阵 
		 */		
		public function updateProjectionMatrix() : void {
			this._projDirty = false;	
			this._invProjDirty = true;
		}
	}
}
