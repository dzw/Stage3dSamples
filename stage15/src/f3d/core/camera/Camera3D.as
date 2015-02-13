package f3d.core.camera {

	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	
	import f3d.core.base.Object3D;
	import f3d.core.camera.lens.Lens3D;
	import f3d.core.components.Transform3D;

	/**
	 * 相机 
	 * @author Neil
	 * 
	 */	
	public class Camera3D extends Object3D {
		
		public var clip : Boolean;
				
		private var _lens 			: Lens3D;
		private var _viewProjection : Matrix3D;
		private var _projDirty		: Boolean;				// projection dirty
		private var _viewProjDirty	: Boolean;				// view projection dirty
		
		public function Camera3D(lens : Lens3D) {
			super();
			this._projDirty = true;
			this._viewProjDirty = true;
			this._viewProjection = new Matrix3D();
			this.lens = lens;
			this.lens.addEventListener(Lens3D.PROJECTION_UPDATE, onLensProjChanged);
			this.transform.addEventListener(Transform3D.UPDATE_TRANSFORM, onUpdateTransform);
		}
		
		private function onUpdateTransform(event:Event) : void {
			this._viewProjDirty = true;
		}
		
		/**
		 * 镜头更新 
		 * @param event
		 * 
		 */		
		private function onLensProjChanged(event:Event) : void {
			this._projDirty = true;
		}
		
		/**
		 * 镜头 
		 * @return 
		 * 
		 */		
		public function get lens():Lens3D {
			return _lens;
		}

		public function set lens(value:Lens3D):void {
			if (this._lens) {
				this._lens.removeEventListener(Lens3D.PROJECTION_UPDATE, onLensProjChanged);
			}
			this._lens = value;
			this._lens.addEventListener(Lens3D.PROJECTION_UPDATE, onLensProjChanged);
		}
		
		/**
		 * 投影矩阵 
		 * @return 
		 * 
		 */		
		public function get projection() : Matrix3D {
			return _lens.projection;
		}
		
		/**
		 * view 
		 * @return 
		 * 
		 */		
		public function get view() : Matrix3D {
			return transform.invWorld;
		}
		
		/**
		 * view projection 
		 * @return 
		 * 
		 */		
		public function get viewProjection() : Matrix3D {
			if (this._projDirty || this._viewProjDirty) {
				this._projDirty = false;
				this._viewProjDirty = false;
				this._viewProjection.copyFrom(view);
				this._viewProjection.append(projection);
			}
			return this._viewProjection;
		}
		
		public function get near() : Number {
			return this._lens.near;
		}
		
		public function set near(value : Number) : void {
			this._lens.near = value;
		}
		
		public function get far() : Number {
			return this._lens.far;
		}
		
		public function set far(value : Number) : void {
			this._lens.far = value;
		}
		
		public function set viewPort(rect : Rectangle) : void {
			this._lens.setViewPort(rect.x, rect.y, rect.width, rect.height);
		}
		
		public function get viewPort() : Rectangle {
			return this._lens.viewPort;
		}
				
		
		
	}
}
