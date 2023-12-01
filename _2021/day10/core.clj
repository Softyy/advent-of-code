(ns _2021.day10.core
  (:require [clojure.string :as str]))

(def file "src/_2021/day10/input.txt")

(defn parse-file [file]
  (->> file
       (slurp)
       (str/split-lines)
       (map #(str/split % #""))))

(defn open-brac? [brac]
  (or
   (= brac "(")
   (= brac "[")
   (= brac "<")
   (= brac "{")))

(defn closure [b1 b2]
  (cond
    (= b1 "(") (= b2 ")")
    (= b1 "[") (= b2 "]")
    (= b1 "<") (= b2 ">")
    (= b1 "{") (= b2 "}")
    :else false))

(defn illegal-brac [brac stack]
  (let [last-brac (peek stack)]
    (not (closure last-brac brac))))

(defn illegal-char-on-line [line]
  (loop [brac (first line)
         line (next line)
         stack []]
    (if (nil? brac)
      nil ;; nothing is wrong
      (if (open-brac? brac)
        (recur (first line) (next line) (conj stack brac)) ;; keep going
        (if (illegal-brac brac stack)
          brac ;; illegal!!
          (recur (first line) (next line) (pop stack)))))))

(defn score [b]
  (cond
    (= b ")") 3
    (= b "]") 57
    (= b "}") 1197
    (= b ">") 25137
    :else 0))

(defn part1-answer [lines]
  (->> lines
       (map illegal-char-on-line)
       (map score)
       (reduce +)))

(part1-answer (parse-file file))

;; 387363

;; Part 2

(defn close-brac [b]
  (cond
    (= b "(") ")"
    (= b "[") "]"
    (= b "{") "}"
    (= b "<") ">"
    :else nil))

(defn score-v2 [b]
  (cond
    (= b ")") 1
    (= b "]") 2
    (= b "}") 3
    (= b ">") 4
    :else 0))

(defn score-reducer [acc score]
  (+ (* 5 acc) score))

(defn score-autocomplete [bracs]
  (reduce score-reducer 0 (map score-v2 bracs)))

(defn autocomplete-line
  "Assumes it's valid"
  [line]
  (loop [brac (first line)
         line (next line)
         stack []]
    (if (nil? brac)
      (map close-brac (reverse stack))
      (if (open-brac? brac)
        (recur (first line) (next line) (conj stack brac))
        (recur (first line) (next line) (pop stack))))))

(defn middle [v]
  (nth v (quot (count v) 2)))

(defn part2-answer [lines]
  (middle
   (->> lines
        (remove #(not (nil? (illegal-char-on-line %))))
        (map autocomplete-line)
        (map score-autocomplete)
        (sort))))

(part2-answer (parse-file file))

;; 4330777059
