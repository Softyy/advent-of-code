(ns _2021.day8.core
  (:require [clojure.string :as str]))

(def file "src/_2021/day9/input.txt")

(defn parse-line [line]
  (map #(Integer/parseInt %) line))

(defn parse-file [file]
  (->> file
       (slurp)
       (str/split-lines)
       (map #(str/split % #""))
       (map parse-line)))

(defn get-height
  "Gets height in grid or nil"
  [x y grid]
  (-> grid
      (nth y [])
      (nth x nil)))

(defn get-neighbour-heights [x y grid]
  (remove nil? [(get-height (dec x) y grid)
                (get-height (inc x) y grid)
                (get-height x (dec y) grid)
                (get-height x (inc y) grid)]))

(defn low-point? [x y grid]
  (let [p (get-height x y grid)
        ns (get-neighbour-heights x y grid)]
    (every? true? (map #(> % p) ns))))

(defn low-points [grid]
  (for [y (range (count grid))]
    (for [x (range (count (nth grid y)))
          :when (low-point? x y grid)]
      [x y])))

(defn part1-answer [file]
  (let [grid (parse-file file)]
    (->> grid
         (low-points)
         (apply concat)
         (map #(apply get-height (conj % grid)))
         (map inc)
         (reduce +))))

(comment
  (part1-answer file))

;; 516

;; Part 2
(defn get-neighbours [x y grid]
  (for [p [[(dec x) y] [(inc x) y] [x (dec y)] [x (inc y)]]
        :when (every? true? ((juxt some? #(not= % 9)) (apply get-height (conj p grid))))]
    p))

(defn calc-area
  "Calc area of basin at x y"
  [x y grid]
  (loop [area 0
         to-visit [[x y]]
         visited #{}]
    (if (empty? to-visit)
      area
      (let [[x y] (peek to-visit)
            ns (get-neighbours x y grid)]
        (if (contains? visited [x y])
          (recur area (pop to-visit) visited)
          (recur (inc area) (apply conj (pop to-visit) ns) (conj visited [x y])))))))

(defn part2-answer [file]
  (let [grid (parse-file file)]
    (->> grid
         (low-points)
         (apply concat)
         (map #(apply calc-area (conj % grid)))
         (sort >)
         (take 3)
         (reduce *))))

(comment
  (part2-answer file))

;;1023660
