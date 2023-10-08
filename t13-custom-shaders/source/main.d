module main;

import dagon;
import scene;

class MyGame: Game
{
    this(uint windowWidth, uint windowHeight, bool fullscreen, string title, string[] args)
    {
        super(windowWidth, windowHeight, fullscreen, title, args);
        currentScene = New!MyScene(this);
    }
}

void main(string[] args)
{
    MyGame game = New!MyGame(1280, 720, false, "Dagon tutorial 13. Custom shaders", args);
    game.run();
    Delete(game);
}
