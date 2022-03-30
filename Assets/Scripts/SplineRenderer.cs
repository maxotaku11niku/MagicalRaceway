using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SplineTest
{
    public class SplineRenderer : MonoBehaviour
    {
        Mesh splineMesh; //Mesh for the spline
        MeshFilter meshFilter;
        MeshRenderer meshRenderer; //Needed to actually render the spline, clearly
        Vector3[] vertexArray;
        Vector2[] uvArray;
        int[] triangleArray; //Never modifed after initialisation
        int splineTexWidth; //Width of the texture on the spline in pixels
        int splineTexHeight; //Height of the texture on the spline in pixels
        float splineTexInvWidth; //Inverses cached for speed
        float splineTexInvHeight;
        public int baseSplineHeight; //Height of the spline in pixels on the screen
        public int baseSplineWidth; //Width of the spline in pixels on the screen
        float invSplineHeight; //Inverses cached for speed
        float invSplineWidth;
        public float bottomScale; //Scale of the spline at the bottom
        public float topScale; //Ditto at the top
        public float xOffset; //Left-right position on the spline
        public float yOffset; //Distance along the spline
        float turnStr; //How sharp the corner is, positive values go to the right.
        float splitAmt; //Split amount of the two sides of the road, positive values mean a spread out
        float pitchStr; //How much the spline pitches, with positive values going downwards.

        public float[] turnStrList; //Interpolation lists for the above values
        public float[] turnStrPoints;
        public float[] splitAmtList;
        public float[] splitAmtPoints;
        public float[] pitchStrList;
        public float[] pitchStrPoints;
        
        float[] vcoordList; //No-offset distance mapping
        float[] dyList; //Delta-vcoord cache
        float[] ubendList; //Horizontal bend cache
        float[] ubendAngleList;
        float[] vbendList; //Vertical bend cache
        float[] vbendAngleList;

        private Vector2[] CalculateUV(int row) //Calculate UV coordinates for the spline texture
        {
            float scale = Mathf.Lerp(bottomScale, topScale, ((float)row)*invSplineHeight);
            float invScale = 1/scale; //Multiplication is faster than division, so cache the inverse of the scale
            float vcoordNoOffset = vcoordList[row]; //These two lines are for lookahead interpolation, so that the spline looks right ahead of where you are
            float adjYOffs = yOffset + vcoordNoOffset;
            for(int i = 1; i < turnStrPoints.Length; i++) //Interpolate turn strength
            {
                if(adjYOffs >= turnStrPoints[i-1] && adjYOffs < turnStrPoints[i])
                {
                    turnStr = Mathf.Lerp(turnStrList[i-1], turnStrList[i], (adjYOffs-turnStrPoints[i-1])/(turnStrPoints[i]-turnStrPoints[i-1]));
                }
            }
            for(int i = 1; i < splitAmtPoints.Length; i++) //Interpolate split amount
            {
                if(adjYOffs >= splitAmtPoints[i-1] && adjYOffs < splitAmtPoints[i])
                {
                    splitAmt = Mathf.Lerp(splitAmtList[i-1], splitAmtList[i], (adjYOffs-splitAmtPoints[i-1])/(splitAmtPoints[i]-splitAmtPoints[i-1]));
                }
            }
            for(int i = 1; i < pitchStrPoints.Length; i++) //Interpolate pitch strength
            {
                if(adjYOffs >= pitchStrPoints[i-1] && adjYOffs < pitchStrPoints[i])
                {
                    pitchStr = Mathf.Lerp(pitchStrList[i-1], pitchStrList[i], (adjYOffs-pitchStrPoints[i-1])/(pitchStrPoints[i]-pitchStrPoints[i-1]));
                }
            }
            float ubend;
            float vbend;
            float uAngleCos = Mathf.Cos(ubendAngleList[row]); //Cache cosines
            float vAngleCos = Mathf.Cos(vbendAngleList[row]);
            if (uAngleCos <= 0f) //Escapes for problematic angles
            {
                ubend = turnStr >= 0f ? 10000f : -10000f;
                if (row < baseSplineHeight)
                {
                    ubendAngleList[row + 1] = ubendAngleList[row];
                }
            }
            else
            {
                float dyModu = dyList[row] / uAngleCos; //Transform distance
                float curvdyModu = turnStr * turnStr * dyModu * dyModu; //Cache multiplications
                float sqrtdyModu = Mathf.Sqrt(1 - curvdyModu);
                float ubendMod = (turnStr != 0) ? (1 / turnStr) * (sqrtdyModu - 1f) : 0f; //Calculate delta-x or z
                float sqdAngleu = (1 + curvdyModu - sqrtdyModu) * (curvdyModu >= 0f ? 1 : -1); //Calculate delta-angle
                ubend = (row != 0) ? ubendList[row - 1] + (dyList[row] * Mathf.Tan(ubendAngleList[row])) + (ubendMod * uAngleCos) : 0f;
                if (row < baseSplineHeight)
                {
                    ubendAngleList[row + 1] = ubendAngleList[row] + Mathf.Sqrt(sqdAngleu) * (turnStr <= 0f ? 1 : -1);
                }
            }
            if (vAngleCos <= 0f)
            {
                vbend = pitchStr >= 0f ? 10000f : -10000f;
                if (row < baseSplineHeight)
                {
                    vbendAngleList[row + 1] = vbendAngleList[row];
                }
            }
            else
            {
                float dyModv = dyList[row] / vAngleCos; //Transform distance
                float curvdyModv = pitchStr * pitchStr * dyModv * dyModv; //Cache multiplications
                float sqrtdyModv = Mathf.Sqrt(1 - curvdyModv);
                float vbendMod = (pitchStr != 0) ? (1 / pitchStr) * (sqrtdyModv - 1f) : 0f; //Calculate delta-x or z
                float sqdAnglev = (1 + curvdyModv - sqrtdyModv) * (curvdyModv >= 0f ? 1 : -1);//Calculate delta-angle
                vbend = (row != 0) ? vbendList[row - 1] + (dyList[row] * Mathf.Tan(vbendAngleList[row])) + (vbendMod * vAngleCos) : 0f;
                if (row < baseSplineHeight)
                {
                    vbendAngleList[row + 1] = vbendAngleList[row] + Mathf.Sqrt(sqdAnglev) * (pitchStr <= 0f ? 1 : -1);
                }
            }
            ubendList[row] = ubend; //Add to lists
            vbendList[row] = vbend;
            float vcoord = (vcoordNoOffset + yOffset)*splineTexInvHeight; //Bunch of code to calculate UV coordinates
            float splitPoint = Mathf.Clamp((((float)baseSplineWidth)*0.5f) - (xOffset + ubend)*scale, 0.1f, (float)baseSplineWidth - 0.1f);
            float uleftcoord = 0.5f + (-((float)baseSplineWidth*0.5f*invScale) + xOffset + ubend)*splineTexInvWidth;
            float urightcoord = 0.5f + (((float)baseSplineWidth*0.5f*invScale) + xOffset + ubend)*splineTexInvWidth;
            float umidcoord = Mathf.Lerp(uleftcoord, urightcoord, splitPoint*invSplineWidth);
            float normsplit = -splitAmt*splineTexInvWidth;
            float dipfloat = (float)row + vbend*scale;
            Vector2 uv0 = new Vector2(splitPoint, dipfloat); //Hacky way to encapsulate variables for the vertex positions
            Vector2 uv1 = new Vector2(uleftcoord - normsplit, vcoord); //Far-left UV coords
            Vector2 uv2 = new Vector2(umidcoord - normsplit, vcoord); //Left-of-split UV coords
            Vector2 uv3 = new Vector2(umidcoord + normsplit, vcoord); //Right-of-split UV coords
            Vector2 uv4 = new Vector2(urightcoord + normsplit, vcoord); //Far-right UV coords
            return new Vector2[]{uv0, uv1, uv2, uv3, uv4}; //Encapsulation
        }

        public float GetHorizonHeight() //Used for the y-position of the sky texture and the background sprites
        {
            return (float)baseSplineHeight + vbendList[baseSplineHeight]*topScale;
        }

        public Vector3 GetScreenPos(float dist, float xoff, float yoff) //Used for sprites, gets a screen position based on distance and x-offset
        {
            float scale = GetScale(dist);
            float relDist = dist - yOffset;
            float interpAmt = 0f;
            float x, y, z;
            int stopind = 0;
            if(relDist <= 0) //Linearly extrapolate beyond the spline
            {
                x = ((xoff - xOffset - (ubendList[0] + relDist*((ubendList[1]-ubendList[0])/dyList[1])))*scale) + 160f;
                y = (relDist + yoff + (vbendList[0] + relDist*((vbendList[1]-vbendList[0])/dyList[1])))*scale;
                z = baseSplineHeight*(bottomScale - scale)/(bottomScale - topScale);
            }
            else //Linearly interpolate within the spline
            {
                for(int i = baseSplineHeight; i >= 0; i--)
                {
                    if(relDist >= vcoordList[i])
                    {
                        if(i == baseSplineHeight) return new Vector3(0f, 0f, -2000f);
                        stopind = i;
                        interpAmt = (relDist - vcoordList[i])/dyList[i+1];
                        break;
                    }
                }
                x = ((xoff - xOffset - (Mathf.Lerp(ubendList[stopind], ubendList[stopind+1], interpAmt)))*scale) + 160f;
                y = (relDist + yoff + (Mathf.Lerp(vbendList[stopind], vbendList[stopind+1], interpAmt)))*scale;
                z = baseSplineHeight*(bottomScale - scale)/(bottomScale - topScale);
            }
            if(Single.IsNaN(x) || Single.IsNaN(y) || (z < -64f)) //Clipping, sends sprites that shouldn't be seen to a place that cannot be seen
            {
                return new Vector3(0f, 0f, -2000f);
            }
            return new Vector3(x, y, z);
        }

        public float GetDistanceOffset(int row)
        {
            return vcoordList[row];
        }

        public float GetScale(float dist) //Used for sprites, gets scale based on distance and x-offset
        {
            float outScale = bottomScale*(1-((dist-yOffset)*(bottomScale-topScale)/(baseSplineHeight+((dist-yOffset)*(bottomScale-topScale)))));
            if(outScale <= 0f) //Prevent negative scale
            {
                outScale = 0f;
            }
            return outScale;
        }

        public float GetRealXOff(float xoff, float yoff, MultiSprite.SpawnSide s) //Get the x-offset of a static sprite suitable for the spline
        {
            float splitComp = 64f;
            for(int i = 1; i < splitAmtPoints.Length; i++)
            {
                if(yoff >= splitAmtPoints[i-1] && yoff < splitAmtPoints[i])
                {
                    splitComp = Mathf.Lerp(splitAmtList[i-1], splitAmtList[i], (yoff-splitAmtPoints[i-1])/(splitAmtPoints[i]-splitAmtPoints[i-1])) + 64f;
                }
            }
            switch(s)
            {
                case MultiSprite.SpawnSide.LEFT:
                    return - xoff - splitComp;
                case MultiSprite.SpawnSide.RIGHT:
                    return xoff + splitComp;
                default:
                    return 0f;
            }
        }

        public float GetRealXOffTex(float xoff, float yoff, TexturedStrip.SpawnSide s) //Get the x-offset of a vertex of a texture suitable for the spline
        {
            float splitComp = 64f;
            for(int i = 1; i < splitAmtPoints.Length; i++)
            {
                if(yoff >= splitAmtPoints[i-1] && yoff < splitAmtPoints[i])
                {
                    splitComp = Mathf.Lerp(splitAmtList[i-1], splitAmtList[i], (yoff-splitAmtPoints[i-1])/(splitAmtPoints[i]-splitAmtPoints[i-1])) + 64f;
                }
            }
            switch(s)
            {
                case TexturedStrip.SpawnSide.LEFT:
                    return - xoff - splitComp;
                case TexturedStrip.SpawnSide.RIGHT:
                    return xoff + splitComp;
                default:
                    return 0f;
            }
        }

        public Vector2 GetStripVector(float yoffs, float xoffs, int zpoint)
        {
            float scale = GetScale(yoffs);
            float relDist = yoffs - yOffset;
            float vecx = ((xoffs - xOffset - ubendList[zpoint])*scale) + 160f;
            float vecy = ((relDist + vbendList[zpoint])*scale) + 0.05f;
            return new Vector2(vecx, vecy);
        }

        public void EditorPreviewInit() //EDITOR ONLY
        {
            Awake();
            Update();
        }

        public void EditorPreviewDestroy() //EDITOR ONLY
        {
            meshFilter.mesh = null;
        }

        void Awake() //Initialisation
        {
            invSplineHeight = 1/((float)baseSplineHeight);
            invSplineWidth = 1/((float)baseSplineWidth);
            meshRenderer = GetComponent<MeshRenderer>();
            meshFilter = GetComponent<MeshFilter>();
            Texture texture = meshRenderer.material.mainTexture; //Grab the texture from the mesh renderer
            splineTexWidth = texture.width;
            splineTexHeight = texture.height;
            splineTexInvHeight = 1/((float)splineTexHeight);
            splineTexInvWidth = 1/((float)splineTexWidth);
            splineMesh = new Mesh();
            meshFilter.mesh = splineMesh;
            Vector2[] calcUV;
            vertexArray = new Vector3[baseSplineHeight*4 + 4];
            uvArray = new Vector2[baseSplineHeight*4 + 4];
            triangleArray = new int[baseSplineHeight*12];
            vcoordList = new float[baseSplineHeight+1];
            dyList = new float[baseSplineHeight+1];
            ubendList = new float[baseSplineHeight+1];
            ubendAngleList = new float[baseSplineHeight+1];
            vbendList = new float[baseSplineHeight+1];
            vbendAngleList = new float[baseSplineHeight+1];
            for(int i = 0; i < baseSplineHeight+1; i++) //Calculate distance mapping
            {
                vcoordList[i] = ((float)i)/(Mathf.Lerp(bottomScale, topScale, ((float)i)*invSplineHeight));
                ubendList[i] = 0f;
                ubendAngleList[i] = 0f;
                vbendList[i] = 0f;
                vbendAngleList[i] = 0f;
            }
            for(int i = 0; i < baseSplineHeight+1; i++)
            {
                dyList[i] = (i == 0)?0f:vcoordList[i]-vcoordList[i-1];
            }
            for(int i = 0; i < baseSplineHeight+1; i++) //Assign initial vertex array and UV array
            {
                calcUV = CalculateUV(i);
                vertexArray[i*4] = new Vector3(0f,i,i);
                vertexArray[i*4 + 1] = new Vector3(((float)baseSplineWidth)/2,i,i);
                vertexArray[i*4 + 2] = new Vector3(((float)baseSplineWidth)/2,i,i);
                vertexArray[i*4 + 3] = new Vector3((float)baseSplineWidth,i,i);
                uvArray[i*4] = calcUV[1];
                uvArray[i*4 + 1] = calcUV[2];
                uvArray[i*4 + 2] = calcUV[3];
                uvArray[i*4 + 3] = calcUV[4];
            }
            for(int i = 0; i < baseSplineHeight; i++) //Assign triangle array; don't change this
            {
                triangleArray[i*12] = i*4 + 1;
                triangleArray[i*12 + 1] = i*4;
                triangleArray[i*12 + 2] = i*4 + 4;
                triangleArray[i*12 + 3] = i*4 + 5;
                triangleArray[i*12 + 4] = i*4 + 1;
                triangleArray[i*12 + 5] = i*4 + 4;
                triangleArray[i*12 + 6] = i*4 + 3;
                triangleArray[i*12 + 7] = i*4 + 2;
                triangleArray[i*12 + 8] = i*4 + 7;
                triangleArray[i*12 + 9] = i*4 + 7;
                triangleArray[i*12 +10] = i*4 + 2;
                triangleArray[i*12 +11] = i*4 + 6;
            }
            splineMesh.vertices = vertexArray; //Reassign arrays to update changes
            splineMesh.uv = uvArray;
            splineMesh.triangles = triangleArray;
        }

        void Update()
        {
            Vector2[] calcUV;
            for(int i = 0; i < baseSplineHeight+1; i++)
            {
                calcUV = CalculateUV(i);
                vertexArray[i*4] = new Vector3(0f,calcUV[0].y,i); //That's what the first bit of the UV array output was for
                vertexArray[i*4 + 1] = new Vector3(calcUV[0].x,calcUV[0].y,i);
                vertexArray[i*4 + 2] = new Vector3(calcUV[0].x,calcUV[0].y,i);
                vertexArray[i*4 + 3] = new Vector3((float)baseSplineWidth,calcUV[0].y,i);
                uvArray[i*4] = calcUV[1];
                uvArray[i*4 + 1] = calcUV[2];
                uvArray[i*4 + 2] = calcUV[3];
                uvArray[i*4 + 3] = calcUV[4];
            }
            splineMesh.vertices = vertexArray; //Reassign arrays to update changes
            splineMesh.uv = uvArray;
        }
    }
}