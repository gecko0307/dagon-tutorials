module main;

import std.stdio;
import std.conv;
import dagon;
import dagon.ext.newton;

class TestScene: Scene
{
    Game game;
    
    NewtonPhysicsWorld physicsWorld;
    enum NumBoxes = 20;
    
    TextureAsset aTexStoneDiffuse;
    TextureAsset aTexStoneNormal;
    TextureAsset aTexStoneHeight;
    
    TextureAsset aTexCrateDiffuse;
    TextureAsset aTexCrateNormal;

    this(Game game)
    {
        super(game);
        this.game = game;
    }

    override void beforeLoad()
    {    
        aTexStoneDiffuse = addTextureAsset("../assets/stone-diffuse.png");
        aTexStoneNormal = addTextureAsset("../assets/stone-normal.png");
        aTexStoneHeight = addTextureAsset("../assets/stone-height.png");
        aTexCrateDiffuse = addTextureAsset("../assets/crate-diffuse.png");
        aTexCrateNormal = addTextureAsset("../assets/crate-normal.png");
    }

    override void afterLoad()
    {
        physicsWorld = New!NewtonPhysicsWorld(eventManager, assetManager);
        physicsWorld.loadPlugins("./");
        
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
        
        auto matGround = addMaterial();
        matGround.baseColorTexture = aTexStoneDiffuse.texture;
        matGround.normalTexture = aTexStoneNormal.texture;
        matGround.heightTexture = aTexStoneHeight.texture;
        matGround.parallaxMode = ParallaxSimple;
        matGround.textureScale = Vector2f(5, 5);
        
        auto ePlane = addEntity();
        ePlane.drawable = New!ShapeBox(Vector3f(10, 0.5f, 10), assetManager);
        ePlane.material = matGround;
        auto planeShape = New!NewtonBoxShape(Vector3f(20, 1, 20), physicsWorld);
        auto ePlanePhysicsController = ePlane.makeStaticBody(physicsWorld, planeShape);
        
        auto matBox = addMaterial();
        matBox.baseColorTexture = aTexCrateDiffuse.texture;
        matBox.normalTexture = aTexCrateNormal.texture;
        matBox.roughnessFactor = 0.8f;
        
        auto shBox = New!ShapeBox(Vector3f(0.5f, 0.5f, 0.5f), assetManager);
        auto boxShape = New!NewtonBoxShape(Vector3f(1, 1, 1), physicsWorld);
        foreach(i; 0..NumBoxes)
        {
            auto eBox = addEntity();
            eBox.drawable = shBox;
            eBox.material = matBox;
            eBox.position = Vector3f(i * 0.05f, 3.0f + 3.0f * cast(float)i, 0.0f);
            auto eBoxPhysicsController = eBox.makeDynamicBody(physicsWorld, boxShape, 10.0f);
        }
    }
    
    override void onUpdate(Time t)
    {
        physicsWorld.update(t.delta);
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
    import loader = bindbc.loader.sharedlib;
    NewtonSupport sup = loadNewton();
    foreach(info; loader.errors)
    {
        writeln(info.error.to!string, " ", info.message.to!string);
    }
    
    MyGame game = New!MyGame(1280, 720, false, "Dagon tutorial 10. Physics", args);
    game.run();
    Delete(game);
}
