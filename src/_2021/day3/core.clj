(ns _2021.day3.core)
(require '[clojure.string :as str])

(def data (map #(str/split % #"") (str/split (slurp "src/_2021/day3/input.txt") #"\n")))

(defn transpose [xs]
  (apply map list xs))

(defn most-common
  [x]
  (->> x
       frequencies
       (sort-by val >)))

(defn b->i [b]
  (Integer/parseInt b 2))

(def gamma_list (for [col (transpose data)]
                  (first (first (most-common col)))))

(def epsilon_list (for [bit gamma_list]
                    (if (= bit "1") "0" "1")))

(* (b->i (str/join "" gamma_list)) (b->i (str/join "" epsilon_list)))

;; 4103154

;; Part 2
