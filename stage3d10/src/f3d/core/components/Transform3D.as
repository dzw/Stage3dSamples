package f3d.core.components {

	import flash.geom.Matrix3D;
	
	import f3d.core.base.Object3D;

	public class Transform3D extends Component3D {
		
		private var _local 		: Matrix3D;		// 本地transform
		private var _world 		: Matrix3D;		// 世界transform
		private var _invWorld	: Matrix3D;		// inv world
		private var _worldDirty : Boolean;		
		
		public function Transform3D() {
			this._local 	 = new Matrix3D();
			this._world 	 = new Matrix3D();
			this._invWorld   = new Matrix3D();
			this._worldDirty = true;
		}
		
		override public function onAdd(master : Object3D) : void {
			super.onAdd(master);
			this._worldDirty = true;
		}
		
		override public function onRemove(master : Object3D) : void {
			super.onRemove(master);
		}
		
		/**
		 * local 
		 * @return 
		 * 
		 */		
		public function get local() : Matrix3D {
			return _local;
		}
		
		/**
		 * world
		 * @return 
		 * 
		 */		
		public function get world() : Matrix3D {
			this._world.copyFrom(local);
			if (object3D.parent) {
				this._world.append(object3D.parent.transform.world);
			}
			return _world;
		}
		
		public function get invWorld() : Matrix3D {
			_invWorld.copyFrom(world);
			_invWorld.invert();
			return _invWorld
		}

	}
}
