package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import f3d.core.base.Object3D;
	import f3d.core.base.Texture3D;
	import f3d.core.components.MeshFilter;
	import f3d.core.loader.OBJLoader;
	import f3d.core.materials.DiffuseMaterial3D;
	import f3d.core.scene.Scene3D;
	import f3d.core.textures.Bitmap2DTexture;
	
	public class Main extends Sprite {
		
		private var scene : Scene3D;
		
		[Embed(source="1.jpg")]
		private var IMG : Class;
		[Embed(source="123.obj", mimeType="application/octet-stream")]
		private var OBJ : Class;
		
		public function Main() {
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			
			this.scene = new Scene3D(this.stage);
			this.scene.background = 0x333333;
			
			this.scene.camera.transform.x = 0;
			this.scene.camera.transform.y = 100;
			this.scene.camera.transform.z = -100;
			this.scene.camera.transform.lookAt(0, 0, 0);
			
			this.scene.addEventListener(Scene3D.CREATE, onCreate);
		}
		
		private function onCreate(event:Event) : void {
			scene.context3d.enableErrorChecking = true;
			// 贴图
			var texture : Texture3D = new Bitmap2DTexture(new IMG().bitmapData);
			texture.upload(scene);
			// 模型
			var objLoader : OBJLoader = new OBJLoader();
			objLoader.loadBytes(new OBJ());
			
			var obj : Object3D = new Object3D();
			obj.addComponent(new MeshFilter([objLoader.surface]));
			obj.addComponent(new DiffuseMaterial3D(texture));
			// add to scene
			this.scene.addChild(obj);
		}
				
	}
}
