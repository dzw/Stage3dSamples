package {

	import flash.display.Sprite;
	
	import ide.Studio;

	public class IDE extends Sprite {
		
		public function IDE() {
			super();
			
			addChild(new Studio());
		}
	}
}
