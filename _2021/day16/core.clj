(ns _2021.day16.core
  (:require [clojure.string :as str]))

(def file "src/_2021/day16/example.txt")

(defn b->int [s]
  (Integer/parseInt (str/join "" s) 2))

(defn hex->b_str [h]
  (let [int (Integer/parseInt (str h) 16)
        num-of-zeros (- (Integer/numberOfLeadingZeros int) 28)
        leading-zeros (str/join "" (take num-of-zeros (repeat "0")))]
    (if (= int 0)
      leading-zeros
      (str/join [leading-zeros (Integer/toBinaryString int)]))))

(defn parse-file [file]
  (->> file
       (slurp)
       (map hex->b_str)
       (apply concat)))

(defn packet-version [b]
  (b->int (take 3 b)))

(defn packet-type [b]
  (b->int (take 3 (drop 3 b))))

;; packet-type =  4 represents a literal value (use the read-literal func)
;; packet-type != 4 represents an operator

(defn length-type-id
  "For operator packet types: returns 1 or 0"
  [b]
  (b->int (take 1 (drop 6 b))))

;; Note: length-type-id = 0 => 15 bit number of the number of bits in a sub-packet
;; Note: length-type-id = 1 => 11 bit number of the count of sub-packets

(defn read-literal [b]
  (loop [b b
         len 6
         literal []]
    (let [leading-bit (first b)
          len (+ len 5)
          new-literal (conj literal (take 4 (drop 1 b)))]
      (if (= leading-bit \0)
        (let [bits (flatten new-literal)]
          [len (b->int bits)])
        (recur (drop 5 b) len new-literal)))))

(defn length-of-packets [ps]
  (apply + (map :len ps)))

(defn read-packet [b]
  (let [version (packet-version b)
        type-id (packet-type b)
        length-id (length-type-id b)]
    (if (= type-id 4)
      (let [[packet-len packet-val] (read-literal (drop 6 b))]
        {:val packet-val, :version version, :len packet-len, :type "literal" :b b})
      ;; need to go deeper
      (extract-packets (drop 7 b)))))
      ;;{:val nil, :version version, :len (count b), :type (if (= length-id 0) "bits" "count"), :b b})))

(defn bit-op [b]
  (let [total-size (b->int (take 15 b))
        b (drop 15 b)]
    (loop [packets []]
      (let [packet-lens (length-of-packets packets)]
        (if (= packet-lens total-size)
          packets
          (recur (conj packets (read-packet (take total-size (drop packet-lens b))))))))))

(defn packet-op [b]
  (let [num-of-packets (b->int (take 11 b))
        b (drop 11 b)]
    (loop [packets []]
      (let [packet-count (count packets)
            packet-lens (length-of-packets packets)
            remaining-b (drop packet-lens b)]
        (if (or (= packet-count num-of-packets) (empty? remaining-b))
          packets
          (recur (conj packets (read-packet remaining-b))))))))

(defn extract-packets [b]
  (loop [unread [(read-packet b)]
         read []]
    (let [packet (peek unread)]
      (if (empty? packet)
        read
        (if (int? (packet :val))
          (recur (pop unread) (conj read packet))
          (let [b (drop 7 (packet :b))
                new-packets (if (= (packet :type) "bits") (bit-op b) (packet-op b))
                operators (filter #(nil? (% :val)) new-packets)
                literals (filter #(not (nil? (% :val))) new-packets)]
            (recur (apply conj (pop unread) operators) (flatten (conj read packet literals)))))))))

(defn sum-versions [b]
  (->> b
       (extract-packets)
       (map :version)
       (apply +)))


(extract-packets (parse-file file))
(bit-op (drop 7 (parse-file file)))


(sum-versions (parse-file file))

