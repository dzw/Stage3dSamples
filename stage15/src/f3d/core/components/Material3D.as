package f3d.core.components {
	
	import f3d.core.base.Surface3D;
	import f3d.core.scene.Scene3D;
	import f3d.core.shader.Shader3D;

	public class Material3D extends Component3D {
		
		/** shader */
		public var shader : Shader3D;
		
		public function Material3D(shader : Shader3D = null) {
			super();
			this.shader = shader;
		}
		
		override public function onDraw(scene : Scene3D) : void {
			var mesh : MeshFilter = object3D.getComponent(MeshFilter) as MeshFilter;
			if (!shader || !mesh) {
				return;
			}
			for each (var surf : Surface3D in mesh.surfaces) {
				shader.draw(scene, object3D, surf, 0, -1);
			}
		}
		
	}
}
