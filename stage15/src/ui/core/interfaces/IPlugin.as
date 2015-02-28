package ui.core.interfaces {

	import ui.core.App;

	public interface IPlugin {

		function init(app : App) : void;
		function start() : void;
	}
}
