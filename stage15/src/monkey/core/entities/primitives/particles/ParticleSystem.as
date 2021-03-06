package monkey.core.entities.primitives.particles {

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.entities.primitives.Plane;
	import monkey.core.entities.primitives.particles.prop.color.PropColor;
	import monkey.core.entities.primitives.particles.prop.color.PropGridientColor;
	import monkey.core.entities.primitives.particles.prop.value.PropConst;
	import monkey.core.entities.primitives.particles.prop.value.PropData;
	import monkey.core.entities.primitives.particles.prop.value.PropRandomTwoConst;
	import monkey.core.entities.primitives.particles.shape.ParticleShape;
	import monkey.core.entities.primitives.particles.shape.SphereShape;
	import monkey.core.interfaces.IComponent;
	import monkey.core.materials.ParticleMaterial;
	import monkey.core.scene.Scene3D;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.GridientColor;
	import monkey.core.utils.Matrix3DUtils;
	import monkey.core.utils.Time3D;
	
	/**
	 * 仿unity3d粒子系统。
	 * 粒子数量有限制，根据shape模型的三角面进行限制。particleSystem不会进行数据分割。
	 * @author Neil
	 * 
	 */	
	public class ParticleSystem extends Object3D {
		
		/** 粒子动画播放完成 */
		public static const COMPLETE		: String = "ParticleSystem:COMPLETE";
		
		private static const completeEvent : Event = new Event(COMPLETE);			// 播放完成事件
		
		/** matrix临时变量 */
		private static const matrix3d 	: Matrix3D = new Matrix3D();
		/** vector临时变量 */
		private static const vector3d 	: Vector3D = new Vector3D();
		
		[Embed(source="ParticleSystem.png")]
		private static const DEFAULT_IMG: Class;
		/** 默认关键帧 */
		private static var _defKeyframe : ByteArray;
		
		private var _surface   			: Surface3D;					// 粒子数据
		private var _duration 			: Number; 						// 持续发射时间
		private var _loops 				: int; 							// 循环发射模式
		private var loopCount			: int;							// 循环计数器
		private var _startDelay 		: Number; 						// 开始延迟时间
		private var _startLifeTime 		: PropData; 					// 生命周期
		private var _startSpeed 		: PropData; 					// 速度
		private var _additionalSpeed	: Vector.<PropRandomTwoConst>;	// 附加速度
		private var _startSize 			: Vector.<PropData>; 			// 初始大小
		private var _startRotation 		: Vector.<PropData>; 			// 初始旋转角度
		private var _startColor 		: PropColor; 					// 初始颜色
		private var _shape 				: ParticleShape; 				// 形状
		private var _simulationSpace 	: Boolean; 						// 坐标系。false:本地；true:世界
		private var _rate 				: int; 							// 发射频率
		private var _bursts 			: Vector.<Point>; 				// 爆炸
		private var _num				: int;							// 粒子数量
		private var _totalTime			: Number;						// 粒子系统的生命周期
		private var _needBuild			: Boolean;						// 是否需要build
		private var _time				: Number = 0;					// 时间
		private var _colorOverLifetime  : GridientColor;				// color over lifetime
		private var _matrixOverLifetime : ByteArray;					// 缩放旋转速度 over lifetime
		private var _image				: BitmapData;					// image
		private var _playing			: Boolean;						// 是否正在播放
		private var texture				: Bitmap2DTexture;				// 粒子贴图
		private var blendTexture   		: Bitmap2DTexture;				// color over lifetime贴图
		private var mesh 				: Mesh3D;						// mesh
		private var material			: ParticleMaterial;				// material
				
		/**
		 *  粒子系统
		 */		
		public function ParticleSystem() {
			super();
			this.init();
		}
		
		/**
		 *  初始化粒子系统参数
		 */		
		private function init() : void {
			this.material 		 = new ParticleMaterial();
			this.mesh			 = new Mesh3D([]);
			this.shape 			 = new SphereShape();
			this.shape.mode 	 = new Plane(1, 1, 1).surfaces[0];				
			this.rate 			 = 20;											
			this.bursts 		 = new Vector.<Point>();						
			this.duration 		 = 5;											
			this.loops 		 	 = 0;											
			this.startDelay 	 = 0;											
			this.startSpeed 	 = new PropConst(5);							
			this.startSize 		 = Vector.<PropData>([new PropConst(1), new PropConst(1), new PropConst(1)]);
			this.startColor 	 = new PropGridientColor();						
			this.startLifeTime   = new PropConst(5);							
			this.startRotation   = Vector.<PropData>([new PropConst(0), new PropConst(0), new PropConst(0)])
			this.additionalSpeed = Vector.<PropRandomTwoConst>([new PropRandomTwoConst(), new PropRandomTwoConst(), new PropRandomTwoConst()]);;
			this.simulationSpace = false;										
			this.colorLifetime 	 = new GridientColor();
			this.image			 = new DEFAULT_IMG().bitmapData;
			this.keyFrames		 = keyframeDatas;
			this.addComponent(this.mesh);
			this.addComponent(this.material);
		}
		
		/**
		 * 构建粒子系统 
		 * 
		 */		
		public function build() : void {
			if (!this._needBuild) {
				return;
			}
			this.mesh.download(true);
			this._surface = new Surface3D();
			this._totalTime = 0;
			this.updateParticleNum();		// 计算所有的粒子数量
			this.surface.setVertexVector(Surface3D.CUSTOM2, new Vector.<Number>(num * shape.vertNum * 2, true), 2);
			this.surface.setVertexVector(Surface3D.CUSTOM3, new Vector.<Number>(num * shape.vertNum * 4, true), 4);
			this.shape.generate(this);		// 生成shape
			// 生成正常发射频率的数据
			var rateNum  : int = rate * duration;
			for (var i:int = 0; i < rateNum; i++) {
				this.updateParticles(i, i * 1.0 / rate);
			}
			// 生成burst数据
			for (var j:int = 0; j < bursts.length; j++) {	
				var burstNum : int = int(bursts[j].y);
				for (var n:int = 0; n < burstNum; n++) {	
					this.updateParticles(rateNum + n, bursts[j].x);
				}
				rateNum += burstNum;
			}
			this.mesh.surfaces[0] = surface;
			this._needBuild = false;
			this.material.totalLife = this.duration;
		}

		/**
		 * 更新粒子系统数据 
		 * @param idx		粒子索引
		 * @param delay		粒子延时
		 */		
		private function updateParticles(idx : int, delay : Number) : void {
			// 粒子数据
			var position : Vector.<Number> = this.surface.getVertexVector(Surface3D.POSITION);	// 位置
			var velocity : Vector.<Number> = this.surface.getVertexVector(Surface3D.CUSTOM1);	// 方向
			var lifetimes: Vector.<Number> = this.surface.getVertexVector(Surface3D.CUSTOM2);	// 时间
			var colors	 : Vector.<Number> = this.surface.getVertexVector(Surface3D.CUSTOM3);	// 颜色
			// 属性
			var speed : Number = startSpeed.getValue(delay);			// 根据延时获取对应的Speed
			var sizeX : Number = startSize[0].getValue(delay);			// 根据延时获取对应的SizeX
			var sizeY : Number = startSize[1].getValue(delay);			// 根据延时获取对应的SizeY
			var sizeZ : Number = startSize[2].getValue(delay);			// 根据延时获取对应的SizeZ
			var rotaX : Number = startRotation[0].getValue(delay);		// 根据延时获取对应的RotationX
			var rotaY : Number = startRotation[1].getValue(delay);		// 根据延时获取对应的RotationY
			var rotaZ : Number = startRotation[2].getValue(delay);		// 根据延时获取对应的RotationZ
			var color : Vector3D = startColor.getRGBA(delay / duration);// 根据延时获取对应的Color
			var lifetime : Number = startLifeTime.getValue(delay);		// 根据延时获取对应的LifeTime
			// 缩放以及旋转
			matrix3d.identity();
			Matrix3DUtils.setScale(matrix3d, sizeX, sizeY, sizeZ);
			Matrix3DUtils.setRotation(matrix3d, rotaX, rotaY, rotaZ);
			// const speed
			var speedX : Number = additionalSpeed[0].getValue(delay);
			var speedY : Number = additionalSpeed[1].getValue(delay);
			var speedZ : Number = additionalSpeed[2].getValue(delay);
			// step
			var step2 : int = shape.vertNum * idx * 2;
			var step3 : int = shape.vertNum * idx * 3;
			var step4 : int = shape.vertNum * idx * 4;
			
			for (var j:int = 0; j < shape.vertNum; j++) {
				// 转换位置数据
				var seg2 : int = j * 2;
				var seg3 : int = j * 3;
				var seg4 : int = j * 4;
				vector3d.x = position[step3 + seg3 + 0];
				vector3d.y = position[step3 + seg3 + 1];
				vector3d.z = position[step3 + seg3 + 2];
				Matrix3DUtils.transformVector(matrix3d, vector3d, vector3d);
				position[step3 + seg3 + 0] = vector3d.x;
				position[step3 + seg3 + 1] = vector3d.y;
				position[step3 + seg3 + 2] = vector3d.z;
				// 转换速度
				vector3d.x = velocity[step3 + seg3 + 0];
				vector3d.y = velocity[step3 + seg3 + 1];
				vector3d.z = velocity[step3 + seg3 + 2];
				vector3d.scaleBy(speed);
				// 附加速度
				vector3d.x += speedX;
				vector3d.y += speedY;
				vector3d.z += speedZ;
				velocity[step3 + seg3 + 0] = vector3d.x;
				velocity[step3 + seg3 + 1] = vector3d.y;
				velocity[step3 + seg3 + 2] = vector3d.z;
				// 生命周期
				lifetimes[step2 + seg2 + 0] = delay;
				lifetimes[step2 + seg2 + 1] = lifetime;
				// 颜色
				colors[step4 + seg4 + 0] = color.x;
				colors[step4 + seg4 + 1] = color.y;
				colors[step4 + seg4 + 2] = color.z;
				colors[step4 + seg4 + 3] = color.w;
			}
			// 根据延时和生命周期计算出粒子系统的最大生命时间
			this._totalTime = Math.max(this._totalTime, delay + lifetime);
		}
		
		/**
		 * 默认的关键帧数据 
		 * @return 
		 * 
		 */		
		private static function get keyframeDatas() : ByteArray {
			if (!_defKeyframe) {
				var bytes  : ByteArray = new ByteArray();
				bytes.endian = Endian.LITTLE_ENDIAN;
				var matrix : Matrix3D = new Matrix3D();
				var datas  : Vector.<Number> = new Vector.<Number>(16 * 11, true);
				for (var i:int = 0; i < 11; i++) {
					matrix.identity();
					Matrix3DUtils.setScale(matrix, 1, 1, 1);		// 缩放
					Matrix3DUtils.setRotation(matrix, 0, 0, 0);		// 旋转
					matrix.transpose();
					for (var j:int = 0; j < 16; j++) {
						datas[16 * i + j] = matrix.rawData[j];
					}
					datas[16 * i + 12] = 0;			// x轴速度
					datas[16 * i + 13] = 0;			// y轴速度
					datas[16 * i + 14] = 0;			// z轴速度
				}
				for (var k:int = 0; k < 176; k++) {
					bytes.writeFloat(datas[k]);
				}
				_defKeyframe = bytes;
			}
			return _defKeyframe;
		}
				
		/**
		 * 粒子贴图 
		 * @return 
		 * 
		 */		
		public function get image():BitmapData {
			return _image;
		}
		
		/**
		 * 粒子贴图 
		 * @param value
		 * 
		 */		
		public function set image(value:BitmapData):void {
			if (texture) {
				texture.dispose(true);
			}
			_image = value;
			texture = new Bitmap2DTexture(value);
			material.texture = texture;
		}
		
		/**
		 * 随生命周期变换的旋转缩放速度数据 
		 * @param value
		 * 
		 */		
		public function get keyFrames():ByteArray {
			return _matrixOverLifetime;
		}
		
		/**
		 * 随生命周期变换的旋转缩放速度数据，一共11个关键帧。关键帧之间使用线性插值。
		 * 格式为:Matrix的rawdata数据，一共11个matrix，需要转置。转置之后最后一个vector保存速度数据。如下：
		 * 
		 * var bytes  : ByteArray = new ByteArray();
		 *	bytes.endian = Endian.LITTLE_ENDIAN;
		 *	var matrix : Matrix3D = new Matrix3D();
		 *	var datas  : Vector.<Number> = new Vector.<Number>(16 * 11, true);
		 *	for (var i:int = 0; i < 11; i++) {
		 *		matrix.identity();
		 *		Matrix3DUtils.setScale(matrix, 1, 1, 1);		// 缩放
		 *		Matrix3DUtils.setRotation(matrix, 0, 0, 0);		// 旋转
		 *		matrix.transpose();
		 *		for (var j:int = 0; j < 16; j++) {
		 *			datas[16 * i + j] = matrix.rawData[j];
		 *		}
		 *		datas[16 * i + 12] = 0;			// x轴速度
		 *		datas[16 * i + 13] = 0;			// y轴速度
		 *		datas[16 * i + 14] = 0;			// z轴速度
		 *	}
		 *	for (var k:int = 0; k < 176; k++) {
		 *		bytes.writeFloat(datas[k]);
		 *	}
		 *
		 * @param value
		 * 
		 */		
		public function set keyFrames(value:ByteArray):void {
			_matrixOverLifetime = value;
			material.keyframes = value;
		}
		
		/**
		 * 随生命周期变化的颜色 
		 * @return 
		 * 
		 */		 
		public function get colorLifetime():GridientColor {
			return _colorOverLifetime;
		}
		
		/**
		 * 随生命周期变化的颜色 
		 * @param value
		 * 
		 */		
		public function set colorLifetime(value:GridientColor):void {
			_colorOverLifetime = value;
			if (blendTexture) {
				blendTexture.dispose(true);
			}
			blendTexture = new Bitmap2DTexture(_colorOverLifetime.gridient);
			material.blendTexture = blendTexture;
		}
		
		/**
		 * 粒子网格数据 
		 * @return 
		 * 
		 */		
		public function get surface() : Surface3D {
			return this._surface;
		}
		
		/**
		 * 粒子系统当前时间 
		 * @return 
		 * 
		 */		
		public function get time():Number {
			return _time;
		}
		
		public function set time(value:Number):void {
			_time = value;
		}

		
		override public function addComponent(icom:IComponent):void {
			// 粒子系统不允许添加新的mesh
			if (icom is Mesh3D && getComponent(Mesh3D)) {
				return;
			}
			super.addComponent(icom);
		}
		
		/**
		 * 附加速度 
		 * @param value
		 * 
		 */		
		public function set additionalSpeed(value:Vector.<PropRandomTwoConst>):void {
			_additionalSpeed = value;
			_needBuild = true;
		}
		
		/**
		 * 附加速度 
		 * @return 
		 * 
		 */		
		public function get additionalSpeed():Vector.<PropRandomTwoConst> {
			return _additionalSpeed;
		}
		
		/**
		 * 粒子数量 
		 * @return 
		 * 
		 */				
		public function get num():int {
			return _num;
		}
		
		/**
		 * 计算粒子系统的粒子数量
		 */		
		private function updateParticleNum() : void {
			var result : int = 0;
			result += int(rate * duration);							// 发射频率 * 发射时间
			for (var i:int = 0; i < bursts.length; i++) {
				result += bursts[i].y;
			}
			this._num = result * 3;
		}
		
		/**
		 * 粒子形状
		 * @return
		 *
		 */
		public function get shape() : ParticleShape {
			return _shape;
		}

		/**
		 * 粒子形状
		 * @param value
		 *
		 */
		public function set shape(value : ParticleShape) : void {
			_shape = value;
			_needBuild = true;
		}

		/**
		 * 爆发粒子
		 * @return
		 *
		 */
		public function get bursts() : Vector.<Point> {
			return _bursts;
		}

		/**
		 * 爆发粒子
		 * @return
		 *
		 */
		public function set bursts(value : Vector.<Point>) : void {
			_bursts = value;
			_needBuild = true;
		}

		/**
		 * 发射频率
		 * @param value
		 *
		 */
		public function get rate() : int {
			return _rate;
		}

		/**
		 * 发射频率
		 * @param value
		 *
		 */
		public function set rate(value : int) : void {
			_rate = value;
			_needBuild = true;
		}
		
		/**
		 * 粒子坐标系
		 * @param value
		 *
		 */
		public function get simulationSpace() : Boolean {
			return _simulationSpace;
		}

		/**
		 * 粒子坐标系
		 * @param value
		 *
		 */
		public function set simulationSpace(value : Boolean) : void {
			_simulationSpace = value;
		}

		/**
		 * 初始颜色
		 * @return
		 *
		 */
		public function get startColor() : PropColor {
			return _startColor;
		}

		/**
		 * 初始颜色
		 * @param value
		 *
		 */
		public function set startColor(value : PropColor) : void {
			_startColor = value;
			_needBuild = true;
		}

		/**
		 * 初始角度
		 * @return
		 *
		 */
		public function get startRotation() : Vector.<PropData> {
			return _startRotation;
		}

		/**
		 * 初始角度
		 * @param value
		 *
		 */
		public function set startRotation(value : Vector.<PropData>) : void {
			_startRotation = value;
			_needBuild = true;
		}

		/**
		 * 初始大小
		 * @return
		 *
		 */
		public function get startSize() : Vector.<PropData> {
			return _startSize;
		}

		/**
		 * 初始大小
		 * @param value
		 *
		 */
		public function set startSize(value : Vector.<PropData>) : void {
			_startSize = value;
			_needBuild = true;
		}

		/**
		 * 初始速度
		 * @return
		 *
		 */
		public function get startSpeed() : PropData {
			return _startSpeed;
		}

		/**
		 * 初始速度
		 * @param value
		 *
		 */
		public function set startSpeed(value : PropData) : void {
			_startSpeed = value;
			_needBuild = true;
		}

		/**
		 * 粒子生命周期
		 * @return
		 *
		 */
		public function get startLifeTime() : PropData {
			return _startLifeTime;
		}

		/**
		 * 粒子生命周期
		 * @param value
		 *
		 */
		public function set startLifeTime(value : PropData) : void {
			_startLifeTime = value;
			_needBuild = true;
		}

		/**
		 * 开始延迟时间
		 * @return
		 *
		 */
		public function get startDelay() : Number {
			return _startDelay;
		}

		/**
		 * 开始延迟时间
		 * @return
		 *
		 */
		public function set startDelay(value : Number) : void {
			_startDelay = value;
		}

		/**
		 * loop模式。0:无限循环；1:循环次数
		 * @return
		 *
		 */
		public function get loops() : int {
			return _loops;
		}

		/**
		 * loop模式。0:无限循环；1:循环次数
		 * @return
		 *
		 */
		public function set loops(value : int) : void {
			_loops = value;
			loopCount = value;
		}

		/**
		 * 发射持续时间
		 * @return
		 *
		 */
		public function get duration() : Number {
			return _duration;
		}

		/**
		 * 发射持续时间
		 * @return
		 *
		 */
		public function set duration(value : Number) : void {
			_duration = value;
			_needBuild = true;
		}
		
		public function get playing() : Boolean {
			return _playing;
		}
		
		public function play() : void {
			_playing = true;
		}
		
		public function stop() : void {
			_playing = false;	
		}
		
		public function gotoAndStop(time : Number) : void {
			_playing = false;
			_time = time;
		}
		
		public function gotoAndPlay(time : Number) : void {
			_playing = true;
			_time = time;
		}
		
		override public function draw(scene:Scene3D, includeChildren:Boolean=true):void {
			if (this._needBuild) {
				this.build();
			}
			// 有限循环次数且循环尽
			if (loops != 0 && loopCount <= 0) {
				return;
			}
			// playing
			if (playing) {
				time += Time3D.deltaTime;	
			}
			// 小于延时
			if (time < startDelay) {
				return;
			}
			// draw
			this.material.time = time - startDelay;
			super.draw(scene, includeChildren);
			// 检测粒子是否播放完成
			if (time >= startDelay + _totalTime && loops != 0) {
				loopCount--;
				time = 0;
				if (loopCount <= 0) {
					this.dispatchEvent(completeEvent);
				}
			}
		}
		
	}
}
