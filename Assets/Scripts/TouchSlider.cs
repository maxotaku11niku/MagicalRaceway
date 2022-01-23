using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem.EnhancedTouch;

public class TouchSlider : TouchControl
{
    public float value;
    public RectTransform sliderBoundingBox;
    public RectTransform touchDetectBoundingBox;
    public float minValue;
    public float maxValue;
    float leftEdgeReal;
    float rightEdgeReal;
    float length;
    float xDeviation;

    void Awake()
    {
        Vector3[] corners = new Vector3[4];
        controlRect = gameObject.GetComponent<RectTransform>();
        sliderBoundingBox.GetWorldCorners(corners);
        leftEdgeReal = corners[0].x;
        rightEdgeReal = corners[2].x;
        length = rightEdgeReal - leftEdgeReal;
    }

    public void ForceBoundsUpdate()
    {
        Vector3[] corners = new Vector3[4];
        sliderBoundingBox.GetWorldCorners(corners);
        leftEdgeReal = corners[0].x;
        rightEdgeReal = corners[2].x;
        length = rightEdgeReal - leftEdgeReal;
    }

    void Update()
    {
        if (UnityEngine.InputSystem.EnhancedTouch.Touch.activeTouches.Count <= 0)
        {
            xDeviation = 0f;
            value = (maxValue + minValue) * 0.5f;
        }
        else
        {
            value = (maxValue + minValue) * 0.5f;
            foreach (UnityEngine.InputSystem.EnhancedTouch.Touch t in UnityEngine.InputSystem.EnhancedTouch.Touch.activeTouches)
            {
                if (RectTransformUtility.RectangleContainsScreenPoint(touchDetectBoundingBox, t.screenPosition))
                {
                    value = Mathf.Lerp(minValue, maxValue, ((t.screenPosition.x - leftEdgeReal) / length));
                    break;
                }
            }
        }
        controlRect.anchoredPosition = new Vector2(Mathf.Lerp(sliderBoundingBox.rect.width*-0.5f, sliderBoundingBox.rect.width*0.5f, (value - minValue)/(maxValue - minValue)), 0f);
    }
}
