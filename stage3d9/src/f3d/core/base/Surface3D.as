package f3d.core.base {
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;

	/**
	 * 网格数据 
	 * @author Neil
	 * 
	 */	
	public class Surface3D {
		
		/** 顶点 */
		public static const POSITION	: int = 0;
		/** uv0,默认uv */
		public static const UV0			: int = 1;
		/** 数据格式数量 */
		public static const LENGTH 		: int = 2;
		
		/** 数据格式 */
		public var formats 		 : Vector.<String>;
		/** 浮点型数据源 */
		public var sources  	 : Vector.<Vector.<Number>>;
		/** buffers */
		public var vertexBuffers : Vector.<VertexBuffer3D>;
		/** 索引Buffer */
		public var indexBuffer	 : IndexBuffer3D;
		/** 三角形数量 */
		public var numTriangles	 : int;
		
		private var _indexVector : Vector.<uint>;			// 索引数据
		private var _context 	 : Context3D;				// context
		
		public function Surface3D() {
			this.formats = new Vector.<String>(LENGTH, true);
			this.sources  = new Vector.<Vector.<Number>>(LENGTH, true);
			this.vertexBuffers = new Vector.<VertexBuffer3D>(LENGTH, true);
			for (var i:int = 0; i < LENGTH; i++) {
				this.formats[i] = null;
			}
		}
		
		/**
		 * 获取索引
		 * @return 
		 * 
		 */		
		public function get indexVector():Vector.<uint> {
			if (!_indexVector) {
				this._indexVector = new Vector.<uint>();
				var size : int = getSizeByFormat(formats[POSITION]); 
				var numVertices : int = sources[POSITION].length / size;
				var i : uint = 0;
				while (i < numVertices) {
					this._indexVector.push(i);
					i++;
				}
			}
			return _indexVector;
		}
		
		/**
		 * 设置索引 
		 * @param value
		 * 
		 */		
		public function set indexVector(value:Vector.<uint>):void {
			_indexVector = value;
		}

		/**
		 * context 
		 * @return 
		 * 
		 */		
		public function get context():Context3D {
			return _context;
		}

		/**
		 * context 
		 * @param value
		 * 
		 */		
		public function set context(value:Context3D):void {
			_context = value;
		}
		
		/**
		 * 设置数据源 
		 * @param type		数据类型
		 * @param data		数据
		 * @param size		长度
		 * 
		 */		
		public function setVertexDataVector(type : int, data : Vector.<Number>, size : int) : void {
			this.formats[type] = "float" + size;
			this.sources[type] = data;
		}
		
		/**
		 * 卸载 
		 * 
		 */		
		public function download() : void {
			this.context = null;
			for (var i:int = 0; i < LENGTH; i++) {
				if (!vertexBuffers[i]) {
					continue;
				}
				this.vertexBuffers[i].dispose();
				this.vertexBuffers[i] = null;
			}
			if (this.indexBuffer) {
				this.indexBuffer.dispose();
				this.indexBuffer = null;
			}
		}
		
		/**
		 * 上传 
		 * @param context
		 * 
		 */		
		public function upload(context : Context3D) : void {
			if (this.context) {
				return;
			}
			this.context = context;
			this.contextEvent();
		}
		
		/**
		 * context event
		 */
		private function contextEvent() : void {
			this.updateVertexBuffer();
			this.updateIndexBuffer();
		}
		
		/**
		 * 更新索引buffer 
		 * 
		 */		
		public function updateIndexBuffer() : void {
			if (!this.context) {
				return;
			}
			if (this.indexBuffer) {
				this.indexBuffer.dispose();
			}
			var size : int = indexVector.length;
			this.indexBuffer = context.createIndexBuffer(size);
			this.indexBuffer.uploadFromVector(indexVector, 0, size);
			this.numTriangles = size / 3;
		}
		
		/**
		 * 更新顶点buffer 
		 */		
		public function updateVertexBuffer() : void {
			if (!context) {
				return;
			}
			var num  : int = -1;
			var size : int = -1;
			for (var i:int = 0; i < LENGTH; i++) {
				if (!sources[i]) {
					continue;	
				}
				if (vertexBuffers[i]) {
					vertexBuffers[i].dispose();
				}
				size = getSizeByFormat(formats[i]);
				num  = sources[i].length / size;
				this.vertexBuffers[i] = this.context.createVertexBuffer(num, size);
				this.vertexBuffers[i].uploadFromVector(sources[i], 0, num);
			}
		}
		
		/**
		 * 根据format获取尺寸 
		 * @param format
		 * @return 
		 * 
		 */		
		private function getSizeByFormat(format : String) : int {
			switch(format) {
				case Context3DVertexBufferFormat.FLOAT_1: {
					return 1;
					break;
				}
				case Context3DVertexBufferFormat.FLOAT_2: {
					return 2;
					break;
				}
				case Context3DVertexBufferFormat.FLOAT_3: {
					return 3;
					break;
				}
				case Context3DVertexBufferFormat.FLOAT_4: {
					return 3;
					break;
				}
			}
			return -1;
		}
		
		/**
		 * 销毁surface3d 
		 * 
		 */		
		public function dispose() : void {
			this.download();
			for (var i:int = 0; i < LENGTH; i++) {
				if (!sources[i]) {
					continue;
				}
				this.sources[i].length = 0;
				this.sources[i] = null;
			}
		}
	}
}
