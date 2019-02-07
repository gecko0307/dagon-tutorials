module main;

import dagon;

class TestScene: Scene
{
    OBJAsset aOBJSuzanne;
    TextureAsset aTexStoneDiffuse;

    this(SceneManager smngr)
    {
        super(smngr);
    }

    override void onAssetsRequest()
    {    
        aOBJSuzanne = addOBJAsset("data/suzanne.obj");
        aTexStoneDiffuse = addTextureAsset("data/stone-diffuse.png");
    }

    override void onAllocate()
    {
        super.onAllocate();
        
        view = New!Freeview(eventManager, assetManager);
        
        mainSun = createLightSun(Quaternionf.identity, environment.sunColor, environment.sunEnergy);
        mainSun.shadow = true;
        environment.setDayTime(9, 00, 00);
        
        auto matSuzanne = createMaterial();
        matSuzanne.diffuse = Color4f(1.0, 0.2, 0.2, 1.0);
        
        auto matGround = createMaterial();
        matGround.diffuse = aTexStoneDiffuse.texture;

        auto eSuzanne = createEntity3D();
        eSuzanne.drawable = aOBJSuzanne.mesh;
        eSuzanne.material = matSuzanne;
        eSuzanne.position = Vector3f(0, 1, 0);
        
        auto ePlane = createEntity3D();
        ePlane.drawable = New!ShapePlane(10, 10, 1, assetManager);
        ePlane.material = matGround;
    }
}

class MyApplication: SceneApplication
{
    this(string[] args)
    {
        super("Dagon tutorial 2. Textures", args);

        TestScene test = New!TestScene(sceneManager);
        sceneManager.addScene(test, "TestScene");
        sceneManager.goToScene("TestScene");
    }
}

void main(string[] args)
{
    MyApplication app = New!MyApplication(args);
    app.run();
    Delete(app);
}
