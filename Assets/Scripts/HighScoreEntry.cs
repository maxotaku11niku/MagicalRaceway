using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace SplineTest
{
    public class HighScore //Logical high-score entry
    {
        private string name;
        private uint score; //Premultiplied by 10 when actually displayed...
        private uint stage;
        private uint time;

        public string Name { get{ return name; } }
        public uint Score { get{ return score; } }
        public uint Stage { get{ return stage; } }
        public uint Time { get{ return time; } }
        public string ScoreText { get{ return score.ToString() + "0"; } } //...which actually means just appending "0" to the score
        public string StageText { get{ return stage.ToString(); } }
        public string TimeMinutesText { get{ return (time/6000).ToString(); } }
        public string TimeSecondsText { get{ return ((time/100)%60).ToString(); } }
        public string TimeCentisecondsText { get{ return (time%100).ToString(); } }

        public HighScore()
        {
            name = "";
            score = 0;
            stage = 1;
            time = 0;
        }

        public HighScore(string nam, uint scor, uint stg, float t) //t in seconds
        {
            name = nam;
            score = scor;
            stage = stg;
            time = (uint)(t*100f);
        }

        public HighScore(string nam, uint scor, uint stg, uint t) //t in centiseconds
        {
            name = nam;
            score = scor;
            stage = stg;
            time = t;
        }

        public void UpdateName(string nam)
        {
            name = nam;
        }

        public string GetFormattedTime()
        {
            return (TimeMinutesText.Length == 1?"0":"") + TimeMinutesText + "'" + (TimeSecondsText.Length == 1?"0":"") + TimeSecondsText + "." + (TimeCentisecondsText.Length == 1?"0":"") + TimeCentisecondsText + '"';
        }
    }

    public class HighScoreEntry : MonoBehaviour //For a high-score entry that actually appears
    {
        public Text nameText;
        public Text scoreText;
        public Text stageText;
        public Text timeText;

        public void SetUpEntry(HighScore entry)
        {
            nameText.text = entry.Name;
            scoreText.text = entry.ScoreText;
            stageText.text = entry.StageText;
            timeText.text = entry.GetFormattedTime();
        }
    }
}