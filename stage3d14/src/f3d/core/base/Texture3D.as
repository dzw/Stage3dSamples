package f3d.core.base {
	
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	
	import f3d.core.scene.Scene3D;
	
	public class Texture3D {
		
		/** 倍增常量插值 */
		public static const FILTER_NEAREST 	: String = 'nearest';
		/** 倍增线性插值 */
		public static const FILTER_LINEAR 	: String = 'linear';
		/** clamp寻址模式 */
		public static const WRAP_CLAMP 		: String = 'clamp';
		/** repeat寻址模式 */
		public static const WRAP_REPEAT 	: String = 'repeat';
		/** 2d纹理格式 */
		public static const TYPE_2D 		: String = '2d';
		/** cube纹理格式 */
		public static const TYPE_CUBE 		: String = 'cube';
		/** 不启用MIP */
		public static const MIP_NONE 		: String = 'mipnone';
		/** 常量MIP插值 */
		public static const MIP_NEAREST 	: String = 'mipnearest';
		/** 线性MIP插值 */
		public static const MIP_LINEAR 		: String = 'miplinear';
		
		/** 纹理 */
		public var texture 		: TextureBase;
		/** scene */
		public var scene   		: Scene3D;
		/** 倍增模式 */
		public var filterType  	: String = FILTER_LINEAR;
		/** 寻址模式 */
		public var wrapType		: String = WRAP_REPEAT;
		/** 缩减模型 */
		public var mipType		: String = MIP_LINEAR;
		/** 纹理格式 */
		public var type			: String = TYPE_2D;
		/** 名称 */
		public var name			: String = "";
						
		private var _width			: int;				// 宽度
		private var _height			: int;				// 高度
				
		/**
		 * Texture3D 
		 * @param request			
		 * @param rtt			是否为rtt
		 * @param format		像素格式
		 * @param type			贴图格式
		 * 
		 */		
		public function Texture3D() {
			
		}
		
		/**
		 * 纹理高度 
		 * @return 
		 * 
		 */		
		public function get height():int {
			return _height;
		}

		public function set height(value:int):void {
			_height = value;
		}

		/**
		 * 纹理宽度 
		 * @return 
		 * 
		 */		
		public function get width():int {
			return _width;
		}

		public function set width(value:int):void {
			_width = value;
		}

		/**
		 * 上传贴图 
		 * @param scene
		 * 
		 */		
		public function upload(scene : Scene3D) : void {
			if (this.scene == scene) {
				return;
			}
			this.scene = scene;
			this.contextEvent();
		}
				
		protected function contextEvent(e : Event = null) : void {
			
		}
	}
}
