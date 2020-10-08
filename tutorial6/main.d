module main;

import dagon;

class TestScene: Scene
{
    Game game;
    OBJAsset aHelmet;
    TextureAsset[5] aHelmetTextures;
    TextureAsset aTexEnvmap;

    this(Game game)
    {
        super(game);
        this.game = game;
    }

    override void beforeLoad()
    {    
        aHelmet = addOBJAsset("data/helmet/helmet.obj");
        aHelmetTextures[0] = addTextureAsset("data/helmet/helmet-albedo.jpg");
        aHelmetTextures[1] = addTextureAsset("data/helmet/helmet-normal.jpg");
        aHelmetTextures[2] = addTextureAsset("data/helmet/helmet-roughness.jpg");
        aHelmetTextures[3] = addTextureAsset("data/helmet/helmet-metallic.jpg");
        aHelmetTextures[4] = addTextureAsset("data/helmet/helmet-emission.jpg");
        
        aTexEnvmap = addTextureAsset("data/envmap.hdr");
    }

    override void afterLoad()
    {
        //game.postProcessingRenderer.tonemapper = Tonemapper.Filmic;
        game.deferredRenderer.ssaoEnabled = true;
        game.deferredRenderer.ssaoPower = 6.0;
        game.postProcessingRenderer.fxaaEnabled = true;
        game.postProcessingRenderer.glowEnabled = true;
        game.postProcessingRenderer.glowThreshold = 0.5f;
        game.postProcessingRenderer.glowIntensity = 0.3f;
        game.postProcessingRenderer.glowRadius = 7;
        
        auto camera = addCamera();
        camera.fov = 23.0f;
        auto freeview = New!FreeviewComponent(eventManager, camera);
        freeview.zoom(-5);
        freeview.pitch(-30.0f);
        freeview.turn(-10.0f);
        game.renderer.activeCamera = camera;

        auto sun = addLight(LightType.Sun);
        sun.shadowEnabled = true;
        sun.energy = 10.0f;
        sun.pitch(-80.0f);
        
        auto matHelmet = addMaterial();
        matHelmet.diffuse = aHelmetTextures[0].texture;
        matHelmet.normal = aHelmetTextures[1].texture;
        matHelmet.roughness = aHelmetTextures[2].texture;
        matHelmet.metallic = aHelmetTextures[3].texture;
        matHelmet.emission = aHelmetTextures[4].texture;
        matHelmet.energy = 1.0f;

        auto eHelmet = addEntity();
        eHelmet.drawable = aHelmet.mesh;
        eHelmet.material = matHelmet;
        eHelmet.position = Vector3f(0, 1, 0);
        eHelmet.scaling = Vector3f(4, 4, 4);
        
        auto envCubemap = New!Cubemap(1024, assetManager);
        envCubemap.fromEquirectangularMap(aTexEnvmap.texture);
        environment.ambientMap = envCubemap;
        environment.fogEnd = 1000.0f;
        
        auto eSky = addEntity();
        eSky.layer = EntityLayer.Background;
        auto psync = New!PositionSync(eventManager, eSky, camera);
        eSky.drawable = New!ShapeBox(Vector3f(1.0f, 1.0f, 1.0f), assetManager);
        eSky.scaling = Vector3f(100.0f, 100.0f, 100.0f);
        eSky.material = addMaterial();
        eSky.material.depthWrite = false;
        eSky.material.culling = false;
        eSky.material.diffuse = envCubemap;
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
    MyGame game = New!MyGame(1280, 720, false, "Dagon tutorial 5. PBR", args);
    game.run();
    Delete(game);
}
