from strutils import `%`
include types

proc `$`*(net: NeuralNetRef): string = 
  "[$1] | [$2] | [$3] | [$4]" % [$net.meta.numInputs, $net.meta.numOutputs, $net.meta.numHiddenLayers,  $net.meta.numNeuronsPerHiddenLayer]

proc createNet*(net: NeuralNetRef): NeuralNetRef = 
  #[
  # Initialises the neural network
  ]#
  new(result)
  result.meta = net.meta
  result.layers = @[]

  #Build our hidden layers
  for i in 0 .. <net.meta.numHiddenLayers:
    #Add a new hidden layer to the net. Auto initialises weights and neurons
    result.layers.add(newNeuronLayer(numNeurons=net.meta.numNeuronsPerHiddenLayer, net.meta.numInputs))
    echo "Added Number $1" % [$i]
  echo "Results.layers len: $1" % [$result.layers.len]

proc getWeights*(net: NeuralNetRef): seq[WeightRef] = 
  #Outer layer of Neuron Layers
  for outer_neuron_layer in net.layers:
    for neuron in outer_neuron_layer.neurons: 
      for weight in neuron.weights:
        result.add(weight)

proc getNumberOfWeights*(net: NeuralNetRef): int =
  result = 0

  #Outer layer of Neuron Layers
  for outer_neuron_layer in net.layers:
    for neuron in outer_neuron_layer.neurons: 
      for weight in neuron.weights:
        result.inc

proc putWeights(net: NeuralNetRef, weights: openarray[float64]): NeuralNetRef =
  shallowCopy(result, net)

  var weightCount = 0

  for ix, outer_neuron_layer in net.layers.pairs():
    for jx, neuron in outer_neuron_layer.neurons.pairs(): 
      for zx, weight in neuron.weights.pairs():
        echo zx
        #result.layers[ix].neurons[jx].weights[zx] = weight[weightCount]
        weightCount.inc


  
