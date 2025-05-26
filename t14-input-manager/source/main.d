module main;

import std.stdio;
import dagon;

class TestScene: Scene
{
    Game game;
    OBJAsset aOBJSuzanne;

    this(Game game)
    {
        super(game);
        this.game = game;
    }

    override void beforeLoad()
    {    
        aOBJSuzanne = addOBJAsset("../assets/suzanne.obj");
    }
    
    override void onControllerButtonDown(int btn)
    {
        string name;
        switch(btn)
        {
            case SDL_CONTROLLER_BUTTON_DPAD_UP: name = "Up"; break;
            case SDL_CONTROLLER_BUTTON_DPAD_DOWN: name = "Down"; break;
            case SDL_CONTROLLER_BUTTON_DPAD_LEFT: name = "Left"; break;
            case SDL_CONTROLLER_BUTTON_DPAD_RIGHT: name = "Right"; break;
            case SDL_CONTROLLER_BUTTON_A: name = "A"; break;
            case SDL_CONTROLLER_BUTTON_B: name = "B"; break;
            case SDL_CONTROLLER_BUTTON_X: name = "X"; break;
            case SDL_CONTROLLER_BUTTON_Y: name = "Y"; break;
            case SDL_CONTROLLER_BUTTON_LEFTSHOULDER: name = "Left shoulder"; break;
            case SDL_CONTROLLER_BUTTON_RIGHTSHOULDER: name = "Right shoulder"; break;
            case SDL_CONTROLLER_BUTTON_START: name = "Start"; break;
            case SDL_CONTROLLER_BUTTON_GUIDE: name = "Guide"; break;
            case SDL_CONTROLLER_BUTTON_BACK: name = "Back"; break;
            default: name = "?"; break;
        }
        logInfo(name);
    }
    
    override void onControllerAxisMotion(int axis, float value)
    {
        string name;
        switch(axis)
        {
            case SDL_CONTROLLER_AXIS_LEFTX: name = "Left X"; break;
            case SDL_CONTROLLER_AXIS_LEFTY: name = "Left Y"; break;
            case SDL_CONTROLLER_AXIS_RIGHTX: name = "Right X"; break;
            case SDL_CONTROLLER_AXIS_RIGHTY: name = "Right Y"; break;
            case SDL_CONTROLLER_AXIS_TRIGGERLEFT: name = "Trigger left"; break;
            case SDL_CONTROLLER_AXIS_TRIGGERRIGHT: name = "Trigger right"; break;
            default: name = "?"; break;
        }
        logInfo(name, ": ", value);
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
        
        auto matSuzanne = addMaterial();
        matSuzanne.baseColorFactor = Color4f(1.0, 0.2, 0.2, 1.0);

        auto eSuzanne = addEntity();
        eSuzanne.drawable = aOBJSuzanne.mesh;
        eSuzanne.material = matSuzanne;
        eSuzanne.position = Vector3f(0, 1, 0);
        
        auto ePlane = addEntity();
        ePlane.drawable = New!ShapePlane(10, 10, 1, assetManager);
    }
    
    override void onUpdate(Time t)
    {
        if (inputManager.getButton("forward")) logInfo("forward");
        if (inputManager.getButton("back")) logInfo("back");
        if (inputManager.getButton("left")) logInfo("left");
        if (inputManager.getButton("right")) logInfo("right");
        if (inputManager.getButton("jump")) logInfo("jump");
        if (inputManager.getButton("interact")) logInfo("interact");
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
    MyGame game = New!MyGame(1280, 720, false, "Dagon tutorial 14. Input manager", args);
    game.run();
    Delete(game);
}
