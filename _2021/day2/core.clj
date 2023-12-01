(ns _2021.day2.core)
(require '[clojure.string :as str])

(def data (for [v (map #(str/split % #" ")
                       (str/split (slurp "src/_2021/day2/input.txt") #"\n"))] [(first v) (Integer/parseInt (second v))]))

(def horz ["forward"])
(def vert ["up" "down"])

;; Part 1

(def deltas (for [v data]
              [(if (some (partial = (first v)) horz)
                 (second v)
                 0)
               (if (some (partial = (first v)) vert)
                 (if (= (first v) "up")
                   (- (second v))
                   (second v)) 0)]))


(reduce * (apply map + deltas))

;; 2070300

;; Part 2

(defn calc [acc item]
  (let [[dist_delta aim_delta] item
        [pos aim] acc
        [dist depth] pos]
    (if (= dist_delta 0)
      [[dist depth] (+ aim aim_delta)]
      [[(+ dist dist_delta) (+ depth (* aim dist_delta))] aim])))


(reduce * (first (reduce calc [[0 0] 0] deltas)))


;; 2078985210