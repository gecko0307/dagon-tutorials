module main;

import dagon;

class TestScene: Scene
{
    TextureAsset aTexEnvmap;
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
        aTexEnvmap = addTextureAsset("data/envmap.hdr");
        aOBJSuzanne = addOBJAsset("data/suzanne.obj");
        aTexStoneDiffuse = addTextureAsset("data/stone-diffuse.png");
        aTexStoneNormal = addTextureAsset("data/stone-normal.png");
        aTexStoneHeight = addTextureAsset("data/stone-height.png");
    }

    override void onAllocate()
    {
        super.onAllocate();
        
        view = New!Freeview(eventManager, assetManager);
        
        environment.setDayTime(0, 0, 0);
        environment.environmentMap = aTexEnvmap.texture;
        
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
        
        auto eSky = createSky();
    }
}

class MyApplication: SceneApplication
{
    this(string[] args)
    {
        super(1280, 720, false, "Dagon tutorial 4. Light sources", args);

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
