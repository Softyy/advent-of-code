(ns _2021.day12.core
  (:require [clojure.string :as str]))

(def file "src/_2021/day12/input.txt")

(defn parse-file [file]
  (->> file
       (slurp)
       (str/split-lines)
       (mapv #(str/split % #"-"))))

(def paths (parse-file file))

(defn in?
  [coll elm]
  (some #(= elm %) coll))

(defn end? [node]
  (= "end" node))

(defn is-large-cave? [node]
  (some #(Character/isUpperCase %) node))

(defn is-small-cave? [node]
  (not (is-large-cave? node)))

(defn exits
  "Get the ways out of a given node"
  [node current-path paths]
  (->> paths
       (filter #(in? % node))
       (flatten)
       (remove #(= % node))
       (remove #(and (is-small-cave? %) (in? current-path %)))))

(defn get-paths []
  (let [all-paths paths]
    (loop [paths [["start"]]
           finished-paths []]
      (let [current-path (peek paths)
            node (peek current-path)]
        (if (nil? current-path)
          finished-paths
          (if (end? node)
            (recur (pop paths) (conj finished-paths current-path))
            (if-let [new-nodes (exits node current-path all-paths)]
              (recur (apply conj (pop paths) (map #(conj current-path %) new-nodes)) finished-paths)
              (recur (pop paths) finished-paths))))))))

(comment
  (time (count (get-paths))))

;; 4775

;; part 2

(defn has-double-small-cave? [path]
  (> (apply max (vals (frequencies (remove is-large-cave? path)))) 1))

(defn start? [node]
  (= "start" node))

(defn exits-v2
  "Get the ways out of a given node"
  [node current-path paths]
  (as-> paths p
    (filter #(in? % node) p)
    (flatten p)
    (remove #(= % node) p)
    (if (has-double-small-cave? current-path)
      (remove #(and (is-small-cave? %) (in? current-path %)) p)
      (remove start? p))))

(defn get-paths-v2 []
  (let [all-paths paths]
    (loop [paths [["start"]]
           finished-paths []]
      (let [current-path (peek paths)
            node (peek current-path)]
        (if (nil? current-path)
          finished-paths
          (if (end? node)
            (recur (pop paths) (conj finished-paths current-path))
            (if-let [new-nodes (exits-v2 node current-path all-paths)]
              (recur (apply conj (pop paths) (map #(conj current-path %) new-nodes)) finished-paths)
              (recur (pop paths) finished-paths))))))))

(comment
  (time (count (get-paths-v2))))

;; 152480
