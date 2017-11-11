import random
import logging

type Config* = object
  dBias*: int
  dActivationResponse*: int
  dMaxPerturbation*: float
  NumInputs*: int
  NumHidden*: int
  NeuronsPerHiddenLayer*: int
  NumOutputs*: int
  MutationRate*: float
  CrossoverRate*: float
  NumEliteCopies*: int
  NumElite*: int

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

  GenomeObj = object
    weights*: seq[WeightRef]
    fitness*: float64

  GenomeRef = ref GenomeObj

  GenAlgObj = object
    population*: seq[GenomeRef]
    popSize: int
    chromoLength: int
    totalFitness: float64
    bestFitness: float64
    averageFitness: float64
    worstFitness: float64
    fittestGenome: int
    mutationRate: float
    crossoverRate: float
    generationCounter: int

  GenAlgRef = ref GenAlgObj

#Operators

proc `<`*(lhs, rhs: GenomeRef): bool = 
  lhs.fitness < rhs.fitness

proc `$`*(genome: GenomeRef): string = 
  $genome.fitness

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
  result.value = random(-1.0 .. 1.0)

## Neurons

proc newNeuron*(numInputs: int): NeuronRef = 
  #[
  # Creates a new neuron with a number of weights where len(weights) = len(numInputs)
  ]#
  new result
  result.numInputs = numInputs
  result.weights = newSeq[WeightRef](numInputs)

  for i in 0 ..< numInputs:
    result.weights[i] = newWeight()

  #Add a weight that will act as the threshold
  result.weights.add(newWeight())

proc newNeuronLayer*(numNeurons, numInputsPerNeuron: int): NeuronLayerRef = 
  new result
  result.numNeurons = numNeurons
  result.neurons = newSeq[NeuronRef](numNeurons)

  for i in 0 ..< numNeurons:
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

proc newGenome*(): GenomeRef = 
  new(result)
  result.weights = @[]
  result.fitness = 0.0

proc newGenome*(fitness: float64): GenomeRef = 
  new(result)
  result.weights = @[]
  result.fitness = fitness

proc newGenome*(fitness: float64, weights: openarray[float64]): GenomeRef = 
  #[
  # New Genome buitl with an array of float values
  ]#
  new(result)
  result.fitness = fitness
  for weight in weights:
    result.weights.add(newWeight(weight))

proc newGenome*(fitness: float64, weights: openarray[WeightRef]): GenomeRef = 
  #[
  # New Genome buitl with an array of WeightRefs
  ]#
  new(result)
  result.fitness = fitness
