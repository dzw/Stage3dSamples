package f3d.core.shader.filters {

	import flash.display3D.textures.Texture;
	
	import f3d.core.base.Surface3D;
	import f3d.core.shader.utils.FsRegisterLabel;
	import f3d.core.shader.utils.ShaderRegisterCache;
	import f3d.core.shader.utils.ShaderRegisterElement;

	public class TextureMapFilter extends Filter3D {

		private var texture : Texture;

		public function TextureMapFilter(texture : Texture) {
			super("TextureMapFilter");
			this.texture = texture;
		}

		/**
		 * 片段程序 
		 * @param regCache		regCache
		 * @param agal			是否创建agal字符串，为优化做准备
		 * @return 
		 * 
		 */		
		override public function getFragmentCode(regCache : ShaderRegisterCache, agal : Boolean) : String {
						
			var fs0 : ShaderRegisterElement = regCache.getFs();
			regCache.fsUsed.push(new FsRegisterLabel(fs0, texture));
			
			var code : String = "";
			if (agal) {
				code += "tex " + regCache.oc + ", " + regCache.getV(Surface3D.UV0) + ", " + fs0 + " <2d, linear, miplinear, repeat>\n";
			}
			return code;
		}

	}
}
