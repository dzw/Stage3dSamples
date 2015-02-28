package ide.plugins {

	import flash.display.BitmapData;
	import flash.display3D.Context3DClearMask;
	import flash.display3D.Context3DCompareMode;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	import L3D.collisions.CollisionInfo;
	import L3D.collisions.MouseCollision;
	import L3D.core.base.Pivot3D;
	import L3D.core.camera.Camera3D;
	import L3D.core.camera.lenses.PerspectiveLens;
	import L3D.core.entities.Mesh3D;
	import L3D.core.entities.primitives.Grid3D;
	import L3D.core.entities.primitives.Quad;
	import L3D.core.interfaces.IComponent;
	import L3D.core.scene.Scene3D;
	import L3D.physic.Collider;
	import L3D.system.Device3D;
	import L3D.system.Input3D;
	import L3D.utils.L3DStats;
	import L3D.utils.Vector3DUtils;
	
	import ide.Studio;
	import ide.events.FrameEvent;
	import ide.events.SceneEvent;
	import ide.panel.ScenePanel;
	
	import ui.core.App;
	import ui.core.controls.Control;
	import ui.core.controls.TabControl;
	import ui.core.event.ControlEvent;
	import ui.core.interfaces.IPlugin;

	public class ScenePlugin extends Scene3D implements IPlugin {

		private static const ACTION_NULL 	: String = "action:null";
		private static const ACTION_ORIBIT 	: String = "action:orbit";
		private static const ACTION_PAN 	: String = "action:pan";
		private static const ACTION_ZOOM 	: String = "action:zoom";
		
		private var _scenePanel 	: ScenePanel;
		private var _grid 			: Grid3D;
		private var _stats 			: L3DStats;
		private var _mouse 			: MouseCollision;
		private var _app 			: App;
		private var _preTime 		: int;
		private var _time 			: int;
		private var _lastFrame 		: Number;
		private var _cameraMode 	: String;
		private var _action 		: String;
		private var _orbitPoint 	: Vector3D;
		private var _orbitDistance 	: Number = 300;
		private var _orbitAxis 		: Vector3D;
		private var _rotationSpeedX : Number = 0;
		private var _rotationSpeedY : Number = 0;
		private var _showGrid 		: Boolean;
		private var _mouseMoved 	: Boolean;
		private var _sceneCamera 	: Camera3D;
		private var _postRenderQuad : Quad;
		
		public function ScenePlugin() {

			super(Studio.stage);
			
			this.antialias 		 = 4;
			this.autoResize 	 = false;
			this.enableRender	 = false;
			this.backgroundColor = 0x505050;
			this.camera.parent   = null;
			
			this._postRenderQuad = new Quad("post", 0, 0, 0, 0, true, null);
			this._cameraMode = "orbit";
			this._action = ACTION_NULL;
			this._showGrid = true;
			this._orbitPoint = new Vector3D();
			this._orbitAxis = new Vector3D();
			this._mouse = new MouseCollision();
			this._sceneCamera = new Camera3D(new PerspectiveLens());
			this.camera = this._sceneCamera;
			this.camera.setPosition(50, 100, -200);
			this.camera.lookAt(0, 0, 0);
			this.camera.far = 50000;
			
			this._lastFrame = 0;
			this._grid = new Grid3D();
			
			this._scenePanel = new ScenePanel(this);
			this._scenePanel.background = false;
			this._scenePanel.addEventListener(ControlEvent.CLICK, changeControlEvent);
			this._scenePanel.addEventListener(ControlEvent.CHANGE, changeControlEvent);
			
			this.addEventListener(Event.CONTEXT3D_CREATE, contextCreateEvent);
		}
		
		public function get sceneCamera() : Camera3D {
			return _sceneCamera;
		}
		
		public function get mouse() : MouseCollision {
			return _mouse;
		}
		
		public function get action() : String {
			return _action;
		}

		public function get showGrid() : Boolean {
			return _showGrid;
		}

		public function set showGrid(value : Boolean) : void {
			_showGrid = value;
		}

		public function get lastFrame() : Number {
			return _lastFrame;
		}

		public function set lastFrame(value : Number) : void {
			_lastFrame = value;
		}

		private function changeControlEvent(event : Event) : void {

		}
		
		private function contextCreateEvent(event : Event) : void {
			this.context.enableErrorChecking = true;
			this._scenePanel.update();
			this._scenePanel.draw();
		}
		
		public function init(app : App) : void {
			
			Input3D.rightClickEnabled = true;
			
			this._scenePanel.menuBar.name = Studio.SCENE_MENU;
			
			this._app = app;
			this._app.scene = this;
			this._app.gui.markPanel(this._scenePanel.menuBar);
			
			var pControl : Control = this._app.gui.getPanel(Studio.SCENE_PANEL);
			if (pControl is TabControl) {
				TabControl(pControl).addPanel(this._scenePanel);
				TabControl(pControl).open();
			}
			
			this._app.gui.update();
			this._app.gui.draw();
			this._app.addEventListener(SceneEvent.CHANGE, 	sceneChangeEvent);
			this._app.addEventListener("SCENE_PANEL", 		openPanel);
		}
		
		private function openPanel(event : Event) : void {
			this._scenePanel.open();
		}
		
		private function sceneChangeEvent(event : Event) : void {
			this.upload(this);
			this.forEach(function(mesh : Mesh3D) : void {
				var found : Boolean = false;
				for each (var com : IComponent in mesh.components) {
					if (com is Collider) {
						found = true;
					}
				}
				if (!found) {
					mesh.addComponent(new Collider());
				}
			}, Mesh3D);
			this._mouse.removeCollisionWith(this);
			this._mouse.addCollisionWith(this);
		}
		
		public function start() : void {
			this._preTime = getTimer();
			this._time 	  = 0;
			this._app.selection.objects = [this];
			this._scenePanel.addEventListener(FrameEvent.CHANGE, changeFrame);
			this._scenePanel.view.addEventListener(Event.ENTER_FRAME, enterFrameEvent);
		}
		
		private function changeFrame(event : Event) : void {
			if (this._app.selection.main != null) {
				this._lastFrame = this._scenePanel.rule.currentFrame;
				this._app.selection.main.gotoAndStop(this._scenePanel.rule.currentFrame);
			}
		}
		
		private function enterFrameEvent(event : Event) : void {
			Input3D.update();
			if (!this.context) {
				return;
			}
			var t : int = getTimer();
			this.render();
			this.update(t - _preTime);
			this._preTime = t;
		}
		
		override public function update(deltaTime : Number, includeChildren : Boolean = false) : void {

			this._time += deltaTime;
			this._app.dispatchEvent(new SceneEvent(SceneEvent.UPDATE_EVENT));
			
			var inScene : Boolean = this.viewPort.contains(Input3D.mouseX, Input3D.mouseY);
			if (inScene) {
				if (Input3D.mouseDown || Input3D.rightMouseDown || Input3D.middleMouseDown) {
					Studio.stage.focus = null;
				}
				if (Input3D.keyDown(Input3D.CONTROL) && Input3D.keyDown(Input3D.D)) {
					this._app.selection.delet();
				} else if (Input3D.keyDown(Input3D.CONTROL) && Input3D.keyDown(Input3D.X)) {
					this._app.selection.cut();
				} else if (Input3D.keyDown(Input3D.CONTROL) && Input3D.keyDown(Input3D.V)) {
					this._app.selection.paste();
				}
			}
			
			if (this._scenePanel.play) {
				this._scenePanel.rule.currentFrame = this._lastFrame + deltaTime / 1000 * 60;
				this._lastFrame = this._scenePanel.rule.currentFrame;
				this.gotoAndStop(this._scenePanel.rule.currentFrame);
				this._app.dispatchEvent(new FrameEvent(FrameEvent.CHANGING));
			}

			if (this._action == ACTION_NULL) {
				if ((inScene && Input3D.rightMouseHit) || (Input3D.middleMouseHit && Input3D.keyDown(Input3D.ALTERNATE))) {
					this._action = ACTION_ORIBIT;
					this._mouseMoved = false;
				} else if (inScene && (Input3D.middleMouseHit || Input3D.keyHit(Input3D.SPACE))) {
					this._action = ACTION_PAN;
				} else if (inScene && (Input3D.delta != 0)) {
					this._action = ACTION_ZOOM;
				}
			}

			if (this._cameraMode == "fps") {
				if (Input3D.rightMouseHit) {
					this._rotationSpeedX = 0;
					this._rotationSpeedY = 0;
				}
			}
		
			if (Studio.stage.focus == null) {
				var speed : int = Input3D.keyDown(Input3D.SHIFT) ? 2 : 1;
				if (Input3D.keyDown(Input3D.UP)) {
					this.camera.translateZ(_scenePanel.footsSpeed.value * speed);
				}
				if (Input3D.keyDown(Input3D.DOWN)) {
					this.camera.translateZ(-_scenePanel.footsSpeed.value * speed);
				}
				if (Input3D.keyDown(Input3D.LEFT)) {
					this.camera.translateX(-this._scenePanel.footsSpeed.value * speed);
				}
				if (Input3D.keyDown(Input3D.RIGHT)) {
					this.camera.translateX(this._scenePanel.footsSpeed.value * speed);
				}
				if (Input3D.keyDown(Input3D.PAGE_UP)) {
					this.camera.translateY(this._scenePanel.footsSpeed.value * speed);
				}
				if (Input3D.keyDown(Input3D.PAGE_DOWN)) {
					this.camera.translateY(-this._scenePanel.footsSpeed.value * speed);
				}
				
				if (this._cameraMode == "fps") {
					if (Input3D.rightMouseDown) {
						if (Input3D.keyDown(Input3D.W)) {
							this.camera.translateZ(this._scenePanel.footsSpeed.value * speed);
						}
						if (Input3D.keyDown(Input3D.S)) {
							this.camera.translateZ(-this._scenePanel.footsSpeed.value * speed);
						}
						if (Input3D.keyDown(Input3D.A)) {
							this.camera.translateX(-this._scenePanel.footsSpeed.value * speed);
						}
						if (Input3D.keyDown(Input3D.D)) {
							this.camera.translateX(this._scenePanel.footsSpeed.value * speed);
						}
						if (Input3D.keyDown(Input3D.E)) {
							this.camera.translateY(this._scenePanel.footsSpeed.value * speed);
						}
						if (Input3D.keyDown(Input3D.Q)) {
							this.camera.translateY(-this._scenePanel.footsSpeed.value * speed);
						}
					}
				}
				
			}
			
			switch (this._action) {
				case ACTION_ORIBIT:  {
					if (this._cameraMode == "orbit" || Input3D.keyDown(Input3D.CONTROL)) {
						this._rotationSpeedX = this._rotationSpeedX * 0.4;
						this._rotationSpeedY = this._rotationSpeedY * 0.4;
						this._rotationSpeedX = this._rotationSpeedX + (Input3D.mouseXSpeed * 0.25);
						this._rotationSpeedY = this._rotationSpeedY + (Input3D.mouseYSpeed * 0.25);
						this.camera.rotateY(this._rotationSpeedX, false, this._orbitPoint);
						this.camera.rotateX(this._rotationSpeedY, true, this._orbitPoint);
					} else {
						this._rotationSpeedX += Input3D.mouseXSpeed * 0.1;
						this._rotationSpeedY += Input3D.mouseYSpeed * 0.1;
						this._rotationSpeedX *= 0.7;
						this._rotationSpeedY *= 0.7;
						this.camera.rotateY(this._rotationSpeedX, false);
						this.camera.rotateX(this._rotationSpeedY, true);
					}
					if (this._mouseMoved == false) {
						this._mouseMoved = Math.abs(Input3D.mouseX) > 1 || Math.abs(Input3D.mouseYSpeed) > 1;
					}
					if (Input3D.rightMouseUp || Input3D.middleMouseUp) {
						this._action = ACTION_NULL;
					}
					break;
				}
				case ACTION_ZOOM:  {
					this._orbitDistance = this.camera.world.position.subtract(this._orbitPoint).length;
					if (Input3D.keyDown(Input3D.SHIFT)) {
						this.camera.translateZ((this._orbitDistance * Input3D.delta) / 2000);
					} else {
						this.camera.translateZ((this._orbitDistance * Input3D.delta) / 200);
					}
					this._action = ACTION_NULL;
					break;
				}
				case ACTION_PAN:  {
					this._mouseMoved = Input3D.mouseMoved > 2;
					if (Input3D.middleMouseDown || (Input3D.keyDown(Input3D.SPACE) && Input3D.mouseDown)) {
						this.camera.translateX((-Input3D.mouseXSpeed * this._orbitDistance) / 800);
						this.camera.translateY((Input3D.mouseYSpeed * this._orbitDistance) / 800);
						this._orbitAxis = camera.getDir(false);
						this.camera.localToGlobal(new Vector3D(0, 0, this._orbitDistance), this._orbitPoint);
					}
					if (Input3D.middleMouseUp || Input3D.keyUp(Input3D.SPACE)) {
						this._action = ACTION_NULL;
						var max : Vector3D = new Vector3D(1000000, 1000000, 1000000);
						var min : Vector3D = new Vector3D(-1000000, -1000000, -1000000);
						if (this._mouse.ray.test(camera.getPosition(false), this._orbitAxis, true, true, false)) {
							for each (var collisonInfo : CollisionInfo in this._mouse.ray.data) {
								if (collisonInfo.mesh == this._mouse.ray.data[0].mesh) {
									max = Vector3DUtils.min(max, collisonInfo.point);
									min = Vector3DUtils.max(min, collisonInfo.point);
								}
							}
							max.incrementBy(min);
							max.scaleBy(0.5);
							this._orbitPoint.copyFrom(max);
							this._orbitDistance = camera.getPosition(false).subtract(this._orbitPoint).length;
						}
					}
					this._action = ACTION_NULL;
					break;
				}
				default:  {
					this._action = ACTION_NULL;
					break;
				}
			}

			if (Input3D.middleMouseDown || (Input3D.keyDown(Input3D.SPACE) && Input3D.mouseDown)) {
				this.camera.translateX(-Input3D.mouseXSpeed * this._orbitDistance / 800);
				this.camera.translateY(Input3D.mouseYSpeed * this._orbitDistance / 800);
				this._orbitAxis = camera.getDir(false);
				this.camera.localToGlobal(new Vector3D(0, 0, this._orbitDistance), this._orbitPoint);
			}
			
			if (Input3D.middleMouseUp || Input3D.keyUp(Input3D.SPACE)) {
				this._action = ACTION_NULL;
			}
			
			var time : Number = deltaTime / 1000;
			
			for each (var pivot : Pivot3D in this.updateList) {
				pivot.update(time, true);
			}
		}

		public function renderToBitmapData(camera1 : Camera3D, bmp : BitmapData) : void {
			this.context.clear(0, 0, 0, 0);
			this.antialias = 8;
			super.render(camera1);
			this.context.drawToBitmapData(bmp);
		}
		
		override public function render(camera : Camera3D = null, clearDepth : Boolean = false) : void {
			
			this.setupFrame(this.camera);
			this.context.clear(this.background.x, this.background.y, this.background.z, this.background.w);
			this.context.setDepthTest(true, Context3DCompareMode.LESS_EQUAL);
			
			if (this._showGrid) {
				this._grid.draw();
			}
			
			Device3D.trianglesDrawn = 0;
			Device3D.drawCalls = 0;
			Device3D.objectsDrawn = 0;
			
			this._app.dispatchEvent(new SceneEvent(SceneEvent.RENDER_EVENT));
			this.setupFrame(this.camera);
			super.render(this.camera);
			this._app.dispatchEvent(new SceneEvent(SceneEvent.POST_RENDER_EVENT));
			this.context.clear(0, 0, 0, 1, 1, 0, Context3DClearMask.DEPTH);
			this._app.dispatchEvent(new SceneEvent(SceneEvent.OVERLAY_RENDER_EVENT));
			this.context.present();
		}

	}
}
