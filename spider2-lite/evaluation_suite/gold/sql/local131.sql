SELECT 
  Musical_Styles.StyleName,
  COUNT(RankedPreferences.FirstStyle)
    AS FirstPreference,
  COUNT(RankedPreferences.SecondStyle)
    AS SecondPreference,
  COUNT(RankedPreferences.ThirdStyle)
    AS ThirdPreference
FROM Musical_Styles,
 (SELECT (CASE WHEN
    Musical_Preferences.PreferenceSeq = 1
               THEN Musical_Preferences.StyleID
               ELSE Null END) As FirstStyle,
         (CASE WHEN
    Musical_Preferences.PreferenceSeq = 2
               THEN Musical_Preferences.StyleID
               ELSE Null END) As SecondStyle,
         (CASE WHEN
    Musical_Preferences.PreferenceSeq = 3
               THEN Musical_Preferences.StyleID
               ELSE Null END) AS ThirdStyle
   FROM Musical_Preferences)  AS RankedPreferences
WHERE Musical_Styles.StyleID =
         RankedPreferences.FirstStyle
  OR Musical_Styles.StyleID =
         RankedPreferences.SecondStyle
  OR Musical_Styles.StyleID =
         RankedPreferences.ThirdStyle
GROUP BY StyleID, StyleName
HAVING COUNT(FirstStyle) > 0
     OR     COUNT(SecondStyle) > 0
     OR     COUNT(ThirdStyle) > 0
ORDER BY FirstPreference DESC,
        SecondPreference DESC,
        ThirdPreference DESC, StyleID;