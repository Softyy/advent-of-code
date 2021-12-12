(ns _2021.day11.core
  (:require [clojure.string :as str]))

(def file "src/_2021/day11/input.txt")

(defn parse-line [line]
  (mapv #(Integer/parseInt %) line))

(defn parse-file [file]
  (->> file
       (slurp)
       (str/split-lines)
       (mapv #(str/split % #""))
       (mapv parse-line)))

(defn get-octo [p grid]
  (let [[x y] p]
    (nth (nth grid y []) x nil)))

(defn increment-all [grid]
  (mapv #(mapv inc %) grid))

(defn flash? [p grid]
  (> (get-octo p grid) 9))

(defn reset [octo-val]
  (if (> octo-val 9) 0 octo-val))

(defn reset-octos [grid]
  (mapv #(mapv reset %) grid))

(defn get-neighbours [p grid]
  (let [[x y] p]
    (apply list
           (apply concat
                  (for [dy (range -1 2)]
                    (for [dx (range -1 2)
                          :let [_x (+ x dx)
                                _y (+ y dy)]
                          :when (get-octo [_x _y] grid)]
                      [_x _y]))))))

(defn flash-octo [p grid]
  (loop [grid grid
         to-inc (get-neighbours p grid)]
    (if (empty? to-inc)
      grid
      (let [[x y] (peek to-inc)]
        (recur (update-in grid [y x] inc) (pop to-inc))))))

(defn octo-to-flash [grid already-flashed]
  (vec
   (apply concat
          (for [y (range (count grid))]
            (for [x (range (count (nth grid y)))
                  :when (and (flash? [x y] grid) (not (contains? already-flashed [x y])))]
              [x y])))))

(defn process-step [grid]
  (let [grid (increment-all grid)]
    (loop [grid grid
           already-flashed #{}
           to-flash (octo-to-flash grid already-flashed)
           flashes 0]
      (if (empty? to-flash)
        [(reset-octos grid) flashes]
        (let [p (peek to-flash)
              already-flashed (conj already-flashed p)
              flashed-grid (flash-octo p grid)]
          (recur flashed-grid already-flashed (octo-to-flash flashed-grid already-flashed) (inc flashes)))))))

;; Note, I had issue with the data types and needed to cast everything to a vec? should fix.

(defn part1-answer [grid steps]
  (loop [grid grid
         step 0
         flashes 0]
    (if (= step steps)
      flashes
      (let [[new-grid new-flashes] (process-step grid)]
        (recur new-grid (inc step) (+ flashes new-flashes))))))
(comment
  (part1-answer (parse-file file) 100))

;; 1673

(defn part2-answer [grid]
  (let [octo-count (* (count (nth grid 0)) (count grid))]
    (loop [grid grid
           step 0
           flashes 0]
      (let [[new-grid new-flashes] (process-step grid)]
        (if (= new-flashes octo-count)
          (inc step)
          (recur new-grid (inc step) (+ flashes new-flashes)))))))

(comment
  (part2-answer (parse-file file)))

;; 279