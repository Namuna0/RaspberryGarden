using UnityEditor;

public class BuildScript
{
    public static void BuildiOS()
    {
        BuildPipeline.BuildPlayer(
            new[] { "Assets/Scenes/MainScene.unity" },
            "build/iOS",
            BuildTarget.iOS,
            BuildOptions.None
        );
    }
}