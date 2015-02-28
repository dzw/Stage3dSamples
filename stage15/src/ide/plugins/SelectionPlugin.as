package ide.plugins {

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import L3D.collisions.CollisionInfo;
	import L3D.core.base.Bounds3D;
	import L3D.core.base.Pivot3D;
	import L3D.core.camera.Camera3D;
	import L3D.core.entities.Mesh3D;
	import L3D.core.entities.primitives.Axis3D;
	import L3D.core.entities.primitives.Cube;
	import L3D.core.entities.primitives.DebugBounds;
	import L3D.core.entities.primitives.DebugCamera;
	import L3D.core.entities.primitives.DebugLight;
	import L3D.core.entities.primitives.DebugWireframe;
	import L3D.core.entities.primitives.Lines3D;
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.light.Light3D;
	import L3D.core.render.SkeletonRender;
	import L3D.core.scene.Scene3D;
	import L3D.system.Input3D;
	
	import ide.Studio;
	import ide.events.FrameEvent;
	import ide.events.SceneEvent;
	import ide.events.SelectionEvent;
	import ide.panel.Gizmo;
	import ide.utils.MathUtils;
	
	import ui.core.App;
	import ui.core.container.Box;
	import ui.core.container.MenuCombox;
	import ui.core.interfaces.IPlugin;

	public class SelectionPlugin implements IPlugin {

		private static var _wire 		: Dictionary = new Dictionary();
		private static var _camerDebug 	: Dictionary = new Dictionary();
		
		private var _app 				: App;					// app
		private var _bbox				: DebugBounds;			// bounds线框
		private var _light 				: DebugLight;			// light线框
		private var _axis 				: Pivot3D;				// 轴
		private var _selection 			: Array;				// 选中物体
		private var _gizmos 			: Dictionary;			// gizmos
		private var _currentGizmo 		: Gizmo;				// gizmo
		private var _showAxis 			: Boolean = true;		// 显示坐标系
		private var _showBoundings 		: Boolean = true;		// 显示包围盒
		private var _showWireframe 		: Boolean = true;		// 显示线框
		private var _showPivots 		: Boolean = true;		// 显示Pivot图标
		private var _showLights 		: Boolean = true;		// 显示灯光图标
		private var _showCameras 		: Boolean = true;		// 显示相机图标
		private var _showShapes 		: Boolean = true;		// 显示shape
		private var _showParticles 		: Boolean = true;		// 显示粒子图标
		private var _selecting 			: Boolean = false;		// 选中状态
		private var _sprite 			: Sprite;				// sprite
		private var _changingFrame 		: Boolean;				// 改变帧
		private var _invalidateFrame 	: Boolean;				// 
		private var _showGizmo 			: Boolean = true;		// 显示gizmo
		
		public function SelectionPlugin() {
			this._bbox 		= new DebugBounds(new Cube("", 1, 1, 1));
			this._light 	= new DebugLight(null, 0xFFCB00, 0.75);
			this._selection = [];
			this._gizmos 	= new Dictionary(true);
			this._sprite 	= new Sprite();
			this._axis 		= new Axis3D();
		}
		
		public function init(app : App) : void {
			this._app = app;
			this._app.addEventListener(SceneEvent.OVERLAY_RENDER_EVENT, overlayRenderEvent, 	false, 0, true);
			this._app.addEventListener(SceneEvent.POST_RENDER_EVENT, 	postRenderEvent, 		false, 0, true);
			this._app.addEventListener(SceneEvent.UPDATE_EVENT, 		updateEvent, 			false, -1000);
			this._app.addEventListener(SceneEvent.CHANGE, 				changeSceneEvent, 		false, -1000);
			this._app.addEventListener(SceneEvent.INVALIDATE, 			invalidateSceneEvent,	false, -1000);
			this._app.addEventListener(SelectionEvent.CHANGE, 			changeSelectionEvent);
			this._app.addEventListener(FrameEvent.CHANGING, 			changeFrameEvent);
			this._app.addEventListener(FrameEvent.CHANGE, 				changeFrameEvent);
			this.initMenu();
		}
		
		private function initMenu() : void {
			var bar  : Box = this._app.gui.getPanel(Studio.SCENE_MENU) as Box;
			var menu : MenuCombox = new MenuCombox("Selection");
			menu.addMenuItem("ShowAxis", 		showAxis);
			menu.addMenuItem("ShowWireframe", 	showWireframe);
			menu.addMenuItem("ShowPivots", 		showPivots);
			menu.addMenuItem("ShowLights", 		showLights);
			menu.addMenuItem("ShowCameras", 	showCameras);
			menu.addMenuItem("ShowParticles", 	showParticles);
			menu.addMenuItem("ShowBoudings", 	showBoundings);
			menu.addMenuItem("ShowShapes", 		showShapes);
			menu.addMenuItem("ShowGizmo",		showGizmo);
			menu.addMenuItem("ResetCamera", 	resetCamera);
			menu.maxWidth = 80;
			menu.minWidth = 80;
			menu.width = 80;
			menu.update();
			menu.draw();
			bar.addControl(menu);
			bar.draw();
		}
		
		private function resetCamera(e : MouseEvent) : void {
			this._app.scene.camera.setPosition(0, 100, -100);
			this._app.scene.camera.lookAt(0, 0, 0);
		}
		
		private function showGizmo(e : MouseEvent) : void {
			this._showGizmo = !this._showGizmo;
		}
		
		private function showShapes(e : MouseEvent) : void {
			this._showShapes = !this._showShapes;
		}

		private function showBoundings(e : MouseEvent) : void {
			this._showBoundings = !this._showBoundings;
		}

		private function showParticles(e : MouseEvent) : void {
			this._showParticles = !this._showParticles;
		}

		private function showCameras(e : MouseEvent) : void {
			this._showCameras = !this._showCameras;
		}

		private function showLights(e : MouseEvent) : void {
			this._showLights = !this._showLights;
		}

		private function showPivots(e : MouseEvent) : void {
			this._showPivots = !this._showPivots;
		}

		private function showWireframe(e : MouseEvent) : void {
			this._showWireframe = !this._showWireframe;
		}

		private function showAxis(e : MouseEvent) : void {
			this._showAxis = !this._showAxis;
		}

		private function changeFrameEvent(event : Event) : void {
			if (event.type == FrameEvent.CHANGE) {
				this._changingFrame   = false;
				this._invalidateFrame = true;
			} else {
				this._changingFrame   = true;
			}
		}
		
		private function changeSelectionEvent(event : Event) : void {
			if (this._showWireframe) {
				this._invalidateFrame = true;
			}
		}
		
		private function invalidateSceneEvent(event : Event) : void {
			_wire = new Dictionary(true);
		}
		
		private function changeSceneEvent(event : Event) : void {
			for each (var gizmo : Gizmo in this._gizmos) {
				if (this._sprite.contains(gizmo)) {
					this._sprite.removeChild(gizmo);
				}
			}
			this._gizmos = new Dictionary(true);
		}
		
		private function updateEvent(event : SceneEvent) : void {
			if (event.isDefaultPrevented()) {
				return;
			}
			var inScene : Boolean = this._app.scene.viewPort.contains(Input3D.mouseX, Input3D.mouseY);
			if (inScene && Input3D.mouseHit && !Input3D.keyDown(Input3D.CONTROL)) {
				if (this._currentGizmo != null) {
					if (Input3D.keyDown(Input3D.ALTERNATE)) {
						this._app.selection.remove([this._currentGizmo.pivot]);
					} else if (this._app.selection.objects.indexOf(this._currentGizmo.pivot) == -1) {
						this._app.selection.objects = [];
						this._app.selection.push([this._currentGizmo.pivot]);
					}
					this._currentGizmo = null;
				} else if (ScenePlugin(this._app.scene).mouse.test(Studio.stage.mouseX, Studio.stage.mouseY)) {
					var pickInfo : CollisionInfo = ScenePlugin(this._app.scene).mouse.data[0];
					if (Input3D.keyDown(Input3D.CONTROL)) {
						this._selecting = true;
					} else if (this._app.selection.objects.indexOf(pickInfo.mesh) == -1) {
						this._app.selection.objects = [];
						this._app.selection.push([pickInfo.mesh]);
						this._app.selection.shader = (pickInfo.mesh as Mesh3D).material.shader;
						this._app.selection.geometry = pickInfo.geometry;
					}
				} else if (Input3D.keyDown(Input3D.CONTROL) == false || Input3D.keyDown(Input3D.ALTERNATE) == false) {
					this._app.selection.objects = [];
				}
			}
		}
		
		private function postRenderEvent(event : Event) : void {
			if (this._showWireframe) {
				for each (var pivot : Pivot3D in this._app.selection.objects) {
					if (pivot.visible == false || pivot is Lines3D || pivot is Particles3D) {
						continue;
					}
					if (pivot is Mesh3D && !((pivot as Mesh3D).render is SkeletonRender) && this._changingFrame == false) {
						if (_wire[pivot] == undefined) {
							_wire[pivot] = new DebugWireframe(pivot as Mesh3D, 0xFFFFFF, 0.25);
						}
						_wire[pivot].world = pivot.world;
						_wire[pivot].draw();
					}
				}
			}
			if (this._showGizmo) {
				this._app.scene.forEach(drawGizmos);
				var gizmos : Array = [];
				for each (var gizmo : Gizmo in this._gizmos) {
					gizmo.selected = false;
					gizmos.push(gizmo);
				}
				gizmos.sortOn('w', Array.NUMERIC);
				for each (var giz : Gizmo in gizmos) {
					if (giz.visible && giz.pivot.visible) {
						if (this._app.selection.objects.indexOf(giz.pivot) != -1) {
							giz.selected = true;
						}
						this._sprite.addChildAt(giz, 0);
					}
				}
			}
			
			this._invalidateFrame = false;
		}

		private function drawGizmos(pivot : Pivot3D) : void {
			if (!pivot || pivot.visible == false) {
				return;
			}
			if (pivot is Particles3D) {
				
			} else if (pivot is Scene3D || pivot is Mesh3D) {
				return;
			}
			
			var pos : Vector3D = pivot.getScreenCoords();
			var gizmo : Gizmo  = this._gizmos[pivot];
			
			if (!gizmo) {
				gizmo = new Gizmo(pivot);
				this._gizmos[pivot] = gizmo;
			}
			
			gizmo.addEventListener(MouseEvent.MOUSE_DOWN, gizmoMouseDown, false, 0, true);
			gizmo.x = pos.x;
			gizmo.y = pos.y;
			gizmo.w = pos.w;
			gizmo.scaleX = gizmo.scaleY = 1;
			gizmo.visible = gizmo.w > 0;
			
			if (pivot is Camera3D && this._app.selection.objects.indexOf(pivot) != -1) {
				if (_camerDebug[pivot] == undefined) {
					_camerDebug[pivot] = new DebugCamera(pivot as Camera3D);
				}
				_camerDebug[pivot].world = pivot.world;
				_camerDebug[pivot].draw();
			} else if (pivot is Light3D && this._app.selection.objects.indexOf(pivot) != -1) {
				var light : Light3D = pivot as Light3D;
				this._light.light = light;
				this._light.draw();
			}
		}
		
		private function gizmoMouseDown(event : MouseEvent) : void {
			this._currentGizmo = event.target as Gizmo;
		}
		
		private function overlayRenderEvent(event : Event) : void {
			for each (var pivot : Pivot3D in this._app.selection.objects) {
				if (pivot is Scene3D || pivot.visible == false) {
					continue;
				}
				if (this._showBoundings) {
					var bounds : Bounds3D = getBounds(pivot);
					if (bounds.length.length < 0.001) {
						bounds.length.setTo(0.001, 0.001, 0.001);
					}
					var center : Vector3D = bounds.center;
					var scale  : Vector3D = pivot.getScale(false);
					pivot.localToGlobal(center, center);
					scale.x *= bounds.length.x <= 0.001 ? 0.001 : bounds.length.x;
					scale.y *= bounds.length.y <= 0.001 ? 0.001 : bounds.length.y;
					scale.z *= bounds.length.z <= 0.001 ? 0.001 : bounds.length.z;
					this._bbox.transform.copyFrom(pivot.world);
					this._bbox.setPosition(center.x, center.y, center.z);
					this._bbox.setScale(scale.x, scale.y, scale.z);
					this._bbox.draw();
					this._app.selection.aabb.x = scale.x;
					this._app.selection.aabb.y = scale.y;
					this._app.selection.aabb.z = scale.z;
				}
				if (this._showAxis) {
					var dir    : Vector3D = this._app.scene.camera.getDir(true);
					var dist   : Number = MathUtils.pointPlane(dir, this._app.scene.camera.getPosition(false), pivot.getPosition(false)) * 2 * this._app.scene.camera.zoom / this._app.scene.viewPort.width;
					var scale0 : Number = Math.max(Math.abs(dist * 1.3), 0.0001);
					this._axis.transform.copyFrom(pivot.world);
					this._axis.setScale(scale0, scale0, scale0);
					this._axis.draw();
				}
			}
			
		}

		private function getBounds(pivot : Pivot3D) : Bounds3D {
			
			var bounds : Bounds3D = new Bounds3D();
			
			if (!(pivot is Mesh3D) && pivot.children.length == 0) {
				return bounds;
			}

			bounds.max.setTo(Number.MIN_VALUE, Number.MIN_VALUE, Number.MIN_VALUE);
			bounds.min.setTo(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE);
			
			if (pivot is Mesh3D) {
				bounds.copyFrom((pivot as Mesh3D).bounds);
			} else {
				pivot.forEach(function(mesh : Mesh3D) : void {
					if (bounds.min.x > mesh.bounds.min.x) {
						bounds.min.x = mesh.bounds.min.x;
					}
					if (bounds.min.y > mesh.bounds.min.y) {
						bounds.min.y = mesh.bounds.min.y;
					}
					if (bounds.min.z > mesh.bounds.min.z) {
						bounds.min.z = mesh.bounds.min.z;
					}
					if (bounds.max.x < mesh.bounds.max.x) {
						bounds.max.x = mesh.bounds.max.x;
					}
					if (bounds.max.y < mesh.bounds.max.y) {
						bounds.max.y = mesh.bounds.max.y;
					}
					if (bounds.max.z < mesh.bounds.max.z) {
						bounds.max.z = mesh.bounds.max.z;
					}
				}, Mesh3D);
			}
		
			bounds.length.x = bounds.max.x - bounds.min.x;
			bounds.length.y = bounds.max.y - bounds.min.y;
			bounds.length.z = bounds.max.z - bounds.min.z;
			bounds.center.x = bounds.length.x * 0.5 + bounds.min.x;
			bounds.center.y = bounds.length.y * 0.5 + bounds.min.y;
			bounds.center.z = bounds.length.z * 0.5 + bounds.min.z;
			bounds.radius = Vector3D.distance(bounds.center, bounds.max);
			
			return bounds;
		}
		
		public function start() : void {
			Studio.stage.addChildAt(this._sprite, 0);
		}
	}
}
