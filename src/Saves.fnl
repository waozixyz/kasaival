(local fi love.filesystem)
(local gr love.graphics)


{:saveName "saves/save"
 :nextSave (fn nextSave [self]
             (.. self.saveName (+ (length (self:getFiles)) 1)))
 :checkFiles (fn checkFiles [self saves]
               (var rtn  [])
               (each [i sav (ipairs saves)]
                 (when (< (length sav) 2)
                   (if (. sav :file)
                     (tset rtn i sav)
                     (table.remove rtn i))))
               rtn)
 ;; returns table of files in :saves with {:img image :file filename}
 :getFiles (fn getFiles [self]
             (var rtn [])
             
             (when (not (fi.getInfo :saves))
               (fi.createDirectory :saves))

             (local files (fi.getDirectoryItems :saves))
             (each [i file (ipairs files)]
               (var id (file:gsub "save" ""))
               (set id (id:gsub ".png" ""))
               (set id (tonumber id))

               (when (= (. rtn id) nil) 
                 (tset rtn id {})) ;; add new save table to return

               (var s (. rtn id)) ;; get the table with id to append data 
               (if (string.find file :.png)
                 (tset s :img (gr.newImage (.. "saves/" file)))
                 (tset s :file file))
               (tset rtn id s)) ;; update return table
             (self:checkFiles rtn))}
