import nimneural.neuralnet

let options = newNeuralNetMeta(64, 64, 3, 16)
var net = newNeuralNet(options)

let n = createNet(net)
echo $n

for j in 0 .. <n.layers.len:
  for z in 0 .. <n.layers[j].neurons.len:
    for i in 0 .. <n.layers[j].neurons[z].weights.len:
      echo $n.layers[j].neurons[z].weights[i]
