(ns _2021.day4.core
  (:require [clojure.string :as str]))

(def file "src/_2021/day4/input.txt")

(defn parse-file [file]
  (-> file
      (slurp)
      (str/split #"\n\n")
      (->> (map str/split-lines))))

(defn transpose [xs]
  (apply map list xs))

(def numbers
  (-> file
      (parse-file)
      (ffirst)
      (str/split #",")
      (->> (map #(Integer/parseInt %)))))

(defn format-card [card]
  (for [row card]
    (->> (str/split row #" ")
         (remove #(= (count %) 0))
         (map #(Integer/parseInt %)))))

(def cards
  (->> file
       (parse-file)
       (drop 1)
       (map format-card)))

(defn in?
  [coll elm]
  (some #(= elm %) coll))

(defn sum-without-called-numbers [card numbers]
  (->> card
       (flatten)
       (filter #(not (in? numbers %)))
       (reduce +)))

(defn row-marked [row numbers]
  (every? true? (map #(in? numbers %) row)))

(defn bingo? [card numbers]
  (some?
   (or
    (some true? (map #(row-marked % numbers) card))
    (some true? (map #(row-marked % numbers) (transpose card))))))

(defn part1-answer [cards numbers]
  (loop [num (first numbers)
         nums [num]
         numbers numbers]
    (let [ans (loop [cards cards]
                (let [card (first cards)]
                  (if (nil? cards)
                    nil
                    (if (bingo? card nums)
                      (* num (sum-without-called-numbers card nums))
                      (recur (next cards))))))]
      (if (some? ans)
        ans
        (recur (first numbers) (conj nums (first numbers)) (next numbers))))))

(part1-answer cards numbers)

;; 44736

;; Part 2

(defn part2-answer [cards numbers]
  (loop [num (first numbers)
         nums [num]
         numbers numbers
         cards cards]
    (let [losing-cards (filter #(not (bingo? % nums)) cards)]
      (if (= (count losing-cards) 0)
        (* num (sum-without-called-numbers (first cards) nums))
        (recur (first numbers) (conj nums (first numbers)) (next numbers) losing-cards)))))

(part2-answer cards numbers)

;; 1827
