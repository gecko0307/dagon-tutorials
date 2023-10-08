module starfield;

import dagon;

class StarfieldShader: Shader
{
    String vs, fs;
    Color4f spaceColor = Color4f(0.0f, 0.0f, 0.0f, 1.0f);
    Color4f starsColor = Color4f(1.0f, 1.0f, 1.0f, 1.0f);
    float starsThreshold = 0.995f;
    float starsBrightness = 8.0f;
    
    Vector3f sunDirection = Vector3f(-1.0f, -1.0f, -1.0f).normalized;
    Color4f sunColor = Color4f(1.0f, 1.0f, 1.0f, 1.0f);

    this(Owner owner)
    {
        vs = Shader.load("shaders/Starfield/Starfield.vert.glsl");
        fs = Shader.load("shaders/Starfield/Starfield.frag.glsl");

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
        // Matrices
        setParameter("modelViewMatrix", state.modelViewMatrix);
        setParameter("projectionMatrix", state.projectionMatrix);
        setParameter("normalMatrix", state.normalMatrix);
        setParameter("viewMatrix", state.viewMatrix);
        setParameter("invViewMatrix", state.invViewMatrix);
        setParameter("prevModelViewMatrix", state.prevModelViewMatrix);
        
        setParameter("spaceColor", spaceColor.rgb);
        setParameter("starsColor", starsColor.rgb);
        setParameter("starsThreshold", starsThreshold);
        setParameter("starsBrightness", starsBrightness);
        
        if (state.material.sun)
        {
            setParameter("sunDirection", state.material.sun.directionAbsolute);
            setParameter("sunColor", state.material.sun.color.rgb);
        }
        else if (state.environment.sun)
        {
            setParameter("sunDirection", state.environment.sun.directionAbsolute);
            setParameter("sunColor", state.environment.sun.color.rgb);
        }
        else
        {
            setParameter("sunDirection", -sunDirection);
            setParameter("sunColor", sunColor.rgb);
        }
        
        super.bindParameters(state);
    }

    override void unbindParameters(GraphicsState* state)
    {
        super.unbindParameters(state);
    }
}
