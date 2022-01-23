using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem.EnhancedTouch;

public class TouchButton : TouchControl
{
    int state;
    public bool isDown { get{ return state == 1; } }
    public bool isHeld { get{ return state == 2; } }
    public bool isReleased { get{ return state == 3; } }

    void Awake()
    {
        controlRect = gameObject.GetComponent<RectTransform>();
    }

    void OnDisable()
    {
        isTouching = false;
        state = 0;
    }

    void Update()
    {
        if(UnityEngine.InputSystem.EnhancedTouch.Touch.activeTouches.Count <= 0)
        {
            isTouching = false;
        }
        else
        {
            isTouching = false;
            foreach(UnityEngine.InputSystem.EnhancedTouch.Touch t in UnityEngine.InputSystem.EnhancedTouch.Touch.activeTouches)
            {
                if(RectTransformUtility.RectangleContainsScreenPoint(controlRect, t.screenPosition))
                {
                    isTouching = true;
                    break;
                }
            }
        }
        if (!isTouching && !lastFrameWasTouching) state = 0;
        else if (isTouching && !lastFrameWasTouching) state = 1;
        else if (isTouching && lastFrameWasTouching) state = 2;
        else if (!isTouching && lastFrameWasTouching) state = 3;
        lastFrameWasTouching = isTouching;
    }
}
