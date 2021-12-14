(ns _2021.day13.core
  (:require [clojure.string :as str]))

(def file "src/_2021/day13/input.txt")

(defn parse-line [line]
  (map #(Integer/parseInt %) line))

(defn parse-file [file]
  (let [[dots folds] (-> file
                         (slurp)
                         (str/split #"\n\n")
                         (->> (map str/split-lines)))]
    (vector
     (->> dots
          (mapv #(str/split % #","))
          (mapv parse-line))
     (->> folds
          (map #(str/split % #"="))
          (map #(vector (keyword (str (last (first %)))) (Integer/parseInt (second %))))))))

(def dots (first (parse-file file)))


(defn blank-paper [length height]
  (->> "."
       (repeat)
       (take length)
       (vec)
       (repeat)
       (take height)
       (vec)))

(defn make-paper [dots]
  (let [length (apply max (map first dots))
        height (apply max (map second dots))
        paper (blank-paper (inc length) (inc height))]
    (loop [dots dots
           paper paper]
      (let [dot-pos (reverse (peek dots))]
        (if (empty? dot-pos)
          paper
          (recur (pop dots) (assoc-in paper dot-pos "#")))))))

(defn transpose [xs]
  (apply map list xs))

(defn dot? [char]
  (= "#" char))

(defn hash? [row x]
  (let [char (nth row x)
        old-char (nth row (-  (count row) (inc x)))]
    (if (and (= "#" old-char) (= "." char))
      old-char
      char)))

(defn count-dots [paper]
  (count (filter dot? (flatten paper))))

(defn fold-row [paper row fold-line row-index]
  (loop [x 0
         paper paper]
    (if (>= x (count row))
      paper
      (if (= x fold-line) ;; line gets droped
        (recur (inc x) paper)
        (if (> x fold-line)
          (recur (inc x) (assoc-in paper [row-index (- (count row) (inc x))] (hash? row x)))
          (recur (inc x) (assoc-in paper [row-index x] (nth row x))))))))

(defn fold-paper [paper fold]
  (let [dir (first fold) ;; e.g. :y
        z (second fold) ;; e.g. 7
        new-paper (apply blank-paper
                         (if (= :x dir) [z (count paper)] [z (count (first paper))]))
        ;; Note: we only handle the horizontial fold and tranpose to handle vertical
        paper (if (= :y dir) (transpose paper) paper)]
    (loop [row-index 0
           new-paper new-paper]
      (let [row (nth paper row-index nil)]
        (if (nil? row)
          (if (= :x dir)
            new-paper
            (transpose new-paper))
          (recur (inc row-index) (fold-row new-paper row z row-index)))))))


(count-dots (fold-paper (make-paper dots) (first (second (parse-file file)))))

;; 682

;; part 2

(def folds (second (parse-file file)))

(comment
  (loop [n 0
         paper (make-paper dots)]
    (let [fold (nth folds n nil)]
      (if (nil? fold)
        (println (str/join "\n" (map #(str/join "" %) paper)))
        (recur (inc n) (fold-paper paper fold))))))

;; ####..##...##..#..#.###..####.#..#.####.
;; #....#..#.#..#.#..#.#..#....#.#..#.#....
;; ###..#..#.#....#..#.#..#...#..####.###..
;; #....####.#.##.#..#.###...#...#..#.#....
;; #....#..#.#..#.#..#.#.#..#....#..#.#....
;; #....#..#..###..##..#..#.####.#..#.####.
