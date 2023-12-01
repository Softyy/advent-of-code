(ns _2021.day14.core
  (:require [clojure.string :as str]))

(def file "src/_2021/day14/input.txt")

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

;; Too slow, let's expand rules to give the new pairs and use frequencies :/

(defn template-pairer
  "Gets a hashmap of the poly pairs with their counts of a template"
  [template]
  (frequencies
   (for [n (range 1 (count template))]
     (str/join "" [(nth template (dec n)) (nth template n)]))))

(defn rule-smasher
  "Converts the hashmap of rules vals to return the hashmap of new poly counts"
  [rules]
  (into (hash-map)
        (for [[k v] rules]
          (let [[p1 p2] k]
            {k (frequencies [(str p1 v) (str v p2)])}))))

(defn score-v2 [template]
  (let [polys (apply merge-with +
                     (for [[k v] template]
                       (merge-with + {(first k) v} {(second k) v})))
        max-poly (apply max (vals polys))
        min-poly (apply min (vals polys))]
    (/ (inc (- max-poly min-poly)) 2)))

(defn parse-file-v2 [file]
  (let [[template rules] (parse-file file)]
    (vector
     (template-pairer template)
     (rule-smasher rules))))

(defn remap [m f]
  (reduce (fn [r [k v]] (assoc r k (f v))) {} m))

(defn *vals [m d]
  (remap m (fn [x] (* d x))))

(defn process-step-v2 [template rules]
  (apply merge-with +
         (for [[k v] template]
           (if-let [rule (rules k)]
             (*vals rule v)
             (v)))))

(defn part2-ans [file]
  (let [data (parse-file-v2 file)
        rules (second data)]
    (loop [counter 0
           template (first data)]
      (if (= counter 40)
        (score-v2 template)
        (recur (inc counter) (process-step-v2 template rules))))))

(part2-ans file)

;; 2651311098752
