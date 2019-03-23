(defun print-box (x y bsize color)
  (sdl:draw-box (sdl:rectangle-from-midpoint-*
                  (+ x (floor bsize 2)) 
                  (+ y (floor bsize 2)) bsize bsize)
                :color color))

(defun print-matrix (matrix row column bsize)
  (sdl:clear-display (if (equal *toggle* 1) *white* *black*))
  (dotimes (i row)
    (dotimes (j column)
      (if (equal (aref matrix i j) 1)
          (print-box (+ 1 (* i bsize) xn)
                     (+ 1 (* j bsize) yn)
                     (- bsize (floor bsize 10))
                     (if (equal *toggle* 1) *black* *white*)))
      (if (equal (aref matrix i j) 2)
          (print-box (+ 1 (* i bsize) xn)
                     (+ 1 (* j bsize) yn)
                     (- bsize (floor bsize 10))
                     (if (equal *toggle* 1) *red* *gray*)))
      ))
  (sdl:update-display))

(defun zoom-in ()
 (if (< bsize *max-zoom*)
     (progn
       (setf bsize (+ bsize *zoom*))
       (setf xn (- xn 50))
       (setf yn (- yn 50))
       )))

(defun zoom-out ()
  (if (> bsize *min-zoom*)
      (progn
        (setf bsize (- bsize *zoom*))
        (setf xn (+ xn 50))
        (setf yn (+ yn 50))
        )))

(defun move-forward-x ()
   (setf xn (+ xn *step*)))

(defun move-backward-x ()
  (setf xn (- xn *step*)))

(defun move-forward-y ()
   (setf yn (+ yn *step*)))

(defun move-backward-y ()
  (setf yn (- yn *step*)))

(defun reset-matrix ()
  (setq matrix (make-array (list row column) :initial-element 0)))

(defun handle-key-event (key)
  (if (sdl:key= key :sdl-key-escape)
      (sdl:push-quit-event))
  (if (OR (sdl:key= key :sdl-key-up) (sdl:key= key :sdl-key-a))
      (move-forward-y))
  (if (OR (sdl:key= key :sdl-key-down) (sdl:key= key :sdl-key-w))
      (move-backward-y))
  (if (OR (sdl:key= key :sdl-key-left) (sdl:key= key :sdl-key-s))
      (move-forward-x))
  (if (OR (sdl:key= key :sdl-key-right) (sdl:key= key :sdl-key-d))
      (move-backward-x))
  (if (OR (sdl:key= key :sdl-key-o) (sdl:key= key :sdl-key-kp-minus)) 
      (zoom-out))
  (if (OR (sdl:key= key :sdl-key-z) (sdl:key= key :sdl-key-kp-plus))
      (zoom-in))
  (if (sdl:key= key :sdl-key-r)
      (reset-matrix))
  (if (sdl:key= key :sdl-key-p)
      (if (= p 0) (incf p) (decf p)))
  (print-matrix matrix row column bsize))

(defun gol-launcher ()
  (sdl:with-init ()
                 (sdl:window width height
                             :resizable t
                             :double-buffer t
                             :title-caption "Carnifex: Game Of Life")
                 (setf (sdl:frame-rate) 60)
                 ; Enable the keyboard repeat rate setting DELAY and INTERVAL to default values of SDL
                 (sdl:enable-key-repeat nil nil)
                 (sdl:with-events ()
                                  (:quit-event () t)
                                  ;; Redraw the screen when it has been modified outside (e.g window manager)
                                  (:video-expose-event ()
                                   (sdl:update-display))
                                  (:key-down-event (:key key)
                                   (handle-key-event key))
                                   ;(when (sdl:key-down-p :sdl-key-escape)
                                   ;  (sdl:push-quit-event)))
                                  (:idle ()
                                   ;(sdl:clear-display (sdl:color))
                                   ;(sdl:draw-box (sdl:rectangle :x 200 :y 250 :w 15 :h 15) :color sdl:*white*)
                                   (when (sdl:mouse-left-p)
                                     ;; Draw the box having a center at the mouse x/y coordinates
                                     (print-box (sdl:mouse-x) (sdl:mouse-y) bsize *white*))
                                   ;; Redraw the display
                                   ;(sdl:update-display)
                                   ;(print (sdl:key-repeat-delay))
                                   ;(print (sdl:key-repeat-interval))
                                   (print-matrix matrix row column bsize)
                                   (gol-algo)
                                   ))))
