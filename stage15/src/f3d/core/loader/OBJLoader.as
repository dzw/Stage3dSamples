package f3d.core.loader {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import f3d.core.base.Surface3D;
	import f3d.core.parser.ObjParser;

	public class OBJLoader extends EventDispatcher {
		
		public var surface : Surface3D;
		
		private var loader : URLLoader;
		private var parser : ObjParser;
		
		public function OBJLoader() {
			super();
			this.parser = new ObjParser();
		}
		
		public function load(url : String) : void {
			this.loader = new URLLoader();
			this.loader.dataFormat = URLLoaderDataFormat.TEXT;
			this.loader.addEventListener(Event.COMPLETE, 			onLoadComplete);
			this.loader.addEventListener(IOErrorEvent.IO_ERROR, 	onIoError);
			this.loader.addEventListener(ProgressEvent.PROGRESS,	onProgress);
			this.loader.load(new URLRequest(url));
		}
		
		public function loadBytes(bytes : ByteArray) : void {
			bytes.position = 0;
			var txt : String = bytes.readUTFBytes(bytes.length);
			this.parseObj(txt);
		}
		
		private function onProgress(event:ProgressEvent) : void {
			this.dispatchEvent(event);
		}
		
		private function onIoError(event:IOErrorEvent) : void {
			this.dispatchEvent(event);
		}
		
		private function onLoadComplete(event:Event) : void {
			this.parseObj(this.loader.data as String);
		}
		
		private function parseObj(txt : String) : void {
			this.parser.parse(txt);
			this.surface = new Surface3D();
			this.surface.setVertexDataVector(Surface3D.POSITION, this.parser.vertices, 3);
			this.surface.setVertexDataVector(Surface3D.UV0, this.parser.uvs, 2);
			this.surface.setVertexDataVector(Surface3D.NORMAL, this.parser.normals, 3);
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
	}
}
