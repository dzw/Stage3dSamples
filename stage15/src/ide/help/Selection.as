package ide.help {

	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import L3D.core.base.Geometry3D;
	import L3D.core.base.Pivot3D;
	import L3D.core.shader.Shader3D;
	
	import ide.events.SceneEvent;
	import ide.events.SelectionEvent;
	import ide.events.TransformEvent;
	
	import ui.core.App;

	public class Selection {
		
		public static const FPS 			: String = "FirstPerson";
		public static const SPACE_LOCAL 	: String = "local";
		public static const SPACE_GLOBAL	: String = "global";
		
		private var _shader 		: Shader3D;					// shader
		private var _geometry 		: Geometry3D;				// 
		private var _objects 		: Array;					// 所有选中的3d对象
		private var _transformMode 	: String = SPACE_GLOBAL;	// 
		private var _clipboardState : String;					// 剪贴板状态
		private var _clipboard 		: Array;					// 剪贴板
		private var _app 			: App;						// app
		private var _main 			: Pivot3D;					// 选中的pivot
		
		public var aabb : Vector3D = new Vector3D();

		public function Selection(app : App) {
			this._objects = [];
			this._app     = app;
		}
		
		public function get main() : Pivot3D {
			return _main;
		}
		
		public function set main(value : Pivot3D) : void {
			_main = value;
		}

		public function get geometry() : Geometry3D {
			return _geometry;
		}

		public function set geometry(value : Geometry3D) : void {
			_geometry = value;
		}

		public function get shader() : Shader3D {
			return _shader;
		}

		public function set shader(value : Shader3D) : void {
			_shader = value;
		}

		public function get transformMode() : String {
			return _transformMode;
		}

		public function set transformMode(value : String) : void {
			_transformMode = value;
		}
		
		/**
		 * cut 
		 */		
		public function cut() : void {
			if (this._objects.length == 0) {
				return;
			}
			this._clipboardState = "cut";
			this._clipboard      = [];
			var pivot : Pivot3D  = null;
			for each (pivot in this.objects) {
				this._clipboard.push(pivot);
			}
			for each (pivot in this._clipboard) {
				pivot.parent = null;
			}
			this.objects = [];
		}
		
		/**
		 * copy 
		 */		
		public function copy() : void {
			if (this._objects.length == 0) {
				return;
			}
			this._clipboardState = "copy";
			this._clipboard 	 = [];
			var pivot : Pivot3D  = null;
			for each (pivot in this.objects) {
				this._clipboard.push(pivot.clone());
			}
			for each (pivot in this._clipboard) {
				pivot.parent = null;
			}
		}
		
		/**
		 * paste 
		 */		
		public function paste() : void {
			if (this._clipboardState == "cut") {
				var parent : Pivot3D = null;
				if (objects.length >= 1) {
					parent = this.objects[0];
				} else {
					parent = this._app.scene;
				}
				for each (var pivot : Pivot3D in this._clipboard) {
					parent.addChild(pivot);
				}
			}
			if (this._clipboard != null) {
				this.objects = this._clipboard;
			}
			this._clipboardState = "";
			this._clipboard = null;
		}
		
		public function get transform() : Matrix3D {
			var result : Matrix3D = new Matrix3D();
			if (this.main == null) {
				return result;
			}
			switch (this.transformMode) {
				case SPACE_GLOBAL:  {
					result.copyFrom(this.main.world);
					break;
				}
				case SPACE_LOCAL:  {
					result.copyFrom(this.main.transform);
					break;
				}
			}
			return result;
		}
		
		public function set transform(value : Matrix3D) : void {
			if (this.main == null) {
				return;
			}
			switch (this.transformMode) {
				case SPACE_GLOBAL:  {
					this.main.world = value;
					break;
				}
				case SPACE_LOCAL:  {
					this.main.transform.copyFrom(value);
					break;
				}
			}
			this.main.updateTransforms(true);
			this._app.dispatchEvent(new TransformEvent(TransformEvent.CHANGE));
		}
		
		public function get objects() : Array {
			if (_objects == null || _objects.length == 0) {
				return [_app.scene];
			}
			return _objects;
		}
		
		public function push(value : Array) : void {
			for each (var pivot : Pivot3D in value) {
				if (this._objects.indexOf(pivot) == -1) {
					this._objects.push(pivot);
				}
			}
			if (value.length >= 1) {
				this.main = value[value.length - 1];
			}
			this._app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE));
		}
		
		public function remove(value : Array) : void {
			for each (var pivot : Pivot3D in value) {
				var idx : int = this._objects.indexOf(pivot);
				if (idx != -1) {
					this._objects.splice(idx, 1);
					if (this.main == pivot) {
						if (this._objects.length == 0) {
							this.main = null;
						} else {
							this.main = this._objects[this._objects.length - 1];
						}
					}
				}
			}
			this._app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE));
		}
		
		public function set objects(value : Array) : void {
			this._objects = [];
			for each (var pivot : Pivot3D in value) {
				if (this._objects.indexOf(pivot) == -1) {
					this._objects.push(pivot);
				}
			}
			if (value.length >= 1) {
				this.main = value[value.length - 1];
			} else {
				this.main = null;
			}
			this._app.dispatchEvent(new SceneEvent(SceneEvent.CHANGE));
			this._app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE));
		}
		
		public function getByClass(glass : Class) : Object {
			var result : Array = [];
			for each (var pivot : Pivot3D in this.objects) {
				if (pivot is glass) {
					result.push(pivot);
				}
			}
			return result;
		}
		
		public function delet() : void {
			if (this.main != null) {
				this.main.parent = null;
			}
			this.objects = [];
		}
	}
}
