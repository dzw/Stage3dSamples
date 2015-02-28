package ui.core {

	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	
	import L3D.core.scene.Scene3D;
	
	import ide.help.Selection;
	
	import ui.core.event.UndoEvent;
	import ui.core.interfaces.IPlugin;
	
	public class App extends EventDispatcher {
		
		private static var _instance : App;

		private var _keysDict 		: Dictionary;				// 按键
		private var _shortKeysDict 	: Dictionary;				// 快捷键
		private var _plugins 		: Vector.<IPlugin>;			// 插件
		private var _container 		: DisplayObjectContainer;	// 显示容器
		private var _started 		: Boolean;					// started
		private var _version 		: String;					// 版本
		private var _undo 			: Undo;						// undo
		private var _gui 			: GUI;						// ui
		private var _menu 			: Menu;						// 按钮
		private var _alert 			: Sprite;					// 弹出框
		private var _scene 			: Scene3D;					// scene
		private var _selection 		: Selection;				// selection
		
		public function get selection() : Selection {
			return _selection;
		}

		public function set selection(value : Selection) : void {
			this._selection = value;
		}

		public function get scene() : Scene3D {
			return _scene;
		}

		public function set scene(value : Scene3D) : void {
			this._scene = value;
		}

		public static function get core() : App {
			return _instance;
		}

		public function get gui() : GUI {
			return this._gui;
		}
		
		public function alert(msg : String) : void {
			
		}
		
		public function App(container : DisplayObjectContainer) {

			if (_instance != null) {
				throw new Error("App:single ton");
			}
			
			_instance = this;
			
			this._container = container;
			var root : Sprite = new Sprite();
			this._container.addChild(root);
			this._alert = new Sprite();
			this._container.addChild(_alert);
			this._selection 	= new Selection(this);
			this._shortKeysDict = new Dictionary();
			this._keysDict 		= new Dictionary();
			this._gui 			= new GUI(root);
			this._plugins 		= new Vector.<IPlugin>();
			
			this._undo = new Undo();
			this._undo.addEventListener(UndoEvent.PUSH, this.dispatchEvent);
			this._undo.addEventListener(UndoEvent.UNDO, this.dispatchEvent);
			this._undo.addEventListener(UndoEvent.REDO, this.dispatchEvent);
			
			this._menu = new Menu();
			this._menu.menu.hideBuiltInItems();
			
			this._container.contextMenu = this._menu.menu;
			this._container.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		/**
		 * 初始化插件 
		 * @param plugin
		 * 
		 */		
		public function initPlugin(plugin : IPlugin) : void {
			plugin.init(this);
			plugin.start();
			this._plugins.push(plugin);
		}
		
		/**
		 * 按键
		 * @param event
		 */		
		private function onKeyDown(event : KeyboardEvent) : void {
			var arr : Array = null;
			if (_shortKeysDict[event.keyCode] != undefined && event.ctrlKey) {
				arr = _shortKeysDict[event.keyCode];
				for (var i : int = 0; i < arr.length; i++) {
					arr[i].call();
				}
			}
			if (_keysDict[event.keyCode] != undefined) {
				arr = _keysDict[event.keyCode];
				for (var j : int = 0; j < arr.length; j++) {
					arr[j].call();
				}
			}
		}
		
		/**
		 * 移除快捷键 
		 * @param callback		回调函数
		 * @param key			keycode
		 * @param command		command
		 * 
		 */		
		public function removeKey(callback : Function, key : int, command : Boolean = false) : void {
			if (command) {
				if (_shortKeysDict[key] == undefined)
					return;
				var arr : Array = _shortKeysDict[key];
				var idx : int = arr.indexOf(callback);
				if (idx == -1)
					return;
				arr.splice(idx, 1);
			} else {
				if (_keysDict[key] == undefined)
					return;
				var arr0 : Array = _keysDict[key];
				var idx0 : int = arr0.indexOf(callback);
				if (idx0 == -1)
					return;
				arr0.splice(idx0, 1);
			}
		}

		/**
		 *
		 * @param callback
		 * @param key
		 * @param command
		 *
		 */
		public function addShortKey(callback : Function, key : int, command : Boolean = false) : void {
			if (command) {
				if (_shortKeysDict[key] == undefined) {
					_shortKeysDict[key] = [];
				}
				var arr : Array = _shortKeysDict[key];
				if (arr.indexOf(callback) == -1) {
					arr.push(callback);
				}
			} else {
				if (_keysDict[key] == undefined) {
					_keysDict[key] = [];
				}
				var arr0 : Array = _keysDict[key];
				if (arr0.indexOf(callback) == -1) {
					arr0.push(callback);
				}
			}
		}

		public function addMenu(menu : String) : void {
			this._menu.addMenuItem(menu);
		}
		
	}
}

/**
 * key item 
 * @author Neil
 */
class KeyItem {
	public var command 	: Boolean;		// command
	public var key 		: int;			// keycode
	public var func 	: Function;		// callback
}
