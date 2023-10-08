module planet;

import dagon;

class PlanetShader: Shader
{
    String vs, fs;
    
    Vector3f sunDirection = Vector3f(-1.0f, -1.0f, -1.0f).normalized;
    Color4f sunColor = Color4f(1.0f, 1.0f, 1.0f, 1.0f);

    this(Owner owner)
    {
        vs = Shader.load("shaders/Planet/Planet.vert.glsl");
        fs = Shader.load("shaders/Planet/Planet.frag.glsl");

        auto myProgram = New!ShaderProgram(vs, fs, this);
        super(myProgram, owner);
    }

    ~this()
    {
        vs.free();
        fs.free();
    }

    override void bindParameters(GraphicsState* state)
    {
        Material mat = state.material;
        
        // Matrices
        setParameter("modelViewMatrix", state.modelViewMatrix);
        setParameter("projectionMatrix", state.projectionMatrix);
        setParameter("normalMatrix", state.normalMatrix);
        setParameter("viewMatrix", state.viewMatrix);
        setParameter("invViewMatrix", state.invViewMatrix);
        setParameter("prevModelViewMatrix", state.prevModelViewMatrix);
        
        setParameter("textureScale", mat.textureScale);
        
        // Diffuse
        glActiveTexture(GL_TEXTURE0);
        setParameter("diffuseTexture", cast(int)0);
        setParameter("diffuseVector", mat.baseColorFactor);
        if (mat.baseColorTexture)
        {
            mat.baseColorTexture.bind();
            setParameterSubroutine("diffuse", ShaderType.Fragment, "diffuseColorTexture");
        }
        else
        {
            glBindTexture(GL_TEXTURE_2D, 0);
            setParameterSubroutine("diffuse", ShaderType.Fragment, "diffuseColorValue");
        }
        
        Vector3f sunDir = sunDirection;
        if (state.material.sun)
        {
            sunDir = state.material.sun.directionAbsolute;
            setParameter("sunColor", state.material.sun.color.rgb);
        }
        else if (state.environment.sun)
        {
            sunDir = state.environment.sun.directionAbsolute;
            setParameter("sunColor", state.environment.sun.color.rgb);
        }
        else
        {
            setParameter("sunColor", sunColor.rgb);
        }
        
        if (state.environment)
            setParameter("ambientColor", state.environment.ambientColor.rgb);
        else
            setParameter("ambientColor", Vector3f(0.0f, 0.0f, 0.0f));
        
        Vector4f lightDirHg = Vector4f(sunDir);
        lightDirHg.w = 0.0;
        Vector3f lightDir = (lightDirHg * state.viewMatrix).xyz;
        setParameter("sunDirection", lightDir);
        
        super.bindParameters(state);
    }

    override void unbindParameters(GraphicsState* state)
    {
        super.unbindParameters(state);
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
}
