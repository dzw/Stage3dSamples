package f3d.core.components {
	
	import f3d.core.base.Surface3D;
	import f3d.core.interfaces.IComponent;

	/**
	 * mesh渲染器 
	 * @author Neil
	 * 
	 */	
	public class MeshFilter extends Component3D implements IComponent {
		
		public var surfaces : Vector.<Surface3D>;
		
		public function MeshFilter(surfaces : Array) {
			super();
			this.surfaces = Vector.<Surface3D>(surfaces);
		}
		
	}
}
