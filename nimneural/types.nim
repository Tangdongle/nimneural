from random import random, randomize
randomize()

#Nodes
type
  WeightObj = object
    value*: float64

  WeightRef = ref WeightObj

  NeuronObj = object
    numInputs*: int
    weights*: seq[WeightRef]

  NeuronRef = ref NeuronObj

  #Layers
  NeuronLayerObj = object
    numNeurons*: int
    neurons*: seq[NeuronRef]

  NeuronLayerRef = ref NeuronLayerObj

  #Metadata about the neural network
  NeuralNetMeta = tuple
    numInputs: int
    numOutputs: int
    numHiddenLayers: int
    numNeuronsPerHiddenLayer: int

  NeuralNetObj* = object
    meta*: NeuralNetMeta
    layers*: seq[NeuronLayerRef]

  NeuralNetRef = ref NeuralNetObj

#Operators

proc `$`*(weight: WeightRef): string = 
  $weight.value

## Weights 
proc newWeight*(value: float64): WeightRef = 
  #[
  # Creates a new Weight with a set value
  ]#
  new result
  result.value = value

proc newWeight*(): WeightRef = 
  #[
  # Creates a new Weight with a random value (0.0 <= x <= 1.0
  ]#
  new result
  result.value = random(1.0)

## Neurons

proc newNeuron*(numInputs: int): NeuronRef = 
  #[
  # Creates a new neuron with a number of weights where len(weights) = len(numInputs)
  ]#
  new result
  result.numInputs = numInputs
  result.weights = newSeq[WeightRef](numInputs)

  for i in 0 .. <numInputs:
    result.weights[i] = newWeight()

  #Add a weight that will act as the threshold
  result.weights.add(newWeight())

proc newNeuronLayer*(numNeurons, numInputsPerNeuron: int): NeuronLayerRef = 
  new result
  result.numNeurons = numNeurons
  result.neurons = newSeq[NeuronRef](numNeurons)

  for i in 0 .. <numNeurons:
    result.neurons[i] = newNeuron(numInputsPerNeuron)

proc newNeuralNetMeta*(numInputs, numOutputs, numHiddenLayers, numNeuronsPerHiddenLayer: int = 0): NeuralNetMeta = 
  result.numInputs = numInputs
  result.numOutputs = numOutputs
  result.numHiddenLayers = numHiddenLayers
  result.numNeuronsPerHiddenLayer = numNeuronsPerHiddenLayer

  echo result.numInputs
  echo result.numOutputs
  echo result.numHiddenLayers
  echo result.numNeuronsPerHiddenLayer

proc newNeuralNet*(): NeuralNetRef = 
  new(result)
  result.meta = (0,0,0,0)
  result.layers = @[]

proc newNeuralNet*(meta: NeuralNetMeta): NeuralNetRef = 
  new(result)
  result.meta = meta
  result.layers = @[]
