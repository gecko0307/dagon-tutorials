module main;

import std.stdio;
import dagon;

class TestScene: Scene
{
    MyGame game;
    
    GLTFAsset aFox;
    GLTFBlendedPose pose;
    
    TextureAsset aGrass;
    
    Entity ePlane;

    this(MyGame game)
    {
        super(game);
        this.game = game;
    }

    override void beforeLoad()
    {
        aFox = addGLTFAsset("../assets/fox/Fox.gltf");
        aGrass = addTextureAsset("../assets/pixel_grass.png");
    }

    override void afterLoad()
    {  
        game.deferredRenderer.ssaoEnabled = true;
        game.deferredRenderer.ssaoPower = 6.0;
        game.postProcessingRenderer.tonemapper = Tonemapper.Filmic;
        game.postProcessingRenderer.fxaaEnabled = true;
        
        environment.backgroundColor = Color4f(0.75f, 0.75f, 1.0f, 1.0f);
        environment.fogEnd = 1000.0f;
        
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
        sun.turn(45.0f);
        sun.pitch(-45.0f);
        
        auto sphere = New!ShapeSphere(0.25f, 6, 12, false, assetManager);
        
        useEntity(aFox.rootEntity);
        foreach(node; aFox.nodes)
        {
            useEntity(node.entity);
        }
        
        aFox.rootEntity.scaling = Vector3f(0.01f, 0.01f, 0.01f);
        aFox.material("fox_material").shadeless = true;
        
        auto nFox = aFox.node("fox");
        pose = New!GLTFBlendedPose(nFox.skin, assetManager);
        pose.switchToAnimation(aFox.animation("Walk"));
        auto eFox = nFox.entity;
        eFox.pose = pose;
        eFox.renderLayer = 1;
        pose.play();
        
        // Attach an Entity to bone:
        //auto eSphere = addEntity(aFox.node("b_Head_05").entity);
        //eSphere.drawable = New!ShapeSphere(15.0f, assetManager);
        
        ePlane = addEntity();
        ePlane.drawable = New!ShapePlane(5, 5, 1, assetManager);
        ePlane.material = addMaterial();
        ePlane.material.shadeless = true;
        ePlane.material.baseColorTexture = aGrass.texture;
        ePlane.material.baseColorTexture.minFilter = GL_NEAREST;
        ePlane.material.baseColorTexture.magFilter = GL_NEAREST;
        ePlane.material.textureScale = Vector2f(4.0f, 4.0f);
        ePlane.renderLayer = 0;
        
        game.pass0.shadowEnabled = true;
        game.pass0.shadowCenter = eFox.position;
        game.pass0.shadowMinRadius = 0.0f;
        game.pass0.shadowMaxRadius = 0.5f;
        game.pass0.shadowOpacity = 0.75f;
    }
    
    float groundScroll = 0.0f;
    float groundScrollSpeed = 0.8f;
    
    override void onKeyDown(int key)
    {
        if (key == KEY_1)
        {
            pose.switchToAnimation(aFox.animation("Survey"), 0.25f);
            groundScrollSpeed = 0.0f;
        }
        else if (key == KEY_2)
        {
            pose.switchToAnimation(aFox.animation("Walk"), 0.25f);
            groundScrollSpeed = 0.8f;
        }
        else if (key == KEY_3)
        {
            pose.switchToAnimation(aFox.animation("Run"), 0.25f);
            groundScrollSpeed = 1.0f;
        }
    }
    
    override void onUpdate(Time t)
    {
        pose.update(t);
        groundScroll += groundScrollSpeed * t.delta;
        if (groundScroll >= 1.0f) groundScroll -= 1.0f;
        ePlane.material.textureOffset = Vector2f(0.0f, groundScroll);
    }
}

class MyGame: Game
{
    SimpleRenderer simpleRenderer;
    SimpleRenderPass pass0;
    SimpleRenderPass pass1;
    
    this(uint w, uint h, bool fullscreen, string title, string[] args)
    {
        super(w, h, fullscreen, title, args);
        currentScene = New!TestScene(this);
        
        simpleRenderer = New!SimpleRenderer(eventManager, this);
        renderer = simpleRenderer;
        
        pass0 = simpleRenderer.defaultLayerPass;
        pass1 = simpleRenderer.addLayerPass(1); // Transparent
    }
}

void main(string[] args)
{
    version (none)
    {
        import etc.linux.memoryerror;
        registerMemoryAssertHandler();
    }

    MyGame game = New!MyGame(1280, 720, false, "Dagon glTF Animation Demo", args);
    game.run();
    Delete(game);
}
