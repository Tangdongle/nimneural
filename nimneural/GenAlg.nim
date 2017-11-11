include types
from strutils import `%`
from algorithm import sorted
from config import loadConfig

proc newGenAlg*(popSize, numWeights: int, mutationRate, crossoverRate: float): GenAlgRef = 
  new(result)

  result.popSize = popSize
  result.chromoLength = numWeights
  result.mutationRate = mutationRate
  result.totalFitness = 0
  result.generationCounter = 0
  result.fittestGenome = 0
  result.bestFitness = 0
  result.worstFitness = 999999
  result.averageFitness = 0
  result.population = newSeq[GenomeRef](popSize)

  #Populate our genomes
  for i in 0 ..< result.popSize:
    result.population[i] = newGenome()

    #populate each genome's chromosomes
    for j in 0 .. result.chromoLength:
      result.population[i].weights.add(newWeight())

proc mutate(alg: var GenAlgRef, chromo: var seq[WeightRef]) {.discardable.} =
  let config = loadConfig()

  for weight in chromo:
    if random(1.0) > alg.mutationRate:
      weight.value += random(-1.0 .. 1.0) * config.dMaxPerturbation

proc getChromoRoulette(alg: GenAlgRef): GenomeRef = 
  new(result)

  var randomFitness = random(0.0 .. alg.totalFitness)
  var fitnessSoFar = 0.0

  for ix, popItem in alg.population.pairs():
    fitnessSoFar += popItem.fitness

    if fitnessSoFar >= randomFitness:
      result.fitness = popItem.fitness
      result.weights = @[]
      for w in popItem.weights:
        result.weights.add(w)
        return result

proc crossover(alg: GenAlgRef, mum, dad: seq[WeightRef]): (seq[WeightRef], seq[WeightRef]) =
  if random(0.0 .. 1.0) > alg.crossoverRate or mum == dad:
    result = (mum, dad)
    return 


  #determine a crossover point
  var cp: int = random(0 ..< alg.chromoLength)

  var baby1, baby2 = newSeq[WeightRef](cp)

  for i in 0 ..< cp:
    baby1[i].deepCopy(mum[i])
    baby2[i].deepCopy(dad[i])

  for i in cp ..< mum.len:
    baby1[i].deepCopy(dad[i])
    baby2[i].deepCopy(mum[i])

  echo "Baby1: $1 | Baby2: $2" % [$baby1.len, $baby2.len]

  return (baby1, baby2)


proc calculateBestWorstAvgTotal(alg: GenAlgRef): GenAlgRef =
  result.deepCopy(alg)

  result.totalFitness = 0
  var highest, lowest: float64

  for ix, popItem in result.population.pairs():
    if popItem.fitness > highest:
      highest = popItem.fitness
      result.fittestGenome = ix
      result.bestFitness = highest

    if popItem.fitness < lowest:
      lowest = popItem.fitness
      result.worstFitness = lowest

    result.totalFitness += popItem.fitness

  result.averageFitness = result.totalFitness / float(result.population.len)

proc getNBest(alg: GenAlgRef, nBest, nCopies: int): seq[GenomeRef] =
  for i in nBest .. 0:
    for j in 0 .. nCopies:
      result.add(alg.population[(alg.population.len - 1) - nBest])

proc resetGeneration(alg: GenAlgRef): GenAlgRef = 
  result.deepCopy(alg)

  result.totalFitness = 0
  result.bestFitness = 0
  result.worstFitness = 999999
  result.averageFitness = 0

proc epoch*(alg: GenAlgRef, oldPop: seq[GenomeRef]): seq[GenomeRef] =
  let config = loadConfig()
  #
  #Create a copy of our Genetic Algorithm object
  var genAlg: GenAlgRef = new(GenAlgRef)
  genAlg.deepCopy(alg)

  genAlg.population = oldPop

  genAlg = genAlg.resetGeneration()
  
  genAlg.population = genAlg.population.sorted do (x, y: GenomeRef) -> int:
    return cmp(x, y)

  genAlg = genAlg.calculateBestWorstAvgTotal()
  
  #Make every second genome an elite mofo
  if (config.NumEliteCopies * config.NumElite) mod 2 == 0:
    result = genAlg.getNBest(config.NumElite, config.NumEliteCopies)

  while result.len < genAlg.popSize:
    let mum = genAlg.getChromoRoulette()
    let dad = genAlg.getChromoRoulette()

    var (baby1, baby2) = genAlg.crossover(mum.weights, dad.weights)

    genAlg.mutate(baby1)
    genAlg.mutate(baby2)

    #let g1 = newGenome(fitness=0.0, weights=baby1)
    var g1 = newGenome()
    echo g1.fitness

    result.add(g1)
    #result.add(newGenome(fitness=0.0, weights=baby2))

