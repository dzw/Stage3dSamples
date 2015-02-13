package f3d.core.shader.utils {
	
	import f3d.core.base.Surface3D;

	public class ShaderRegisterCache {
		
		/** 使用的fs寄存器 */
		public var fsUsed : Vector.<FsRegisterLabel>;
		/** 使用的vc寄存器 */
		public var vcUsed : Vector.<VcRegisterLabel>;
		/** 使用的fc寄存器 */
		public var fcUsed : Vector.<FcRegisterLabel>;
		
		private var _vtPool : RegisterPool;	// vt
		private var _vcPool : RegisterPool; // vc
		private var _vaPool : RegisterPool; // va
		private var _vPool	: RegisterPool; // v
		private var _ftPool : RegisterPool; // ft
		private var _fcPool : RegisterPool; // fc
		private var _fsPool : RegisterPool; // fs
		
		private var _op : ShaderRegisterElement;	// op
		private var _oc : ShaderRegisterElement;	// oc
		
		private var _vcMvp  : ShaderRegisterElement;	// mvp vc
		private var _vc0123 : ShaderRegisterElement;	// 0123常量是我们最经常用到的，因此缓存
		private var _fc0123 : ShaderRegisterElement;	// 0123常量是我们最经常用到的，因此缓存
		
		private var _vas : Vector.<ShaderRegisterElement>;
		private var _vs  : Vector.<ShaderRegisterElement>;
		
		public function ShaderRegisterCache() {
			this.fsUsed = new Vector.<FsRegisterLabel>();
			this.vcUsed = new Vector.<VcRegisterLabel>();
			this.fcUsed = new Vector.<FcRegisterLabel>();
			this._vas = new Vector.<ShaderRegisterElement>(Surface3D.LENGTH, true);
			this._vs  = new Vector.<ShaderRegisterElement>(Surface3D.LENGTH, true);
			this._ftPool = new RegisterPool("ft", 8);
			this._vtPool = new RegisterPool("vt", 8);
			this._vPool  = new RegisterPool("v",  8);
			this._fsPool = new RegisterPool("fs", 8);
			this._vaPool = new RegisterPool("va", 8);
			this._fcPool = new RegisterPool("fc", 28);
			this._vcPool = new RegisterPool("vc", 128);
			this._op = this.getVt();
			this._oc = this.getFt();
		}

		/**
		 * 销毁 
		 */		
		public function dispose() : void {
			this._ftPool.dispose();
			this._vtPool.dispose();
			this._vPool.dispose();
			this._fsPool.dispose();
			this._vaPool.dispose();
			this._fcPool.dispose();
			this._vcPool.dispose();
		}
				
		/**
		 * 获取mvp
		 * @return 
		 * 
		 */		
		public function get vcMvp() : ShaderRegisterElement {
			if (!_vcMvp) {
				_vcMvp = getVc();	// mvp为一个矩阵，需要四个寄存器
				getVc();
				getVc();
				getVc();
			}
			return _vcMvp;
		}
		
		public function get fc0123() : ShaderRegisterElement {
			if (!_fc0123) {
				_fc0123 = getFc();
				fcUsed.push(new FcRegisterLabel(_fc0123, Vector.<Number>([0, 1, 2, 3])));
			}
			return _fc0123;
		}
		
		public function get vc0123() : ShaderRegisterElement {
			if (!_vc0123) {
				_vc0123 = getVc();
				vcUsed.push(new VcRegisterLabel(_vc0123, Vector.<Number>([0, 1, 2, 3])));
			}
			return _vc0123;
		}
		
		public function get op() : ShaderRegisterElement {
			return _op;
		}
		
		public function get oc() : ShaderRegisterElement {
			return _oc;
		}
		
		public function get vas() : Vector.<ShaderRegisterElement> {
			return _vas;
		}
		
		public function get vs() : Vector.<ShaderRegisterElement> {
			return _vs;
		}
		
		/**
		 * 申请一个vt临时寄存器 
		 * @return 
		 * 
		 */		
		public function getVt() : ShaderRegisterElement {
			return this._vtPool.requestReg();
		}
		
		/**
		 * 归还一个vt临时寄存器 
		 * @param vt
		 * 
		 */		
		public function removeVt(vt : ShaderRegisterElement) : void {
			this._vtPool.removeUsage(vt);
		}
		
		/**
		 * 获取一个vc寄存器 
		 * @return 
		 * 
		 */		
		public function getVc() : ShaderRegisterElement {
			return this._vcPool.requestReg();
		}
		
		/**
		 * 获取一个fc寄存器 
		 * @return 
		 * 
		 */		
		public function getFc() : ShaderRegisterElement {
			return this._fcPool.requestReg();
		}
		
		/**
		 * 申请一个ft临时寄存器 
		 * @return 
		 * 
		 */		
		public function getFt() : ShaderRegisterElement {
			return this._ftPool.requestReg();
		}
		
		/**
		 * 申请一个fs寄存器 
		 * @return 
		 * 
		 */		
		public function getFs() : ShaderRegisterElement {
			return this._fsPool.requestReg();
		}
		
		/**
		 * 获取Surface3D对应的Va 
		 * @param type	Surface3D数据类型
		 * @return 
		 * 
		 */		
		public function getVa(type : int) : ShaderRegisterElement {
			if (!_vas[type]) {
				_vas[type] = getFreeVa();
			}
			return this._vas[type];
		}
		
		/**
		 * 获取Surface3D对应的V 
		 * @param type	Surface3D数据类型
		 * @return 
		 * 
		 */		
		public function getV(type : int) : ShaderRegisterElement {
			if (!_vs[type]) {
				_vs[type] = getFreeV();
			}
			return this._vs[type];
		}
		
		/**
		 * 申请一个空闲的va 
		 * @return 
		 * 
		 */		
		public function getFreeVa() : ShaderRegisterElement {
			return this._vaPool.requestReg();
		}
		
		/**
		 * 申请一个空闲的V 
		 * @return 
		 * 
		 */		
		public function getFreeV() : ShaderRegisterElement {
			return this._vPool.requestReg();
		}
		
		/**
		 * 归还一个ft临时寄存器 
		 * @param ft
		 * 
		 */		
		public function removeFt(ft : ShaderRegisterElement) : void {
			this._ftPool.removeUsage(ft);
		}
		
		
		
	}
}
