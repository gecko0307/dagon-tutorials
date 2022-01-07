module main;

import dagon;

class TestScene: Scene
{
    Game game;
    OBJAsset aOBJSuzanne;
    Camera camera;
    FirstPersonViewComponent fpview;

    this(Game game)
    {
        super(game);
        this.game = game;
    }

    override void beforeLoad()
    {    
        aOBJSuzanne = addOBJAsset("../assets/suzanne.obj");
    }

    override void afterLoad()
    {
        game.deferredRenderer.ssaoEnabled = true;
        game.deferredRenderer.ssaoPower = 6.0;
        game.postProcessingRenderer.tonemapper = Tonemapper.Filmic;
        game.postProcessingRenderer.fxaaEnabled = true;
        
        camera = addCamera();
        camera.position = Vector3f(0.0f, 1.8f, 5.0f);
        fpview = New!FirstPersonViewComponent(eventManager, camera);
        game.renderer.activeCamera = camera;
        eventManager.showCursor(false);

        auto sun = addLight(LightType.Sun);
        sun.shadowEnabled = true;
        sun.energy = 10.0f;
        sun.pitch(-45.0f);
        
        auto matSuzanne = addMaterial();
        matSuzanne.diffuse = Color4f(1.0, 0.2, 0.2, 1.0);

        auto eSuzanne = addEntity();
        eSuzanne.drawable = aOBJSuzanne.mesh;
        eSuzanne.material = matSuzanne;
        eSuzanne.position = Vector3f(0, 1, 0);
        
        auto ePlane = addEntity();
        ePlane.drawable = New!ShapePlane(10, 10, 1, assetManager);
    }
    
    override void onUpdate(Time t)
    {
        // Camera movement
        float speed = 5.0f * t.delta;
        if (inputManager.getButton("forward")) camera.move(-speed);
        if (inputManager.getButton("back")) camera.move(speed);
        if (inputManager.getButton("left")) camera.strafe(-speed);
        if (inputManager.getButton("right")) camera.strafe(speed);
    }
    
    override void onMouseButtonUp(int button)
    {
        fpview.active = !fpview.active;
        eventManager.showCursor(!fpview.active);
        fpview.prevMouseX = eventManager.mouseX;
        fpview.prevMouseY = eventManager.mouseY;
    }
    
    override void onKeyDown(int key)
    {
        if (key == KEY_ESCAPE)
            application.exit();
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
    MyGame game = New!MyGame(1280, 720, false, "Dagon tutorial 7. First Person Camera", args);
    game.run();
    Delete(game);
}
