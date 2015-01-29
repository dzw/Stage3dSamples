package f3d.core.base {

	import flash.events.EventDispatcher;
	
	import f3d.core.components.Transform3D;
	import f3d.core.interfaces.IComponent;

	public class Object3D extends EventDispatcher {
		
		/** 名称 */
		public var name : String = "";
			
		// 所有组件
		private var _components : Vector.<IComponent>;
		// transform
		private var _transform  : Transform3D;		
		// 子节点
		private var _children   : Vector.<Object3D>;
		// 父级
		private var _parent		: Object3D;
		
		public function Object3D() {
			super();
			this._components = new Vector.<IComponent>();
			this._transform  = new Transform3D();
			this._children	 = new Vector.<Object3D>();
			this.addComponent(transform);
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
			children.indexOf(child);
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
			for each (var c : IComponent in components) {
				if (c is clazz) {
					return c;
				}
			}
			return null;
		}
		
		/**
		 * 根据获取所有的component 
		 * @param clazz	类型
		 * @param out	输出目标
		 * @return 		所有的组件
		 * 
		 */		
		public function getComponents(clazz : Class, out : Vector.<IComponent> = null) : Vector.<IComponent> {
			if (!out) {
				out = new Vector.<IComponent>();
			}
			for each (var c : IComponent in components) {
				if (c is clazz) {
					out.push(c);
				}
			}
			return out;
		}
		
	}
}
