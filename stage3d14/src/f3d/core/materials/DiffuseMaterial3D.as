package f3d.core.materials {

	import f3d.core.base.Texture3D;
	import f3d.core.components.Material3D;
	import f3d.core.scene.Scene3D;
	import f3d.core.shader.Shader3D;
	import f3d.core.shader.filters.TextureMapFilter;

	public class DiffuseMaterial3D extends Material3D {
		
		private var textureMapFilter : TextureMapFilter;
		private var texture : Texture3D;
		
		public function DiffuseMaterial3D(texture : Texture3D) {
			this.texture = texture;
			this.textureMapFilter = new TextureMapFilter(texture);
			super(new Shader3D([textureMapFilter]));
			this.shader.blendMode = Shader3D.BLEND_ADDITIVE;
		}
		
		override public function onDraw(scene:Scene3D):void {
			super.onDraw(scene);
		}
		
	}
}
