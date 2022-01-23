using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SplineTest
{
    public class SendCharacterInfo : MonoBehaviour
    {
        public PlayMaster pm;
        public int charNum;

        public void SendInfo()
        {
            pm.EnterChar(charNum);
        }
    }
}