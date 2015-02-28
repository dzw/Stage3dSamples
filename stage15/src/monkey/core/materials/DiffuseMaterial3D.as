package monkey.core.materials {

	import monkey.core.textures.Texture3D;
	import monkey.core.scene.Scene3D;
	import monkey.core.shader.filters.TextureMapFilter;

	/**
	 * diffuse材质 
	 * @author Neil
	 * 
	 */	
	public class DiffuseMaterial3D extends Material3D {
		
		private var textureMapFilter : TextureMapFilter;
		
		public function DiffuseMaterial3D(texture : Texture3D) {
			this.textureMapFilter = new TextureMapFilter(texture);
			this.shader.twoSided = true;
		}
		
		override public function onDraw(scene:Scene3D):void {
			super.onDraw(scene);
		}
		
	}
}
