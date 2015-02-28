package ide.plugins {

	import flash.display.MovieClip;
	import flash.events.Event;
	
	import L3D.core.base.Bone3D;
	import L3D.core.base.Pivot3D;
	import L3D.core.camera.Camera3D;
	import L3D.core.entities.Mesh3D;
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.light.Light3D;
	import L3D.core.scene.Scene3D;
	
	import ide.Studio;
	import ide.events.SceneEvent;
	import ide.events.SelectionEvent;
	import ide.plugins.groups.properties.AABBGroup;
	import ide.plugins.groups.properties.AnimationGroup;
	import ide.plugins.groups.properties.CameraGroup;
	import ide.plugins.groups.properties.DirectionLightGroup;
	import ide.plugins.groups.properties.GeneralGroup;
	import ide.plugins.groups.properties.MeshGroup;
	import ide.plugins.groups.properties.NameGroup;
	import ide.plugins.groups.properties.NavmeshGroup;
	import ide.plugins.groups.properties.ParticlesGroup;
	import ide.plugins.groups.properties.PointLightGroup;
	import ide.plugins.groups.properties.PropertiesGroup;
	import ide.plugins.groups.properties.SkyboxGroup;
	import ide.plugins.groups.properties.TransformGroup;
	import ide.plugins.groups.properties.WaterGroup;
	
	import ui.core.App;
	import ui.core.container.Panel;
	import ui.core.controls.Layout;
	import ui.core.controls.TabControl;
	import ui.core.event.ControlEvent;
	import ui.core.interfaces.IPlugin;

	public class PropertiesPlugin implements IPlugin {

		private var _panel 		: Panel;
		private var _icon 		: MovieClip;
		private var _app 		: App;
		private var _nameGroup 	: NameGroup;
		private var _layout 	: Layout;
		private var _groups 	: Vector.<PropertiesGroup>;
		
		public function PropertiesPlugin() {
			this._icon 		= new McIcons();
			this._nameGroup = new NameGroup();
			this._groups 	= new Vector.<PropertiesGroup>();
		}
		
		public function init(app : App) : void {
			this._app = app;
			
			this._panel = new Panel("PROPERTIES", 200, 350, false);
			this._panel.minWidth = 200;
			this._layout = new Layout(true);
			this._layout.root.background = true;
			this._layout.root.minHeight = 800;
			this._layout.margins = 0;
			this._layout.space = 1;
			this._layout.minHeight = 800;
			this._layout.addControl(this._nameGroup);
			
			this._groups.push(new GeneralGroup());
			this._groups.push(new TransformGroup());
			this._groups.push(new MeshGroup());
			this._groups.push(new AABBGroup());
			this._groups.push(new NavmeshGroup());
			this._groups.push(new CameraGroup());
			this._groups.push(new WaterGroup());
			this._groups.push(new SkyboxGroup());
			this._groups.push(new ParticlesGroup());
			this._groups.push(new DirectionLightGroup());
			this._groups.push(new PointLightGroup());
			this._groups.push(new AnimationGroup());
			
			this._icon.gotoAndStop(0);
			this._icon.x = 20;
			this._icon.y = 17;
			this._icon.graphics.clear();
			this._icon.graphics.lineStyle(1, 0xA0A0A0, 1, true);
			this._icon.graphics.drawRect(-10, -11, 20, 20);
			this._nameGroup.view.addChild(this._icon);
			this._panel.addControl(this._layout);
			this._nameGroup.addEventListener(ControlEvent.CHANGE, this.changingControlEvent);
			
			var tab : TabControl = this._app.gui.getPanel(Studio.MIDDLE_TAB) as TabControl;
			tab.addPanel(this._panel);
			tab.open();
		}
		
		protected function changingControlEvent(event : Event) : void {
			switch (event.target) {
				case this._nameGroup.names:  {
					if (this._app.selection.main != null) {
						this._app.selection.main.name = this._nameGroup.names.text;
					} else {
						this._app.scene.name = this._nameGroup.names.text;
					}
					this._app.dispatchEvent(new SceneEvent(SceneEvent.CHANGE));
					break;
				}
			}
		}
		
		public function start() : void {
			this._app.addEventListener(SelectionEvent.CHANGE, this.changeSelectionEvent);
			this.changeSelectionEvent(null);
		}
		
		private function changeSelectionEvent(event : Event) : void {
			var objects : Array = this._app.selection.objects;
			var main : Pivot3D = this._app.selection.main;
			if (main == null) {
				main = this._app.scene;
			}
			if (objects.length == 0) {
				objects = [this._app.scene];
			}
			
			this._layout.removeAllControls();
			this._layout.addControl(this._nameGroup);
			
			var name : String = "";
			for each (var pivot : Pivot3D in objects) {
				name += pivot.name + ",";
			}
			if (objects.length > 1) {
				name = objects.length + " Object Selected : " + name;
				this._nameGroup.names.toolTip = name;
			} else {
				this._nameGroup.names.toolTip = null;
			}
			
			this._nameGroup.names.text = name.substr(0, -1);
			this._nameGroup.names.enabled = (objects.length == 1);
			
			if (objects.length != 1) {
				this._icon.gotoAndStop(0);
			} else if (main is Particles3D) {
				this._icon.gotoAndStop(7);
			} else if (main is Scene3D) {
				this._icon.gotoAndStop(6);
			} else if (main is Mesh3D) {
				this._icon.gotoAndStop(1);
			} else if (main is Camera3D) {
				this._icon.gotoAndStop(4);
			} else if (main is Light3D) {
				this._icon.gotoAndStop(11);
			} else if (main is Bone3D) {
				this._icon.gotoAndStop(10);
			} else {
				this._icon.gotoAndStop(2);
			}
			
			for each (var group : PropertiesGroup in this._groups) {
				if (group.update(this._app)) {
					this._layout.addControl(group.accordion);
				}
			}
			
			this._layout.draw();
		}
	}
}