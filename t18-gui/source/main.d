module main;

import std.stdio;

import dagon;
import dagon.ext.nuklear;
import dagon.ext.ftfont;

class TestScene: Scene
{
    Game game;
    
    OBJAsset aOBJSuzanne;
    Entity eSuzanne;
    
    FreeviewComponent freeview;
    
    FontAsset aFont;
    NuklearGUI gui;
    Entity eNuklear;
    
    Color4f diffuseColor = Color4f(1.0, 0.2, 0.2, 1.0);
    bool diffuseColorPicker = false;
    float roughness = 0.5f;
    float metallic = 0.0f;
    float energy = 0.0f;

    this(Game game)
    {
        super(game);
        this.game = game;
    }

    override void beforeLoad()
    {
        aOBJSuzanne = addOBJAsset("../assets/suzanne.obj");
        aFont = this.addFontAsset("../assets/font/DroidSans.ttf", 14);
    }

    override void afterLoad()
    {
        game.deferredRenderer.ssaoEnabled = true;
        game.deferredRenderer.ssaoPower = 6.0;
        game.postProcessingRenderer.tonemapper = Tonemapper.Filmic;
        game.postProcessingRenderer.motionBlurEnabled = true;
        game.postProcessingRenderer.motionBlurFramerate = 45;
        game.postProcessingRenderer.glowEnabled = true;
        game.postProcessingRenderer.glowThreshold = 0.3f;
        game.postProcessingRenderer.glowIntensity = 0.3f;
        game.postProcessingRenderer.glowRadius = 10;
        game.postProcessingRenderer.fxaaEnabled = true;
        game.postProcessingRenderer.lutEnabled = false;
        game.postProcessingRenderer.lensDistortionEnabled = false;
        
        auto camera = addCamera();
        freeview = New!FreeviewComponent(eventManager, camera);
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
        
        auto ePlane = addEntity();
        ePlane.drawable = New!ShapePlane(10, 10, 2, assetManager);
        ePlane.material = matGround;
        
        auto matSuzanne = addMaterial();

        eSuzanne = addEntity();
        eSuzanne.drawable = aOBJSuzanne.mesh;
        eSuzanne.material = matSuzanne;
        eSuzanne.position = Vector3f(0, 1, 0);
        
        gui = New!NuklearGUI(eventManager, assetManager);
        gui.addFont(aFont, 18, gui.localeGlyphRanges);
        eNuklear = addEntityHUD();
        eNuklear.drawable = gui;
        eNuklear.visible = true;
        
        eventManager.showCursor(true);
    }
    
    override void onKeyDown(int key)
    {
        if (key == KEY_ESCAPE)
            application.exit();
        else if (key == KEY_RETURN)
            eNuklear.visible = !eNuklear.visible;
        else if (key == KEY_BACKSPACE)
            gui.inputKeyDown(NK_KEY_BACKSPACE);
        else if (key == KEY_DELETE)
            gui.inputKeyDown(NK_KEY_DEL);
        else if (key == KEY_C && eventManager.keyPressed[KEY_LCTRL])
            gui.inputKeyDown(NK_KEY_COPY);
        else if (key == KEY_V && eventManager.keyPressed[KEY_LCTRL])
            gui.inputKeyDown(NK_KEY_PASTE);
        else if (key == KEY_A && eventManager.keyPressed[KEY_LCTRL])
            gui.inputKeyDown(NK_KEY_TEXT_SELECT_ALL);
    }
    
    override void onKeyUp(int key)
    {
        if (eNuklear.visible)
        {
            if (key == KEY_BACKSPACE)
                gui.inputKeyUp(NK_KEY_BACKSPACE);
        }
    }
    
    override void onMouseButtonDown(int button)
    {
        bool unfocused = true;
        if (eNuklear.visible)
        {
            gui.inputButtonDown(button);
            unfocused = !gui.itemIsAnyActive();
        }
        
        freeview.active = unfocused;
    }
    
    override void onMouseButtonUp(int button)
    {
        bool unfocused = true;
        if (eNuklear.visible)
        {
            gui.inputButtonUp(button);
            unfocused = !gui.itemIsAnyActive();
        }
        
        freeview.active = unfocused;
    }

    override void onTextInput(dchar unicode)
    {
        if (gui && eNuklear.visible)
            gui.inputUnicode(unicode);
    }

    override void onMouseWheel(int x, int y)
    {
        if (gui && eNuklear.visible && !freeview.active)
            gui.inputScroll(x, y);
    }
    
    override void onUpdate(Time t)
    {
        if (eNuklear.visible)
            updateGUI(t);
        
        eSuzanne.material.baseColorFactor = diffuseColor;
        eSuzanne.material.roughnessFactor = roughness;
        eSuzanne.material.metallicFactor = metallic;
    }
    
