package f3d.core.shader {

	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Program3D;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import f3d.core.base.Object3D;
	import f3d.core.base.Surface3D;
	import f3d.core.scene.Scene3D;
	import f3d.core.shader.filters.Filter3D;
	import f3d.core.shader.utils.FcRegisterLabel;
	import f3d.core.shader.utils.FsRegisterLabel;
	import f3d.core.shader.utils.ShaderRegisterCache;
	import f3d.core.shader.utils.ShaderRegisterElement;
	import f3d.core.shader.utils.VcRegisterLabel;
	import f3d.core.utils.AGALMiniAssembler;
	import f3d.core.utils.Device3D;
	
	/**
	 * shader 
	 * @author Neil
	 * 
	 */	
	public class Shader3D extends EventDispatcher {
		
		public static const BLEND_NONE 			: String = 'BLEND_NONE';
		public static const BLEND_ADDITIVE 		: String = 'BLEND_ADDITIVE';
		public static const BLEND_ALPHA_BLENDED : String = 'BLEND_ALPHA_BLENDED';
		public static const BLEND_MULTIPLY 		: String = 'BLEND_MULTIPLY';
		public static const BLEND_SCREEN 		: String = 'BLEND_SCREEN';
		public static const BLEND_ALPHA 		: String = 'BLEND_ALPHA';
		
		/** 名称 */
		public  var name 			: String;
		
		private var regCache 		: ShaderRegisterCache;					// 寄存器
		private var _filters 		: Vector.<Filter3D>;					// filters
		private var _program 		: Program3D;							// GPU指令
		private var _scene 			: Scene3D;								// scene
		private var _sourceFactor	: String;								// 混合模式
		private var _destFactor		: String;								// 混合模式
		private var _depthWrite 	: Boolean;								// 开启深度
		private var _depthCompare 	: String;								// 测试条件
		private var _cullFace 		: String;								// 裁剪
		private var _blendMode 		: String = BLEND_NONE;					// 混合模式
		private var _stateDirty		: Boolean = false;						// context状态
		private var _programDirty	: Boolean = true;						// GPU指令
		private var _disposed		: Boolean = false;						// 是否已经被dispose
		private var _initWithBytes  : Boolean = false;						// 通过bytes初始化shader
		
		public function Shader3D(filters : Array) {
			super(null);
			this.name 			= "Shader3D";
			this._filters  	 	= Vector.<Filter3D>(filters);
			this._depthWrite  	= Device3D.defaultDepthWrite;
			this._depthCompare	= Device3D.defaultCompare;
			this._cullFace	 	= Device3D.defaultCullFace;
			this._sourceFactor	= Device3D.defaultSourceFactor;
			this._destFactor	= Device3D.defaultDestFactor;
			this._programDirty 	= true;
		}
		
		/**
		 * 是否已经被释放 
		 * @return 
		 * 
		 */		
		public function get disposed():Boolean {
			return _disposed;
		}
		
		/** 裁剪 */
		public function get cullFace():String {
			return _cullFace;
		}
		
		/**
		 * @private
		 */
		public function set cullFace(value:String):void {
			_cullFace = value;
			this.validateState();
		}
		
		/** 深度测试条件 */
		public function get depthCompare():String {
			return _depthCompare;
		}
		
		/**
		 * @private
		 */
		public function set depthCompare(value:String):void {
			_depthCompare = value;
			this.validateState();
		}
		
		/** 深度测试 */
		public function get depthWrite():Boolean {
			return _depthWrite;
		}
		
		/**
		 * @private
		 */
		public function set depthWrite(value:Boolean):void {
			_depthWrite = value;
			this.validateState();
		}
		
		/** 混合模式->destFactor */
		public function get destFactor():String {
			return _destFactor;
		}
		
		/**
		 * @private
		 */
		public function set destFactor(value:String):void {
			_destFactor = value;
			this.validateState();
		}
		
		/** 混合模式->sourceFactor */
		public function get sourceFactor():String {
			return _sourceFactor;
		}
		
		/**
		 * @private
		 */
		public function set sourceFactor(value:String):void {
			_sourceFactor = value;
			this.validateState();
		}
		
		public function get scene() : Scene3D {
			return _scene;
		}
		
		public function set scene(value : Scene3D) : void {
			this._scene = value;
		}

		/**
		 * 获取所有的filter 
		 * @return 
		 * 
		 */		
		public function get filters() : Vector.<Filter3D> {
			return this._filters;
		}
		
		/**
		 * 通过名称获取Filter 
		 * @param name
		 * @return 
		 * 
		 */		
		public function getFilterByName(name : String) : Filter3D {
			for each (var filter : Filter3D in filters) {
				if (filter.name == name) {
					return filter;
				}
			}
			return null;
		}
		
		/**
		 * 通过类型获取Filter 
		 * @param clazz
		 * @return 
		 * 
		 */		
		public function getFilterByClass(clazz : Class) : Filter3D {
			for each (var filter : Filter3D in filters) {
				if (filter is clazz) {
					return filter;
				}
			}
			return null;
		}
		
		/**
		 * 添加一个Filter 
		 * @param filter
		 * 
		 */		
		public function addFilter(filter : Filter3D) : void {
			if (filters.indexOf(filter) == -1) {
				this.filters.push(filter);
				this._programDirty = true;
			}
		}
		
		/**
		 * 移除一个Filter 
		 * @param filter
		 * 
		 */		
		public function removeFilter(filter : Filter3D) : void {
			var idx : int = this.filters.indexOf(filter);
			if (idx != -1) {
				this.filters.splice(idx, 1);
				this._programDirty = true;
			}
		}
		
		/**
		 * 绘制方法 
		 * @param context		context3d
		 * @param mvp			mvp
		 * @param surface		网格数据
		 * @param firstIdx		第一个三角形索引
		 * @param count			三角形数量
		 * 
		 */		
		public function draw(scene3d : Scene3D, object3d : Object3D, surface : Surface3D, firstIdx : int = 0, count : int = -1) : void {
			if (!this.scene || this._programDirty) {
				this.upload(scene3d);
			}
			if (!surface.scene) {
				surface.upload(scene3d);
			}
			var context : Context3D = scene3d.context3d;
			// 修改混合、深度测试、裁减
			if (_stateDirty) {
				context.setBlendFactors(sourceFactor, destFactor);
				context.setDepthTest(depthWrite, depthCompare);
				context.setCulling(cullFace);
			}
						
			Device3D.mvp.copyFrom(object3d.transform.world);
			Device3D.mvp.append(scene3d.camera.viewProjection);
						
			scene3d.context3d.setProgram(_program);
			setContextDatas(context, surface);
			// mvp
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, regCache.vcMvp.index, Device3D.mvp, true);
			context.drawTriangles(surface.indexBuffer, firstIdx, count);
			clearContextDatas(context);
			
			// 重置回默认状态
			if (_stateDirty) {
				context.setBlendFactors(Device3D.defaultSourceFactor, Device3D.defaultDestFactor);
				context.setDepthTest(Device3D.defaultDepthWrite, Device3D.defaultCompare);
				context.setCulling(Device3D.defaultCullFace);
			}
		}
		
		private function clearContextDatas(context : Context3D) : void {
			for each (var va : ShaderRegisterElement in regCache.vas) {
				if (va) {
					context.setVertexBufferAt(va.index, null);
				}
			}
			for each (var fs : FsRegisterLabel in regCache.fsUsed) {
				context.setTextureAt(fs.fs.index, null);
			}
		}
		
		/**
		 * 设置context数据 
		 * @param context	context
		 * @param surface	网格数据
		 * 
		 */		
		private function setContextDatas(context : Context3D, surface : Surface3D) : void {
			var i   : int = 0;
			var len : int = regCache.vas.length;
			// 设置va数据
			for (i = 0; i < len; i++) {
				var va : ShaderRegisterElement = regCache.vas[i];
				if (va) {
					context.setVertexBufferAt(va.index, surface.vertexBuffers[i], 0, surface.formats[i]);
				}
			}
			// 设置vc数据
			for each (var vcLabel : VcRegisterLabel in regCache.vcUsed) {
				if (vcLabel.vector) {
					context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcLabel.vc.index, vcLabel.vector, vcLabel.num);
				} else if (vcLabel.matrix) {
					context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, vcLabel.vc.index, vcLabel.matrix, true);
				} else {
					context.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, vcLabel.vc.index, vcLabel.num, vcLabel.bytes, 0);
				}
			}
			// 设置fc
			for each (var fcLabel : FcRegisterLabel in regCache.fcUsed) {
				if (fcLabel.vector) {
					// vector频率使用得最高
					context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, fcLabel.fc.index, fcLabel.vector, fcLabel.num);
				} else if (fcLabel.matrix) {
					// matrix其次
					context.setProgramConstantsFromMatrix(Context3DProgramType.FRAGMENT, fcLabel.fc.index, fcLabel.matrix, true);
				} else {
					// bytes最后
					context.setProgramConstantsFromByteArray(Context3DProgramType.FRAGMENT, fcLabel.fc.index, fcLabel.num, fcLabel.bytes, 0);
				}
			}
			// 设置fs
			for each (var fsLabel : FsRegisterLabel in regCache.fsUsed) {
				context.setTextureAt(fsLabel.fs.index, fsLabel.texture.texture);
			}
		}
		
		public function download() : void {
			if (this._scene) {
				this._scene.removeEventListener(Scene3D.CREATE, this.context3DEvent);
				this._scene = null;
			}
			if (this._program) {
				this._program.dispose();
				this._program = null;
			}
			if (this.regCache) {
				this.regCache.dispose();
				this.regCache = null;
			}
			this._programDirty = true;
		}
		
		/**
		 * 上传 
		 * @param context
		 * 
		 */		
		public function upload(scene : Scene3D) : void {
			if (_scene == scene) {
				return;
			}
			if (!_programDirty) {
				return;
			}
			this._scene = scene;
			if (scene.context3d) {
				this.context3DEvent();
			}
			scene.addEventListener(Scene3D.CREATE, context3DEvent);
		}
		
		/**
		 * context3d event 
		 * @param event
		 * 
		 */		
		private function context3DEvent(event : Event = null) : void {
			this.build();
		}
		
		/**
		 * build 
		 */		
		public function build() : void {
			if (!scene || !this._programDirty) {
				return;
			}
			var temp : Scene3D = this.scene;
			this.download();
			this._scene = temp;
			
			this.regCache = new ShaderRegisterCache();
			
			var fragCode : String = buildFragmentCode();
			var vertCode : String = buildVertexCode();
			
			var vertAgal : AGALMiniAssembler = new AGALMiniAssembler();
			vertAgal.assemble(Context3DProgramType.VERTEX, vertCode);
			var fragAgal : AGALMiniAssembler = new AGALMiniAssembler();
			fragAgal.assemble(Context3DProgramType.FRAGMENT, fragCode);
			
			if (Device3D.debug) {
				trace('---------程序开始------------');
				trace('---------顶点程序------------');
				trace(vertCode);
				trace('---------片段程序------------');
				trace(fragCode);
				trace('---------程序结束------------');
			}
						
			this._program = scene.context3d.createProgram();
			this._program.upload(vertAgal.agalcode, fragAgal.agalcode);
			this._programDirty = false;
		}
		
		/**
		 * 构建片段着色程序 
		 * 最先构建片段着色程序，因为只有最先构建了片段着色程序之后，在顶点程序中才只能，片段着色程序需要使用到哪些V变量。
		 * @return 
		 * 
		 */		
		private function buildFragmentCode() : String {
			// 对oc进行初始化
			var code : String = "mov " + regCache.oc + ", " + regCache.fc0123 + ".yyyy \n";
			for each (var filter : Filter3D in filters) {
				code += filter.getFragmentCode(regCache, true);
			}
			code += "mov oc, " + regCache.oc + " \n";
			return code;
		}
		
		/**
		 * 构建顶点着色程序 
		 * @return 
		 * 
		 */		
		private function buildVertexCode() : String {
			// 对op进行初始化
			var code : String = "mov " + regCache.op + ", " + regCache.getVa(Surface3D.POSITION) + " \n"; 
			// 开始对v变量进行赋值,vs是所有在片段程序中使用到的v变量,通过getV()获取,vs数组索引就是surface3d对应数据类型
			var length : int = regCache.vs.length;		
			for (var i:int = 0; i < length; i++) {
				if (regCache.vs[i]) {
					code += "mov " + regCache.getV(i) + ", " + regCache.getVa(i) + " \n";
				}
			}
			// 拼接filter的顶点shader
			for each (var filter : Filter3D in filters) {
				code += filter.getVertexCode(regCache, true);
			}
			// 对filter拼接完成之后，将regCache.op输出到真正的op寄存器
			code += "m44 op, " + regCache.op + ", " + regCache.vcMvp + " \n";
			return code;
		}
		
		/**
		 * 释放 
		 */		
		public function dispose() : void {
			if (disposed) {
				return;
			}
			this.download();
			this._disposed= true;
			this._filters = null;
		}
		
		/**
		 * 透明 
		 * @return 
		 */		
		public function get transparent() : Boolean {
			return blendMode == BLEND_ALPHA ? true : false;
		}
		
		/**
		 * 透明 
		 * @param value
		 */		
		public function set transparent(value : Boolean) : void {
			if (value) {
				this.blendMode = BLEND_ALPHA;
			} else {
				this.blendMode = BLEND_NONE;
			}
		}
		
		/**
		 * 双面显示 
		 * @return 
		 */		
		public function get twoSided() : Boolean {
			return this.cullFace == Context3DTriangleFace.NONE;
		}
		
		/**
		 * 双面显示
		 * @param value
		 */
		public function set twoSided(value : Boolean) : void {
			if (value) {
				this.cullFace = Context3DTriangleFace.NONE;
			} else {
				this.cullFace = Context3DTriangleFace.BACK;
			}
			this.validateState();
		}
		
		/**
		 * 混合模式 
		 * @return 
		 * 
		 */		
		public function get blendMode() : String {
			return this._blendMode;
		}
		
		/**
		 * 设置混合模式
		 * @param value
		 */
		public function set blendMode(value : String) : void {
			if (_blendMode == value) {
				return;
			}
			this._blendMode = value;
			switch (this._blendMode) {
				case BLEND_NONE:
					this.sourceFactor 	= Context3DBlendFactor.ONE;
					this.destFactor 	= Context3DBlendFactor.ZERO;
					break;
				case BLEND_ADDITIVE:
					this.sourceFactor 	= Context3DBlendFactor.ONE;
					this.destFactor 	= Context3DBlendFactor.ONE;
					break;
				case BLEND_ALPHA_BLENDED:
					this.sourceFactor 	= Context3DBlendFactor.ONE;
					this.destFactor 	= Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
					break;
				case BLEND_MULTIPLY:
					this.sourceFactor 	= Context3DBlendFactor.DESTINATION_COLOR;
					this.destFactor 	= Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
					break;
				case BLEND_SCREEN:
					this.sourceFactor 	= Context3DBlendFactor.ONE;
					this.destFactor 	= Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR;
					break;
				case BLEND_ALPHA:
					this.sourceFactor 	= Context3DBlendFactor.SOURCE_ALPHA;
					this.destFactor 	= Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
					break;
			}
			this.validateState();
		}
		
		private function validateState() : void {
			this._stateDirty = true;
			if (this.sourceFactor 	== Device3D.defaultSourceFactor &&
				this.destFactor		== Device3D.defaultDestFactor	&&
				this.depthCompare	== Device3D.defaultCompare		&&
				this.depthWrite		== Device3D.defaultDepthWrite	&&
				this.cullFace		== Device3D.defaultCullFace) {
				this._stateDirty = false;
			}
		}
		
	}
}
