package f3d.core.shader.utils {
	
	import flash.display3D.textures.Texture;

	public class FsRegisterLabel {
		
		public var fs 		: ShaderRegisterElement;
		public var texture 	: Texture;
		
		public function FsRegisterLabel(fs : ShaderRegisterElement, texture : Texture) {
			this.fs 		= fs;
			this.texture	= texture;
		}
	}
}
