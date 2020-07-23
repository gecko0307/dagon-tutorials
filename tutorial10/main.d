module main;

import dagon;
import dagon.ext.physics;

class TestScene: Scene
{
    Game game;
    
    PhysicsWorld physicsWorld;
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
        aTexStoneDiffuse = addTextureAsset("data/stone-diffuse.png");
        aTexStoneNormal = addTextureAsset("data/stone-normal.png");
        aTexStoneHeight = addTextureAsset("data/stone-height.png");
        
        aTexCrateDiffuse = addTextureAsset("data/crate-diffuse.png");
        aTexCrateNormal = addTextureAsset("data/crate-normal.png");
    }

    override void afterLoad()
    {
        physicsWorld = New!PhysicsWorld(assetManager);
        
        game.deferredRenderer.ssaoEnabled = true;
        game.deferredRenderer.ssaoPower = 6.0;
        game.postProcessingRenderer.fxaaEnabled = true;
        
        auto camera = addCamera();
        auto freeview = New!FreeviewComponent(eventManager, camera);
        freeview.zoom(-20);
        freeview.pitch(-30.0f);
        freeview.turn(10.0f);
        game.renderer.activeCamera = camera;

        auto sun = addLight(LightType.Sun);
        sun.shadowEnabled = true;
        sun.energy = 10.0f;
        sun.pitch(-45.0f);
        
        auto matGround = addMaterial();
        matGround.diffuse = aTexStoneDiffuse.texture;
        matGround.normal = aTexStoneNormal.texture;
        matGround.height = aTexStoneHeight.texture;
        matGround.parallax = ParallaxSimple;
        matGround.textureScale = Vector2f(2, 2);
        
        auto ePlane = addEntity();
        ePlane.drawable = New!ShapePlane(20, 20, 2, assetManager);
        ePlane.material = matGround;
        
        RigidBody rbPlane = physicsWorld.addStaticBody(Vector3f(0.0f, -1.0f, 0.0f));
        auto rbPlaneGeom = New!GeomBox(physicsWorld, Vector3f(10, 1, 10));
        physicsWorld.addShapeComponent(rbPlane, rbPlaneGeom, Vector3f(0.0f, 0.0f, 0.0f), 1.0f);
        
        auto matBox = addMaterial();
        matBox.diffuse = aTexCrateDiffuse.texture;
        matBox.normal = aTexCrateNormal.texture;
        matBox.roughness = 0.8f;
        
        auto rbBoxGeom = New!GeomBox(physicsWorld, Vector3f(0.5f, 0.5f, 0.5f));
        auto shBox = New!ShapeBox(Vector3f(1, 1, 1), assetManager);
        foreach(i; 0..NumBoxes)
        {
            auto eBox = addEntity();
            eBox.drawable = shBox;
            eBox.material = matBox;
            eBox.position = Vector3f(i * 0.05f, 3.0f + 3.0f * cast(float)i, 0.0f);
            eBox.scaling = Vector3f(0.5f, 0.5f, 0.5f);
            auto rbBox = physicsWorld.addDynamicBody(Vector3f(0, 0, 0), 0.0f);
            RigidBodyComponent rbBoxComp = New!RigidBodyComponent(eventManager, eBox, rbBox);
            physicsWorld.addShapeComponent(rbBox, rbBoxGeom, Vector3f(0.0f, 0.0f, 0.0f), 10.0f);
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
    MyGame game = New!MyGame(1280, 720, false, "Dagon tutorial 10. Physics", args);
    game.run();
    Delete(game);
}
