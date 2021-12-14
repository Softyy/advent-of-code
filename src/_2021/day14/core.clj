(ns _2021.day14.core
  (:require [clojure.string :as str]))

(def file "src/_2021/day14/input.txt")

(defn parse-line [line]
  (map #(Integer/parseInt %) line))

(defn parse-file [file]
  (let [[template rules] (-> file
                             (slurp)
                             (str/split #"\n\n")
                             (->> (map str/split-lines)))]
    (vector
     (-> template
         first
         (str/split #""))
     (->> rules
          (map #(str/split % #" -> "))
          (into (hash-map))))))

(defn process-step [template rules]
  (loop [n 1
         new-template [(first template)]]
    (let [cur-poly (nth template n nil)
          last-poly (nth template (dec n))
          combo-poly (str last-poly cur-poly)
          insertion (rules combo-poly)]
      (if (nil? cur-poly)
        new-template
        (if (nil? insertion)
          (recur (inc n) (conj new-template cur-poly))
          (recur (inc n) (conj new-template insertion cur-poly)))))))


(defn score [template]
  (let [freq (frequencies template)
        max-poly (apply max (vals freq))
        min-poly (apply min (vals freq))]
    (- max-poly min-poly)))


(defn part1-ans [file]
  (let [data (parse-file file)
        rules (second data)]
    (loop [counter 0
           template (first data)]
      (if (= counter 10)
        (score template)
        (recur (inc counter) (process-step template rules))))))


(part1-ans file)

;; 2408

;; part 2

(defn part2-ans [file]
  (let [data (parse-file file)
        rules (second data)]
    (loop [counter 0
           template (first data)]
      (if (= counter 40)
        (score template)
        (recur (inc counter) (process-step template rules))))))

;; Too slow :/