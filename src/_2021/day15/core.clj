(ns _2021.day15.core
  (:require [clojure.string :as str]))

(def file "src/_2021/day15/input.txt")

(defn parse-line [line]
  (map #(Integer/parseInt %) line))

(defn parse-file [file]
  (->> file
       (slurp)
       (str/split-lines)
       (map #(str/split % #""))
       (mapv parse-line)))

(defn zero-grid [length height]
  (->> 0
       (repeat)
       (take length)
       (vec)
       (repeat)
       (take height)
       (vec)))

(defn minn [a b]
  (let [c (remove nil? [a b])
        start? (empty? c)]
    (if start? 0 (apply min c))))

(defn risk-score [grid]
  (let [length (count (first grid))
        height (count grid)
        risks (zero-grid length height)]
    (loop [y 0
           x 0
           risks risks]
      (let [above-risk (nth (nth risks (dec y) []) x nil)
            left-risk (nth (nth risks  y []) (dec x) nil)
            cur-risk (nth (nth grid  y []) x 0)
            lowest-risk (minn above-risk left-risk)
            new-risk (+ cur-risk lowest-risk)]
        (if (= y height)
          (- (last (last risks)) (ffirst  grid))
          (if (= (inc x) length)
            (recur (inc y) 0 (assoc-in risks [y x] new-risk))
            (recur y (inc x) (assoc-in risks [y x] new-risk))))))))

(comment
  (risk-score (parse-file file)))

;; 613


;; part 2

(defn wrap [risk n]
  (let [new-risk (+ risk n)
        mod-risk (mod new-risk 9)]
    (if (> new-risk 9)  (if (= 0 mod-risk) 9 mod-risk) new-risk)))

(defn %grid [grid x]
  (mod x (count grid)))

(defn ghost-nth [grid x y]
  (let [v (nth (nth grid (mod x (count (first grid))) []) (mod y (count grid)) 0)
        n (+ (quot x (count grid)) (quot y (count grid)))]
    (wrap v n)))

(defn risk-score-v2 [grid]
  (let [length (* 5 (count (first grid)))
        height (* 5 (count grid))
        risks (zero-grid length height)]
    (loop [y 0
           x 0
           risks risks]
      (let [above-risk (nth (nth risks (dec y) []) x nil)
            left-risk (nth (nth risks  y []) (dec x) nil)
            cur-risk  (ghost-nth grid x y)
            lowest-risk (minn above-risk left-risk)
            new-risk (+ cur-risk lowest-risk)]
        (if (= y height)
          (- (last (last risks)) (ffirst grid))
          (if (= (inc x) length)
            (recur (inc y) 0 (assoc-in risks [y x] new-risk))
            (recur y (inc x) (assoc-in risks [y x] new-risk))))))))

(comment
  (risk-score-v2 (parse-file file)))
