module main;

import dagon;
import soloud;

class TestScene: Scene
{
    MyGame game;
    Soloud audio;
    
    Camera camera;
    FirstPersonViewComponent fpview;
    
    WavStream music;

    this(MyGame game)
    {
        super(game);
        this.game = game;
        this.audio = game.audio;
    }

    override void beforeLoad()
    {
        // Load music
        music = WavStream.create();
        music.load("data/music.flac");
        music.set3dDistanceDelay(true);
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
        
        game.deferredRenderer.ssaoEnabled = true;
        game.deferredRenderer.ssaoPower = 6.0;
        game.postProcessingRenderer.fxaaEnabled = true;
        
        // Play music in 3D
        int voice = audio.play3d(music, eCube.position.x, eCube.position.y, eCube.position.z);
        audio.setLooping(voice, true);
        audio.set3dSourceMinMaxDistance(voice, 1.0f, 50.0f);
        audio.set3dSourceAttenuation(voice, 2, 1.0f);
        audio.update3dAudio();
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
        
        // Feed camera data to 3D listener
        audio.set3dListenerPosition(camera.position.x, camera.position.y, camera.position.z);
        audio.set3dListenerAt(camera.direction.x, camera.direction.y, camera.direction.z);
        audio.set3dListenerUp(camera.up.x, camera.up.y, camera.up.z);
        audio.update3dAudio();
    }
    
    override void onKeyDown(int key)
    {
        if (key == KEY_ESCAPE)
            application.exit();
    }
    
    override void onKeyUp(int key) { }
    
    override void onMouseButtonDown(int button) { }

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
    Soloud audio;
    
    this(uint w, uint h, bool fullscreen, string title, string[] args)
    {
        super(w, h, fullscreen, title, args);
        audio = Soloud.create();
        audio.init(Soloud.CLIP_ROUNDOFF | Soloud.LEFT_HANDED_3D);
        currentScene = New!TestScene(this);
    }
}

void main(string[] args)
{
    loadSoloud();
    MyGame game = New!MyGame(1280, 720, false, "Dagon application", args);
    game.run();
    Delete(game);
}
