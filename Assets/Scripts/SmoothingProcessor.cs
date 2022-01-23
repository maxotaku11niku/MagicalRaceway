using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.InputSystem;

#if UNITY_EDITOR
[InitializeOnLoad]
#endif
public class SmoothingProcessor : InputProcessor<float>
{
    [Tooltip("How fast the control will settle.")]
    public float decayRate;
    float outValue;

#if UNITY_EDITOR
    static SmoothingProcessor()
    {
        Initialize();
    }
#endif
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSplashScreen)]
    static void Initialize()
    {
        InputSystem.RegisterProcessor<SmoothingProcessor>();
    }

    public override float Process(float value, InputControl control)
    {
        outValue += (value - outValue) * decayRate * Time.deltaTime;
        if (outValue < 0.05f && outValue > -0.05f && value == 0f) outValue = 0f;
        return outValue;
    }
}
