package f3d.core.materials {

	import flash.display3D.textures.Texture;
	
	import f3d.core.components.Material3D;
	import f3d.core.scene.Scene3D;
	import f3d.core.shader.Shader3D;
	import f3d.core.shader.filters.TextureMapFilter;

	public class DiffuseMaterial3D extends Material3D {
		
		private var textureMapFilter : TextureMapFilter;
		private var texture : Texture;
		
		public function DiffuseMaterial3D(texture : Texture) {
			this.texture = texture;
			this.textureMapFilter = new TextureMapFilter(texture);
			super(new Shader3D([textureMapFilter]));
		}
		
		override public function onDraw(scene:Scene3D):void {
			super.onDraw(scene);
		}
		
	}
}
