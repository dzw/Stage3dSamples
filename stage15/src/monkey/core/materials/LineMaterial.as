package monkey.core.materials {

	import monkey.core.materials.shader.LineShader;

	public class LineMaterial extends Material3D {
		
		public function LineMaterial() {
			super();
			this.shader = LineShader.instance;
			this.blendMode = BLEND_ALPHA;
		}
	}
}
