module main;

import dagon;
import dagon.ext.audio;

class TestScene: Scene
{
    MyGame game;
    AudioManager audio;
    
    Camera camera;
    FirstPersonViewComponent fpview;
    
    WavStream music;

    this(MyGame game)
    {
        super(game);
        this.game = game;
        this.audio = game.audioManager;
    }

    override void beforeLoad()
    {
        // Load music
        music = audio.loadMusic("../assets/music/music.flac");
    }
    
    override void onLoad(Time t, float progress)
    {
    }

    override void afterLoad()
    {
        camera = addCamera();
        camera.position = Vector3f(0.0f, 1.8f, 5.0f);
        fpview = New!FirstPersonViewComponent(eventManager, camera);
        game.renderer.activeCamera = camera;
        
        audio.listener = camera;

        auto sun = addLight(LightType.Sun);
        sun.shadowEnabled = true;
        sun.energy = 10.0f;
        sun.pitch(-45.0f);
        
        auto matRed = addMaterial();
        matRed.baseColorFactor = Color4f(1.0, 0.2, 0.2, 1.0);

        auto eCube = addEntity();
        eCube.drawable = New!ShapeBox(Vector3f(1, 1, 1), assetManager);
        eCube.material = matRed;
        eCube.position = Vector3f(0, 1, 0);
        
        auto ePlane = addEntity();
        ePlane.drawable = New!ShapePlane(10, 10, 1, assetManager);
        
        // Play music in 3D
        SoundComponent soundComp = audio.addSoundTo(eCube);
        soundComp.looping = true;
        soundComp.play(music);
    }
    
    ~this()
    {
        music.free();
    }
    
    override void onUpdate(Time t)
    {
        // Camera movement
        float speed = 5.0f * t.delta;
        if (inputManager.getButton("forward")) camera.move(-speed);
        if (inputManager.getButton("back")) camera.move(speed);
        if (inputManager.getButton("left")) camera.strafe(-speed);
        if (inputManager.getButton("right")) camera.strafe(speed);
        
        audio.update(t);
    }
    
    override void onKeyDown(int key)
    {
        if (key == KEY_ESCAPE)
            application.exit();
    }

    override void onMouseButtonUp(int button)
    {
        fpview.active = !fpview.active;
        eventManager.showCursor(!fpview.active);
        fpview.prevMouseX = eventManager.mouseX;
        fpview.prevMouseY = eventManager.mouseY;
    }
}

class MyGame: Game
{
    AudioManager audioManager;
    
    this(uint w, uint h, bool fullscreen, string title, string[] args)
    {
        super(w, h, fullscreen, title, args);
        audioManager = New!AudioManager(this);
        currentScene = New!TestScene(this);
    }
}

void main(string[] args)
{
    loadSoloud();
    MyGame game = New!MyGame(1280, 720, false, "Dagon tutorial 19. 3D sound", args);
    game.run();
    Delete(game);
}
