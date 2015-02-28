package ide.plugins {

	import flash.events.Event;
	import flash.text.TextFieldType;
	
	import ide.Studio;
	import ide.events.LogEvent;
	
	import ui.core.App;
	import ui.core.Menu;
	import ui.core.container.Panel;
	import ui.core.controls.InputText;
	import ui.core.controls.TabControl;
	import ui.core.event.ControlEvent;
	import ui.core.interfaces.IPlugin;

	public class LogPlugin implements IPlugin {
		
		private var _app 	: App;
		private var _panel 	: Panel;
		private var _output : InputText;

		public function LogPlugin() {
			this._output = new InputText("Hi! ^_^", true);
		}

		public function init(app : App) : void {
			
			this._app = app;
			this._output.minHeight = 20;
			this._output.textField.type = TextFieldType.DYNAMIC;
			this._panel = new Panel("Console", 200, 100, false);
			this._panel.minHeight = -1;
			this._panel.margins = 5;
			this._panel.addControl(this._output);
			
			var menu : Menu = new Menu();
			menu.addMenuItem("Clear", clearLog);
			
			this._output.view.contextMenu = menu.menu;
			this._app.addEventListener(LogEvent.LOG, onLog);
			
			var outTab : TabControl = this._app.gui.getPanel(Studio.OUTPUT_PANEL) as TabControl;
			if (outTab != null) {
				outTab.addPanel(this._panel);
				outTab.open();
			}
			this._output.textField.addEventListener(ControlEvent.RIGHT_CLICK, onRightClick);
		}

		private function onRightClick(event : Event) : void {
			this._output.textField.htmlText = "";
		}
		
		private function onLog(event : LogEvent) : void {
			var date : Date  = new Date();
			var msg : String = "" + date.hours + ":" + date.minutes + ":" + date.seconds + ":";
			if (event.level == LogEvent.NORMAL) {
				msg += "<font color='#207020'>" + event.log + "</font> \n";
			} else if (event.level == LogEvent.ERROR) {
				msg += "<font color='#ff8080'>" + event.log + "</font> \n";
			} else {
				msg += "<font color='#907020'>" + event.log + "</font> \n";
			}
			this._output.textField.htmlText += msg;
			this._output.textField.scrollV = this._output.textField.maxScrollV;
		}

		private function clearLog() : void {
			this._output.text = "";
		}
		
		public function start() : void {

		}
	}
}
