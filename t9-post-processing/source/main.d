module main;

import dagon;

class TestScene: Scene
{
    Game game;
    OBJAsset aOBJSuzanne;
    TextureAsset aTexStoneDiffuse;
    TextureAsset aTexStoneNormal;
    TextureAsset aTexStoneHeight;
    
    TextureAsset aTexColorTable;

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
        aTexColorTable = addTextureAsset("../assets/filter1.png");
    }

    override void afterLoad()
    {
        game.deferredRenderer.ssaoEnabled = true;
        game.deferredRenderer.ssaoPower = 6.0;
        game.postProcessingRenderer.tonemapper = Tonemapper.AgX_Punchy;
        game.postProcessingRenderer.motionBlurEnabled = true;
        game.postProcessingRenderer.glowEnabled = true;
        game.postProcessingRenderer.glowThreshold = 0.3f;
        game.postProcessingRenderer.glowIntensity = 0.3f;
        game.postProcessingRenderer.glowRadius = 10;
        game.postProcessingRenderer.fxaaEnabled = true;
        game.postProcessingRenderer.lutEnabled = true;
        game.postProcessingRenderer.lensDistortionEnabled = true;
        game.postProcessingRenderer.motionBlurFramerate = 45;
        game.postProcessingRenderer.colorLookupTable = aTexColorTable.texture;
        
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
        
        auto matSuzanne = addMaterial();
        matSuzanne.baseColorFactor = Color4f(1.0, 0.2, 0.2, 1.0);
        
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
    MyGame game = New!MyGame(1280, 720, false, "Dagon tutorial 9. Post-processing", args);
    game.run();
    Delete(game);
}
