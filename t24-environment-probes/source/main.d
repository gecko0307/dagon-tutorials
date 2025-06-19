module main;

import dagon;

class TestScene: Scene
{
    MyGame game;
    GLTFAsset aHelmet;
    GLTFAsset aRoom;
    TextureAsset aEnvmap;
    TextureAsset aEnvmapRoom;
    TextureAsset aBRDF;
    
    Entity helmet;
    
    this(MyGame game)
    {
        super(game);
        this.game = game;
    }

    override void beforeLoad()
    {
        aHelmet = addGLTFAsset("../assets/helmet-gltf/DamagedHelmet.gltf");
        aRoom = addGLTFAsset("../assets/room/room.gltf");
        aEnvmap = addTextureAsset("../assets/envmap.dds");
        aEnvmapRoom = addTextureAsset("../assets/room/room.hdr");
        aBRDF = addTextureAsset("../assets/brdf.dds");
    }

    override void afterLoad()
    {
        game.deferredRenderer.ssaoEnabled = true;
        game.deferredRenderer.ssaoSamples = 20;
        game.deferredRenderer.ssaoPower = 3.0f;
        game.deferredRenderer.ssaoRadius = 0.25;
        game.deferredRenderer.ssaoDenoise = 0.5f;
        game.deferredRenderer.occlusionBufferDetail = 1.0f;
        game.postProcessingRenderer.fxaaEnabled = true;
        game.postProcessingRenderer.fStop = 1.0;
        game.postProcessingRenderer.glowEnabled = true;
        game.postProcessingRenderer.glowThreshold = 1.0f;
        game.postProcessingRenderer.glowIntensity = 0.2f;
        game.postProcessingRenderer.glowRadius = 7;
        game.postProcessingRenderer.tonemapper = Tonemapper.Filmic;
        game.postProcessingRenderer.exposure = 1.0f;
        
        environment.ambientMap = aEnvmap.texture;
        environment.ambientBRDF = aBRDF.texture;
        environment.ambientEnergy = 1.0f;
        aBRDF.texture.useMipmapFiltering = false;
        aBRDF.texture.enableRepeat(false);
        
        auto camera = addCamera();
        auto freeview = New!FreeviewComponent(eventManager, camera);
        freeview.zoom(10);
        freeview.setRotation(30.0f, 180.0f, 0.0f);
        freeview.translationStiffness = 0.2f;
        freeview.rotationStiffness = 0.2f;
        freeview.zoomStiffness = 0.2f;
        game.renderer.activeCamera = camera;

        auto sun = addLight(LightType.Sun);
        sun.color = Color4f(1.0f, 0.72781f, 0.491441f, 1.0f);
        sun.shadowEnabled = true;
        sun.energy = 5.0f;
        sun.turn(200.0f);
        sun.pitch(-40.0f);
        environment.sun = sun;
        
        helmet = aHelmet.rootEntity;
        helmet.position.y = 1.0f;
        helmet.turn(-180);
        useEntity(helmet);
        foreach(node; aHelmet.nodes)
            useEntity(node.entity);
        
        auto eRoomProbe = addEntity();
        float wallWidth = 0.4f;
        Vector3f roomExtents = Vector3f(4, 2, 3) + wallWidth;
        eRoomProbe.drawable = New!ShapeBox(roomExtents, assetManager);
        eRoomProbe.position = Vector3f(0, 2, 0);
        eRoomProbe.probe = true;
        eRoomProbe.probeExtents = roomExtents;
        eRoomProbe.probeFalloffMargin = wallWidth;
        eRoomProbe.probeUseBoxProjection = true;
        auto probeMaterial = addMaterial();
        probeMaterial.blendMode = Transparent;
        probeMaterial.emissionTexture = aEnvmapRoom.texture;
        probeMaterial.emissionFactor = Color4f(1.0f, 1.0f, 1.0f, 1.0f);
        probeMaterial.emissionEnergy = 1.0f;
        probeMaterial.depthWrite = false;
        probeMaterial.outputColor = true;
        probeMaterial.outputNormal = false;
        probeMaterial.outputPBR = false;
        eRoomProbe.material = probeMaterial;
        
        aRoom.markTransparentEntities();
        useEntity(aRoom.rootEntity);
        foreach(node; aRoom.nodes)
        {
            useEntity(node.entity);
        }
        
        auto ePlane = addEntity();
        ePlane.position = Vector3f(0, -0.1f, 0);
        ePlane.drawable = New!ShapePlane(20, 20, 1, assetManager);
        ePlane.material = addMaterial();
        ePlane.material.roughnessFactor = 0.5f;
        
        auto eSky = addEntity();
        eSky.layer = EntityLayer.Background;
        auto psync = New!PositionSync(eventManager, eSky, camera);
        eSky.drawable = New!ShapeBox(Vector3f(1.0f, 1.0f, 1.0f), assetManager);
        eSky.scaling = Vector3f(100.0f, 100.0f, 100.0f);
        eSky.material = addMaterial();
        eSky.material.depthWrite = false;
        eSky.material.useCulling = false;
        eSky.material.baseColorTexture = aEnvmap.texture;
        eSky.gbufferMask = 0.0f;
    }
    
    override void onUpdate(Time t)
    {
        if (eventManager.keyPressed[KEY_RIGHT])
            helmet.position.x += 1.0f * t.delta;
        else if (eventManager.keyPressed[KEY_LEFT])
            helmet.position.x -= 1.0f * t.delta;
        else if (eventManager.keyPressed[KEY_DOWN])
            helmet.position.z += 1.0f * t.delta;
        else if (eventManager.keyPressed[KEY_UP])
            helmet.position.z -= 1.0f * t.delta;
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
    MyGame game = New!MyGame(1280, 720, false, "Dagon tutorial 24. Environment Probes", args);
    game.run();
    Delete(game);
}
