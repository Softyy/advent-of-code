(ns _2021.day7.core
  (:require [clojure.string :as str]))

(def file "src/_2021/day7/input.txt")

(defn parse-file [file]
  (-> file
      (slurp)
      (str/split #",")
      (->> (map #(Integer/parseInt %)))))

(defn fuel-to-pos [pos crabs]
  (apply + (map #(Math/abs (- % pos)) crabs)))

(defn min-fuel [crabs]
  (apply min (map #(fuel-to-pos % crabs) (range (apply max crabs)))))

(min-fuel (parse-file file))

;; 336120 

;; Part 2

;; Math fact: n + n-1 + n-2 + ... + 3 + 2 + 1 = n(n + 1)/2

(defn integer-sum [n]
  (/ (* n (inc n)) 2))

(defn fuel-to-pos-v2 [pos crabs]
  (apply + (map #(integer-sum (Math/abs (- % pos))) crabs)))

(defn min-fuel-v2 [crabs]
  (apply min (map #(fuel-to-pos-v2 % crabs) (range (apply max crabs)))))

(min-fuel-v2 (parse-file file))

;; 96864235
