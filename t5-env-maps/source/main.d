module main;

import dagon;

class TestScene: Scene
{
    Game game;
    OBJAsset aOBJSuzanne;
    TextureAsset aTexStoneDiffuse;
    TextureAsset aTexStoneNormal;
    TextureAsset aTexStoneHeight;
    TextureAsset aEnvmap;
    TextureAsset aBRDF;

    this(Game game)
    {
        super(game);
        this.game = game;
    }

    override void beforeLoad()
    {    
        aOBJSuzanne = addOBJAsset("../assets/suzanne.obj");
        aTexStoneDiffuse = addTextureAsset("../assets/stone-diffuse.png");
        aTexStoneNormal = addTextureAsset("../assets/stone-normal.png");
        aTexStoneHeight = addTextureAsset("../assets/stone-height.png");
        aEnvmap = addTextureAsset("../assets/envmap.dds");
        aBRDF = addTextureAsset("../assets/brdf.dds");
    }

    override void afterLoad()
    {
        game.deferredRenderer.ssaoEnabled = true;
        game.deferredRenderer.ssaoPower = 6.0;
        game.postProcessingRenderer.tonemapper = Tonemapper.Filmic;
        game.postProcessingRenderer.fxaaEnabled = true;
        
        auto camera = addCamera();
        auto freeview = New!FreeviewComponent(eventManager, camera);
        freeview.zoom(5);
        freeview.pitch(-30.0f);
        freeview.turn(10.0f);
        game.renderer.activeCamera = camera;

        auto sun = addLight(LightType.Sun);
        sun.shadowEnabled = true;
        sun.energy = 10.0f;
        sun.turn(-90.0f);
        sun.pitch(-24.0f);
        
        auto matSuzanne = addMaterial();
        matSuzanne.baseColorFactor = Color4f(1.0, 0.2, 0.2, 1.0);
        matSuzanne.roughnessFactor = 0.8f;
        
        auto matGround = addMaterial();
        matGround.baseColorTexture = aTexStoneDiffuse.texture;
        matGround.normalTexture = aTexStoneNormal.texture;
        matGround.heightTexture = aTexStoneHeight.texture;
        matGround.parallaxMode = ParallaxSimple;
        matGround.textureScale = Vector2f(2, 2);

        auto eSuzanne = addEntity();
        eSuzanne.drawable = aOBJSuzanne.mesh;
        eSuzanne.material = matSuzanne;
        eSuzanne.position = Vector3f(0, 1, 0);
        
        auto ePlane = addEntity();
        ePlane.drawable = New!ShapePlane(10, 10, 1, assetManager);
        ePlane.material = matGround;
        
        environment.ambientMap = aEnvmap.texture;
        environment.ambientBRDF = aBRDF.texture;
        aBRDF.texture.useMipmapFiltering = false;
        aBRDF.texture.enableRepeat(false);
        
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
    MyGame game = New!MyGame(1280, 720, false, "Dagon tutorial 5. Environment maps", args);
    game.run();
    Delete(game);
}
