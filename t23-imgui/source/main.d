module main;

import dagon;
import dagon.ext.imgui;

class ImGui: EventListener
{
    Application application;
    ImGuiContext* igContext;
    ImGuiIO* io;
    ImFont* font;
    
    this(Application application)
    {
        super(application.eventManager, application);
        this.application = application;
        
        igContext = igCreateContext(null);
        igSetCurrentContext(igContext);
        io = igGetIO();
        io.ConfigFlags |= ImGuiConfigFlags.DockingEnable;
        io.ConfigWindowsMoveFromTitleBarOnly = true;
        ImWchar[] ranges = [
            0x0020, 0x00FF, // Basic Latin + Latin Supplement
            0x0370, 0x03FF, // Greek
            0x0400, 0x044F, // Cyrillic
            0
        ];
        font = ImFontAtlas_AddFontFromFileTTF(io.Fonts, "../assets/font/DroidSans.ttf", 16, null, 
            ranges.ptr);
        igStyleColorsDark(null);
        ImGui_ImplSDL2_InitForOpenGL(application.window, application.glcontext);
        ImGuiOpenGLBackend.init();
    }
    
    void onProcessEvent(SDL_Event* event)
    {
        ImGui_ImplSDL2_ProcessEvent(event);
    }
    
    bool capturesMouse() @property
    {
        return io.WantCaptureMouse;
    }
    
    bool capturesKeyboard() @property
    {
        return io.WantCaptureKeyboard;
    }
    
    bool show_demo_window = true;
    
    void update(Time t)
    {
        processEvents();
        
        ImGuiOpenGLBackend.new_frame();
        ImGui_ImplSDL2_NewFrame();
        igNewFrame();
        
        if (show_demo_window)
            igShowDemoWindow(&show_demo_window);
        
        igRender();
    }
    
    void render()
    {
        ImGuiOpenGLBackend.render_draw_data(igGetDrawData());
    }
}

class MyScene: Scene
{
    Game game;
    FreeviewComponent freeview;

    this(Game game)
    {
        super(game);
        this.game = game;
    }

    override void beforeLoad()
    {
    }
    
    override void onLoad(Time t, float progress)
    {
    }

    override void afterLoad()
    {
        auto camera = addCamera();
        freeview = New!FreeviewComponent(eventManager, camera);
        freeview.zoom(10);
        freeview.pitch(-30.0f);
        freeview.turn(10.0f);
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
    }
    
    override void onUpdate(Time t)
    {
        freeview.active = focused;
    }
    
    override void onKeyDown(int key) { }
    override void onKeyUp(int key) { }
    override void onMouseButtonDown(int button) { }
    override void onMouseButtonUp(int button) { }
}

class MyGame: Game
{
    ImGui ui;
    
    this(uint windowWidth, uint windowHeight, bool fullscreen, string title, string[] args)
    {
        super(windowWidth, windowHeight, fullscreen, title, args);
        currentScene = New!MyScene(this);
        ui = New!ImGui(this);
        eventManager.onProcessEvent = &ui.onProcessEvent;
    }
    
    override void onUpdate(Time t)
    {
        super.onUpdate(t);
        ui.update(t);
        currentScene.focused = !ui.capturesMouse;
    }
    
    override void onRender()
    {
        super.onRender();
        ui.render();
    }
}

void main(string[] args)
{
    ImGuiSupport sup = loadImGui();
    MyGame game = New!MyGame(1280, 720, false, "Dagon tutorial 23. ImGui", args);
    game.run();
    Delete(game);
}
