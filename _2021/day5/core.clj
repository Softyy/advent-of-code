(ns _2021.day5.core
  (:require [clojure.string :as str]))

(def file "src/_2021/day5/input.txt")

(defn list-int-parse [coll]
  (map #(Integer/parseInt %) coll))

(defn parse-line [line]
  (->> line
       (map #(str/split % #","))
       (map list-int-parse)))

(defn parse-file [file]
  (->> file
       (slurp)
       (str/split-lines)
       (map #(str/split % #" -> "))
       (map parse-line)))

(defn point-key
  "Hash key don't take tuples? Ask Russ/Ryan about it?"
  [p]
  (let [[x y] p]
    (str x "-" y)))

(defn filter-line
  "Return `True` if line is vertical or horiztonal"
  [line]
  (let [[p1 p2] line
        [x1 y1] p1
        [x2 y2] p2]
    (or
     (= x2 x1)
     (= y2 y1))))

(defn add-one-to-last [coll]
  (let [n1 (first coll)
        n2 (last coll)]
    (list n1 (+ 1 n2))))

(defn get-line-points [line]
  (let [[p1 p2] line
        [x1 y1] p1
        [x2 y2] p2]
    (if (= x1 x2)
      (apply merge (map #(hash-map (keyword %) 1) (map point-key (map #(list x1 %) (apply range (add-one-to-last (sort [y1 y2])))))))
      (apply merge (map #(hash-map (keyword %) 1) (map point-key (map #(list % y1) (apply range (add-one-to-last (sort [x1 x2]))))))))))

(defn part1-answer [file]
  (let [lines (filter filter-line (parse-file file))]
    (loop [line (first lines)
           lines (next lines)
           grid {}]
      (if (nil? line)
        (count (filter #(> (val %) 1) grid))
        (let [new-grid (merge-with + grid (get-line-points line))]
          (recur (first lines) (next lines) new-grid))))))

(comment
  (part1-answer file))

;; 5167

(defn full-range
  "When range is not enough, go for range+ !!!"
  [start & {:keys [to]}]
  (cond (nil? to) (range (inc start))
        :else (if (> to start)
                (range start (inc to))
                (range start (dec to) -1))))

(defn zip [& colls]
  (partition (count colls) (apply interleave colls)))

(defn get-line-points-v2 [line]
  (let [[p1 p2] line
        [x1 y1] p1
        [x2 y2] p2]
    (if (and (not= x1 x2) (not= y1 y2))
      (apply merge (map #(hash-map (keyword %) 1) (map point-key (zip (full-range x1 :to x2) (full-range y1 :to y2)))))
      (if (= x1 x2)
        (apply merge (map #(hash-map (keyword %) 1) (map point-key (map #(list x1 %) (apply range (add-one-to-last (sort [y1 y2])))))))
        (apply merge (map #(hash-map (keyword %) 1) (map point-key (map #(list % y1) (apply range (add-one-to-last (sort [x1 x2])))))))))))

(defn part2-answer [file]
  (let [lines (parse-file file)]
    (loop [line (first lines)
           lines (next lines)
           grid {}]
      (if (nil? line)
        (count (filter #(> (val %) 1) grid))
        (let [new-grid (merge-with + grid (get-line-points-v2 line))]
          (recur (first lines) (next lines) new-grid))))))

(comment
  (part2-answer file))

;; 17604