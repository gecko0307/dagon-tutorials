module main;

import dagon;

class TestScene: Scene
{
    OBJAsset aOBJSuzanne;
    TextureAsset aTexStoneDiffuse;
    TextureAsset aTexStoneNormal;
    TextureAsset aTexStoneHeight;

    this(SceneManager smngr)
    {
        super(smngr);
    }

    override void onAssetsRequest()
    {    
        aOBJSuzanne = addOBJAsset("data/suzanne.obj");
        aTexStoneDiffuse = addTextureAsset("data/stone-diffuse.png");
        aTexStoneNormal = addTextureAsset("data/stone-normal.png");
        aTexStoneHeight = addTextureAsset("data/stone-height.png");
    }

    override void onAllocate()
    {
        super.onAllocate();
        
        view = New!Freeview(eventManager, assetManager);
        
        environment.setDayTime(00, 00, 00);
        
        auto matSuzanne = createMaterial();
        matSuzanne.diffuse = Color4f(1.0, 0.2, 0.2, 1.0);
        
        auto matGround = createMaterial();
        matGround.diffuse = aTexStoneDiffuse.texture;
        matGround.normal = aTexStoneNormal.texture;
        matGround.height = aTexStoneHeight.texture;

        auto eSuzanne = createEntity3D();
        eSuzanne.drawable = aOBJSuzanne.mesh;
        eSuzanne.material = matSuzanne;
        eSuzanne.position = Vector3f(0, 1, 0);
        
        auto ePlane = createEntity3D();
        ePlane.drawable = New!ShapePlane(10, 10, 1, assetManager);
        ePlane.material = matGround;
        
        auto light1 = createLightSphere(Vector3f(-2, 1, 0), Color4f(1.0f, 1.0f, 0.0f), 10.0f, 5.0f, 0.1f);
        auto light2 = createLightSphere(Vector3f(2, 1, 0), Color4f(0.0f, 1.0f, 1.0f), 10.0f, 5.0f, 0.1f);
    }
}

class MyApplication: SceneApplication
{
    this(string[] args)
    {
        super("Dagon tutorial 4. Light sources", args);

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
