using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SplineTest
{
    public class PlayerColliderControl : MonoBehaviour
    {
        public PlayMaster master;

        void OnCollisionEnter(Collision col)
        {
            SpriteManager sprman = col.transform.parent.gameObject.GetComponent<SpriteManager>();
            if(sprman.canCollide)
            {
                if(sprman.spriteType == SpriteManager.SpriteType.STATIC)
                {
                    master.StaticSpriteCollision();
                }
                if(sprman.spriteType == SpriteManager.SpriteType.DYNAMIC)
                {
                    master.DynamicSpriteCollision();
                }
            }
        }
    }
}