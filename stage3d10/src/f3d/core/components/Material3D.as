package f3d.core.components {
	
	import f3d.core.base.Object3D;
	import f3d.core.interfaces.IComponent;
	import f3d.core.materials.Shader3D;

	public class Material3D extends Component3D {
		
		/** shader */
		public var shader : Shader3D;
		// mesh
		private var mesh : Mesh3D;
		
		public function Material3D(shader : Shader3D = null) {
			super();
			this.shader = shader;
		}
		
		override public function onAdd(master:Object3D):void {
			super.onAdd(master);
			this.mesh = this.object3D.getComponent(Mesh3D) as Mesh3D;
		}
		
		override public function onOtherComponentAdd(component:IComponent):void {
			super.onOtherComponentAdd(component);
			if (component is Mesh3D) {
				this.mesh = this.object3D.getComponent(Mesh3D) as Mesh3D;				
			}
		}
		
		override public function onOtherComponentRemove(component:IComponent):void {
			super.onOtherComponentRemove(component);
			if (component is Mesh3D) {
				this.mesh = null;
			}
		}
		
		override public function onRemove(master:Object3D):void {
			super.onRemove(master);
			this.mesh = null;
		}
		
		override public function onDraw() : void {
			
		}
		
	}
}
