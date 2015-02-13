package f3d.core.shader.filters {

	import flash.geom.Vector3D;
	
	import f3d.core.base.Surface3D;
	import f3d.core.shader.utils.FcRegisterLabel;
	import f3d.core.shader.utils.ShaderRegisterCache;
	import f3d.core.shader.utils.ShaderRegisterElement;

	public class PointLightFilter extends LightFilter {
		
		private static var temp : Vector3D = new Vector3D();

		private var _pointData 	: Vector.<Number>;
		
		public function PointLightFilter() {
			this._pointData = Vector.<Number>([0, 100, 0, 10000]);
			this.ambient 	= 0x555555;
			this.lightColor = 0xFF0000;
		}
		
		/**
		 * 设置灯光颜色 
		 * @param value
		 */		
		override public function set lightColor(value : uint) : void {
			// 3 为强度
			this._lightColor = value;
			this._lightData[0] = (int(value >> 16) & 0xFF) / 0xFF * 3;
			this._lightData[1] = (int(value >> 8) & 0xFF)  / 0xFF * 3;
			this._lightData[2] = (int(value >> 0) & 0xFF)  / 0xFF * 3;
			this._lightData[3] = 0;
		}
		
		override public function getFragmentCode(regCache : ShaderRegisterCache, agal : Boolean) : String {
			
			var ft1 : ShaderRegisterElement = regCache.getFt();
			var ft2 : ShaderRegisterElement = regCache.getFt();
			var ft3 : ShaderRegisterElement = regCache.getFt();
			var ft4 : ShaderRegisterElement = regCache.getFt();

			var posFc : ShaderRegisterElement = regCache.getFc();
			regCache.fcUsed.push(new FcRegisterLabel(posFc, _pointData));
			var difFc : ShaderRegisterElement = regCache.getFc();
			regCache.fcUsed.push(new FcRegisterLabel(difFc, _lightData));
			var ambFc : ShaderRegisterElement = regCache.getFc();
			regCache.fcUsed.push(new FcRegisterLabel(ambFc, _ambientData));

			var code : String = "";
			
			code += "mov " + regCache.oc + ".xyz, " + regCache.fc0123 + ".yyy \n";
			code += "mov " + ft1 + ", " + regCache.fc0123 + ".xxxx \n";
			code += "nrm " + ft1 + ".xyz, " + regCache.getV(Surface3D.NORMAL) + " \n";
			code += "mov " + ft1 + ".w, " + regCache.fc0123 + ".x \n";
			code += "mov " + ft2 + ".xyzw, " + regCache.fc0123 + ".xxxx \n";
			code += "sub " + ft2 + ", " + posFc + ", " + regCache.getV(Surface3D.POSITION) + ".xyzx \n";
			code += "dp3 " + ft1 + ".w, " + ft2 + ", " + ft2 + " \n";
			code += "div " + ft4 + ", " + ft1 + ".w, " + posFc + ".w \n";
			code += "sub " + ft1 + ".w, " + regCache.fc0123 + ".y, " + ft4 + ".x \n";
			code += "max " + ft4 + ".x, " + ft1 + ".w, " + difFc + ".w \n";
			code += "nrm " + ft2 + ".xyz, " + ft2 + " \n";
			code += "dp3 " + ft1 + ".w, " + ft1 + ", " + ft2 + " \n";
			code += "mul " + ft2 + ", " + difFc + ", " + ft4 + ".xxxx \n";
			code += "max " + ft1 + ".x, " + ft1 + ".w, " + regCache.fc0123 + ".x \n";
			code += "mul " + ft4 + ", " + ft1 + ".xxxx, " + ft2 + " \n";
			code += "mov " + ft3 + ", " + ft4 + " \n";
			code += "add " + ft3 + ", " + ft3 + ", " + ambFc + " \n";
			code += "mul " + ft3 + ", " + ft3 + ", " + regCache.oc + " \n";
			code += "mov " + ft3 + ".w, " + regCache.oc + ".w \n";
			code += "sat " + regCache.oc + ", " + ft3 + " \n";

			regCache.removeFt(ft1);
			regCache.removeFt(ft2);
			regCache.removeFt(ft3);
			regCache.removeFt(ft4);

			return code;
		}

	}
}
