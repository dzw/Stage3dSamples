package f3d.core.base {

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import f3d.core.components.Material3D;
	import f3d.core.components.Transform3D;
	import f3d.core.interfaces.IComponent;
	import f3d.core.scene.Scene3D;
	
	public class Object3D extends EventDispatcher {
		
		/** enter draw */
		private static const enterDrawEvent : Event = new Event(Scene3D.ENTER_FRAME);
		/** exit draw */
		private static const exitDrawEvent  : Event = new Event(Scene3D.EXIT_FRAME);
		
		/** 名称 */
		public var name : String = "";
			
		// 所有组件
		private var _components 	: Vector.<IComponent>;
		// 组件字典
		private var _componentMap 	: Dictionary;
		// transform
		private var _transform  	: Transform3D;		
		// 子节点
		private var _children   	: Vector.<Object3D>;
		// 父级
		private var _parent			: Object3D;
		
		public function Object3D() {
			super();
			this._components   = new Vector.<IComponent>();
			this._transform    = new Transform3D();
			this._children	   = new Vector.<Object3D>();
			this._componentMap = new Dictionary();
			this.addComponent(_transform);
		}
		
		/**
		 * 添加一个child 
		 * @param child
		 * 
		 */		
		public function addChild(child : Object3D) : void {
			if (children.indexOf(child) != -1) {
				return;
			}
			child._parent = this;
			children.push(child);
		}
		
		/**
		 * 移除child 
		 * @param child
		 * 
		 */		
		public function removeChild(child : Object3D) : void {
			var idx : int = children.indexOf(child);
			if (idx == -1) {
				return;
			}
			children.splice(idx, 1);
			child._parent = null;
		}
		
		/**
		 * 父级 
		 * @return 
		 * 
		 */		
		public function get parent() : Object3D {
			return _parent;
		}
		
		/**
		 * 子节点 
		 * @return 
		 * 
		 */		
		public function get children() : Vector.<Object3D> {
			return _children;
		}
		
		/**
		 * transform 
		 * @return 
		 * 
		 */		
		public function get transform() : Transform3D {
			return _transform;
		}
				
		/**
		 * 所有组件 
		 * @return 
		 * 
		 */		
		public function get components() : Vector.<IComponent> {
			return this._components;
		}
		
		/**
		 * 添加组件 
		 * @param com
		 * 
		 */		
		public function addComponent(icom : IComponent) : void {
			if (components.indexOf(icom) != -1) {
				return;
			}
			// add to dict
			var clazz : Class = Object(icom).constructor;
			if (!_componentMap[clazz]) {
				_componentMap[clazz] = [];
			}
			_componentMap[clazz].push(icom);
			// 
			components.push(icom);
			icom.onAdd(this);
			for each (var c : IComponent in components) {
				c.onOtherComponentAdd(icom);
			}
		}
		
		/**
		 * 移除组件 
		 * @param com
		 * 
		 */		
		public function removeComponent(icom : IComponent) : void {
			var idx : int = components.indexOf(icom);
			if (idx == -1) {
				return;
			}
			components.splice(idx, 1);
			var clazz : Class = Object(icom).constructor;
			// remove from dict
			idx = _componentMap[clazz].indexOf(icom);
			_componentMap[clazz].splice(idx, 1);
			// remove
			icom.onRemove(this);
			for each (var c : IComponent in components) {
				c.onOtherComponentRemove(icom);
			}
		}
		
		/**
		 * 根据类型获取component 
		 * @param clazz	类型
		 * @return 
		 * 
		 */		
		public function getComponent(clazz : Class) : IComponent {
			return _componentMap[clazz][0];
		}
		
		/**
		 * 根据类型获取components
		 * @param clazz
		 * @return 
		 * 
		 */		
		public function getComponents(clazz : Class) : Array {
			return _componentMap[clazz];
		}
		
		/**
		 * 更新 
		 * @param includeChildren
		 * 
		 */		
		public function update(includeChildren : Boolean) : void {
			for each (var icom : IComponent in components) {
				if (icom.enable) {
					icom.onUpdate();
				}
			}
		}
		
		/**
		 * 绘制 
		 * @param includeChildren
		 * @param scene
		 * 
		 */		
		public function draw(scene : Scene3D, material : Material3D = null, includeChildren : Boolean = true) : void {
			this.dispatchEvent(enterDrawEvent);
			for each (var icom : IComponent in components) {
				if (icom.enable) {
					icom.onDraw(scene);
				}
			}
			this.dispatchEvent(exitDrawEvent);
			if (includeChildren) {
				for each (var child : Object3D in children) {
					child.draw(scene, material, includeChildren);
				}
			}
		}
			
	}
}
