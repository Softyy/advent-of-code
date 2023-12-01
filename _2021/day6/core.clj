(ns _2021.day6.core
  (:require [clojure.string :as str]))

(def file "src/_2021/day6/input.txt")

(defn parse-file [file]
  (-> file
      (slurp)
      (str/split #",")
      (->> (map #(Integer/parseInt %)))))

(defn process-day [fishes]
  ;; Count fishes that are at 0 and reset fish from 0 to 7
  (let [new-fish-count (count (filter zero? fishes))
        fishes (map #(if (= % 0) 7 %) fishes)]
      ;; Take a day off each fish and add new fish
    (apply conj (map #(- % 1) fishes) (take new-fish-count (repeat 8)))))

(defn count-fish [fishes days]
  (loop [n 1
         fishes fishes]
    (if (> n days)
      (count fishes)
      (recur (inc n) (process-day fishes)))))

(defn part1-answer
  [file]
  (count-fish (parse-file file) 80))

(comment
  (part1-answer file))

;; 373378

;; Part 2 - Math it up, too big for computer comp.

;; Every 7 days, an existing fish produces. So the count looks like
;; Day 1, Count ~ 1 [6]
;; Day 3, Count ~ 1 [4]
;; Day 10, Count ~ 2 [4,6] ~ Day 1 + Day 3
;; Day 13, Count ~2 [1,3]
;; Day 15, Count ~3 [6,1,8]
;; Day 17, Count ~4 [4,6,6,8]
;; Day 22, Count ~5 [6,1,1,3,8] ~ Day 13 + Day 15
;; Day 24, Count ~7 [4,6,6,1,6,8,8] ~ Day 15 + Day 17
;; ...
;; Day N = Day N-7 + Day N-9

(defn count-fish+ [fishes day known-values]
  (if-let [ans (known-values (keyword (str day)))]
    ans
    (if (< day 10)
      (count-fish fishes day)
      (+ (count-fish+ fishes (- day 9) known-values)
         (count-fish+ fishes (- day 7) known-values)))))

(defn count-fish-with-map [fishes days]
  (loop [day 1
         known-values {}]
    (if (> day days)
      (get known-values (keyword (str days)))
      (let [ans (count-fish+ fishes day known-values)]
        (recur (inc day) (merge known-values (hash-map (keyword (str day)) ans)))))))

(defn part2-answer
  [file]
  (count-fish-with-map (parse-file file) 256))

(comment
  (part2-answer file))

;; 1682576647495