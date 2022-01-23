using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TitleAnimation : MonoBehaviour
{
    public GameObject[] letters;
    RectTransform[] letterPos;
    Image[] letterImg;
    float t;

    public float wavelength;
    public float period;
    public float amplitude;
    float k; //Spatial frequency
    float w; //Temporal frequency

    public float colourWavelength;
    public float colourPeriod;
    float ck; //Spatial frequency
    float cf; //Temporal frequency

    void Awake()
    {
        letterPos = new RectTransform[letters.Length];
        letterImg = new Image[letters.Length];
        for(int i = 0; i < letters.Length; i++)
        {
            letterPos[i] = letters[i].GetComponent<RectTransform>();
            letterImg[i] = letters[i].GetComponent<Image>();
        }
        k = (2*Mathf.PI)/wavelength;
        w = (2*Mathf.PI)/period;
        ck = 1f/colourWavelength;
        cf = 1f/colourPeriod;
        t = 0f;
    }

    void OnEnable()
    {
        t = 0f;
    }

    Color Rainbow(float c) //raaaaaaaaaaaaaaaaaainboooooooooooooooooows
    {
        return Color.HSVToRGB(c, 1f, 1f);
    }

    void Update()
    {
        for(int i = 0; i < letters.Length; i++)
        {
            letterPos[i].anchoredPosition = new Vector2(i*16f, amplitude*Mathf.Sin(k*i*16f - w*t)); //Just your normal everyday wave
            letterImg[i].color = Rainbow((cf*t - ck*i + 10f)%1f);
        }
        t += Time.deltaTime;
    }
}
