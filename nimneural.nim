import nimneural.neuralnet
import nimneural.GenAlg

let alg = newGenAlg(100, 20, 0.3, 0.7)

let s = alg.epoch(alg.population)

for i in s:
  echo s
