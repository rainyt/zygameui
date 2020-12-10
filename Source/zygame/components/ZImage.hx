package zygame.components;

import zygame.utils.ZGC;
import openfl.display.Shader;
import zygame.components.base.DataProviderComponent;
import zygame.display.Image;
import openfl.display.BitmapData;
import zygame.utils.AssetsUtils in Assets;
import zygame.utils.load.Frame;
import openfl.geom.Rectangle;

/**
 *  支持使用图片路径、以及位图设置内容
 */
class ZImage extends DataProviderComponent {
	private var isDispose:Bool = false;

	private var isAysn:Bool = false;

	public var display:Image;

	public function new() {
		super();
		display = new Image(null);
		this.addChild(display);
	}

	override public function initComponents():Void {
		this.updateComponents();
	}

	override public function updateComponents():Void {
		if (display != null) {
			var data:Dynamic = super.dataProvider;
			if (data != null) {
				if (Std.is(data, String)) {
					var path:String = data;
					// 启动异步载入
					isAysn = true;
					Assets.loadBitmapData(path, false).onComplete(function(bitmapData:BitmapData):Void {
						if (isDispose) {
							ZGC.disposeBitmapData(bitmapData);
							return;
						}
						display.bitmapData = bitmapData;
						onBitmapDataUpdate();
					});
				}
				// else if(Std.is(data,BitmapData) || Std.is(data,Frame) || Std.is(data,AsyncFrame))
				else if (Std.is(data, BitmapData) || Std.is(data, Frame)) {
					display.bitmapData = cast data;
				}
			}
			display.visible = data != null;
			if (@:privateAccess display._setWidth)
				display.width = @:privateAccess display._width;
			if (@:privateAccess display._setHeight)
				display.height = @:privateAccess display._height;
		}
	}

	#if flash
	@:setter(width)
	public function set_width(value:Float) {
		display.width = value;
		return value;
	}

	@:getter(width)
	public function get_width() {
		return display.width;
	}

	@:setter(height)
	public function set_height(value:Float) {
		display.height = value;
		return value;
	}

	@:getter(height)
	public function get_height() {
		return display.height;
	}
	#else
	private override function set_width(value:Float):Float {
		display.width = value;
		return value;
	}

	private override function set_height(value:Float):Float {
		display.height = value;
		return value;
	}

	private override function get_width():Float {
		return Math.abs(display.width * scaleX);
	}

	private override function get_height():Float {
		return Math.abs(display.height * scaleY);
	}
	#end

	private override function set_dataProvider(data:Dynamic):Dynamic {
		if (super.dataProvider == data)
			return data;
		if (this.display.bitmapData != null && isAysn && Std.is(this.display.bitmapData, BitmapData)) {
			ZGC.disposeBitmapData(this.display.bitmapData);
		}
		super.dataProvider = data;
		this.updateComponents();
		return data;
	}

	private override function get_dataProvider():Dynamic {
		return super.dataProvider;
	}

	/**
	 * 设置九宫格格式
	 * @param rect
	 */
	public function setScale9Grid(rect:Rectangle):Void {
		display.setScale9Grid(rect);
	}

	/**
	 * 设置着色器
	 * @param value
	 * @return Shader
	 */
	override function set_shader(value:Shader):Shader {
		if (display != null)
			display.shader = value;
		return value;
	}

	override function get_shader():Shader {
		if(display == null)
			return null;
		return display.shader;
	}

	/**
	 * 当图片异步载入更新后发生
	 */
	dynamic public function onBitmapDataUpdate():Void {}

	override function destroy() {
		super.destroy();
		this.isDispose = true;
		if (this.display.bitmapData != null && isAysn && Std.is(this.display.bitmapData, BitmapData)) {
			ZGC.disposeBitmapData(this.display.bitmapData);
		}
	}

	override function set_vAlign(value:String):String {
		this.display.vAlign = value;
		return super.set_vAlign(value);
	}

	override function set_hAlign(value:String):String {
		this.display.hAlign = value;
		return super.set_hAlign(value);
	}

	override function alignPivot(?v:String = null, ?h:String = null) {
		super.alignPivot(v, h);
		this.display.alignPivot(v,h);
	}
}
