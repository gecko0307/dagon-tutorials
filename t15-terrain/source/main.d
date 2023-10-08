module main;

import dagon;

class TestScene: Scene
{
    Game game;
    ImageAsset aHeightmap;
    TextureAsset aTexDesertAlbedo;
    TextureAsset aTexDesertNormal;
    TextureAsset aTexGrassAlbedo;
    TextureAsset aTexGrassNormal;
    TextureAsset aSplatmapGrass;

    this(Game game)
    {
        super(game);
        this.game = game;
    }

    override void beforeLoad()
    {
        aHeightmap = addImageAsset("../assets/terrain/heightmap.png");
        aTexDesertAlbedo = addTextureAsset("../assets/terrain/desert-albedo.png");
        aTexDesertNormal = addTextureAsset("../assets/terrain/desert-normal.png");
        aTexGrassAlbedo = addTextureAsset("../assets/terrain/grass-albedo.png");
        aTexGrassNormal = addTextureAsset("../assets/terrain/grass-normal.png");
        aSplatmapGrass = addTextureAsset("../assets/terrain/splatmap-grass.png");
    }

    override void afterLoad()
    {
        game.deferredRenderer.ssaoEnabled = true;
        game.deferredRenderer.ssaoPower = 6.0;
        game.postProcessingRenderer.tonemapper = Tonemapper.Filmic;
        game.postProcessingRenderer.fxaaEnabled = true;
        
        auto camera = addCamera();
        camera.fov = 50.0f;
        
        auto freeview = New!FreeviewComponent(eventManager, camera);
        freeview.zoom(-10);
        freeview.pitch(-20.0f);
        freeview.turn(10.0f);
        game.renderer.activeCamera = camera;

        auto sun = addLight(LightType.Sun);
        sun.shadowEnabled = true;
        sun.energy = 10.0f;
        sun.pitch(-45.0f);
        
        environment.sun = sun;
        environment.backgroundColor = Color4f(0.5f, 0.5f, 0.5f, 1.0f);
        environment.fogColor = Color4f(0.5f, 0.5f, 0.5f, 1.0f);
        environment.fogEnd = 1000.0f;
        environment.ambientColor = environment.backgroundColor;
        
        auto matSuzanne = addMaterial();
        matSuzanne.baseColorFactor = Color4f(1.0, 0.2, 0.2, 1.0);
        
        auto heightmap = New!ImageHeightmap(aHeightmap.image, 30.0f, assetManager);
        auto terrain = New!Terrain(512, 64, heightmap, assetManager);
        auto eTerrain = addEntity();
        eTerrain.dynamic = false;
        eTerrain.solid = true;
        eTerrain.drawable = terrain;
        eTerrain.position = Vector3f(-64, 0, -64);
        eTerrain.scaling = Vector3f(0.25f, 0.25f, 0.25f);
        
        auto terrainMaterial = environment.terrainMaterial;
        
        auto layer1 = terrainMaterial.addLayer();
        layer1.baseColorTexture = aTexDesertAlbedo.texture;
        layer1.normalTexture = aTexDesertNormal.texture;
        layer1.roughnessFactor = 0.2f;
        layer1.textureScale = Vector2f(50, 50);
        
        auto layer2 = terrainMaterial.addLayer();
        layer2.baseColorTexture = aTexGrassAlbedo.texture;
        layer2.normalTexture = aTexGrassNormal.texture;
        layer2.roughnessFactor = 0.9f;
        layer2.maskTexture = aSplatmapGrass.texture;
        layer2.textureScale = Vector2f(50, 50);
        
        eTerrain.material = terrainMaterial;
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
    MyGame game = New!MyGame(1280, 720, false, "Dagon tutorial 15. Terrain", args);
    game.run();
    Delete(game);
}
