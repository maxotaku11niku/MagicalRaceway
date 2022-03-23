using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SplineTest
{
    public class TexturedStripManager : MonoBehaviour
    {
        Mesh stripMesh;
        public MeshRenderer meshRenderer;
        public MeshFilter meshFilter;
        public SplineRenderer spline;
        public Texture2D tex;
        public TexturedStrip.SpawnSide anchorSide;
        public Vector2 size;
        public float baseDistance;
        public FloatWithDistance[] xoffsList;

        public Vector3[] vertexArray;
        public Vector2[] uvArray;
        public int[] triangleArray; //Never modifed after initialisation

        void Awake()
        {
            meshRenderer = GetComponent<MeshRenderer>();
            meshFilter = GetComponent<MeshFilter>();
        }

        public void InitStrip()
        {
            stripMesh = new Mesh();
            meshFilter.mesh = stripMesh;
            vertexArray = new Vector3[spline.baseSplineHeight*2 + 2];
            uvArray = new Vector2[spline.baseSplineHeight*2 + 2];
            triangleArray = new int[spline.baseSplineHeight*6];
            for(int i = 0; i < spline.baseSplineHeight + 1; i++)
            {
                vertexArray[i*2] = new Vector3(0f, 0f, 0f);
                vertexArray[i*2 + 1] = new Vector3(0f, 0f, 0f);
                uvArray[i*2] = new Vector2(0f, 0f);
                uvArray[i*2 + 1] = new Vector2(0f, 0f);
            }
            for(int i = 0; i < spline.baseSplineHeight; i++)
            {
                triangleArray[i*6] = i*2 + 1;
                triangleArray[i*6 + 1] = i*2;
                triangleArray[i*6 + 2] = i*2 + 2;
                triangleArray[i*6 + 3] = i*2 + 2;
                triangleArray[i*6 + 4] = i*2 + 3;
                triangleArray[i*6 + 5] = i*2 + 1;
            }
            stripMesh.vertices = vertexArray;
            stripMesh.uv = uvArray;
            stripMesh.triangles = triangleArray;
        }

        public void ReassignTexture()
        {
            Material mat = meshRenderer.material;
            mat.SetTexture("_MainTex", tex);
            meshRenderer.material = mat;
        }

        public void PositionStrip(float distance, float xoff)
        {
            float d = 0f;
            float x = 0f;
            float sideMul = (anchorSide == TexturedStrip.SpawnSide.RIGHT)?1f:-1f;
            int sideSwap = (anchorSide == TexturedStrip.SpawnSide.RIGHT)?0:1;
            bool outOfRange = true;
            Vector2 vec;
            for(int i = 0; i < spline.baseSplineHeight + 1; i++)
            {
                
                d = Mathf.Clamp(distance + spline.GetDistanceOffset(i), baseDistance, baseDistance + size.y) - baseDistance;
                if(d <= 0f)
                {
                    x = xoffsList[0].val;
                    outOfRange = true;
                    
                }
                else if(d >= xoffsList[xoffsList.Length-1].distance)
                {
                    x = xoffsList[xoffsList.Length-1].val;
                    outOfRange = false;
                }
                else
                {
                    outOfRange = false;
                    for(int j = 0; j < (xoffsList.Length-1); j++)
                    {
                        if(d >= xoffsList[j].distance && d < xoffsList[j+1].distance)
                        {
                            x = Mathf.Lerp(xoffsList[j].val, xoffsList[j+1].val, (d-xoffsList[j].distance)/(xoffsList[j+1].distance-xoffsList[j].distance));
                            break;
                        }
                    }
                }
                if(d >= size.y) outOfRange = true;
                d += baseDistance;
                x = spline.GetRealXOffTex(x, d, anchorSide);
                vec = spline.GetStripVector(d, x, i);
                if(outOfRange) vertexArray[i*2 + sideSwap] = new Vector3(vec.x, vec.y, 200f);
                else vertexArray[i*2 + sideSwap] = new Vector3(vec.x, vec.y, i);
                uvArray[i*2 + sideSwap] = new Vector2(0f,(d-baseDistance)/tex.height);
                vec = spline.GetStripVector(d, x + sideMul*size.x, i);
                if(outOfRange) vertexArray[i*2 + 1 - sideSwap] = new Vector3(vec.x, vec.y, 200f);
                else vertexArray[i*2 + 1 - sideSwap] = new Vector3(vec.x, vec.y, i);
                uvArray[i*2 + 1 - sideSwap] = new Vector2(size.x/tex.width,(d-baseDistance)/tex.height);
            }
            stripMesh.vertices = vertexArray;
            stripMesh.uv = uvArray;
        }
    }
}
