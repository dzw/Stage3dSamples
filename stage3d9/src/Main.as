package {

	import com.adobe.utils.PerspectiveMatrix3D;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import f3d.core.base.Surface3D;
	import f3d.core.loader.OBJLoader;
	import f3d.core.materials.Shader3D;
	import f3d.core.materials.filters.TextureMapFilter;
	
	public class Main extends Sprite {
		
		private var context3D 		: Context3D;
		private var shader			: Shader3D;
		private var projection 		: PerspectiveMatrix3D = new PerspectiveMatrix3D();
		private var model 			: Matrix3D = new Matrix3D();
		private var view 			: Matrix3D = new Matrix3D();
		private var mvp				: Matrix3D = new Matrix3D();
		private var texture			: Texture;
		private var surface			: Surface3D;
		
		[Embed(source="1.jpg")]
		private var IMG : Class;
		[Embed(source="123.obj", mimeType="application/octet-stream")]
		private var OBJ : Class;
		
		public function Main() {
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;

			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
			stage.stage3Ds[0].requestContext3D(Context3DRenderMode.AUTO, Context3DProfile.BASELINE);
		}

		private function onContext3DCreate(e : Event) : void {
			
			this.context3D = stage.stage3Ds[0].context3D;
			this.context3D.enableErrorChecking = true;
			
			var objLoader : OBJLoader = new OBJLoader();
			objLoader.loadBytes(new OBJ());
			
			this.surface = objLoader.surface;
			this.surface.upload(this.context3D);

			view.appendTranslation(0, 0, -200);
			view.invert();
			
			projection.perspectiveFieldOfViewLH(75, stage.stageWidth / stage.stageHeight, 0.1, 3000);
			
			// 创建纹理
			texture = context3D.createTexture(1024, 1024, Context3DTextureFormat.BGRA, false);
			// 上传mip纹理
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
			
			this.shader = new Shader3D([new TextureMapFilter(texture)]);
						
			context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, true);

			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrame(event : Event) : void {
			context3D.clear(0.2, 0.2, 0.2, 1);
			
			mvp.identity();
			// 让模型绕着z轴旋转
			model.appendRotation(1, Vector3D.Z_AXIS);
			mvp.append(model);
			mvp.append(view);
			mvp.append(projection);
			
			this.shader.draw(context3D, mvp, surface, 0, -1);
			
			context3D.present();
		}
		
	}
}
