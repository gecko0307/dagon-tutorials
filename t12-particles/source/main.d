module main;

import dagon;

class TestScene: Scene
{
    Game game;
    
    TextureAsset aTexFireDiffuse;
    TextureAsset aTexSmokeDiffuse;

    this(Game game)
    {
        super(game);
        this.game = game;
    }

    override void beforeLoad()
    {
        aTexFireDiffuse = addTextureAsset("../assets/particles/fire.png");
        aTexSmokeDiffuse = addTextureAsset("../assets/particles/smoke-diffuse.png");
    }

    override void afterLoad()
    {
        game.deferredRenderer.ssaoEnabled = true;
        game.deferredRenderer.ssaoPower = 6.0;
        game.postProcessingRenderer.tonemapper = Tonemapper.Filmic;
        game.postProcessingRenderer.fxaaEnabled = true;
        
        auto camera = addCamera();
        auto freeview = New!FreeviewComponent(eventManager, camera);
        freeview.setZoom(5);
        freeview.setRotation(30.0f, -45.0f, 0.0f);
        freeview.translationStiffness = 0.25f;
        freeview.rotationStiffness = 0.25f;
        freeview.zoomStiffness = 0.25f;
        game.renderer.activeCamera = camera;

        auto sun = addLight(LightType.Sun);
        sun.shadowEnabled = true;
        sun.energy = 10.0f;
        sun.pitch(-45.0f);
        
        auto mParticlesSmoke = addMaterial();
        mParticlesSmoke.baseColorTexture = aTexSmokeDiffuse.texture;
        mParticlesSmoke.sphericalNormal = true;
        mParticlesSmoke.shadeless = true;
        mParticlesSmoke.blendMode = Transparent;
        mParticlesSmoke.depthWrite = false;
        mParticlesSmoke.emissionEnergy = 2.0f;
        mParticlesSmoke.sun = sun;
        
        auto mParticlesFire = addMaterial();
        mParticlesFire.baseColorTexture = aTexFireDiffuse.texture;
        mParticlesFire.sphericalNormal = true;
        mParticlesFire.shadeless = true;
        mParticlesFire.blendMode = Additive;
        mParticlesFire.depthWrite = false;
        mParticlesFire.emissionEnergy = 5.0f;
        mParticlesFire.sun = sun;

        auto eParticleSystem = addEntity();
        auto particleSystem = New!ParticleSystem(eventManager, eParticleSystem);
        
        auto eParticlesFire = addEntity();
        auto emitterFire = New!Emitter(eParticlesFire, particleSystem, 50);
        emitterFire.material = mParticlesFire;
        emitterFire.startColor = Color4f(1.0f, 0.8f, 0.5f, 1.0f);
        emitterFire.endColor = Color4f(0.5f, 0.0f, 0.0f, 0.0f);
        emitterFire.initialDirectionRandomFactor = 0.2f;
        emitterFire.scaleStep = Vector2f(-1.0f, 1.5f);
        emitterFire.rotationStep = 0.5f;
        emitterFire.minInitialSpeed = 5.0f;
        emitterFire.maxInitialSpeed = 10.0f;
        emitterFire.minSize = 0.5f;
        emitterFire.maxSize = 2.0f;
        emitterFire.minLifetime = 0.5f;
        emitterFire.maxLifetime = 1.0f;
        eParticlesFire.position = Vector3f(0.0f, 0.0f, 0.0f);
        eParticlesFire.visible = true;
        
        auto eParticlesSmoke = addEntity();
        auto emitterSmoke = New!Emitter(eParticlesSmoke, particleSystem, 50);
        emitterSmoke.material = mParticlesSmoke;
        emitterSmoke.startColor = Color4f(1.0f, 1.0f, 1.0f, 0.2f);
        emitterSmoke.endColor = Color4f(1.0f, 1.0f, 1.0f, 0.0f);
        emitterSmoke.initialDirectionRandomFactor = 0.2f;
        emitterSmoke.scaleStep = Vector2f(1.0f, 1.0f);
        emitterSmoke.rotationStep = 0.0f;
        emitterSmoke.minInitialSpeed = 5.0f;
        emitterSmoke.maxInitialSpeed = 10.0f;
        emitterSmoke.minSize = 0.5f;
        emitterSmoke.maxSize = 2.0f;
        eParticlesSmoke.position = Vector3f(0.0f, 2.0f, 0.0f);
        eParticlesSmoke.visible = true;
    }
}

class MyGame: Game
{
    this(uint w, uint h, bool fullscreen, string title, string[] args)
    {
        super(w, h, fullscreen, title, args);
        currentScene = New!TestScene(this);
    }
}

void main(string[] args)
{
    MyGame game = New!MyGame(1280, 720, false, "Dagon tutorial 12. Particles", args);
    game.run();
    Delete(game);
}
