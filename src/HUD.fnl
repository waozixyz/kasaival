(local suit (require :lib.suit))
(local push (require :lib.push))

(local Cursor (require :src.Cursor))
(local Music (require :src.Music))

(local gr love.graphics)
(local mo love.mouse)

(fn toggle [val] (if val false true))

{:init (fn init [self]
         (Cursor:init)
         (set self.exit (gr.newImage :assets/icons/exit.png))
         (set self.resume (gr.newImage :assets/icons/resume.png))
         (set self.pause (gr.newImage :assets/icons/pause.png))
         (set self.music (gr.newImage :assets/icons/music.png))
         (set self.nomusic (gr.newImage :assets/icons/nomusic.png))
         (set self.sound (gr.newImage :assets/icons/sound.png))
         (set self.nosound (gr.newImage :assets/icons/nosound.png)))
 :draw (fn draw [self])

 :update (fn update [self game]
           (local (W H) (push:getDimensions))
           

           (var exit_button (suit.ImageButton self.exit 20 20))
           (when (= exit_button.hit true)
             (set game.exit true))


           (var pause_image self.pause) 
           (when game.paused (set pause_image self.resume))
           (var pause_button (suit.ImageButton pause_image 100 20))
           (when (= pause_button.hit true)
             (set game.paused (toggle game.paused)))
  

           (var music_image self.music)
           (when game.muted (set music_image self.nomusic))
           (var music_button (suit.ImageButton music_image (- W 84) 20))
           (when (= music_button.hit true)
             (set game.muted (toggle game.muted)))

           ;;(var sound_button (suit.ImageButton self.sound (- W 164) 20))
           ;;(when (= sound_button.hit true)
           ;;  nil)

           (Cursor:update))


 :keypressed (fn keypressd [self game key set-mode]
               (when (= key :kp+)
                 (Music.bgm:setVolume (+ (Music.bgm:getVolume) .1)))
               (when (= key :kp-)
                 (Music.bgm:setVolume (- (Music.bgm:getVolume) .1)))
               (when (= key :n)
                 (Music.bgm:stop))
               (when (= key :m)
                 (if game.muted
                   (Music.bgm:play)
                   (Music.bgm:pause))
                 (set game.muted (toggle game.muted)))
               (when (or (= key :p) (= key :pause))
                 (set game.paused (toggle game.paused)))
               (when (= key :escape)
                 (set game.paused true)
                 (set game.exit true)))}
