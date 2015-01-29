package f3d.core.materials.filters {
	import f3d.core.materials.utils.ShaderRegisterCache;
	
	

	public class Filter3D {
		
		public var name : String;
		
		public function Filter3D(name : String = "Filter3D") {
			this.name = name;
		}
		
		/**
		 * 获取片段程序代码
		 * @param regCache		寄存器管理器
		 * @param agal			是否拼接agal
		 * @return 				code
		 * 
		 */		
		public function getFragmentCode(regCache : ShaderRegisterCache, agal : Boolean) : String {
			return '';
		}
		
		/**
		 * 获取顶点程序代码 
		 * @param regCache		寄存器管理器
		 * @param agal			是否拼接agal
		 * @return 				code
		 * 
		 */		
		public function getVertexCode(regCache : ShaderRegisterCache, agal : Boolean) : String {
			return '';
		}
		
	}
}
