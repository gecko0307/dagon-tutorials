module scene;

import dagon;
import starfield;
import planet;
import rings;

class MyScene: Scene
{
    Game game;
    
    GLTFAsset planet;
    TextureAsset aRings;

    this(Game game)
    {
        super(game);
        this.game = game;
    }

    override void beforeLoad()
    {
        planet = addGLTFAsset("../assets/planet/planet.gltf");
        aRings = addTextureAsset("../assets/planet/rings.png");
    }
    
    override void onLoad(Time t, float progress)
    {
    }

    override void afterLoad()
    {
        auto camera = addCamera();
        camera.fov = 60.0f;
        auto freeview = New!FreeviewComponent(eventManager, camera);
        freeview.setZoom(5);
        freeview.setRotation(30.0f, -45.0f, 0.0f);
        freeview.translationStiffness = 0.25f;
        freeview.rotationStiffness = 0.25f;
        freeview.zoomStiffness = 0.25f;
        game.renderer.activeCamera = camera;
        
        Color4f envColor = Color4f(0.15f, 0.075f, 0.0f, 1.0f);
        environment.backgroundColor = envColor;
        environment.fogEnd = 1000.0f;
        environment.fogColor = envColor;
        environment.ambientColor = envColor;
        environment.ambientEnergy = 5.0f;

        auto sun = addLight(LightType.Sun);
        sun.color = Color4f(1.0f, 0.9f, 0.8f, 1.0f);
        sun.turn(-30.0f);
        sun.pitch(-20.0f); //-45
        sun.shadowEnabled = true;
        sun.energy = 5.0f;
        sun.scatteringEnabled = true;
        sun.scattering = 0.3f;
        sun.mediumDensity = 0.075f;
        sun.scatteringUseShadow = true;
        sun.scatteringMaxRandomStepOffset = 0.055f;
        environment.sun = sun;
        
        auto eSky = addEntity();
        auto psync = New!PositionSync(eventManager, eSky, camera);
        eSky.drawable = New!ShapeBox(Vector3f(1.0f, 1.0f, 1.0f), assetManager);
        eSky.scaling = Vector3f(100.0f, 100.0f, 100.0f);
        eSky.layer = EntityLayer.Background;
        eSky.gbufferMask = 0.0f;
        eSky.material = New!Material(assetManager);
        eSky.material.shader = New!SkyShader(assetManager);
        eSky.material.depthWrite = false;
        eSky.material.useCulling = false;
        auto starfieldShader = New!StarfieldShader(assetManager);
        eSky.material.shader = starfieldShader;
        starfieldShader.spaceColor = envColor;
        starfieldShader.starsColor = Color4f(1.0f, 0.8f, 0.5f, 1.0f);
        
        auto ePlanet = addEntity();
        auto psync2 = New!PositionSync(eventManager, ePlanet, camera);
        ePlanet.drawable = planet.meshes[0];
        ePlanet.position = Vector3f(-50.0f, -3.0f, -70.0f);
        ePlanet.scaling = Vector3f(30.0f, 30.0f, 30.0f);
        ePlanet.pitch(10.0f);
        ePlanet.layer = EntityLayer.Background;
        ePlanet.material = New!Material(assetManager);
        auto planetShader = New!PlanetShader(assetManager);
        ePlanet.material.shader = planetShader;
        
        auto eRings = addEntity();
        auto psync3 = New!PositionSync(eventManager, eRings, camera);
        eRings.drawable = New!ShapePlane(5.0f, 5.0f, 1, assetManager);
        eRings.transparent = true;
        eRings.scaling = Vector3f(30.0f, 30.0f, 30.0f);
        eRings.position = ePlanet.position;
        eRings.pitch(10.0f);
        eRings.layer = EntityLayer.Background;
        eRings.material = New!Material(assetManager);
        eRings.material.shader = planetShader;
        eRings.material.blendMode = Transparent;
        eRings.material.baseColorTexture = aRings.texture;
        auto ringsShader = New!RingsShader(assetManager);
        ringsShader.planetPosition = ePlanet.position;
        ringsShader.planetRadius = 30.0f;
        eRings.material.shader = ringsShader;
        
        game.deferredRenderer.ssaoEnabled = true;
        game.deferredRenderer.ssaoPower = 8.0f;
        game.deferredRenderer.ssaoRadius = 0.5;
        game.deferredRenderer.ssaoDenoise = 1.0f;
        game.deferredRenderer.occlusionBufferDetail = 1.0f;
        game.postProcessingRenderer.fxaaEnabled = true;
        game.postProcessingRenderer.motionBlurEnabled = true;
        game.postProcessingRenderer.glowEnabled = true;
        game.postProcessingRenderer.glowThreshold = 0.4f;
        game.postProcessingRenderer.glowIntensity = 0.3f;
        game.postProcessingRenderer.glowRadius = 7;
        game.postProcessingRenderer.tonemapper = Tonemapper.Filmic;
    }
}
