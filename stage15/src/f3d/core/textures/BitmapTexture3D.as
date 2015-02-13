package f3d.core.textures {

	import flash.display.BitmapData;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import f3d.core.base.Texture3D;

	public class BitmapTexture3D extends Texture3D {
		
		private var _bitmapData  : BitmapData;
		private var _transparent : Boolean;
		
		/**
		 * 必须为2的幂 
		 * @param bitmapdata
		 * 
		 */		
		public function BitmapTexture3D(bitmapdata : BitmapData) {
			super();
			this.bitmapData = bitmapdata;
			this.type 		= TYPE_2D;
			this.filterType = FILTER_LINEAR;
			this.wrapType   = WRAP_REPEAT;
			this.mipType	= MIP_LINEAR;
			this.width  	= bitmapdata.width;
			this.height 	= bitmapdata.height;
			this._transparent = bitmapdata.transparent;
		}
				
		override protected function contextEvent(e : Event = null) : void {
			if (this.texture) {
				this.texture.dispose();
			}
			this.uploadWithMips();
		}
		
		private function uploadWithMips() : void {
			
			texture = scene.context3d.createTexture(width, height, Context3DTextureFormat.BGRA, false);
						
			if (mipType == MIP_NONE) {
				Texture(texture).uploadFromBitmapData(bitmapData);
				return;
			} 
			
			// mip
			var w 		: int = width;
			var h 		: int = height;
			var miplevel: int = 0;
			var mat		: Matrix 	 = new Matrix();
			var mipRect : Rectangle  = new Rectangle();
			var oldMips : BitmapData = null;
			var levels	: BitmapData = null;
			while (w >= 1 || h >= 1) {
				if (w == width && h === height) {
					levels = bitmapData;
				} else {
					levels = new BitmapData(w, h, _transparent, 0);
					levels.draw(oldMips, mat, null, null, mipRect, true);
				}
				Texture(texture).uploadFromBitmapData(levels, miplevel);
				oldMips = levels;
				mat.a = 0.5;
				mat.d = 0.5;
				w = w >> 1;
				h = h >> 1;
				mipRect.width  = w;
				mipRect.height = h;
				miplevel++;
			}
		}
		
		public function get bitmapData() : BitmapData {
			return _bitmapData;
		}

		public function set bitmapData(value : BitmapData) : void {
			_bitmapData = value;
		}

	}
}