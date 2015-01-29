package f3d.core.interfaces {
	
	import f3d.core.base.Object3D;

	public interface IComponent {
		
		/**
		 * 被添加到Object3D 
		 * @param master	宿主
		 * 
		 */		
		function onAdd(master : Object3D) : void;
		
		/**
		 * 被移除 
		 * @param master	宿主
		 * 
		 */		
		function onRemove(master : Object3D) : void;
		
		/**
		 * 其他组件被添加到master 
		 * @param component	新添加的组件	
		 * 
		 */		
		function onOtherComponentAdd(component : IComponent) : void;
		
		/**
		 * 其他组件被移除 
		 * @param component 被移除的组件
		 * 
		 */		
		function onOtherComponentRemove(component : IComponent) : void;
		
		/**
		 * 更新
		 */
		function onUpdate() : void;
		
		/**
		 * 绘制
		 */
		function onDraw() : void;
		
		/**
		 * 开/关组件 
		 * @param value
		 * 
		 */		
		function set enable(value : Boolean) : void;
		
		/**
		 * 是否启用 
		 * @return 
		 */		
		function get enable() : Boolean;
	}
	
}
