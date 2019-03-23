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

(defun calculate-v (bool)
  (if (equal bool 'true)
      (if (>= v 20)
          (setf v (+ v *speed*)))
      (if (<= v 100)
          (setf v (- v *speed*)))))

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
  (if (OR (sdl:key= key :sdl-key-v) (sdl:key= key :sdl-key-greater))
      (calculate-v 'true)
      ;(format t "~%v= ~d~%" v)
      )
  (if (OR (sdl:key= key :sdl-key-c) (sdl:key= key :sdl-key-less))
      (calculate-v 'nil)
      ;(format t "~%v= ~d~%" v)
      )
  (if (sdl:key= key :sdl-key-r)
      (progn
        (reset-matrix)
        (setf p 1)))
  (if (sdl:key= key :sdl-key-p)
      (if (= p 1) (decf p) (incf p)))
  (print-matrix matrix row column bsize))

(defun handle-mouse-event (button)
  (if (= button 4) ; When down
      (if (or (sdl:key-down-p :sdl-key-lshift)
              (sdl:key-down-p :sdl-key-rshift))
          (calculate-v 'nil) ; shifted
          (zoom-out)))
  (if (= button 5) ; When up
      (if (or (sdl:key-down-p :sdl-key-lshift)
              (sdl:key-down-p :sdl-key-rshift))
          (calculate-v 'true) ; shifted
          (zoom-in)))
  (if (= button 1)
      (progn
        (setf last-x 0)
        (setf last-y 0)))
  )

(defun mouse-event-handler ()
  (if (sdl:mouse-left-p)
      (progn
        (if (or (sdl:key-down-p :sdl-key-lctrl)
                (sdl:key-down-p :sdl-key-rctrl))
            (progn
              (if (and (eq last-x 0)
                       (eq last-y 0))
                  (progn
                    (setf last-x (sdl:mouse-x))
                    (setf last-y (sdl:mouse-y)))
                  (progn
                    (let*
                      ((x (sdl:mouse-x))
                       (y (sdl:mouse-y)))
                      (setf xn (+ xn (- x last-x)))
                      (setf yn (+ yn (- y last-y)))
                      (setf last-x x)
                      (setf last-y y)))))
            (let ((i (floor (- (sdl:mouse-x) xn)
                            bsize))
                  (j (floor (- (sdl:mouse-y) yn)
                            bsize)))
              (if (equal (and (>= i 0)
                              (< i row)
                              (>= j 0)
                              (< j column)) T)
                  (setf (aref matrix i j) 1))))))
  (if (sdl:mouse-right-p)
      (let
        ((i (floor (- (sdl:mouse-x) xn)
                   bsize))
         (j (floor (- (sdl:mouse-y) yn)
                   bsize)))
        (if (equal (and (>= i 0)
                        (< i row)     ; Global y
                        (>= j 0)
                        (< j column)) t) ; Global x
            (setf (aref matrix i j)
                  0))))
  (print-matrix matrix column row bsize))

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
                                  (:mouse-button-up-event (:button button)
                                   (handle-mouse-event button))
                                  (:key-down-event (:key key)
                                   (handle-key-event key))
                                  ;(when (sdl:key-down-p :sdl-key-escape)
                                  ;  (sdl:push-quit-event)))
                                  (:idle ()
                                   ;(when (sdl:mouse-left-p)
                                   ;; Draw the box having a center at the mouse x/y coordinates
                                   ;(print-box (sdl:mouse-x) (sdl:mouse-y) bsize *white*))
                                   ;; Redraw the display
                                   ;(sdl:update-display)
                                   (mouse-event-handler)
                                   ;(print-matrix matrix row column bsize)
                                   (if (eq p 0)
                                       (progn
                                         (setf curr-time (get-internal-run-time))
                                         (let ((time-wait (- last-time (- curr-time v))))
                                           (if (> time-wait 0)
                                               (sleep (/ time-wait 100))))
                                         (gol-algo)
                                         (setf last-time curr-time)))
                                   ))))
