package ide.panel {

	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import L3D.core.base.Bone3D;
	import L3D.core.base.Pivot3D;
	import L3D.core.camera.Camera3D;
	import L3D.core.entities.Mesh3D;
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.light.Light3D;
	import L3D.core.scene.Scene3D;

	public class Gizmo extends Sprite {
		
		public var pivot : Pivot3D;
		public var w	 : int;
		
		private var _icon 	  : MovieClip;
		private var _selected : Boolean = false;
		
		public function Gizmo(pivot : Pivot3D) {
			super();
			
			this.pivot = pivot;
			this._icon = new McIcons();
			
			if (pivot is Particles3D) {
				this._icon.gotoAndStop(7);
			} else if (pivot is Mesh3D) {
				this._icon.gotoAndStop(1);
			} else if (pivot is Light3D) {
				this._icon.gotoAndStop(11);
			} else if (pivot is Camera3D) {
				this._icon.gotoAndStop(4);
			} else if (pivot is Scene3D) {
				this._icon.gotoAndStop(6);
			} else if (pivot is Bone3D) {
				this._icon.gotoAndStop(10);
			} else {
				this._icon.gotoAndStop(2);
			}
			this._icon.mouseEnabled  = false;
			this._icon.mouseChildren = false;
			this.addChild(this._icon);
			this.draw();
		}
		
		public function draw() : void {
			graphics.clear();
			graphics.lineStyle(1, (this.selected ? 0xFFCB00 : 0x909090), 0.75, true);
			graphics.beginFill(0x202020, 0.6);
			graphics.drawRect(-10, -10, 20, 20);
		}
		
		override public function toString() : String {
			return super.toString() + ":" + this.pivot.name;
		}
		
		public function get selected() : Boolean {
			return this._selected;
		}

		public function set selected(selected : Boolean) : void {
			this._selected = selected;
			this.draw();
		}
		
	}
}
