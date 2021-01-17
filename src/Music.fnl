(local au love.audio)
(local ma love.math)

{:songAuthor "TeknoAXE"
 :songs ["Running_On_Air" "Robot_Disco_Dance" "Supersonic" "Dystopian_Paradise" "Caught_in_the_Drift"]
 :dir "assets/music/"
 :ext ".mp3"
 :play (fn play [self]
  (var title self.songTitle)
  (while (= title self.songTitle)
    (set self.songTitle (. self.songs (ma.random (length self.songs)))))
  (set self.bgm (au.newSource (.. self.dir self.songTitle self.ext) "stream"))
  (au.play self.bgm))}
