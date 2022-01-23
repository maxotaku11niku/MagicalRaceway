using System;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace SplineTest
{
    public class HighScoreGroup
    {
        private static readonly HighScoreGroup testDefault = new HighScoreGroup("TEST", new HighScore[] { new HighScore("Maxim Hoxha", 4928854, 2, 13136), //It's me!
                                                                                                          new HighScore("Raymoo Hackery", 1900000, 2, 19000), //broke shrine maiden
                                                                                                          new HighScore("Marisus Ksamey", 1800000, 2, 18000), //ordinary magician thief
                                                                                                          new HighScore("Succya Izaboi", 1700000, 2, 17000), //dio maid
                                                                                                          new HighScore("Sanooee Gotcha", 1600000, 2, 16000), //green raymoo
                                                                                                          new HighScore("Yummy Gonepack", 1500000, 2, 15000), //half ghost feeder
                                                                                                          new HighScore("Raisin Udonge", 1400000, 2, 14000), //mad bunny
                                                                                                          new HighScore("Yucurri Yakky", 1300000, 2, 13000), //gap hag
                                                                                                          new HighScore("Remilia Scrlt", 1200000, 2, 12000), //mistr00s
                                                                                                          new HighScore("MimaIsNotGone!", 1100000, 2, 11000), //literally who?
                                                                                                          new HighScore("KanaccOfMoriya", 1000000, 1, 10000), //donut goddess
                                                                                                          new HighScore("YuyukoEatALot", 900000, 1, 9000), //fat fuck <3
                                                                                                          new HighScore("    pilf ajieS", 800000, 1, 8000), //sdrawkcab
                                                                                                          new HighScore("Purest Junko", 700000, 1, 7000), //pure mum
                                                                                                          new HighScore("alway rember", 600000, 1, 6000), //sunflowers
                                                                                                          new HighScore("Utsuhoe NUCULR", 500000, 1, 5000), //nuclear raven
                                                                                                          new HighScore("lily white", 400000, 1, 4000), //spring is here!
                                                                                                          new HighScore("Clownpiss¤¤¤¤¤", 300000, 1, 3000), //america fuck yeah
                                                                                                          new HighScore("¤X-Æ-A-12¤µ¼ß£", 200000, 1, 2000), //wtf elongated muskrat??
                                                                                                          new HighScore("crino", 100000, 1, 1000) }); //dumb shit fairy
        private static readonly HighScoreGroup easyDefault = new HighScoreGroup("EASY", new HighScore[] { new HighScore("Maxim Hoxha", 694206942, 69, 418229),
                                                                                                          new HighScore("Raymoo Hackery", 87329134, 20, 137378),
                                                                                                          new HighScore("Marisus Ksamey", 72389495, 18, 121745),
                                                                                                          new HighScore("Succya Izaboi", 64529324, 17, 1),
                                                                                                          new HighScore("Sanooee Gotcha", 59389245, 16, 105219),
                                                                                                          new HighScore("Yummy Gonepack", 55398593, 15, 98589),
                                                                                                          new HighScore("Raisin Udonge", 48387824, 14, 94542),
                                                                                                          new HighScore("Yucurri Yakky", 42042042, 13, 85876),
                                                                                                          new HighScore("Remilia Scrlt", 36839459, 12, 81465),
                                                                                                          new HighScore("MimaIsNotGone!", 31234532, 11, 73234),
                                                                                                          new HighScore("KanaccOfMoriya", 24953643, 10, 70303),
                                                                                                          new HighScore("YuyukoEatALot", 19292929, 9, 62143),
                                                                                                          new HighScore("    pilf ajieS", 16482345, 8, 52907),
                                                                                                          new HighScore("Purest Junko", 11111111, 7, 42395),
                                                                                                          new HighScore("alway rember", 9992384, 6, 36912),
                                                                                                          new HighScore("Utsuhoe NUCULR", 7583924, 5, 34543),
                                                                                                          new HighScore("lily white", 5578243, 4, 27227),
                                                                                                          new HighScore("Clownpiss¤¤¤¤¤", 4148782, 3, 19529),
                                                                                                          new HighScore("¤X-Æ-A-12¤µ¼ß£", 2348478, 2, 14592),
                                                                                                          new HighScore("crino", 9, 1, 9100) });
        private static readonly HighScoreGroup mediumDefault = new HighScoreGroup("MEDIUM", new HighScore[] { new HighScore("Maxim Hoxha", 694206942, 69, 418229),
                                                                                                          new HighScore("Raymoo Hackery", 87329134, 20, 137378),
                                                                                                          new HighScore("Marisus Ksamey", 72389495, 18, 121745),
                                                                                                          new HighScore("Succya Izaboi", 64529324, 17, 1),
                                                                                                          new HighScore("Sanooee Gotcha", 59389245, 16, 105219),
                                                                                                          new HighScore("Yummy Gonepack", 55398593, 15, 98589),
                                                                                                          new HighScore("Raisin Udonge", 48387824, 14, 94542),
                                                                                                          new HighScore("Yucurri Yakky", 42042042, 13, 85876),
                                                                                                          new HighScore("Remilia Scrlt", 36839459, 12, 81465),
                                                                                                          new HighScore("MimaIsNotGone!", 31234532, 11, 73234),
                                                                                                          new HighScore("KanaccOfMoriya", 24953643, 10, 70303),
                                                                                                          new HighScore("YuyukoEatALot", 19292929, 9, 62143),
                                                                                                          new HighScore("    pilf ajieS", 16482345, 8, 52907),
                                                                                                          new HighScore("Purest Junko", 11111111, 7, 42395),
                                                                                                          new HighScore("alway rember", 9992384, 6, 36912),
                                                                                                          new HighScore("Utsuhoe NUCULR", 7583924, 5, 34543),
                                                                                                          new HighScore("lily white", 5578243, 4, 27227),
                                                                                                          new HighScore("Clownpiss¤¤¤¤¤", 4148782, 3, 19529),
                                                                                                          new HighScore("¤X-Æ-A-12¤µ¼ß£", 2348478, 2, 14592),
                                                                                                          new HighScore("crino", 9, 1, 9100) });
        private static readonly HighScoreGroup hardDefault = new HighScoreGroup("HARD", new HighScore[] { new HighScore("Maxim Hoxha", 694206942, 69, 418229),
                                                                                                          new HighScore("Raymoo Hackery", 87329134, 20, 137378),
                                                                                                          new HighScore("Marisus Ksamey", 72389495, 18, 121745),
                                                                                                          new HighScore("Succya Izaboi", 64529324, 17, 1),
                                                                                                          new HighScore("Sanooee Gotcha", 59389245, 16, 105219),
                                                                                                          new HighScore("Yummy Gonepack", 55398593, 15, 98589),
                                                                                                          new HighScore("Raisin Udonge", 48387824, 14, 94542),
                                                                                                          new HighScore("Yucurri Yakky", 42042042, 13, 85876),
                                                                                                          new HighScore("Remilia Scrlt", 36839459, 12, 81465),
                                                                                                          new HighScore("MimaIsNotGone!", 31234532, 11, 73234),
                                                                                                          new HighScore("KanaccOfMoriya", 24953643, 10, 70303),
                                                                                                          new HighScore("YuyukoEatALot", 19292929, 9, 62143),
                                                                                                          new HighScore("    pilf ajieS", 16482345, 8, 52907),
                                                                                                          new HighScore("Purest Junko", 11111111, 7, 42395),
                                                                                                          new HighScore("alway rember", 9992384, 6, 36912),
                                                                                                          new HighScore("Utsuhoe NUCULR", 7583924, 5, 34543),
                                                                                                          new HighScore("lily white", 5578243, 4, 27227),
                                                                                                          new HighScore("Clownpiss¤¤¤¤¤", 4148782, 3, 19529),
                                                                                                          new HighScore("¤X-Æ-A-12¤µ¼ß£", 2348478, 2, 14592),
                                                                                                          new HighScore("crino", 9, 1, 9100) });
        private static readonly HighScoreGroup insaneDefault = new HighScoreGroup("INSANE", new HighScore[] { new HighScore("Maxim Hoxha", 694206942, 69, 418229),
                                                                                                          new HighScore("Raymoo Hackery", 87329134, 20, 137378),
                                                                                                          new HighScore("Marisus Ksamey", 72389495, 18, 121745),
                                                                                                          new HighScore("Succya Izaboi", 64529324, 17, 1),
                                                                                                          new HighScore("Sanooee Gotcha", 59389245, 16, 105219),
                                                                                                          new HighScore("Yummy Gonepack", 55398593, 15, 98589),
                                                                                                          new HighScore("Raisin Udonge", 48387824, 14, 94542),
                                                                                                          new HighScore("Yucurri Yakky", 42042042, 13, 85876),
                                                                                                          new HighScore("Remilia Scrlt", 36839459, 12, 81465),
                                                                                                          new HighScore("MimaIsNotGone!", 31234532, 11, 73234),
                                                                                                          new HighScore("KanaccOfMoriya", 24953643, 10, 70303),
                                                                                                          new HighScore("YuyukoEatALot", 19292929, 9, 62143),
                                                                                                          new HighScore("    pilf ajieS", 16482345, 8, 52907),
                                                                                                          new HighScore("Purest Junko", 11111111, 7, 42395),
                                                                                                          new HighScore("alway rember", 9992384, 6, 36912),
                                                                                                          new HighScore("Utsuhoe NUCULR", 7583924, 5, 34543),
                                                                                                          new HighScore("lily white", 5578243, 4, 27227),
                                                                                                          new HighScore("Clownpiss¤¤¤¤¤", 4148782, 3, 19529),
                                                                                                          new HighScore("¤X-Æ-A-12¤µ¼ß£", 2348478, 2, 14592),
                                                                                                          new HighScore("crino", 9, 1, 9100) });

        private static readonly char[] scorefileID = new char[]{(char)0x4D, (char)0x52, (char)0x53, (char)0x46}; //"MRSF"
        private static readonly char[] scorefileVersion = new char[]{(char)0x33, (char)0x39}; //"39"
#if UNITY_EDITOR
        public static readonly string scorefileDirectory = "Assets/Scorefiles/";
#elif UNITY_STANDALONE
        public static readonly string scorefileDirectory = "Scorefiles/";
#elif UNITY_ANDROID
        public static readonly string scorefileDirectory = "Scorefiles/";
#else
        public static readonly string scorefileDirectory = "Scorefiles/";
#endif
        public static readonly string scorefileExtension = ".mrs";

        private string name;
        private HighScore[] entries;

        public string Name { get{ return name; } }
        public HighScore[] EntryList { get{ return entries; } }

        public HighScoreGroup()
        {
            name = "";
            entries = new HighScore[20]; //This is as much as can fit on the screen
        }

        public HighScoreGroup(string nam, int length)
        {
            name = nam;
            entries = new HighScore[length];
        }

        public HighScoreGroup(string nam, HighScore[] entr)
        {
            name = nam;
            entries = entr;
        }

        public static HighScoreGroup ImportScoreDataFromFile(string path)
        {
            char[] charlist;
            string nam;
            uint scor;
            uint stgandt; //Stage number and time mashed together in one 32-bit integer
            HighScore currentHS;
            HighScoreGroup currentHSG;
            if(File.Exists(path))
            {
                BinaryReader reader = new BinaryReader(File.Open(path, FileMode.Open), Encoding.GetEncoding(28591));
                charlist = reader.ReadChars(4);
                if(new String(charlist) != new String(scorefileID))
                {
                    Debug.LogWarning(path + " is not a valid score file. All valid score files start with 'MRSF' in the header.");
                    return null;
                }
                charlist = reader.ReadChars(2);
                if(new String(charlist) != new String(scorefileVersion))
                {
                    Debug.LogWarning(path + " is an incompatible scorefile. '39' is the current scorefile version indicator.");
                    return null;
                }
                charlist = reader.ReadChars(16);
                nam = new String(charlist);
                charlist = reader.ReadChars(1);
                if(charlist[0] != 0x02)
                {
                    Debug.LogWarning(path + " has an incorrectly terminated header. Terminate the header with the STX control (0x02).");
                    return null;
                }
                currentHSG = new HighScoreGroup(nam, 20);
                for(int i = 0; i < 20; i++)
                {
                    charlist = reader.ReadChars(14);
                    nam = new String(charlist);
                    scor = reader.ReadUInt32();
                    stgandt = reader.ReadUInt32();
                    currentHS = new HighScore(nam, scor, stgandt&0x000000FF, (stgandt&0xFFFFFF00)>>8); //Decouple the time and stage number
                    currentHSG.AddEntry(currentHS);
                }
                Debug.Log(path + " was successfully loaded!");
                reader.Close();
                return currentHSG;
            }
            else
            {
                Debug.LogWarning(path + " could not be found.");
                return null;
            }
        }

        public static void WriteDefaultScoreDataToFile(string appBaseDirectory) //This method is rather long and explicit
        {
            char[] charlist;
            uint compint;

            BinaryWriter writer = new BinaryWriter(File.Open(appBaseDirectory + scorefileDirectory + "test" + scorefileExtension, FileMode.Create), Encoding.GetEncoding(28591));
            writer.Write(scorefileID);
            writer.Write(scorefileVersion);
            charlist = new char[16];
            for (int i = 0; i < 16; i++)
            {
                if (i >= testDefault.name.Length)
                {
                    charlist[i] = (char)0x20;
                }
                else
                {
                    charlist[i] = testDefault.name[i];
                }
            }
            writer.Write(charlist);
            writer.Write((byte)0x02);
            foreach (HighScore HS in testDefault.entries)
            {
                charlist = new char[14];
                for (int i = 0; i < 14; i++)
                {
                    if (i >= HS.Name.Length)
                    {
                        charlist[i] = (char)0x20;
                    }
                    else
                    {
                        charlist[i] = HS.Name[i];
                    }
                }
                writer.Write(charlist);
                writer.Write(HS.Score);
                compint = HS.Stage + (HS.Time << 8);
                writer.Write(compint);
            }
            writer.Write((byte)0x04);
            writer.Close();

            writer = new BinaryWriter(File.Open(appBaseDirectory + scorefileDirectory + "easy" + scorefileExtension, FileMode.Create), Encoding.GetEncoding(28591));
            writer.Write(scorefileID);
            writer.Write(scorefileVersion);
            charlist = new char[16];
            for (int i = 0; i < 16; i++)
            {
                if (i >= easyDefault.name.Length)
                {
                    charlist[i] = (char)0x20;
                }
                else
                {
                    charlist[i] = easyDefault.name[i];
                }
            }
            writer.Write(charlist);
            writer.Write((byte)0x02);
            foreach (HighScore HS in easyDefault.entries)
            {
                charlist = new char[14];
                for (int i = 0; i < 14; i++)
                {
                    if (i >= HS.Name.Length)
                    {
                        charlist[i] = (char)0x20;
                    }
                    else
                    {
                        charlist[i] = HS.Name[i];
                    }
                }
                writer.Write(charlist);
                writer.Write(HS.Score);
                compint = HS.Stage + (HS.Time << 8);
                writer.Write(compint);
            }
            writer.Write((byte)0x04);
            writer.Close();

            writer = new BinaryWriter(File.Open(appBaseDirectory + scorefileDirectory + "medium" + scorefileExtension, FileMode.Create), Encoding.GetEncoding(28591));
            writer.Write(scorefileID);
            writer.Write(scorefileVersion);
            charlist = new char[16];
            for (int i = 0; i < 16; i++)
            {
                if (i >= mediumDefault.name.Length)
                {
                    charlist[i] = (char)0x20;
                }
                else
                {
                    charlist[i] = mediumDefault.name[i];
                }
            }
            writer.Write(charlist);
            writer.Write((byte)0x02);
            foreach (HighScore HS in mediumDefault.entries)
            {
                charlist = new char[14];
                for (int i = 0; i < 14; i++)
                {
                    if (i >= HS.Name.Length)
                    {
                        charlist[i] = (char)0x20;
                    }
                    else
                    {
                        charlist[i] = HS.Name[i];
                    }
                }
                writer.Write(charlist);
                writer.Write(HS.Score);
                compint = HS.Stage + (HS.Time << 8);
                writer.Write(compint);
            }
            writer.Write((byte)0x04);
            writer.Close();

            writer = new BinaryWriter(File.Open(appBaseDirectory + scorefileDirectory + "hard" + scorefileExtension, FileMode.Create), Encoding.GetEncoding(28591));
            writer.Write(scorefileID);
            writer.Write(scorefileVersion);
            charlist = new char[16];
            for (int i = 0; i < 16; i++)
            {
                if (i >= hardDefault.name.Length)
                {
                    charlist[i] = (char)0x20;
                }
                else
                {
                    charlist[i] = hardDefault.name[i];
                }
            }
            writer.Write(charlist);
            writer.Write((byte)0x02);
            foreach (HighScore HS in hardDefault.entries)
            {
                charlist = new char[14];
                for (int i = 0; i < 14; i++)
                {
                    if (i >= HS.Name.Length)
                    {
                        charlist[i] = (char)0x20;
                    }
                    else
                    {
                        charlist[i] = HS.Name[i];
                    }
                }
                writer.Write(charlist);
                writer.Write(HS.Score);
                compint = HS.Stage + (HS.Time << 8);
                writer.Write(compint);
            }
            writer.Write((byte)0x04);
            writer.Close();

            writer = new BinaryWriter(File.Open(appBaseDirectory + scorefileDirectory + "insane" + scorefileExtension, FileMode.Create), Encoding.GetEncoding(28591));
            writer.Write(scorefileID);
            writer.Write(scorefileVersion);
            charlist = new char[16];
            for (int i = 0; i < 16; i++)
            {
                if (i >= insaneDefault.name.Length)
                {
                    charlist[i] = (char)0x20;
                }
                else
                {
                    charlist[i] = insaneDefault.name[i];
                }
            }
            writer.Write(charlist);
            writer.Write((byte)0x02);
            foreach (HighScore HS in insaneDefault.entries)
            {
                charlist = new char[14];
                for (int i = 0; i < 14; i++)
                {
                    if (i >= HS.Name.Length)
                    {
                        charlist[i] = (char)0x20;
                    }
                    else
                    {
                        charlist[i] = HS.Name[i];
                    }
                }
                writer.Write(charlist);
                writer.Write(HS.Score);
                compint = HS.Stage + (HS.Time << 8);
                writer.Write(compint);
            }
            writer.Write((byte)0x04);
            writer.Close();
        }

        public void WriteScoreDataToFile(string path)
        {
            char[] charlist;
            uint compint;
            BinaryWriter writer = new BinaryWriter(File.Open(path, FileMode.Create), Encoding.GetEncoding(28591));
            writer.Write(scorefileID);
            writer.Write(scorefileVersion);
            charlist = new char[16];
            for(int i = 0; i < 16; i++)
            {
                if(i >= name.Length)
                {
                    charlist[i] = (char)0x20;
                }
                else
                {
                    charlist[i] = name[i];
                }
            }
            writer.Write(charlist);
            writer.Write((byte)0x02);
            foreach(HighScore HS in entries)
            {
                charlist = new char[14];
                for(int i = 0; i < 14; i++)
                {
                    if(i >= HS.Name.Length)
                    {
                        charlist[i] = (char)0x20;
                    }
                    else
                    {
                        charlist[i] = HS.Name[i];
                    }
                }
                writer.Write(charlist);
                writer.Write(HS.Score);
                compint = HS.Stage + (HS.Time << 8); //Fuse time and stage number into one 32-bit integer
                writer.Write(compint);
            }
            writer.Write((byte)0x04);
            writer.Close();
        }

        public void AddEntry(HighScore newEntry)
        {
            for(int i = 0; i < entries.Length; i++)
            {
                if(entries[i] == null) //Trivial if the entry is empty
                {
                    entries[i] = newEntry;
                    return;
                }
                else if(newEntry.Score > entries[i].Score) //Only add if the new score is higher than any of the existing ones
                {
                    for(int j = entries.Length - 1; j > i; j--)
                    {
                        entries[j] = entries[j-1];
                    }
                    entries[i] = newEntry;
                    return;
                }
            }
        }

        public bool CanAddEntry(HighScore newEntry) //Primarily used in gameplay
        {
            for(int i = 0; i < entries.Length; i++)
            {
                if(entries[i] == null)
                {
                    return true;
                }
                else if(newEntry.Score > entries[i].Score)
                {
                    return true;
                }
            }
            return false;
        }
    }

    public class HighScoreScreen : MonoBehaviour
    {
        public GameMaster gm;
        public TouchButton acceptTButton;
        public TouchButton declineTButton;
        public TouchButton dpadUpTButton;
        public TouchButton dpadDownTButton;
        public TouchButton dpadLeftTButton;
        public TouchButton dpadRightTButton;
        public GameObject entryPrefab;
        public HighScoreEntry[] entries;
        public Text groupNameText;
        public int currentGroup;

        void Update()
        {
            if(gm.playerInput.currentActionMap.FindAction("Menu Navigation").triggered || dpadLeftTButton.isDown || dpadRightTButton.isDown)
            {
#if UNITY_EDITOR
                currentGroup += (int)(gm.playerInput.currentActionMap.FindAction("Menu Navigation").ReadValue<Vector2>().x);
#elif UNITY_STANDALONE
                currentGroup += (int)(gm.playerInput.currentActionMap.FindAction("Menu Navigation").ReadValue<Vector2>().x);
#elif UNITY_ANDROID
                if (dpadRightTButton.isDown)
                {
                    currentGroup++;
                }
                else if (dpadLeftTButton.isDown)
                {
                    currentGroup--;
                }
#elif UNITY_IOS
                if (dpadRightTButton.isDown)
                {
                    currentGroup++;
                }
                else if (dpadLeftTButton.isDown)
                {
                    currentGroup--;
                }
#endif
                currentGroup %= gm.scoreGroups.Length; //Wrap
                if(currentGroup < 0) currentGroup = gm.scoreGroups.Length - 1;
                HighScoreGroup curGroup = gm.scoreGroups[currentGroup];
                groupNameText.text = curGroup.Name;
                for(int i = 0; i < curGroup.EntryList.Length; i++)
                {
                    entries[i].SetUpEntry(curGroup.EntryList[i]);
                }
            }
        }

        void OnEnable()
        {
            currentGroup = 0;
            HighScoreGroup curGroup = gm.scoreGroups[currentGroup];
            entries = new HighScoreEntry[curGroup.EntryList.Length];
            groupNameText.text = curGroup.Name;
            for(int i = 0; i < curGroup.EntryList.Length; i++)
            {
                entries[i] = GameObject.Instantiate(entryPrefab, new Vector3(8f, 200f - i*8f, -100f), Quaternion.identity, this.transform).GetComponent<HighScoreEntry>();
                entries[i].SetUpEntry(curGroup.EntryList[i]);
            }
        }

        void OnDisable()
        {
            foreach(HighScoreEntry E in entries)
            {
                GameObject.Destroy(E.gameObject);
            }
        }
    }
}
