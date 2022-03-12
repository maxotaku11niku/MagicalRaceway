using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SplineTest
{
    [CreateAssetMenu(fileName = "spritedef", menuName = "Custom Assets/Static Sprite Definition", order = 2)]
    [PreferBinarySerialization]
    public class StaticSpriteDef : ScriptableObject
    {
        public Sprite sprite;
        public Vector3 collisionBounds;
        public Vector3 GetRealCollisionBounds(float scale)
        {
            return collisionBounds/scale;
        }
    }
}