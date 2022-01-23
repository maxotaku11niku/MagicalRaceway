using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem.EnhancedTouch;

public class TouchControl : MonoBehaviour
{
    protected RectTransform controlRect;
    public bool isTouching;
    protected bool lastFrameWasTouching;

    void Awake()
    {
        controlRect = gameObject.GetComponent<RectTransform>();
    }

    void OnDisable()
    {
        isTouching = false;
    }
}
