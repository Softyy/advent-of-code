(ns _2021.day3.core
  (:require [clojure.string :as str]))

(def file "src/_2021/day3/input.txt")

(defn parse-file [file]
  (->> file
       (slurp)
       (str/split-lines)
       (map #(str/split % #""))))

(defn transpose [xs]
  (apply map list xs))

(defn b_list->i [b_list]
  (Integer/parseInt (str/join "" b_list) 2))

(defn most-common [x]
  (let [freqs (sort-by val > (frequencies x))]
    (if (apply = (vals freqs))
      "1"
      (ffirst freqs))))

(defn flip-bits [x]
  (map #(if (= % "1") "0" "1") x))

(defn get-gamma [file]
  (->> file
       (parse-file)
       (transpose)
       (map most-common)))

(defn part1-answer [file]
  (let [gamma (get-gamma file)]
    ;; fliping the bits of gamma ~ epsilon 
    (->> [gamma (flip-bits gamma)]
         (map b_list->i)
         (apply *))))

(comment
  (part1-answer file))

;; 4103154

;; Part 2

(defn least-common [x]
  (let [freqs (sort-by val < (frequencies x))]
    (if (apply = (vals freqs))
      "0"
      (ffirst freqs))))

(defn get-value-via-selector [file selector]
  (loop [items (parse-file file)
         idx 0]
    (if (= (count items) 1)
      (first items) ;; return value
      (let [bit (selector (nth (transpose items) idx))]
        (recur (filter #(= (nth % idx) bit) items) (+ idx 1))))))

(defn part2-answer [file]
  (let [oxygen (get-value-via-selector file most-common)
        co2 (get-value-via-selector file least-common)]
    (->> [oxygen co2]
         (map #(str/join "" %))
         (map b_list->i)
         (apply *))))

(comment
  (part2-answer file))

;; 4245351
