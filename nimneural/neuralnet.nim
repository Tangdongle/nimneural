from strutils import `%`
from math import exp

from config import loadConfig
include types

#Forward declarations
proc sigmoid(netInput, response: float64): float64

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
  for i in 0 ..< net.meta.numHiddenLayers:
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
        result.layers[ix].neurons[jx].weights[zx] = newWeight(weights[weightCount])
        weightCount.inc


proc updateInputs(net: NeuralNetRef, inputs: openarray[float64]): seq[float64] =
  
  let config = loadConfig()
  var cWeight, numInputs: int
  var netInput: float64

  let bias = config.dBias
  let activationResponse = config.dActivationResponse

  if inputs.len != net.meta.numInputs:
    return result

  #For each neuron, sum the (input * weights) Send this
  # to our sigmoid function to get the output
  for ix, outer_neuron_layer in net.layers.pairs():
    cWeight = 0

    for jx, neuron in outer_neuron_layer.neurons.pairs(): 
      netInput = 0
      numInputs = neuron.numInputs

      for k in 0 ..< numInputs:
        netInput += neuron.weights[k].value * inputs[cWeight]
        cWeight.inc

      netInput += neuron.weights[numInputs - 1].value * float(bias)

      result.add(sigmoid(netInput, float(activationResponse)))

      cWeight = 0

proc sigmoid(netInput, response: float64): float64 = 
  1 / (1 + exp(-netInput / response))
