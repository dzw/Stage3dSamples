package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import monkey.core.base.Object3D;
	import monkey.core.camera.Camera3D;
	import monkey.core.camera.lens.PerspectiveLens;
	import monkey.core.entities.Axis3D;
	import monkey.core.entities.Capsule;
	import monkey.core.entities.Cone;
	import monkey.core.entities.Cube;
	import monkey.core.entities.DebugBounds;
	import monkey.core.entities.DebugCamera;
	import monkey.core.entities.DebugLight;
	import monkey.core.entities.DebugWireframe;
	import monkey.core.entities.Grid3D;
	import monkey.core.entities.Lines3D;
	import monkey.core.entities.Quad;
	import monkey.core.entities.Sphere;
	import monkey.core.entities.primitives.particles.ParticleSystem;
	import monkey.core.light.PointLight;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.utils.FPSStats;
	import monkey.core.utils.Mesh3DUtils;
	
	public class Main extends Sprite {
		
		private var scene : Scene3D;
		
		[Embed(source="1.jpg")]
		private var IMG : Class;
		[Embed(source="123.obj", mimeType="application/octet-stream")]
		private var OBJ : Class;
		[Embed(source="xiaonan_boo1.mesh", mimeType="application/octet-stream")]
		private var MESH_DATA : Class;
		
		public function Main() {
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align 	 = StageAlign.TOP_LEFT;
			this.stage.frameRate = 60;
			
			this.scene = new Viewer3D(this.stage);
			this.scene.camera.far = 50000;
			this.scene.camera.transform.x = 0;
			this.scene.camera.transform.z = -100;
			this.scene.camera.transform.lookAt(0, 0, 0);
			
			this.scene.addEventListener(Scene3D.CREATE, onCreate);
			
			this.addChild(new FPSStats());
			this.addChild(txt);
			txt.defaultTextFormat = new TextFormat("", 16, 0xFFFFFF);
			txt.autoSize = TextFieldAutoSize.LEFT;
			txt.x = 100;
		}
		
		private function onCreate(event:Event) : void {
			scene.context.enableErrorChecking = true;
//			
//			var lifeTime : PropCurves = new PropCurves();
//			lifeTime.curve.datas.push(new Point(0, 5));
//			lifeTime.curve.datas.push(new Point(3, 5));
//			lifeTime.curve.datas.push(new Point(5, 10));
//			
//			var obj : ParticleSystem = new ParticleSystem();
//			obj.startLifeTime = lifeTime;
//			obj.startDelay = 0;
//			obj.rate = 1;
//			obj.loops = 0;
//			obj.startDelay = 0;
//			obj.gotoAndStop(0);
//			obj.play();
//			obj.addEventListener(Object3D.ENTER_DRAW, onDraw);
//			
//			obj.bursts.push(new Point(5, 100));
//			
//			scene.addChild(obj);
			
			var obj : Object3D = Mesh3DUtils.readMesh(new MESH_DATA());
			obj.addComponent(new ColorMaterial(0xFF00FF));
			scene.addChild(obj);
			
			var line : Lines3D = new Lines3D();
			line.lineStyle(1, 0xFF0000, 1);
			line.moveTo(0, 0, 0);
			line.lineTo(50, 0, 0);
			line.lineStyle(1, 0xFFFF00, 1);
			line.lineTo(50, 50, 0);
			scene.addChild(line);
			scene.addChild(new DebugBounds(obj));
			scene.addChild(new DebugCamera(new Camera3D(new PerspectiveLens())));
			scene.addChild(new DebugLight(new PointLight()));
			scene.addChild(new DebugWireframe(obj));
			scene.addChild(new Grid3D());
			scene.addChild(new Axis3D());
			
			var capsule : Object3D = new Object3D();
			capsule.addComponent(new Capsule());
			capsule.addComponent(new ColorMaterial());
			scene.addChild(capsule);
			
			var cone : Object3D = new Object3D();
			cone.addComponent(new Cone());
			cone.addComponent(new ColorMaterial());
			scene.addChild(cone);
			
			var cube : Object3D = new Object3D();
			cube.addComponent(new Cube());
			cube.addComponent(new ColorMaterial());
			scene.addChild(cube);
			
			var quad : Object3D = new Object3D();
			quad.addComponent(new Quad(0, 0, 500, 500, false));
			quad.addComponent(new ColorMaterial());
			scene.addChild(quad);
		
			var sphere : Object3D = new Object3D();
			sphere.addComponent(new Sphere(10));
			sphere.addComponent(new ColorMaterial());
			sphere.transform.x = 10;
			scene.addChild(sphere);
		}
		
		private var txt : TextField = new TextField();
		
		protected function onDraw(event:Event) : void {
			txt.text = "" + (event.target as ParticleSystem).time;	
		}
		
	}
}
