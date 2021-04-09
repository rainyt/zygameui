package zygame.particles.renderers;

import lime.graphics.opengl.GL;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.display.Tile;
import openfl.display.Tileset;
import openfl.events.Event;
import openfl.geom.ColorTransform;
import zygame.particles.internal.TilemapExt;
import zygame.particles.ParticleSystem;
import zygame.particles.util.MathHelper;

class TilemapParticleRendererData {
    public var ps : ParticleSystem;
    public var tilemap : TilemapExt;
    public var tileList : Array<Tile>;
    public var updated : Bool = false;

    public function new(ps : ParticleSystem, tilemap : TilemapExt, tileList : Array<Tile>) {
        this.ps = ps;
        this.tilemap = tilemap;
        this.tileList = tileList;
    }
}

// Use -Dzameparticles_use_tile_visibility to enable tile pool.
// This can be faster or slower, depending on the project (especially on neko).

class TilemapParticleRenderer extends Sprite implements ParticleSystemRenderer {
    private var manualUpdate : Bool;
    private var dataList : Array<TilemapParticleRendererData> = [];

    public function new(manualUpdate : Bool = false) {
        super();
        this.manualUpdate = manualUpdate;
    }

    public function addParticleSystem(ps : ParticleSystem) : ParticleSystemRenderer {
        if (dataList.length == 0 && !manualUpdate) {
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        ps.__initialize();
        var tileList = new Array<Tile>();

        var tileset = new Tileset(ps.textureBitmapData);
        tileset.addRect(ps.textureBitmapData.rect);

        var currentStage = (stage != null ? stage : openfl.Lib.current.stage);

        #if zygame
        var tilemap = new TilemapExt(Std.int(zygame.core.Start.current.getStageWidth()), Std.int(zygame.core.Start.current.getStageHeight()), tileset);
        #else
        var tilemap = new TilemapExt(currentStage.stageWidth, currentStage.stageHeight, tileset);
        #end
        addChild(tilemap);

        #if zameparticles_use_tile_visibility
            for (i in 0 ... ps.maxParticles) {
                var tile = new Tile(0);
                tile.visible = false;

                tileList.push(tile);
                tilemap.addTile(tile);
            }
        #end

        dataList.push(new TilemapParticleRendererData(ps, tilemap, tileList));
        return this;
    }

    public function removeParticleSystem(ps : ParticleSystem) : ParticleSystemRenderer {
        var index = 0;

        while (index < dataList.length) {
            if (dataList[index].ps == ps) {
                removeChild(dataList[index].tilemap);
                dataList.splice(index, 1);
            } else {
                index++;
            }
        }

        if (dataList.length == 0 && !manualUpdate) {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        return this;
    }

    public function update() : Void {
        var updated = false;

        for (data in dataList) {
            if (data.updated = data.ps.__update()) {
                updated = true;
            }
        }

        if (!updated) {
            return;
        }

        for (data in dataList) {
            if (!data.updated) {
                continue;
            }

            var ps = data.ps;

            if (ps.blendFuncSource == GL.DST_COLOR) {
                data.tilemap.blendMode = BlendMode.MULTIPLY;
            } else if (ps.blendFuncDestination == GL.ONE) {
                data.tilemap.blendMode = BlendMode.ADD;
            } else {
                data.tilemap.blendMode = BlendMode.NORMAL;
            }

            var widthMult : Float;
            var heightMult : Float;
            var ethalonSize : Float;

            if (!ps.forceSquareTexture
                || ps.textureBitmapData.width == ps.textureBitmapData.height
                || ps.textureBitmapData.width == 0
                || ps.textureBitmapData.height == 0
            ) {
                widthMult = 1.0;
                heightMult = 1.0;
                ethalonSize = ps.textureBitmapData.width;
            } else if (ps.textureBitmapData.width > ps.textureBitmapData.height) {
                widthMult = ps.textureBitmapData.height / ps.textureBitmapData.width;
                heightMult = 1.0;
                ethalonSize = ps.textureBitmapData.height;
            } else {
                widthMult = 1.0;
                heightMult = ps.textureBitmapData.width / ps.textureBitmapData.height;
                ethalonSize = ps.textureBitmapData.width;
            }

            #if (html5 && dom)
                // Workaround

                if (Math.abs(scaleX) > MathHelper.EPSILON) {
                    widthMult /= scaleX;
                }

                if (Math.abs(scaleY) > MathHelper.EPSILON) {
                    heightMult /= scaleY;
                }
            #end

            var halfWidth : Float = ps.textureBitmapData.width * 0.5;
            var halfHeight : Float = ps.textureBitmapData.height * 0.5;
            var tileList = data.tileList;

            for (i in 0 ... ps.__particleCount) {
                var particle = ps.__particleList[i];

                #if zameparticles_use_tile_visibility
                    var tile : Tile = tileList[i];
                #else
                    var tile : Tile;

                    if (i < tileList.length) {
                        tile = tileList[i];
                    } else {
                        tile = new Tile(0);
                        tileList.push(tile);
                        data.tilemap.addTile(tile);
                    }
                #end

                var particleScale : Float = particle.particleSize / ethalonSize * ps.particleScaleSize;
                var particleScaleX : Float = particleScale * widthMult;
                var particleScaleY : Float = particleScale * heightMult;

                var rotationSine : Float = Math.sin(particle.rotation);
                var rotationCosine : Float = Math.cos(particle.rotation);

                var mat = tile.matrix;
                mat.a = rotationCosine * particleScaleX;
                mat.b = rotationSine * particleScaleX;
                mat.c = - rotationSine * particleScaleY;
                mat.d = rotationCosine * particleScaleY;

                // #if (html5 && dom)
                //     // Workaround
                //     mat.tx = (particle.position.x * ps.particleScaleX - x) * parentScaleX - halfWidth * mat.a - halfHeight * mat.c;
                //     mat.ty = (particle.position.y * ps.particleScaleY - y) * parentScaleY - halfWidth * mat.b - halfHeight * mat.d;
                // #else
                    mat.tx = particle.position.x * ps.particleScaleX - halfWidth * mat.a - halfHeight * mat.c;
                    mat.ty = particle.position.y * ps.particleScaleY - halfWidth * mat.b - halfHeight * mat.d;
                // #end

                tile.matrix = mat;
                tile.alpha = particle.color.a;

                if (tile.colorTransform == null) {
                    tile.colorTransform = new ColorTransform();
                }

                tile.colorTransform.redMultiplier = particle.color.r;
                tile.colorTransform.greenMultiplier = particle.color.g;
                tile.colorTransform.blueMultiplier = particle.color.b;
                tile.invalidate();

                #if zameparticles_use_tile_visibility
                    tile.visible = true;
                #end
            }

            #if zameparticles_use_tile_visibility
                for (i in ps.__particleCount ... tileList.length) {
                    tileList[i].visible = false;
                }
            #else
                if (tileList.length > ps.__particleCount) {
                    data.tilemap.removeTiles(ps.__particleCount, tileList.length);
                    tileList.splice(ps.__particleCount, tileList.length - ps.__particleCount + 1);
                }
            #end
        }
    }

    private function onEnterFrame(_) : Void {
        update();
    }
}
