package zygame.particles.loaders;

import haxe.Json;
import openfl.Assets;
import zygame.particles.ParticleSystem;
import zygame.particles.util.DynamicExt;
import zygame.particles.util.MathHelper;
import zygame.particles.util.ParticleColor;
import zygame.particles.util.ParticleVector;

using zygame.particles.util.DynamicTools;

class JsonParticleLoader {
    public static function load(path : String) : ParticleSystem {
        var map : DynamicExt = Json.parse(Assets.getText(path));
        var ps = new ParticleSystem();

        ps.emitterType = map["emitterType"].asInt();
        ps.maxParticles = map["maxParticles"].asInt();
        ps.positionType = 0;
        ps.duration = map["duration"].asFloat();
        ps.gravity = asVector(map, "gravity");
        ps.particleLifespan = map["particleLifespan"].asFloat();
        ps.particleLifespanVariance = map["particleLifespanVariance"].asFloat();
        ps.speed = map["speed"].asFloat();
        ps.speedVariance = map["speedVariance"].asFloat();
        ps.sourcePosition = new ParticleVector(0.0, 0.0);
        ps.sourcePositionVariance = asVector(map, "sourcePositionVariance");
        ps.angle = MathHelper.deg2rad(map["angle"].asFloat());
        ps.angleVariance = MathHelper.deg2rad(map["angleVariance"].asFloat());
        ps.startParticleSize = map["startParticleSize"].asFloat();
        ps.startParticleSizeVariance = map["startParticleSizeVariance"].asFloat();
        ps.finishParticleSize = map["finishParticleSize"].asFloat();
        ps.finishParticleSizeVariance = map["finishParticleSizeVariance"].asFloat();
        ps.startColor = asColor(map, "startColor");
        ps.startColorVariance = asColor(map, "startColorVariance");
        ps.finishColor = asColor(map, "finishColor");
        ps.finishColorVariance = asColor(map, "finishColorVariance");
        ps.minRadius = map["minRadius"].asFloat();
        ps.minRadiusVariance = map["minRadiusVariance"].asFloat();
        ps.maxRadius = map["maxRadius"].asFloat();
        ps.maxRadiusVariance = map["maxRadiusVariance"].asFloat();
        ps.rotationStart = MathHelper.deg2rad(map["rotationStart"].asFloat());
        ps.rotationStartVariance = MathHelper.deg2rad(map["rotationStartVariance"].asFloat());
        ps.rotationEnd = MathHelper.deg2rad(map["rotationEnd"].asFloat());
        ps.rotationEndVariance = MathHelper.deg2rad(map["rotationEndVariance"].asFloat());
        ps.rotatePerSecond = MathHelper.deg2rad(map["rotatePerSecond"].asFloat());
        ps.rotatePerSecondVariance = MathHelper.deg2rad(map["rotatePerSecondVariance"].asFloat());
        ps.radialAcceleration = map["radialAcceleration"].asFloat();
        ps.radialAccelerationVariance = map["radialAccelVariance"].asFloat();
        ps.tangentialAcceleration = map["tangentialAcceleration"].asFloat();
        ps.tangentialAccelerationVariance = map["tangentialAccelVariance"].asFloat();
        ps.blendFuncSource = map["blendFuncSource"].asInt();
        ps.blendFuncDestination = map["blendFuncDestination"].asInt();
        ps.textureBitmapData = ParticleLoader.loadTexture(map["textureImageData"].asString(), map["textureFileName"].asString(), path);
        ps.yCoordMultiplier = (map["yCoordFlipped"].asInt() == 1 ? -1.0 : 1.0);
        ps.headToVelocity = map["headToVelocity"].asBool(); // custom property
        ps.forceSquareTexture = true;

        return ps;
    }

    private static function asVector(map : DynamicExt, prefix : String) : ParticleVector {
        return new ParticleVector(
            map['${prefix}x'].asFloat(),
            map['${prefix}y'].asFloat()
        );
    }

    private static function asColor(map : DynamicExt, prefix : String) : ParticleColor {
        return new ParticleColor(
            map['${prefix}Red'].asFloat(),
            map['${prefix}Green'].asFloat(),
            map['${prefix}Blue'].asFloat(),
            map['${prefix}Alpha'].asFloat()
        );
    }
}
