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
		
		private static const LENGTH 	: int = 2;
		
		/** 数据格式 */
		public var formats 		 : Vector.<String>;
		/** 浮点型数据源 */
		public var sourceVector  : Vector.<Vector.<Number>>;
		/** buffers */
		public var vertexBuffers : Vector.<VertexBuffer3D>;
		/** 索引Buffer */
		public var indexBuffer	 : IndexBuffer3D;
		/** 三角形数量 */
		public var numTriangles	 : int;
		
		private var _indexVector : Vector.<uint>;
		private var _context 	 : Context3D;
		
		public function Surface3D() {
			this.formats = new Vector.<String>(LENGTH, true);
			this.sourceVector  = new Vector.<Vector.<Number>>(LENGTH, true);
			this.vertexBuffers = new Vector.<VertexBuffer3D>(LENGTH, true);
			for (var i:int = 0; i < LENGTH; i++) {
				this.formats[i] = null;
			}
		}
		
		/** 索引数据 */
		public function get indexVector():Vector.<uint> {
			if (!_indexVector) {
				this._indexVector = new Vector.<uint>();
				var size : int = getSizeByFormat(formats[POSITION]); 
				var numVertices : int = sourceVector[POSITION].length / size;
				var i : uint = 0;
				while (i < numVertices) {
					this._indexVector.push(i);
					i++;
				}
			}
			return _indexVector;
		}
		
		/**
		 * @private
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
		 * @param type
		 * @param data
		 * @param size
		 * 
		 */		
		public function setVertexDataVector(type : int, data : Vector.<Number>, size : int) : void {
			this.formats[type] = "float" + size;
			this.sourceVector[type] = data;
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
				vertexBuffers[i].dispose();
				vertexBuffers[i] = null;
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
			this.indexBuffer = context.createIndexBuffer(indexVector.length);
			this.indexBuffer.uploadFromVector(indexVector, 0, indexVector.length);
			this.numTriangles = indexVector.length / 3;
		}
		
		/**
		 * 更新顶点buffer 
		 */		
		public function updateVertexBuffer() : void {
			if (!context) {
				return;
			}
			var numVertices : int = -1;
			var size : int = -1;
			for (var i:int = 0; i < LENGTH; i++) {
				if (!sourceVector[i]) {
					continue;	
				}
				if (vertexBuffers[i]) {
					vertexBuffers[i].dispose();
				}
				size = getSizeByFormat(formats[i]);
				numVertices = sourceVector[i].length / size;
				vertexBuffers[i] = this.context.createVertexBuffer(numVertices, size);
				vertexBuffers[i].uploadFromVector(sourceVector[i], 0, numVertices);
			}
		}
		
		private function getSizeByFormat(format : String) : int {
			if (format == Context3DVertexBufferFormat.FLOAT_1) {
				return 1;
			} else if (format == Context3DVertexBufferFormat.FLOAT_2) {
				return 2;
			} else if (format == Context3DVertexBufferFormat.FLOAT_3) {
				return 3;
			} else if (format == Context3DVertexBufferFormat.FLOAT_4) {
				return 4;
			}
			return -1;
		}
		
		public function dispose() : void {
			this.download();
			for (var i:int = 0; i < LENGTH; i++) {
				if (!sourceVector[i]) {
					continue;
				}
				sourceVector[i].length = 0;
				sourceVector[i] = null;
			}
		}
	}
}
