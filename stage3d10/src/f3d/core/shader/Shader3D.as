package f3d.core.shader {

	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
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
	import f3d.core.utils.Device3D;
	
	/**
	 * shader 
	 * @author Neil
	 * 
	 */	
	public class Shader3D extends EventDispatcher {
		
		public var name : String;
		
		private var _filters 	: Vector.<Filter3D>;		// 所有的filter
		private var _scene		: Scene3D;					// scene3d
		private var _needBuild 	: Boolean;					// 需要build
		private var regCache    : ShaderRegisterCache;		// 寄存器管理器
		private var program		: Program3D;				// program
		
		public function Shader3D(filters : Array) {
			super(null);
			this.name = "";
			this._filters   = Vector.<Filter3D>(filters);
			this._needBuild = true;
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
				this._needBuild = true;
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
				this._needBuild = true;
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
			if (!this.scene) {
				this.upload(scene3d);
			}
			if (!surface.scene) {
				surface.upload(scene3d);
			}
			
			Device3D.mvp.copyFrom(object3d.transform.world);
			Device3D.mvp.append(scene3d.camera.viewProjection);
			
			scene3d.context3d.setProgram(program);
			setContextDatas(scene3d.context3d, surface);
			// mvp
			scene3d.context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, regCache.vcMvp.index, Device3D.mvp, true);
			scene3d.context3d.drawTriangles(surface.indexBuffer, firstIdx, count);
			clearContextDatas(scene3d.context3d);
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
				context.setTextureAt(fsLabel.fs.index, fsLabel.texture);
			}
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
			this._scene = scene;
			this.context3DEvent();
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
			if (!scene || !this._needBuild) {
				return;
			}
			if (this.regCache) {
				this.regCache.dispose();
			}
			if (this.program) {
				this.program.dispose();
			}
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
						
			this.program = scene.context3d.createProgram();
			this.program.upload(vertAgal.agalcode, fragAgal.agalcode);
			this._needBuild = false;
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
		
	}
}
