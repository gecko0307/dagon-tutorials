module main;

import dagon;

class TestScene: Scene
{
    Game game;
    OBJAsset aOBJSuzanne;
    TextureAsset aTexStoneDiffuse;
    TextureAsset aTexStoneNormal;
    TextureAsset aTexStoneHeight;
    ShapeSphere lightSphere;

    this(Game game)
    {
        super(game);
        this.game = game;
    }

    override void beforeLoad()
    {    
        aOBJSuzanne = addOBJAsset("../assets/suzanne.obj");
        aTexStoneDiffuse = addTextureAsset("../assets/stone-diffuse.png");
        aTexStoneNormal = addTextureAsset("../assets/stone-normal.png");
        aTexStoneHeight = addTextureAsset("../assets/stone-height.png");
    }

    override void afterLoad()
    {
        environment.ambientColor = Color4f(0.2, 0.2, 0.2, 1);
        game.deferredRenderer.ssaoEnabled = true;
        game.deferredRenderer.ssaoPower = 6.0;
        game.postProcessingRenderer.glowEnabled = true;
        game.postProcessingRenderer.glowThreshold = 0.2f;
        game.postProcessingRenderer.glowIntensity = 0.05f;
        game.postProcessingRenderer.glowRadius = 10;
        game.postProcessingRenderer.fxaaEnabled = true;
        
        auto camera = addCamera();
        auto freeview = New!FreeviewComponent(eventManager, camera);
        freeview.zoom(5);
        freeview.pitch(-30.0f);
        freeview.turn(10.0f);
        game.renderer.activeCamera = camera;
        
        auto matSuzanne = addMaterial();
        matSuzanne.diffuse = Color4f(1.0, 1.0, 1.0, 1.0);
        
        auto matGround = addMaterial();
        matGround.diffuse = aTexStoneDiffuse.texture;
        matGround.normal = aTexStoneNormal.texture;
        matGround.height = aTexStoneHeight.texture;
        matGround.parallax = ParallaxSimple;
        matGround.roughness = 0.2f;
        matGround.textureScale = Vector2f(2, 2);

        auto eSuzanne = addEntity();
        eSuzanne.drawable = aOBJSuzanne.mesh;
        eSuzanne.material = matSuzanne;
        eSuzanne.position = Vector3f(0, 1, 0);
        
        auto ePlane = addEntity();
        ePlane.drawable = New!ShapePlane(10, 10, 1, assetManager);
        ePlane.material = matGround;
        
        lightSphere = New!ShapeSphere(1.0f, 24, 16, false, assetManager);
        
        addLight(LightType.AreaSphere, Vector3f(-3, 1, 0), Color4f(1.0f, 0.5f, 0.0f), 10.0f, 0.1f, 5.0f);
        addLight(LightType.AreaSphere, Vector3f(3, 1, 0),  Color4f(0.0f, 0.5f, 1.0f), 10.0f, 0.2f, 5.0f);
        addLight(LightType.AreaSphere, Vector3f(0, 1, 3),  Color4f(0.0f, 1.0f, 0.0f), 10.0f, 0.3f, 5.0f);
        addLight(LightType.AreaSphere, Vector3f(0, 1, -3), Color4f(1.0f, 0.0f, 0.0f), 10.0f, 0.4f, 5.0f);
    }
    
    Light addLight(LightType type, Vector3f pos, Color4f color, float energy, float areaRadius, float volumeRadius)
    {
        auto light = super.addLight(type);
        light.castShadow = false;
        light.position = pos;
        light.color = color;
        light.energy = energy;
        light.radius = areaRadius;
        light.volumeRadius = volumeRadius;

        auto lightGeom = addEntity(light);
        lightGeom.drawable = lightSphere;
        lightGeom.scaling = Vector3f(areaRadius, areaRadius, areaRadius);
        lightGeom.material = New!Material(assetManager);
        lightGeom.material.diffuse = color;
        lightGeom.material.emission = color;
        lightGeom.material.energy = energy;

        return light;
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
    MyGame game = New!MyGame(1280, 720, false, "Dagon tutorial 4. Light sources", args);
    game.run();
    Delete(game);
}
