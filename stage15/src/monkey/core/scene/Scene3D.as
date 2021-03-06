package monkey.core.scene {

	import flash.display.DisplayObject;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.camera.Camera3D;
	import monkey.core.camera.lens.PerspectiveLens;
	import monkey.core.textures.Texture3D;
	import monkey.core.utils.Device3D;
	import monkey.core.utils.Input3D;
	import monkey.core.utils.Time3D;
		
	public class Scene3D extends Object3D {
		
		/** 不支持该profile */
		public static const UNSUPORT_PROFILE 	: String = "Scene3D:UNSUPORT_PROFILE";
		/** 软解模式 */
		public static const SOFTWARE 			: String = "Scene3D:SOFTWARE";
		/** 创建完成 */
		public static const CREATE   			: String = Event.CONTEXT3D_CREATE;
		/** context被销毁 */
		public static const DISPOSED 			: String = "Scene3D:DISPOSED";
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
		
		/** 所有网格数据 */
		public var surfaces				: Vector.<Surface3D>;
		/** 所有材质数据 */
		public var textures				: Vector.<Texture3D>;		
		/** 跳过本次渲染 */
		public var skipCurrentRender	: Boolean;
				
		private var _container 			: DisplayObject;		// 2d容器
		private var _backgroundColor 	: uint;					// 背景色
		private var _clearColor			: Vector3D;				// 后台缓冲区颜色
		private var _stage3d			: Stage3D;				// stage3d
		private var _context3d			: Context3D;			// context3d
		private var _autoResize			: Boolean;				// 是否自动缩放大小
		private var _viewPort			: Rectangle;			// viewport
		private var _antialias			: int;					// 抗锯齿等级
		private var _paused				: Boolean;				// 是否暂停
		private var _camera				: Camera3D;				// camera
		
		/**
		 * @param dispObject
		 */		
		public function Scene3D(dispObject : DisplayObject) {
			super();
			this.surfaces	= new Vector.<Surface3D>();
			this.textures   = new Vector.<Texture3D>();
			this.container  = dispObject;
			this.antialias  = 4;
			this.clearColor = new Vector3D();
			this.background = 0x333333;
			this.camera     = new Camera3D(new PerspectiveLens());
			this.camera.transform.setPosition(0, 0, -100);
			if (this.container.stage) {
				this.addedToStageEvent();
			} else {
				this.container.addEventListener(Event.ADDED_TO_STAGE, addedToStageEvent, false, 0, true);
			}
		}
				
		/**
		 * 获取相机 
		 * @return 
		 * 
		 */		
		public function get camera():Camera3D {
			return _camera;
		}
		
		/**
		 * 设置相机 
		 * @param value
		 * 
		 */		
		public function set camera(value:Camera3D):void {
			if (value == _camera) {
				return;
			}
			_camera = value;
		}
		
		/**
		 * clear颜色:w分量为alpha 
		 * @return 
		 * 
		 */		
		public function get clearColor():Vector3D {
			return _clearColor;
		}
		
		/**
		 * clear颜色:w分量为alpha 
		 * @param value
		 * 
		 */		
		public function set clearColor(value:Vector3D):void {
			_clearColor = value;
		}
		
		/**
		 * 获取抗锯齿等级 
		 * @return 
		 * 
		 */		
		public function get antialias():int {
			return _antialias;
		}

		/**
		 * 设置抗锯齿等级 
		 * @param value
		 * 
		 */		
		public function set antialias(value:int):void {
			if (value == _antialias) {
				return;
			}
			_antialias = value;
			if (viewPort && _stage3d && _stage3d.context3D) {
				_stage3d.context3D.configureBackBuffer(viewPort.width, viewPort.height, value);
				_stage3d.context3D.clear(clearColor.x, clearColor.y, clearColor.z, clearColor.w);
			}
		}
		
		/**
		 * scene视口 
		 * @return 
		 * 
		 */		
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
			if (context && context.driverInfo.indexOf("Software") != -1) {
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
			var adapt : Boolean = false;
			if (_camera && _camera.viewPort.equals(viewPort)) {
				adapt = true;
			}
			_viewPort.setTo(x, y, width, height);
			if (_camera && adapt) {
				_camera.lens.setViewPort(0, 0, width, height);
			}
			if (context) {
				stage3d.x = x;
				stage3d.y = y;
				context.configureBackBuffer(width, height, antialias);
				context.clear(clearColor.x, clearColor.y, clearColor.z, clearColor.w);
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
			this._stage3d = container.stage.stage3Ds[stage3dIdx];
			this.stage3d.addEventListener(Event.CONTEXT3D_CREATE, stageContextEvent, false, 0, true);
			// 申请context3d
			try {
				this.stage3d.requestContext3D(Context3DRenderMode.AUTO, Device3D.profile);
			} catch (e : Error) {
				this.dispatchEvent(new Event(UNSUPORT_PROFILE));
				this.stage3d.requestContext3D(Context3DRenderMode.AUTO);
			}
			stage3dIdx++;
		}
		
		private function stageContextEvent(event:Event) : void {
			this.resume();
			this._context3d = stage3d.context3D;
			if (context.driverInfo.indexOf("Software") != -1) {
				this.dispatchEvent(new Event(SOFTWARE));		// 软解模式
			} else if (context.driverInfo.indexOf("disposed") != -1) {
				this.dispatchEvent(new Event(DISPOSED));		// context被销毁
				this.pause(); 									// context被销毁，需要暂停渲染
			}
			if (!this.viewPort) {
				this.setViewPort(0, 0, container.stage.stageWidth, container.stage.stageHeight);
			} else {
				this.stage3d.x = viewPort.x;
				this.stage3d.y = viewPort.y;
				this.context.configureBackBuffer(viewPort.width, viewPort.height, antialias);
				this.context.clear();
			}
			Time3D.update();
			this.container.addEventListener(Event.ENTER_FRAME,		  onEnterFrame);
			this.dispatchEvent(event);
		}
		
		/**
		 * enterFrame 
		 * @param event
		 * 
		 */		
		private function onEnterFrame(event : Event) : void {
			if (stage3dIdx == 1) {
				Input3D.update();	// 输入
				Time3D.update();	// 时间
			}
			if (this.paused) {
				return;
			}
			this.setupFrame(this.camera);
			this.update(true);
			this.renderScene();
			if (stage3dIdx == 1) {
				Input3D.clear();
			}
		}
		
		/**
		 * 绘制场景 
		 * 
		 */		
		private function renderScene() : void {
			if (this.context) {
				this.context.clear(clearColor.x, clearColor.y, clearColor.z, clearColor.w);
				this.context.setDepthTest(Device3D.defaultDepthWrite, Device3D.defaultCompare);
				this.context.setCulling(Device3D.defaultCullFace);
				this.context.setBlendFactors(Device3D.defaultSourceFactor, Device3D.defaultDestFactor);
				this.skipCurrentRender = false;
				this.dispatchEvent(preRenderEvent);
				if (!this.skipCurrentRender) {
					this.render(this.camera);
				}
				this.dispatchEvent(postRenderEvent);
				this.context.present();
			}
		}
		
		/**
		 * 设置相机 
		 * @param camera
		 * 
		 */		
		public function setupFrame(camera : Camera3D) : void {
			Device3D.triangles = 0;
			Device3D.drawCalls  = 0;
			Device3D.drawOBJNum  	   = 0;
			Device3D.camera    = camera;
			Device3D.scene     = this;
			Device3D.proj.copyFrom(Device3D.camera.projection);
			Device3D.view.copyFrom(Device3D.camera.view);
			Device3D.viewProjection.copyFrom(Device3D.camera.viewProjection);
			if (this.viewPort.equals(camera.lens.viewPort)) {
				this.context.setScissorRectangle(null);
			} else {
				this.context.setScissorRectangle(camera.lens.viewPort);
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
				child.draw(this, true);
			}
		}
		
		override public function update(includeChildren : Boolean) : void {
			this.dispatchEvent(enterFrameEvent);
			for each (var child : Object3D in children) {
				child.update(includeChildren);
			}
			this.dispatchEvent(exitFrameEvent);
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
		
		/**
		 * 暂停渲染 
		 * @return 
		 * 
		 */		
		public function get paused() : Boolean {
			return _paused;
		}
		
		/**
		 * 自适应 
		 * @return 
		 * 
		 */		
		public function get autoResize():Boolean {
			return _autoResize;
		}
		
		/**
		 * 自适应 
		 * @param value
		 * 
		 */		
		public function set autoResize(value:Boolean):void {
			if (value == _autoResize) {
				return;
			}
			_autoResize = value;
			if (container && container.stage) {
				if (value) {
					container.stage.align = StageAlign.TOP_LEFT;
					container.stage.scaleMode = StageScaleMode.NO_SCALE;
					container.stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);
				} else {
					container.stage.removeEventListener(Event.RESIZE, onStageResize);
				}
			}
		}
		
		private function onStageResize(event:Event) : void {
			if (_autoResize) {
				this.setViewPort(0, 0, container.stage.stageWidth, container.stage.stageHeight);
			}
		}
		
		/**
		 * context 
		 * @return 
		 * 
		 */		
		public function get context():Context3D {
			return _context3d;
		}
		
		/**
		 * stage3d 
		 * @return 
		 * 
		 */		
		public function get stage3d():Stage3D {
			return _stage3d;
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
		
		public function show() : void {
			if (stage3d) {
				stage3d.visible = true;
			}
		}
		
		public function hide() : void {
			if (stage3d) {
				stage3d.visible = false;
			}
		}
		
		/**
		 *  shader由自己释放
		 */		
		override public function dispose():void {
			while (this.textures.length > 0) {
				this.textures[0].dispose(true);
			}
			while (this.surfaces.length > 0) {
				this.surfaces[0].dispose(true);
			}
			this.children.length = 0;
		}
				
		/**
		 * 释放显存，shader由自己释放。
		 */		
		public function freeMemory() : void {
			while (this.textures.length > 0) {
				this.textures[0].download(true);
			}
			while (this.surfaces.length > 0) {
				this.surfaces[0].download(true);
			}
			this.children.length = 0;
		}
		
	}
}
