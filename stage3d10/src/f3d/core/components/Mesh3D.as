package f3d.core.components {
	
	import f3d.core.base.Surface3D;

	/**
	 * mesh渲染器 
	 * @author Neil
	 * 
	 */	
	public class Mesh3D extends Component3D {
		
		public var surfaces : Vector.<Surface3D>;
		
		public function Mesh3D(surfaces : Vector.<Surface3D>) {
			super();
			this.surfaces = surfaces;
		}
		
	}
}
