package zygame.components;

import zygame.loader.parser.AsepriteParser.AsepriteTextureAtlas;

/**
 * 可用于播放Aseprite精灵图的动画对象
 */
class ZAsepriteAnimation extends ZAnimation {
	public var tag:String;

	private var _atlas:AsepriteTextureAtlas;

	public function new(atlas:AsepriteTextureAtlas) {
		super();
		_atlas = atlas;
	}

	/**
	 * 播放Tag动画组
	 * @param tag 
	 */
	public function playTag(tag:String):Void {
		if (this.tag == tag)
			return;
		this.tag = tag;
		var tagData = _atlas.frameTags.get(tag);
		if (tagData == null) {
			return;
		}
		this.dataProvider = _atlas.frameBitmapData.get(tag);
		this.play(999);
	}

	override function onFrame() {
		// 动画逻辑判断

		super.onFrame();
	}
}
