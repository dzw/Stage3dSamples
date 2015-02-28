package ide.plugins.groups.properties {

	import L3D.core.base.Pivot3D;
	import L3D.core.entities.Mesh3D;
	import L3D.core.scene.Scene3D;
	
	import ide.events.SceneEvent;
	
	import ui.core.App;
	import ui.core.controls.CheckBox;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;
	import ui.core.type.Align;

	public class GeneralGroup extends PropertiesGroup {

		private var _app : App;
		private var visible : CheckBox;
		private var isView : CheckBox;
		private var layer : Spinner;
		

		public function GeneralGroup() {
			super("GENERAL");
			this.layout.labelWidth = 55;
			this.layout.addHorizontalGroup();
			this.isView = layout.addControl(new CheckBox("", false, Align.LEFT), "InView:") as CheckBox;
			this.visible = layout.addControl(new CheckBox("", true, Align.LEFT), "Visible:") as CheckBox;
			this.layer = layout.addControl(new Spinner(0, -1000, 1000, 0, 0.1), "Layer:") as Spinner;
			this.layout.endGroup();
			this.layout.addEventListener(ControlEvent.CHANGE, this.changeControlEvent);
			this.layout.addEventListener(ControlEvent.CLICK, this.changeControlEvent);
			this.accordion.contentHeight = 30;
		}
		
		private var _tick : Boolean = false;
		private function changeControlEvent(e : ControlEvent) : void {
			for each (var pivot : Pivot3D in this._app.selection.objects) {
				if ((pivot is Scene3D) == false) {
					switch (e.target) {
						case this.visible:
							if (this.visible.value) {
								pivot.show();
							} else {
								pivot.hide();
							}
							break;
						case this.layer:
							pivot.setLayer(this.layer.value, false);
							break
					}
				}
			}
			this._app.dispatchEvent(new SceneEvent(SceneEvent.CHANGE));
		}

		override public function update(app : App) : Boolean {
			this._app = app;
			if ((app.selection.objects.length == 1) && (app.selection.objects[0] is Scene3D)) {
				return false;
			}
			this.visible.value = app.selection.main.visible;
			this.layer.value = app.selection.main.layer;
			return true;
		}

	}
}
