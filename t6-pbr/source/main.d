module main;

import dagon;

class TestScene: Scene
{
    Game game;
    GLTFAsset aHelmet;
    TextureAsset aEnvmap;
    TextureAsset aBRDF;

    this(Game game)
    {
        super(game);
        this.game = game;
    }

    override void beforeLoad()
    {    
        aHelmet = addGLTFAsset("../assets/helmet-gltf/DamagedHelmet.gltf");
        aEnvmap = addTextureAsset("../assets/envmap.dds");
        aBRDF = addTextureAsset("../assets/brdf.dds");
    }

    override void afterLoad()
    {
        game.postProcessingRenderer.tonemapper = Tonemapper.Filmic;
        game.deferredRenderer.ssaoEnabled = true;
        game.deferredRenderer.ssaoPower = 6.0;
        game.postProcessingRenderer.fxaaEnabled = true;
        
        auto camera = addCamera();
        camera.fov = 23.0f;
        auto freeview = New!FreeviewComponent(eventManager, camera);
        freeview.zoom(15.0f);
        freeview.pitch(-30.0f);
        freeview.turn(-10.0f);
        game.renderer.activeCamera = camera;

        auto sun = addLight(LightType.Sun);
        sun.shadowEnabled = true;
        sun.energy = 10.0f;
        sun.pitch(-24.0f);

        Entity helmet = aHelmet.rootEntity;
        useEntity(helmet);
        foreach(node; aHelmet.nodes)
            useEntity(node.entity);
        
        environment.ambientMap = aEnvmap.texture;
        environment.ambientBRDF = aBRDF.texture;
        aBRDF.texture.useMipmapFiltering = false;
        aBRDF.texture.enableRepeat(false);
        environment.fogStart = 100.0f;
        environment.fogEnd = 10000.0f;
        
        auto eSky = addEntity();
        eSky.layer = EntityLayer.Background;
        auto psync = New!PositionSync(eventManager, eSky, camera);
        eSky.drawable = New!ShapeBox(Vector3f(1.0f, 1.0f, 1.0f), assetManager);
        eSky.scaling = Vector3f(100.0f, 100.0f, 100.0f);
        eSky.material = addMaterial();
        eSky.material.depthWrite = false;
        eSky.material.useCulling = false;
        eSky.material.baseColorTexture = aEnvmap.texture;
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
    MyGame game = New!MyGame(1280, 720, false, "Dagon tutorial 6. glTF Asset with PBR materials", args);
    game.run();
    Delete(game);
}
