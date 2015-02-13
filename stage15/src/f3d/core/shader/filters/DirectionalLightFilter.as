package f3d.core.shader.filters {

	import flash.geom.Vector3D;
	
	import f3d.core.base.Surface3D;
	import f3d.core.shader.utils.FcRegisterLabel;
	import f3d.core.shader.utils.ShaderRegisterCache;
	import f3d.core.shader.utils.ShaderRegisterElement;

	public class DirectionalLightFilter extends LightFilter {
		
		private var _dirData		: Vector.<Number>;		// 方向数据
		private var _eyeData		: Vector.<Number>;		// 观察者位置
		private var _specular 		: uint;					// 高光
		private var _specularData	: Vector.<Number>;		// 高光数据
		private var _power 			: Number = 50;			// 高光强度
		
		public function DirectionalLightFilter() {
			this._specularData 	= Vector.<Number>([1, 1, 1, 1]);
			this._eyeData 		= Vector.<Number>([0, 0, 1, 0]);
			this._dirData 		= Vector.<Number>([0, 0, -1, 0]);
			this.specular 		= 0x000000;
			this.dirData 		= new Vector3D(0, 0, 1);
			this.lightColor 	= 0xFF0000;
			this.ambient 		= 0x555555;
			this.specular 		= 0xFFFFFF;
			this.power 			= 50;
		}
		
		/**
		 * 高光强度
		 * @param value
		 *
		 */
		public function set power(value : Number) : void {
			this._power = value;
			this._specularData[3] = value;
		}
		
		public function get power() : Number {
			return _power;
		}
		
		public function get specular() : uint {
			return _specular;
		}
		
		/**
		 * 高光颜色
		 * @param value
		 * 
		 */		
		public function set specular(value : uint) : void {
			this._specular = value;
			this._specularData[0] = (int(value >> 16) & 0xFF) / 0xFF;
			this._specularData[1] = (int(value >> 8) & 0xFF) / 0xFF;
			this._specularData[2] = (int(value >> 0) & 0xFF) / 0xFF;
		}
		
		private function set eyeData(pos : Vector3D):void {
			this._eyeData[0] = pos.x;
			this._eyeData[1] = pos.y;
			this._eyeData[2] = pos.z;
		}
		
		private function set dirData(dir : Vector3D):void {
			dir.normalize();
			this._dirData[0] = -dir.x;
			this._dirData[1] = -dir.y;
			this._dirData[2] = -dir.z;
			this._dirData[3] = 0;
		}
				
		override public function getFragmentCode(regCache : ShaderRegisterCache, agal : Boolean):String {
			
			var eyeFc    : ShaderRegisterElement = regCache.getFc();
			regCache.fcUsed.push(new FcRegisterLabel(eyeFc, _eyeData));
			var specuFc  : ShaderRegisterElement = regCache.getFc();
			regCache.fcUsed.push(new FcRegisterLabel(specuFc, _specularData));
			var lightDir : ShaderRegisterElement = regCache.getFc();
			regCache.fcUsed.push(new FcRegisterLabel(lightDir, _dirData));
			var colorFc  : ShaderRegisterElement = regCache.getFc();
			regCache.fcUsed.push(new FcRegisterLabel(colorFc, _lightData));
			var ambFc    : ShaderRegisterElement = regCache.getFc();
			regCache.fcUsed.push(new FcRegisterLabel(ambFc, _ambientData));
			
			var ft0 : ShaderRegisterElement = regCache.getFt();
			var ft1 : ShaderRegisterElement = regCache.getFt();	
			var ft2 : ShaderRegisterElement = regCache.getFt();
			
			var code : String = '';
			
			if (agal) {
				// 赋值为纯白色
				code += 'mov ' + regCache.oc + '.xyz, ' + regCache.fc0123 + '.yyy \n';
				// 法线ft0
				code += 'mov ' + ft0 + '.xyz, ' + regCache.getV(Surface3D.NORMAL) + '.xyz \n';
				// 法线ft1
				code += 'sub ' + ft1 + '.xyz, ' + eyeFc + '.xyz, ' + regCache.getV(Surface3D.POSITION) + " \n";
				code += 'nrm ' + ft1 + '.xyz, ' + ft1 + '.xyz \n';
				// 高光
				code += 'add ' + ft2 + '.xyz, ' + lightDir + '.xyz, ' + ft1 + '.xyz \n';
				code += 'nrm ' + ft2 + '.xyz, ' + ft2 + '.xyz \n';
				code += 'dp3 ' + ft2 + '.w, ' + ft0 + '.xyz, ' + ft2 + '.xyz \n';
				code += 'max ' + ft2 + '.w, ' + ft2 + '.w, ' + regCache.fc0123 + '.x \n';
				code += 'pow ' + ft2 + '.w, ' + ft2 + '.w, ' + specuFc + '.w \n';
				// 灯光
				code += 'dp3 ' + ft0 + '.w, ' + ft0 + '.xyz, ' + lightDir + '.xyz \n';
				code += 'max ' + ft0 + '.w, ' + ft0 + '.w, ' + regCache.fc0123 + '.x \n';
				code += 'mul ' + ft0 + '.xyz, ' + colorFc + '.xyz, ' + ft0 + '.w \n';
				// 灯光颜色+环境色
				code += 'add ' + ft0 + '.xyz, ' + ft0 + '.xyz, ' + ambFc + '.xyz \n';
				code += 'mul ' + ft0 + '.xyz, ' + ft0 + '.xyz, ' + regCache.oc + '.xyz \n';
				// 最终结果
				code += 'mul ' + ft2 + '.xyz, ' + ft2 + '.w, ' + specuFc + '.xyz \n';
				code += 'add ' + ft0 + '.xyz, ' + ft0 + '.xyz, ' + ft2 + '.xyz \n';
				code += 'mov ' + regCache.oc + '.xyz, ' + ft0 + '.xyz \n';
			}
			
			regCache.removeFt(ft0);
			regCache.removeFt(ft1);
			regCache.removeFt(ft2);
			
			return code;
		}
				
	}
}
