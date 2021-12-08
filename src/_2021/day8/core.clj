(ns _2021.day8.core
  (:require [clojure.string :as str])
  (:require [clojure.set :as set]))

(def file "src/_2021/day8/input.txt")

(defn parse-line [line]
  (map #(str/split % #" ") line))

(defn parse-file [file]
  (-> file
      (slurp)
      (str/split-lines)
      (->> (map #(str/split % #" \| "))
           (map parse-line))))

(defn one-four-seven-or-eight? [s]
  (let [segments (count s)]
    (or (= segments 2) (= segments 3) (= segments 4) (= segments 7))))

(defn part1-answer [file]
  (loop [lines (parse-file file)
         line (first lines)
         counter 0]
    (if (nil? line)
      counter
      (recur (next lines)
             (second lines)
             (+ counter (count (filter one-four-seven-or-eight? (second line))))))))

(comment
  (part1-answer file))

;; 539

;; Part 2

;; Note: 1 = (len 2)
;;       7 = (len 3)
;;       4 = (len 4)
;;       3 = (len 5) + contains 1
;;       5 = (len 5) + (5 /int 4 ~ count 3)
;;       2 = (len 5) + (5 /int 4 ~ count 2)
;;       0 = (len 6) + contains 1
;;       9 = (len 6) + contains 4
;;       6 = (len 6) + not 0 or not 9

(defn in?
  [coll elm]
  (some #(= elm %) coll))

(defn all-in? [s1 s2]
  (every? true? (map #(in? s2 %) s1)))

(defn count-overlap [s1 s2]
  (count (filter #(in? s2 %) s1)))

(defn sort-by-alpha [s]
  (str/join "" (sort (str/split s #""))))

(defn find-value [coded-val known-vals]
  (let [coded-val (sort-by-alpha coded-val)]
    (cond
      (= (count coded-val) 2) {:1 coded-val}
      (= (count coded-val) 3) {:7 coded-val}
      (= (count coded-val) 4) {:4 coded-val}
      (and (= (count coded-val) 5) (all-in? (known-vals :1) coded-val)) {:3 coded-val}
      (and (= (count coded-val) 5) (= (count-overlap (known-vals :4) coded-val) 3)) {:5 coded-val}
      (and (= (count coded-val) 5) (= (count-overlap (known-vals :4) coded-val) 2)) {:2 coded-val}
      (and (= (count coded-val) 6) (all-in? (known-vals :4) coded-val)) {:9 coded-val}
      (and (= (count coded-val) 6) (all-in? (known-vals :1) coded-val)) {:0 coded-val}
      (= (count coded-val) 6) {:6 coded-val}
      :else {(keyword "8") coded-val})))

(defn get-decoder
  [coded-vals]
  (loop [coded-vals (sort-by count coded-vals)
         known-vals {}]
    (if (nil? coded-vals)
      known-vals
      (let [new-value (find-value (first coded-vals) known-vals)]
        (recur (next coded-vals) (merge known-vals new-value))))))

(defn part2-answer [file]
  (loop [lines (parse-file file)
         line (first lines)
         counter 0]
    (if (nil? line)
      counter
      (let [decoder (get-decoder (first line))
            flipped-decoder (set/map-invert decoder)]
        (recur (next lines)
               (second lines)
               (+ counter (Integer/parseInt (apply str (map #(name (flipped-decoder (sort-by-alpha %))) (second line))))))))))

(comment
  (part2-answer file))

;; 1084606