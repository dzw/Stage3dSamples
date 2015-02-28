package ide {

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	
	import L3D.core.scene.Scene3D;
	import L3D.system.Input3D;
	
	import ide.plugins.ControllerPlugin;
	import ide.plugins.CreatePlugin;
	import ide.plugins.ExportPlugin;
	import ide.plugins.HierarchyPlugin;
	import ide.plugins.ImportPlugin;
	import ide.plugins.LogPlugin;
	import ide.plugins.MaterialPlugin;
	import ide.plugins.PropertiesPlugin;
	import ide.plugins.ScenePlugin;
	import ide.plugins.SelectionPlugin;
	
	import ui.core.App;
	import ui.core.Style;
	import ui.core.container.Box;
	import ui.core.controls.TabControl;
	import ui.core.controls.ToolTip;
	import ui.core.controls.Window;

	public class Studio extends Sprite {
		
		/** 场景面板 */
		public static const SCENE_PANEL 	: String = "panel:scene";
		/** log面板 */
		public static const OUTPUT_PANEL 	: String = "panel:out";
		/** 左边tab */
		public static const RIGHT_TAB 		: String = "tab:right";
		/** 中间tab */
		public static const MIDDLE_TAB 		: String = "tab:middle";
		/** 工具条 */
		public static const SCENE_MENU 		: String = "bar:menu";
		
		private static var _stage 	: Stage;			// stage
		private static var _scene 	: Scene3D;			// scene3d
		private static var _app 	: App;				// app
		
		private var _guiConfig  : Object;				// ui配置
		private var _root 		: Sprite;				// root
		private var _pop 		: Sprite;				// 弹出层

		public static function get stage() : Stage {
			return _stage;
		}

		public function Studio() {
			if (this.stage != null) {
				this.init();
			} else {
				this.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			}
		}

		protected function onAddToStage(event : Event) : void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			this.init();
		}

		/**
		 * TODO:根据配置文件直接生成
		 */
		private function initIdeUI() : void {
			_app.gui.root.orientation = Box.HORIZONTAL;
			_app.gui.root.addControl(createLeftPanel());
			_app.gui.root.addControl(createRightPanel());
			_app.gui.root.update();
			_app.gui.root.draw();
		}
		
		/**
		 * 创建左边面板
		 * @param left
		 * 
		 */		
		private function createLeftPanel() : Box {
			var left : Box = new Box();
			left.minWidth = 900;
			left.orientation = Box.VERTICAL;
			left.allowResize = true;
			left.showBorders = true;
			
			var top : TabControl = new TabControl();
			top.minHeight = 550;
			top.name = Studio.SCENE_PANEL;
			
			var bottom : TabControl = new TabControl();
			bottom.minHeight = 100;
			bottom.name = Studio.OUTPUT_PANEL;
			
			_app.gui.markPanel(top);
			_app.gui.markPanel(bottom);
			
			left.addControl(top);
			left.addControl(bottom);
			
			return left;
		}
		
		/**
		 * 创建右边面板
		 * @param right
		 * 
		 */		
		private function createRightPanel() : Box {
			
			var right : Box = new Box();
			right.minWidth = 100;
			right.width = 400;
			right.orientation = Box.HORIZONTAL;
			right.showBorders = true;
			right.allowResize = true;
			right.minWidth = 240;
			
			var leftTab : TabControl = new TabControl();
			leftTab.minWidth = 200;
			leftTab.name = MIDDLE_TAB;
			
			var rightTab : TabControl = new TabControl();
			rightTab.minWidth = 120;
			
			rightTab.name = RIGHT_TAB;
			right.addControl(leftTab);
			right.addControl(rightTab);
			
			_app.gui.markPanel(leftTab);
			_app.gui.markPanel(rightTab);
			
			return right;
		}
		
		private function init() : void {
			
			Input3D.initialize(this.stage);
			
			_root = new Sprite();
			_pop  = new Sprite();
			_pop.addChild(ToolTip.toolTip);
			_pop.addChild(Window.popWindow.view);
			
			addChild(_root);
			addChild(_pop);
			
			Window.popWindow.visible = false;
			Window.popWindow.x = stage.stageWidth / 2;
			Window.popWindow.y = stage.stageHeight / 2;
			
			_stage = this.stage;
			_stage.color = Style.backgroundColor;
			_stage.frameRate = 60;
			_app = new App(_root);
			
			initIdeUI();
			
			_app.initPlugin(new ScenePlugin());
			_app.initPlugin(new LogPlugin());
			_app.initPlugin(new CreatePlugin());
			_app.initPlugin(new SelectionPlugin());
			_app.initPlugin(new PropertiesPlugin());
			_app.initPlugin(new HierarchyPlugin());
			_app.initPlugin(new MaterialPlugin());
			_app.initPlugin(new ImportPlugin());
			_app.initPlugin(new ControllerPlugin());
			_app.initPlugin(new ExportPlugin());
			
			stage.addEventListener(Event.RESIZE, onResize);
		}

		protected function onResize(event : Event) : void {
			_app.gui.update();
			_app.gui.draw();
		}

	}
}
