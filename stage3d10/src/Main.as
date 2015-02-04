package {

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Vector3D;
	
	import f3d.core.base.Object3D;
	import f3d.core.components.MeshFilter;
	import f3d.core.event.Scene3DEvent;
	import f3d.core.loader.OBJLoader;
	import f3d.core.materials.DiffuseMaterial3D;
	import f3d.core.scene.Scene3D;
	import f3d.core.shader.Shader3D;
	
	public class Main extends Sprite {
		
		private var context3D 	: Context3D;
		private var shader		: Shader3D;
		private var texture		: Texture;
		private var scene 		: Scene3D;
		
		[Embed(source="1.jpg")]
		private var IMG : Class;
		[Embed(source="123.obj", mimeType="application/octet-stream")]
		private var OBJ : Class;
		
		public function Main() {
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
						
			this.scene = new Scene3D(this.stage);
			this.scene.background = 0x333333;
			this.scene.camera.transform.local.position = new Vector3D(0, 0, -100);
			this.scene.addEventListener(Scene3DEvent.CREATE, onCreate);
		}
		
		private function onCreate(event:Event) : void {
			
			texture = scene.context3d.createTexture(1024, 1024, Context3DTextureFormat.BGRA, false);
			var bmp : BitmapData = new IMG().bitmapData;
			var ws : int = bmp.width;
			var hs : int = bmp.height;
			var level : int = 0;
			var tmp   : BitmapData = null;
			var transform : Matrix = new Matrix();
			tmp = new BitmapData(ws, hs, true, 0x00000000);
			while (ws >= 1 && hs >= 1) { 
				tmp.draw(bmp, transform, null, null, null, true); 
				texture.uploadFromBitmapData(tmp, level);			// 上传略缩版贴图
				trace("尺寸:", tmp.width, tmp.height, "mip:", level);
				transform.scale(0.5, 0.5);							// 缩放图片
				level++;
				ws >>= 1;
				hs >>= 1;
				if (hs && ws) {
					tmp.dispose();
					tmp = new BitmapData(ws, hs, true, 0x00000000);
				}
			}
			tmp.dispose();
						
			var objLoader : OBJLoader = new OBJLoader();
			objLoader.loadBytes(new OBJ());
			
			var obj : Object3D = new Object3D();
			obj.addComponent(new MeshFilter([objLoader.surface]));
			obj.addComponent(new DiffuseMaterial3D(texture));
			
			
			this.scene.addChild(obj);
			trace(this.scene.camera.view.rawData);
		}
		
	}
}
