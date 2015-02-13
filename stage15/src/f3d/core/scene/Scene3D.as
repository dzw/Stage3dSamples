package f3d.core.scene {

	import flash.display.DisplayObject;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import f3d.core.base.Object3D;
	import f3d.core.camera.Camera3D;
	import f3d.core.camera.lens.PerspectiveLens;
	import f3d.core.utils.Device3D;
	import f3d.core.utils.Input3D;
	import f3d.core.utils.Time3D;
		
	public class Scene3D extends Object3D {
		
		/** 不支持该profile */
		public static const UNSUPORT_PROFILE 	: String = "Scene3D:UNSUPORT_PROFILE";
		/** 软解模式 */
		public static const SOFTWARE 			: String = "Scene3D:SOFTWARE";
		/** 创建完成 */
		public static const CREATE   			: String = Event.CONTEXT3D_CREATE;
		/** context被销毁 */
		public static const DISPOSED 			: String = "Scene3D:DISPOSED";
		/** enterframe事件 */
		public static const ENTER_FRAME 		: String = "Scene3D:ENTER_FRAME";
		/** exit frame事件 */
		public static const EXIT_FRAME 			: String = "Scene3D:EXIT_FRAME";
		/** pre render */
		public static const PRE_RENDER 			: String = "Scene3D:PRE_RENDER";
		/** post render */
		public static const POST_RENDER 		: String = "Scene3D:POST_RENDER";
		/** render */
		public static const RENDER				: String = "Scene3D:RENDER";
		
		/** enterframe事件 */
		private static var enterFrameEvent : Event = new Event(ENTER_FRAME);
		/** exitframe事件 */
		private static var exitFrameEvent  : Event = new Event(EXIT_FRAME);
		/** pre render */
		private static var preRenderEvent  : Event = new Event(PRE_RENDER);
		/** post render */
		private static var postRenderEvent : Event = new Event(POST_RENDER);
		/** render event */
		private static var renderEvent	   : Event = new Event(RENDER);
		
		
		/** stage3d设备索引 */
		private static var stage3dIdx 	: int = 0;
				
		private var _container 			: DisplayObject;		// 2d容器
		private var _backgroundColor 	: uint;					// 背景色
		private var _clearColor			: Vector3D;				// clear color
		private var _stage3d			: Stage3D;				// stage3d
		private var _context3d			: Context3D;			// context3d
		private var _autoResize			: Boolean;				// 是否自动缩放大小
		private var _viewPort			: Rectangle;			// viewport
		private var _antialias			: int;					// 抗锯齿等级
		private var _paused				: Boolean;				// 是否暂停
		private var _camera				: Camera3D;				// camera
		
		/**
		 * 
		 * @param dispObject
		 * 
		 */		
		public function Scene3D(dispObject : DisplayObject) {
			super();
			this.container  = dispObject;
			this.antialias  = 0;
			this.clearColor = new Vector3D();
			this.background = 0x333333;
			this.camera     = new Camera3D(new PerspectiveLens());
			this.camera.transform.world.position = new Vector3D(0, 0, -200);
			if (this.container.stage) {
				this.addedToStageEvent();
			} else {
				this.container.addEventListener(Event.ADDED_TO_STAGE, addedToStageEvent, false, 0, true);
			}
		}
		
		public function get camera():Camera3D {
			return _camera;
		}

		public function set camera(value:Camera3D):void {
			_camera = value;
		}

		public function get clearColor():Vector3D {
			return _clearColor;
		}

		public function set clearColor(value:Vector3D):void {
			_clearColor = value;
		}

		public function get antialias():int {
			return _antialias;
		}

		public function set antialias(value:int):void {
			_antialias = value;
		}

		public function get viewPort():Rectangle {
			return _viewPort;
		}

		/**
		 * 设置3D视口 
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 * 
		 */		
		public function setViewPort(x : int, y : int, width : int, height : int) : void {
			if (_viewPort && _viewPort.x == x && _viewPort.y == y && _viewPort.width == width && _viewPort.height == height) {
				return;
			}
			if (width <= 50) {
				width = 50;
			}
			if (height <= 50) {
				height = 50;
			}
			if (context3d && context3d.driverInfo.indexOf("Software") != -1) {
				if (width > 2048) {
					width = 2048;
				}
				if (height > 2048) {
					height = 2048;
				}
			}
			if (!_viewPort) {
				_viewPort = new Rectangle();
			}
			_viewPort.setTo(x, y, width, height);
			if (_camera) {
				_camera.lens.setViewPort(0, 0, width, height);
			}
			if (context3d) {
				stage3d.x = x;
				stage3d.y = y;
				context3d.configureBackBuffer(width, height, antialias);
				context3d.clear(clearColor.x, clearColor.y, clearColor.z, 1);
			}
		}
		
		/**
		 * 被添加到舞台 
		 * @param e
		 * 
		 */		
		private function addedToStageEvent(e : Event = null) : void {
			this.container.removeEventListener(Event.ADDED_TO_STAGE, addedToStageEvent);
			// 初始化input3d
			if (stage3dIdx == 0) {
				Input3D.initialize(this.container.stage);
			}
			if (stage3dIdx >= 4) {
				throw new Error("无法创建4个以上的scene");
			}
			this.stage3d = this.container.stage.stage3Ds[stage3dIdx];
			this.stage3d.addEventListener(Event.CONTEXT3D_CREATE, stageContextEvent, false, 0, true);
			// 申请context3d
			try {
				this.stage3d.requestContext3D(Context3DRenderMode.AUTO, Device3D.profile);
			} catch (e : Error) {
				this.dispatchEvent(new Event(UNSUPORT_PROFILE));
				this.stage3d.requestContext3D(Context3DRenderMode.AUTO);
			}
		}
		
		private function stageContextEvent(event:Event) : void {
			this.context3d = stage3d.context3D;
			
			if (context3d.driverInfo.indexOf("Software") != -1) {
				this.dispatchEvent(new Event(SOFTWARE));		// 软解模式
			} else if (context3d.driverInfo.indexOf("disposed") != -1) {
				this.dispatchEvent(new Event(DISPOSED));		// context被销毁
				this.pause(); // context被销毁，需要暂停渲染
			}
			if (!this.viewPort) {
				this.setViewPort(0, 0, container.stage.stageWidth, container.stage.stageHeight);
			} else {
				this.stage3d.x = viewPort.x;
				this.stage3d.y = viewPort.y;
				this.context3d.configureBackBuffer(viewPort.width, viewPort.height, antialias);
				this.context3d.clear();
			}
			
			Time3D.update();
			
			this.container.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			this.container.addEventListener(Event.ENTER_FRAME,		  onEnterFrame);
			
			this.dispatchEvent(event);
		}
		
		/**
		 * enterFrame 
		 * @param event
		 * 
		 */		
		private function onEnterFrame(event : Event) : void {
			Input3D.update();
			Time3D.update();
			if (paused) {
				return;
			}
			this.setupFrame(this.camera);
			this.dispatchEvent(enterFrameEvent);
			this.update(true);
			this.renderScene();
		}
				
		/**
		 * 绘制场景 
		 * 
		 */		
		private function renderScene() : void {
			if (context3d) {
				this.context3d.clear(clearColor.x, clearColor.y, clearColor.z);
				this.context3d.setDepthTest(Device3D.defaultDepthWrite, Device3D.defaultCompare);
				this.context3d.setCulling(Device3D.defaultCullFace);
				this.context3d.setBlendFactors(Device3D.defaultSourceFactor, Device3D.defaultDestFactor);
				this.dispatchEvent(preRenderEvent);
				this.render(this.camera);
				this.dispatchEvent(postRenderEvent);
				this.context3d.present();
			}
		}
		
		/**
		 * 设置相机 
		 * @param camera
		 * 
		 */		
		public function setupFrame(camera : Camera3D) : void {
			Device3D.triangles = 0;
			Device3D.drawCall  = 0;
			Device3D.obj  	   = 0;
			Device3D.camera = camera;
			Device3D.scene  = this;
			Device3D.proj.copyFrom(Device3D.camera.projection);
			Device3D.view.copyFrom(Device3D.camera.view);
			Device3D.viewProjection.copyFrom(Device3D.view);
			Device3D.viewProjection.append(Device3D.proj);
			if (this.viewPort.equals(camera.lens.viewPort)) {
				this.context3d.setScissorRectangle(null);
			} else {
				this.context3d.setScissorRectangle(camera.lens.viewPort);
			}
		}
		
		/**
		 * 渲染 
		 * @param camera
		 * 
		 */		
		public function render(camera : Camera3D) : void {
			this.dispatchEvent(renderEvent);
			for each (var child : Object3D in children) {
				child.draw(this, null, true);
			}
		}
		
		override public function update(includeChildren : Boolean) : void {
			for each (var child : Object3D in children) {
				child.update(includeChildren);
			}
		}
		
		/**
		 *  恢复渲染
		 */		
		public function resume() : void {
			_paused = false;
		}
		
		/**
		 *  暂停渲染
		 */		
		public function pause() : void {
			_paused = true;	
		}
		
		public function get paused() : Boolean {
			return _paused;
		}
		
		public function get autoResize():Boolean {
			return _autoResize;
		}

		public function set autoResize(value:Boolean):void {
			_autoResize = value;
		}
		
		public function get context3d():Context3D {
			return _context3d;
		}

		public function set context3d(value:Context3D):void {
			_context3d = value;
		}

		public function get stage3d():Stage3D {
			return _stage3d;
		}

		public function set stage3d(value:Stage3D):void {
			_stage3d = value;
		}

		private function onRemoveFromStage(event:Event) : void {
			
		}
		
		/**
		 * 2d显示对象
		 * @return 
		 * 
		 */		
		public function get container():DisplayObject {
			return _container;
		}
		
		/**
		 * 2d显示对象
		 * @param value
		 * 
		 */		
		public function set container(value:DisplayObject):void {
			_container = value;
		}

		/**
		 * 背景色 
		 * @return 
		 * 
		 */		
		public function get background():uint {
			return _backgroundColor;
		}
		
		/**
		 * 背景色 
		 * @param value
		 * 
		 */		
		public function set background(value:uint):void {
			_backgroundColor = value;
			clearColor.z = (value & 0xFF) / 0xFF;
			clearColor.y = ((value >> 8) & 0xFF) / 0xFF;
			clearColor.x = ((value >> 16) & 0xFF) / 0xFF;
		}
		
	}
}
