(ns _2021.day1.core)
(require '[clojure.string :as str])

(def data (map #(Integer/parseInt %) (str/split (slurp "src/_2021/day1/input.txt") #"\n")))

;; Part 1

(reduce + (for [n (range 1 (count data))]
            (if (> (nth data n) (nth data (- n 1))) 1 0)))
;; # 1298

;; Part 2

(reduce + (for [n (range 3 (count data))]
            (if (> (+ (nth data n) (nth data (- n 1)) (nth data (- n 2)))
                   (+ (nth data (- n 1)) (nth data (- n 2)) (nth data (- n 3)))) 1 0)))

;; 1248