    void updateGUI(Time t)
    {
        gui.update(t);
        
        if (gui.begin("Properties", NKRect(0, 40, 300, eventManager.windowHeight - 40), NK_WINDOW_TITLE))
        {
            updateRenderTab();
            updateMaterialTab();
        }
        gui.end();
        
        if (gui.begin("Menu", NKRect(0, 0, eventManager.windowWidth, 40), 0))
        {
            gui.menubarBegin();
            {
                gui.layoutRowStatic(30, 40, 5);

                if (gui.menuBeginLabel("File", NK_TEXT_LEFT, NKVec2(200, 200)))
                {
                    gui.layoutRowDynamic(25, 1);
                    if (gui.menuItemLabel("New", NK_TEXT_LEFT)) { }
                    if (gui.menuItemLabel("Open", NK_TEXT_LEFT)) { }
                    if (gui.menuItemLabel("Save", NK_TEXT_LEFT)) { }
                    if (gui.menuItemLabel("Exit", NK_TEXT_LEFT)) { application.exit(); }
                    gui.menuEnd();
                }

                if (gui.menuBeginLabel("Edit", NK_TEXT_LEFT, NKVec2(200, 200)))
                {
                    gui.layoutRowDynamic(25, 1);
                    if (gui.menuItemLabel("Copy", NK_TEXT_LEFT)) { }
                    if (gui.menuItemLabel("Paste", NK_TEXT_LEFT)) { }
                    gui.menuEnd();
                }

                if (gui.menuBeginLabel("Help", NK_TEXT_LEFT, NKVec2(200, 200)))
                {
                    gui.layoutRowDynamic(25, 1);
                    if (gui.menuItemLabel("About...", NK_TEXT_LEFT)) { }
                    gui.menuEnd();
                }
            }
            gui.menubarEnd();
        }
        gui.end();
    }
    
    void updateRenderTab()
    {
        if (gui.treePush(NK_TREE_NODE, "Render", NK_MAXIMIZED))
        {
            gui.layoutRowDynamic(25, 1);
            game.deferred.ssaoSamples = gui.property("AO samples:", 1, game.deferred.ssaoSamples, 25, 1, 1);
            game.deferred.ssaoRadius = gui.property("AO radius:", 0.05f, game.deferred.ssaoRadius, 1.0f, 0.01f, 0.005f);
            game.deferred.ssaoPower = gui.property("AO power:", 0.0f, game.deferred.ssaoPower, 10.0f, 0.01f, 0.01f);
            game.deferred.ssaoDenoise = gui.property("AO denoise:", 0.0f, game.deferred.ssaoDenoise, 1.0f, 0.01f, 0.01f);

            gui.layoutRowDynamic(25, 1);
            game.postProc.glowThreshold = gui.property("Glow threshold:", 0.0f, game.postProc.glowThreshold, 1.0f, 0.01f, 0.005f);
            game.postProc.glowIntensity = gui.property("Glow intensity:", 0.0f, game.postProc.glowIntensity, 1.0f, 0.01f, 0.005f);

            gui.layoutRowDynamic(25, 1);
            game.postProc.glowRadius = gui.property("Glow radius:", 1, game.postProc.glowRadius, 10, 1, 1);
            
            gui.layoutRowDynamic(25, 1);
            game.postProc.motionBlurFramerate = gui.property("Motion blur framerate:", 1, game.postProc.motionBlurFramerate, 30, 1, 1);
            game.postProc.motionBlurSamples = gui.property("Motion blur samples:", 1, game.postProc.motionBlurSamples, 24, 1, 1);

            gui.layoutRowDynamic(30, 2);
            gui.label("Tonemapper:", NK_TEXT_LEFT);
            game.postProc.tonemapper =
                cast(Tonemapper)gui.comboString(
                    "None\0Reinhard\0Uncharted\0ACES\0Filmic\0Reinhard2\0Unreal\0AgX Base\0Agx Punchy\0",
                    game.postProc.tonemapper, 9, 25, NKVec2(120, 200));

            gui.layoutRowDynamic(25, 1);
            game.postProc.exposure = gui.property("Exposure:", 0.0f, game.postProc.exposure, 2.0f, 0.01f, 0.005f);

            gui.treePop();
        }
    }
    
    void updateMaterialTab()
    {
        if (gui.treePush(NK_TREE_NODE, "Material", NK_MAXIMIZED))
        {
            gui.layoutRowDynamic(25, 2);
            gui.label("Diffuse color:", NK_TEXT_LEFT);
            if (gui.buttonColor(diffuseColor))
                diffuseColorPicker = !diffuseColorPicker;

            if (diffuseColorPicker)
            {
                NKRect s = NKRect(300, 100, 300, 350);
                if (gui.popupBegin(NK_POPUP_STATIC, "Color", NK_WINDOW_CLOSABLE, s))
                {
                    gui.layoutRowDynamic(180, 1);
                    diffuseColor = gui.colorPicker(diffuseColor, NK_RGB);
                    gui.layoutRowDynamic(25, 1);
                    diffuseColor.r = gui.property("#R:", 0.0f, diffuseColor.r, 1.0f, 0.01f, 0.005f);
                    diffuseColor.g = gui.property("#G:", 0.0f, diffuseColor.g, 1.0f, 0.01f, 0.005f);
                    diffuseColor.b = gui.property("#B:", 0.0f, diffuseColor.b, 1.0f, 0.01f, 0.005f);
                    gui.popupEnd();
                }
                else diffuseColorPicker = false;
            }

            gui.layoutRowDynamic(25, 1);
            roughness = gui.property("Roughness:", 0.0f, roughness, 1.0f, 0.01f, 0.005f);

            gui.layoutRowDynamic(25, 1);
            metallic = gui.property("Metallic:", 0.0f, metallic, 1.0f, 0.01f, 0.005f);
            
            gui.treePop();
        }
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
    MyGame game = New!MyGame(1280, 720, false, "Dagon tutorial 18. Nuklear GUI", args);
    game.run();
    Delete(game);
}
