package ide.plugins {
	
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import L3D.core.base.Pivot3D;
	import L3D.core.camera.Camera3D;
	import L3D.core.camera.lenses.PerspectiveLens;
	import L3D.core.entities.primitives.Capsule;
	import L3D.core.entities.primitives.Cone;
	import L3D.core.entities.primitives.Cube;
	import L3D.core.entities.primitives.Cylinder;
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.entities.primitives.Plane;
	import L3D.core.entities.primitives.SkyBox;
	import L3D.core.entities.primitives.Sphere;
	import L3D.core.entities.primitives.Water;
	import L3D.core.light.DirectionalLight;
	import L3D.core.light.PointLight;
	import L3D.core.shader.Shader3D;
	import L3D.core.shader.filters.particle.action.rotation.BillboardAction;
	import L3D.core.shader.filters.particle.action.velocity.VelocityLocalAction;
	import L3D.core.texture.Texture3D;
	import L3D.system.Device3D;
	import L3D.utils.UUID;
	
	import ide.Studio;
	
	import ui.core.App;
	import ui.core.container.Box;
	import ui.core.container.MenuCombox;
	import ui.core.interfaces.IPlugin;

	public class CreatePlugin implements IPlugin {
		
		private var _app : App;
		private var _bar : Box;
		
		public function CreatePlugin() {
			
		}
		
		public function init(app : App) : void {
			this._app = app;
			this._bar = this._app.gui.getPanel(Studio.SCENE_MENU) as Box;
			var menu0 : MenuCombox = new MenuCombox("Create");
			menu0.addMenuItem("Camera", 	createCamera);
			menu0.addMenuItem("Pivot", 		createPivot);
			menu0.addMenuItem("Cube", 		createCube);
			menu0.addMenuItem("Capsule", 	createCapsule);
			menu0.addMenuItem("Cone", 		createCone);
			menu0.addMenuItem("Cylinder", 	createCylinder);
			menu0.addMenuItem("Plane +xz", 	createXZPlane);
			menu0.addMenuItem("Plane +xy", 	createXYPlane);
			menu0.addMenuItem("Plane +yz", 	createYZPlane);
			menu0.addMenuItem("Sphere", 	createSphere);
			menu0.addMenuItem("Particles", 	createParticles);
			menu0.addMenuItem("Water", 		createWater);
			menu0.addMenuItem("PointLight", createPointLight);
			menu0.addMenuItem("DirecLight", createDirectionLight);
			menu0.addMenuItem("SkyBox", 	createSkybox);
			menu0.minWidth = 60;
			menu0.maxWidth = 60;
			this._bar.addControl(menu0);
			this._bar.draw();
		}
		
		private function createDirectionLight(e : MouseEvent) : void {
			var light : DirectionalLight = new DirectionalLight();
			light.name = "DirectionalLight";
			this._app.scene.addChild(light);
		}
		
		private function createSkybox(e : MouseEvent) : void {
			var sky : SkyBox = new SkyBox(Device3D.nullBitmapData.clone(), 1000, 0.8);
			this._app.scene.addChild(sky);
			setTimeout(function():void{
				_app.selection.objects = [sky];
			}, 10);	
		}
		
		private function createWater(e : MouseEvent) : void {
			var water : Water = new Water(new Texture3D(null, false, 0, Texture3D.TYPE_CUBE), new Texture3D(), 3000, 3000, 32);
			this._app.scene.addChild(water);
			setTimeout(function():void{
				_app.selection.objects = [water];
			}, 10);	
		}
		
		private function createYZPlane(e : MouseEvent) : void {
			var plane : Plane = new Plane("plane", 10, 10, 1, null, "+yz");
			this._app.scene.addChild(plane);
			setTimeout(function():void{
				_app.selection.objects = [plane];
			}, 10);	
		}
		
		private function createXYPlane(e : MouseEvent) : void {
			var plane : Plane = new Plane("plane", 10, 10, 1, null, "+xy");
			this._app.scene.addChild(plane);
			setTimeout(function():void{
				_app.selection.objects = [plane];
			}, 10);	
		}
		
		private function createCamera(e : MouseEvent) : void {
			var camera : Camera3D = new Camera3D(new PerspectiveLens());
			camera.viewPort = _app.scene.viewPort;
			this._app.scene.addChild(camera);
			setTimeout(function():void{
				_app.selection.objects = [camera];
			}, 10);			
		}
		
		private function createPointLight(e : MouseEvent) : void {
			var light : PointLight = new PointLight();
			light.name = "PointLight";
			this._app.scene.addChild(light);
		}
		
		private function createParticles(e : MouseEvent) : void {
			var particle : Particles3D = new Particles3D("particle");
			particle.userData.id = UUID.generate();
			particle.userData.textureID = "Defaultadfskjldgfaskd.jpg";
			particle.fps = 60;
			particle.nums = 200;
			particle.minDelay = 0;
			particle.maxDelay = 1;
			particle.maxDuration = 1;
			particle.minDuration = 1;
			particle.addAction(new VelocityLocalAction());
			particle.addAction(new BillboardAction());
			particle.build();
			particle.gotoAndStop(60);
			this._app.scene.addChild(particle);
			setTimeout(function():void{
				_app.selection.objects = [particle];
			}, 10);	
		}
		
		private function createSphere(e : MouseEvent) : void {
			var sphere : Sphere = new Sphere("sphere", 5, 15);
			this._app.scene.addChild(sphere);
			setTimeout(function():void{
				_app.selection.objects = [sphere];
			}, 10);	
		}
		
		private function createXZPlane(e : MouseEvent) : void {
			var plane : Plane = new Plane("plane", 10, 10, 1, null, "+xz");
			this._app.scene.addChild(plane);
			setTimeout(function():void{
				_app.selection.objects = [plane];
			}, 10);	
		}
		
		private function createCylinder(e : MouseEvent) : void {
			var cylinder : Cylinder = new Cylinder("cylinder");
			this._app.scene.addChild(cylinder);
			setTimeout(function():void{
				_app.selection.objects = [cylinder];
			}, 10);	
		}
		
		private function createCone(e : MouseEvent) : void {
			var cone : Cone = new Cone("cone");
			this._app.scene.addChild(cone);
			setTimeout(function():void{
				_app.selection.objects = [cone];
			}, 10);	
		}
		
		private function createPivot(e : MouseEvent) : void {
			var pivot : Pivot3D = new Pivot3D("pivot");
			this._app.scene.addChild(pivot);
			setTimeout(function():void{
				_app.selection.objects = [pivot];
			}, 10);	
		}
		
		private function createCube(e : MouseEvent) : void {
			var cube : Cube = new Cube("cube");
			this._app.scene.addChild(cube);
			setTimeout(function():void{
				_app.selection.objects = [cube];
			}, 10);	
		}
		
		private function createCapsule(e : MouseEvent) : void {
			var capsule : Capsule = new Capsule("capsule");
			this._app.scene.addChild(capsule);
			setTimeout(function():void{
				_app.selection.objects = [capsule];
			}, 10);	
		}
		
		public function start() : void {
			
		}
	}
}
