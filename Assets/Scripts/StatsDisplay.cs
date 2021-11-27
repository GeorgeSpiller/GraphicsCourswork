using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.Profiling;
using System.Text;
/*
    Adapteed script from Unity Docs:
    https://docs.unity3d.com/Manual/ProfilerMemory.html
    https://docs.unity3d.com/ScriptReference/Unity.Profiling.ProfilerRecorder.html
*/
public class StatsDisplay : MonoBehaviour
{
    double frameCount = 0;
    double dt = 0.0;
    double fps = 0.0;
    double updateRate = 4.0;  // 4 updates per sec.
    
    string statsText;
    ProfilerRecorder totalReservedMemoryRecorder;
    ProfilerRecorder gcReservedMemoryRecorder;
    ProfilerRecorder systemUsedMemoryRecorder;

    private void calculateFPS() 
    {
        frameCount++;
        dt += Time.deltaTime;
        if (dt > 1.0/updateRate)
        {
            fps = frameCount / dt ;
            frameCount = 0;
            dt -= 1.0/updateRate;
        }
    }

    void OnEnable()
    {
        totalReservedMemoryRecorder = ProfilerRecorder.StartNew(ProfilerCategory.Memory, "Total Reserved Memory");
        gcReservedMemoryRecorder = ProfilerRecorder.StartNew(ProfilerCategory.Memory, "GC Reserved Memory");
        systemUsedMemoryRecorder = ProfilerRecorder.StartNew(ProfilerCategory.Memory, "System Used Memory");
    }

    void OnDisable()
    {
        totalReservedMemoryRecorder.Dispose();
        gcReservedMemoryRecorder.Dispose();
        systemUsedMemoryRecorder.Dispose();
    }

    void Update()
    {
        var sb = new StringBuilder(600);
        calculateFPS();

        if (totalReservedMemoryRecorder.Valid) 
        {
            sb.AppendLine($"GC Memory: {gcReservedMemoryRecorder.LastValue / (1024 * 1024)} MB");
        }
        if (systemUsedMemoryRecorder.Valid) 
        {
            sb.AppendLine($"System Memory: {systemUsedMemoryRecorder.LastValue / (1024 * 1024)} MB");
        }

        sb.AppendLine($"System FPS: {fps}");
        statsText = sb.ToString();
    }

    void OnGUI()
    {
        GUI.TextArea(new Rect(5, 5, 240, 65), statsText);
    }
}
