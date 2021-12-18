(ns _2021.day17.core
  (:require [clojure.string :as str]))

(def file "src/_2021/day17/input.txt")

(defn parse-line [line]
  (map #(Integer/parseInt %) line))

(defn parse-file [file]
  (-> file
      (slurp)
      (str/split #":")
      (second)
      (str/split #",")
      (->> (map #(str/split % #"="))
           (map second)
           (map #(str/split % #"\.\."))
           (map parse-line)
           (flatten)
           (zipmap [:xmin :xmax :ymin :ymax]))))


(defn v-step [v]
  (let [[vx vy] v]
    [(if (= vx 0) 0 (if (> vx 0) (dec vx) (inc vx))) (dec vy)]))

(defn p-step [pv]
  (let [[p v] pv
        [x y] p
        [vx vy] v]
    [[(+ x vx) (+ y vy)] (v-step v)]))

(defn within-target? [p box]
  (let [[x y] p]
    (and
     (<= (box :xmin) x (box :xmax))
     (<= (box :ymin) y (box :ymax)))))

(defn will-never-hit-target? [p box]
  (let [[x y] p]
    (or
     (> x (box :xmax))
     (< y (box :ymin)))))

(defn steps [initial_v box]
  (let [not-impossible? (fn [pv]
                          (let [[p v] pv]
                            (not (will-never-hit-target? p box))))
        within? (fn [pv]
                  (let [[p v] pv]
                    (within-target? p box)))
        stepping? (fn [pv]
                    (or
                     (within? pv)
                     (not-impossible? pv)))]
    (take-while stepping? (iterate p-step [[0 0] initial_v]))))

(defn will-it-blend? [initial_v box]
  (let [within? (fn [pv]
                  (let [[p v] pv]
                    (within-target? p box)))]
    (within? (last (steps initial_v box)))))

(defn part1-ans [file]
  (let [box (parse-file file)]
    (for [vx (range 0 (inc (box :xmax)))]
      (for [vy (range (box :ymin) (* 2 (box :xmax)))
            :when (will-it-blend? [vx vy] box)]
        [vx vy]))))

;; I just looked for the largest y, #hacks

(comment
  (apply max (map second (map first (steps [17 153] (parse-file file))))))

;; 11781

;; part 2

(comment
  (apply + (map count (remove empty? (part1-ans file)))))

;; 4531
